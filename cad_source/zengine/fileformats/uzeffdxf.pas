{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
unit uzeffdxf;
{$INCLUDE zengineconfig.inc}
{$MODE delphi}{$H+}
interface
uses
  uzbpaths,uzbstrproc,uzgldrawcontext,usimplegenerics,uzestylesdim,uzeentityfactory,
  {$IFNDEF DELPHI}LazUTF8,{$ENDIF}uzbUnits,
  UGDBNamedObjectsArray,uzestyleslinetypes,uzedrawingsimple,uzelongprocesssupport,
  gzctnrVectorTypes,uzglviewareadata,uzeffdxfsupport,uzestrconsts,uzestylestexts,
  uzegeometry,uzeentsubordinated,uzeentgenericsubentry,uzeTypes,
  uzegeometrytypes,sysutils,uzeconsts,UGDBObjBlockdefArray,
  uzctnrVectorBytesStream,UGDBVisibleOpenArray,uzeentity,uzeblockdef,uzestyleslayers,
  uzeffmanager,uzbLogIntf,uzeLogIntf,
  uzMVSMemoryMappedFile,uzMVReader,uzbBaseUtils,uzclog;

resourcestring
  rsLoadDXFFile='Load DXF file';

type
  TCreateExtLoadData=function:pointer;
  TProcessExtLoadData=procedure(peld:pointer);
  DXFEntDesc=record
    UCASEEntName:String;
  end;
  TLongProcessIndicator=Procedure(a:integer) of object;

const
  IgnoredDXFEntsArray:array of DXFEntDesc=[
    //(UCASEEntName:'HATCH'),
    (UCASEEntName:'ACAD_PROXY_ENTITY')
  ];

var
  CreateExtLoadData:TCreateExtLoadData=nil;
  ClearExtLoadData:TProcessExtLoadData=nil;
  FreeExtLoadData:TProcessExtLoadData=nil;

function AddFromDXF(const AFileName: String;var dwgCtx:TZDrawingContext;const LogIntf:TZELogProc=nil):TDXFHeaderInfo;

implementation

function IsIgnoredEntity(const name:String):Integer;
var
  i:Integer;
  uname:String;
begin
  uname:=uppercase(name);
  for i:=low(IgnoredDXFEntsArray) to high(IgnoredDXFEntsArray) do
    if IgnoredDXFEntsArray[i].UCASEEntName=uname then
      exit(i);
  result:=-1;
end;

{ Ищет информацию о сущности по DXF-имени.
  Если сущность зарегистрирована — возвращает её EntInfoData.
  Если сущность неизвестна, но не в списке игнорируемых — считает её кастомной
  proxy-сущностью и возвращает EntInfoData прокси-класса (GDBObjAcdProxy).
  Это обеспечивает отображение кастомных объектов (например, SPDSPOLYMORPHMARK)
  в виде ограничивающей рамки вместо их полного игнорирования.
  Возвращает False только если сущность в списке игнорируемых или прокси не зарегистрирован. }
function FindOrProxyEntInfo(const name:String; var EntInfoData:TEntInfoData):Boolean;
begin
  { Сначала ищем сущность в реестре зарегистрированных DXF-сущностей }
  if DXFName2EntInfoData.MyGetValue(name, EntInfoData) then begin
    Result := True;
    Exit;
  end;
  { Сущность не зарегистрирована — проверяем, не в списке ли она игнорируемых }
  if IsIgnoredEntity(name) >= 0 then begin
    Result := False;
    Exit;
  end;
  { Кастомная неизвестная сущность: загружаем как proxy-объект }
  if ObjID2EntInfoData.MyGetValue(GDBAcdProxyID, EntInfoData) then begin
    programlog.LogOutFormatStr(
      'uzeffdxf: unknown entity "%s" treated as proxy', [name], LM_Info);
    Result := True;
  end else
    Result := False;
end;
procedure gotodxf(var rdr:TZMemReader; fcode: Integer; const fname: String);
var
  byt: Byte;
  s: String;
  //error: Integer;
begin
  if fname<>'' then begin
    while not rdr.EOF do begin
      byt:=rdr.ParseInteger;
      //s := rdr.ParseString;
      //val(s, byt, error);
      //if error <> 0 then
      //  s := s{чето тут не так};
      s := rdr.ParseString;
      if (byt = fcode) and (s = fname) then
        exit;
    end;
  end else begin
    while not rdr.EOF do begin
      byt:=rdr.ParseInteger;
      //s := rdr.ParseString;
      //val(s, byt, error);
      //if error <> 0 then
      //  s := s{чето тут не так};
      if (byt = fcode) then
        exit;
      //s:=rdr.ParseString;
      rdr.SkipString;
    end;
  end;
end;
procedure readvariables(var drawing:TSimpleDrawing;var rdr:TZMemReader;var ctstyle:String; var clayer:String;var cltype:String;var cdimstyle:String;LoadMode:TLoadOpt;DWGVarsDict:TString2StringDictionary);
var
  s: String;
begin
  if LoadMode=TLOLoad then  begin
    DWGVarsDict.mygetvalue('$CLAYER',clayer);
    DWGVarsDict.mygetvalue('$TEXTSTYLE',ctstyle);
    DWGVarsDict.mygetvalue('$DIMSTYLE',cdimstyle);
    DWGVarsDict.mygetvalue('$CELTYPE',cltype);
    if DWGVarsDict.mygetvalue('$CELWEIGHT',s) then
      drawing.CurrentLineW:=strtoint(s);
    if DWGVarsDict.mygetvalue('$LWDISPLAY',s) then
      case strtoint(s) of
        1:drawing.LWDisplay:=true;
        0:drawing.LWDisplay:=false;
      end;
    if DWGVarsDict.mygetvalue('$LTSCALE',s) then
      drawing.LTScale:=strtofloat(s);
    if DWGVarsDict.mygetvalue('$CELTSCALE',s) then
      drawing.CLTScale:=strtofloat(s);
    if DWGVarsDict.mygetvalue('$CECOLOR',s) then
      drawing.CColor:=strtoint(s);
    if DWGVarsDict.mygetvalue('$LUNITS',s) then
      drawing.LUnits:=TLUnits(strtoint(s)-1);
    if DWGVarsDict.mygetvalue('$LUPREC',s) then
      drawing.LUPrec:=TUPrec(strtoint(s));
    if DWGVarsDict.mygetvalue('$AUNITS',s) then
      drawing.AUnits:=TAUnits(strtoint(s));
    if DWGVarsDict.mygetvalue('$AUPREC',s) then
      drawing.AUPrec:=TUPrec(strtoint(s));
    if DWGVarsDict.mygetvalue('$ANGDIR',s) then
      drawing.AngDir:=TAngDir(strtoint(s));
    if DWGVarsDict.mygetvalue('$ANGBASE',s) then
      drawing.AngBase:=strtofloat(s);
    if DWGVarsDict.mygetvalue('$UNITMODE',s) then
      drawing.UnitMode:=TUnitMode(strtoint(s));
    if DWGVarsDict.mygetvalue('$INSUNITS',s) then
      drawing.InsUnits:=TInsUnits(strtoint(s));
    if DWGVarsDict.mygetvalue('$TEXTSIZE',s) then
      drawing.TextSize:=strtofloat(s);
  end;
end;
function ReadDXFHeader(var rdr:TZMemReader;var fileCtx:TIODXFLoadContext):boolean;
type
  TDXFHeaderMode=(TDXFHMWaitSection,TDXFHMSection,TDXFHMHeader);
const
  maxlines=9;
var
  group,i,vers: integer;
  s,varname: String;
  varcount: Integer;
  ParseMode:TDXFHeaderMode;
  valuesarray:array[0..maxlines]of string;
  currentindex,maxindex:integer;
  ACVERSION,DWGCODEPAGE:boolean;

  function VarStr2Int(APrefiX,AValue:string):integer;
  var
    i,d:integer;
  begin
    Result:=VarValueWrong;
    if length(APrefiX)>=length(AValue)then
      exit;
    for i:=1 to length(APrefiX) do
      if APrefiX[i]<>uppercase(AValue[i])then
        exit;
    d:=1;
    for i:=length(AValue) downto length(APrefiX)+1 do begin
      if (AValue[i]>='0')and(AValue[i]<='9')then begin
        Result:=Result+(ord(AValue[i])-ord('0'))*d;
        d:=d*10;
      end else
        exit(VarValueWrong);
    end;
  end;

  procedure storevariable;
  begin
    case currentindex of
      //https://github.com/zamtmn/zcad/issues/207
      //$DIMASSOC почемуто дублируется в in.dxf
      //поэтому add->AddOrSetValue
      0:fileCtx.DWGVarsDict.AddOrSetValue(varname,valuesarray[0]);
      1:fileCtx.DWGVarsDict.AddOrSetValue(varname,valuesarray[0]+'|'+valuesarray[1]);
      else fileCtx.DWGVarsDict.AddOrSetValue(varname,valuesarray[0]+'|'+valuesarray[1]+'|'+valuesarray[2]);
    end;

    if not ACVERSION then
      if varname=dxfVar_ACADVER then begin
        fileCtx.Header.iVersion:=VarStr2Int('AC',valuesarray[0]);
        fileCtx.Header.Version:=ACVer2DXF_ACVer(fileCtx.Header.iVersion);
        ACVERSION:=true;
      end;

    if not DWGCODEPAGE then
      if varname=dxfVar_DWGCODEPAGE then begin
        fileCtx.Header.iDWGCodePage:=VarStr2Int('ANSI_',valuesarray[0]);
        fileCtx.Header.DWGCodePage:=SysCP2ACCP(fileCtx.Header.iDWGCodePage);
        DWGCODEPAGE:=true;
      end;

    currentindex:=-1;
  end;

  procedure processvalue(const group:integer;const value:String);
  begin
    inc(currentindex);
    if currentindex>maxindex then
      maxindex:=currentindex;
    valuesarray[currentindex]:={dxfDeCodeString}(value{,fileCtx.Header});
  end;

  procedure freearrays;
  var
    i:integer;
  begin
    for i:=0 to maxindex do
      valuesarray[i]:='';
  end;

begin
  result:=false;
  ACVERSION:=false;
  DWGCODEPAGE:=false;
  fileCtx.Header.DWGCodePage:=ZCCodePage2ACDWGCodePage(sysvarSysDWG_CodePage);
  fileCtx.Header.iDWGCodePage:=ZCCodePage2SysCP(sysvarSysDWG_CodePage);
  fileCtx.Header.Version:=AC1009;
  fileCtx.Header.iVersion:=1009;

  ParseMode:=TDXFHMWaitSection;
  varcount:=0;
  currentindex:=-1;
  maxindex:=currentindex;
  try
    while not rdr.EOF do begin
      group:=rdr.ParseInteger;
      s:=rdr.ParseString;
      s:=dxfDeCodeString(s,fileCtx.Header);
      if group<>999 then begin
        case ParseMode of
          TDXFHMWaitSection:begin
            if uppercase(s)=dxfName_SECTION then begin
              ParseMode:=TDXFHMSection;
            end else begin
              zDebugLn('{W}ReadDXFHeader:No header found');
              exit;
            end;
          end;
          TDXFHMSection:begin
            if uppercase(s)=dxfName_HEADER then begin
              ParseMode:=TDXFHMHeader;
              result:=true;
            end else begin
              zDebugLn('{W}ReadDXFHeader:No header found');
              exit;
            end;
          end;
          TDXFHMHeader:begin
            if group=0 then
              if uppercase(s)=dxfName_ENDSEC then begin
                if varcount>0 then
                  storevariable;
                exit;
              end;
            if group=9 then begin
              if varcount>0 then
                storevariable;
              varname:=s;
              inc(varcount);
            end else begin
              processvalue(group,s);
            end
          end;
        end;{case}
      end else
        zDebugLn('{IH}Found dxf comment "%s"',[s]);
      end;
  finally
    freearrays;
    if not ACVERSION then
      fileCtx.Header.iVersion:=VarValueWrong;
    if not DWGCODEPAGE then
      fileCtx.Header.iDWGCodePage:=VarValueWrong;
   end;
end;

function GoToDXForENDTAB(var rdr:TZMemReader; fcode: Integer; const fname: String):boolean;
var
  byt:Byte;
  s:String;
begin
  result:=false;
  while not rdr.EOF do begin
    byt:=rdr.ParseInteger;
    s:=rdr.ParseString;
    if(byt=fcode)and(s=fname)then
      exit(true);
    if(byt=0)and(uppercase(s)=dxfName_ENDTAB) then
      exit;
  end;
end;
procedure addentitiesfromdxf(var rdr:TZMemReader; const exitString: String;owner:PGDBObjSubordinated;var drawing:TSimpleDrawing;DC:TDrawContext;var context:TIODXFLoadContext);
var
  s: String;
  group:integer;
  objid: Integer;
  pobj,postobj: PGDBObjEntity;
  newowner:PGDBObjSubordinated;
  m4:TzeTypedMatrix4d;
  trash:boolean;
  PExtLoadData:Pointer;
  EntInfoData:TEntInfoData;
  bylayerlt:Pointer;
  lph:TLPSHandle;
begin
  s:='';
  lph:=lps.StartLongProcess('addentitiesfromdxf',@rdr,rdr.Size);
  if Assigned(CreateExtLoadData) then
    PExtLoadData:=CreateExtLoadData()
  else
    PExtLoadData:=nil;
  group:=-1;
  bylayerlt:=drawing.LTypeStyleTable.getAddres('ByLayer');
  while (not rdr.EOF) and (s <> exitString) do begin
    lps.ProgressLongProcess(lph,rdr.CurrentPos);
    s := rdr.ParseString;
    //if (group=0)and(DXFName2EntInfoData.MyGetValue(s,EntInfoData)) then begin
    { exitString (например ENDBLK, ENDSEC) — структурный маркер DXF, не сущность.
      Его не нужно ни загружать, ни пропускать через gotodxf — цикл завершится сам. }
    if (group=0)and(s <> exitString)and(FindOrProxyEntInfo(s,EntInfoData)) then begin
    if owner <> nil then begin
      zTraceLn('{D+}[DXF_CONTENTS]AddEntitiesFromDXF.Found primitive %s',[s]);
      pobj := EntInfoData.AllocAndInitEntity(nil);
      PGDBObjEntity(pobj)^.LoadFromDXF(rdr,PExtLoadData,drawing,context);
      if (PGDBObjEntity(pobj)^.vp.Layer=@DefaultErrorLayer)or(PGDBObjEntity(pobj)^.vp.Layer=nil) then
        PGDBObjEntity(pobj)^.vp.Layer:=drawing.LayerTable.GetSystemLayer;
      if (PGDBObjEntity(pobj)^.vp.LineType=nil) then
        PGDBObjEntity(pobj)^.vp.LineType:=bylayerlt;
      if assigned(PGDBObjEntity(pobj)^.EntExtensions) then
        PGDBObjEntity(pobj)^.EntExtensions.RunSupportOldVersions(pobj,drawing);
      pointer(postobj):=PGDBObjEntity(pobj)^.FromDXFPostProcessBeforeAdd(PExtLoadData,drawing);
      trash:=false;
      if postobj=nil  then begin
        newowner:=owner;
        if PGDBObjEntity(pobj)^.PExtAttrib<>nil then begin
          if PGDBObjEntity(pobj)^.PExtAttrib^.Handle>200 then begin
            context.h2p.Add(PGDBObjEntity(pobj)^.PExtAttrib^.Handle,TDXFHandle2ZCObject.TPointerWithType.CreateRec(pobj,OT_Entity));
            context.h2p.Add(PGDBObjEntity(pobj)^.PExtAttrib^.dwgHandle,TDXFHandle2ZCObject.TPointerWithType.CreateRec(pobj,OT_Entity));
          end;
          if PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle>200 then
            newowner:=context.h2p.MyGetValue(PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle).p;

          if newowner<>nil then
            case newowner.DXFLoadTryMi(PExtLoadData,pobj) of
              TR_NeedTrash:begin
                postobj:=nil;
                trash:=true;
              end;
              TR_Nothing:begin
                pointer(postobj):=PGDBObjEntity(pobj)^.FromDXFPostProcessBeforeAdd(PExtLoadData,drawing);
                trash:=false;
              end;
          end;

          if PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle=h_trash then
            trash:=true;
        end;
        if newowner=nil then begin
          zDebugLn('{EH}Warning! OwnerHandle $'+inttohex(PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle,8)+' not found');
          newowner:=owner;
        end;
        if not trash then begin
          if (newowner<>owner) then begin
            PGDBObjEntity(newowner)^.CalcObjMatrix(@drawing);
            m4:=PGDBObjEntity(newowner)^.getmatrix^;
            MatrixInvert(m4);
            pobj^.CalcObjMatrix(@drawing);
            pobj^.transform(m4);
          end else
            pobj^.CalcObjMatrix(@drawing);
        end;
        if not trash then begin
          newowner^.DXFLoadAddMi(pobj);
        if not(IsObjectIt(TypeOf(owner^),TypeOf(GDBObjBlockdef))) then begin
          if PGDBObjEntity(pobj)^.DXFDelayedBuildGeometry then begin
            {PGDBObjEntity(pobj)^.BuildGeometry(drawing);
            PGDBObjEntity(pobj)^.FormatAfterDXFLoad(drawing,dc);
            PGDBObjEntity(pobj)^.FromDXFPostProcessAfterAdd;}
          end else begin
            PGDBObjEntity(pobj)^.BuildGeometry(drawing);
            PGDBObjEntity(pobj)^.FormatAfterDXFLoad(drawing,dc);
            PGDBObjEntity(pobj)^.FromDXFPostProcessAfterAdd;
          end
        end;
        end else begin
          pobj^.done;
          Freemem(pointer(pobj));
        end;
      end else begin
        newowner:=owner;
        if PGDBObjEntity(pobj)^.PExtAttrib<>nil then begin
          postobj^.PExtAttrib:=pobj^.CopyExtAttrib;
        if PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle>200 then
          newowner:=context.h2p.MyGetValue(PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle).p;
        end;
        if newowner<>nil then begin
          if PGDBObjEntity(pobj)^.PExtAttrib<>nil then begin
            if PGDBObjEntity(pobj)^.PExtAttrib^.Handle>200 then
              context.h2p.AddOrSetValue(PGDBObjEntity(pobj)^.PExtAttrib^.Handle,TDXFHandle2ZCObject.TPointerWithType.CreateRec(postobj,OT_Entity));
            context.h2p.Add(PGDBObjEntity(pobj)^.PExtAttrib^.dwgHandle,TDXFHandle2ZCObject.TPointerWithType.CreateRec(postobj,OT_Entity));
          end;
          if newowner<>owner then begin
            m4:=PGDBObjEntity(newowner)^.getmatrix^;
            MatrixInvert(m4);
            postobj^.FormatEntity(drawing,dc,[EFCalcEntityCS]);
            postobj^.transform(m4);
          end;
          newowner^.AddMi(postobj);
          if assigned(pobj^.EntExtensions)then
            pobj^.EntExtensions.CopyAllExtToEnt(pobj,postobj);
          if not(IsObjectIt(TypeOf(owner^),TypeOf(GDBObjBlockdef))) then begin
            PGDBObjEntity(postobj)^.BuildGeometry(drawing);
            PGDBObjEntity(postobj)^.FormatAfterDXFLoad(drawing,dc);
            PGDBObjEntity(postobj)^.FromDXFPostProcessAfterAdd;
          end;
        end else begin
          postobj^.done;
          Freemem(pointer(postobj));
        end;
        pobj^.done;
        Freemem(pointer(pobj));
      end;
        zTraceLn('{D-}[DXF_CONTENTS]End primitive %s',[s]);
      end;
      if Assigned(ClearExtLoadData) then
        ClearExtLoadData(PExtLoadData);
    end else begin
      if (group=0)and(s <> exitString) then begin
        { FindOrProxyEntInfo вернул false: сущность в списке игнорируемых
          или прокси-класс не зарегистрирован — пропускаем до следующей сущности.
          exitString не пропускаем через gotodxf: данные после него должны остаться
          нетронутыми для корректного завершения загрузки блока. }
        gotodxf(rdr, 0, '');
      end else
        if trystrtoint(s,group)then else
          group:=-1;
    end;
  end;
  if Assigned(FreeExtLoadData) then
    FreeExtLoadData(PExtLoadData);
  owner.postload(context);
  lps.EndLongProcess(lph);
end;
procedure AddFromDXF12(var rdr:TZMemReader; const exitString: String;var ZCDCtx:TZDrawingContext;const LogProc:TZELogProc=nil);
var
  LayerColor: Integer;
  s, sname,scode,LayerName: String;
  ErrorCode,GroupCode: Integer;
  tp: PGDBObjBlockdef;
  context:TIODXFLoadContext;
  lph:TLPSHandle;
begin
  s:='';
  lph:=lps.StartLongProcess('addfromdxf12',@rdr,rdr.CurrentPos);
  zDebugLn('{D+}AddFromDXF12');
  context.InitRec;
  while (not rdr.EOF) and (s <> exitString) do begin
    lps.ProgressLongProcess(lph,rdr.CurrentPos);
    s := rdr.ParseString;
    if s = dxfName_Layer then begin
      zDebugLn('{D+}[DXF_CONTENTS]Found layer table');
      repeat
        scode := rdr.ParseString;
        sname := rdr.ParseString;
        val(scode,GroupCode,ErrorCode);
      until GroupCode=0;
      repeat
        if sname=dxfName_ENDTAB then system.break;
        if sname<>dxfName_Layer then zDebugLn('{FM}''LAYER'' expected but '''+sname+''' found');
        repeat
          scode := rdr.ParseString;
          sname := rdr.ParseString;
          val(scode,GroupCode,ErrorCode);
          case GroupCode of
            2:LayerName:=sname;
            62:val(sname,LayerColor,ErrorCode);
          end;{case}
        until GroupCode=0;
        zDebugLn('{D}[DXF_CONTENTS]Found layer '+LayerName);
        ZCDCtx.pdrawing^.LayerTable.addlayer(LayerName,LayerColor,-3,true,false,true,'',TLOLoad);
      until sname=dxfName_ENDTAB;
      zDebugLn('{D-}[DXF_CONTENTS]end; {layer table}');
    end else if s = 'BLOCKS' then begin
      zDebugLn('{D+}[DXF_CONTENTS]Found block table');
      sname := '';
      repeat
        if sname = '  2' then
          if (s = '$MODEL_SPACE') or (s = '$PAPER_SPACE') then
          begin
            while (s <> 'ENDBLK') do
              s := rdr.ParseString;
          end
          else
          begin
            tp := ZCDCtx.pdrawing^.BlockDefArray.create(s);
            zDebugLn('{D+}[DXF_CONTENTS]Found block '+s);
            addentitiesfromdxf(rdr, 'ENDBLK',tp,ZCDCtx.pdrawing^,ZCDCtx.dc,context);
            zDebugLn('{D-}[DXF_CONTENTS]end; {block}');
          end;
        sname := rdr.ParseString;
        s := rdr.ParseString;
      until (s = dxfName_ENDSEC);
      zDebugLn('{D-}end; {block table}');
    end else if s='ENTITIES' then begin
      zDebugLn('{D+}[DXF_CONTENTS]Found entities section');
      addentitiesfromdxf(rdr,dxf_EOF,ZCDCtx.powner,ZCDCtx.pdrawing^,ZCDCtx.dc,context);
      zDebugLn('{D-}[DXF_CONTENTS]end {entities section}');
    end;
  end;
  context.Done;
  lps.EndLongProcess(lph);
  zDebugLn('{D-}end; {AddFromDXF12}');
end;
procedure ReadLTStyles(var s:ansiString; const cltype:string;var rdr:TZMemReader; const exitString: String;var ZCDCtx:TZDrawingContext;var context:TIODXFLoadContext);
var
  pltypeprop:PGDBLtypeProp;
  byt: Integer;
  dashinfo:TDashInfo;
  shapenumber,stylehandle:TDWGHandle;
  PSP:PShapeProp;
  PTP:PTextProp;
  BShapeProp:BasicSHXDashProp;
  txtstr:string;
  TempDouble:Double;
  flags: Integer;
  DWGHandle:TDWGHandle;
  len:double;
begin
  DWGHandle:=0;
  dashinfo:=TDIDash;
  txtstr:='';
  len:=0;
  stylehandle:=0;
  BShapeProp.initnul;
  shapenumber:=0;

  if GoToDXForENDTAB(rdr, 0, dxfName_LType) then
    while s = dxfName_LType do begin
      pltypeprop:=nil;
      byt := 2;
      while byt <> 0 do
      begin
      byt:=rdr.ParseInteger;
      s:=rdr.ParseString;
      case byt of
        2:begin
          len:=0;
          s:=dxfDeCodeString(s,context.Header);
          case ZCDCtx.PDrawing^.LTypeStyleTable.AddItem(s,pointer(pltypeprop)) of
            IsFounded:begin
              context.h2p.Add(DWGHandle,TDXFHandle2ZCObject.TPointerWithType.CreateRec(pltypeprop,OT_LineType));
              if ZCDCtx.LoadMode=TLOLoad then begin
              end else
                pltypeprop:=nil;
            end;
            IsCreated:begin
              pltypeprop^.init(s);
              dashinfo:=TDIDash;
              context.h2p.Add(DWGHandle,TDXFHandle2ZCObject.TPointerWithType.CreateRec(pltypeprop,OT_LineType));
            end;
            IsError:begin
            end;
          end;
          if ZCDCtx.PDrawing^.CurrentLType=nil then
            ZCDCtx.PDrawing^.CurrentLType:=pltypeprop
          else if uppercase(s)=uppercase(cltype)then
            ZCDCtx.PDrawing^.CurrentLType:=pltypeprop;
         end;
        3:begin
           s:=dxfDeCodeString(s,context.Header);
              if pltypeprop<>nil then
                                pltypeprop^.desk:=s;
        end;
        5:begin
              DWGHandle:=strtoint64('$'+s)
        end;
        40:begin
              if pltypeprop<>nil then
              pltypeprop^.LengthDXF:=strtofloat(s);
        end;
        49:begin
          if pltypeprop<>nil then begin
            case dashinfo of
              TDIShape:begin
                if stylehandle<>0 then begin
                  pointer(psp):=pltypeprop^.shapearray.CreateObject;
                  psp^.initnul;
                  psp^.param:=BShapeProp.param;
                  psp^.Psymbol:=nil;
                  psp^.ShapeNum:=shapenumber;
                  psp^.param.PStyle:=pointer(stylehandle);
                  psp^.param.PstyleIsHandle:=true;
                  pltypeprop^.dasharray.PushBackData(dashinfo);
                end;
              end;
              TDIText:begin
                pointer(ptp):=pltypeprop^.Textarray.CreateObject;
                ptp^.initnul;
                ptp^.param:=BShapeProp.param;
                ptp^.Text:=txtstr;
                ptp^.param.PStyle:=pointer(stylehandle);
                ptp^.param.PstyleIsHandle:=true;
                pltypeprop^.dasharray.PushBackData(dashinfo);
              end;
              { #todo : сменить case на if }
              TDIDash:;//заглушка на варнинг
            end;
            dashinfo:=TDIDash;
            TempDouble:=strtofloat(s);
            pltypeprop^.dasharray.PushBackData(dashinfo);
            pltypeprop^.strokesarray.PushBackData(TempDouble);
            len:=len+abs(TempDouble);
            if TempDouble>eps then begin
              pltypeprop^.LastStroke:=TODILine;
              pltypeprop^.WithoutLines:=false;
            end else if TempDouble<-eps then
              pltypeprop^.LastStroke:=TODIBlank
            else pltypeprop^.LastStroke:=TODIPoint;
            if pltypeprop^.FirstStroke=TODIUnknown then
              pltypeprop^.FirstStroke:=pltypeprop^.LastStroke;
          end;
        end;
        74:
           if pltypeprop<>nil then begin
             flags:=strtoint(s);
             if (flags and 1)>0 then
               BShapeProp.param.AD:={BShapeProp.param.AD.}TACAbs
             else
               BShapeProp.param.AD:={BShapeProp.param.AD.}TACRel;
             if (flags and 2)>0 then
               dashinfo:=TDIText;
             if (flags and 4)>0 then
               dashinfo:=TDIShape;
           end;
        75:begin
          shapenumber:=strtoint(s);//
        end;
        340:begin
          if pltypeprop<>nil then
            stylehandle:=strtoint64('$'+s);
        end;
        46:begin
          BShapeProp.param.Height:=strtofloat(s);
        end;
      50:begin
        BShapeProp.param.Angle:=strtofloat(s);
      end;
      44:begin
        BShapeProp.param.X:=strtofloat(s);
      end;
      45:begin
        BShapeProp.param.Y:=strtofloat(s);
      end;
      9:begin
          if pltypeprop<>nil then
            txtstr:=s;
      end;
       end;
       end;
      if assigned(pltypeprop) then
        pltypeprop^.strokesarray.LengthFact:=len;
    end;
  BShapeProp.Done;
end;
procedure ReadLayers(var s:ansistring; const clayer:string;var rdr:TZMemReader; const exitString: String;var ZCDCtx:TZDrawingContext;var context:TIODXFLoadContext);
var
byt: Integer;
lname,desk: String;
nulisread:boolean;
player:PGDBLayerProp;
begin
  nulisread:=false;
  gotodxf(rdr, 0, dxfName_Layer);
  player:=nil;
  while s = dxfName_Layer do
  begin
    byt := 2;
    while byt <> 0 do
    begin
      if not nulisread then begin
        byt:=rdr.ParseInteger;
        s := rdr.ParseString;
      end else
        nulisread:=false;
      case byt of
        2:begin
          zDebugLn('{D}[DXF_CONTENTS]Found layer  '+s);
          s:=dxfDeCodeString(s,context.Header);
          lname:=s;
          player:=ZCDCtx.PDrawing^.LayerTable.MergeItem(s,ZCDCtx.LoadMode);
          if player<>nil then
            player^.init(s);
        end;
        6:if player<>nil then
          player^.LT:=ZCDCtx.PDrawing^.LTypeStyleTable.getAddres(dxfDeCodeString(s,context.Header));
        1001:begin
          if s='AcAecLayerStandard' then begin
            s := rdr.ParseString;
            byt:=strtoint(s);
            if byt<>0 then begin
              s := rdr.ParseString;
              s := rdr.ParseString;
              byt:=strtoint(s);
              if byt<>0 then begin
                dxfLoadString(rdr,desk,context.Header);
                //desk := rdr.ParseString;
                if player<>nil then
                  player^.desk:=desk;
              end else begin
                nulisread:=true;
                s:=rdr.ParseString;
              end;
            end else begin
                nulisread:=true;
                s := rdr.ParseString;
            end;
          end;
        end;
        else begin
          if player<>nil then
            player^.SetValueFromDxf(byt,s);
        end;
      end;
    end;
    if ZCDCtx.PDrawing^.CurrentLayer=nil then
      ZCDCtx.PDrawing^.CurrentLayer:=player
    else if lname=clayer then
      ZCDCtx.PDrawing^.CurrentLayer:=player;
  end;
end;
procedure ReadTextstyles(var s:ansistring; const ctstyle:string;var rdr:TZMemReader; const exitString: String;var ZCDCtx:TZDrawingContext;var context:TIODXFLoadContext;const LogProc:TZELogProc=nil);
var
  tstyle:GDBTextStyle;
  ptstyle:PGDBTextStyle;
  DWGHandle:TDWGHandle;
  byt: Integer;
  flags: Integer;
  FontFile,FontFamily: String;
  ti:PGDBTextStyle;
  pltypeprop:PGDBLtypeProp;
  ir,ir2:itrec;
  PSP:PShapeProp;
  PTP:PTextProp;
begin
  if GoToDXForENDTAB(rdr, 0, dxfName_Style) then
    while s = dxfName_Style do begin
      FontFile:='';
      FontFamily:='';
      tstyle.name:='';
      tstyle.pfont:=nil;
      tstyle.prop.oblique:=0;
      tstyle.prop.size:=1;
      DWGHandle:=0;

      byt := 2;

      while byt <> 0 do begin
        byt:=rdr.ParseInteger;
        case byt of
              2:dxfLoadString(rdr,tstyle.name,context.Header);//tstyle.name:=rdr.ParseString;
              5:DWGHandle:=rdr.ParseHexQWord;//strtoint64('$'+rdr.ParseString);
             40:tstyle.prop.size:=rdr.ParseDouble;
             41:tstyle.prop.wfactor:=rdr.ParseDouble;
             50:tstyle.prop.oblique:=rdr.ParseDouble*pi/180;
             70:flags:=rdr.ParseInteger;
              3:FontFile:=rdr.ParseString;
           1000:FontFamily:=rdr.ParseString;
           else
             s := rdr.ParseString;
        end;
      end;
      ti:=nil;
      if (flags and 1)=0 then begin
        ti:=ZCDCtx.PDrawing^.TextStyleTable.FindStyle(tstyle.Name,false);
        if ti<>nil then begin
          if ZCDCtx.LoadMode=TLOLoad then
            ti:=ZCDCtx.PDrawing^.TextStyleTable.setstyle(tstyle.Name,FontFile,FontFamily,tstyle.prop,false);
        end else
          ti:=ZCDCtx.PDrawing^.TextStyleTable.addstyle(tstyle.Name,FontFile,FontFamily,tstyle.prop,false,LogProc);
      end else begin
        if ZCDCtx.PDrawing^.TextStyleTable.FindStyle(FontFile,true)<>nil then begin
          if ZCDCtx.LoadMode=TLOLoad then
            ti:=ZCDCtx.PDrawing^.TextStyleTable.setstyle(FontFile,FontFile,FontFamily,tstyle.prop,true);
        end else
          ti:=ZCDCtx.PDrawing^.TextStyleTable.addstyle(FontFile,FontFile,FontFamily,tstyle.prop,true);
      end;
      if ti<>nil then begin
        context.h2p.Add(DWGHandle,TDXFHandle2ZCObject.TPointerWithType.CreateRec(ti,OT_TextStyle));
        ptstyle:={drawing.TextStyleTable.getelement}(ti);
        pltypeprop:=ZCDCtx.PDrawing^.LTypeStyleTable.beginiterate(ir);
        if pltypeprop<>nil then
        repeat
          PSP:=pltypeprop^.shapearray.beginiterate(ir2);
          if PSP<>nil then
          repeat
            if psp^.param.PstyleIsHandle then
              if psp^.param.PStyle=pointer(DWGHandle) then begin
                psp^.param.PStyle:=ptstyle;
                psp^.FontName:=ptstyle^.FontFile;
                if assigned(ptstyle^.pfont) then begin
                  psp^.Psymbol:=ptstyle^.pfont^.GetOrReplaceSymbolInfo(integer(psp^.ShapeNum){//-ttf-//,tdinfo});
                  psp^.SymbolName:=psp^.Psymbol^.Name;
                end;
              end;
            PSP:=pltypeprop^.shapearray.iterate(ir2);
          until PSP=nil;

          PTP:=pltypeprop^.Textarray.beginiterate(ir2);
          if PTP<>nil then
          repeat
            if pTp^.param.PStyle=pointer(DWGHandle) then begin
              pTp^.param.PStyle:=ptstyle;
            end;
            PTP:=pltypeprop^.Textarray.iterate(ir2);
          until PTP=nil;
         pltypeprop:=ZCDCtx.PDrawing^.LTypeStyleTable.iterate(ir);
        until pltypeprop=nil;
    end;
    zDebugLn('{D}[DXF_CONTENTS]Found style  '+tstyle.Name);
    if ZCDCtx.PDrawing^.CurrentTextStyle=nil then
      ZCDCtx.PDrawing^.CurrentTextStyle:=ZCDCtx.PDrawing^.TextStyleTable.FindStyle(tstyle.Name,false)
    else if tstyle.Name=ctstyle then
      ZCDCtx.PDrawing^.CurrentTextStyle:=ZCDCtx.PDrawing^.TextStyleTable.FindStyle(tstyle.Name,false);
    tstyle.Name:='';
  end;
  ZCDCtx.PDrawing^.LTypeStyleTable.format;
end;
procedure ReadVport(var s:ansistring;var rdr:TZMemReader; const exitString: String;var ZCDCtx:TZDrawingContext;var context:TIODXFLoadContext);
var
   byt: Integer;
   active:boolean;
   flags: Integer;
begin
     zDebugLn('{D+}[DXF_CONTENTS]ReadVport');
     if GoToDXForENDTAB(rdr, 0, 'VPORT') then
     begin
       byt := -100;
       active:=false;

       while byt <> 0 do
       begin
         {s := rdr.ParseString;
         byt := strtoint(s);}
         byt:=rdr.ParseInteger;
         s := rdr.ParseString;
         if (byt=0)and(s='VPORT')then
         begin
               byt := -100;
               active:=false;
         end;
         case byt of
           2:
             begin
                  if uppercase(s)='*ACTIVE' then
                                                active:=true
                                            else
                                                active:=false;
             end;
           12:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  if ZCDCtx.PDrawing<>nil then
                  if ZCDCtx.PDrawing^.pcamera<>nil then
                  begin
                       ZCDCtx.PDrawing^.pcamera^.prop.point.x:=-strtofloat(s);
                  end;
              end;
           22:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  if ZCDCtx.PDrawing<>nil then
                  if ZCDCtx.PDrawing^.pcamera<>nil then
                  begin
                       ZCDCtx.PDrawing^.pcamera^.prop.point.y:=-strtofloat(s);
                  end;
              end;
           13:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  //if sysvar.DWG.DWG_Snap<>nil then
                  begin
                       ZCDCtx.PDrawing^.Snap.Base.x{sysvar.DWG.DWG_Snap^.Base.x}:=strtofloat(s);
                  end;
              end;
           23:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  //if sysvar.DWG.DWG_Snap<>nil then
                  begin
                       ZCDCtx.PDrawing^.Snap.Base.y{sysvar.DWG.DWG_Snap^.Base.y}:=strtofloat(s);
                  end;
              end;
           14:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  //if sysvar.DWG.DWG_Snap<>nil then
                  begin
                       ZCDCtx.PDrawing^.Snap.Spacing.x{sysvar.DWG.DWG_Snap^.Spacing.x}:=strtofloat(s);
                  end;
              end;
           24:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  //if sysvar.DWG.DWG_Snap<>nil then
                  begin
                       ZCDCtx.PDrawing^.Snap.Spacing.y{sysvar.DWG.DWG_Snap^.Spacing.y}:=strtofloat(s);
                  end;
              end;
           15:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  //if sysvar.DWG.DWG_GridSpacing<>nil then
                  begin
                       ZCDCtx.PDrawing^.GridSpacing.x{sysvar.DWG.DWG_GridSpacing^.x}:=strtofloat(s);
                  end;
              end;
           25:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  //if sysvar.DWG.DWG_GridSpacing<>nil then
                  begin
                       ZCDCtx.PDrawing^.GridSpacing.y{sysvar.DWG.DWG_GridSpacing^.y}:=strtofloat(s);
                  end;
              end;
           40:
             begin
               if ZCDCtx.LoadMode=TLOLoad then
                 if active then
                   if ZCDCtx.PDrawing<>nil then
                     if ZCDCtx.PDrawing^.pcamera<>nil then
                       if ZCDCtx.PDrawing^.wa<>nil then
                         if ZCDCtx.PDrawing^.wa.getviewcontrol<>nil then
                           ZCDCtx.PDrawing^.pcamera^.prop.zoom:=(strtofloat(s)/ZCDCtx.PDrawing^.wa.getviewcontrol.ClientHeight);
              end;
           41:
             begin
               if ZCDCtx.LoadMode=TLOLoad then
                 if active then
                   if ZCDCtx.PDrawing<>nil then
                     if ZCDCtx.PDrawing^.pcamera<>nil then
                       if ZCDCtx.PDrawing^.wa<>nil then
                         if ZCDCtx.PDrawing^.wa.getviewcontrol<>nil then
                           if ZCDCtx.PDrawing^.wa.getviewcontrol.ClientHeight*strtofloat(s)>ZCDCtx.PDrawing^.wa.getviewcontrol.ClientWidth then
                             ZCDCtx.PDrawing^.pcamera^.prop.zoom:=ZCDCtx.PDrawing^.pcamera^.prop.zoom*strtofloat(s)*ZCDCtx.PDrawing^.wa.getviewcontrol.ClientHeight/ZCDCtx.PDrawing^.wa.getviewcontrol.ClientWidth;
              end;
           71:
             begin
               if ZCDCtx.LoadMode=TLOLoad then
                 if active then
                   if ZCDCtx.PDrawing<>nil then
                     if ZCDCtx.PDrawing^.wa<>nil then
                       if ZCDCtx.PDrawing^.wa.getviewcontrol<>nil then begin
                         flags:=strtoint(s);
                         if (flags and 1)<>0 then
                           ZCDCtx.PDrawing^.wa.param.projtype:=PROJPerspective
                         else
                           ZCDCtx.PDrawing^.wa.param.projtype:=PROJParallel;
                       end;
             end;
           75:
             begin
                  if ZCDCtx.LoadMode=TLOLoad then
                  if active then
                  //if sysvar.DWG.DWG_SnapGrid<>nil then
                  begin
                       if s<>'0' then
                                     ZCDCtx.PDrawing^.SnapGrid{sysvar.DWG.DWG_SnapGrid^}:=true
                                 else
                                     ZCDCtx.PDrawing^.SnapGrid{sysvar.DWG.DWG_SnapGrid^}:=false;
                  end;
             end;
         76:
           begin
                if ZCDCtx.LoadMode=TLOLoad then
                if active then
                //if sysvar.DWG.DWG_DrawGrid<>nil then
                begin
                     if s<>'0' then
                                   ZCDCtx.PDrawing^.DrawGrid{sysvar.DWG.DWG_DrawGrid^}:=true
                               else
                                   ZCDCtx.PDrawing^.DrawGrid{sysvar.DWG.DWG_DrawGrid^}:=false;
                end;
            end;
       end;

     end;
     end;
     zDebugLn('{D-}[DXF_CONTENTS]end;{ReadVport}');
end;
procedure ReadDimStyles(var s:ansistring; const cdimstyle:string;var rdr:TZMemReader; const exitString: String;var ZCDCtx:TZDrawingContext;var context:TIODXFLoadContext);
var
  psimstyleprop:PGDBDimStyle;
  byt:integer;
  ReadDimStylesMode:TDimStyleReadMode;
begin
  if GoToDXForENDTAB(rdr, 0, dxfName_DIMSTYLE) then begin
    while s = dxfName_DIMSTYLE do begin
      psimstyleprop:=nil;
      ReadDimStylesMode:=TDSRM_ACAD;
      byt := 2;
      while byt <> 0 do begin
      {s := rdr.ParseString;
      byt := strtoint(s);}
      byt:=rdr.ParseInteger;
      //s := rdr.ParseString;
        if psimstyleprop=nil then begin
          if byt=2 then begin
            dxfLoadString(rdr,s,context.Header);
            psimstyleprop:=ZCDCtx.PDrawing^.DimStyleTable.MergeItem(s,ZCDCtx.LoadMode);
            if psimstyleprop<>nil then begin
              psimstyleprop^.init(s);
              psimstyleprop^.Name:=s;
            end;
            if ZCDCtx.PDrawing^.CurrentDimStyle=nil then
              ZCDCtx.PDrawing^.CurrentDimStyle:=psimstyleprop
            else if uppercase(s)=uppercase(cdimstyle)then
            if (ZCDCtx.LoadMode=TLOLoad) then
              ZCDCtx.PDrawing^.CurrentDimStyle:=psimstyleprop;
          end else
            s:=rdr.ParseString;
        end else begin
          s:=rdr.ParseString;
          psimstyleprop^.SetValueFromDxf(ReadDimStylesMode,byt,s,context);
        end
      end;
    end;
    if psimstyleprop<>nil then
      if psimstyleprop^.Text.DIMTXSTY=nil then
        psimstyleprop^.Text.DIMTXSTY:=ZCDCtx.PDrawing^.GetTextStyleTable^.FindStyle(TSNStandardStyleName,false);
  end;
end;
procedure ReadBlockRecord(const Handle2BlockName:TMapBlockHandle_BlockNames;var s:ansistring;var rdr:TZMemReader; const exitString: String;var ZCDCtx:TZDrawingContext;var context:TIODXFLoadContext);
var
   byt:integer;
   bname:string;
   bhandle:TDWGHandle;
begin
  bhandle:=0;
while s = dxfName_BLOCKRECORD do
begin
     byt := 2;
     while byt <> 0 do
     begin
     {s := rdr.ParseString;
     byt := strtoint(s);}
     byt:=rdr.ParseInteger;
     s := rdr.ParseString;
     if byt=2 then
                  begin
                       bname:= dxfDeCodeString(s,context.Header);
                       Handle2BlockName.{$IFDEF DELPHI}Add{$ENDIF}{$IFNDEF DELPHI}insert{$ENDIF}(bhandle,bname);
                  end;
     if byt=5 then
                  begin
                       bhandle:=DXFHandle(s);
                  end;
     end;
end;
end;

procedure AddFromDXF20XX(var rdr:TZMemReader; const exitString: String;var ZCDCtx:TZDrawingContext;var context:TIODXFLoadContext;const LogProc:TZELogProc=nil);
var
  byt,flag: Integer;
  error: Integer;
  US, sname: String;
  s:ansistring;
  tp: PGDBObjBlockdef;
  blockload:boolean;

  clayer,cdimstyle,cltype,ctstyle:String;
  Handle2BlockName:TMapBlockHandle_BlockNames;
  lph:TLPSHandle;
  SaveOptions:TDContextOptions;
begin
  ctstyle:='';
  clayer:='';
  cltype:='';
  cdimstyle:='';
  lph:=lps.StartLongProcess('addfromdxf2000',@rdr,rdr.CurrentPos);
  Handle2BlockName:=TMapBlockHandle_BlockNames.Create;
  blockload:=false;
  zDebugLn('{D+}[DXF_CONTENTS]AddFromDXF2000');
  //programlog.LogOutStr('AddFromDXF2000',lp_IncPos,LM_Debug);
  readvariables(ZCDCtx.PDrawing^,rdr,ctstyle,clayer,cltype,cdimstyle,ZCDCtx.LoadMode,context.DWGVarsDict);
  repeat
    gotodxf(rdr, 0, dxfName_SECTION);
    if rdr.EOF then
      system.break;
    s := rdr.ParseString;
    s := rdr.ParseString;
    if s = dxfName_TABLES then
    begin
      if rdr.EOF then
        system.break;
      s := rdr.ParseString;
      s := rdr.ParseString;
      while s = dxfName_TABLE do
      begin
        if rdr.EOF then
          system.break;
        s := rdr.ParseString;
        s := rdr.ParseString;

        //case (s) of
                    if s = dxfName_CLASSES{:}then
                                    gotodxf(rdr, 0, dxfName_ENDTAB)//scip this table
                    else if s = dxfName_APPID{:}then
                                    gotodxf(rdr, 0, dxfName_ENDTAB)//scip this table
               else if s = dxfName_BLOCK_RECORD{:}then
                                    begin
                                    zDebugLn('{D+}[DXF_CONTENTS]Found BLOCK_RECORD table');
                                    ReadBlockRecord(Handle2BlockName,s,rdr,exitString,ZCDCtx,context);
                                    zDebugLn('{D-}[DXF_CONTENTS]end; {BLOCK_RECORD table}');
                                    end
                   else if s = dxfName_DIMSTYLE{:}then
                                    begin
                                      zDebugLn('{D+}[DXF_CONTENTS]Found dimstyles table');
                                      ReadDimStyles(s,cdimstyle,rdr,exitString,ZCDCtx,context);
                                      zDebugLn('{D-}[DXF_CONTENTS]end; {dimstyles table}');
                                    end
                      else if s = dxfName_Layer{:}then
                                    begin
                                      zDebugLn('{D+}[DXF_CONTENTS]Found layer table');
                                      ReadLayers(s,clayer,rdr,exitString,ZCDCtx,context);
                                      zDebugLn('{D-}[DXF_CONTENTS]end; {layer table}');
                                    end
                      else if s = dxfName_LType{:}then
                                    begin
                                      zDebugLn('{D+}[DXF_CONTENTS]Found line types table');
                                      ReadLTStyles(s,cltype,rdr,exitString,ZCDCtx,context);
                                      zDebugLn('{D-}[DXF_CONTENTS]end; (line types table)');
                                    end
                      else if s = dxfName_Style{:}then
                                    begin
                                      zDebugLn('{D+}[DXF_CONTENTS]Found style table');
                                      ReadTextstyles(s,ctstyle,rdr,exitString,ZCDCtx,context,LogProc);
                                      zDebugLn('{D-}[DXF_CONTENTS]end; {style table}');
                                    end
                              else if s = 'UCS'{:}then
                                    gotodxf(rdr, 0, dxfName_ENDTAB)//scip this table
                             else if s = 'VIEW'{:}then
                                    gotodxf(rdr, 0, dxfName_ENDTAB)//scip this table
                            else if s = 'VPORT'{:}then
                                    begin
                                    zDebugLn('{D+}[DXF_CONTENTS]Found vports table');
                                    ReadVport(s,rdr,exitString,ZCDCtx,context);
                                    zDebugLn('{D-}[DXF_CONTENTS]end; {vports table}');
                                    end;
        //end;{case}
        s := rdr.ParseString;
        s := rdr.ParseString;
      end;

    end
    else
      if s = 'ENTITIES' then
      begin
        zDebugLn('{D+}[DXF_CONTENTS]Found entities section');
        addentitiesfromdxf(rdr, dxfName_ENDSEC,ZCDCtx.powner,ZCDCtx.pdrawing^,ZCDCtx.dc,context);
        ZCDCtx.powner^.ObjArray.pack;
        ZCDCtx.powner^.correctobjects(nil,0);
        zDebugLn('{D-}[DXF_CONTENTS]end; {entities section}');
      end
      else
        if s = 'BLOCKS' then
        begin
          zDebugLn('{D+}[DXF_CONTENTS]Found block table');
          //programlog.LogOutStr('Found block table',lp_IncPos,LM_Debug);
          sname := '';
          repeat
            US:=uppercase(s);
            if (sname = '  2') or (sname = '2') then
              if (pos('MODEL_SPACE',US)<>0)or(pos('PAPER_SPACE',US)<>0)or(pos('*A',US)=1)or(pos('*D',US)=1){or(pos('*U',US)=1)}then   //блоки *U игнорировать нестоит, что то связанное с параметризацией
              begin
                //programlog.logoutstr('Ignored block '+s+';',lp_OldPos);
                zDebugLn('{I}'+rsBlockIgnored,[s]);
                //HistoryOutStr(format(rsBlockIgnored,[s]));
                while (s <> 'ENDBLK') do
                  s := rdr.ParseString;
              end
              else if ZCDCtx.pdrawing^.BlockDefArray.getindex(s)>=0 then begin
                zDebugLn('{I}'+rsDoubleBlockIgnored,[{Tria_AnsiToUtf8}(s)]);
                while (s <> 'ENDBLK') do
                s := rdr.ParseString;
              end else begin
                tp := ZCDCtx.pdrawing^.BlockDefArray.create(s);
                zDebugLn('{D+}[DXF_CONTENTS]Found blockdef '+s);
                byt:=rdr.ParseInteger;
                if byt=70 then
                  flag:=rdr.ParseInteger;
                byt:=rdr.ParseInteger;
                if byt=10 then begin
                  while dxfLoadGroupCodeDouble(rdr,10,byt,tp^.Base.x)
                     or dxfLoadGroupCodeDouble(rdr,20,byt,tp^.Base.y)
                     or dxfLoadGroupCodeDouble(rdr,30,byt,tp^.Base.z) do
                    byt:=rdr.ParseInteger;
                end;
                zDebugLn(format('{D+}[DXF_CONTENTS]Base x:%g y:%g z:%g',[tp^.Base.x,tp^.Base.y,tp^.Base.z]));
                SaveOptions:=ZCDCtx.dc.Options;
                exclude(ZCDCtx.dc.Options,DCODrawable);
                AddEntitiesFromDXF(rdr,'ENDBLK',tp,ZCDCtx.pdrawing^,ZCDCtx.dc,context);
                ZCDCtx.dc.Options:=SaveOptions;
                tp^.LoadFromDXF(rdr,nil,ZCDCtx.pdrawing^,context);
                blockload:=true;
                zDebugLn('{D-}[DXF_CONTENTS]end block;');
                sname:='##'
              end;
            if not blockload then
                                 sname := rdr.ParseString;
            blockload:=false;
            s:=dxfDeCodeString(rdr.ParseString,context.Header);
          until (s = dxfName_ENDSEC);
          zDebugLn('{D-}[DXF_CONTENTS]end; {block table}');
          //programlog.LogOutStr('end; {block table}',lp_DecPos,LM_Debug);
          //drawing.BlockDefArray.Format;
          ZCDCtx.pdrawing^.DimStyleTable.ResolveTextstyles(TGenericNamedObjectsArray(ZCDCtx.pdrawing^.TextStyleTable));
          ZCDCtx.pdrawing^.DimStyleTable.ResolveDXFHandles(Handle2BlockName);
          ZCDCtx.pdrawing^.DimStyleTable.ResolveLineTypes(ZCDCtx.pdrawing^.LTypeStyleTable);
        end;

//    s := s;
//       if (byt=fcode) and (s=fname) then exit;
    lps.ProgressLongProcess(lph,rdr.CurrentPos);
    //if assigned(ProcessLongProcessProc)then
    //ProcessLongProcessProc(rdr.ReadPos);
  until rdr.EOF;
  {$IFNDEF DELPHI}
  Handle2BlockName.destroy;
  {$ENDIF}
  zDebugLn('{D-}[DXF_CONTENTS]end; {AddFromDXF2000}');
  //programlog.LogOutStr('end; {AddFromDXF2000}',lp_DecPos,LM_Debug);
  lps.EndLongProcess(lph);
end;

function AddFromDXF(const AFileName: String;var dwgCtx:TZDrawingContext;const LogIntf:TZELogProc=nil):TDXFHeaderInfo;
var
  fileCtx:TIODXFLoadContext;
  lph:TLPSHandle;
  DxfStream:TZMVSMemoryMappedFile;
  rdr:TZMemReader;
const
   ffs='%s (%s)';
begin
  DefaultFormatSettings.DecimalSeparator:='.';
  result.InitRec;
  zDebugLn('{D+}AddFromDXF("%s")',[AFileName]);
  try
    Log(LogIntf,ZESGeneral,ZEMsgCriticalInfo,format(rsLoadingFile,[AFileName]));
    try
      DxfStream:=TZMVSMemoryMappedFile.Create(AFileName,fmOpenRead);
    except
      on E: Exception do begin
        Log(LogIntf,ZESGeneral,ZEMsgError,format(rsWhenOpeningFileAnErrorOccupedWithMsg,[AFileName,E.ClassName,E.Message]));
        exit;
      end;
    end;
    rdr:=TZMemReader.Create(DxfStream);
    try
      if rdr.HaveData then
      begin
        fileCtx.InitRec;
        if not ReadDXFHeader(rdr,fileCtx) then begin
          rdr.setPosition(0);
          fileCtx.Header.iDWGCodePage:=1252;
          fileCtx.Header.iVersion:=1009;
        end;
        lph:=lps.StartLongProcess(rsLoadDXFFile,@rdr,rdr.Size,LPSOSilent);
        case fileCtx.Header.Version of
          AC1009:begin
            Log(LogIntf,ZESGeneral,ZEMsgInfo,format(rsFileFormat,[format(ffs,[ACVer2DXFVerStr(fileCtx.Header.iVersion),ACVer2ACVerStr(fileCtx.Header.iVersion)])]));
            AddFromDXF12(rdr,dxf_EOF,dwgCtx,LogIntf);
          end;
          AC1014,AC1015,AC1018,AC1021,AC1024,AC1027,AC1032:begin
            Log(LogIntf,ZESGeneral,ZEMsgInfo,format(rsFileFormat,[format(ffs,[ACVer2DXFVerStr(fileCtx.Header.iVersion),ACVer2ACVerStr(fileCtx.Header.iVersion)])]));
            AddFromDXF20XX(rdr,dxf_EOF,dwgCtx,fileCtx,LogIntf)
          end;
          else
            if fileCtx.Header.iVersion<>VarValueWrong then
              Log(LogIntf,ZESGeneral,ZEMsgError,'{EM}'+rsUnknownFileFormat+' $ACADVER='+fileCtx.DWGVarsDict[dxfVar_ACADVER])
            else
              Log(LogIntf,ZESGeneral,ZEMsgError,rsUnknownFileFormat);
        end;
        lps.EndLongProcess(lph);
        dwgCtx.POwner^.calcbb(dwgCtx.DC);
        result:=fileCtx.Header;
        fileCtx.Done;
      end else
        Log(LogIntf,ZESGeneral,ZEMsgError,'Can not open file: '+AFileName);
    finally
      DxfStream.Free;
      rdr.Free;
    end;
  finally
      zDebugLn('{D-}end; {AddFromDXF}');
  end;
end;

begin
end.
