unit registervirtualtreeview; 

{$Mode ObjFpc}
{$H+}

interface
  
procedure Register;

implementation

uses
  Classes, SysUtils, LResources, LazarusPackageIntf,
  VirtualTrees, VTHeaderPopup, VTIDEEditors, ComponentEditors;


procedure RegisterUnitVirtualTrees;
begin
  RegisterComponents('Virtual Controls', [TVirtualDrawTree, TVirtualStringTree]);
end;  

procedure RegisterUnitVTHeaderPopup;
begin
  RegisterComponents('Virtual Controls', [TVTHeaderPopupMenu]);
end;

procedure Register;

begin
  RegisterComponentEditor([TVirtualDrawTree, TVirtualStringTree], TVirtualTreeEditor);
  RegisterUnit('VirtualTrees', @RegisterUnitVirtualTrees);
  RegisterUnit('VTHeaderPopup', @RegisterUnitVTHeaderPopup);
end;

initialization
{$i ideicons.lrs}
 
end.
