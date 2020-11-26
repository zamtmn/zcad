unit uzcdevicebase;
{$INCLUDE def.inc}
interface
uses uzcinterface,uzbpaths,uzctranslations,gvector,varmandef,CsvDocument,uzcdevicebaseabstract,uzcsysvars,
     LazUTF8,uzcsysinfo,strmy,uzbtypesbase,uzbtypes,UUnitManager,varman,sysutils,
     typedescriptors,URecordDescriptor,UObjectDescriptor,uzclog;
type
{REGISTEROBJECTTYPE DeviceDbBaseObject}
{REGISTEROBJECTTYPE ElDeviceBaseObject}
{REGISTEROBJECTTYPE CableDeviceBaseObject}
{EXPORT+}
PDeviceDbBaseObject=^DeviceDbBaseObject;
DeviceDbBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object(DbBaseObject)
                       UID:GDBString;(*'**Уникальный идентификатор'*)(*oi_readonly*)

                       NameShortTemplate:GDBString;(*'**Формат короткого названия'*)(*oi_readonly*)
                       NameTemplate:GDBString;(*'**Формат названия'*)(*oi_readonly*)
                       NameFullTemplate:GDBString;(*'**Формат полного названия'*)(*oi_readonly*)
                       UIDTemplate:GDBString;(*'**Формат уникального идентификатора'*)(*oi_readonly*)
                       Variants:{-}TCSVDocument{/GDBPointer/};(*'Варианты'*)(*oi_readonly*)
                       constructor initnul;
                       procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
                       procedure Format;virtual;
                       procedure SetOtherFields(PField,PTypeDescriptor:GDBPointer);virtual;
                 end;
ElDeviceBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object(DeviceDbBaseObject)
                                   Pins:GDBString;(*'**Клеммы'*)
                                   constructor initnul;
                                   procedure Format;virtual;
                             end;
CableDeviceBaseObject={$IFNDEF DELPHI}packed{$ENDIF} object(DeviceDbBaseObject)
                                   CoreCrossSection:GDBDouble;(*'**Сечение жилы'*)
                                   NumberOfCores:GDBDouble;(*'**Количество жил'*)
                                   OuterDiameter:GDBDouble;(*'**Наружный диаметр'*)
                                   constructor initnul;
                             end;
{EXPORT-}
DeviceManager=object(GDBaseObject)
                    constructor init;
                    procedure loadfromdir(path: GDBString);
              end;
thead=record
            offset:integer;
            TD:PUserTypeDescriptor;
            cheked:boolean;
      end;
theadarray=TVector<thead>;
{procedure startup;
procedure finalize;}
const
     firstfilename='_startup.pas';
var devman:DeviceManager;
implementation
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
     variants:=nil;
     GDBPointer(NameTemplate):=nil;
     //NameTemplate:='DeviceDbBaseObject.initnul';
     GDBPointer(UIDTemplate):=nil;
     //UIDTemplate:='DeviceDbBaseObject.initnul';
     GDBPointer(NameFullTemplate):=nil;
     //NameFullTemplate:='DeviceDbBaseObject.initnul';
end;
procedure DeviceDbBaseObject.SetOtherFields(PField,PTypeDescriptor:GDBPointer);
var
    i:integer;
    FieldName:string;
    //cheked:boolean;

    //offset:GDBInteger;
    //tc:PUserTypeDescriptor;
    //pf:GDBPointer;

    headarray:theadarray;
    head:thead;

function checkrow(row:integer):boolean;
var
    j:integer;
    value:string;
begin
     for j:=0 to headarray.Size-1 do
     begin
          if headarray[j].cheked then
          begin
               value:=headarray[j].TD.GetValueAsString(@self+headarray[j].offset);
               if variants.Cells[j,row]<>'*' then
               if variants.Cells[j,row]<>value then
                                                 begin
                                                      result:=false;
                                                      exit;
                                                 end;
          end;
     end;
     result:=true;
end;
procedure setrow(row:integer);
var
    j:integer;
    //value:string;
begin
     for j:=0 to headarray.Size-1 do
     begin
          if not headarray[j].cheked then
          begin
               headarray[j].TD.SetValueFromString(@self+headarray[j].offset,variants.Cells[j,i]);
          end;
     end;
end;

begin
     if not assigned(variants) then exit;
     headarray:=theadarray.Create;
     for i:=0 to variants.ColCount[0]-1 do
     begin
          head.cheked:=false;
          FieldName:=variants.Cells[i,0];
          if FieldName<>''then
          if FieldName[1]='^'then
                                 begin
                                      head.cheked:=true;
                                      FieldName:=copy(FieldName,2,length(FieldName)-1);
                                 end;
          head.offset:=0;
          PRecordDescriptor(PTypeDescriptor).ApplyOperator('.',FieldName,head.offset,head.td);
          headarray.PushBack(head);
     end;
     for i:=1 to variants.RowCount do
     begin
          if checkrow(i) then
                             setrow(i);
     end;
     headarray.Destroy;
end;

procedure DeviceDbBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);
begin
     SetOtherFields(PField,PTypeDescriptor);
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
     //inherited format;
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
     DisableTranslate;
     s:=sysvar.PATH.device_library^;
     repeat
           GetPartOfPath(ts,s,'|');
           ts:=ExpandPath(ts);
           if DirectoryExists(utf8tosys(ts)) then
                                 begin
                                      loadfromdir(ts);
                                 end;
     until s='';
     EnableTranslate;
end;
procedure loaddev(fn:string;pdata:pointer);
begin
     units.loadunit(SupportPath,InterfaceTranslate,{utf8tosys}(fn),nil);
end;
procedure loadvariants(fn:string;pdata:pointer);
var
   pvd:pvardesk;
   pfd:PFieldDescriptor;
   pf:ppointer;
   dbobject:string;
begin
     dbobject:=extractfilename(ChangeFileExt(fn,''));
     pvd:=DBUnit.FindVariable(dbobject);
     if pvd<>nil then
                     begin
                          pfd:=PRecordDescriptor(pvd^.data.PTD)^.FindField('Variants');
                          if pfd<>nil then
                          begin
                               pf:=pvd.data.Instance+pfd.Offset;
                               pf^:=TCSVDocument.Create;
                               TCSVDocument(pf^).Delimiter:=';';
                               TCSVDocument(pf^).LoadFromFile(utf8tosys(fn));
                               //TCSVDocument(pf^).SaveToFile('c:\1.csv');
                          end;
                     end
                 else
                     ZCMsgCallBackInterface.TextMessage('',TMWOShowError);
end;
procedure DeviceManager.loadfromdir(path: GDBString);
//var sr: TSearchRec;
    //s:gdbstring;
begin

  FromDirIterator(utf8tosys(path),'*.pas',firstfilename,loaddev,nil);
  FromDirIterator(utf8tosys(path),'*.csv','',loadvariants,nil);

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
  startup;
end.
