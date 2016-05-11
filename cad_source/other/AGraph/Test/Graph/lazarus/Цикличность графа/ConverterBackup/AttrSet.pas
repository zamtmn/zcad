{ Version 040625. Copyright © Alexey A.Chernobaev, 1996-2005 }

{ Предполагается, что SizeOf(Pointer) = 4 (см. GetData/SetData). }

unit AttrSet;

interface

{$I VCheck.inc}

uses
  SysUtils, Vectors, ExtType, ExtSys, AttrType, AttrMap, VStream, VTxtStrm,
  VFormat, VectStr, VectErr, AttrErr{$IFDEF V_WIDESTRINGS}{$IFNDEF LINUX},
  {$IFNDEF DYNAMIC_NLS}VUnicode{$ELSE}NLSProcsDyn{$ENDIF}{$ENDIF}{$ENDIF};

function CompareSets(AttrSet1, AttrSet2: Pointer): Integer;
{ сравнивает наборы атрибутов AttrSet1 и AttrSet2 в алфавитном порядке; если
  очередной проверяемый атрибут имеется только у одного из элементов, считаем,
  что значение данного атрибута для другого элемента равно значению "пусто",
  которое по определению меньше любого другого значения; если типы атрибутов
  не совпадают, то возбуждается исключительная ситуация }

function CompareUserSets(AttrSet1, AttrSet2: Pointer): Integer;
{ аналогична CompareSets, но игнорирует атрибуты, начинающиеся с символов <= '.' }

type
  TAttrSet = class(TVector)
  protected
    FMap: TAttrMap;
    procedure FreeDynamic;
    procedure CheckSize(Offset: Integer; AType: TAttrType);
    procedure ClearData(AType: TAttrType; var Data);
    procedure GetData(const Name: String; AType: TAttrType; var Data); virtual;
    procedure SetData(const Name: String; AType: TAttrType; const Data); virtual;
    procedure SetField(MapIndex: Integer; const VarRec: TVarRec);
    function DoCompareWith(AttrSet2: TAttrSet; Params: Word; SkipUser: Bool): Int32;
    function GetAsInt8(const Name: String): Int8;
    procedure SetAsInt8(const Name: String; Value: Int8);
    function GetAsUInt8(const Name: String): UInt8;
    procedure SetAsUInt8(const Name: String; Value: UInt8);
    function GetAsBool(const Name: String): Bool;
    procedure SetAsBool(const Name: String; Value: Bool);
    function GetAsChar(const Name: String): Char;
    procedure SetAsChar(const Name: String; Value: Char);
    function GetAsInt16(const Name: String): Int16;
    procedure SetAsInt16(const Name: String; Value: Int16);
    function GetAsUInt16(const Name: String): UInt16;
    procedure SetAsUInt16(const Name: String; Value: UInt16);
    function GetAsInt32(const Name: String): Int32;
    procedure SetAsInt32(const Name: String; Value: Int32);
    function GetAsUInt32(const Name: String): UInt32;
    procedure SetAsUInt32(const Name: String; Value: UInt32);
    function GetAsFloat32(const Name: String): Float32;
    procedure SetAsFloat32(const Name: String; Value: Float32);
    function GetAsPointer(const Name: String): Pointer;
    procedure SetAsPointer(const Name: String; Value: Pointer);
    {$IFDEF CHECK_ATTRS}
    function GetAsAutoFree(const Name: String): Pointer;
    procedure SetAsAutoFree(const Name: String; Value: Pointer);
    {$ENDIF}
    function GetAsString(const Name: String): String;
    procedure SetAsString(const Name, Value: String);
    function GetAsFloat64(const Name: String): Float64;
    procedure SetAsFloat64(const Name: String; Value: Float64);
    function GetAsFloat80(const Name: String): Float80;
    procedure SetAsFloat80(const Name: String; Value: Float80);
    {$IFDEF V_WIDESTRINGS}
    function GetAsWideString(const Name: String): WideString;
    procedure SetAsWideString(const Name: String; const Value: WideString);
    {$ENDIF}
    function GetAsText(const Name: String): String; virtual;
    procedure SetAsText(const Name, Value: String); virtual;
    function GetAsInt8ByOfs(Ofs: Integer): Int8;
    procedure SetAsInt8ByOfs(Ofs: Integer; Value: Int8);
    function GetAsUInt8ByOfs(Ofs: Integer): UInt8;
    procedure SetAsUInt8ByOfs(Ofs: Integer; Value: UInt8);
    function GetAsBoolByOfs(Ofs: Integer): Bool;
    procedure SetAsBoolByOfs(Ofs: Integer; Value: Bool);
    function GetAsCharByOfs(Ofs: Integer): Char;
    procedure SetAsCharByOfs(Ofs: Integer; Value: Char);
    function GetAsInt16ByOfs(Ofs: Integer): Int16;
    procedure SetAsInt16ByOfs(Ofs: Integer; Value: Int16);
    function GetAsUInt16ByOfs(Ofs: Integer): UInt16;
    procedure SetAsUInt16ByOfs(Ofs: Integer; Value: UInt16);
    function GetAsInt32ByOfs(Ofs: Integer): Int32;
    procedure SetAsInt32ByOfs(Ofs: Integer; Value: Int32);
    function GetAsUInt32ByOfs(Ofs: Integer): UInt32;
    procedure SetAsUInt32ByOfs(Ofs: Integer; Value: UInt32);
    function GetAsFloat32ByOfs(Ofs: Integer): Float32;
    procedure SetAsFloat32ByOfs(Ofs: Integer; Value: Float32);
    function GetAsPointerByOfs(Ofs: Integer): Pointer;
    procedure SetAsPointerByOfs(Ofs: Integer; Value: Pointer);
    {$IFDEF CHECK_ATTRS}
    function GetAsAutoFreeByOfs(Ofs: Integer): Pointer;
    procedure SetAsAutoFreeByOfs(Ofs: Integer; Value: Pointer);
    {$ENDIF}
    function GetAsStringByOfs(Ofs: Integer): String;
    procedure SetAsStringByOfs(Ofs: Integer; const Value: String);
    {$IFDEF V_WIDESTRINGS}
    function GetAsWideStringByOfs(Ofs: Integer): WideString;
    procedure SetAsWideStringByOfs(Ofs: Integer; const Value: WideString);
    {$ENDIF}
    function GetAsFloat64ByOfs(Ofs: Integer): Float64;
    procedure SetAsFloat64ByOfs(Ofs: Integer; Value: Float64);
    function GetAsFloat80ByOfs(Ofs: Integer): Float80;
    procedure SetAsFloat80ByOfs(Ofs: Integer; Value: Float80);
  public
    constructor Create(AMap: TAttrMap);
    destructor Destroy; override;
    procedure WriteToStream(VStream: TVStream); override;
    procedure ReadFromStream(VStream: TVStream); override;
    { для правильного считывания из потока необходимо, чтобы типы и порядок
      определения атрибутов в карте атрибутов в моменты сохранения и
      считывания совпадали; в противном случае возможен крах системы! }
    procedure WriteToTextStream(TextStream: TTextStream); virtual;
    { запись в текстовый поток }
    procedure ReadFromTextStream(TextStream: TTextStream); virtual;
    { чтение из текстового потока }
    procedure Assign(Source: TVector); override;
    { AutoFree-атрибуты не копируются! }
    procedure Clear; override;
    class function Compare(AttrSet1, AttrSet2: Pointer): Integer;
    { аналогична CompareSets }
    class function CompareUser(AttrSet1, AttrSet2: Pointer): Integer;
    { аналогична CompareUserSets }
    procedure SetFields(const Fields: array of String; const Values: array of const);
    { присвоить полям, перечисленным в Fields, значения Values }
    procedure SetAllFields(const Values: array of const);
    { присвоить всем полям (в порядке их следования в карте атрибутов) значения
      Values }
    function SafeAttrType(const Name: String): TExtAttrType;
    { возвращает тип атрибута с именем Name, либо AttrNone, если атрибут не
      определен }
    function GetType(const Name: String): TExtAttrType;
    { возвращает тип атрибута с именем Name; если атрибут не определен, то
      возбуждается исключительная ситуация }
    function LoLevelCompare(AttrSet2: TAttrSet; AttrType: TExtAttrType;
      Ofs1, Ofs2: Integer; Params: Word): Int32;
    { сравнить значение Self типа AttrType, хранящееся по смещению Ofs1,
      с однотипным значением атрибута AttrSet2, хранящимся по смещению Ofs2,
      с параметрами сравнения, равными Params; параметры учитываются для
      AttrString (CmpStrF в модуле VectStr) и AttrWideString (при Params = 0
      регистр строк не учитывается, иначе - учитывается) }
    function CompareWith(AttrSet2: TAttrSet; Params: Word): Int32;
    { сравнить Self со значениями атрибута AttrSet2, у которого может быть как
      та же карта атрибутов, так и другая (атрибуты сравниваются в алфавитном
      порядке; функция учитывает все атрибуты, как общие, так и локальные; если
      очередной проверяемый атрибут имеется только у одного из элементов,
      считаем, что значение данного атрибута для другого элемента равно значению
      "пусто", которое по определению меньше любого другого значения; если типы
      атрибутов не совпадают, то возбуждается исключительная ситуация) }
    function CompareWithUser(AttrSet2: TAttrSet; Params: Word): Int32;
    { аналогична CompareWith, но игнорирует атрибуты, начинающиеся с символов
      <= '.' }
    property AsInt8[const Name: String]: Int8
      read GetAsInt8 write SetAsInt8;
    property AsUInt8[const Name: String]: UInt8
      read GetAsUInt8 write SetAsUInt8;
    property AsBool[const Name: String]: Bool
      read GetAsBool write SetAsBool;
    property AsChar[const Name: String]: Char
      read GetAsChar write SetAsChar;
    property AsInt16[const Name: String]: Int16
      read GetAsInt16 write SetAsInt16;
    property AsUInt16[const Name: String]: UInt16
      read GetAsUInt16 write SetAsUInt16;
    property AsInt32[const Name: String]: Int32
      read GetAsInt32 write SetAsInt32;
    property AsUInt32[const Name: String]: UInt32
      read GetAsUInt32 write SetAsUInt32;
    property AsFloat32[const Name: String]: Float32
      read GetAsFloat32 write SetAsFloat32;
    property AsFloat64[const Name: String]: Float64
      read GetAsFloat64 write SetAsFloat64;
    property AsFloat80[const Name: String]: Float80
      read GetAsFloat80 write SetAsFloat80;
    {$IFDEF FLOAT_EQ_FLOAT32}
    property AsFloat[const Name: String]: Float
      read GetAsFloat32 write SetAsFloat32;
    {$ELSE} {$IFDEF FLOAT_EQ_FLOAT64}
    property AsFloat[const Name: String]: Float
      read GetAsFloat64 write SetAsFloat64;
    {$ELSE} {$IFDEF FLOAT_EQ_FLOAT80}
    property AsFloat[const Name: String]: Float
      read GetAsFloat80 write SetAsFloat80;
    {$ENDIF} {$ENDIF} {$ENDIF}
    property AsDateTime[const Name: String]: Float64
      read GetAsFloat64 write SetAsFloat64;
    property AsPointer[const Name: String]: Pointer
      read GetAsPointer write SetAsPointer;
    property AsAutoFree[const Name: String]: Pointer
      {$IFDEF CHECK_ATTRS}
      read GetAsAutoFree write SetAsAutoFree;
      {$ELSE}
      read GetAsPointer write SetAsPointer;
      {$ENDIF}
    property AsString[const Name: String]: String
      read GetAsString write SetAsString;
    {$IFDEF V_WIDESTRINGS}
    property AsWideString[const Name: String]: WideString
      read GetAsWideString write SetAsWideString;
    {$ENDIF}
    property AsText[const Name: String]: String read GetAsText write SetAsText;
    { автоматически приводит данные любого типа к типу String и наоборот }
    property AsInt8ByOfs[Ofs: Integer]: Int8
      read GetAsInt8ByOfs write SetAsInt8ByOfs;
    property AsUInt8ByOfs[Ofs: Integer]: UInt8
      read GetAsUInt8ByOfs write SetAsUInt8ByOfs;
    property AsBoolByOfs[Ofs: Integer]: Bool
      read GetAsBoolByOfs write SetAsBoolByOfs;
    property AsCharByOfs[Ofs: Integer]: Char
      read GetAsCharByOfs write SetAsCharByOfs;
    property AsInt16ByOfs[Ofs: Integer]: Int16
      read GetAsInt16ByOfs write SetAsInt16ByOfs;
    property AsUInt16ByOfs[Ofs: Integer]: UInt16
      read GetAsUInt16ByOfs write SetAsUInt16ByOfs;
    property AsInt32ByOfs[Ofs: Integer]: Int32
      read GetAsInt32ByOfs write SetAsInt32ByOfs;
    property AsUInt32ByOfs[Ofs: Integer]: UInt32
      read GetAsUInt32ByOfs write SetAsUInt32ByOfs;
    property AsFloat32ByOfs[Ofs: Integer]: Float32
      read GetAsFloat32ByOfs write SetAsFloat32ByOfs;
    property AsFloat64ByOfs[Ofs: Integer]: Float64
      read GetAsFloat64ByOfs write SetAsFloat64ByOfs;
    property AsFloat80ByOfs[Ofs: Integer]: Float80
      read GetAsFloat80ByOfs write SetAsFloat80ByOfs;
    {$IFDEF FLOAT_EQ_FLOAT32}
    property AsFloatByOfs[Ofs: Integer]: Float
      read GetAsFloat32ByOfs write SetAsFloat32ByOfs;
    {$ELSE} {$IFDEF FLOAT_EQ_FLOAT64}
    property AsFloatByOfs[Ofs: Integer]: Float
      read GetAsFloat64ByOfs write SetAsFloat64ByOfs;
    {$ELSE} {$IFDEF FLOAT_EQ_FLOAT80}
    property AsFloatByOfs[Ofs: Integer]: Float
      read GetAsFloat80ByOfs write SetAsFloat80ByOfs;
    {$ENDIF} {$ENDIF} {$ENDIF}
    property AsDateTimeByOfs[Ofs: Integer]: Float64
      read GetAsFloat64ByOfs write SetAsFloat64ByOfs;
    property AsPointerByOfs[Ofs: Integer]: Pointer
      read GetAsPointerByOfs write SetAsPointerByOfs;
    property AsAutoFreeByOfs[Ofs: Integer]: Pointer
      {$IFDEF CHECK_ATTRS}
      read GetAsAutoFreeByOfs write SetAsAutoFreeByOfs;
      {$ELSE}
      read GetAsPointerByOfs write SetAsPointerByOfs;
      {$ENDIF}
    property AsStringByOfs[Ofs: Integer]: String
      read GetAsStringByOfs write SetAsStringByOfs;
    {$IFDEF V_WIDESTRINGS}
    property AsWideStringByOfs[Ofs: Integer]: WideString
      read GetAsWideStringByOfs write SetAsWideStringByOfs;
    {$ENDIF}
    procedure ClearField(const Name: String); virtual;
    { очистить поле Name (присвоить ему 0 - для числовых типов, '' - для строк,
      nil - для указателей) }
    property Map: TAttrMap read FMap;
  end;

  TAutoAttrSet = class(TAttrSet)
    constructor Create;
    destructor Destroy; override;
    procedure WriteToStream(VStream: TVStream); override;
    procedure ReadFromStream(VStream: TVStream); override;
    procedure WriteToTextStream(TextStream: TTextStream); override;
    procedure ReadFromTextStream(TextStream: TTextStream); override;
    procedure Assign(Source: TVector); override;
  end;

implementation

function CompareSets(AttrSet1, AttrSet2: Pointer): Integer;
begin
  Result:=TAttrSet(AttrSet1).CompareWith(TAttrSet(AttrSet2), 0);
end;

function CompareUserSets(AttrSet1, AttrSet2: Pointer): Integer;
begin
  Result:=TAttrSet(AttrSet1).CompareWithUser(TAttrSet(AttrSet2), 0);
end;

{$IFDEF V_WIDESTRINGS}
function GetWide(P: PPointer): WideString;
var
  L: Integer;
begin
  if P^ <> nil then
    if Integer(P^) and 1 = 0 then
      Result:=PPVString(P)^^
    else begin
      P:=Pointer(Integer(P^) and not 1);
      L:=Length(PVString(P)^);
      SetLength(Result, L div 2);
      Move(Pointer(PVString(P)^)^, Pointer(Result)^, L);
    end
  else
    Result:='';
end;

procedure SetWide(P: PPointer; const Value: WideString);
var
  S: String;
begin
  if P^ <> nil then
    DisposeVStr(PVString(Integer(P^) and not 1));
  if IsASCIIWideString(Value) then
    PPVString(P)^:=NewVStr(Value)
  else begin
    SetString(S, PChar(Pointer(Value)), Length(Value) * 2);
    P^:=Pointer(Integer(NewVStr(S)) or 1);
  end;
end;
{$ENDIF}

{ TAttrSet }

constructor TAttrSet.Create(AMap: TAttrMap);
begin
  inherited Create(1);
  FMap:=AMap;
end;

destructor TAttrSet.Destroy;
begin
  FreeDynamic;
  inherited Destroy;
end;

procedure TAttrSet.FreeDynamic;
var
  I: Integer;
  Offset: Integer;
  P: PPointer;
  AttrType: TExtAttrType;
begin
  for I:=0 to FMap.Count - 1 do begin
    AttrType:=FMap.AttrTypeByIndex(I);
    if AttrType in [AttrAutoFree, AttrString{$IFDEF V_WIDESTRINGS}, AttrWideString{$ENDIF}] then begin
      Offset:=FMap.OffsetByIndex(I);
      if Offset < FCount then begin
        P:=PPointer(PChar(FItems) + Offset);
        if AttrType = AttrString then
          DisposeVStr(PPVString(P)^)
        {$IFDEF V_WIDESTRINGS}
        else if AttrType = AttrWideString then
          SetWide(P, '')
        {$ENDIF}
        else { AttrType = AttrAutoFree }
          TObject(P^).Free;
      end;
    end;
  end;
end;

procedure TAttrSet.WriteToStream(VStream: TVStream);
var
  I: Integer;
  Offset: Integer;
  P: Pointer;
  S: String;
  AttrType: TExtAttrType;
begin
  VStream.WriteInt32(FCount);
  if FCount > 0 then
    for I:=0 to FMap.Count - 1 do begin
      Offset:=FMap.OffsetByIndex(I);
      if Offset < FCount then begin
        P:=PChar(FItems) + Offset;
        AttrType:=FMap.AttrTypeByIndex(I);
        if AttrType = AttrString then begin
          P:=PPVString(P)^;
          if P <> nil then
            S:=PVString(P)^
          else
            S:='';
          VStream.WriteString(S);
        end
        {$IFDEF V_WIDESTRINGS}
        else if AttrType = AttrWideString then
          VStream.WriteWideString(GetWide(P))
        {$ENDIF}
        else
          VStream.WriteProc(P^, AttrSizes[AttrType]);
      end;
    end;
end;

procedure TAttrSet.ReadFromStream(VStream: TVStream);
var
  I, ACount: Integer;
  Offset: Integer;
  P: Pointer;
  AttrType: TExtAttrType;
begin
  FreeDynamic;
  ACount:=VStream.ReadInt32;
  Count:=ACount;
  if ACount > 0 then
    for I:=0 to FMap.Count - 1 do begin
      Offset:=FMap.OffsetByIndex(I);
      if Offset < ACount then begin
        P:=PChar(FItems) + Offset;
        AttrType:=FMap.AttrTypeByIndex(I);
        if AttrType = AttrString then
          PPVString(P)^:=NewVStr(VStream.ReadString)
        {$IFDEF V_WIDESTRINGS}
        else if AttrType = AttrWideString then
          SetWide(P, VStream.ReadWideString)
        {$ENDIF}
        else
          VStream.ReadProc(P^, AttrSizes[AttrType]);
      end;
    end;
end;

procedure TAttrSet.WriteToTextStream(TextStream: TTextStream);
var
  I: Integer;
  Name, Value: String;
begin
  for I:=0 to FMap.Count - 1 do begin
    Name:=FMap.AttrName(I);
    Value:=AsText[Name];
    if FMap.AttrTypeByIndex(I) in [AttrString{$IFDEF V_WIDESTRINGS}, AttrWideString{$ENDIF}] then
      Value:=StringToLiteral(Value);
    TextStream.WriteString(Name + '=' + Value);
  end;
end;

procedure TAttrSet.ReadFromTextStream(TextStream: TTextStream);
var
  I, J: Integer;
  S: String;
begin
  for I:=0 to FMap.Count - 1 do begin
    S:=TextStream.ReadString;
    J:=Pos('=', S);
    if J = 0 then
      Error(SWrongTextStreamFormat);
    AsText[Trim(Copy(S, 1, J - 1))]:=
      LiteralToString(Trim(Copy(S, J + 1, Length(S))));
  end;
end;

procedure TAttrSet.Assign(Source: TVector);
var
  I, N, Offset, DataEnd, SourceOffset, NewCount: Integer;
  AttrType: TExtAttrType;
  AttrSize: Byte;
  P: PPointer;
  S: String;
  {$IFDEF V_WIDESTRINGS}
  W: WideString;
  {$ENDIF}
begin
  if Source is TAttrSet then begin
    {$IFDEF CHECK_ATTRS}
    { проверяем идентичность карт - из соображений эффективности, только в
      отладочном режиме }
    if not FMap.CompatibleMap(TAttrSet(Source).FMap) then
      Error(SIncompatibleClasses);
    {$ENDIF}
    N:=FMap.Count;
    if FMap = TAttrSet(Source).FMap then begin
      { порядок атрибутов совпадает => быстрый вариант }
      FreeDynamic;
      inherited Assign(Source);
      { не копируем AutoFree-атрибуты, дабы избежать их повторного освобождения;
        копируем строки }
      for I:=0 to N - 1 do begin
        AttrType:=FMap.AttrTypeByIndex(I);
        if AttrType in [AttrAutoFree, AttrString{$IFDEF V_WIDESTRINGS}, AttrWideString{$ENDIF}] then begin
          Offset:=FMap.OffsetByIndex(I);
          if Offset < FCount then begin
            P:=PPointer(PChar(FItems) + Offset);
            if AttrType = AttrString then
              PPVString(P)^:=NewVStr(TAttrSet(Source).AsStringByOfs[Offset])
            {$IFDEF V_WIDESTRINGS}
            else if AttrType = AttrWideString then
              SetWide(P, TAttrSet(Source).AsWideStringByOfs[Offset])
            {$ENDIF}
            else { AttrAutoFree }
              P^:=nil
          end;
        end;
      end; {for}
    end
    else begin { порядок атрибутов не совпадает => медленный вариант }
      NewCount:=0;
      { выделяем память "с запасом", чтобы уменьшить количество обращений
        к менеджеру памяти }
      inherited Clear; { начальные значения будут равны 0 }
      Count:=TAttrSet(Source).Count + N * MaxAttrSize;
      for I:=0 to N - 1 do begin
        Offset:=(FMap.AttrOffsets)[I];
        SourceOffset:=TAttrSet(Source).FMap.OffsetByIndex(
          TAttrSet(Source).FMap.IndexOfAttr(FMap.AttrName(I)));
        AttrType:=FMap.AttrTypeByIndex(I);
        AttrSize:=AttrSizes[AttrType];
        DataEnd:=Offset + AttrSize;
        if AttrType = AttrString then begin
          S:=TAttrSet(Source).AsStringByOfs[SourceOffset];
          AsStringByOfs[Offset]:=S;
          if (S <> '') and (DataEnd > NewCount) then
            NewCount:=DataEnd;
        end
        {$IFDEF V_WIDESTRINGS}
        else if AttrType = AttrWideString then begin
          W:=TAttrSet(Source).AsWideStringByOfs[SourceOffset];
          AsWideStringByOfs[Offset]:=W;
          if (W <> '') and (DataEnd > NewCount) then
            NewCount:=DataEnd;
        end
        {$ENDIF}
        else
          if (SourceOffset < TAttrSet(Source).FCount) and
            (AttrType <> AttrAutoFree) then
          begin
            Move((PChar(TAttrSet(Source).FItems) + SourceOffset)^,
              (PChar(FItems) + Offset)^, AttrSize);
            if DataEnd > NewCount then
              NewCount:=DataEnd;
          end
          else
            FillChar((PChar(FItems) + Offset)^, AttrSize, 0);
      end;
      { устанавливаем точный размер }
      Count:=NewCount;
    end;
  end
  else
    Error(SIncompatibleClasses);
end;

procedure TAttrSet.Clear;
begin
  FreeDynamic;
  inherited Clear;
end;

class function TAttrSet.Compare(AttrSet1, AttrSet2: Pointer): Integer;
begin
  Result:=TAttrSet(AttrSet1).CompareWith(TAttrSet(AttrSet2), 0);
end;

class function TAttrSet.CompareUser(AttrSet1, AttrSet2: Pointer): Integer;
begin
  Result:=TAttrSet(AttrSet1).CompareWithUser(TAttrSet(AttrSet2), 0);
end;

procedure TAttrSet.SetField(MapIndex: Integer; const VarRec: TVarRec);
var
  Offset: Integer;
  AType: TExtAttrType;
  P: Pointer;
  {$IFDEF CHECK_ATTRS} Correct: Bool; {$ENDIF}
begin
  Offset:=FMap.OffsetByIndex(MapIndex);
  AType:=FMap.AttrTypeByIndex(MapIndex);
  CheckSize(Offset, AType);
  P:=PChar(FItems) + Offset;
  {$IFDEF CHECK_ATTRS}
  Case VarRec.VType of
    vtInteger: Correct:=AType in [AttrInt8, AttrUInt8, AttrInt16, AttrUInt16,
      AttrInt32, AttrUInt32];
    vtBoolean: Correct:=AType = AttrBool;
    vtChar: Correct:=AType = AttrChar;
    vtExtended: Correct:=AType in [AttrFloat32, AttrFloat64, AttrFloat80];
    vtPointer, vtObject: Correct:=AType = AttrPointer;
  {$IFDEF WIN32}
    {$IFOPT H-}
    vtString: Correct:=AType = AttrString;
    {$ENDIF}
    {$IFOPT H+}
    vtAnsiString: Correct:=AType = AttrString;
    {$ENDIF}
    vtWideString: Correct:=AType = AttrWideString;
  {$ELSE}
    vtString: Correct:=AType = AttrString;
  {$ENDIF}
  Else
    Correct:=False;
  End;
  if not Correct then
    Error(SErrorInParameters);
  {$ENDIF}
  Case AType of
    AttrInt8, AttrUInt8, AttrBool, AttrChar: PInt8(P)^:=Int8(VarRec.VInteger);
    AttrInt16, AttrUInt16: PInt16(P)^:=Int16(VarRec.VInteger);
    AttrInt32, AttrUInt32, AttrFloat32, AttrPointer: PInt32(P)^:=Int32(VarRec.VPointer);
    AttrString: begin
      DisposeVStr(PPVString(P)^);
    {$IFDEF WIN32}
      {$IFOPT H+}
      PPVString(P)^:=NewVStr(String(PChar(VarRec.VAnsiString)));
      {$ELSE}
      PPVString(P)^:=NewVStr(VarRec.VString^);
      {$ENDIF}
    {$ELSE}
      PPVString(P)^:=NewVStr(VarRec.VString^);
    {$ENDIF}
    end;
    AttrFloat64: PFloat64(P)^:=VarRec.VExtended^;
    AttrFloat80: PFloat80(P)^:=VarRec.VExtended^;
    {$IFDEF V_WIDESTRINGS}
    AttrWideString: SetWide(P, WideString(PWideChar(VarRec.VWideString)));
    {$ENDIF}
  End;
end;

procedure TAttrSet.SetFields(const Fields: array of String;
  const Values: array of const);
var
  I: Integer;
begin
  {$IFDEF CHECK_ATTRS}
  if High(Fields) <> High(Values) then
    Error(SErrorInParameters);
  {$ENDIF}
  for I:=0 to High(Fields) do SetField(FMap.IndexOfAttr(Fields[I]), Values[I]);
end;

procedure TAttrSet.SetAllFields(const Values: array of const);
var
  I: Integer;
begin
  {$IFDEF CHECK_ATTRS}
  if High(Values) <> Map.Count - 1 then
    Error(SErrorInParameters);
  {$ENDIF}
  for I:=0 to High(Values) do SetField(I, Values[I]);
end;

function TAttrSet.SafeAttrType(const Name: String): TExtAttrType;
begin
  Result:=FMap.GetType(Name);
end;

function TAttrSet.GetType(const Name: String): TExtAttrType;
begin
  Result:=SafeAttrType(Name);
  if Result = AttrNone then
    ErrorFmt(SAttrNotDefined_s, [Name]);
end;

function TAttrSet.LoLevelCompare(AttrSet2: TAttrSet; AttrType: TExtAttrType;
  Ofs1, Ofs2: Integer; Params: Word): Int32;
var
  I1, I2: Int32;
  U1, U2: UInt32;
  T: Float80;
begin
  Result:=0;
  Case AttrType of
    AttrInt8:
      Result:=Int32(AsInt8ByOfs[Ofs1]) - Int32(AttrSet2.AsInt8ByOfs[Ofs2]);
    AttrUInt8, AttrBool, AttrChar:
      Result:=Int32(AsUInt8ByOfs[Ofs1]) - Int32(AttrSet2.AsUInt8ByOfs[Ofs2]);
    AttrInt16:
      Result:=Int32(AsInt16ByOfs[Ofs1]) - Int32(AttrSet2.AsInt16ByOfs[Ofs2]);
    AttrUInt16:
      Result:=Int32(AsUInt16ByOfs[Ofs1]) - Int32(AttrSet2.AsUInt16ByOfs[Ofs2]);
    AttrInt32: begin
      I1:=AsInt32ByOfs[Ofs1];
      I2:=AttrSet2.AsInt32ByOfs[Ofs2];
      if I1 > I2 then
        Result:=1
      else
        if I1 < I2 then
          Result:=-1;
    end;
    AttrUInt32, AttrPointer: begin
      U1:=AsUInt32ByOfs[Ofs1];
      U2:=AttrSet2.AsUInt32ByOfs[Ofs2];
      if U1 > U2 then
        Result:=1
      else
        if U1 < U2 then
          Result:=-1;
    end;
    AttrFloat32: begin
      T:=AsFloat32ByOfs[Ofs1] - AttrSet2.AsFloat32ByOfs[Ofs2];
      if T > 0 then
        Result:=1
      else
        if T < 0 then
          Result:=-1;
    end;
    AttrString:
      Result:=CmpStrF(AsStringByOfs[Ofs1], AttrSet2.AsStringByOfs[Ofs2], Params);
    AttrFloat64: begin
      T:=AsFloat64ByOfs[Ofs1] - AttrSet2.AsFloat64ByOfs[Ofs2];
      if T > 0 then
        Result:=1
      else
        if T < 0 then
          Result:=-1;
    end;
    AttrFloat80: begin
      T:=AsFloat80ByOfs[Ofs1] - AttrSet2.AsFloat80ByOfs[Ofs2];
      if T > 0 then
        Result:=1
      else
        if T < 0 then
          Result:=-1;
    end;
    {$IFDEF V_WIDESTRINGS}
    AttrWideString:
      if Params = 0 then
        {$IFNDEF LINUX}
        Result:=CompareTextWide(AsWideStringByOfs[Ofs1], AttrSet2.AsWideStringByOfs[Ofs2])
        {$ELSE}
        Result:=WideCompareText(AsWideStringByOfs[Ofs1], AttrSet2.AsWideStringByOfs[Ofs2])
        {$ENDIF}
      else
        {$IFNDEF LINUX}
        Result:=CompareStrWide(AsWideStringByOfs[Ofs1], AttrSet2.AsWideStringByOfs[Ofs2]);
        {$ELSE}
        Result:=WideCompareStr(AsWideStringByOfs[Ofs1], AttrSet2.AsWideStringByOfs[Ofs2]);
        {$ENDIF}
    {$ENDIF}
  End;
end;

function TAttrSet.DoCompareWith(AttrSet2: TAttrSet; Params: Word; SkipUser: Bool): Int32;
var
  Map2: TAttrMap;
  I, J, C1, C2: Integer;
  Ofs: Integer;
  B1, B2: Bool;
  S1, S2: String;
  AType: TAttrType;
begin
  Result:=0;
  if AttrSet2 <> Self then begin
    I:=0;
    C1:=FMap.Count;
    if SkipUser then
      while (I < C1) and (FMap.AttrName(I)[1] <= '.') do Inc(I);
    Map2:=AttrSet2.FMap;
    if FMap = Map2 then With FMap do
      for I:=0 to C1 - 1 do begin
        Ofs:=OffsetByIndex(I);
        Result:=LoLevelCompare(AttrSet2, AttrTypeByIndex(I), Ofs, Ofs, Params);
        if Result <> 0 then
          Break;
      end
    else begin
      J:=0;
      C2:=Map2.Count;
      if SkipUser then
        while (J < C2) and (Map2.AttrName(J)[1] <= '.') do Inc(J);
      repeat
        B1:=I >= C1;
        B2:=J >= C2;
        if B1 or B2 then begin
          if B1 <> B2 then
            if B1 then
              Result:=-1
            else
              Result:=1;
          Break;
        end;
        S1:=FMap.AttrName(I);
        S2:=Map2.AttrName(J);
        if S1 = S2 then begin
          AType:=FMap.AttrTypeByIndex(I);
          if TExtAttrType(AType) <> Map2.AttrTypeByIndex(J) then
            ErrorFmt(SWrongAttrType_s, [S1]);
          Result:=LoLevelCompare(AttrSet2, AType, FMap.OffsetByIndex(I),
            Map2.OffsetByIndex(J), Params);
          if Result <> 0 then
            Break;
        end
        else begin
          if S1 < S2 then
            Result:=-1
          else
            Result:=1;
          Break;
        end;
        Inc(I);
        Inc(J);
      until False;
    end;
  end;
end;

function TAttrSet.CompareWith(AttrSet2: TAttrSet; Params: Word): Int32;
begin
  Result:=DoCompareWith(AttrSet2, Params, False);
end;

function TAttrSet.CompareWithUser(AttrSet2: TAttrSet; Params: Word): Int32;
begin
  Result:=DoCompareWith(AttrSet2, Params, True);
end;

function TAttrSet.GetAsInt8(const Name: String): Int8;
begin
  GetData(Name, AttrInt8, Result);
end;

procedure TAttrSet.SetAsInt8(const Name: String; Value: Int8);
begin
  SetData(Name, AttrInt8, Value);
end;

function TAttrSet.GetAsUInt8(const Name: String): UInt8;
begin
  GetData(Name, AttrUInt8, Result);
end;

procedure TAttrSet.SetAsUInt8(const Name: String; Value: UInt8);
begin
  SetData(Name, AttrUInt8, Value);
end;

function TAttrSet.GetAsBool(const Name: String): Bool;
begin
  GetData(Name, AttrBool, Result);
end;

procedure TAttrSet.SetAsBool(const Name: String; Value: Bool);
begin
  SetData(Name, AttrBool, Value);
end;

function TAttrSet.GetAsChar(const Name: String): Char;
begin
  GetData(Name, AttrChar, Result);
end;

procedure TAttrSet.SetAsChar(const Name: String; Value: Char);
begin
  SetData(Name, AttrChar, Value);
end;

function TAttrSet.GetAsInt16(const Name: String): Int16;
begin
  GetData(Name, AttrInt16, Result);
end;

procedure TAttrSet.SetAsInt16(const Name: String; Value: Int16);
begin
  SetData(Name, AttrInt16, Value);
end;

function TAttrSet.GetAsUInt16(const Name: String): UInt16;
begin
  GetData(Name, AttrUInt16, Result);
end;

procedure TAttrSet.SetAsUInt16(const Name: String; Value: UInt16);
begin
  SetData(Name, AttrUInt16, Value);
end;

function TAttrSet.GetAsInt32(const Name: String): Int32;
begin
  GetData(Name, AttrInt32, Result);
end;

procedure TAttrSet.SetAsInt32(const Name: String; Value: Int32);
begin
  SetData(Name, AttrInt32, Value);
end;

function TAttrSet.GetAsUInt32(const Name: String): UInt32;
begin
  GetData(Name, AttrUInt32, Result);
end;

procedure TAttrSet.SetAsUInt32(const Name: String; Value: UInt32);
begin
  SetData(Name, AttrUInt32, Value);
end;

function TAttrSet.GetAsFloat32(const Name: String): Float32;
begin
  GetData(Name, AttrFloat32, Result);
end;

procedure TAttrSet.SetAsFloat32(const Name: String; Value: Float32);
begin
  SetData(Name, AttrFloat32, Value);
end;

function TAttrSet.GetAsFloat64(const Name: String): Float64;
begin
  GetData(Name, AttrFloat64, Result);
end;

procedure TAttrSet.SetAsFloat64(const Name: String; Value: Float64);
begin
  SetData(Name, AttrFloat64, Value);
end;

function TAttrSet.GetAsFloat80(const Name: String): Float80;
begin
  GetData(Name, AttrFloat80, Result);
end;

procedure TAttrSet.SetAsFloat80(const Name: String; Value: Float80);
begin
  SetData(Name, AttrFloat80, Value);
end;

function TAttrSet.GetAsPointer(const Name: String): Pointer;
begin
  GetData(Name, AttrPointer, Result);
end;

procedure TAttrSet.SetAsPointer(const Name: String; Value: Pointer);
begin
  SetData(Name, AttrPointer, Value);
end;

{$IFDEF CHECK_ATTRS}
function TAttrSet.GetAsAutoFree(const Name: String): Pointer;
begin
  GetData(Name, AttrAutoFree, Result);
end;

procedure TAttrSet.SetAsAutoFree(const Name: String; Value: Pointer);
begin
  SetData(Name, AttrAutoFree, Value);
end;
{$ENDIF}

function TAttrSet.GetAsString(const Name: String): String;
begin
  GetData(Name, AttrString, Result);
end;

procedure TAttrSet.SetAsString(const Name: String; const Value: String);
begin
  SetData(Name, AttrString, Value);
end;

{$IFDEF V_WIDESTRINGS}
function TAttrSet.GetAsWideString(const Name: String): WideString;
begin
  GetData(Name, AttrWideString, Result);
end;

procedure TAttrSet.SetAsWideString(const Name: String; const Value: WideString);
begin
  SetData(Name, AttrWideString, Value);
end;
{$ENDIF}

function TAttrSet.GetAsText(const Name: String): String;
var
  Offset: Integer;

  procedure ReturnInteger(I: {$IFNDEF V_D4}LongInt{$ELSE}Int64{$ENDIF});
  begin
    Str(I, Result);
  end;

begin
  Offset:=FMap.Offset(Name);
  if Offset < FCount then
    Case GetType(Name) of
      AttrBool: Result:=BoolStr[AsBoolByOfs[Offset]];
      AttrChar: Result:=CharToStr(AsCharByOfs[Offset]);
      AttrInt8: ReturnInteger(AsInt8ByOfs[Offset]);
      AttrUInt8: ReturnInteger(AsUInt8ByOfs[Offset]);
      AttrInt16: ReturnInteger(AsInt16ByOfs[Offset]);
      AttrUInt16: ReturnInteger(AsUInt16ByOfs[Offset]);
      AttrInt32: ReturnInteger(AsInt32ByOfs[Offset]);
      AttrUInt32: ReturnInteger(AsUInt32ByOfs[Offset]);
      AttrFloat32: Result:=RealToString(AsFloat32ByOfs[Offset], DefaultRealFormat);
      AttrString: Result:=AsStringByOfs[Offset];
      AttrFloat64: Result:=RealToString(AsFloat64ByOfs[Offset], DefaultRealFormat);
      AttrFloat80: Result:=RealToString(AsFloat80ByOfs[Offset], DefaultRealFormat);
      {$IFDEF V_WIDESTRINGS}
      AttrWideString: Result:=AsWideStringByOfs[Offset];
      {$ENDIF}
    Else
      Result:='';
    End
  else
    Result:='';
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
procedure TAttrSet.SetAsText(const Name, Value: String);
var
  Offset: Integer;
  B: Bool;
  C: Char;
  S: String;
begin
  Offset:=FMap.Offset(Name);
  Case GetType(Name) of
    AttrBool:
      begin
        S:=UpperCase(Trim(Value));
        if (S = 'TRUE') or (S = 'YES') or (S = 'Y') or (S = '1') or
          (S = 'ДА') or (S = 'Д')
        then
          B:=True
        else
          if (S = 'FALSE') or (S = 'NO') or (S = 'N') or (S = '0') or
            (S = 'НЕТ') or (S = 'Н')
          then
            B:=False
          else
            ErrorFmt(SWrongAttrType_s, [Name]);
        AsBoolByOfs[Offset]:=B;
      end;
    AttrChar:
      begin
        if Value <> '' then
          C:=StrToChar(Value)
        else
          C:=#0;
        AsCharByOfs[Offset]:=C;
      end;
    {$IFNDEF V_D4}
    AttrInt8: AsInt8ByOfs[Offset]:=StrToInt(Value);
    AttrUInt8: AsUInt8ByOfs[Offset]:=StrToInt(Value);
    AttrInt16: AsInt16ByOfs[Offset]:=StrToInt(Value);
    AttrUInt16: AsUInt16ByOfs[Offset]:=StrToInt(Value);
    AttrInt32: AsInt32ByOfs[Offset]:=StrToInt(Value);
    AttrUInt32: AsUInt32ByOfs[Offset]:=StrToInt(Value);
    {$ELSE}
    AttrInt8: AsInt8ByOfs[Offset]:=StrToInt64(Value);
    AttrUInt8: AsUInt8ByOfs[Offset]:=StrToInt64(Value);
    AttrInt16: AsInt16ByOfs[Offset]:=StrToInt64(Value);
    AttrUInt16: AsUInt16ByOfs[Offset]:=StrToInt64(Value);
    AttrInt32: AsInt32ByOfs[Offset]:=StrToInt64(Value);
    AttrUInt32: AsUInt32ByOfs[Offset]:=StrToInt64(Value);
    {$ENDIF}
    AttrFloat32: AsFloat32ByOfs[Offset]:=StringToReal(Value);
    AttrString: AsStringByOfs[Offset]:=Value;
    AttrFloat64: AsFloat64ByOfs[Offset]:=StringToReal(Value);
    AttrFloat80: AsFloat80ByOfs[Offset]:=StringToReal(Value);
    {$IFDEF V_WIDESTRINGS}
    AttrWideString: AsWideStringByOfs[Offset]:=Value;
    {$ENDIF}
  Else
    if Trim(Value) <> '' then
      ErrorFmt(SWrongAttrType_s, [Name]);
  End;
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

procedure TAttrSet.CheckSize(Offset: Integer; AType: TAttrType);
begin
  {$IFDEF CHECK_ATTRS}
  if Offset < 0 then
    ErrorFmt(SRangeError_d, [Offset]);
  {$ENDIF}
  Inc(Offset, AttrSizes[AType]);
  if FCount < Offset then
    Count:=Offset;
end;

function TAttrSet.GetAsInt8ByOfs(Ofs: Integer): Int8;
begin
  CheckSize(Ofs, AttrInt8);
  Result:=PInt8(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsInt8ByOfs(Ofs: Integer; Value: Int8);
begin
  CheckSize(Ofs, AttrInt8);
  PInt8(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsUInt8ByOfs(Ofs: Integer): UInt8;
begin
  CheckSize(Ofs, AttrUInt8);
  Result:=PUInt8(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsUInt8ByOfs(Ofs: Integer; Value: UInt8);
begin
  CheckSize(Ofs, AttrUInt8);
  PUInt8(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsBoolByOfs(Ofs: Integer): Bool;
begin
  CheckSize(Ofs, AttrBool);
  Result:=PBool(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsBoolByOfs(Ofs: Integer; Value: Bool);
begin
  CheckSize(Ofs, AttrBool);
  PBool(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsCharByOfs(Ofs: Integer): Char;
begin
  CheckSize(Ofs, AttrChar);
  Result:=PChar(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsCharByOfs(Ofs: Integer; Value: Char);
begin
  CheckSize(Ofs, AttrChar);
  PChar(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsInt16ByOfs(Ofs: Integer): Int16;
begin
  CheckSize(Ofs, AttrInt16);
  Result:=PInt16(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsInt16ByOfs(Ofs: Integer; Value: Int16);
begin
  CheckSize(Ofs, AttrInt16);
  PInt16(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsUInt16ByOfs(Ofs: Integer): UInt16;
begin
  CheckSize(Ofs, AttrUInt16);
  Result:=PUInt16(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsUInt16ByOfs(Ofs: Integer; Value: UInt16);
begin
  CheckSize(Ofs, AttrUInt16);
  PUInt16(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsInt32ByOfs(Ofs: Integer): Int32;
begin
  CheckSize(Ofs, AttrInt32);
  Result:=PInt32(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsInt32ByOfs(Ofs: Integer; Value: Int32);
begin
  CheckSize(Ofs, AttrInt32);
  PInt32(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsUInt32ByOfs(Ofs: Integer): UInt32;
begin
  CheckSize(Ofs, AttrUInt32);
  Result:=PUInt32(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsUInt32ByOfs(Ofs: Integer; Value: UInt32);
begin
  CheckSize(Ofs, AttrUInt32);
  PUInt32(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsFloat32ByOfs(Ofs: Integer): Float32;
begin
  CheckSize(Ofs, AttrFloat32);
  Result:=PFloat32(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsFloat32ByOfs(Ofs: Integer; Value: Float32);
begin
  CheckSize(Ofs, AttrFloat32);
  PFloat32(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsFloat64ByOfs(Ofs: Integer): Float64;
begin
  CheckSize(Ofs, AttrFloat64);
  Result:=PFloat64(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsFloat64ByOfs(Ofs: Integer; Value: Float64);
begin
  CheckSize(Ofs, AttrFloat64);
  PFloat64(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsFloat80ByOfs(Ofs: Integer): Float80;
begin
  CheckSize(Ofs, AttrFloat80);
  Result:=PFloat80(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsFloat80ByOfs(Ofs: Integer; Value: Float80);
begin
  CheckSize(Ofs, AttrFloat80);
  PFloat80(PChar(FItems) + Ofs)^:=Value;
end;

function TAttrSet.GetAsPointerByOfs(Ofs: Integer): Pointer;
begin
  CheckSize(Ofs, AttrPointer);
  Result:=PPointer(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsPointerByOfs(Ofs: Integer; Value: Pointer);
begin
  CheckSize(Ofs, AttrPointer);
  PPointer(PChar(FItems) + Ofs)^:=Value;
end;

{$IFDEF CHECK_ATTRS}
function TAttrSet.GetAsAutoFreeByOfs(Ofs: Integer): Pointer;
begin
  CheckSize(Ofs, AttrAutoFree);
  Result:=PPointer(PChar(FItems) + Ofs)^;
end;

procedure TAttrSet.SetAsAutoFreeByOfs(Ofs: Integer; Value: Pointer);
begin
  CheckSize(Ofs, AttrAutoFree);
  PPointer(PChar(FItems) + Ofs)^:=Value;
end;
{$ENDIF}

function TAttrSet.GetAsStringByOfs(Ofs: Integer): String;
var
  P: PPVString;
begin
  Result:='';
  if Ofs < FCount then begin
    CheckSize(Ofs, AttrString);
    P:=PPVString(PChar(FItems) + Ofs);
    if P^ <> nil then
      Result:=P^^;
  end;
end;

procedure TAttrSet.SetAsStringByOfs(Ofs: Integer; const Value: String);
var
  P: PPVString;
begin
  if (Ofs < FCount) or (Value <> '') then begin
    CheckSize(Ofs, AttrString);
    P:=PPVString(PChar(FItems) + Ofs);
    DisposeVStr(P^);
    P^:=NewVStr(Value);
  end;
end;

{$IFDEF V_WIDESTRINGS}
function TAttrSet.GetAsWideStringByOfs(Ofs: Integer): WideString;
begin
  Result:='';
  if Ofs < FCount then begin
    CheckSize(Ofs, AttrWideString);
    Result:=GetWide(PPointer(PChar(FItems) + Ofs));
  end;
end;

procedure TAttrSet.SetAsWideStringByOfs(Ofs: Integer; const Value: WideString);
begin
  if (Ofs < FCount) or (Value <> '') then begin
    CheckSize(Ofs, AttrWideString);
    SetWide(PPointer(PChar(FItems) + Ofs), Value);
  end;
end;
{$ENDIF}

procedure TAttrSet.ClearData(AType: TAttrType; var Data);
begin
  Case TExtAttrType(AType) of
    AttrInt8, AttrUInt8, AttrBool, AttrChar: Int8(Data):=0;
    AttrInt16, AttrUInt16: Int16(Data):=0;
    AttrInt32, AttrUInt32, AttrFloat32, AttrPointer, AttrAutoFree: Int32(Data):=0;
    AttrString: String(Data):='';
    AttrFloat64: Float64(Data):=0;
    AttrFloat80: Float80(Data):=0;
    {$IFDEF V_WIDESTRINGS}
    AttrWideString: WideString(Data):='';
    {$ENDIF}
  End;
end;

procedure TAttrSet.GetData(const Name: String; AType: TAttrType; var Data);
var
  Offset: Integer;
  P: Pointer;
begin
  {$IFDEF CHECK_ATTRS}
  if Ord(GetType(Name)) <> Ord(AType) then
    ErrorFmt(SWrongAttrType_s, [Name]);
  {$ENDIF}
  Offset:=FMap.Offset(Name);
  if Offset < FCount then begin
    P:=PChar(FItems) + Offset;
    Case TExtAttrType(AType) of
      AttrInt8, AttrUInt8, AttrBool, AttrChar: Int8(Data):=PInt8(P)^;
      AttrInt16, AttrUInt16: Int16(Data):=PInt16(P)^;
      AttrInt32, AttrUInt32, AttrFloat32, AttrPointer, AttrAutoFree:
        Int32(Data):=PInt32(P)^;
      AttrString:
        if PPVString(P)^ <> nil then
          String(Data):=PPVString(P)^^
        else
          String(Data):='';
      AttrFloat64: Float64(Data):=PFloat64(P)^;
      AttrFloat80: Float80(Data):=PFloat80(P)^;
      {$IFDEF V_WIDESTRINGS}
      AttrWideString: WideString(Data):=GetWide(P);
      {$ENDIF}
    End;
  end
  else
    ClearData(AType, Data);
end;

procedure TAttrSet.SetData(const Name: String; AType: TAttrType; const Data);
var
  Offset: Integer;
  P: Pointer;
begin
  {$IFDEF CHECK_ATTRS}
  if Ord(GetType(Name)) <> Ord(AType) then
    ErrorFmt(SWrongAttrType_s, [Name]);
  {$ENDIF}
  Offset:=FMap.Offset(Name);
  CheckSize(Offset, AType);
  P:=PChar(FItems) + Offset;
  Case TExtAttrType(AType) of
    AttrInt8, AttrUInt8, AttrBool, AttrChar: PInt8(P)^:=Int8(Data);
    AttrInt16, AttrUInt16: PInt16(P)^:=Int16(Data);
    AttrInt32, AttrUInt32, AttrFloat32, AttrPointer, AttrAutoFree: PInt32(P)^:=Int32(Data);
    AttrString: begin
      DisposeVStr(PPVString(P)^);
      PPVString(P)^:=NewVStr(String(Data));
    end;
    AttrFloat64: PFloat64(P)^:=Float64(Data);
    AttrFloat80: PFloat80(P)^:=Float80(Data);
    {$IFDEF V_WIDESTRINGS}
    AttrWideString: SetWide(P, WideString(Data));
    {$ENDIF}
  End;
end;

procedure TAttrSet.ClearField(const Name: String);
var
  I, Offset: Integer;
  P: Pointer;
  AType: TAttrType;
begin
  I:=FMap.IndexOfAttr(Name);
  Offset:=FMap.OffsetByIndex(I);
  AType:=FMap.AttrTypeByIndex(I);
  if FCount >= Offset + AttrSizes[AType] then begin
    P:=PChar(FItems) + Offset;
    Case TExtAttrType(AType) of
      AttrInt8, AttrUInt8, AttrBool, AttrChar:
        PInt8(P)^:=0;
      AttrInt16, AttrUInt16:
        PInt16(P)^:=0;
      AttrInt32, AttrUInt32, AttrFloat32, AttrPointer:
        PInt32(P)^:=0;
      AttrAutoFree: begin
        TObject(PPointer(P)^).Free;
        PInt32(P)^:=0;
      end;
      AttrString: begin
        DisposeVStr(PPVString(P)^);
        PPVString(P)^:=nil;
      end;
      AttrFloat64: PFloat64(P)^:=0;
      AttrFloat80: PFloat80(P)^:=0;
      {$IFDEF V_WIDESTRINGS}
      AttrWideString: SetWide(P, '');
      {$ENDIF}
    End;
  end;
end;

{ TAutoAttrSet }

constructor TAutoAttrSet.Create;
begin
  inherited Create(TAttrMap.Create);
end;

destructor TAutoAttrSet.Destroy;
var
  AMap: TAttrMap;
begin
  AMap:=FMap;
  inherited Destroy;
  AMap.Free;
end;

procedure TAutoAttrSet.WriteToStream(VStream: TVStream);
begin
  FMap.WriteToStream(VStream);
  inherited WriteToStream(VStream);
end;

procedure TAutoAttrSet.ReadFromStream(VStream: TVStream);
begin
  FMap.ReadFromStream(VStream);
  inherited ReadFromStream(VStream);
end;

procedure TAutoAttrSet.WriteToTextStream(TextStream: TTextStream);
begin
  FMap.WriteToTextStream(TextStream);
  inherited WriteToTextStream(TextStream);
end;

procedure TAutoAttrSet.ReadFromTextStream(TextStream: TTextStream);
begin
  FMap.ReadFromTextStream(TextStream);
  inherited ReadFromTextStream(TextStream);
end;

procedure TAutoAttrSet.Assign(Source: TVector);
begin
  if Source is TAttrSet then begin
    FMap.Assign(TAttrSet(Source).FMap);
    inherited Assign(Source);
  end
  else
    Error(SIncompatibleClasses);
end;

end.
