unit DEVICE_OS_TURNSTILEONE;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='TURNSTILE.1';
   NMO_BaseName:='TURNSTILE';
   DB_link:='TURNSTILE';
   BTY_TreeCoord:='PLAN_OS_Турникет односторонний';
   NMO_Template:='@@[NMO_BaseName].@@[NMO_Suffix]';
end.
