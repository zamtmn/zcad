unit laz.RegisterVirtualTreeView; 

{$Mode ObjFpc}
{$H+}

interface

procedure Register;

implementation

{$R laz.ideicons.res}


uses
  Classes, SysUtils, LResources, LazarusPackageIntf,
  laz.VirtualTrees, laz.VTHeaderPopup, laz.VTIDEEditors, ComponentEditors;


procedure RegisterUnitVirtualTrees;
begin
  RegisterComponents('LazControls', [TLazVirtualDrawTree, TLazVirtualStringTree]);
end;  

procedure RegisterUnitVTHeaderPopup;
begin
  RegisterComponents('LazControls', [TLazVTHeaderPopupMenu]);
end;

procedure Register;

begin
  RegisterComponentEditor([TLazVirtualDrawTree, TLazVirtualStringTree], TLazVirtualTreeEditor);
  RegisterUnit('laz.VirtualTrees', @RegisterUnitVirtualTrees);
  RegisterUnit('laz.VTHeaderPopup', @RegisterUnitVTHeaderPopup);
end;

end.
