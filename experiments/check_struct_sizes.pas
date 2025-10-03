program CheckStructSizes;

{$mode objfpc}{$H+}

uses
  SysUtils,
  dwg in '../cad_source/components/fpdwg/dwg.pp';

begin
  WriteLn('=== Pascal Structure Sizes ===');
  WriteLn('SizeOf(Dwg_Object) = ', SizeOf(Dwg_Object));
  WriteLn('SizeOf(Dwg_Object_Entity) = ', SizeOf(Dwg_Object_Entity));
  WriteLn('SizeOf(Dwg_Object_Object) = ', SizeOf(Dwg_Object_Object));
  WriteLn('SizeOf(Dwg_Handle) = ', SizeOf(Dwg_Handle));
  WriteLn('SizeOf(Dwg_Class) = ', SizeOf(Dwg_Class));

  WriteLn;
  WriteLn('=== Pointer and Basic Type Sizes ===');
  WriteLn('SizeOf(Pointer) = ', SizeOf(Pointer));
  WriteLn('SizeOf(PtrUInt) = ', SizeOf(PtrUInt));
  WriteLn('SizeOf(BITCODE_RL) = ', SizeOf(BITCODE_RL));
  WriteLn('SizeOf(BITCODE_BS) = ', SizeOf(BITCODE_BS));
  WriteLn('SizeOf(BITCODE_BL) = ', SizeOf(BITCODE_BL));
  WriteLn('SizeOf(DWG_OBJECT_TYPE) = ', SizeOf(DWG_OBJECT_TYPE));
  WriteLn('SizeOf(DWG_OBJECT_SUPERTYPE) = ', SizeOf(DWG_OBJECT_SUPERTYPE));
end.
