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

unit iodxf;
{$INCLUDE def.inc}
interface
uses varman,geometry,GDBSubordinated,shared,gdbasetypes{,GDBRoot},log,GDBGenericSubEntry,SysInfo,gdbase, GDBManager, {OGLtypes,} sysutils{, strmy}, memman, UGDBDescriptor,gdbobjectsconstdef,
     UGDBObjBlockdefArray{,URecordDescriptor},UGDBOpenArrayOfTObjLinkRecord{,varmandef},UGDBOpenArrayOfByte,UGDBVisibleOpenArray,gdbEntity{,GDBBlockInsert,GDBCircle,GDBArc,GDBPoint,GDBText,GDBMtext,GDBLine,GDBPolyLine,GDBLWPolyLine},TypeDescriptors;
type
  entnamindex=record
                    entname:GDBString;
              end;
const
     acadentsupportcol=10;
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
     (entname:'3DFACE')
     );
type
  dxfhandlerec = record
    old, nev: GDBLongword;
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
procedure addfromdxf(name: GDBString;owner:PGDBObjGenericSubEntry);
procedure savedxf2000(name: GDBString; PDrawing:PTDrawing);
procedure saveZCP(name: GDBString; gdb: PGDBDescriptor);
procedure LoadZCP(name: GDBString; gdb: PGDBDescriptor);
implementation
uses GDBBlockDef,mainwindow,UGDBLayerArray;
function dxfhandlearraycreate(col: GDBInteger): GDBPointer;
var
  temp: pdxfhandlerecopenarray;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{D0FC4FBD-35D4-4E1A-A5E0-6D74D0516215}',{$ENDIF}GDBPointer(temp), sizeof(GDBInteger) + col * sizeof(dxfhandlerec));
  temp^.count := 0;
  result := temp;
end;

procedure pushhandle(p: pdxfhandlerecopenarray; old, nev: GDBLongword);
begin
  p^.arr[p^.count].old := old;
  p^.arr[p^.count].nev := nev;
  inc(p^.count);
end;

function getnevhandle(p: pdxfhandlerecopenarray; old: GDBLongword): GDBLongword;
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

function getoldhandle(p: pdxfhandlerecopenarray; nev: GDBLongword): GDBLongword;
var
  i: GDBInteger;
begin
  for i := 0 to p^.count - 1 do
    if p^.arr[i].nev = nev then
    begin
      result := p^.arr[i].old;
      exit;
    end;
  result := 0;
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
end;
procedure addentitiesfromdxf(var f: GDBOpenArrayOfByte;exitGDBString: GDBString;owner:PGDBObjSubordinated);
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

    MainFormN.ProcessLongProcess(f.ReadPos);

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
        PGDBObjEntity(pobj)^.LoadFromDXF(f,@additionalunit);
        pointer(postobj):=PGDBObjEntity(pobj)^.FromDXFPostProcessBeforeAdd(@additionalunit);
        trash:=false;
        if postobj=nil  then
                            begin
                                newowner:=owner;
                                if PGDBObjEntity(pobj).PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj).PExtAttrib.Handle>200 then
                                                                                      pushhandle(phandlearray,PGDBObjEntity(pobj).PExtAttrib.Handle,GDBLongword(pobj));
                                     if PGDBObjEntity(pobj).PExtAttrib.OwnerHandle>200 then
                                                                                      newowner:=pointer(getnevhandle(phandlearray,PGDBObjEntity(pobj).PExtAttrib.OwnerHandle));
                                     if PGDBObjEntity(pobj).PExtAttrib.OwnerHandle=h_trash then
                                                                                      trash:=true;


                                end;
                                if newowner=nil then
                                                    begin
                                                         historyoutstr('Warning! OwnerHandle $'+inttohex(PGDBObjEntity(pobj).PExtAttrib.OwnerHandle,8)+' not found');
                                                         newowner:=owner;
                                                    end;

                                if not trash then
                                if (newowner<>owner) then
                                begin
                                     m4:=PGDBObjEntity(newowner)^.getmatrix^;
                                     MatrixInvert(m4);
                                     pobj^.transform(@m4);
                                end;

                                if not trash then
                                begin
                                 newowner.AddMi(@pobj);
                                 if foc=0 then
                                              PGDBObjEntity(pobj)^.BuildGeometry;
                                 if foc=0 then
                                              PGDBObjEntity(pobj)^.format;
                                 if foc=0 then PGDBObjEntity(pobj)^.FromDXFPostProcessAfterAdd;
                                end
                                   else
                                       begin
                                 pobj.done;
                                 GDBFreeMem(pointer(pobj));

                                       end;

                            end
                        else
                            begin
                                newowner:=owner;
                                if PGDBObjEntity(pobj).PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj).PExtAttrib.OwnerHandle>200 then
                                                                                      newowner:=pointer(getnevhandle(phandlearray,PGDBObjEntity(pobj).PExtAttrib.OwnerHandle));
                                end;
                                if newowner<>nil then
                                begin
                                if PGDBObjEntity(pobj).PExtAttrib<>nil then
                                begin
                                     if PGDBObjEntity(pobj).PExtAttrib.Handle>200 then
                                                                                      pushhandle(phandlearray,PGDBObjEntity(pobj).PExtAttrib.Handle,GDBLongword(postobj));
                                end;
                                if newowner<>owner then
                                begin
                                     m4:=PGDBObjEntity(newowner)^.getmatrix^;
                                     MatrixInvert(m4);
                                     postobj^.transform(@m4);
                                end;

                                 newowner.AddMi(@postobj);
                                 pobj.OU.CopyTo(@PGDBObjEntity(postobj)^.ou);
                                 pobj.done;
                                 GDBFreeMem(pointer(pobj));
                                 if foc=0 then PGDBObjEntity(postobj)^.BuildGeometry;
                                 if foc=0 then
                                              PGDBObjEntity(postobj)^.FormatAfterDXFLoad;
                                 if foc=0 then PGDBObjEntity(postobj)^.FromDXFPostProcessAfterAdd;
                                end
                                   //else
                                   //    newowner:=newowner;
                            end;
      end;
      additionalunit.free;
    end;
  end;
  additionalunit.done;
end;
procedure addfromdxf12(var f:GDBOpenArrayOfByte;exitGDBString: GDBString;owner:PGDBObjSubordinated);
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

  MainFormN.ProcessLongProcess(f.ReadPos);

    s := f.readGDBString;
    if s = 'LAYER' then
    begin
      {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer table',lp_IncPos);{$ENDIF}
      repeat
            scode := f.readGDBString;
            sname := f.readGDBString;
            val(scode,GroupCode,ErrorCode);
      until GroupCode=0;
      repeat
        if sname='ENDTAB' then system.break;
        if sname<>'LAYER' then FatalError('''LAYER'' expected but '''+sname+''' found');
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
        gdb.GetCurrentDWG.LayerTable.addlayer(LayerName,LayerColor,-3,true,false,true);
      until sname='ENDTAB';
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
            tp := gdb.GetCurrentDWG.BlockDefArray.create(s);
            programlog.logoutstr('Found block '+s+';',lp_IncPos);
            {addfromdxf12}addentitiesfromdxf(f, 'ENDBLK',tp);
            programlog.logoutstr('end; {block '+s+'}',lp_DecPos);
          end;
        sname := f.readGDBString;
        s := f.readGDBString;
      until (s = 'ENDSEC');
      {$IFDEF TOTALYLOG}programlog.logoutstr('end; {block table}',lp_DecPos);{$ENDIF}
    end
    else if s = 'ENTITIES' then
    begin
         {$IFDEF TOTALYLOG}programlog.logoutstr('Found entities section',lp_IncPos);{$ENDIF}
         addentitiesfromdxf(f, 'EOF',owner);;
         {$IFDEF TOTALYLOG}programlog.logoutstr('end {entities section}',lp_DecPos);{$ENDIF}
    end;
  end;
  {$IFDEF TOTALYLOG}programlog.logoutstr('end; {AddFromDXF12}',lp_decPos);{$ENDIF}
end;
procedure addfromdxf2000(var f:GDBOpenArrayOfByte; exitGDBString: GDBString;owner:PGDBObjGenericSubEntry);
var
  byt: GDBInteger;
  error: GDBInteger;
  s, sname, lname, lcolor, llw: String;
  tp: PGDBObjBlockdef;
  oo,ll,pp:GDBBoolean;
  blockload:boolean;
begin
  blockload:=false;
  {$IFDEF TOTALYLOG}programlog.logoutstr('AddFromDXF2000',lp_IncPos);{$ENDIF}
  repeat
    gotodxf(f, 0, 'SECTION');
    if not f.notEOF then
      exit;
    s := f.readGDBString;
    s := f.readGDBString;
    if s = 'TABLES' then
    begin
      if not f.notEOF then
        exit;
      s := f.readGDBString;
      s := f.readGDBString;
      while s = 'TABLE' do
      begin
        if not f.notEOF then
          exit;
        s := f.readGDBString;
        s := f.readGDBString;

        if s = 'CLASSES' then
        begin
          gotodxf(f, 0, 'ENDTAB');
        end
        else
          if s = 'APPID' then
          begin
            gotodxf(f, 0, 'ENDTAB');
          end
          else
            if s = 'BLOCK_RECORD' then
            begin
              gotodxf(f, 0, 'ENDTAB');
            end
            else
              if s = 'DIMSTYLE' then
              begin
                gotodxf(f, 0, 'ENDTAB');
              end
              else
                if s = 'LAYER' then
                begin
                  {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer table',lp_IncPos);{$ENDIF}
                  gotodxf(f, 0, 'LAYER');

                  while s = 'LAYER' do
                  begin
                    byt := 2;
                    oo:=true;
                    ll:=false;
                    pp:=true;
                    while byt <> 0 do
                    begin
                      s := f.readGDBString;
                      byt := strtoint(s);
                      s := f.readGDBString;
                      case byt of
                        2:
                          begin
                            lname := s;
                          end;
                        62:
                          begin
                            lcolor := s;
                            if strtoint(lcolor)<0 then begin
                                                            oo:=false;
                                                       end;
                          end;
                        370:
                          begin
                            llw := s;
                          end;
                        70:
                          begin
                               if (strtoint(s)and 4)<>0 then
                                                                 begin
                                                                      ll:=true;
                                                                 end;
                           end;
                        290:
                          begin
                               if (strtoint(s)and 4)=0 then
                                                            begin
                                                                 pp:=false;
                                                            end;
                           end;


                      end;
                    end;
                    gdb.GetCurrentDWG.LayerTable.addlayer(lname, abs(strtoint(lcolor)), strtoint(llw),oo,ll,pp);
                    {$IFDEF TOTALYLOG}programlog.logoutstr('Found layer '+lname,0);{$ENDIF}
                  end;
                  {$IFDEF TOTALYLOG}programlog.logoutstr('end; {layer table}',lp_DecPos);{$ENDIF}
          //gotodxf(f, 0, 'ENDTAB');
                end
                else
                  if s = 'LTYPE' then
                  begin
                    gotodxf(f, 0, 'ENDTAB');
                  end
                  else
                    if s = 'STYLE' then
                    begin
                      gotodxf(f, 0, 'ENDTAB');
                    end
                    else
                      if s = 'UCS' then
                      begin
                        gotodxf(f, 0, 'ENDTAB');
                      end
                      else
                        if s = 'VIEW' then
                        begin
                          gotodxf(f, 0, 'ENDTAB');
                        end
                        else
                          if s = 'VPORT' then
                          begin
                            gotodxf(f, 0, 'ENDTAB');
                          end;
        s := f.readGDBString;
        s := f.readGDBString;
      end;

    end
    else
      if s = 'ENTITIES' then
      begin
        {$IFDEF TOTALYLOG}programlog.logoutstr('Found entities section',lp_IncPos);{$ENDIF}
        //inc(foc);
        {addfromdxf12}addentitiesfromdxf(f, 'ENDSEC',owner);
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
                shared.HistoryOutStr('Ignored block '+s+';');
                while (s <> 'ENDBLK') do
                  s := f.readGDBString;
              end
              else if gdb.GetCurrentDWG.BlockDefArray.getindex(pointer(@s[1]))>=0 then
                               begin
                                    //programlog.logoutstr('Ignored double definition block '+s+';',lp_OldPos);
                                    shared.HistoryOutStr('Ignored double definition block '+s+';');
                                    if s='DEVICE_KIP_UK-P'then
                                               s:=s;
                                    while (s <> 'ENDBLK') do
                                    s := f.readGDBString;
                               end
              else begin
                tp := gdb.GetCurrentDWG.BlockDefArray.create(s);
                programlog.logoutstr('Found block '+s+';',lp_IncPos);
                if s='Break' then
                               s:=s;
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
                AddEntitiesFromDXF(f,'ENDBLK',tp);
                dec(foc);
                if tp^.name='DEVICE_EL_MOTOR' then
                                                           tp.name:=tp.name;
                tp^.LoadFromDXF(f,nil);
                blockload:=true;
                programlog.logoutstr('end block;',lp_DecPos);
                sname:='##'
              end;
            if not blockload then
                                 sname := f.readGDBString;
            blockload:=false;
            s := f.readGDBString;
          until (s = 'ENDSEC');
          {$IFDEF TOTALYLOG}programlog.logoutstr('end; {block table}',lp_DecPos);{$ENDIF}
          gdb.GetCurrentDWG.BlockDefArray.Format;
        end;

    s := s;
//       if (byt=fcode) and (s=fname) then exit;
    MainFormN.ProcessLongProcess(f.ReadPos);
  until not f.notEOF;
  {$IFDEF TOTALYLOG}programlog.logoutstr('end; {AddFromDXF2000}',lp_decPos);{$ENDIF}
end;

procedure addfromdxf(name: GDBString;owner:PGDBObjGenericSubEntry);
var
  f: GDBOpenArrayOfByte;
  s: GDBString;
begin
  programlog.logoutstr('AddFromDXF',lp_IncPos);
  shared.HistoryOutStr('Loading file '+name+';');
  f.InitFromFile(name);
  if f.Count<>0 then
  begin
     phandlearray := dxfhandlearraycreate(10000);
  //f.ReadFromFile(name);
    MainFormN.StartLongProcess(f.Count);
  while f.notEOF do
  begin
    s := f.ReadString2;
    if s = '$ACADVER' then
    begin
      s := f.ReadString2;
      if s = '1' then
      begin
        s := f.ReadString2;
        if s = 'AC1009' then
        begin
          shared.HistoryOutStr('DXF12 fileformat;');
          //programlog.logout('DXF12 fileformat;',lp_OldPos);
          gotodxf(f, 0, 'ENDSEC');
          addfromdxf12(f,'EOF',owner);
        end
        else if s = 'AC1015' then
        begin
          shared.HistoryOutStr('DXF2000 fileformat;');
          //programlog.logout('DXF2000 fileformat;',lp_OldPos);
          gotodxf(f, 0, 'ENDSEC');
          addfromdxf2000(f,'EOF',owner);
        end
        else
        begin
             ShowError('Uncnown fileformat; $ACADVER='+s);
             //programlog.logoutstr('ERROR: Uncnown fileformat; $ACADVER='+s,lp_OldPos);
        end;
      end;
    end;
  end;
    MainFormN.EndLongProcess;
  owner.calcbb;
  GDBFreeMem(GDBPointer(phandlearray));
  end
     else
         shared.ShowError('IODXF.ADDFromDXF: Не могу открыть файл: '+name);
  f.done;
  programlog.logoutstr('end; {AddFromDXF}',lp_DecPos);
end;
procedure saveentitiesdxf2000(pva: PGDBObjEntityOpenArray; outhandle: GDBInteger; var handle: GDBInteger);
var
//  i:GDBInteger;
  pv:pgdbobjEntity;
  ir:itrec;
begin

     pv:=pva^.beginiterate(ir);
     if pv<>nil then
     repeat
          MainFormN.ProcessLongProcess(ir.itc);
          pv^.DXFOut(handle, outhandle);
     pv:=pva^.iterate(ir);
     until pv=nil;
end;

procedure savedxf2000;
var
  templatefile: GDBOpenArrayOfByte;
  outhandle: GDBInteger;
  groups, values: GDBString;
  groupi, valuei, intable: GDBInteger;
  handle,plottablefansdle,i{,cod}: GDBInteger;
  phandlea: pdxfhandlerecopenarray;
  inlayertable, inblocksec, inblocktable: GDBBoolean;
  handlepos:integer;
begin
  if FileExists(name) then
                         begin
                              deletefile(name+'.bak');
                              renamefile(name,name+'.bak');
                         end;

  outhandle := FileCreate(name);
  if outhandle>0 then
  begin
  MainFormN.StartLongProcess(pdrawing^.pObjRoot^.ObjArray.Count);
  phandlea := dxfhandlearraycreate(10000);
  templatefile.InitFromFile(sysparam.programpath + 'components/empty.dxf');
  handle := $2;
  inlayertable := false;
  inblocksec := false;
  inblocktable := false;
  while templatefile.notEOF do
  begin
    if  (templatefile.count-templatefile.ReadPos)<10
    then
        handle:=handle;
    groups := templatefile.readGDBString;
    values := templatefile.readGDBString;
    groupi := strtoint(groups);
    if (groupi = 9) and (values = '$HANDSEED') then
    begin
      WriteString_EOL(outhandle, groups);
      WriteString_EOL(outhandle, '$HANDSEED');
      WriteString_EOL(outhandle, '5');
      handlepos:=FileSeek(outhandle,0,1);
      WriteString_EOL(outhandle, 'FUCK OFF');
      groups := templatefile.readGDBString;
      values := templatefile.readGDBString;
      handle := strtoint('$' + values);
    end
    else
      if (groupi = 5) or (groupi = 320) or (groupi = 330) or (groupi = 340) or (groupi = 350) or (groupi = 1005) or (groupi = 390) or (groupi = 360) or (groupi = 105) then
      begin
        valuei := strtoint('$' + values);
                          {if valuei<>0 then
                                       begin}
        intable := {getnevhandle(phandlea, valuei)}valuei;
        if {intable <> 0}true then
        begin
          WriteString_EOL(outhandle, groups);
          WriteString_EOL(outhandle, inttohex(intable, 0));
        end
        else
        begin
          pushhandle(phandlea, valuei, handle);
          WriteString_EOL(outhandle, groups);
          WriteString_EOL(outhandle, inttohex(handle, 0));
          inc(handle);
        end;
        if inlayertable and (groupi=390) then
                                             plottablefansdle:={handle-1}intable;  {поймать плоттабле}
      end
      else
        if (groupi = 2) and (values = 'ENTITIES') then
        begin
          WriteString_EOL(outhandle, groups);
          WriteString_EOL(outhandle, values);
          //historyoutstr('Entities start here_______________________________________________________');
          saveentitiesdxf2000(@pdrawing^.pObjRoot^.ObjArray, outhandle, handle);
        end
        else
          if (groupi = 2) and (values = 'BLOCKS') then
          begin
            WriteString_EOL(outhandle, groups);
            WriteString_EOL(outhandle, values);
            inblocksec := true;
          end
          else
            if (inblocksec) and ((groupi = 0) and (values = 'ENDSEC')) then
            begin
              //historyoutstr('Blockdefs start here_______________________________________________________');
              if pdrawing^.BlockDefArray.count>0 then
              for i := 0 to pdrawing^.BlockDefArray.count - 1 do
              begin
                WriteString_EOL(outhandle, '0');
                WriteString_EOL(outhandle, 'BLOCK');
                WriteString_EOL(outhandle, '5');
                WriteString_EOL(outhandle, inttohex(handle, 0));
                inc(handle);
                WriteString_EOL(outhandle, '100');
                WriteString_EOL(outhandle, 'AcDbEntity');
                WriteString_EOL(outhandle, '8');
                WriteString_EOL(outhandle, '0');
                WriteString_EOL(outhandle, '100');
                WriteString_EOL(outhandle, 'AcDbBlockBegin');
                WriteString_EOL(outhandle, '2');
                WriteString_EOL(outhandle, PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].name);
                WriteString_EOL(outhandle, '70');
                WriteString_EOL(outhandle, '2');
                WriteString_EOL(outhandle, '10');
                WriteString_EOL(outhandle, floattostr(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].base.x));
                WriteString_EOL(outhandle, '20');
                WriteString_EOL(outhandle, floattostr(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].base.y));
                WriteString_EOL(outhandle, '30');
                WriteString_EOL(outhandle, floattostr(PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].base.z));
                WriteString_EOL(outhandle, '3');
                WriteString_EOL(outhandle, PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].name);
                WriteString_EOL(outhandle, '1');
                WriteString_EOL(outhandle, '');

                saveentitiesdxf2000(@PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].ObjArray, outhandle, handle);

                WriteString_EOL(outhandle, '0');
                WriteString_EOL(outhandle, 'ENDBLK');
                WriteString_EOL(outhandle, '5');
                WriteString_EOL(outhandle, inttohex(handle, 0));
                inc(handle);
                WriteString_EOL(outhandle, '100');
                WriteString_EOL(outhandle, 'AcDbEntity');
                WriteString_EOL(outhandle, '8');
                WriteString_EOL(outhandle, '0');
                WriteString_EOL(outhandle, '100');
                WriteString_EOL(outhandle, 'AcDbBlockEnd');

                //PBlockdefArray(gdb^.BlockDefArray.parray)^[i].SaveToDXFPostProcess(outhandle); asdasd

              end;

              WriteString_EOL(outhandle, '0');
              WriteString_EOL(outhandle, 'ENDSEC');


              inblocksec := false;
            end
            else if (inblocktable) and ((groupi = 0) and (values = 'ENDTAB')) then
            begin
              inblocktable := false;
              if pdrawing^.BlockDefArray.count>0 then

              for i := 0 to pdrawing^.BlockDefArray.count - 1 do
              begin
                WriteString_EOL(outhandle, '0');
                WriteString_EOL(outhandle, 'BLOCK_RECORD');
                WriteString_EOL(outhandle, '5');
                WriteString_EOL(outhandle, inttohex(handle, 0));
                inc(handle);
                WriteString_EOL(outhandle, '100');
                WriteString_EOL(outhandle, 'AcDbSymbolTableRecord');
                WriteString_EOL(outhandle, '100');
                WriteString_EOL(outhandle, 'AcDbBlockTableRecord');
                WriteString_EOL(outhandle, '2');
                WriteString_EOL(outhandle, PBlockdefArray(pdrawing^.BlockDefArray.parray)^[i].name);

              end;
              WriteString_EOL(outhandle, '0');
              WriteString_EOL(outhandle, 'ENDTAB');
            end

            else
              if (inlayertable) and ((groupi = 0) and (values = 'ENDTAB')) then
              begin
                inlayertable := false;
                for i := 0 to gdb.GetCurrentDWG.layertable.count - 1 do
                begin
                  if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name <> '0' then
                  begin
                    WriteString_EOL(outhandle, '0');
                    WriteString_EOL(outhandle, 'LAYER');
                    WriteString_EOL(outhandle, '5');
                    WriteString_EOL(outhandle, inttohex(handle, 0));
                    inc(handle);
                    WriteString_EOL(outhandle, '100');
                    WriteString_EOL(outhandle, 'AcDbSymbolTableRecord');
                    WriteString_EOL(outhandle, '100');
                    WriteString_EOL(outhandle, 'AcDbLayerTableRecord');
                    WriteString_EOL(outhandle, '2');
                    WriteString_EOL(outhandle, PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name);
                    WriteString_EOL(outhandle, '70');
                    WriteString_EOL(outhandle, '0');
                    WriteString_EOL(outhandle, '62');
                    if PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i]._on
                     then
                         WriteString_EOL(outhandle, inttostr(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].color))
                     else
                         WriteString_EOL(outhandle, inttostr(-PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].color));
                    WriteString_EOL(outhandle, '6');
                    WriteString_EOL(outhandle, 'Continuous');
                    WriteString_EOL(outhandle, '290');
                    if uppercase(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].name) <> 'DEFPOINTS' then
                      WriteString_EOL(outhandle, '1')
                    else
                      WriteString_EOL(outhandle, '0');
                    WriteString_EOL(outhandle, '370');
                    WriteString_EOL(outhandle,inttostr(PGDBLayerPropArray(gdb.GetCurrentDWG.layertable.parray)^[i].lineweight));
                    //WriteString_EOL(outhandle, '-3');
                    WriteString_EOL(outhandle, '390');
                    WriteString_EOL(outhandle, inttohex(plottablefansdle,0));
                  end;
                end;
                WriteString_EOL(outhandle, groups);
                WriteString_EOL(outhandle, values);
              end
              else
                if (groupi = 0) and (values = 'TABLE') then
                begin
                  WriteString_EOL(outhandle, groups);
                  WriteString_EOL(outhandle, values);
                  groups := templatefile.readGDBString;
                  values := templatefile.readGDBString;
                  groupi := strtoint(groups);
                  WriteString_EOL(outhandle, groups);
                  WriteString_EOL(outhandle, values);
                  if (groupi = 2) and (values = 'LAYER') then
                  begin
                    inlayertable := true;
                  end
                  else if (groupi = 2) and (values = 'BLOCK_RECORD') then
                  begin
                    inblocktable := true;
                  end;
                end
                else
                begin
                  WriteString_EOL(outhandle, groups);
                  WriteString_EOL(outhandle, values);
                  //val('$' + values, i, cod);
                end;
    //s := readspace(s);
  end;
  //templatefileclose;
  FileSeek(outhandle,handlepos,0);
  WriteString_EOL(outhandle,inttohex(handle+1,8));
  fileclose(outhandle);
  GDBFreeMem(GDBPointer(phandlea));
  templatefile.done;
  MainFormN.EndLongProcess;
  end
     else
         shared.ShowError('Не могу открыть файл: '+name);
end;
procedure SaveZCP(name: GDBString; gdb: PGDBDescriptor);
var
//  memsize:longint;
//  objcount:GDBInteger;
//  pmem,tmem:GDBPointer;
  outfile:GDBInteger;
  memorybuf:PGDBOpenArrayOfByte;
  s:ZCPHeader;
  linkbyf:PGDBOpenArrayOfTObjLinkRecord;
//  test:gdbvertex;
  sub:integer;
begin
     memorybuf:=nil;
     linkbyf:=nil;
     fillchar(s,sizeof(s),0);
     zcpmode:=zcptxt;
     sub:=0;
     sysunit.TypeName2PTD('ZCPHeader')^.Serialize(@ZCPHead,SA_SAVED_TO_SHD,memorybuf,linkbyf,sub);

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

     outfile:=FileCreate(name);
     FileWrite(outfile,memorybuf^.parray^,memorybuf^.Count);
     fileclose(outfile);
     outfile:=FileCreate(name+'remap');
     FileWrite(outfile,linkbyf^.parray^,linkbyf^.Count*linkbyf^.Size);
     fileclose(outfile);
     memorybuf.done;
     linkbyf.done;
end;
procedure LoadZCP(name: GDBString; gdb: PGDBDescriptor);
var
//  objcount:GDBInteger;
//  pmem,tmem:GDBPointer;
//  infile:GDBInteger;
//  head:ZCPheader;
  memorybuf:GDBOpenArrayOfByte;
  FileHeader:ZCPHeader;
//  test:gdbvertex;
  linkbyf:PGDBOpenArrayOfTObjLinkRecord;
begin
     fillchar(FileHeader,sizeof(FileHeader),0);
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
     gdb.GetCurrentDWG.FileName:=name;
     gdb.GetCurrentROOT.correctobjects(nil,-1);
     //fillchar(FileHeader,sizeof(FileHeader),0);
     {systype.TypeName2PTD('GDBVertex')^.DeSerialize(@test,SA_SAVED_TO_SHD,memorybuf);}
     (*FileRead(infile,header,sizeof(shdblockheader));
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
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('iodxf.initialization');{$ENDIF} 
     i2:=0;
     FOC:=0;
end.
