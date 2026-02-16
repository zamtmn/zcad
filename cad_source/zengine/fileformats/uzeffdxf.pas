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
  uzMVSMemoryMappedFile,uzMVReader,uzbBaseUtils;
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
  IgnoredDXFEntsArray:array [0..1] of DXFEntDesc=(
    (UCASEEntName:'HATCH'),
    (UCASEEntName:'ACAD_PROXY_ENTITY')
  );

{ todo: вернуть как было после https://gitlab.com/freepascal.org/fpc/source/-/issues/40073
-     IgnoredDXFEntsArray:array of DXFEntDesc=[
+     IgnoredDXFEntsArray:array [0..1] of DXFEntDesc=(
        (UCASEEntName:'HATCH'),
        (UCASEEntName:'ACAD_PROXY_ENTITY')
-     ];
+     );}
var
  CreateExtLoadData:TCreateExtLoadData=nil;
  ClearExtLoadData:TProcessExtLoadData=nil;
  FreeExtLoadData:TProcessExtLoadData=nil;

function AddFromDXF(const AFileName: String;var dwgCtx:TZDrawingContext;const LogIntf:TZELogProc=nil):TDXFHeaderInfo;
function savedxf2000(const SavedFileName:String; const TemplateFileName:String;var drawing:TSimpleDrawing;codepage:integer):boolean;

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
    if (group=0)and(DXFName2EntInfoData.MyGetValue(s,EntInfoData)) then begin
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
      if group=0 then begin
         objid:=IsIgnoredEntity(s);
         if objid>0 then
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
procedure saveentitiesdxf2000(pva: PGDBObjEntityOpenArray; var outStream:TZctnrVectorBytes;var drawing:TSimpleDrawing;var IODXFContext:TIODXFSaveContext);
var
  pv:pgdbobjEntity;
  ir:itrec;
  lph:TLPSHandle;
begin
     lph:=lps.StartLongProcess('saveentitiesdxf2000',@outStream,pva^.Count);
     pv:=pva^.beginiterate(ir);
     if pv<>nil then
     repeat
          lps.ProgressLongProcess(lph,ir.itc);
          IODXFContext.LocalEntityFlags:=DefaultLocalEntityFlags;
          pv^.DXFOut(outStream,drawing,IODXFContext);
     pv:=pva^.iterate(ir);
     until pv=nil;
     lps.EndLongProcess(lph);
end;

procedure RegisterAcadAppInDXF(const appname:String; outstream: PTZctnrVectorBytes;var handle: TDWGHandle);
begin
  outstream^.TXTAddStringEOL(dxfGroupCode(0));
  outstream^.TXTAddStringEOL('APPID');

  outstream^.TXTAddStringEOL(dxfGroupCode(5));
  outstream^.TXTAddStringEOL(inttohex(handle, 0));
  inc(handle);

  outstream^.TXTAddStringEOL(dxfGroupCode(100));
  outstream^.TXTAddStringEOL('AcDbSymbolTableRecord');
  outstream^.TXTAddStringEOL(dxfGroupCode(100));
  outstream^.TXTAddStringEOL('AcDbRegAppTableRecord');
  outstream^.TXTAddStringEOL(dxfGroupCode(2));
  outstream^.TXTAddStringEOL(appname);
  outstream^.TXTAddStringEOL(dxfGroupCode(70));
  outstream^.TXTAddStringEOL('0');
  {
  0
  APPID
  5
  12
  >>330
  >>9
  100
  AcDbSymbolTableRecord
  100
  AcDbRegAppTableRecord
  2
  ACAD
  70
  0
  }
end;
procedure MakeVariablesDict(VarsDict:TString2StringDictionary; var drawing:TSimpleDrawing);
var
   pcurrtextstyle:PGDBTextStyle;
   pcurrentdimstyle:PGDBDimStyle;
begin
    VarsDict.Add('$CLAYER',drawing.GetCurrentLayer^.Name);
    VarsDict.Add('$CELTYPE',drawing.GetCurrentLType^.Name);
    VarsDict.Add('$DWGCODEPAGE',ZCCP2Str(drawing.DXFCodePage));

    pcurrtextstyle:=drawing.GetCurrentTextStyle;
    if pcurrtextstyle<>nil then
                               VarsDict.Add('$TEXTSTYLE',drawing.GetCurrentTextStyle^.Name)
                           else
                               VarsDict.Add('$TEXTSTYLE',TSNStandardStyleName);
    pcurrentdimstyle:=drawing.GetCurrentDimStyle;
    if pcurrentdimstyle<>nil then
                                 VarsDict.Add('$DIMSTYLE',pcurrentdimstyle^.Name)
                             else
                                 VarsDict.Add('$DIMSTYLE','Standatd');

    //if assigned(sysvar.DWG.DWG_CLinew) then
                                           VarsDict.Add('$CELWEIGHT',inttostr({sysvar.DWG.DWG_CLinew^}drawing.CurrentLineW));
                                       //else
                                       //    VarsDict.insert('$CELWEIGHT',inttostr(-1));

    //if assigned(sysvar.DWG.DWG_LTScale) then
                                            VarsDict.Add('$LTSCALE',floattostr({sysvar.DWG.DWG_LTScale^}drawing.LTScale));
                                        //else
                                        //    VarsDict.insert('$LTSCALE',floattostr(1.0));

    //if assigned(sysvar.DWG.DWG_CLTScale) then
                                             VarsDict.Add('$CELTSCALE',floattostr({sysvar.DWG.DWG_CLTScale^}drawing.CLTScale));
                                         //else
                                         //    VarsDict.insert('$CELTSCALE',floattostr(1.0));

    //if assigned(sysvar.DWG.DWG_CColor) then
                                           VarsDict.Add('$CECOLOR',inttostr({sysvar.DWG.DWG_CColor^}drawing.CColor));
                                       //else
                                           //VarsDict.insert('$CECOLOR',inttostr(256));


    //if assigned(sysvar.DWG.DWG_DrawMode) then
                                             begin
                                                  if {sysvar.DWG.DWG_DrawMode^}drawing.LWDisplay then
                                                                                  VarsDict.Add('$LWDISPLAY',inttostr(1))
                                                                              else
                                                                                  VarsDict.Add('$LWDISPLAY',inttostr(0));
                                             end;
                                         //else
                                         //    VarsDict.insert('$LWDISPLAY',inttostr(0));
   VarsDict.Add('$HANDSEED','FUCK OFF!');

   //if assigned(sysvar.DWG.DWG_LUnits) then
                                        VarsDict.Add('$LUNITS',inttostr(ord({sysvar.DWG.DWG_LUnits^}drawing.LUnits)+1));
   //if assigned(sysvar.DWG.DWG_LUPrec) then
                                        VarsDict.Add('$LUPREC',inttostr(ord({sysvar.DWG.DWG_LUPrec^}drawing.LUPrec)));
   //if assigned(sysvar.DWG.DWG_AUnits) then
                                        VarsDict.Add('$AUNITS',inttostr(ord({sysvar.DWG.DWG_AUnits^}drawing.AUnits)));
   //if assigned(sysvar.DWG.DWG_AUPrec) then
                                        VarsDict.Add('$AUPREC',inttostr(ord({sysvar.DWG.DWG_AUPrec^}drawing.AUPrec)));
   //if assigned(sysvar.DWG.DWG_AngDir) then
                                        VarsDict.Add('$ANGDIR',inttostr(ord({sysvar.DWG.DWG_AngDir^}drawing.AngDir)));
   //if assigned(sysvar.DWG.DWG_AngBase) then
                                        VarsDict.Add('$ANGBASE',floattostr({sysvar.DWG.DWG_AngBase^}drawing.AngBase));
   //if assigned(sysvar.DWG.DWG_UnitMode) then
                                        VarsDict.Add('$UNITMODE',inttostr(ord({sysvar.DWG.DWG_UnitMode^}drawing.UnitMode)));
   //if assigned(sysvar.DWG.DWG_InsUnits) then
                                           VarsDict.Add('$INSUNITS',inttostr(ord({sysvar.DWG.DWG_InsUnits^}drawing.InsUnits)));
   //if assigned(sysvar.DWG.DWG_TextSize) then
                                           VarsDict.Add('$TEXTSIZE',floattostr({sysvar.DWG.DWG_TextSize^}drawing.TextSize));
end;

function savedxf2000(const SavedFileName:String; const TemplateFileName:String;var drawing:TSimpleDrawing;codepage:integer):boolean;
var
  sysfilename:RawByteString;
  templatefile: TZctnrVectorBytes;
  outstream:TZctnrVectorBytes;
  groups,values,ts: String;
  groupi,valuei,intable,attr: Integer;
  temphandle,temphandle2,lasthandle,vporttablehandle,plottablefansdle,dimtablehandle: TDWGHandle;
  i: integer;
  OldHandele2NewHandle:TMapHandleToHandle;

  inlayertable, inblocksec, inblocktable, inlttypetable, indimstyletable, inappidtable: Boolean;
  handlepos:integer;
  ignoredsource:boolean;
  instyletable:boolean;
  invporttable:boolean;

  pltp:PGDBLtypeProp;
  plp:PGDBLayerProp;
  pdsp:PGDBDimStyle;
  ir,ir2,ir3,ir4,ir5:itrec;
  TDI:PTDashInfo;
  PStroke:PDouble;
  PSP:PShapeProp;
  PTP:PTextProp;
  p:pointer;
  IODXFContext:TIODXFSaveContext;
  laststrokewrited:boolean;
  pcurrtextstyle:PGDBTextStyle;
  variablenotprocessed:boolean;
  processedvarscount:integer;
  lph:TLPSHandle;
begin
  intable:=0;
  IODXFContext.InitRec;
  IODXFContext.Header.Version:=AC1015;
  IODXFContext.Header.iVersion:=1015;

  IODXFContext.Header.DWGCodePage:=SysCP2ACCP(codepage);
  IODXFContext.Header.iDWGCodePage:=codepage;

  DefaultFormatSettings.DecimalSeparator := '.';
  outstream.init(10*1024*1024);
  begin
    lph:=lps.StartLongProcess('Save DXF file',@outstream,drawing.pObjRoot^.ObjArray.Count);
  OldHandele2NewHandle:=TMapHandleToHandle.Create;
  templatefile.InitFromFile(TemplateFileName);
  inlayertable := false;
  inblocksec := false;
  inblocktable := false;
  instyletable := false;
  ignoredsource:=false;
  invporttable:=false;
  inlttypetable:=false;
  indimstyletable:=false;
  inappidtable:=false;
  MakeVariablesDict(IODXFContext.VarsDict,drawing);
  processedvarscount:=IODXFContext.VarsDict.count;
  while templatefile.notEOF do
  begin
    groups := templatefile.readString;
    values := templatefile.readString;
    //ucvalues:=uppercase(values);
    groupi := strtoint(groups);
    variablenotprocessed:=true;
    if (groupi = 9)and(processedvarscount>0) then
    begin
      variablenotprocessed:=false;
      if IODXFContext.VarsDict.mygetvalue(values,ts) then
        begin
             outstream.TXTAddStringEOL(groups);
             outstream.TXTAddStringEOL(values);
             groups := templatefile.readString;
             {values := }templatefile.readString;
             outstream.TXTAddStringEOL(groups);
             if values='$HANDSEED' then
                                       handlepos:=outstream.Count;
             outstream.TXTAddStringEOL(dxfEnCodeString(ts,IODXFContext.Header));
             dec(processedvarscount);
        end
      else variablenotprocessed:=true;
    end
    {else};if variablenotprocessed then
      if (groupi = 5)
      or (groupi = 320)
      or (groupi = 330)
      or (groupi = 340)
      or (groupi = 350)
      or (groupi = 1005)
      or (groupi = 390)
      or (groupi = 360)
      or (groupi = 105) then
      begin
        valuei := strtoint('$' + values);
                          {if valuei<>0 then
                                       begin}
        if valuei=0 then
                        valuei:=0;
        if inlayertable and (groupi=390) then
                                             plottablefansdle:={handle-1}intable;  {поймать плоттабле}
        intable :=OldHandele2NewHandle.MyGetValue(valuei);
        //intable :=GetNewHandle(valuei);
        //intable := {}getnevhandle(phandlea, valuei){}{valuei};
        if {}intable >0{}{true} then
        begin
          if not ignoredsource then
          begin
          outstream.TXTAddStringEOL(groups);
          outstream.TXTAddStringEOL(inttohex(intable, 0));
          end;
          lasthandle:=intable;
        end
        else
        begin
          OldHandele2NewHandle.Add(valuei, IODXFContext.handle);
          //pushhandle(phandlea, valuei, handle);
          if not ignoredsource then
          begin
          outstream.TXTAddStringEOL(groups);
          outstream.TXTAddStringEOL(inttohex(IODXFContext.handle, 0));
          end;
          lasthandle:=IODXFContext.handle;
          inc(IODXFContext.handle);
        end;
        if inlayertable and (groupi=390) then
                                             plottablefansdle:=lasthandle;  {поймать плоттабле}
        if indimstyletable and (groupi=5) then
                                             dimtablehandle:=lasthandle;  {поймать dimtable}
        (*{if instyletable and (groupi=5) then
                                             standartstylehandle:=lasthandle;{intable;}  {поймать standart}*)
      end
      else
        if (groupi = 2) and (values = 'ENTITIES') then
        begin
          outstream.TXTAddStringEOL(groups);
          //WriteString_EOL(outstream, groups);
          outstream.TXTAddStringEOL(values);
          //WriteString_EOL(outstream, values);
          //historyoutstr('Entities start here_______________________________________________________');
          saveentitiesdxf2000(@{p}drawing.pObjRoot^.ObjArray, outstream,drawing,IODXFContext);
        end
        else
          if (groupi = 2) and (values = 'BLOCKS') then
          begin
            outstream.TXTAddStringEOL(groups);
            outstream.TXTAddStringEOL(values);
            //WriteString_EOL(outstream, groups);
            //WriteString_EOL(outstream, values);
            inblocksec := true;
          end
          else
            if (inblocksec) and ((groupi = 0) and (values = dxfName_ENDSEC)) then
            begin
              //historyoutstr('Blockdefs start here_______________________________________________________');
              if {p}drawing.BlockDefArray.count>0 then
              for i := 0 to {p}drawing.BlockDefArray.count - 1 do
              begin
                zDebugLn('{D}[DXF_CONTENTS]write BlockDef '+PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].name);
                outstream.TXTAddStringEOL(dxfGroupCode(0));
                outstream.TXTAddStringEOL('BLOCK');

                //GetOrCreateHandle(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),handle,temphandle);
                //
                outstream.TXTAddStringEOL(dxfGroupCode(5));
                outstream.TXTAddStringEOL(inttohex(IODXFContext.handle{temphandle}, 0));
                inc(IODXFContext.handle);
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL(dxfName_AcDbEntity);
                outstream.TXTAddStringEOL(dxfGroupCode(8));
                outstream.TXTAddStringEOL('0');
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL('AcDbBlockBegin');
                outstream.TXTAddStringEOL(dxfGroupCode(2));
                outstream.TXTAddStringEOL(dxfEnCodeString(PBlockdefArray(drawing.BlockDefArray.parray)^[i].name,IODXFContext.Header));
                outstream.TXTAddStringEOL(dxfGroupCode(70));
                outstream.TXTAddStringEOL('2');
                outstream.TXTAddStringEOL(dxfGroupCode(10));
                outstream.TXTAddStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.x));
                outstream.TXTAddStringEOL(dxfGroupCode(20));
                outstream.TXTAddStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.y));
                outstream.TXTAddStringEOL(dxfGroupCode(30));
                outstream.TXTAddStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.z));
                outstream.TXTAddStringEOL(dxfGroupCode(3));
                outstream.TXTAddStringEOL(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].name);
                outstream.TXTAddStringEOL(dxfGroupCode(1));
                outstream.TXTAddStringEOL('');

                saveentitiesdxf2000(@PBlockdefArray(drawing.BlockDefArray.parray)^[i].ObjArray, outstream,drawing,IODXFContext);

                outstream.TXTAddStringEOL(dxfGroupCode(0));
                outstream.TXTAddStringEOL('ENDBLK');
                outstream.TXTAddStringEOL(dxfGroupCode(5));
                outstream.TXTAddStringEOL(inttohex(IODXFContext.handle, 0));
                inc(IODXFContext.handle);
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL(dxfName_AcDbEntity);
                outstream.TXTAddStringEOL(dxfGroupCode(8));
                outstream.TXTAddStringEOL('0');
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL('AcDbBlockEnd');

                dxfStringout(outstream,1001,ZCADAppNameInDXF);
                dxfStringout(outstream,1002,'{');
                if assigned(PBlockdefArray(drawing.BlockDefArray.parray)^[i].EntExtensions) then
                  PBlockdefArray(drawing.BlockDefArray.parray)^[i].EntExtensions.RunSaveToDxf(outstream,@PBlockdefArray(drawing.BlockDefArray.parray)^[i],IODXFContext);
                dxfStringout(outstream,1002,'}');


              end;

              outstream.TXTAddStringEOL(dxfGroupCode(0));
              outstream.TXTAddStringEOL(dxfName_ENDSEC);


              inblocksec := false;
            end
            else if (invporttable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
            begin
               invporttable:=false;
               ignoredsource:=false;

               outstream.TXTAddStringEOL(dxfGroupCode(5));
               outstream.TXTAddStringEOL(inttohex(IODXFContext.handle,0));
               vporttablehandle:=IODXFContext.handle;
               inc(IODXFContext.handle);

               outstream.TXTAddStringEOL(dxfGroupCode(330));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(100));
               outstream.TXTAddStringEOL('AcDbSymbolTable');
               outstream.TXTAddStringEOL(dxfGroupCode(70));
               outstream.TXTAddStringEOL('1');
               outstream.TXTAddStringEOL(dxfGroupCode(0));
               outstream.TXTAddStringEOL('VPORT');
               outstream.TXTAddStringEOL(dxfGroupCode(5));
               outstream.TXTAddStringEOL(inttohex(IODXFContext.handle,0));
               inc(IODXFContext.handle);
               outstream.TXTAddStringEOL(dxfGroupCode(330));
               outstream.TXTAddStringEOL(inttohex(vporttablehandle,0));

               outstream.TXTAddStringEOL(dxfGroupCode(100));
               outstream.TXTAddStringEOL('AcDbSymbolTableRecord');
               outstream.TXTAddStringEOL(dxfGroupCode(100));
               outstream.TXTAddStringEOL('AcDbViewportTableRecord');

               outstream.TXTAddStringEOL(dxfGroupCode(2));
               outstream.TXTAddStringEOL('*Active');
               outstream.TXTAddStringEOL(dxfGroupCode(70));
               outstream.TXTAddStringEOL('0');

               outstream.TXTAddStringEOL(dxfGroupCode(10));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(20));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(11));
               outstream.TXTAddStringEOL('1.0');
               outstream.TXTAddStringEOL(dxfGroupCode(21));
               outstream.TXTAddStringEOL('1.0');

               if assigned(drawing.wa)and(drawing.wa.getviewcontrol<>nil) then
                                                        begin
                                                             outstream.TXTAddStringEOL(dxfGroupCode(12));
                                                             outstream.TXTAddStringEOL(floattostr(drawing.wa.param.CPoint.x));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(22));
                                                             outstream.TXTAddStringEOL(floattostr(drawing.wa.param.CPoint.y));
                                                        end
                                                    else
                                                        begin
                                                             outstream.TXTAddStringEOL(dxfGroupCode(12));
                                                             outstream.TXTAddStringEOL('0');
                                                             outstream.TXTAddStringEOL(dxfGroupCode(22));
                                                             outstream.TXTAddStringEOL('0');
                                                        end;
               outstream.TXTAddStringEOL(dxfGroupCode(13));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_Snap^.Base.x}drawing.Snap.Base.x));
               outstream.TXTAddStringEOL(dxfGroupCode(23));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_Snap^.Base.y}drawing.Snap.Base.y));
               outstream.TXTAddStringEOL(dxfGroupCode(14));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_Snap^.Spacing.x}drawing.Snap.Spacing.x));
               outstream.TXTAddStringEOL(dxfGroupCode(24));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_Snap^.Spacing.y}drawing.Snap.Spacing.y));
               outstream.TXTAddStringEOL(dxfGroupCode(15));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_GridSpacing^.x}drawing.GridSpacing.x));
               outstream.TXTAddStringEOL(dxfGroupCode(25));
               outstream.TXTAddStringEOL(floattostr({sysvar.DWG.DWG_GridSpacing^.y}drawing.GridSpacing.y));
               outstream.TXTAddStringEOL(dxfGroupCode(16));
               outstream.TXTAddStringEOL(floattostr(-drawing.pcamera^.prop.look.x));
               outstream.TXTAddStringEOL(dxfGroupCode(26));
               outstream.TXTAddStringEOL(floattostr(-drawing.pcamera^.prop.look.y));
               outstream.TXTAddStringEOL(dxfGroupCode(36));
               outstream.TXTAddStringEOL(floattostr(-drawing.pcamera^.prop.look.z));
               outstream.TXTAddStringEOL(dxfGroupCode(17));
               outstream.TXTAddStringEOL(floattostr(0));
               outstream.TXTAddStringEOL(dxfGroupCode(27));
               outstream.TXTAddStringEOL(floattostr(0));
               outstream.TXTAddStringEOL(dxfGroupCode(37));
               outstream.TXTAddStringEOL(floattostr(0));
               outstream.TXTAddStringEOL(dxfGroupCode(40));
               if assigned(drawing.wa)and(drawing.wa.getviewcontrol<>nil) then
                                                        outstream.TXTAddStringEOL(floattostr(drawing.wa.param.ViewHeight))
                                                    else
                                                        outstream.TXTAddStringEOL(inttostr(500));
               outstream.TXTAddStringEOL(dxfGroupCode(41));
               if assigned(drawing.wa)and(drawing.wa.getviewcontrol<>nil) then
                                                        outstream.TXTAddStringEOL(floattostr(drawing.wa.getviewcontrol.ClientWidth/drawing.wa.getviewcontrol.ClientHeight))
                                                    else
                                                        outstream.TXTAddStringEOL(inttostr(1));
               outstream.TXTAddStringEOL(dxfGroupCode(42));
               outstream.TXTAddStringEOL('50.0');
               outstream.TXTAddStringEOL(dxfGroupCode(43));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(44));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(50));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(51));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(71));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(72));
               outstream.TXTAddStringEOL('1000');
               outstream.TXTAddStringEOL(dxfGroupCode(73));
               outstream.TXTAddStringEOL('1');
               outstream.TXTAddStringEOL(dxfGroupCode(74));
               outstream.TXTAddStringEOL('3');
               outstream.TXTAddStringEOL(dxfGroupCode(75));
               //if sysvar.DWG.DWG_SnapGrid<>nil then
                                                   begin
                                                        if {sysvar.DWG.DWG_SnapGrid^}drawing.SnapGrid then
                                                                                        outstream.TXTAddStringEOL('1')
                                                                                    else
                                                                                        outstream.TXTAddStringEOL('0');
                                                   end;
                                               //else
                                               //    outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(76));
               //if sysvar.DWG.DWG_DrawGrid<>nil then
                                                     begin
                                                          if {sysvar.DWG.DWG_DrawGrid^}drawing.DrawGrid then
                                                                                          outstream.TXTAddStringEOL('1')
                                                                                      else
                                                                                          outstream.TXTAddStringEOL('0');
                                                     end;
                                                 //else
                                                 //    outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(77));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(78));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(281));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(65));
               outstream.TXTAddStringEOL('1');
               outstream.TXTAddStringEOL(dxfGroupCode(110));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(120));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(130));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(111));
               outstream.TXTAddStringEOL('1.0');
               outstream.TXTAddStringEOL(dxfGroupCode(121));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(131));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(112));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(122));
               outstream.TXTAddStringEOL('1.0');
               outstream.TXTAddStringEOL(dxfGroupCode(132));
               outstream.TXTAddStringEOL('0.0');
               outstream.TXTAddStringEOL(dxfGroupCode(79));
               outstream.TXTAddStringEOL('0');
               outstream.TXTAddStringEOL(dxfGroupCode(146));
               outstream.TXTAddStringEOL('0.0');
               //outstream.TXTAddStringEOL(dxfGroupCode(1001));
               //outstream.TXTAddStringEOL('ACAD_NAV_VCDISPLAY');
               //outstream.TXTAddStringEOL(dxfGroupCode(1070));
               //outstream.TXTAddStringEOL('3');
               outstream.TXTAddStringEOL(dxfGroupCode(0));
               outstream.TXTAddStringEOL('ENDTAB');

            end
            else if (inblocktable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
            begin
              inblocktable := false;
              if {p}drawing.BlockDefArray.count>0 then

              for i := 0 to {p}drawing.BlockDefArray.count - 1 do
              begin
                outstream.TXTAddStringEOL(dxfGroupCode(0));
                outstream.TXTAddStringEOL(dxfName_BLOCK_RECORD);

                IODXFContext.p2h.MyGetOrCreateValue(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),IODXFContext.handle,temphandle);
                //GetOrCreateHandle(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),handle,temphandle);

                outstream.TXTAddStringEOL(dxfGroupCode(5));
                outstream.TXTAddStringEOL(inttohex(temphandle, 0));
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                outstream.TXTAddStringEOL(dxfGroupCode(100));
                outstream.TXTAddStringEOL('AcDbBlockTableRecord');
                outstream.TXTAddStringEOL(dxfGroupCode(2));
                outstream.TXTAddStringEOL(dxfEnCodeString(PBlockdefArray(drawing.BlockDefArray.parray)^[i].name,IODXFContext.Header));

              end;
              outstream.TXTAddStringEOL(dxfGroupCode(0));
              outstream.TXTAddStringEOL(dxfName_ENDTAB);
            end

            else
              if (inlayertable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                inlayertable := false;
                ignoredsource:=false;
                plp:=drawing.layertable.beginiterate(ir);
                if plp<>nil then
                repeat
                //for i := 0 to drawing.layertable.count - 1 do
                begin
                  //if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[pltp].name <> '0' then
                  begin
                    outstream.TXTAddStringEOL(dxfGroupCode(0));
                    outstream.TXTAddStringEOL(dxfName_Layer);
                    outstream.TXTAddStringEOL(dxfGroupCode(5));
                    outstream.TXTAddStringEOL(inttohex(IODXFContext.handle, 0));
                    inc(IODXFContext.handle);
                    outstream.TXTAddStringEOL(dxfGroupCode(100));
                    outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                    outstream.TXTAddStringEOL(dxfGroupCode(100));
                    outstream.TXTAddStringEOL('AcDbLayerTableRecord');
                    outstream.TXTAddStringEOL(dxfGroupCode(2));
                    outstream.TXTAddStringEOL(dxfEnCodeString(plp^.name,IODXFContext.Header));
                    attr:=0;
                    if plp^._lock then
                                     attr:=attr + 4;
                    outstream.TXTAddStringEOL(dxfGroupCode(70));
                    outstream.TXTAddStringEOL(inttostr(attr));
                    outstream.TXTAddStringEOL(dxfGroupCode(62));
                    if plp^._on
                     then
                         outstream.TXTAddStringEOL(inttostr(plp^.color))
                     else
                         outstream.TXTAddStringEOL(inttostr(-plp^.color));
                    outstream.TXTAddStringEOL(dxfGroupCode(6));
                    outstream.TXTAddStringEOL(dxfEnCodeString(GetLTName(plp^.LT),IODXFContext.Header));
                    {if assigned(plp^.LT) then
                                             outstream.TXTAddStringEOL(PGDBLtypeProp(plp^.LT)^.Name)
                                         else
                                             outstream.TXTAddStringEOL('Continuous');}
                    outstream.TXTAddStringEOL(dxfGroupCode(290));
                    if plp^._print then
                    //if uppercase(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[pltp].name) <> 'DEFPOINTS' then
                      outstream.TXTAddStringEOL('1')
                    else
                      outstream.TXTAddStringEOL('0');
                    outstream.TXTAddStringEOL(dxfGroupCode(370));
                    outstream.TXTAddStringEOL(inttostr(plp^.lineweight));
                    //WriteString_EOL(outstream, '-3');
                    outstream.TXTAddStringEOL(dxfGroupCode(390));
                    outstream.TXTAddStringEOL(inttohex(plottablefansdle,0));

                    if plp^.desk<>''then
                    begin
                         outstream.TXTAddStringEOL(dxfGroupCode(1001));
                         outstream.TXTAddStringEOL('AcAecLayerStandard');
                         outstream.TXTAddStringEOL(dxfGroupCode(1000));
                         outstream.TXTAddStringEOL('');
                         outstream.TXTAddStringEOL(dxfGroupCode(1000));
                         outstream.TXTAddStringEOL(dxfEnCodeString(plp^.desk,IODXFContext.Header));
                    end;
                  end;
                end;
                plp:=drawing.layertable.iterate(ir);
                until plp=nil;

                outstream.TXTAddStringEOL(groups);
                outstream.TXTAddStringEOL(values);
              end


            else
              if (inlttypetable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                   inlttypetable := false;
                   ignoredsource:=false;
                   temphandle:=IODXFContext.handle-1;
                   pltp:=drawing.LTypeStyleTable.beginiterate(ir);
                   if pltp<>nil then
                   repeat
                         zDebugLn('{D}[DXF_CONTENTS]write linetype '+pltp^.Name);
                         outstream.TXTAddStringEOL(dxfGroupCode(0));
                         outstream.TXTAddStringEOL(dxfName_LTYPE);
                         IODXFContext.p2h.MyGetOrCreateValue(pltp,IODXFContext.handle,temphandle);
                         outstream.TXTAddStringEOL(dxfGroupCode(5));
                         outstream.TXTAddStringEOL(inttohex(temphandle, 0));
                         {outstream.TXTAddStringEOL(inttohex(handle, 0));
                         inc(handle);}
                         outstream.TXTAddStringEOL(dxfGroupCode(330));
                         outstream.TXTAddStringEOL(inttohex(temphandle, 0));
                         outstream.TXTAddStringEOL(dxfGroupCode(100));
                         outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                         outstream.TXTAddStringEOL(dxfGroupCode(100));
                         outstream.TXTAddStringEOL('AcDbLinetypeTableRecord');
                         outstream.TXTAddStringEOL(dxfGroupCode(2));
                         outstream.TXTAddStringEOL(dxfEnCodeString(pltp^.Name,IODXFContext.Header));
                         outstream.TXTAddStringEOL(dxfGroupCode(70));
                         outstream.TXTAddStringEOL('0');
                         outstream.TXTAddStringEOL(dxfGroupCode(3));
                         outstream.TXTAddStringEOL(dxfEnCodeString(pltp^.desk,IODXFContext.Header));
                         outstream.TXTAddStringEOL(dxfGroupCode(72));
                         outstream.TXTAddStringEOL('65');
                         i:=pltp^.strokesarray.GetRealCount;
                         outstream.TXTAddStringEOL(dxfGroupCode(73));
                         outstream.TXTAddStringEOL(inttostr(i));
                         outstream.TXTAddStringEOL(dxfGroupCode(40));
                         outstream.TXTAddStringEOL(floattostr(pltp^.LengthDXF));
                         if i>0 then
                         begin
                              TDI:=pltp^.dasharray.beginiterate(ir2);
                              PStroke:=pltp^.strokesarray.beginiterate(ir3);
                              PSP:=pltp^.shapearray.beginiterate(ir4);
                              PTP:=pltp^.textarray.beginiterate(ir5);
                              laststrokewrited:=false;
                              if PStroke<>nil then
                              repeat
                                    case TDI^ of
                                                TDIDash:begin
                                                             if laststrokewrited then
                                                                                     begin
                                                                                     outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                                                     outstream.TXTAddStringEOL('0');
                                                                                     end;
                                                             outstream.TXTAddStringEOL(dxfGroupCode(49));
                                                             outstream.TXTAddStringEOL(floattostr(PStroke^));
                                                             {outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddStringEOL('0');}
                                                             PStroke:=pltp^.strokesarray.iterate(ir3);
                                                             laststrokewrited:=true;
                                                        end;
                                               TDIShape:if PSP^.param.PStyle<>nil then
                                                        begin
                                                             laststrokewrited:=false;
                                                             outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddStringEOL('4');
                                                             outstream.TXTAddStringEOL(dxfGroupCode(75));
                                                             outstream.TXTAddStringEOL(inttostr(PSP^.ShapeNum));

                                                             IODXFContext.p2h.MyGetOrCreateValue(PSP^.param.PStyle,IODXFContext.handle,temphandle);
                                                             //GetOrCreateHandle(PSP^.param.PStyle,handle,temphandle);

                                                             outstream.TXTAddStringEOL(dxfGroupCode(340));
                                                             outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(46));
                                                             outstream.TXTAddStringEOL(floattostr(PSP^.param.Height));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(50));
                                                             outstream.TXTAddStringEOL(floattostr(PSP^.param.Angle));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(44));
                                                             outstream.TXTAddStringEOL(floattostr(PSP^.param.X));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(45));
                                                             outstream.TXTAddStringEOL(floattostr(PSP^.param.Y));
                                                             PSP:=pltp^.shapearray.iterate(ir4);
                                                        end;
                                               TDIText:begin
                                                             laststrokewrited:=false;
                                                             outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddStringEOL('2');
                                                             outstream.TXTAddStringEOL(dxfGroupCode(75));
                                                             outstream.TXTAddStringEOL('0');

                                                             IODXFContext.p2h.MyGetOrCreateValue(PTP^.param.PStyle,IODXFContext.handle,temphandle);
                                                             //GetOrCreateHandle(PTP^.param.PStyle,handle,temphandle);

                                                             {else
                                                                 temphandle:=standartstylehandle;}
                                                             outstream.TXTAddStringEOL(dxfGroupCode(340));
                                                             outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(46));
                                                             outstream.TXTAddStringEOL(floattostr(PTP^.param.Height));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(50));
                                                             outstream.TXTAddStringEOL(floattostr(PTP^.param.Angle));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(44));
                                                             outstream.TXTAddStringEOL(floattostr(PTP^.param.X));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(45));
                                                             outstream.TXTAddStringEOL(floattostr(PTP^.param.Y));
                                                             outstream.TXTAddStringEOL(dxfGroupCode(9));
                                                             outstream.TXTAddStringEOL(PTP^.TEXT);
                                                             PTP:=pltp^.textarray.iterate(ir5);
                                                        end;
                                    end;
                                    TDI:=pltp^.dasharray.iterate(ir2);
                              until {PStroke}TDI=nil;
                              if laststrokewrited then
                                                       begin
                                                       outstream.TXTAddStringEOL(dxfGroupCode(74));
                                                       outstream.TXTAddStringEOL('0');
                                                       end;

                         end;


                         pltp:=drawing.LTypeStyleTable.iterate(ir);
                   until pltp=nil;
                   outstream.TXTAddStringEOL(groups);
                   outstream.TXTAddStringEOL(values);
              end
            else
              if (indimstyletable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                { TODO :  надо писать заголовок таблицы руками, а не из шаблона DXF, т.к. там есть перечень стилей который проебывается}
                indimstyletable:=false;
                ignoredsource:=false;
                //temphandle3:=handle-1;
                //temphandle4:=handle-3;
                //дальше идут стили
                pdsp:=drawing.DimStyleTable.beginiterate(ir);
                if pdsp<>nil then
                repeat
                      outstream.TXTAddStringEOL(dxfGroupCode(0));
                      outstream.TXTAddStringEOL('DIMSTYLE');
                      outstream.TXTAddStringEOL(dxfGroupCode(105));
                      outstream.TXTAddStringEOL(inttohex({temphandle3}IODXFContext.handle, 0));
                      inc(IODXFContext.handle);

                      outstream.TXTAddStringEOL(dxfGroupCode(330));
                      outstream.TXTAddStringEOL(inttohex({temphandle4}{temphandle3}dimtablehandle, 0));

                      outstream.TXTAddStringEOL(dxfGroupCode(100));
                      outstream.TXTAddStringEOL('AcDbSymbolTableRecord');
                      outstream.TXTAddStringEOL(dxfGroupCode(100));
                      outstream.TXTAddStringEOL('AcDbDimStyleTableRecord');
                      outstream.TXTAddStringEOL(dxfGroupCode(2));
                      outstream.TXTAddStringEOL({pdsp^.Name}dxfEncodeString(pdsp^.Name,IODXFContext.Header));
                      outstream.TXTAddStringEOL(dxfGroupCode(3));
                      outstream.TXTAddStringEOL(pdsp^.Units.DIMPOST);
                      outstream.TXTAddStringEOL(dxfGroupCode(70));
                      outstream.TXTAddStringEOL('0');

                      //тут сами настройки
                      outstream.TXTAddStringEOL(dxfGroupCode(40));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Units.DIMSCALE));
                      outstream.TXTAddStringEOL(dxfGroupCode(44));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Lines.DIMEXE));
                      outstream.TXTAddStringEOL(dxfGroupCode(42));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Lines.DIMEXO));
                      outstream.TXTAddStringEOL(dxfGroupCode(46));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Lines.DIMDLE));

                      outstream.TXTAddStringEOL(dxfGroupCode(41));
                      outstream.TXTAddStringEOL(floattostr(pdsp^.Arrows.DIMASZ));

                      outstream.TXTAddStringEOL(dxfGroupCode(173));
                      if pdsp^.Arrows.DIMBLK1<>pdsp^.Arrows.DIMBLK2 then
                                                                        begin
                                                                             outstream.TXTAddStringEOL('1');
                                                                         end
                                           else
                                               begin
                                                    outstream.TXTAddStringEOL('0');
                                               end;

                      if pdsp^.Arrows.DIMLDRBLK<>TSClosedFilled then
                      begin
                           IODXFContext.p2h.MyGetOrCreateValue(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(-1).name),IODXFContext.handle,temphandle);
                           //GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(-1).name),handle,temphandle);
                           outstream.TXTAddStringEOL(dxfGroupCode(341));
                           outstream.TXTAddStringEOL(inttohex(temphandle,0));
                      end;


                      if pdsp^.Arrows.DIMBLK1<>pdsp^.Arrows.DIMBLK2 then
                                                                        begin
                                                                             if pdsp^.Arrows.DIMBLK1<>TSClosedFilled then
                                                                             begin
                                                                                   IODXFContext.p2h.MyGetOrCreateValue(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),IODXFContext.handle,temphandle);
                                                                                   //GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),handle,temphandle);
                                                                                   if temphandle<>0 then
                                                                                   begin
                                                                                         outstream.TXTAddStringEOL(dxfGroupCode(343));
                                                                                         outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                                                   end;
                                                                             end;
                                                                             if pdsp^.Arrows.DIMBLK2<>TSClosedFilled then
                                                                             begin
                                                                                   IODXFContext.p2h.MyGetOrCreateValue(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(1).name),IODXFContext.handle,temphandle);
                                                                                   //GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(1).name),handle,temphandle);
                                                                                   if temphandle<>0 then
                                                                                   begin
                                                                                         outstream.TXTAddStringEOL(dxfGroupCode(344));
                                                                                         outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                                                   end;
                                                                             end;
                                                                         end
                                           else
                                               begin
                                                    if pdsp^.Arrows.DIMBLK1<>TSClosedFilled then
                                                    begin
                                                    IODXFContext.p2h.MyGetOrCreateValue(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),IODXFContext.handle,temphandle);
                                                    //GetHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),temphandle);
                                                    if temphandle<>0 then
                                                    begin
                                                    outstream.TXTAddStringEOL(dxfGroupCode(342));
                                                    outstream.TXTAddStringEOL(inttohex(temphandle,0));
                                                    end;
                                                    end;
                                               end;

                      //GetOrCreateHandle(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),handle,temphandle);

                       (*
                       TGDBDimArrowsProp=packed record
                                              DIMBLK1:TArrowStyle;//First arrow block name//group343
                                              DIMBLK2:TArrowStyle;//First arrow block name//group344
                                              DIMLDRBLK:TArrowStyle;//Arrow block name for leaders//group341
                                         end;
                       *)
                       outstream.TXTAddStringEOL(dxfGroupCode(140));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Text.DIMTXT));

                       outstream.TXTAddStringEOL(dxfGroupCode(141));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Lines.DIMCEN));

                       outstream.TXTAddStringEOL(dxfGroupCode(73));
                       if pdsp^.Text.DIMTIH then
                                                outstream.TXTAddStringEOL('1')
                                            else
                                                outstream.TXTAddStringEOL('0');
                       outstream.TXTAddStringEOL(dxfGroupCode(74));
                       if pdsp^.Text.DIMTOH then
                                                outstream.TXTAddStringEOL('1')
                                            else
                                                outstream.TXTAddStringEOL('0');
                       outstream.TXTAddStringEOL(dxfGroupCode(147));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Text.DIMGAP));

                       outstream.TXTAddStringEOL(dxfGroupCode(77));
                       case pdsp^.Text.DIMTAD of
                                  DTVPCenters:outstream.TXTAddStringEOL('0');
                                    DTVPAbove:outstream.TXTAddStringEOL('1');
                                  DTVPOutside:outstream.TXTAddStringEOL('2');
                                      DTVPJIS:outstream.TXTAddStringEOL('3');
                                   DTVPBellov:outstream.TXTAddStringEOL('4');
                       end;{case}

                       outstream.TXTAddStringEOL(dxfGroupCode(144));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Units.DIMLFAC));
                       outstream.TXTAddStringEOL(dxfGroupCode(271));
                       outstream.TXTAddStringEOL(inttostr(pdsp^.Units.DIMDEC));
                       outstream.TXTAddStringEOL(dxfGroupCode(45));
                       outstream.TXTAddStringEOL(floattostr(pdsp^.Units.DIMRND));

                       outstream.TXTAddStringEOL(dxfGroupCode(277));
                       case pdsp^.Units.DIMLUNIT of
                                   DUScientific:outstream.TXTAddStringEOL('1');
                                      DUDecimal:outstream.TXTAddStringEOL('2');
                                  DUEngineering:outstream.TXTAddStringEOL('3');
                                DUArchitectural:outstream.TXTAddStringEOL('4');
                                   DUFractional:outstream.TXTAddStringEOL('5');
                                       DUSystem:outstream.TXTAddStringEOL('6');
                       end;{case}
                       outstream.TXTAddStringEOL(dxfGroupCode(278));
                       case pdsp^.Units.DIMDSEP of
                                   DDSDot:outstream.TXTAddStringEOL('46');
                                 DDSComma:outstream.TXTAddStringEOL('44');
                                 DDSSpace:outstream.TXTAddStringEOL('32');
                       end;{case}
                       outstream.TXTAddStringEOL(dxfGroupCode(279));
                       case pdsp^.Placing.DIMTMOVE of
                                   DTMMoveDimLine:outstream.TXTAddStringEOL('0');
                                 DTMCreateLeader:outstream.TXTAddStringEOL('1');
                                 DTMnothung:outstream.TXTAddStringEOL('2');
                       end;{case}

                       if pdsp^.Lines.DIMLWD<>DIMLWDDefaultValue then
                       begin
                        //dxfIntegerout(outhandle,371,pdsp^.Lines.DIMLWD);
                        outstream.TXTAddStringEOL(dxfGroupCode(371));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Lines.DIMLWD));
                       end;
                       if pdsp^.Lines.DIMLWE<>DIMLWEDefaultValue then
                       begin
                        //dxfIntegerout(outhandle,372,pdsp^.Lines.DIMLWE);
                        outstream.TXTAddStringEOL(dxfGroupCode(372));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Lines.DIMLWE));
                       end;

                       if pdsp^.Lines.DIMCLRD<>DIMCLRDDefaultValue then
                       begin
                        outstream.TXTAddStringEOL(dxfGroupCode(176));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Lines.DIMCLRD));
                       end;
                       if pdsp^.Lines.DIMCLRE<>DIMCLREDefaultValue then
                       begin
                        outstream.TXTAddStringEOL(dxfGroupCode(177));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Lines.DIMCLRE));
                       end;
                       if pdsp^.Text.DIMCLRT<>DIMCLRTDefaultValue then
                       begin
                        outstream.TXTAddStringEOL(dxfGroupCode(178));
                        outstream.TXTAddStringEOL(inttostr(pdsp^.Text.DIMCLRT));
                       end;

                      outstream.TXTAddStringEOL(dxfGroupCode(340));
                      p:=pdsp^.Text.DIMTXSTY{drawing.TextStyleTable.FindStyle('Standard',false)};

                      IODXFContext.p2h.MyGetOrCreateValue(p,IODXFContext.handle,temphandle);
                      //GetOrCreateHandle(p,handle,temphandle);

                      outstream.TXTAddStringEOL(inttohex(temphandle, 0));

                      pltp:=drawing.LTypeStyleTable.GetSystemLT(TLTByBlock);
                      if (pdsp^.Lines.DIMLTYPE<>pltp)and(pdsp^.Lines.DIMLTYPE<>nil)then
                      begin
                           outstream.TXTAddStringEOL(dxfGroupCode(1001));
                           outstream.TXTAddStringEOL('ACAD_DSTYLE_DIM_LINETYPE');
                           outstream.TXTAddStringEOL(dxfGroupCode(1070));
                           outstream.TXTAddStringEOL('380');
                           outstream.TXTAddStringEOL(dxfGroupCode(1005));
                           IODXFContext.p2h.MyGetOrCreateValue(pdsp^.Lines.DIMLTYPE,IODXFContext.handle,temphandle);
                           outstream.TXTAddStringEOL(inttohex(temphandle,0));
                      end;
                      if (pdsp^.Lines.DIMLTEX1<>pltp)and(pdsp^.Lines.DIMLTEX1<>nil)then
                      begin
                           outstream.TXTAddStringEOL(dxfGroupCode(1001));
                           outstream.TXTAddStringEOL('ACAD_DSTYLE_DIM_EXT1_LINETYPE');
                           outstream.TXTAddStringEOL(dxfGroupCode(1070));
                           outstream.TXTAddStringEOL('381');
                           outstream.TXTAddStringEOL(dxfGroupCode(1005));
                           IODXFContext.p2h.MyGetOrCreateValue(pdsp^.Lines.DIMLTEX1,IODXFContext.handle,temphandle);
                           outstream.TXTAddStringEOL(inttohex(temphandle,0));
                      end;
                      if (pdsp^.Lines.DIMLTEX2<>pltp)and(pdsp^.Lines.DIMLTEX2<>nil)then
                      begin
                           outstream.TXTAddStringEOL(dxfGroupCode(1001));
                           outstream.TXTAddStringEOL('ACAD_DSTYLE_DIM_EXT2_LINETYPE');
                           outstream.TXTAddStringEOL(dxfGroupCode(1070));
                           outstream.TXTAddStringEOL('382');
                           outstream.TXTAddStringEOL(dxfGroupCode(1005));
                           IODXFContext.p2h.MyGetOrCreateValue(pdsp^.Lines.DIMLTEX2,IODXFContext.handle,temphandle);
                           outstream.TXTAddStringEOL(inttohex(temphandle,0));
                      end;

                      pdsp:=drawing.DimStyleTable.iterate(ir);
                until pdsp=nil;
                outstream.TXTAddStringEOL(groups);
                outstream.TXTAddStringEOL(values);
{0
DIMSTYLE
105
2EE
330
2ED
100
AcDbSymbolTableRecord
100
AcDbDimStyleTableRecord
  2
Standard
 70
     0
340
2DC
  0
ENDTAB}

              end
            else if (groupi = 0) and (values = dxfName_ENDTAB)and inappidtable then
                begin
                  inappidtable := false;
                  ignoredsource:=false;

                  RegisterAcadAppInDXF('ACAD',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF('ACAD_PSEXT',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF('AcAecLayerStandard',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF(ZCADAppNameInDXF,@outstream,IODXFContext.handle);
                  //RegisterAcadAppInDXF('ACAD_NAV_VCDISPLAY',@outstream,handle);
                  RegisterAcadAppInDXF('ACAD_DSTYLE_DIM_LINETYPE',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF('ACAD_DSTYLE_DIM_EXT1_LINETYPE',@outstream,IODXFContext.handle);
                  RegisterAcadAppInDXF('ACAD_DSTYLE_DIM_EXT2_LINETYPE',@outstream,IODXFContext.handle);

                  outstream.TXTAddStringEOL(dxfGroupCode(0));
                  outstream.TXTAddStringEOL('ENDTAB');
                end
            else
              if (instyletable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                instyletable := false;
                ignoredsource:=false;
                temphandle2:=IODXFContext.handle-2;
                if drawing.TextStyleTable.GetRealCount>0 then
                begin
                pcurrtextstyle:=drawing.TextStyleTable.beginiterate(ir);
                if pcurrtextstyle<>nil then
                //for i := 0 to drawing.TextStyleTable.count - 1 do
                repeat
                  //if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name <> '0' then
                  if {drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.UsedInLTYPE then
                  begin
                  outstream.TXTAddStringEOL(dxfGroupCode(0));
                  outstream.TXTAddStringEOL(dxfName_Style);
                  p:={drawing.TextStyleTable.getelement(i))}pcurrtextstyle;

                  IODXFContext.p2h.MyGetOrCreateValue({drawing.TextStyleTable.getelement(i))}pcurrtextstyle,IODXFContext.handle,temphandle);
                  //GetOrCreateHandle(drawing.TextStyleTable.getelement(i),handle,temphandle);

                  outstream.TXTAddStringEOL(dxfGroupCode(5));
                  outstream.TXTAddStringEOL(inttohex({handle}temphandle, 0));
                  inc(IODXFContext.handle);
                  outstream.TXTAddStringEOL(dxfGroupCode(330));
                  outstream.TXTAddStringEOL(inttohex(temphandle2, 0));
                  outstream.TXTAddStringEOL(dxfGroupCode(100));
                  outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                  outstream.TXTAddStringEOL(dxfGroupCode(100));
                  outstream.TXTAddStringEOL('AcDbTextStyleTableRecord');
                  outstream.TXTAddStringEOL(dxfGroupCode(2));
                  outstream.TXTAddStringEOL('');
                  outstream.TXTAddStringEOL(dxfGroupCode(70));
                  outstream.TXTAddStringEOL('1');

                  outstream.TXTAddStringEOL(dxfGroupCode(40));
                  outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.size));

                  outstream.TXTAddStringEOL(dxfGroupCode(41));
                  outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.wfactor));

                  outstream.TXTAddStringEOL(dxfGroupCode(50));
                  outstream.TXTAddStringEOL(floattostr(pcurrtextstyle^.prop.oblique*180/pi));

                  outstream.TXTAddStringEOL(dxfGroupCode(71));
                  outstream.TXTAddStringEOL('0');

                  outstream.TXTAddStringEOL(dxfGroupCode(42));
                  outstream.TXTAddStringEOL('2.5');

                  outstream.TXTAddStringEOL(dxfGroupCode(3));
                  outstream.TXTAddStringEOL({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.FontFile);

                  outstream.TXTAddStringEOL(dxfGroupCode(4));
                  outstream.TXTAddStringEOL('');

                  end
                  else
                  begin
                    outstream.TXTAddStringEOL(dxfGroupCode(0));
                    outstream.TXTAddStringEOL(dxfName_Style);
                    outstream.TXTAddStringEOL(dxfGroupCode(5));
                    //if uppercase(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.name)<>TSNStandardStyleName then
                    begin
                    p:={drawing.TextStyleTable.getelement(i))}pcurrtextstyle;

                    IODXFContext.p2h.MyGetOrCreateValue(p,IODXFContext.handle,temphandle);
                    //GetOrCreateHandle(p,handle,temphandle);

                    outstream.TXTAddStringEOL(inttohex(temphandle, 0));
                    //inc(handle);
                    end;
                    {else
                        outstream.TXTAddStringEOL(inttohex(standartstylehandle, 0));}
                  outstream.TXTAddStringEOL(dxfGroupCode(330));
                  outstream.TXTAddStringEOL(inttohex(temphandle2, 0));
                    outstream.TXTAddStringEOL(dxfGroupCode(100));
                    outstream.TXTAddStringEOL(dxfName_AcDbSymbolTableRecord);
                    outstream.TXTAddStringEOL(dxfGroupCode(100));
                    outstream.TXTAddStringEOL('AcDbTextStyleTableRecord');
                    outstream.TXTAddStringEOL(dxfGroupCode(2));
                    outstream.TXTAddStringEOL({pcurrtextstyle^.name}dxfEncodeString(pcurrtextstyle^.name,IODXFContext.Header));
                    outstream.TXTAddStringEOL(dxfGroupCode(70));
                    outstream.TXTAddStringEOL('0');

                    outstream.TXTAddStringEOL(dxfGroupCode(40));
                    outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.size));

                    outstream.TXTAddStringEOL(dxfGroupCode(41));
                    outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.wfactor));

                    outstream.TXTAddStringEOL(dxfGroupCode(50));
                    outstream.TXTAddStringEOL(floattostr({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.prop.oblique*180/pi));

                    outstream.TXTAddStringEOL(dxfGroupCode(71));
                    outstream.TXTAddStringEOL('0');

                    outstream.TXTAddStringEOL(dxfGroupCode(42));
                    outstream.TXTAddStringEOL('2.5');

                    outstream.TXTAddStringEOL(dxfGroupCode(3));
                    outstream.TXTAddStringEOL({drawing.TextStyleTable.getelement(i))}pcurrtextstyle^.FontFile);

                    outstream.TXTAddStringEOL(dxfGroupCode(4));
                    outstream.TXTAddStringEOL('');
                    if pcurrtextstyle^.FontFamily<>'' then begin
                      outstream.TXTAddStringEOL(dxfGroupCode(1001));
                      outstream.TXTAddStringEOL('ACAD');
                      outstream.TXTAddStringEOL(dxfGroupCode(1000));
                      outstream.TXTAddStringEOL(pcurrtextstyle^.FontFamily);
                    end;
                  end;
                pcurrtextstyle:=drawing.TextStyleTable.iterate(ir);
                until pcurrtextstyle=nil;
                end;
                outstream.TXTAddStringEOL(groups);
                outstream.TXTAddStringEOL(values);
              end


              else
                if (groupi = 0) and (values = dxfName_TABLE) then
                begin
                  outstream.TXTAddStringEOL(groups);
                  outstream.TXTAddStringEOL(values);
                  groups := templatefile.readString;
                  values := templatefile.readString;
                  groupi := strtoint(groups);
                  outstream.TXTAddStringEOL(groups);
                  outstream.TXTAddStringEOL(values);
                  if (groupi = 2) and (values = dxfName_Layer) then
                  begin
                    inlayertable := true;
                  end
                  else if (groupi = 2) and (values = dxfName_BLOCK_RECORD) then
                  begin
                    inblocktable := true;
                  end
                  else if (groupi = 2) and (values = dxfName_Style) then
                  begin
                    instyletable := true;
                  end
                  else if (groupi = 2) and (values = dxfName_LType) then
                  begin
                    inlttypetable := true;
                  end
                  else if (groupi = 2) and (values = 'DIMSTYLE') then
                  begin
                    indimstyletable := true;
                  end
                  else if (groupi = 2) and (values = 'APPID') then
                  begin
                    inappidtable := true;
                  end
                  else if (groupi = 2) and (values = 'VPORT') then
                  begin
                    invporttable := true;
                    IgnoredSource := true;
                  end;

                end

              else if (groupi = 0) and (values = dxfName_Layer)and inlayertable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = 'APPID')and inappidtable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = dxfName_Style)and instyletable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = dxfName_LType)and inlttypetable then
                  begin
                    IgnoredSource := true;
                  end
              else if (groupi = 0) and (values = dxfName_DIMSTYLE)and indimstyletable then
                  begin
                    IgnoredSource := true;
                  end
                else
                begin
                  if not ignoredsource then
                  begin
                  outstream.TXTAddStringEOL(groups);
                  outstream.TXTAddStringEOL(values);
                  end;
                  //val('$' + values, i, cod);
                end;
    //s := readspace(s);
  end;
  //templatefileclose;

  i:=outstream.Count;
  outstream.Count:=handlepos;
  outstream.TXTAddStringEOL(inttohex(IODXFContext.handle+$100000000,9){'100000013'});
  outstream.Count:=i;

  //-------------FileSeek(outstream,handlepos,0);
  //-------------WriteString_EOL(outstream,inttohex(handle+1,8));
  //-------------fileclose(outstream);


  //Freemem(Pointer(phandlea));
  OldHandele2NewHandle.Destroy;
  templatefile.done;

  sysfilename:={$IFNDEF DELPHI}utf8tosys{$ENDIF}(SavedFileName);
  if FileExists(sysfilename) then begin
    deletefile(sysfilename+'.bak');
    if not renamefile(sysfilename,sysfilename+'.bak') then
      zDebugLn('{WH}'+rsUnableRenameFileToBak,[SavedFileName]);
  end;

  if outstream.SaveToFile({expandpath}(SavedFileName))<=0 then
                                       begin
                                       //ShowError(format(rsUnableToWriteFile,[SavedFileName]));
                                       zDebugLn('{EM}'+rsUnableToWriteFile,[SavedFileName]);
                                       result:=false;
                                       end
                                   else
                                       result:=true;
  {if assigned(EndLongProcessProc)then
  EndLongProcessProc;}
  lps.EndLongProcess(lph);

  end;
  outstream.done;
  (*!!!if @SetCurrentDWGProc<>nil
                           then
                               if olddwg<>nil then
                                                  SetCurrentDWGProc(olddwg);*)
  IODXFContext.done;
end;
begin
end.
