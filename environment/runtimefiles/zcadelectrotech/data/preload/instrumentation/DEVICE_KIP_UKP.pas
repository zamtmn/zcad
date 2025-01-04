unit DEVICE_KIP_UKP;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
implementation
begin
   Device_Type:=TDT_Junction;
   Device_Class:=TDC_Shell;

   BTY_TreeCoord:='PLAN_KIPIA_Коробка ответвительная';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Prefix:='';
   NMO_BaseName:='C';
   NMO_Suffix:='??';

   DB_link:='Коробка';
end.