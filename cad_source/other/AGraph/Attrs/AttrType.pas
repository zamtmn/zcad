{ Version 040228. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit AttrType;

interface

{$I VCheck.inc}

uses
  ExtType, SysUtils, VectErr, AttrErr;

type
  TExtAttrType = (AttrNone, AttrInt8, AttrUInt8, AttrBool, AttrChar, AttrInt16,
    AttrUInt16, AttrInt32, AttrUInt32, AttrPointer, AttrAutoFree, AttrString,
    AttrFloat32, AttrFloat64, AttrFloat80{$IFDEF V_32}, AttrWideString{$ENDIF});

  { AttrNone: атрибут не существует (может быть результатом метода AttrType);
    AttrEmpty: у атрибута нет значения (важен сам факт наличия атрибута);
    AttrAutoFree: аналог AttrPointer для хранения объектов; при уничтожении
    атрибута соответствующий объект уничтожается автоматически;
    другие типы: атрибут имеет значение соответствующего типа }

  TAttrType = Succ(AttrNone)..High(TExtAttrType);

  TAttrTypes = set of TAttrType;

const
{$IFDEF FLOAT_EQ_FLOAT32}
  AttrFloat = AttrFloat32;
{$ELSE} {$IFDEF FLOAT_EQ_FLOAT64}
  AttrFloat = AttrFloat64;
{$ELSE} {$IFDEF FLOAT_EQ_FLOAT80}
  AttrFloat = AttrFloat80;
{$ENDIF} {$ENDIF} {$ENDIF}

  MaxAttrSize = SizeOf(Float80);

  AttrSizes: array [TAttrType] of Byte = (SizeOf(Int8), SizeOf(UInt8),
    SizeOf(Bool), SizeOf(Char), SizeOf(Int16), SizeOf(UInt16), SizeOf(Int32),
    SizeOf(UInt32), SizeOf(Pointer), SizeOf(Pointer), SizeOf(PVString),
    SizeOf(Float32), SizeOf(Float64), SizeOf(Float80)
    {$IFDEF V_32}, SizeOf(WideString){$ENDIF});

  AttrNames: array [TAttrType] of String = ('Int8', 'UInt8', 'Bool', 'Char',
    'Int16', 'UInt16', 'Int32', 'UInt32', 'Pointer', 'AutoFree', 'String',
    'Float32', 'Float64', 'Float80'{$IFDEF V_32}, 'WideString'{$ENDIF});

function AttrTypeByName(const Name: String): TAttrType;
{ возвращает тип атрибута с именем Name (регистр неважен), если такой атрибут
  существует; иначе возбуждается исключительная ситуация }

implementation

function AttrTypeByName(const Name: String): TAttrType;
var
  UpperName: String;
  R: TAttrType;
begin
  UpperName:=UpperCase(Name);
  for R:=Low(TAttrType) to High(TAttrType) do
    if UpperName = UpperCase(AttrNames[R]) then begin
      Result:=R;
      Exit;
    end;
  raise Exception.Create('AttrTypeByName error: ' +
    ErrMsg(SWrongAttrName_s, [Name]));
end;

end.
