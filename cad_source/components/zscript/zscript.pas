{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zscript;

{$warn 5023 off : no warning about unused units}
interface

uses
  langsystem, languade, UArrayDescriptor, UBaseTypeDescriptor, 
  UEnumDescriptor, UObjectDescriptor, UPointerDescriptor, URecordDescriptor, 
  USinonimDescriptor, UUnitManager, Varman, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zscript', @Register);
end.
