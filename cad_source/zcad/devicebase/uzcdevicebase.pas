unit uzcdevicebase;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzcinterface,uzctranslations,

  SysUtils,gvector,

  LazUTF8,CsvDocument,uzcsysvars,

  uzsbVarmanDef,Varman,URecordDescriptor,UObjectDescriptor,uzsbTypeDescriptors,UUnitManager,
  uzcdevicebaseabstract,

  uzbpaths,uzeTypes;
type

DeviceDbBaseObject= object(DbBaseObject)
                       UID:String;(*'**Уникальный идентификатор'*)

                       NameShortTemplate:String;(*'**Формат короткого названия'*)
                       NameTemplate:String;(*'**Формат названия'*)
                       NameFullTemplate:String;(*'**Формат полного названия'*)
                       UIDTemplate:String;(*'**Формат уникального идентификатора'*)
                       Variants:TCSVDocument;(*'Варианты'*)
                       constructor initnul;
                       procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
                       procedure Format;virtual;
                       procedure SetOtherFields(PField,PTypeDescriptor:Pointer);virtual;
                 end;
PDeviceDbBaseObject=^DeviceDbBaseObject;

ElDeviceBaseObject= object(DeviceDbBaseObject)
                                   Pins:String;(*'**Клеммы'*)
                                   constructor initnul;
                                   procedure Format;virtual;
                             end;
PElDeviceBaseObject=^ElDeviceBaseObject;

CableDeviceBaseObject= object(DeviceDbBaseObject)
                                   CoreCrossSection:Double;(*'**Сечение жилы'*)
                                   NumberOfCores:Double;(*'**Количество жил'*)
                                   OuterDiameter:Double;(*'**Наружный диаметр'*)
                                   DDT:Double;(*'**ДТТ'*)
                                   constructor initnul;
                             end;
PCableDeviceBaseObject=^CableDeviceBaseObject;



DeviceManager=object(GDBaseObject)
                    constructor init;
                    procedure loadfromdir(path: String);
              end;
thead=record
            offset:integer;
            TD:PUserTypeDescriptor;
            cheked:boolean;
      end;
theadarray=TVector<thead>;

const
     firstfilename='_startup.pas';
var devman:DeviceManager;
procedure startup;
implementation
constructor CableDeviceBaseObject.initnul;
begin
     Inherited initnul;
     OuterDiameter:=0;
end;
constructor ElDeviceBaseObject.initnul;
begin
     Inherited initnul;
     Pointer(Pins):=nil;
     Pins:='ElDeviceBaseObject.initnul';
end;
constructor DeviceDbBaseObject.initnul;
begin
     Inherited initnul;
     variants:=nil;
     Pointer(NameTemplate):=nil;
     //NameTemplate:='DeviceDbBaseObject.initnul';
     Pointer(UIDTemplate):=nil;
     //UIDTemplate:='DeviceDbBaseObject.initnul';
     Pointer(NameFullTemplate):=nil;
     //NameFullTemplate:='DeviceDbBaseObject.initnul';
end;
procedure DeviceDbBaseObject.SetOtherFields(PField,PTypeDescriptor:Pointer);
var
    i:integer;
    FieldName:string;
    //cheked:boolean;

    //offset:Integer;
    //tc:PUserTypeDescriptor;
    //pf:Pointer;

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
               value:=headarray[j].TD.GetValueAsString(PByte(@self)+headarray[j].offset);
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
               headarray[j].TD.SetValueFromString(PByte(@self)+headarray[j].offset,variants.Cells[j,i]);
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

procedure DeviceDbBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
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
   s,ts:String;
begin
     DisableTranslate;
     s:=sysvar.PATH.device_library^;
     repeat
           GetPartOfPath(ts,s,';');
           ts:=ExpandPath(ts);
           if DirectoryExists(utf8tosys(ts)) then
                                 begin
                                      loadfromdir(ts);
                                 end;
     until s='';
     EnableTranslate;
end;
procedure loaddev(const fn:string;pdata:pointer);
begin
     units.loadunit(GetSupportPaths,InterfaceTranslate,{utf8tosys}(fn),nil);
end;
procedure loadvariants(const fn:string;pdata:pointer);
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
                               pf:=pvd.data.Addr.Instance+pfd.Offset;
                               pf^:=TCSVDocument.Create;
                               TCSVDocument(pf^).Delimiter:=';';
                               TCSVDocument(pf^).LoadFromFile(utf8tosys(fn));
                               //TCSVDocument(pf^).SaveToFile('c:\1.csv');
                          end;
                     end
                 else
                     zcUI.TextMessage('',TMWOShowError);
end;
procedure DeviceManager.loadfromdir(path: String);
//var sr: TSearchRec;
    //s:String;
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
     pt^.RegisterTypeinfo(TypeInfo(DbBaseObject));
     pt^.RegisterVMT(TypeOf(DbBaseObject));
     pt^.AddMetod('','initnul','',@DbBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('ElDeviceBaseObject');
     pt^.RegisterTypeinfo(TypeInfo(ElDeviceBaseObject));
     pt^.RegisterVMT(TypeOf(ElDeviceBaseObject));
     pt^.AddMetod('','initnul','',@ElDeviceBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('CableDeviceBaseObject');
     pt^.RegisterTypeinfo(TypeInfo(CableDeviceBaseObject));
     pt^.RegisterVMT(TypeOf(CableDeviceBaseObject));
     pt^.AddMetod('','initnul','',@CableDeviceBaseObject.initnul,m_constructor);

     //pt^.AddMetod('AfterDeSerialize','(SaveFlag:Word; membuf:Pointer):Integer;',nil,m_virtual);
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
  //startup;
end.
