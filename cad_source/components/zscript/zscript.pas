{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zscript;

interface

uses
  langsystem, languade, TypeDescriptors, UArrayDescriptor, 
  UBaseTypeDescriptor, UEnumDescriptor, UObjectDescriptor, UPointerDescriptor, 
  URecordDescriptor, Varman, USinonimDescriptor, UUnitManager, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('zscript', @Register);
end.
