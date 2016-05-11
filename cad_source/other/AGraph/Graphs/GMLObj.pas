{ Version 990825. Copyright © Alexey A.Chernobaev, 1996-1999 }

unit GMLObj;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Pointerv;

type
  TGMLType = (GMLInt, GMLReal, GMLString, GMLList);
  {
    Типы данных GML:
    GMLInt: целый, не менее, чем 32 бита;
    GMLReal: с плавающей точкой, не менее, чем двойной точности (64 бита);
    GMLString: строковый;
    GMLList: список (принадлежит объекту GML и автоматически освобождается).
  }

  TGMLData = record
    case Byte of
      0: (AsInt: Int32);
      1: (AsReal: Float64);
      2: (AsString: PString);
      3: (AsList: TClassList);
  end;

  TGMLObject = class
  private
    FKey: PString;
    FGMLType: TGMLType;
    function GetKey: String;
  public
    Tag: Int32;
    Data: TGMLData;
    constructor CreateInt(const AKey: String; Value: Int32);
    constructor CreateReal(const AKey: String; Value: Float64);
    constructor CreateString(const AKey: String; const Value: String);
    constructor CreateList(const AKey: String; Value: TClassList);
    destructor Destroy; override;
    property Key: String read GetKey;
    property GMLType: TGMLType read FGMLType;
  end;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

constructor TGMLObject.CreateInt(const AKey: String; Value: Int32);
begin
  inherited Create;
  FKey:=NewStr(AKey);
  FGMLType:=GMLInt;
  Data.AsInt:=Value;
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
end;

constructor TGMLObject.CreateReal(const AKey: String; Value: Float64);
begin
  inherited Create;
  FKey:=NewStr(AKey);
  FGMLType:=GMLReal;
  Data.AsReal:=Value;
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
end;

constructor TGMLObject.CreateString(const AKey: String; const Value: String);
begin
  inherited Create;
  FKey:=NewStr(AKey);
  FGMLType:=GMLString;
  Data.AsString:=NewStr(Value);
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
end;

constructor TGMLObject.CreateList(const AKey: String; Value: TClassList);
begin
  inherited Create;
  FKey:=NewStr(AKey);
  FGMLType:=GMLList;
  Data.AsList:=Value;
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
end;

destructor TGMLObject.Destroy;
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectFree(Self);
  {$ENDIF}
  DisposeStr(FKey);
  if GMLType = GMLList then With Data.AsList do begin
    FreeItems;
    Free;
  end
  else
    if GMLType = GMLString then DisposeStr(Data.AsString);
  inherited Destroy;
end;

function TGMLObject.GetKey: String;
begin
  Result:=FKey^;
end;

end.
