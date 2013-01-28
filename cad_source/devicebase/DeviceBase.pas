unit DeviceBase;
{$INCLUDE def.inc}
interface
uses devicebaseabstract,zcadsysvars,fileutil,strproc,strmy,gdbasetypes,gdbase,UUnitManager,varman,{varmandef,}sysutils,typedescriptors,URecordDescriptor,UObjectDescriptor,shared;
type
{REGISTEROBJECTTYPE DbBaseObject}
{REGISTEROBJECTTYPE ElDeviceBaseObject}
{REGISTEROBJECTTYPE CableDeviceBaseObject}
{EXPORT+}
PDeviceDbBaseObject=^DeviceDbBaseObject;
DeviceDbBaseObject=object(DbBaseObject)
                       UID:GDBString;(*'**Уникальный идентификатор'*)(*oi_readonly*)

                       NameShortTemplate:GDBString;(*'**Формат короткого названия'*)(*oi_readonly*)
                       NameTemplate:GDBString;(*'**Формат названия'*)(*oi_readonly*)
                       NameFullTemplate:GDBString;(*'**Формат полного названия'*)(*oi_readonly*)
                       UIDTemplate:GDBString;(*'**Формат уникального идентификатора'*)(*oi_readonly*)
                       constructor initnul;
                       procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
                       procedure Format;virtual;
                 end;
ElDeviceBaseObject=object(DeviceDbBaseObject)
                                   Pins:GDBString;(*'**Клеммы'*)
                                   constructor initnul;
                                   procedure Format;virtual;
                             end;
CableDeviceBaseObject=object(DeviceDbBaseObject)
                                   ThreadSection:GDBDouble;(*'**Сечение жилы'*)
                                   ThreadCount:GDBDouble;(*'**Количество жил'*)
                                   OuterDiameter:GDBDouble;(*'**Наружный диаметр'*)
                                   constructor initnul;
                             end;
{EXPORT-}
DeviceManager=object(GDBaseObject)
                    constructor init;
                    procedure loadfromdir(path: GDBString);
              end;
{procedure startup;
procedure finalize;}
const
     firstfilename='_startup.pas';
var devman:DeviceManager;
implementation
uses log;
constructor CableDeviceBaseObject.initnul;
begin
     Inherited initnul;
     OuterDiameter:=0;
end;
constructor ElDeviceBaseObject.initnul;
begin
     Inherited initnul;
     GDBPointer(Pins):=nil;
     Pins:='ElDeviceBaseObject.initnul';
end;
constructor DeviceDbBaseObject.initnul;
begin
     Inherited initnul;
     GDBPointer(NameTemplate):=nil;
     //NameTemplate:='DeviceDbBaseObject.initnul';
     GDBPointer(UIDTemplate):=nil;
     //UIDTemplate:='DeviceDbBaseObject.initnul';
     GDBPointer(NameFullTemplate):=nil;
     //NameFullTemplate:='DeviceDbBaseObject.initnul';
end;
procedure DeviceDbBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);
begin
     format;
     if NameShortTemplate<>'' then
     NameShort:=typeformat(NameShortTemplate,@self,PTypeDescriptor);
     if NameTemplate<>'' then
     Name:=typeformat(NameTemplate,@self,PTypeDescriptor);
     if NameFullTemplate<>'' then
     NameFull:=typeformat(NameFullTemplate,@self,PTypeDescriptor);
     UID:=typeformat(UIDTemplate,@self,PTypeDescriptor);
end;
procedure DeviceDbBaseObject.Format;
begin
     inherited format;
     if NameShortTemplate<>'' then
     NameShort:=NameShortTemplate;
     if NameTemplate<>'' then
     Name:=NameTemplate;
     if NameFullTemplate<>'' then
     NameFull:=NameFullTemplate;
     UID:=UIDTemplate;
end;
procedure ElDeviceBaseObject.Format;
begin
     inherited format;
end;
constructor DeviceManager.init;
var
   s,ts:gdbstring;
begin
     s:=sysvar.PATH.device_library^;
     repeat
           GetPartOfPath(ts,s,'|');
           ts:=ExpandPath(ts);
           if DirectoryExists(utf8tosys(ts)) then
                                 begin
                                      loadfromdir(ts);
                                 end;
     until s='';
end;
procedure loaddev(fn:gdbstring);
begin
     units.loadunit({utf8tosys}(fn),nil);
end;
procedure DeviceManager.loadfromdir(path: GDBString);
var sr: TSearchRec;
    s:gdbstring;
begin

  FromDirIterator(utf8tosys(path),'*.pas',firstfilename,loaddev,nil);

end;
procedure startup;
var pt:PObjectDescriptor;
     //t:ElDeviceBaseObject;
begin
     if assigned(sysunit) then
     begin
     pt:=SysUnit.ObjectTypeName2PTD('DbBaseObject');
     pt^.RegisterVMT(TypeOf(DbBaseObject));
     pt^.AddMetod('','initnul','',@DbBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('ElDeviceBaseObject');
     pt^.RegisterVMT(TypeOf(ElDeviceBaseObject));
     pt^.AddMetod('','initnul','',@ElDeviceBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('CableDeviceBaseObject');
     pt^.RegisterVMT(TypeOf(CableDeviceBaseObject));
     pt^.AddMetod('','initnul','',@CableDeviceBaseObject.initnul,m_constructor);

     //pt^.AddMetod('AfterDeSerialize','(SaveFlag:GDBWord; membuf:GDBPointer):GDBInteger;',nil,m_virtual);
     //pt^.AddMetod('format','',@ElDeviceBaseObject.format,m_procedure);
     //t.initnul;
     //pt^.RunMetod('initnul',@t);
     //pt^.RunMetod('format',@t);
     devman.init;
     end;
end;
procedure finalize;
begin
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDeviceBase.initialization');{$ENDIF}
  startup;
end.
