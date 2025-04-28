program textparserprofile;
{$Codepage UTF8}
{$Mode delphi}
uses
  SysUtils,StrUtils,Math,
  Interfaces,
  uzbtypes,
  uzetextpreprocessor,uzctextpreprocessorimpl,
  velecparser;

type
  TTestFunc=function(AData:TDXFEntsInternalStringType):TDXFEntsInternalStringType;

function CalcCheckCRC(AData:TDXFEntsInternalStringType):Word;
var
  uch:UnicodeChar;
begin
  result:=0;
  for uch in AData do
    result:=result+ord(uch);
end;

function ZCADTextFormatTest(AData:TDXFEntsInternalStringType):TDXFEntsInternalStringType;
begin
  Result:=textformat(AData,nil);
end;

function DoTest(ATestFunc:TTestFunc;AData:TDXFEntsInternalStringType;ATestName:string):TDXFEntsInternalStringType;
const
  maxsyms=20;//количество отображаемых символов результата
var
  LPTime:Tdatetime;
  l:integer;
begin
  //имя теста
  writeln(ATestName,':');
  LPTime:=now();
  Result:=ATestFunc(AData);
  LPTime:=now()-LPTime;
  //выводим первые maxsyms символов результата
  l:=min(maxsyms,Length(Result));
  writeln(format('  First result %d chars = %s',[l,copy(Result,1,l)]));
  //на случай если результат длинный его долину и CRC для проверки
  writeln('  Result length  = ',Length(Result));
  writeln('  Result CRC  = ',CalcCheckCRC(Result));
  //время теста
  writeln('  Time elapsed = '+inttostr(round(lptime*10e7))+'ms');
end;
var
  VTestData:TDXFEntsInternalStringType;
  TestResult:TDXFEntsInternalStringType;
begin
  VTestData:=DupeString('йцукqwer',1000000);
  TestResult:='';
  TestResult:=DoTest(@ZCADTextFormatTest,VTestData,'ZCADTextFormatTest(DupeString(''йцукqwer'',1000000))');
  TestResult:='';
  TestResult:=DoTest(@velecParseMText,VTestData,'velecParseMText(DupeString(''йцукqwer'',1000000))');
  readln;
end.



