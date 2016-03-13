(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}  
unit uzccablemanager;
{$INCLUDE def.inc}
interface
uses uzcenitiesvariablesextender,uzcvariablesutils,Varman,strproc,GDBCable,GDBDevice,gdbobjectsconstdef,UGDBOpenArrayOfPObjects{,Varman},languade,UGDBOpenArrayOfObjects{,RegCnownTypes,URegisterObjects},SysUtils{,UBaseTypeDescriptor},gdbasetypes{, uzcshared},gdbase{,UGDBOpenArrayOfByte}, varmandef{,sysinfo}{,UGDBOpenArrayOfData},{log,}memman;
const
     DefCableName='Создан. Не назван';
     UnNamedCable='Имя отсутствует';
type
{EXPORT+}
    PTCableDesctiptor=^TCableDesctiptor;
    TCableDesctiptor={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
                     Name:GDBString;
                     Segments:GDBOpenArrayOfPObjects;
                     StartDevice,EndDevice:PGDBObjDevice;
                     StartSegment:PGDBObjCable;
                     Devices:GDBOpenArrayOfPObjects;
                     length:GDBDouble;
                     constructor init;
                     destructor done;virtual;
                     function GetObjTypeName:GDBString;virtual;
                     function GetObjName:GDBString;virtual;
                 end;

    PTCableManager=^TCableManager;
    TCableManager={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfObjects)(*OpenArrayOfPObj*)
                       constructor init;
                       procedure build;virtual;
                       function FindOrCreate(sname:gdbstring):PTCableDesctiptor;virtual;
                       function Find(sname:gdbstring):PTCableDesctiptor;virtual;
                 end;
{EXPORT-}
implementation
uses UGDBDescriptor;
function TCableDesctiptor.GetObjTypeName;
begin
     result:='TCableDesctiptor';
end;
function TCableDesctiptor.GetObjName;
begin
     if self.Segments.count=1 then
                                  result:=Name
                              else
                                  result:=Name+' ('+inttostr(self.Segments.count)+')';
end;
constructor TCableDesctiptor.init;
begin
     inherited;
     name:=defcablename;
     length:=0;
     Segments.init({$IFDEF DEBUGBUILD}'{FE431793-97FF-48AE-9B55-22D186BD5471}',{$ENDIF}10);
     Devices.init({$IFDEF DEBUGBUILD}'{7C4DC8CC-F0C0-402A-84F6-6FEA2C06F0C8}',{$ENDIF}10);
end;
constructor TCableManager.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{D8494E55-1296-45ED-A5ED-175D6C0671F5}',{$ENDIF}100,sizeof(TCableDesctiptor));
end;
destructor TCableDesctiptor.done;
begin
     name:='';
     Segments.done;
     //inherited;
end;
procedure TCableManager.build;
var pobj,pobj2:PGDBObjCable;
    ir,ir2,ir3:itrec;
    p1,p2:ppointer;
    tp:pointer;
    pvn,pvn2:pvardesk;
    sname:gdbstring;
    pcd,prevpcd:PTCableDesctiptor;
    tcd:TCableDesctiptor;
    itsok:boolean;
    pnp:PTNodeProp;
    sorted:boolean;
    lastadddevice:PGDBObjDevice;
    pentvarext,pentvarext2:PTVariablesExtender;
begin
     pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.vp.ID=GDBCableID then
           begin
                pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
                //pvn:=PTObjectUnit(pobj^.ou.Instance)^.FindVariable('NMO_Name');
                pvn:=pentvarext^.entityunit.FindVariable('NMO_Name');
                if pvn<>nil then
                                sname:=pgdbstring(pvn^.data.Instance)^
                            else
                                sname:=UnNamedCable;
                if sname='RS' then
                               sname:=sname;
                pcd:=FindOrCreate(sname);
                pcd^.Segments.AddRef(pobj^);
                //pvn:=PTObjectUnit(pobj^.ou.Instance)^.FindVariable('AmountD');
                pvn:=pentvarext^.entityunit.FindVariable('AmountD');
                if pvn<>nil then
                                pcd^.length:=pcd^.length+pgdbdouble(pvn^.data.Instance)^;
           end;
           pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
     until pobj=nil;
     pcd:=beginiterate(ir2);
     if pcd<>nil then
     repeat
           if pcd^.Segments.Count>1 then
           begin
                repeat
                itsok:=true;
                pobj2:=pcd^.Segments.beginiterate(ir);
                pentvarext2:=pobj2^.GetExtension(typeof(TVariablesExtender));
                p2:=pointer(ir.itp);
                pobj:=pcd^.Segments.iterate(ir);
                p1:=pointer(ir.itp);
                if pobj<>nil then
                repeat
                      pentvarext:=pobj^.GetExtension(typeof(TVariablesExtender));
                      //pvn :=PTObjectUnit(pobj^.ou.Instance)^.FindVariable('CABLE_Segment');
                      //pvn2:=PTObjectUnit(pobj2^.ou.Instance)^.FindVariable('CABLE_Segment');
                      pvn :=pentvarext^.entityunit.FindVariable('CABLE_Segment');
                      pvn2:=pentvarext2^.entityunit.FindVariable('CABLE_Segment');
                      if pgdbinteger(pvn^.data.Instance)^<
                         pgdbinteger(pvn2^.data.Instance)^ then
                         begin
                              tp:=p2^;
                              p2^:=p1^;
                              p1^:=tp;
                              itsok:=false;
                         end
                            else
                                begin
                                pobj2:=pobj;
                                pentvarext2:=pentvarext;
                                end;
                      p2:=p1;
                      pobj:=pcd^.Segments.iterate(ir);
                      if pobj<>nil then
                                       p1:=pointer(ir.itp);
                until pobj=nil;
                until itsok;
           end;
                lastadddevice:=nil;
                pobj:=pcd^.Segments.beginiterate(ir);
                pcd^.StartSegment:=pobj;
                      pnp:=pobj^.NodePropArray.beginiterate(ir3);
                      pcd^.StartDevice:=pnp^.DevLink;
                if pobj<>nil then
                repeat
                      pnp:=pobj^.NodePropArray.beginiterate(ir3);
                      //pcd^.StartDevice:=pnp^.DevLink;
                      if pnp<>nil then
                      repeat
                            if pnp^.DevLink<>nil then
                            begin
                                 if pnp^.DevLink<>lastadddevice then
                                 begin
                                       pcd^.Devices.AddRef(pnp^.DevLink^);
                                       lastadddevice:=pnp^.DevLink;
                                 end;
                                 if pcd^.EndDevice<>nil then
                                 begin
                                      pvn :=FindVariableInEnt(pnp^.DevLink,'RiserName');
                                      pvn2:=FindVariableInEnt(pcd^.EndDevice,'RiserName');
                                      if (pvn<>nil)and(pvn2<>nil)then
                                      begin
                                           if pstring(pvn^.data.Instance)^=pstring(pvn2^.data.Instance)^ then
                                           begin
                                                pvn :=FindVariableInEnt(pnp^.DevLink,'Elevation');
                                                pvn2:=FindVariableInEnt(pcd^.EndDevice,'Elevation');
                                                if (pvn<>nil)and(pvn2<>nil)then
                                                begin
                                                     pcd^.length:=pcd^.length+abs(pgdbdouble(pvn^.data.Instance)^-pgdbdouble(pvn2^.data.Instance)^);
                                                end;
                                           end;
                                      end;
                                 end;
                            end;
                            pcd^.EndDevice:=pnp^.DevLink;
                            pnp:=pobj^.NodePropArray.iterate(ir3);
                      until pnp=nil;
                      pobj:=pcd^.Segments.iterate(ir);
                until pobj=nil;
           pcd:=iterate(ir2);
     until pcd=nil;

     repeat
     sorted:=false;
     prevpcd:=beginiterate(ir2);
     pcd:=iterate(ir2);
     if (prevpcd<>nil)and(pcd<>nil) then
     repeat
           if {CompareNUMSTR}AnsiNaturalCompare(prevpcd^.Name,pcd^.Name)>0 then
                                          begin
                                               tcd:=prevpcd^;
                                               prevpcd^:=pcd^;
                                               pcd^:=tcd;
                                               sorted:=true;
                                          end;
           prevpcd:=pcd;
           pcd:=iterate(ir2);
     until pcd=nil;
     until not sorted;

     {pcd:=beginiterate(ir2);
     if (pcd<>nil) then
     repeat
           HistoryOutStr('Кабель "'+pcd^.Name+'", сегментов '+inttostr(pcd^.Segments.Count));
           pcd:=iterate(ir2);
     until pcd=nil;}
end;
function TCableManager.FindOrCreate;
var
    pcd:PTCableDesctiptor;
    ir:itrec;
    sn:gdbstring;
begin
     sn:=uppercase(sname);
     pcd:=beginiterate(ir);
     if pcd<>nil then
     repeat
           if uppercase(pcd^.Name)=sn then
                                             system.break;
           pcd:=iterate(ir);
     until pcd=nil;
     if pcd=nil then
     begin
          pcd:=pointer(self.CreateObject);
          pcd^.init;
          pcd^.name:=sname;
     end;
     result:=pcd;
end;
function TCableManager.Find;
var
    pcd:PTCableDesctiptor;
    ir:itrec;
    sn:gdbstring;
begin
     sn:=uppercase(sname);
     pcd:=beginiterate(ir);
     if pcd<>nil then
     repeat
           if uppercase(pcd^.Name)=sn then
                                             system.break;
           pcd:=iterate(ir);
     until pcd=nil;
     result:=pcd;
end;
begin
end.
