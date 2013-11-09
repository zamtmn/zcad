{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$MODE OBJFPC}
unit iodxf;
{$INCLUDE def.inc}
interface
uses usimplegenerics,ugdbdimstylearray,gdbentityfactory,{$IFNDEF DELPHI}gmap,gutil,dxfvectorialreader,svgvectorialreader,epsvectorialreader,fpvectorial,fileutil,{$ENDIF}UGDBNamedObjectsArray,ugdbltypearray,ugdbsimpledrawing,zcadsysvars,zcadinterface,{pdfvectorialreader,}GDBCircle,GDBArc,oglwindowdef,dxflow,zcadstrconsts,gdbellipse,UGDBTextStyleArray,varman,geometry,GDBSubordinated,shared,gdbasetypes{,GDBRoot},log,GDBGenericSubEntry,SysInfo,gdbase, {GDBManager,} {OGLtypes,} sysutils{, strmy}, memman, {UGDBDescriptor,}gdbobjectsconstdef,
     UGDBObjBlockdefArray,UGDBOpenArrayOfTObjLinkRecord{,varmandef},UGDBOpenArrayOfByte,UGDBVisibleOpenArray,GDBEntity{,GDBBlockInsert,GDBCircle,GDBArc,GDBPoint,GDBText,GDBMtext,GDBLine,GDBPolyLine,GDBLWPolyLine},TypeDescriptors;
type
   entnamindex=record
                    entname:GDBString;
              end;
const
     acadentignoredcol=1;
     ignorenamtable:array[1..acadentignoredcol]of entnamindex=
     (
     (entname:'HATCH')
     );
     {MODE OBJFPC}
     //a: array of string = ('aaa', 'bbb', 'ccc');
     acadentsupportcol=14;
     entnamtable:array[1..acadentsupportcol]of entnamindex=
     (
     (entname:'POINT'),
     (entname:'LINE'),
     (entname:'CIRCLE'),
     (entname:'POLYLINE'),
     (entname:'TEXT'),
     (entname:'ARC'),
     (entname:'INSERT'),
     (entname:'MTEXT'),
     (entname:'LWPOLYLINE'),
     (entname:'3DFACE'),
     (entname:'SOLID'),
     (entname:'ELLIPSE'),
     (entname:'SPLINE'),
     (entname:'DIMENSION')
     );
const
     NULZCPHeader:ZCPHeader=(
     Signature:'';
     Copyright:'';
     Coment:'';
     HiVersion:0;
     LoVersion:0;
     OffsetTable:(
                  GDB:0;
                  GDBRT:0;
                 );
                );
type
  dxfhandlerec = record
    old, nev: TDWGHandle;
  end;
  dxfhandlerecarray = array[0..300] of dxfhandlerec;
  pdxfhandlerecopenarray = ^dxfhandlerecopenarray;
  dxfhandlerecopenarray = record
    count: GDBInteger;
    arr: dxfhandlerecarray;
  end;
const
  eol: GDBString = #13 + #10;
{$IFDEF DEBUGBUILD}
var i2:GDBInteger;
{$ENDIF}
var FOC:GDBInteger;
    phandlearray: pdxfhandlerecopenarray;
procedure addfromdxf(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
procedure savedxf2000(name: GDBString; {PDrawing:PTSimpleDrawing}var drawing:TSimpleDrawing);
procedure saveZCP(name: GDBString; {gdb: PGDBDescriptor}var drawing:TSimpleDrawing);
procedure LoadZCP(name: GDBString; {gdb: PGDBDescriptor}var drawing:TSimpleDrawing);
{$IFNDEF DELPHI}
procedure Import(name: GDBString;var drawing:TSimpleDrawing);
{$ENDIF}
implementation
uses GDBLine,GDBBlockDef,UGDBLayerArray,varmandef;
function dxfhandlearraycreate(col: GDBInteger): GDBPointer;
var
  temp: pdxfhandlerecopenarray;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{D0FC4FBD-35D4-4E1A-A5E0-6D74D0516215}',{$ENDIF}GDBPointer(temp), sizeof(GDBInteger) + col * sizeof(dxfhandlerec));
  temp^.count := 0;
  result := temp;
end;

procedure pushhandle(p: pdxfhandlerecopenarray; old, nev: GDBPlatformint);
begin
  p^.arr[p^.count].old := old;
  p^.arr[p^.count].nev := nev;
  inc(p^.count);
end;

function getnevhandle(p: pdxfhandlerecopenarray; old: ptruint): GDBPlatformint;
var
  i: GDBInteger;
begin
  for i := 0 to p^.count - 1 do
    if p^.arr[i].old = old then
    begin
      result := p^.arr[i].nev;
      exit;
    end;
  result := -1;
end;
function getnevhandleWithNil(p: pdxfhandlerecopenarray; old: ptruint): GDBPlatformint;
var
  i: GDBInteger;
begin
  for i := 0 to p^.count - 1 do
    if p^.arr[i].old = old then
    begin
      result := p^.arr[i].nev;
      exit;
    end;
  result := 0;
end;
function getoldhandle(p: pdxfhandlerecopenarray; nev: GDBLongword): Integer;
var
  i: GDBInteger;
begin
  for i := 0 to p^.count - 1 do
    if p^.arr[i].nev = nev then
    begin
      result := p^.arr[i].old;
      exit;
    end;
  result := -1;
end;
function ISIFNOREDENT(name:GDBString):GDBInteger;
var i:GDBInteger;
begin
     result:=-1;
     for i:=1 to acadentignoredcol do
          if uppercase(ignorenamtable[i].entname)=uppercase(name) then
          begin
               result:=i;
               exit;
          end;
end;

function entname2GDBID(name:GDBString):GDBInteger;
var i:GDBInteger;
begin
     result:=-1;
     for i:=1 to acadentsupportcol do
          if uppercase(entnamtable[i].entname)=uppercase(name) then
          begin
               result:=i;
               exit;
          end;
end;
procedure gotodxf(var f: GDBOpenArrayOfByte; fcode: GDBInteger; fname: GDBString);
var
  byt: GDBByte;
  s: GDBString;
  error: GDBInteger;
begin
  if fname<>'' then
  begin
  while f.notEOF do
  begin
    s := f.readGDBString;
    val(s, byt, error);
    if error <> 0 then
      s := s{чето тут не так};
    s := f.readGDBString;
    if (byt = fcode) and (s = fname) then
      exit;
  end;
  end
  else
  begin
  while f.notEOF do
  begin
    s := f.readGDBString;
    val(s, byt, error);
    if error <> 0 then
      s := s{чето тут не так};
    if (byt = fcode) then
          exit;
    s := f.readGDBString;
  end;
  end;
end;
procedure readvariables(var f: GDBOpenArrayOfByte;var ctstyle:GDBstring; var clayer:GDBString;var cltype:GDBString;LoadMode:TLoadOpt);
var
  byt: GDBByte;
  s: GDBString;
  error: GDBInteger;
begin
     //gotodxf(f, 0, dxfName_ENDSEC);
  while f.notEOF do
  begin
    s := f.readGDBString;
    val(s, byt, error);
    if error <> 0 then
                      s := s{чето тут не так};
    s := f.readGDBString;
    //programlog.LogOutStrfast(s,0);
     if (byt = 9) and (s = '$CLAYER') then
                                          begin
                                               s := f.readGDBString;
                                               s:=f.readGDBString;
                                               if LoadMode=TLOLoad then
                                                                       clayer := s;
                                          end
else if (byt = 9) and (s = '$TEXTSTYLE') then
                                    begin
                                         s := f.readGDBString;
                                         s:=f.readGDBString;
                                         if LoadMode=TLOLoad then
                                                                 ctstyle := s;
                                    end
else if (byt = 9) and (s = '$CELTYPE') then
                                     begin
                                          s := f.readGDBString;
                                          s:=f.readGDBString;
                                          if LoadMode=TLOLoad then
                                                                  cltype := s;
                                     end
else if (byt = 9) and (s = '$CELWEIGHT') then
                                          begin
                                               s := f.readGDBString;
                                               s := f.readGDBString;
                                               if LoadMode=TLOLoad then
                                               if sysvar.DWG.DWG_CLinew<>nil then
                                               sysvar.DWG.DWG_CLinew^ := strtoint(s);
                                          end
else if (byt = 9) and (s = '$LWDISPLAY') then
                                          begin
                                               s := f.readGDBString;
                                               s := f.readGDBString;
                                               if LoadMode=TLOLoad then
                                               if sysvar.DWG.DWG_DrawMode<>nil then
                                               case strtoint(s) of
                                                               1:sysvar.DWG.DWG_DrawMode^ := true;
                                                               0:sysvar.DWG.DWG_DrawMode^ := false;
                                               end;
                                          end
else if (byt = 9) and (s = '$LTSCALE') then
                                          begin
                                               s := f.readGDBString;
                                               s := f.readGDBString;
                                               if LoadMode=TLOLoad then
                                               if sysvar.DWG.DWG_LTScale<>nil then
                                               sysvar.DWG.DWG_LTScale^ := strtofloat(s);
                                          end
else if (byt = 9) and (s = '$CELTSCALE') then
                                          begin
                                               s := f.readGDBString;
                                               s := f.readGDBString;
                                               if LoadMode=TLOLoad then
                                               if sysvar.DWG.DWG_CLTScale<>nil then
                                               sysvar.DWG.DWG_CLTScale^ := strtofloat(s);
                                          end
else if (byt = 9) and (s = '$CECOLOR') then
                                          begin
                                               s := f.readGDBString;
                                               s := f.readGDBString;
                                               if LoadMode=TLOLoad then
                                               if sysvar.DWG.DWG_CColor<>nil then
                                               sysvar.DWG.DWG_CColor^ := strtoint(s);
                                          end
else if (byt = 0) and (s = dxfName_ENDSEC) then
                                              exit;
  end;
end;
function GoToDXForENDTAB(var f: GDBOpenArrayOfByte; fcode: GDBInteger; fname: GDBString):boolean;
var
  byt: GDBByte;
  s: GDBString;
  error: GDBInteger;
begin
  result:=false;
  while f.notEOF do
  begin
    s := f.readGDBString;
    val(s, byt, error);
    if error <> 0 then
      s := s{чето тут не так};
    s := f.readGDBString;
    if (byt = fcode) and (s = fname) then
                                         begin
                                              result:=true;
                                              exit;
                                         end;
    if (byt = 0) and (uppercase(s) = dxfName_ENDTAB) then
                                         begin
                                              exit;
                                         end;
  end;
end;

procedure correctvariableset(pobj: PGDBObjEntity);
var vd:vardesk;
begin
     //if (pobj.vp.ID=GDBBlockInsertID)or
     //   (pobj.vp.ID=GDBCableID) then
        begin
             if pobj^.ou.FindVariable('GC_HeadDevice')<>nil then
             if pobj^.ou.FindVariable('GC_Metric')=nil then
             begin
                  pobj^.ou.setvardesc(vd,'GC_Metric','','GDBString');
                  pobj^.ou.InterfaceVariables.createvariable(vd.name,vd);
             end;

             if pobj^.ou.FindVariable('GC_HDGroup')<>nil then
             if pobj^.ou.FindVariable('GC_HDGroupTemplate')=nil then
             begin
                  pobj^.ou.setvardesc(vd,'GC_HDGroupTemplate','Шаблон группы','GDBString');
                  pobj^.ou.InterfaceVariables.createvariable(vd.name,vd);
             end;
             if pobj^.ou.FindVariable('GC_HeadDevice')<>nil then
             if pobj^.ou.FindVariable('GC_HeadDeviceTemplate')=nil then
             begin
                  pobj^.ou.setvardesc(vd,'GC_HeadDeviceTemplate','Шаблон головного устройства','GDBString');
                  pobj^.ou.InterfaceVariables.createvariable(vd.name,vd);
             end;

             if pobj^.ou.FindVariable('GC_HDShortName')<>nil then
             if pobj^.ou.FindVariable('GC_HDShortNameTemplate')=nil then
             begin
                  pobj^.ou.setvardesc(vd,'GC_HDShortNameTemplate','Шаблон короткого имени головного устройства','GDBString');
                  pobj^.ou.InterfaceVariables.createvariable(vd.name,vd);
             end;
             if pobj^.ou.FindVariable('GC_Metric')<>nil then
             if pobj^.ou.FindVariable('GC_InGroup_Metric')=nil then
             begin
                  pobj^.ou.setvardesc(vd,'GC_InGroup_Metric','Метрика нумерации в группе','GDBString');
                  pobj^.ou.InterfaceVariables.createvariable(vd.name,vd);
             end;


        end;
end;

procedure addentitiesfromdxf(var f: GDBOpenArrayOfByte;exitGDBString: GDBString;owner:PGDBObjSubordinated;var drawing:TSimpleDrawing);
var
//  byt,LayerColor: GDBInteger;
  s{, sname, sx1, sy1, sz1,scode,LayerName}: GDBString;
//  ErrorCode,GroupCode: GDBInteger;

objid: GDBInteger;
  pobj,postobj: PGDBObjEntity;
//  tp: PGDBObjBlockdef;
  newowner:PGDBObjSubordinated;
  m4:DMatrix4D;
  trash:boolean;
  additionalunit:TUnit;
begin
  additionalunit.init('temparraryunit');
  additionalunit.InterfaceUses.addnodouble(@SysUnit);
  while (f.notEOF) and (s <> exitGDBString) do
  begin
    if assigned(ProcessLongProcessProc) then
                                            ProcessLongProcessProc(f.ReadPos);

    s := f.readGDBString;
    objid:=entname2GDBID(s);
    if objid>0 then
    begin
    if owner <> nil then
      begin
        {$IFDEF TOTALYLOG}programlog.logoutstr('AddEntitiesFromDXF.Found primitive '+s,0);{$ENDIF}
        {$IFDEF DEBUGBUILD}inc(i2);if i2=4349 then
                                                  i2:=i2;{$ENDIF}
        pobj := {po^.CreateInitObj(objid,owner)}CreateInitObjFree(objid,nil);
        PGDBObjEntity(pobj)^.LoadFromDXF(f,@additionalunit,drawing);
        if (PGDBObjEntity(pobj)^.vp.Layer=@DefaultErrorLayer)or(PGDBObjEntity(pobj)^.vp.Layer=nil) then
                                                                 PGDBObjEntity(pobj)^.vp.Layer:=drawing.LayerTable.GetSystemLayer;
        if (PGDBObjEntity(pobj)^.vp.LineType=nil) then
                                                      PGDBObjEntity(pobj)^.vp.LineType:=drawing.LTypeStyleTable.getAddres('ByLayer');
        correctvariableset(pobj);
        pointer(postobj):=PGDBObjEntity(pobj)^.FromDXFPostProcessBeforeAdd(@additionalunit,drawing);
        trash:=false;
        if postobj=nil  then
                            begin
                                newowner:=owner;
                                if PGDBObjEntity(pobj)^.PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj)^.PExtAttrib^.Handle>200 then
                                                                                      pushhandle(phandlearray,PGDBObjEntity(pobj)^.PExtAttrib^.Handle,GDBPlatformint(pobj));
                                     if PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle>200 then
                                                                                      newowner:=pointer(getnevhandleWithNil(phandlearray,PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle));
                                     if PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle=h_trash then
                                                                                      trash:=true;


                                end;
                                if newowner=nil then
                                                    begin
                                                         historyoutstr('Warning! OwnerHandle $'+inttohex(PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle,8)+' not found');
                                                         newowner:=owner;
                                                    end;

                                if not trash then
                                begin
                                if (newowner<>owner) then
                                begin
                                     m4:=PGDBObjEntity(newowner)^.getmatrix^;
                                     MatrixInvert(m4);
                                     //pobj^.Format;
                                     pobj^.CalcObjMatrix;
                                     pobj^.transform(m4);
                                end
                                else
                                    pobj^.CalcObjMatrix;
                                end;
                                if not trash then
                                begin
                                 newowner^.AddMi(@pobj);
                                 if foc=0 then
                                              PGDBObjEntity(pobj)^.BuildGeometry(drawing);
                                 if foc=0 then
                                              //PGDBObjEntity(pobj)^.format;
                                              PGDBObjEntity(pobj)^.FormatAfterDXFLoad(drawing);
                                 if foc=0 then PGDBObjEntity(pobj)^.FromDXFPostProcessAfterAdd;
                                end
                                   else
                                       begin
                                 pobj^.done;
                                 GDBFreeMem(pointer(pobj));

                                       end;

                            end
                        else
                            begin
                                newowner:=owner;
                                if PGDBObjEntity(pobj)^.PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle>200 then
                                                                                      newowner:=pointer(getnevhandleWithNil(phandlearray,PGDBObjEntity(pobj)^.PExtAttrib^.OwnerHandle));
                                end;
                                if newowner<>nil then
                                begin
                                if PGDBObjEntity(pobj)^.PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj)^.PExtAttrib^.Handle>200 then
                                                                                      pushhandle(phandlearray,PGDBObjEntity(pobj)^.PExtAttrib^.Handle,GDBPlatformint(postobj));
                                end;
                                if newowner=pointer($ffffffff) then
                                                           newowner:=newowner;
                                if newowner<>owner then
                                begin
                                     m4:=PGDBObjEntity(newowner)^.getmatrix^;
                                     MatrixInvert(m4);
                                     postobj^.FormatEntity(drawing);
                                     postobj^.transform(m4);
                                end;

                                 newowner^.AddMi(@postobj);
                                 pobj^.OU.CopyTo(@PGDBObjEntity(postobj)^.ou);
                                 pobj^.done;
                                 GDBFreeMem(pointer(pobj));
                                 if foc=0 then
                                              PGDBObjEntity(postobj)^.BuildGeometry(drawing);
                                 if foc=0 then
                                              begin
                                                //PGDBObjEntity(postobj)^.Format;
                                                PGDBObjEntity(postobj)^.FormatAfterDXFLoad(drawing);
                                              end;
                                 if foc=0 then PGDBObjEntity(postobj)^.FromDXFPostProcessAfterAdd;
                                end
                                   //else
                                   //    newowner:=newowner;
                            end;
      end;
      additionalunit.free;
    end
    else
    begin
         objid:=ISIFNOREDENT(s);
         if objid>0 then
         gotodxf(f, 0, '');
    end;
  end;
  additionalunit.done;
end;
procedure addfromdxf12(var f:GDBOpenArrayOfByte;exitGDBString: GDBString;owner:PGDBObjSubordinated;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
  {byt,}LayerColor: GDBInteger;
  s, sname{, sx1, sy1, sz1},scode,LayerName: GDBString;
  ErrorCode,GroupCode: GDBInteger;

//objid: GDBInteger;
//  pobj,postobj: PGDBObjEntity;
  tp: PGDBObjBlockdef;
begin
  {$IFDEF TOTALYLOG}programlog.logoutstr('AddFromDXF12',lp_IncPos);{$ENDIF}
  while (f.notEOF) and (s <> exitGDBString) do
  begin
  if assigned(ProcessLongProcessProc)then
  ProcessLongProcessProc(f.ReadPos);

    s := f.readGDBString;
    if s = dxfName_Layer then
    begin
      {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer table',lp_IncPos);{$ENDIF}
      repeat
            scode := f.readGDBString;
            sname := f.readGDBString;
            val(scode,GroupCode,ErrorCode);
      until GroupCode=0;
      repeat
        if sname=dxfName_ENDTAB then system.break;
        if sname<>dxfName_Layer then FatalError('''LAYER'' expected but '''+sname+''' found');
        repeat
              scode := f.readGDBString;
              sname := f.readGDBString;
              val(scode,GroupCode,ErrorCode);
              case GroupCode of
                               2:LayerName:=sname;
                               62:val(sname,LayerColor,ErrorCode);
              end;{case}
        until GroupCode=0;
        {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer '+LayerName,0);{$ENDIF}
        drawing.LayerTable.addlayer(LayerName,LayerColor,-3,true,false,true,'',TLOLoad);
      until sname=dxfName_ENDTAB;
      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {layer table}',lp_DecPos);{$ENDIF}
    end
    else if s = 'BLOCKS' then
    begin
      {$IFDEF TOTALYLOG}programlog.logoutstr('Found block table',lp_IncPos);{$ENDIF}
      sname := '';
      repeat
        if sname = '  2' then
          if (s = '$MODEL_SPACE') or (s = '$PAPER_SPACE') then
          begin
            while (s <> 'ENDBLK') do
              s := f.readGDBString;
          end
          else
          begin
            tp := drawing.BlockDefArray.create(s);
            programlog.logoutstr('Found block '+s+';',lp_IncPos);
            {addfromdxf12}addentitiesfromdxf(f, 'ENDBLK',tp,drawing);
            programlog.logoutstr('end; {block '+s+'}',lp_DecPos);
          end;
        sname := f.readGDBString;
        s := f.readGDBString;
      until (s = dxfName_ENDSEC);
      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {block table}',lp_DecPos);{$ENDIF}
    end
    else if s = 'ENTITIES' then
    begin
         {$IFDEF TOTALYLOG}programlog.logoutstr('Found entities section',lp_IncPos);{$ENDIF}
         addentitiesfromdxf(f, 'EOF',owner,drawing);;
         {$IFDEF TOTALYLOG}programlog.logoutstr('end {entities section}',lp_DecPos);{$ENDIF}
    end;
  end;
  {$IFDEF TOTALYLOG}programlog.logoutstr('end; {AddFromDXF12}',lp_decPos);{$ENDIF}
end;
procedure ReadLTStyles(var s:String;cltype:string;var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
   pltypeprop:PGDBLtypeProp;
   byt: GDBInteger;
   dashinfo:TDashInfo;
   shapenumber,stylehandle:TDWGHandle;
   PSP:PShapeProp;
   PTP:PTextProp;
   BShapeProp:BasicSHXDashProp;
   txtstr:string;
   TempDouble:GDBDouble;
   error,flags: GDBInteger;
begin
  dashinfo:=TDIDash;
  if GoToDXForENDTAB(f, 0, dxfName_LType) then
  while s = dxfName_LType do
  begin
       pltypeprop:=nil;
       byt := 2;
       while byt <> 0 do
       begin
       s := f.readGDBString;
       byt := strtoint(s);
       s := f.readGDBString;
       case byt of
       2:
         begin
           case drawing.LTypeStyleTable.AddItem(s,pointer(pltypeprop)) of
                        IsFounded:
                                  begin
                                       if LoadMode=TLOLoad then
                                       begin
                                       end
                                       else
                                           pltypeprop:=nil;
                                  end;
                        IsCreated:
                                  begin
                                       pltypeprop^.init(s);
                                       dashinfo:=TDIDash;
                                  end;
                        IsError:
                                  begin
                                  end;
                end;
              if uppercase(s)=uppercase(cltype)then
                                                   if sysvar.DWG.DWG_CLType<>nil then
                                                                                     sysvar.DWG.DWG_CLType^:=pltypeprop;

         end;
       3:
         begin
              if pltypeprop<>nil then
                                pltypeprop^.desk:=s;
         end;
       40:
         begin
              if pltypeprop<>nil then
              pltypeprop^.len:=strtofloat(s);
         end;
       49:
          begin
               if pltypeprop<>nil then
               begin
               case dashinfo of
               TDIShape:begin
                             if stylehandle<>0 then
                             begin
                                 pointer(psp):=pltypeprop^.shapearray.CreateObject;
                                 psp^.initnul;
                                 psp^.param:=BShapeProp.param;
                                 psp^.Psymbol:=pointer(shapenumber);
                                 psp^.param.PStyle:=pointer(stylehandle);
                                 pltypeprop^.dasharray.Add(@dashinfo);
                             end;
                        end;
               TDIText:begin
                             pointer(ptp):=pltypeprop^.Textarray.CreateObject;
                             ptp^.initnul;
                             ptp^.param:=BShapeProp.param;
                             ptp^.Text:=txtstr;
                             //ptp^.Style:=;
                             ptp^.param.PStyle:=pointer(stylehandle);
                             pltypeprop^.dasharray.Add(@dashinfo);
                        end;
               end;
                    dashinfo:=TDIDash;
                    TempDouble:=strtofloat(s);
                    pltypeprop^.dasharray.Add(@dashinfo);
                    pltypeprop^.strokesarray.Add(@TempDouble);
               end;
          end;
       74:if pltypeprop<>nil then
          begin
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
      9:begin if pltypeprop<>nil then
              txtstr:=s;
         end;
       end;
       end;
  end;
end;
procedure ReadLayers(var s:string;clayer:string;var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
byt: GDBInteger;
lname,desk: String;
nulisread:boolean;
player:PGDBLayerProp;
begin
  nulisread:=false;
  gotodxf(f, 0, dxfName_Layer);
  player:=nil;
  while s = dxfName_Layer do
  begin
    byt := 2;
    while byt <> 0 do
    begin
      if not nulisread then
      begin
      s := f.readGDBString;
      byt := strtoint(s);
      s := f.readGDBString;
      end
      else
          nulisread:=false;
      case byt of
        2:
          begin
            {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer '+s,0);{$ENDIF}
            lname:=s;
            player:=drawing.LayerTable.MergeItem(s,LoadMode);
            if player<>nil then
                               player^.init(s);
          end;
        6:
          begin
               if player<>nil then
                                  player^.LT:=drawing.LTypeStyleTable.getAddres(s);
          end;
        1001:
          begin
               if s='AcAecLayerStandard' then
                 begin
                      s := f.readGDBString;
                      byt:=strtoint(s);
                      if byt<>0 then
                      begin
                          s := f.readGDBString;
                          begin
                                s := f.readGDBString;
                                byt:=strtoint(s);
                                if byt<>0 then
                                              begin
                                                   desk := f.readGDBString;
                                                   if player<>nil then
                                                                      player^.desk:=desk;
                                              end
                                          else
                                              begin
                                              nulisread:=true;
                                              s := f.readGDBString;
                                              end;

                          end;
                      end
                         else
                         begin
                          nulisread:=true;
                          s := f.readGDBString;
                         end;
                 end;
           end;
         else begin
                   if player<>nil then
                                  player^.SetValueFromDxf(byt,s);
              end;

      end;
    end;

    if uppercase(lname)=uppercase(clayer)then
                                             if sysvar.DWG.DWG_CLayer<>nil then
                                                                               sysvar.DWG.DWG_CLayer^:=player;
  end;
end;
procedure ReadTextstyles(var s:string;ctstyle:string;var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
   tstyle:GDBTextStyle;
   ptstyle:PGDBTextStyle;
   DWGHandle:TDWGHandle;
   byt: GDBInteger;
   error,flags: GDBInteger;
   sname, lname, lcolor, llw,desk,ltn: String;
   ti:PGDBTextStyle;
   pltypeprop:PGDBLtypeProp;
   ir,ir2:itrec;
   PSP:PShapeProp;
   PTP:PTextProp;
   TDInfo:TTrianglesDataInfo;
begin
  if GoToDXForENDTAB(f, 0, dxfName_Style) then
  while s = dxfName_Style do
  begin
    tstyle.name:='';
    tstyle.pfont:=nil;
    tstyle.prop.oblique:=0;
    tstyle.prop.size:=1;
    DWGHandle:=0;

    byt := 2;

    while byt <> 0 do
    begin
      s := f.readGDBString;
      byt := strtoint(s);
      s := f.readGDBString;
      case byt of
        2:
          begin
            tstyle.name := s;
          end;
        5:begin
               DWGHandle:=strtoint64('$'+s)
          end;

        40:
          begin
            tstyle.prop.size:=strtofloat(s);
          end;
        41:
          begin
            tstyle.prop.wfactor:=strtofloat(s);
          end;
        50:
          begin
            tstyle.prop.oblique:=strtofloat(s);
          end;
        70:begin
                flags:=strtoint(s);
           end;
        3:
          begin
               lname:=s;
               //FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,s));
               //tstyle.pfont:=FontManager.getAddres(s);
               //if tstyle.pfont:=;
           end;
      end;
    end;
    ti:=nil;
    if (flags and 1)=0 then
    begin
    ti:=drawing.TextStyleTable.FindStyle(tstyle.Name,false);
    if ti<>nil then
    begin
      if LoadMode=TLOLoad then
                              ti:=drawing.TextStyleTable.setstyle(tstyle.Name,lname,tstyle.prop,false);
    end
       else
           ti:=drawing.TextStyleTable.addstyle(tstyle.Name,lname,tstyle.prop,false);
    end
    else
        begin
          if drawing.TextStyleTable.FindStyle(lname,true)<>nil then
          begin
            if LoadMode=TLOLoad then
                                    ti:=drawing.TextStyleTable.setstyle(lname,lname,tstyle.prop,true);
          end
             else
                 ti:=drawing.TextStyleTable.addstyle(lname,lname,tstyle.prop,true);
        end;
    if ti<>nil then
    begin
         ptstyle:={drawing.TextStyleTable.getelement}(ti);
         pltypeprop:=drawing.LTypeStyleTable.beginiterate(ir);
         if pltypeprop<>nil then
         repeat
               PSP:=pltypeprop^.shapearray.beginiterate(ir2);
               if PSP<>nil then
               repeat
                     if psp^.param.PStyle=pointer(DWGHandle) then
                     begin
                        psp^.param.PStyle:=ptstyle;
                        psp^.FontName:=ptstyle^.dxfname;
                        psp^.Psymbol:=ptstyle^.pfont^.GetOrReplaceSymbolInfo(integer(psp^.Psymbol),tdinfo);
                        psp^.SymbolName:=psp^.Psymbol^.Name;
                     end;

                     PSP:=pltypeprop^.shapearray.iterate(ir2);
               until PSP=nil;

               PTP:=pltypeprop^.Textarray.beginiterate(ir2);
               if PTP<>nil then
               repeat
                     if pTp^.param.PStyle=pointer(DWGHandle) then
                     begin
                        pTp^.param.PStyle:=ptstyle;
                        {pTp^.FontName:=ptstyle^.dxfname;
                        pTp^.Psymbol:=ptstyle^.pfont^.GetOrReplaceSymbolInfo(integer(pTp^.Psymbol));
                        pTp^.SymbolName:=pTp^.Psymbol^.Name;}
                     end;

                     PTP:=pltypeprop^.Textarray.iterate(ir2);
               until PTP=nil;

               pltypeprop:=drawing.LTypeStyleTable.iterate(ir);
         until pltypeprop=nil;
    end;
    {$IFDEF TOTALYLOG}programlog.logoutstr('Found style '+tstyle.Name,0);{$ENDIF}
   if uppercase(tstyle.Name)=uppercase(ctstyle)then
                if sysvar.DWG.DWG_CTStyle<>nil then
                                                  sysvar.DWG.DWG_CTStyle^:=drawing.TextStyleTable.FindStyle(tstyle.Name,false);
    tstyle.Name:='';
  end;
  drawing.LTypeStyleTable.format;
end;
procedure ReadVport(var s:string;var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
   byt: GDBInteger;
   active:boolean;
   error,flags: GDBInteger;
begin
                               if GoToDXForENDTAB(f, 0, 'VPORT') then
                               begin
                                 byt := -100;
                                 active:=false;

                                 while byt <> 0 do
                                 begin
                                   s := f.readGDBString;
                                   programlog.LogOutStr(s,0);
                                   byt := strtoint(s);
                                   s := f.readGDBString;
                                   if (byt=0)and(s='VPORT')then
                                   begin
                                         byt := -100;
                                         active:=false;
                                   end;
                                   programlog.LogOutStr(s,0);
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
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if @drawing<>nil then
                                            if drawing.pcamera<>nil then
                                            begin
                                                 drawing.pcamera^.prop.point.x:=-strtofloat(s);
                                            end;
                                        end;
                                     22:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if @drawing<>nil then
                                            if drawing.pcamera<>nil then
                                            begin
                                                 drawing.pcamera^.prop.point.y:=-strtofloat(s);
                                            end;
                                        end;
                                     13:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if sysvar.DWG.DWG_Snap<>nil then
                                            begin
                                                 sysvar.DWG.DWG_Snap^.Base.x:=strtofloat(s);
                                            end;
                                        end;
                                     23:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if sysvar.DWG.DWG_Snap<>nil then
                                            begin
                                                 sysvar.DWG.DWG_Snap^.Base.y:=strtofloat(s);
                                            end;
                                        end;
                                     14:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if sysvar.DWG.DWG_Snap<>nil then
                                            begin
                                                 sysvar.DWG.DWG_Snap^.Spacing.x:=strtofloat(s);
                                            end;
                                        end;
                                     24:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if sysvar.DWG.DWG_Snap<>nil then
                                            begin
                                                 sysvar.DWG.DWG_Snap^.Spacing.y:=strtofloat(s);
                                            end;
                                        end;
                                     15:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if sysvar.DWG.DWG_GridSpacing<>nil then
                                            begin
                                                 sysvar.DWG.DWG_GridSpacing^.x:=strtofloat(s);
                                            end;
                                        end;
                                     25:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if sysvar.DWG.DWG_GridSpacing<>nil then
                                            begin
                                                 sysvar.DWG.DWG_GridSpacing^.y:=strtofloat(s);
                                            end;
                                        end;
                                     40:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if @drawing<>nil then
                                            if drawing.pcamera<>nil then
                                            if drawing.OGLwindow1<>nil then
                                            begin
                                                 drawing.pcamera^.prop.zoom:=(strtofloat(s)/drawing.OGLwindow1.ClientHeight);
                                            end;
                                        end;
                                     41:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if @drawing<>nil then
                                            if drawing.pcamera<>nil then
                                            if drawing.OGLwindow1<>nil then
                                            begin
                                                 if drawing.OGLwindow1.ClientHeight*strtofloat(s)>drawing.OGLwindow1.ClientWidth then
                                                 drawing.pcamera^.prop.zoom:=drawing.pcamera^.prop.zoom*strtofloat(s)*drawing.OGLwindow1.ClientHeight/drawing.OGLwindow1.ClientWidth;
                                            end;
                                        end;
                                     71:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if @drawing<>nil then
                                            if drawing.OGLwindow1<>nil then
                                            begin
                                                 flags:=strtoint(s);
                                                 if (flags and 1)<>0 then
                                                               drawing.OGLwindow1.param.projtype:=PROJPerspective
                                                           else
                                                               drawing.OGLwindow1.param.projtype:=PROJParalel;
                                            end;
                                       end;
                                     75:
                                       begin
                                            if LoadMode=TLOLoad then
                                            if active then
                                            if sysvar.DWG.DWG_SnapGrid<>nil then
                                            begin
                                                 if s<>'0' then
                                                               sysvar.DWG.DWG_SnapGrid^:=true
                                                           else
                                                               sysvar.DWG.DWG_SnapGrid^:=false;
                                            end;
                                       end;
                                   76:
                                     begin
                                          if LoadMode=TLOLoad then
                                          if active then
                                          if sysvar.DWG.DWG_DrawGrid<>nil then
                                          begin
                                               if s<>'0' then
                                                             sysvar.DWG.DWG_DrawGrid^:=true
                                                         else
                                                             sysvar.DWG.DWG_DrawGrid^:=false;
                                          end;
                                      end;
                                 end;

                               end;
                               end;
end;
procedure ReadDimStyles(var s:string;var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
   psimstyleprop:PGDBDimStyle;
   byt:integer;
begin
if GoToDXForENDTAB(f, 0, dxfName_DIMSTYLE) then
while s = dxfName_DIMSTYLE do
begin
     psimstyleprop:=nil;
     byt := 2;
     while byt <> 0 do
     begin
     s := f.readGDBString;
     byt := strtoint(s);
     s := f.readGDBString;


     if psimstyleprop=nil then
     begin
           if byt=2 then
                         begin
                              psimstyleprop:=drawing.DimStyleTable.MergeItem(s,LoadMode);
                              if psimstyleprop<>nil then
                                                        psimstyleprop^.init(s);
                         end;
     end
     else
         psimstyleprop^.SetValueFromDxf(byt,s);
     end;
end;
end;
procedure ReadBlockRecird(const Handle2BlockName:TMapBlockHandle_BlockNames;var s:string;var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
   byt:integer;
   bname:string;
   bhandle:TDWGHandle;
begin
while s = dxfName_BLOCKRECORD do
begin
     byt := 2;
     while byt <> 0 do
     begin
     s := f.readGDBString;
     byt := strtoint(s);
     s := f.readGDBString;
     if byt=2 then
                  begin
                       bname:=s;
                       Handle2BlockName.Insert(bhandle,bname);
                  end;
     if byt=5 then
                  begin
                       bhandle:=DXFHandle(s);
                  end;
     end;
end;
end;

procedure addfromdxf2000(var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
  byt: GDBInteger;
  error: GDBInteger;
  s, sname: String;
  tp: PGDBObjBlockdef;
  blockload:boolean;

  clayer,cltype,ctstyle:GDBString;
  Handle2BlockName:TMapBlockHandle_BlockNames;
begin
  {$IFNDEF DELPHI}
  Handle2BlockName:=TMapBlockHandle_BlockNames.Create;
  {$ENDIF}
  blockload:=false;
  {$IFDEF TOTALYLOG}programlog.logoutstr('AddFromDXF2000',lp_IncPos);{$ENDIF}
  readvariables(f,ctstyle,clayer,cltype,LoadMode);
  repeat
    gotodxf(f, 0, dxfName_SECTION);
    if not f.notEOF then
      exit;
    s := f.readGDBString;
    s := f.readGDBString;
    if s = dxfName_TABLES then
    begin
      if not f.notEOF then
        exit;
      s := f.readGDBString;
      s := f.readGDBString;
      while s = dxfName_TABLE do
      begin
        if not f.notEOF then
          exit;
        s := f.readGDBString;
        s := f.readGDBString;

        case s of
                    dxfName_CLASSES:
                                    gotodxf(f, 0, dxfName_ENDTAB);//scip this table
                      dxfName_APPID:
                                    gotodxf(f, 0, dxfName_ENDTAB);//scip this table
               dxfName_BLOCK_RECORD:
                                    begin
                                    {$IFDEF TOTALYLOG}programlog.logoutstr('Found BLOCK_RECORD table',lp_IncPos);{$ENDIF}
                                    ReadBlockRecird(Handle2BlockName,s,f,exitGDBString,owner,LoadMode,drawing);
                                    {$IFDEF TOTALYLOG}programlog.logoutstr('end; {BLOCK_RECORD table}',lp_DecPos);{$ENDIF}
                                    end;
                   dxfName_DIMSTYLE:
                                    begin
                                      {$IFDEF TOTALYLOG}programlog.logoutstr('Found dimstyles table',lp_IncPos);{$ENDIF}
                                      ReadDimStyles(s,f,exitGDBString,owner,LoadMode,drawing);
                                      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {dimstyles table}',lp_DecPos);{$ENDIF}
                                    end;
                      dxfName_Layer:
                                    begin
                                      {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer table',lp_IncPos);{$ENDIF}
                                      ReadLayers(s,clayer,f,exitGDBString,owner,LoadMode,drawing);
                                      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {layer table}',lp_DecPos);{$ENDIF}
                                    end;
                      dxfName_LType:
                                    begin
                                      {$IFDEF TOTALYLOG}programlog.logoutstr('Found line types table',lp_IncPos);{$ENDIF}
                                      ReadLTStyles(s,cltype,f,exitGDBString,owner,LoadMode,drawing);
                                      {$IFDEF TOTALYLOG}programlog.logoutstr('end; (line types table)',lp_DecPos);{$ENDIF}
                                    end;
                      dxfName_Style:
                                    begin
                                      {$IFDEF TOTALYLOG}programlog.logoutstr('Found style table',lp_IncPos);{$ENDIF}
                                      ReadTextstyles(s,ctstyle,f,exitGDBString,owner,LoadMode,drawing);
                                      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {style table}',lp_DecPos);{$ENDIF}
                                    end;
                              'UCS':
                                    gotodxf(f, 0, dxfName_ENDTAB);//scip this table
                             'VIEW':
                                    gotodxf(f, 0, dxfName_ENDTAB);//scip this table
                            'VPORT':
                                    begin
                                    {$IFDEF TOTALYLOG}programlog.logoutstr('Found vports table',lp_IncPos);{$ENDIF}
                                    ReadVport(s,f,exitGDBString,owner,LoadMode,drawing);
                                    {$IFDEF TOTALYLOG}programlog.logoutstr('end; {vports table}',lp_DecPos);{$ENDIF}
                                    end;
        end;{case}
        s := f.readGDBString;
        s := f.readGDBString;
      end;

    end
    else
      if s = 'ENTITIES' then
      begin
        {$IFDEF TOTALYLOG}programlog.logoutstr('Found entities section',lp_IncPos);{$ENDIF}
        //inc(foc);
        {addfromdxf12}addentitiesfromdxf(f, dxfName_ENDSEC,owner,drawing);
        owner^.ObjArray.pack;
        owner^.correctobjects(nil,0);
        //inc(foc);
        {$IFDEF TOTALYLOG}programlog.logoutstr('end {entities section}',lp_DecPos);{$ENDIF}
      end
      else
        if s = 'BLOCKS' then
        begin
          {$IFDEF TOTALYLOG}programlog.logoutstr('Found block table',lp_IncPos);{$ENDIF}
          sname := '';
          repeat
            if (sname = '  2') or (sname = '2') then
              if (pos('MODEL_SPACE',uppercase(s))<>0)or(pos('PAPER_SPACE',uppercase(s))<>0)then
              begin
                //programlog.logoutstr('Ignored block '+s+';',lp_OldPos);
                shared.HistoryOutStr(format(rsBlockIgnored,[s]));
                while (s <> 'ENDBLK') do
                  s := f.readGDBString;
              end
              else if drawing.BlockDefArray.getindex(pointer(@s[1]))>=0 then
                               begin
                                    //programlog.logoutstr('Ignored double definition block '+s+';',lp_OldPos);
                                    shared.HistoryOutStr(format(rsDoubleBlockIgnored,[s]));
                                    if s='DEVICE_PS_UK-VK'then
                                               s:=s;
                                    while (s <> 'ENDBLK') do
                                    s := f.readGDBString;
                               end
              else begin
                   if s='DEVICE_PS_AR2' then
                                  s:=s;

                tp := drawing.BlockDefArray.create(s);
                programlog.logoutstr('Found block '+s+';',lp_IncPos);
                   //addfromdxf12(f, GDBPointer(GDB.pgdbblock^.blockarray[GDB.pgdbblock^.count].ppa),@tp^.Entities, 'ENDBLK');
                while (s <> ' 30') and (s <> '30') do
                begin
                  s := f.readGDBString;
                  val(s, byt, error);
                  case byt of
                    10:
                      begin
                        s := f.readGDBString;
                        tp^.Base.x := strtofloat(s);
                      end;
                    20:
                      begin
                        s := f.readGDBString;
                        tp^.Base.y := strtofloat(s);
                      end;
                  end;
                end;
                s := f.readGDBString;
                tp^.Base.z := strtofloat(s);
                inc(foc);
                AddEntitiesFromDXF(f,'ENDBLK',tp,drawing);
                dec(foc);
                if tp^.name='TX' then
                                                           tp^.name:=tp^.name;
                tp^.LoadFromDXF(f,nil,drawing);
                blockload:=true;
                programlog.logoutstr('end block;',lp_DecPos);
                sname:='##'
              end;
            if not blockload then
                                 sname := f.readGDBString;
            blockload:=false;
            s := f.readGDBString;
          until (s = dxfName_ENDSEC);
          {$IFDEF TOTALYLOG}programlog.logoutstr('end; {block table}',lp_DecPos);{$ENDIF}
          drawing.BlockDefArray.Format;
          drawing.DimStyleTable.ResolveDXFHandles(Handle2BlockName);
        end;

    s := s;
//       if (byt=fcode) and (s=fname) then exit;
    if assigned(ProcessLongProcessProc)then
    ProcessLongProcessProc(f.ReadPos);
  until not f.notEOF;
  {$IFNDEF DELPHI}
  Handle2BlockName.destroy;
  {$ENDIF}
  {$IFDEF TOTALYLOG}programlog.logoutstr('end; {AddFromDXF2000}',lp_decPos);{$ENDIF}
end;

procedure addfromdxf(name: GDBString;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
  f: GDBOpenArrayOfByte;
  s,s1,s2: GDBString;
  dxfversion,code:integer;
begin
  programlog.logoutstr('AddFromDXF',lp_IncPos);
  shared.HistoryOutStr(format(rsLoadingFile,[name]));
  f.InitFromFile(name);
  if f.Count<>0 then
  begin
     phandlearray := dxfhandlearraycreate(10000);
  //f.ReadFromFile(name);
  if assigned(StartLongProcessProc)then
    StartLongProcessProc(f.Count,'Load DXF file');
  while f.notEOF do
  begin
    s := f.ReadString2;
    if s = '$ACADVER' then
    begin
      s := f.ReadString2;
      if s = '1' then
      begin
        s := f.ReadString2;

        s1:=copy(s,3,length(s)-2);
        s2:=copy(s,1,2);
        val(s1,dxfversion,code);

        if (uppercase(s2)='AC')and(code=0)then
        begin
             case dxfversion of
                               1009:begin
                                         shared.HistoryOutStr(format(rsFileFormat,['DXF12 ('+s+')']));
                                         gotodxf(f, 0, dxfName_ENDSEC);
                                         addfromdxf12(f,'EOF',owner,loadmode,drawing);
                                    end;
                               1015:begin
                                         shared.HistoryOutStr(format(rsFileFormat,['DXF2000 ('+s+')']));
                                         addfromdxf2000(f,'EOF',owner,loadmode,drawing)
                                    end;
                               1018:begin
                                         shared.HistoryOutStr(format(rsFileFormat,['DXF2004 ('+s+')']));
                                         addfromdxf2000(f,'EOF',owner,loadmode,drawing)
                                    end;
                               1021:begin
                                         shared.HistoryOutStr(format(rsFileFormat,['DXF2007 ('+s+')']));
                                         addfromdxf2000(f,'EOF',owner,loadmode,drawing)
                                    end;
                               1024:begin
                                         shared.HistoryOutStr(format(rsFileFormat,['DXF2010 ('+s+')']));
                                         addfromdxf2000(f,'EOF',owner,loadmode,drawing)
                                    end;
                               else
                                       begin
                                            ShowError(rsUnknownFileFormat+' $ACADVER='+s);
                                       end;


             end;
        end
           else ShowError(rsUnknownFileFormat+' $ACADVER='+s);
        (*
        if s = 'AC1009' then
        begin
          shared.HistoryOutStr(format(rsFileFormat,['DXF12']));
          //shared.HistoryOutStr('DXF12 fileformat;');
          //programlog.logout('DXF12 fileformat;',lp_OldPos);
          gotodxf(f, 0, dxfName_ENDSEC);
          addfromdxf12(f,'EOF',owner,loadmode);
        end
        else if s = 'AC1015' then
        begin
          shared.HistoryOutStr(format(rsFileFormat,['DXF2000']));
          //gotodxf(f, 0, dxfName_ENDSEC);
          //readvariables(f);
          addfromdxf2000(f,'EOF',owner,loadmode);
        end
        else if s = 'AC1018' then
        begin
          shared.HistoryOutStr(format(rsFileFormat,['DXF2004']));
          addfromdxf2000(f,'EOF',owner,loadmode);
        end
        else
        begin
             ShowError(rsUnknownFileFormat+' $ACADVER='+s);
             //ShowError('Uncnown fileformat; $ACADVER='+s);
             //programlog.logoutstr('ERROR: Uncnown fileformat; $ACADVER='+s,lp_OldPos);
        end;*)
      end;
    end;
  end;
  if assigned(EndLongProcessProc)then
    EndLongProcessProc;
  owner^.calcbb;
  GDBFreeMem(GDBPointer(phandlearray));
  end
     else
         shared.ShowError('IODXF.ADDFromDXF: Не могу открыть файл: '+name);
  f.done;
  programlog.logoutstr('end; {AddFromDXF}',lp_DecPos);
end;
procedure saveentitiesdxf2000(pva: PGDBObjEntityOpenArray; var outhandle:{GDBInteger}GDBOpenArrayOfByte; var handle: TDWGHandle;const drawing:TSimpleDrawing);
var
//  i:GDBInteger;
  pv:pgdbobjEntity;
  ir:itrec;
begin

     pv:=pva^.beginiterate(ir);
     if pv<>nil then
     repeat
          if assigned(ProcessLongProcessProc)then
                                                 ProcessLongProcessProc(ir.itc);
          pv^.DXFOut(handle, outhandle,drawing);
     pv:=pva^.iterate(ir);
     until pv=nil;
end;

procedure savedxf2000(name: GDBString; var drawing:TSimpleDrawing);
var
  templatefile: GDBOpenArrayOfByte;
  outstream: {GDBInteger}GDBOpenArrayOfByte;
  groups, values, ucvalues: GDBString;
  groupi, valuei, intable,attr: GDBInteger;
  temphandle,temphandle2,temphandle3,temphandle4,handle,lasthandle,vporttablehandle,plottablefansdle,dimtablehandle,i{,cod}: TDWGHandle;
  phandlea: pdxfhandlerecopenarray;
  inlayertable, inblocksec, inblocktable, inlttypetable, indimstyletable: GDBBoolean;
  handlepos:integer;
  ignoredsource:boolean;
  instyletable:boolean;
  invporttable:boolean;
  olddwg:{PTDrawing}PTSimpleDrawing;
  pltp:PGDBLtypeProp;
  plp:PGDBLayerProp;
  pdsp:PGDBDimStyle;
  ir,ir2,ir3,ir4,ir5:itrec;
  TDI:PTDashInfo;
  PStroke:PGDBDouble;
  PSP:PShapeProp;
  PTP:PTextProp;
  p:pointer;
  {$IFNDEF DELPHI}
  Handle2pointer:mappDWGHi;
  HandleIterator:mappDWGHi.TIterator;
  {$ENDIF}
  //DWGHandle:TDWGHandle;
  laststrokewrited:boolean;
procedure GetOrCreateHandle(const PDWGObject:pointer; var handle:TDWGHandle; out temphandle:TDWGHandle);
begin
    {$IFNDEF DELPHI}
    HandleIterator:=Handle2pointer.Find(PDWGObject);
    if  HandleIterator=nil then
                               begin
                                    Handle2pointer.Insert(PDWGObject,handle);
                                    temphandle:=handle;
                                    inc(handle);
                               end
                           else
                               begin
                                    temphandle:=HandleIterator.GetValue;
                                    HandleIterator.Destroy;
                               end;
   {$ENDIF}
end;
procedure GetHandle(const PDWGObject:pointer; out temphandle:TDWGHandle);
begin
    {$IFNDEF DELPHI}
    HandleIterator:=Handle2pointer.Find(PDWGObject);
    if  HandleIterator=nil then
                               temphandle:=0
                           else
                               begin
                                    temphandle:=HandleIterator.GetValue;
                                    HandleIterator.Destroy;
                               end;
   {$ENDIF}
end;



begin
  {$IFNDEF DELPHI}
  Handle2pointer:=mappDWGHi.Create;
  {$ENDIF}
  DecimalSeparator := '.';
  //standartstylehandle:=0;
  olddwg:=nil;//@drawing;
  if @SetCurrentDWGProc<>nil
                            then olddwg:=SetCurrentDWGProc(@drawing);
  //gdb.SetCurrentDWG(pdrawing);
  //--------------------------outstream := FileCreate(name);
  outstream.init({$IFDEF DEBUGBUILD}'{51453949-893A-49C2-9588-42B25346D071}',{$ENDIF}10*1024*1024);
  //--------------------------if outstream>0 then
  begin
    if assigned(StartLongProcessProc)then
  StartLongProcessProc({p}drawing.pObjRoot^.ObjArray.Count,'Save DXF file');
  phandlea := dxfhandlearraycreate(10000);
  pushhandle(phandlea,0,0);
  templatefile.InitFromFile(sysparam.programpath + 'components/empty.dxf');
  handle := $2;
  inlayertable := false;
  inblocksec := false;
  inblocktable := false;
  instyletable := false;
  ignoredsource:=false;
  invporttable:=false;
  inlttypetable:=false;
  indimstyletable:=false;
  while templatefile.notEOF do
  begin
    if  (templatefile.count-templatefile.ReadPos)<10
    then
        handle:=handle;
    groups := templatefile.readGDBString;
    values := templatefile.readGDBString;
    ucvalues:=uppercase(values);
    groupi := strtoint(groups);
    if (groupi = 9) and (values = '$HANDSEED') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      //WriteString_EOL(outstream, groups);
      outstream.TXTAddGDBStringEOL('$HANDSEED');
      //WriteString_EOL(outstream, '$HANDSEED');
      outstream.TXTAddGDBStringEOL('5');
      //WriteString_EOL(outstream, '5');
      handlepos:=outstream.Count;
      //handlepos:=FileSeek(outstream,0,1);
      outstream.TXTAddGDBStringEOL('FUCK OFF!');
      //WriteString_EOL(outstream, 'FUCK OFF');
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
      handle := strtoint('$' + values);
    end
else if (groupi = 9) and (ucvalues = '$CLAYER') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      outstream.TXTAddGDBStringEOL('$CLAYER');
      outstream.TXTAddGDBStringEOL('8');
      outstream.TXTAddGDBStringEOL(drawing.LayerTable.GetCurrentLayer^.Name);
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
    end
else if (groupi = 9) and (ucvalues = '$CELTYPE') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      outstream.TXTAddGDBStringEOL('$CELTYPE');
      outstream.TXTAddGDBStringEOL('6');
      outstream.TXTAddGDBStringEOL(drawing.LTypeStyleTable.GetCurrentLType^.Name);
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
    end
else if (groupi = 9) and (ucvalues = '$TEXTSTYLE') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      outstream.TXTAddGDBStringEOL('$TEXTSTYLE');
      outstream.TXTAddGDBStringEOL('7');
      outstream.TXTAddGDBStringEOL(drawing.TextStyleTable.GetCurrentTextStyle^.Name);
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
    end
else if (groupi = 9) and (ucvalues = '$CELWEIGHT') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      outstream.TXTAddGDBStringEOL('$CELWEIGHT');
      outstream.TXTAddGDBStringEOL('370');
      if assigned(sysvar.DWG.DWG_CLinew) then
                                             outstream.TXTAddGDBStringEOL(inttostr(sysvar.DWG.DWG_CLinew^))
                                         else
                                             outstream.TXTAddGDBStringEOL(inttostr(-1));
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
    end
else if (groupi = 9) and (ucvalues = '$LTSCALE') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      outstream.TXTAddGDBStringEOL('$LTSCALE');
      outstream.TXTAddGDBStringEOL('40');
      if assigned(sysvar.DWG.DWG_LTScale) then
                                             outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_LTScale^))
                                         else
                                             outstream.TXTAddGDBStringEOL(floattostr(1.0));
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
    end
else if (groupi = 9) and (ucvalues = '$CELTSCALE') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      outstream.TXTAddGDBStringEOL('$CELTSCALE');
      outstream.TXTAddGDBStringEOL('40');
      if assigned(sysvar.DWG.DWG_CLTScale) then
                                             outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_CLTScale^))
                                         else
                                             outstream.TXTAddGDBStringEOL(floattostr(1.0));
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
    end
else if (groupi = 9) and (ucvalues = '$CECOLOR') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      outstream.TXTAddGDBStringEOL('$CECOLOR');
      outstream.TXTAddGDBStringEOL('62');
      if assigned(sysvar.DWG.DWG_CColor) then
                                             outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_CColor^))
                                         else
                                             outstream.TXTAddGDBStringEOL(floattostr(256));
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
    end
else if (groupi = 9) and (ucvalues = '$LWDISPLAY') then
    begin
      outstream.TXTAddGDBStringEOL(groups);
      outstream.TXTAddGDBStringEOL('$LWDISPLAY');
      outstream.TXTAddGDBStringEOL('290');
      if assigned(sysvar.DWG.DWG_DrawMode) then
                                               begin
                                                    if sysvar.DWG.DWG_DrawMode^ then
                                                                                    outstream.TXTAddGDBStringEOL(inttostr(1))
                                                                                else
                                                                                    outstream.TXTAddGDBStringEOL(inttostr(0));
                                               end
                                           else
                                               outstream.TXTAddGDBStringEOL(inttostr(0));
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
    end
    else
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
        intable := {}getnevhandle(phandlea, valuei){}{valuei};
        if {}intable <>-1{}{true} then
        begin
          if not ignoredsource then
          begin
          outstream.TXTAddGDBStringEOL(groups);
          outstream.TXTAddGDBStringEOL(inttohex(intable, 0));
          end;
          lasthandle:=intable;
        end
        else
        begin
          pushhandle(phandlea, valuei, handle);
          if not ignoredsource then
          begin
          outstream.TXTAddGDBStringEOL(groups);
          outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
          end;
          lasthandle:=handle;
          inc(handle);
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
          outstream.TXTAddGDBStringEOL(groups);
          //WriteString_EOL(outstream, groups);
          outstream.TXTAddGDBStringEOL(values);
          //WriteString_EOL(outstream, values);
          //historyoutstr('Entities start here_______________________________________________________');
          saveentitiesdxf2000(@{p}drawing.pObjRoot^.ObjArray, outstream, handle,drawing);
        end
        else
          if (groupi = 2) and (values = 'BLOCKS') then
          begin
            outstream.TXTAddGDBStringEOL(groups);
            outstream.TXTAddGDBStringEOL(values);
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
                outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
                outstream.TXTAddGDBStringEOL('BLOCK');

                //GetOrCreateHandle(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),handle,temphandle);
                //
                outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
                outstream.TXTAddGDBStringEOL(inttohex(handle{temphandle}, 0));
                inc(handle);
                outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                outstream.TXTAddGDBStringEOL(dxfName_AcDbEntity);
                outstream.TXTAddGDBStringEOL(dxfGroupCode(8));
                outstream.TXTAddGDBStringEOL('0');
                outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                outstream.TXTAddGDBStringEOL('AcDbBlockBegin');
                outstream.TXTAddGDBStringEOL(dxfGroupCode(2));
                outstream.TXTAddGDBStringEOL(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].name);
                outstream.TXTAddGDBStringEOL(dxfGroupCode(70));
                outstream.TXTAddGDBStringEOL('2');
                outstream.TXTAddGDBStringEOL(dxfGroupCode(10));
                outstream.TXTAddGDBStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.x));
                outstream.TXTAddGDBStringEOL(dxfGroupCode(20));
                outstream.TXTAddGDBStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.y));
                outstream.TXTAddGDBStringEOL(dxfGroupCode(30));
                outstream.TXTAddGDBStringEOL(floattostr(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].base.z));
                outstream.TXTAddGDBStringEOL(dxfGroupCode(3));
                outstream.TXTAddGDBStringEOL(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].name);
                outstream.TXTAddGDBStringEOL(dxfGroupCode(1));
                outstream.TXTAddGDBStringEOL('');

                saveentitiesdxf2000(@PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].ObjArray, outstream, handle,drawing);

                outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
                outstream.TXTAddGDBStringEOL('ENDBLK');
                outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
                outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
                inc(handle);
                outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                outstream.TXTAddGDBStringEOL(dxfName_AcDbEntity);
                outstream.TXTAddGDBStringEOL(dxfGroupCode(8));
                outstream.TXTAddGDBStringEOL('0');
                outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                outstream.TXTAddGDBStringEOL('AcDbBlockEnd');

                //PBlockdefArray(gdb^.BlockDefArray.parray)^[i].SaveToDXFPostProcess(outstream); asdasd

              end;

              outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
              outstream.TXTAddGDBStringEOL(dxfName_ENDSEC);


              inblocksec := false;
            end
            else if (invporttable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
            begin
               invporttable:=false;
               ignoredsource:=false;

               outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
               outstream.TXTAddGDBStringEOL(inttohex(handle,0));
               vporttablehandle:=handle;
               inc(handle);

               outstream.TXTAddGDBStringEOL(dxfGroupCode(330));
               outstream.TXTAddGDBStringEOL('0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
               outstream.TXTAddGDBStringEOL('AcDbSymbolTable');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(70));
               outstream.TXTAddGDBStringEOL('1');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
               outstream.TXTAddGDBStringEOL('VPORT');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
               outstream.TXTAddGDBStringEOL(inttohex(handle,0));
               inc(handle);
               outstream.TXTAddGDBStringEOL(dxfGroupCode(330));
               outstream.TXTAddGDBStringEOL(inttohex(vporttablehandle,0));

               outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
               outstream.TXTAddGDBStringEOL('AcDbSymbolTableRecord');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
               outstream.TXTAddGDBStringEOL('AcDbViewportTableRecord');

               outstream.TXTAddGDBStringEOL(dxfGroupCode(2));
               outstream.TXTAddGDBStringEOL('*Active');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(70));
               outstream.TXTAddGDBStringEOL('0');

               outstream.TXTAddGDBStringEOL(dxfGroupCode(10));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(20));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(11));
               outstream.TXTAddGDBStringEOL('1.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(21));
               outstream.TXTAddGDBStringEOL('1.0');

               if drawing.OGLwindow1<>nil then
                                                        begin
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(12));
                                                             outstream.TXTAddGDBStringEOL(floattostr(drawing.OGLwindow1.param.CPoint.x));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(22));
                                                             outstream.TXTAddGDBStringEOL(floattostr(drawing.OGLwindow1.param.CPoint.y));
                                                        end
                                                    else
                                                        begin
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(12));
                                                             outstream.TXTAddGDBStringEOL('0');
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(22));
                                                             outstream.TXTAddGDBStringEOL('0');
                                                        end;
               outstream.TXTAddGDBStringEOL(dxfGroupCode(13));
               outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_Snap^.Base.x));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(23));
               outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_Snap^.Base.y));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(14));
               outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_Snap^.Spacing.x));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(24));
               outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_Snap^.Spacing.y));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(15));
               outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_GridSpacing^.x));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(25));
               outstream.TXTAddGDBStringEOL(floattostr(sysvar.DWG.DWG_GridSpacing^.y));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(16));
               outstream.TXTAddGDBStringEOL(floattostr(-drawing.pcamera^.prop.look.x));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(26));
               outstream.TXTAddGDBStringEOL(floattostr(-drawing.pcamera^.prop.look.y));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(36));
               outstream.TXTAddGDBStringEOL(floattostr(-drawing.pcamera^.prop.look.z));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(17));
               outstream.TXTAddGDBStringEOL(floattostr(0));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(27));
               outstream.TXTAddGDBStringEOL(floattostr(0));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(37));
               outstream.TXTAddGDBStringEOL(floattostr(0));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(40));
               if drawing.OGLwindow1<>nil then
                                                        outstream.TXTAddGDBStringEOL(floattostr(drawing.OGLwindow1.param.ViewHeight))
                                                    else
                                                        outstream.TXTAddGDBStringEOL(inttostr(500));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(41));
               if drawing.OGLwindow1<>nil then
                                                        outstream.TXTAddGDBStringEOL(floattostr(drawing.OGLwindow1.ClientWidth/drawing.OGLwindow1.ClientHeight))
                                                    else
                                                        outstream.TXTAddGDBStringEOL(inttostr(1));
               outstream.TXTAddGDBStringEOL(dxfGroupCode(42));
               outstream.TXTAddGDBStringEOL('50.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(43));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(44));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(50));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(51));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(71));
               outstream.TXTAddGDBStringEOL('0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(72));
               outstream.TXTAddGDBStringEOL('1000');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(73));
               outstream.TXTAddGDBStringEOL('1');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(74));
               outstream.TXTAddGDBStringEOL('3');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(75));
               if sysvar.DWG.DWG_SnapGrid<>nil then
                                                   begin
                                                        if sysvar.DWG.DWG_SnapGrid^ then
                                                                                        outstream.TXTAddGDBStringEOL('1')
                                                                                    else
                                                                                        outstream.TXTAddGDBStringEOL('0');
                                                   end
                                               else
                                                   outstream.TXTAddGDBStringEOL('0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(76));
               if sysvar.DWG.DWG_DrawGrid<>nil then
                                                     begin
                                                          if sysvar.DWG.DWG_DrawGrid^ then
                                                                                          outstream.TXTAddGDBStringEOL('1')
                                                                                      else
                                                                                          outstream.TXTAddGDBStringEOL('0');
                                                     end
                                                 else
                                                     outstream.TXTAddGDBStringEOL('0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(77));
               outstream.TXTAddGDBStringEOL('0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(78));
               outstream.TXTAddGDBStringEOL('0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(281));
               outstream.TXTAddGDBStringEOL('0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(65));
               outstream.TXTAddGDBStringEOL('1');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(110));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(120));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(130));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(111));
               outstream.TXTAddGDBStringEOL('1.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(121));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(131));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(112));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(122));
               outstream.TXTAddGDBStringEOL('1.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(132));
               outstream.TXTAddGDBStringEOL('0.0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(79));
               outstream.TXTAddGDBStringEOL('0');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(146));
               outstream.TXTAddGDBStringEOL('0.0');
               //outstream.TXTAddGDBStringEOL(dxfGroupCode(1001));
               //outstream.TXTAddGDBStringEOL('ACAD_NAV_VCDISPLAY');
               //outstream.TXTAddGDBStringEOL(dxfGroupCode(1070));
               //outstream.TXTAddGDBStringEOL('3');
               outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
               outstream.TXTAddGDBStringEOL('ENDTAB');

            end
            else if (inblocktable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
            begin
              inblocktable := false;
              if {p}drawing.BlockDefArray.count>0 then

              for i := 0 to {p}drawing.BlockDefArray.count - 1 do
              begin
                outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
                outstream.TXTAddGDBStringEOL(dxfName_BLOCK_RECORD);

                GetOrCreateHandle(@(PBlockdefArray(drawing.BlockDefArray.parray)^[i]),handle,temphandle);

                outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
                outstream.TXTAddGDBStringEOL(inttohex({handle}temphandle, 0));
                //inc(handle);
                outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                outstream.TXTAddGDBStringEOL(dxfName_AcDbSymbolTableRecord);
                outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                outstream.TXTAddGDBStringEOL('AcDbBlockTableRecord');
                outstream.TXTAddGDBStringEOL(dxfGroupCode(2));
                outstream.TXTAddGDBStringEOL(PBlockdefArray({p}drawing.BlockDefArray.parray)^[i].name);

              end;
              outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
              outstream.TXTAddGDBStringEOL(dxfName_ENDTAB);
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
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
                    outstream.TXTAddGDBStringEOL(dxfName_Layer);
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
                    outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
                    inc(handle);
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                    outstream.TXTAddGDBStringEOL(dxfName_AcDbSymbolTableRecord);
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                    outstream.TXTAddGDBStringEOL('AcDbLayerTableRecord');
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(2));
                    outstream.TXTAddGDBStringEOL(plp^.name);
                    attr:=0;
                    if plp^._lock then
                                     attr:=attr + 4;
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(70));
                    outstream.TXTAddGDBStringEOL(inttostr(attr));
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(62));
                    if plp^._on
                     then
                         outstream.TXTAddGDBStringEOL(inttostr(plp^.color))
                     else
                         outstream.TXTAddGDBStringEOL(inttostr(-plp^.color));
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(6));
                    if assigned(plp^.LT) then
                                             outstream.TXTAddGDBStringEOL(PGDBLtypeProp(plp^.LT)^.Name)
                                         else
                                             outstream.TXTAddGDBStringEOL('Continuous');
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(290));
                    if plp^._print then
                    //if uppercase(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[pltp].name) <> 'DEFPOINTS' then
                      outstream.TXTAddGDBStringEOL('1')
                    else
                      outstream.TXTAddGDBStringEOL('0');
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(370));
                    outstream.TXTAddGDBStringEOL(inttostr(plp^.lineweight));
                    //WriteString_EOL(outstream, '-3');
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(390));
                    outstream.TXTAddGDBStringEOL(inttohex(plottablefansdle,0));

                    if plp^.desk<>''then
                    begin
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(1001));
                         outstream.TXTAddGDBStringEOL('AcAecLayerStandard');
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(1000));
                         outstream.TXTAddGDBStringEOL('');
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(1000));
                         outstream.TXTAddGDBStringEOL(plp^.desk);
                    end;
                  end;
                end;
                plp:=drawing.layertable.iterate(ir);
                until plp=nil;

                outstream.TXTAddGDBStringEOL(groups);
                outstream.TXTAddGDBStringEOL(values);
              end


            else
              if (inlttypetable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                   inlttypetable := false;
                   ignoredsource:=false;
                   temphandle:=handle-1;
                   pltp:=drawing.LTypeStyleTable.beginiterate(ir);
                   if pltp<>nil then
                   repeat
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
                         outstream.TXTAddGDBStringEOL(dxfName_LTYPE);
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
                         outstream.TXTAddGDBStringEOL(inttohex(handle, 0));
                         inc(handle);
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(330));
                         outstream.TXTAddGDBStringEOL(inttohex(temphandle, 0));
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                         outstream.TXTAddGDBStringEOL(dxfName_AcDbSymbolTableRecord);
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                         outstream.TXTAddGDBStringEOL('AcDbLinetypeTableRecord');
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(2));
                         outstream.TXTAddGDBStringEOL(pltp^.Name);
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(70));
                         outstream.TXTAddGDBStringEOL('0');
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(3));
                         outstream.TXTAddGDBStringEOL(pltp^.desk);
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(72));
                         outstream.TXTAddGDBStringEOL('65');
                         i:=pltp^.strokesarray.GetRealCount;
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(73));
                         outstream.TXTAddGDBStringEOL(inttostr(i));
                         outstream.TXTAddGDBStringEOL(dxfGroupCode(40));
                         outstream.TXTAddGDBStringEOL(floattostr(pltp^.len));
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
                                                                                     outstream.TXTAddGDBStringEOL(dxfGroupCode(74));
                                                                                     outstream.TXTAddGDBStringEOL('0');
                                                                                     end;
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(49));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PStroke^));
                                                             {outstream.TXTAddGDBStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddGDBStringEOL('0');}
                                                             PStroke:=pltp^.strokesarray.iterate(ir3);
                                                             laststrokewrited:=true;
                                                        end;
                                               TDIShape:begin
                                                             laststrokewrited:=false;
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddGDBStringEOL('4');
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(75));
                                                             outstream.TXTAddGDBStringEOL(inttostr(PSP^.Psymbol^.number));

                                                             GetOrCreateHandle(PSP^.param.PStyle,handle,temphandle);

                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(340));
                                                             outstream.TXTAddGDBStringEOL(inttohex(temphandle,0));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(46));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PSP^.param.Height));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(50));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PSP^.param.Angle));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(44));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PSP^.param.X));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(45));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PSP^.param.Y));
                                                             PSP:=pltp^.shapearray.iterate(ir4);
                                                        end;
                                               TDIText:begin
                                                             laststrokewrited:=false;
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(74));
                                                             outstream.TXTAddGDBStringEOL('2');
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(75));
                                                             outstream.TXTAddGDBStringEOL('0');

                                                             GetOrCreateHandle(PTP^.param.PStyle,handle,temphandle);

                                                             {else
                                                                 temphandle:=standartstylehandle;}
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(340));
                                                             outstream.TXTAddGDBStringEOL(inttohex(temphandle,0));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(46));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PTP^.param.Height));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(50));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PTP^.param.Angle));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(44));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PTP^.param.X));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(45));
                                                             outstream.TXTAddGDBStringEOL(floattostr(PTP^.param.Y));
                                                             outstream.TXTAddGDBStringEOL(dxfGroupCode(9));
                                                             outstream.TXTAddGDBStringEOL(PTP^.TEXT);
                                                             PTP:=pltp^.textarray.iterate(ir4);
                                                        end;
                                    end;
                                    TDI:=pltp^.dasharray.iterate(ir2);
                              until {PStroke}TDI=nil;
                              if laststrokewrited then
                                                       begin
                                                       outstream.TXTAddGDBStringEOL(dxfGroupCode(74));
                                                       outstream.TXTAddGDBStringEOL('0');
                                                       end;

                         end;


                         pltp:=drawing.LTypeStyleTable.iterate(ir);
                   until pltp=nil;
                   outstream.TXTAddGDBStringEOL(groups);
                   outstream.TXTAddGDBStringEOL(values);
              end
            else
              if (indimstyletable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                //TODO надо писать заголовок таблицы руками, а не из шаблона DXF, т.к. там есть перечень стилей который проебывается
                indimstyletable:=false;
                ignoredsource:=false;
                temphandle3:=handle-1;
                temphandle4:=handle-3;
                //дальше идут стили
                pdsp:=drawing.DimStyleTable.beginiterate(ir);
                if pdsp<>nil then
                repeat
                      outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
                      outstream.TXTAddGDBStringEOL('DIMSTYLE');
                      outstream.TXTAddGDBStringEOL(dxfGroupCode(105));
                      outstream.TXTAddGDBStringEOL(inttohex({temphandle3}handle, 0));
                      inc(handle);

                      outstream.TXTAddGDBStringEOL(dxfGroupCode(330));
                      outstream.TXTAddGDBStringEOL(inttohex({temphandle4}{temphandle3}dimtablehandle, 0));

                      outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                      outstream.TXTAddGDBStringEOL('AcDbSymbolTableRecord');
                      outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                      outstream.TXTAddGDBStringEOL('AcDbDimStyleTableRecord');
                      outstream.TXTAddGDBStringEOL(dxfGroupCode(2));
                      outstream.TXTAddGDBStringEOL(pdsp^.Name);
                      outstream.TXTAddGDBStringEOL(dxfGroupCode(70));
                      outstream.TXTAddGDBStringEOL('0');

                      //тут сами настройки
                      outstream.TXTAddGDBStringEOL(dxfGroupCode(44));
                      outstream.TXTAddGDBStringEOL(floattostr(pdsp^.Lines.DIMEXE));
                      outstream.TXTAddGDBStringEOL(dxfGroupCode(42));
                      outstream.TXTAddGDBStringEOL(floattostr(pdsp^.Lines.DIMEXO));
                      outstream.TXTAddGDBStringEOL(dxfGroupCode(46));
                      outstream.TXTAddGDBStringEOL(floattostr(pdsp^.Lines.DIMDLE));

                      outstream.TXTAddGDBStringEOL(dxfGroupCode(41));
                      outstream.TXTAddGDBStringEOL(floattostr(pdsp^.Arrows.DIMASZ));

                      outstream.TXTAddGDBStringEOL(dxfGroupCode(173));
                      if pdsp^.Arrows.DIMBLK1<>pdsp^.Arrows.DIMBLK2 then
                                                                        begin
                                                                             outstream.TXTAddGDBStringEOL('1');
                                                                         end
                                           else
                                               begin
                                                    outstream.TXTAddGDBStringEOL('0');
                                               end;

                      if pdsp^.Arrows.DIMLDRBLK<>TSClosedFilled then
                      begin
                           GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(-1).name),handle,temphandle);
                           outstream.TXTAddGDBStringEOL(dxfGroupCode(341));
                           outstream.TXTAddGDBStringEOL(inttohex(temphandle,0));
                      end;


                      if pdsp^.Arrows.DIMBLK1<>pdsp^.Arrows.DIMBLK2 then
                                                                        begin
                                                                             if pdsp^.Arrows.DIMBLK1<>TSClosedFilled then
                                                                             begin
                                                                                   GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),handle,temphandle);
                                                                                   if temphandle<>0 then
                                                                                   begin
                                                                                         outstream.TXTAddGDBStringEOL(dxfGroupCode(343));
                                                                                         outstream.TXTAddGDBStringEOL(inttohex(temphandle,0));
                                                                                   end;
                                                                             end;
                                                                             if pdsp^.Arrows.DIMBLK2<>TSClosedFilled then
                                                                             begin
                                                                                   GetOrCreateHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(1).name),handle,temphandle);
                                                                                   if temphandle<>0 then
                                                                                   begin
                                                                                         outstream.TXTAddGDBStringEOL(dxfGroupCode(344));
                                                                                         outstream.TXTAddGDBStringEOL(inttohex(temphandle,0));
                                                                                   end;
                                                                             end;
                                                                         end
                                           else
                                               begin
                                                    if pdsp^.Arrows.DIMBLK1<>TSClosedFilled then
                                                    begin
                                                    GetHandle(drawing.BlockDefArray.getblockdef(pdsp^.GetDimBlockParam(0).name),temphandle);
                                                    if temphandle<>0 then
                                                    begin
                                                    outstream.TXTAddGDBStringEOL(dxfGroupCode(342));
                                                    outstream.TXTAddGDBStringEOL(inttohex(temphandle,0));
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
                       outstream.TXTAddGDBStringEOL(dxfGroupCode(140));
                       outstream.TXTAddGDBStringEOL(floattostr(pdsp^.Text.DIMTXT));

                       outstream.TXTAddGDBStringEOL(dxfGroupCode(73));
                       if pdsp^.Text.DIMTIH then
                                                outstream.TXTAddGDBStringEOL('1')
                                            else
                                                outstream.TXTAddGDBStringEOL('0');
                       outstream.TXTAddGDBStringEOL(dxfGroupCode(74));
                       if pdsp^.Text.DIMTOH then
                                                outstream.TXTAddGDBStringEOL('1')
                                            else
                                                outstream.TXTAddGDBStringEOL('0');
                       outstream.TXTAddGDBStringEOL(dxfGroupCode(147));
                       outstream.TXTAddGDBStringEOL(floattostr(pdsp^.Text.DIMGAP));

                       outstream.TXTAddGDBStringEOL(dxfGroupCode(77));
                       case pdsp^.Text.DIMTAD of
                                  DTVPCenters:outstream.TXTAddGDBStringEOL('0');
                                    DTVPAbove:outstream.TXTAddGDBStringEOL('1');
                                  DTVPOutside:outstream.TXTAddGDBStringEOL('2');
                                      DTVPJIS:outstream.TXTAddGDBStringEOL('3');
                                   DTVPBellov:outstream.TXTAddGDBStringEOL('4');
                       end;{case}

                       outstream.TXTAddGDBStringEOL(dxfGroupCode(144));
                       outstream.TXTAddGDBStringEOL(floattostr(pdsp^.Units.DIMLFAC));
                       outstream.TXTAddGDBStringEOL(dxfGroupCode(271));
                       outstream.TXTAddGDBStringEOL(inttostr(pdsp^.Units.DIMDEC));
                       outstream.TXTAddGDBStringEOL(dxfGroupCode(45));
                       outstream.TXTAddGDBStringEOL(floattostr(pdsp^.Units.DIMRND));

                       outstream.TXTAddGDBStringEOL(dxfGroupCode(277));
                       case pdsp^.Units.DIMLUNIT of
                                   DUScientific:outstream.TXTAddGDBStringEOL('1');
                                      DUDecimal:outstream.TXTAddGDBStringEOL('2');
                                  DUEngineering:outstream.TXTAddGDBStringEOL('3');
                                DUArchitectural:outstream.TXTAddGDBStringEOL('4');
                                   DUFractional:outstream.TXTAddGDBStringEOL('5');
                                       DUSystem:outstream.TXTAddGDBStringEOL('6');
                       end;{case}
                       outstream.TXTAddGDBStringEOL(dxfGroupCode(278));
                       case pdsp^.Units.DIMDSEP of
                                   DDSDot:outstream.TXTAddGDBStringEOL('46');
                                 DDSComma:outstream.TXTAddGDBStringEOL('44');
                                 DDSSpace:outstream.TXTAddGDBStringEOL('32');
                       end;{case}

                      outstream.TXTAddGDBStringEOL(dxfGroupCode(340));
                      p:=drawing.TextStyleTable.FindStyle('Standard',false);

                      GetOrCreateHandle(p,handle,temphandle);

                      outstream.TXTAddGDBStringEOL(inttohex(temphandle, 0));


                      pdsp:=drawing.DimStyleTable.iterate(ir);
                until pdsp=nil;
                outstream.TXTAddGDBStringEOL(groups);
                outstream.TXTAddGDBStringEOL(values);
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
            else
              if (instyletable) and ((groupi = 0) and (values = dxfName_ENDTAB)) then
              begin
                instyletable := false;
                ignoredsource:=false;
                temphandle2:=handle-2;
                if drawing.TextStyleTable.count>0 then
                for i := 0 to drawing.TextStyleTable.count - 1 do
                begin
                  //if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name <> '0' then
                  if PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.UsedInLTYPE then
                  begin
                  outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
                  outstream.TXTAddGDBStringEOL(dxfName_Style);
                  p:=drawing.TextStyleTable.getelement(i);

                  GetOrCreateHandle(drawing.TextStyleTable.getelement(i),handle,temphandle);

                  outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
                  outstream.TXTAddGDBStringEOL(inttohex({handle}temphandle, 0));
                  inc(handle);
                  outstream.TXTAddGDBStringEOL(dxfGroupCode(330));
                  outstream.TXTAddGDBStringEOL(inttohex(temphandle2, 0));
                  outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                  outstream.TXTAddGDBStringEOL(dxfName_AcDbSymbolTableRecord);
                  outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                  outstream.TXTAddGDBStringEOL('AcDbTextStyleTableRecord');
                  outstream.TXTAddGDBStringEOL(dxfGroupCode(2));
                  outstream.TXTAddGDBStringEOL('');
                  outstream.TXTAddGDBStringEOL(dxfGroupCode(70));
                  outstream.TXTAddGDBStringEOL('1');

                  outstream.TXTAddGDBStringEOL(dxfGroupCode(40));
                  outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.prop.size));

                  outstream.TXTAddGDBStringEOL(dxfGroupCode(41));
                  outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.prop.wfactor));

                  outstream.TXTAddGDBStringEOL(dxfGroupCode(50));
                  outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.prop.oblique));

                  outstream.TXTAddGDBStringEOL(dxfGroupCode(71));
                  outstream.TXTAddGDBStringEOL('0');

                  outstream.TXTAddGDBStringEOL(dxfGroupCode(42));
                  outstream.TXTAddGDBStringEOL('2.5');

                  outstream.TXTAddGDBStringEOL(dxfGroupCode(3));
                  outstream.TXTAddGDBStringEOL(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.dxfname);

                  outstream.TXTAddGDBStringEOL(dxfGroupCode(4));
                  outstream.TXTAddGDBStringEOL('');

                  end
                  else
                  begin
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(0));
                    outstream.TXTAddGDBStringEOL(dxfName_Style);
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(5));
                    //if uppercase(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.name)<>TSNStandardStyleName then
                    begin
                    p:=drawing.TextStyleTable.getelement(i);

                    GetOrCreateHandle(p,handle,temphandle);

                    outstream.TXTAddGDBStringEOL(inttohex(temphandle, 0));
                    //inc(handle);
                    end;
                    {else
                        outstream.TXTAddGDBStringEOL(inttohex(standartstylehandle, 0));}
                  outstream.TXTAddGDBStringEOL(dxfGroupCode(330));
                  outstream.TXTAddGDBStringEOL(inttohex(temphandle2, 0));
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                    outstream.TXTAddGDBStringEOL(dxfName_AcDbSymbolTableRecord);
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(100));
                    outstream.TXTAddGDBStringEOL('AcDbTextStyleTableRecord');
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(2));
                    outstream.TXTAddGDBStringEOL(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.name);
                    outstream.TXTAddGDBStringEOL(dxfGroupCode(70));
                    outstream.TXTAddGDBStringEOL('0');

                    outstream.TXTAddGDBStringEOL(dxfGroupCode(40));
                    outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.prop.size));

                    outstream.TXTAddGDBStringEOL(dxfGroupCode(41));
                    outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.prop.wfactor));

                    outstream.TXTAddGDBStringEOL(dxfGroupCode(50));
                    outstream.TXTAddGDBStringEOL(floattostr(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.prop.oblique));

                    outstream.TXTAddGDBStringEOL(dxfGroupCode(71));
                    outstream.TXTAddGDBStringEOL('0');

                    outstream.TXTAddGDBStringEOL(dxfGroupCode(42));
                    outstream.TXTAddGDBStringEOL('2.5');

                    outstream.TXTAddGDBStringEOL(dxfGroupCode(3));
                    outstream.TXTAddGDBStringEOL(PGDBTextStyle(drawing.TextStyleTable.getelement(i))^.dxfname);

                    outstream.TXTAddGDBStringEOL(dxfGroupCode(4));
                    outstream.TXTAddGDBStringEOL('');

                  end;
                end;
                outstream.TXTAddGDBStringEOL(groups);
                outstream.TXTAddGDBStringEOL(values);
              end


              else
                if (groupi = 0) and (values = dxfName_TABLE) then
                begin
                  outstream.TXTAddGDBStringEOL(groups);
                  outstream.TXTAddGDBStringEOL(values);
                  groups := templatefile.readGDBString;
                  values := templatefile.readGDBString;
                  groupi := strtoint(groups);
                  outstream.TXTAddGDBStringEOL(groups);
                  outstream.TXTAddGDBStringEOL(values);
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
                  outstream.TXTAddGDBStringEOL(groups);
                  outstream.TXTAddGDBStringEOL(values);
                  end;
                  //val('$' + values, i, cod);
                end;
    //s := readspace(s);
  end;
  //templatefileclose;

  i:=outstream.Count;
  outstream.Count:=handlepos;
  outstream.TXTAddGDBStringEOL(inttohex(handle+$100000000,9){'100000013'});
  outstream.Count:=i;

  //-------------FileSeek(outstream,handlepos,0);
  //-------------WriteString_EOL(outstream,inttohex(handle+1,8));
  //-------------fileclose(outstream);


  GDBFreeMem(GDBPointer(phandlea));
  templatefile.done;

  if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(name)) then
                           begin
                                deletefile(name+'.bak');
                                renamefile(name,name+'.bak');
                           end;

  if outstream.SaveToFile(name)<=0 then
                                       shared.ShowError(format(rsUnableToWriteFile,[name]));
                                       //shared.ShowError('Не могу открыть для записи файл: '+name);
  if assigned(EndLongProcessProc)then
  EndLongProcessProc;

  end;
  outstream.done;
  if @SetCurrentDWGProc<>nil
                           then
                               if olddwg<>nil then
                                                  SetCurrentDWGProc(olddwg);
  {$IFNDEF DELPHI}Handle2pointer.Destroy;{$ENDIF}
  //gdb.SetCurrentDWG(olddwg);
end;
procedure SaveZCP(name: GDBString; {gdb: PGDBDescriptor}var drawing:TSimpleDrawing);
var
//  memsize:longint;
//  objcount:GDBInteger;
//  pmem,tmem:GDBPointer;
  outfile:GDBInteger;
  memorybuf:PGDBOpenArrayOfByte;
  //s:ZCPHeader;
  linkbyf:PGDBOpenArrayOfTObjLinkRecord;
//  test:gdbvertex;
  sub:integer;
begin
     memorybuf:=nil;
     linkbyf:=nil;
     //s:=NULZCPHeader;
     zcpmode:=zcptxt;
     sub:=0;
     sysunit^.TypeName2PTD('ZCPHeader')^.Serialize(@ZCPHead,SA_SAVED_TO_SHD,memorybuf,linkbyf,sub);

     PTZCPOffsetTable(memorybuf^.getelement(ZCPHeadOffsetTableOffset))^.GDB:=memorybuf^.Count;

     linkbyf^.SetGenMode(EnableGen);
     //sysunit.TypeName2PTD('GDBDescriptor')^.Serialize(gdb,SA_SAVED_TO_SHD,memorybuf,linkbyf); убратькомент!!!!

     PTZCPOffsetTable(memorybuf^.getelement(ZCPHeadOffsetTableOffset))^.GDBRT:=memorybuf^.Count;

     linkbyf^.SetGenMode(DisableGen);

     {test.x:=1;
     test.y:=2;
     test.z:=3;
     systype.TypeName2PTD('GDBvertex')^.Serialize(@test,SA_SAVED_TO_SHD,memorybuf,linkbyf);}

     linkbyf^.Minimize;
     //sysunit.TypeName2PTD('GDBOpenArrayOfTObjLinkRecord')^.Serialize(linkbyf,SA_SAVED_TO_SHD,memorybuf,linkbyf);убратькомент!!!!

     {systype.TypeName2PTD('ZCPHeader')^.DeSerialize(@s,SA_SAVED_TO_SHD,memorybuf);
     fillchar(gdb^,sizeof(GDBDescriptor),0);
     systype.TypeName2PTD('GDBDescriptor')^.DeSerialize(gdb,SA_SAVED_TO_SHD,memorybuf);}

     outfile:=FileCreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(name));
     FileWrite(outfile,memorybuf^.parray^,memorybuf^.Count);
     fileclose(outfile);
     outfile:=FileCreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(name+'remap'));
     FileWrite(outfile,linkbyf^.parray^,linkbyf^.Count*linkbyf^.Size);
     fileclose(outfile);
     memorybuf^.done;
     linkbyf^.done;
end;
procedure LoadZCP(name: GDBString; {gdb: PGDBDescriptor}var drawing:TSimpleDrawing);
//var
//  objcount:GDBInteger;
//  pmem,tmem:GDBPointer;
//  infile:GDBInteger;
//  head:ZCPheader;
  //memorybuf:GDBOpenArrayOfByte;
  //FileHeader:ZCPHeader;
//  test:gdbvertex;
  //linkbyf:PGDBOpenArrayOfTObjLinkRecord;
begin
     (*
     FileHeader:=NULZCPHeader;
     memorybuf.InitFromFile(name);
     sysunit.TypeName2PTD('ZCPHeader')^.DeSerialize(@FileHeader,SA_SAVED_TO_SHD,memorybuf,nil);
     HistoryOutStr('Loading file: '+name);
     HistoryOutStr('ZCad project file v'+inttostr(FileHeader.HiVersion)+'.'+inttostr(FileHeader.LoVersion));
     HistoryOutStr('File coment: '+FileHeader.Coment);
     memorybuf.Seek(FileHeader.OffsetTable.GDBRT);
     GDBGetMem({$IFDEF DEBUGBUILD}'{E975EEDE-66A9-4391-8E28-17537B7A2C9C}',{$ENDIF}pointer(linkbyf),sizeof(GDBOpenArrayOfTObjLinkRecord));
     sysunit.TypeName2PTD('GDBOpenArrayOfTObjLinkRecord')^.DeSerialize(linkbyf,SA_SAVED_TO_SHD,memorybuf,nil);
     memorybuf.Seek(FileHeader.OffsetTable.GDB);
     fillchar(gdb^,sizeof(GDBDescriptor),0);
     sysunit.TypeName2PTD('GDBDescriptor')^.DeSerialize(gdb,SA_SAVED_TO_SHD,memorybuf,linkbyf);
     gdb.GetCurrentDWG.SetFileName(name);
     gdb.GetCurrentROOT.correctobjects(nil,-1);
     //fillchar(FileHeader,sizeof(FileHeader),0);
     {systype.TypeName2PTD('GDBVertex')^.DeSerialize(@test,SA_SAVED_TO_SHD,memorybuf);}
     FileRead(infile,header,sizeof(shdblockheader));
     while header.blocktype<>shd_block_eof do
     begin
          case header.blocktype of
                                  shd_block_head:begin
                                                      FileRead(infile,head,sizeof(ZCPheader));
                                                 end;
                              shd_block_primitiv:begin
                                                      FileRead(infile,objcount,sizeof(objcount));
                                                      header.blocksize:=header.blocksize-sizeof(objcount);
                                                      GDBGetMem({$IFDEF DEBUGBUILD}'{01399BB7-5744-4DFE-97C3-00F5E501275C}',{$ENDIF}pmem,header.blocksize);
                                                      FileRead(infile,pmem^,header.blocksize);
                                                      tmem:=pmem;
                                                      //gdb.ObjRoot.ObjArray.LoadCompactMemSize2(tmem,objcount);
                                                      GDBFreeMem(pmem);
                                                 end;
                                            else begin
                                                      FileSeek(infile,header.blocksize,1)
                                                 end;
          end;
          FileRead(infile,header,sizeof(shdblockheader));
     end;
     fileclose(infile);*)
end;
{$IFNDEF DELPHI}
procedure Import(name: GDBString;var drawing:TSimpleDrawing);
var
  Vec: TvVectorialDocument;
  source:{TvVectorialPage}TvPage;
  CurEntity: TvEntity;
  i:integer;
  pobj:PGDBObjEntity;
  j{, k}: Integer;
  CurSegment: TPathSegment;
  Cur2DSegment: T2DSegment absolute CurSegment;
  PosX, PosY: Double;
begin
    Vec := TvVectorialDocument.Create;
  try
    Vec.ReadFromFile(name);
    source:=Vec.GetPage(0);
    for i := 0 to source.GetEntitiesCount - 1 do
    begin
      CurEntity := source.GetEntity(i);
      if CurEntity is TvCircle then
      begin
           pobj := CreateInitObjFree(GDBCircleID,nil);
           pgdbobjCircle(pobj)^.Radius:=TvCircle(CurEntity).Radius;
           pgdbobjCircle(pobj)^.Local.P_insert.x:=TvCircle(CurEntity).x;
           pgdbobjCircle(pobj)^.Local.P_insert.y:=TvCircle(CurEntity).y;
           drawing{gdb}.GetCurrentRoot^.AddMi(@pobj);
           PGDBObjEntity(pobj)^.BuildGeometry(drawing);
           PGDBObjEntity(pobj)^.formatEntity(drawing);
      end
 else if CurEntity is TvCircularArc then
      begin
           pobj := CreateInitObjFree(GDBArcID,nil);
           pgdbobjArc(pobj)^.R:=TvCircularArc(CurEntity).Radius;
           pgdbobjArc(pobj)^.Local.P_insert.x:=TvCircularArc(CurEntity).x;
           pgdbobjArc(pobj)^.Local.P_insert.y:=TvCircularArc(CurEntity).y;
           pgdbobjArc(pobj)^.StartAngle:=TvCircularArc(CurEntity).StartAngle*pi/180;
           pgdbobjArc(pobj)^.EndAngle:=TvCircularArc(CurEntity).EndAngle*pi/180;
           drawing{gdb}.GetCurrentRoot^.AddMi(@pobj);
           PGDBObjEntity(pobj)^.BuildGeometry(drawing);
           PGDBObjEntity(pobj)^.formatEntity(drawing);
      end
  else if CurEntity is fpvectorial.TPath then
      begin
      fpvectorial.TPath(CurEntity).PrepareForSequentialReading;
      for j := 0 to fpvectorial.TPath(CurEntity).Len - 1 do
      begin
        CurSegment := TPathSegment(fpvectorial.TPath(CurEntity).Next());

        case CurSegment.SegmentType of
        stMoveTo:
        begin
          PosX := Cur2DSegment.X;
          PosY := Cur2DSegment.Y;
        end;
        st2DLineWithPen,st2DLine, st3DLine:
        begin
           pobj := CreateInitObjFree(GDBLineID,nil);
           PGDBObjLine(pobj)^.CoordInOCS.lBegin:=createvertex(PosX,PosY,0);
           PosX := Cur2DSegment.X;
           PosY := Cur2DSegment.Y;
           PGDBObjLine(pobj)^.CoordInOCS.lEnd:=createvertex(PosX,PosY,0);
           drawing{gdb}.GetCurrentRoot^.AddMi(@pobj);
           PGDBObjEntity(pobj)^.BuildGeometry(drawing);
           PGDBObjEntity(pobj)^.formatEntity(drawing);
        end;
        end;
      end;

      end;
    end;
  except
        on Exception do
        begin
             shared.ShowError('Unsupported vector graphics format?');
        end
  end;
  //finally
    Vec.Free;
  //end;
end;
{$ENDIF}
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('iodxf.initialization');{$ENDIF} 
     i2:=0;
     FOC:=0;
end.
