program textparserprofile;
{$Codepage UTF8}
{$Mode delphi}
uses
  SysUtils,StrUtils,Math,uzetextpreprocessor,uzctextpreprocessordxfimpl,
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
  Result:=textformat(AData,SPFSources.GetFull,nil);
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
  VTestData:=DupeString('йцукqwer',1);
  TestResult:='';
  TestResult:=DoTest(@ZCADTextFormatTest,VTestData,'ZCADTextFormatTest(DupeString(''йцукqwer'',1000000))');
  TestResult:='';
  TestResult:=DoTest(@velecParseMText,VTestData,'velecParseMText(DupeString(''йцукqwer'',1000000))');

  VTestData:=DupeString('йцукqwer\U+0428',1);
  TestResult:='';
  TestResult:=DoTest(@ZCADTextFormatTest,VTestData,'ZCADTextFormatTest(DupeString(''йцукqwer\U+0428'',1000000))');
  TestResult:='';
  TestResult:=DoTest(@velecParseMText,VTestData,'velecParseMText(DupeString(''йцукqwer\U+0428'',1000000))');

  VTestData:=DupeString('\U+0428',1);
  TestResult:='';
  TestResult:=DoTest(@ZCADTextFormatTest,VTestData,'ZCADTextFormatTest(DupeString(''\U+0428'',1000000))');
  TestResult:='';
  TestResult:=DoTest(@velecParseMText,VTestData,'velecParseMText(DupeString(''\U+0428'',1000000))');
  VTestData:=DupeString('{\fCalibri|b1|i0|c204|p34;Ко\fCascadia Code|b0|i0|c204|p49;мму}\U+0442\U+0430\U+0446{\U+0438}\U+043E\U+043D{\fCalibri|b0|i1|c204|p34;ная стойка }\U+0421\U+04421',1);
  TestResult:='';
  TestResult:=DoTest(@ZCADTextFormatTest,VTestData,'МТЕКСТ:Коммутационная стойка');
  TestResult:='';
  TestResult:=DoTest(@velecParseMText,VTestData,'МТЕКСТ:Коммутационная стойка');

  readln;
end.



