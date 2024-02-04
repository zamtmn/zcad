{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzbstrproc;

interface
uses {$IFNDEF DELPHI}{fileutil,}{$ENDIF}uzbtypes,sysutils,strutils{$IFNDEF DELPHI},{LCLProc}LazUTF8,lazutf16{$ENDIF};
function GetPredStr(var s: String; substr: String): String;overload;
function GetPredStr(var s: String; substrs: array of const; out nearestsubstr:string): String;overload;
function readspace(expr: String): String;

//function sys2interf(s:String):String;
function Tria_Utf8ToAnsi(const s:string):string;
function Tria_AnsiToUtf8(const s:string):string;

function Ansi2CP(astr:AnsiString):String;
function Uni2CP(astr:AnsiString):String;
function CP2Ansi(astr:AnsiString):String;
function CP2Uni(astr:AnsiString):String;

function uch2ach(uch:word):byte;
function ach2uch(ach:byte):word;

function CompareNUMSTR(str1,str2:String):Boolean;
function AnsiNaturalCompare(const str1, str2: string; vCaseSensitive: boolean = False): integer;

function ConvertFromDxfString(str:TDXFEntsInternalStringType):String;
function ConvertToDxfString(str:String):TDXFEntsInternalStringType;
function MakeHash(const s: String):SizeUInt;//TODO в gzctnrSTL есть копия этой процедуры. надо убирать

procedure KillString(var str:String);inline;

Function PosWithBracket(c,OpenBracket,CloseBracket:AnsiChar;Const s:AnsiString;StartPos,InitCounterValue:SizeInt):SizeInt;
function isNotUtf8(const s:RawByteString):boolean;

type
  TCodePage=(CP_utf8,CP_win);

const
    syn_breacer=[#13,#10,' '];
    lineend:string=#13#10;
var
  CodePage:TCodePage;
implementation
//uses
//    log;
(*Function PosWithBracket(c : AnsiChar; Const s : {RawByteString}String) : SizeInt;
var
  i: SizeInt;
  pc : PAnsiChar;
  bracketcounter:SizeInt;
begin
  bracketcounter:=0;
  pc:=@s[1];
  for i:=1 to length(s) do
   begin
     if pc^='(' then
                   inc(bracketcounter)
else if pc^=')' then
                   dec(bracketcounter)
else if bracketcounter=0 then
     if pc^=c then
      begin
        exit(i);
      end;
     inc(pc);
   end;
  exit(0)
end;*)
Function PosWithBracket(c,OpenBracket,CloseBracket:AnsiChar;Const s:AnsiString;StartPos,InitCounterValue:SizeInt):SizeInt;
var
  i: SizeInt;
  pc : PAnsiChar;
begin
  pc:=@s[StartPos];
  for i:=StartPos to length(s) do begin
    if pc^={'('}OpenBracket then begin
      if OpenBracket<>CloseBracket then
        inc(InitCounterValue)
      else begin
        if InitCounterValue>0 then
          dec(InitCounterValue)
        else
          inc(InitCounterValue)
      end;
    end else if pc^={')'}CloseBracket then
      dec(InitCounterValue);
    if InitCounterValue=0 then
      if pc^=c then
        exit(i);
    inc(pc);
  end;
  result:=0;
end;
procedure KillString(var str:String);inline;
begin
     Pointer(str):=nil;
end;
function MakeHash(const s: String):SizeUInt;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(s) do
    Result := ((Result shl 7) or (Result shr 25)) + Ord(s[I]);
end;

function ConvertFromDxfString(str:TDXFEntsInternalStringType):String;
begin
     //result:=Tria_AnsiToUtf8(str);
     {$IFNDEF DELPHI}result:=UTF8Encode(StringsReplace(str, ['\P'],[LineEnding],[rfReplaceAll,rfIgnoreCase]));{$ENDIF}
end;

function ConvertToDxfString(str:String):TDXFEntsInternalStringType;
begin
     //{$IFNDEF DELPHI}result:=StringsReplace(str, [LineEnding],['\P'],[rfReplaceAll,rfIgnoreCase]);{$ENDIF}
     result:={Tria_Utf8ToAnsi}UTF8ToString(StringsReplace(str, [LineEnding],['\P'],[rfReplaceAll,rfIgnoreCase]));
end;
function uch2ach(uch:word):byte;
var s:String;
begin
     {$IFNDEF DELPHI}
//     if uch=$412 then
//                     uch:=uch;
//     if uch=44064 then
//                     uch:=uch;
     s:=UnicodeToUtf8(uch);
     s:={UTF8toANSI}Tria_Utf8ToAnsi(s);
     //if length(s)=1 then
                        result:=ord(s[1]);
     //               else
     //                   result:=0;
     //WideCharToMultiByte(CP_ACP,0,@uch, 1, @result, 1, nil, nil);
//     if result=194 then
//                     uch:=uch;
     {$ENDIF}
end;
function ach2uch(ach:byte):word;
var s:String;
    {$IFNDEF DELPHI}tstr:{UTF16String}TDXFEntsInternalStringType;{$ENDIF}
    CharLen: integer;
begin
    {$IFNDEF DELPHI}
     {if ach<127 then
                    begin
                    result:=ach;
                    exit;
                    end;}
     //s:=char(ach);
     s:=Tria_AnsiToUtf8(char(ach));
     tstr:=UTF8ToUTF16(s);
     result:=UTF16CharacterToUnicode(@tstr[1],CharLen);

     //if length(s)=1 then
     //                   result:=ord(s[1]);
     //               else
     //                   result:=0;
     //WideCharToMultiByte(CP_ACP,0,@uch, 1, @result, 1, nil, nil);
     //if result=194 then
     //                uch:=uch;
     {$ENDIF}
end;
function GetDigitCount(str1:String):Integer;
begin

     if str1='' then
                    begin
                         result:=0;
                         exit;
                    end;
     result:=1;
     if str1[result] in ['0'..'9'] then
                                   begin
                                        repeat
                                             inc(result)
                                        until (result>length(str1))or(not(str1[result] in ['0'..'9']));
                                        dec(result);
                                   end
                                   else
                                       result:=0;
end;
function AnsiNaturalCompare(const str1, str2: string; vCaseSensitive: boolean = False): integer;
//v3.5
//by engkin from here http://forum.lazarus.freepascal.org/index.php/topic,24450.0.html
var
  l1, l2, l: integer;       //Str length
  n1, n2: QWord{int64};     //numrical part
  nl: integer;
  nl1, nl2: integer;        //length of numrical part
  d: Smallint;//PtrInt;?
  pc : PChar;               //temp var
  pc1, pc2: PChar;
  pb1: PByte absolute pc1;  //to get pc1^ as a byte
  pb2: PByte absolute pc2;  //to get pc2^ as a byte
  pe1, pe2: PChar;          //pointer to end of str
  sign: integer;
  sum1, sum2: DWord;      //sum of non-numbers. More caps gives a smaller sum

  function lowcase(const c : char) : byte;
  begin
    if (c in ['A'..'Z']) then
      lowcase := byte(c)+32
    else
      lowcase := byte(c);
  end;

  (*function CorrectedResult(vRes: integer): integer; inline;
  begin
    //to correct the result when we switch vars due for
    //pc1, pe1 need to point at shorter string, always
    Result := sign * vRes;
  end;*)

begin
  l1 := Length(str1);
  l2 := Length(str2);

  //Any empty str?
  if (l1 = 0) and (l2 = 0) then exit(0);
  if (l1 = 0) then exit(-1);
  if (l2 = 0) then exit(1);

  //pc1, pe1 point at the shorter string, always
  if l1<=l2 then
  begin
    pc1 := @str1[1];
    pc2 := @str2[1];

    sign := 1;
  end
  else
  begin
    pc1 := @str2[1];
    pc2 := @str1[1];

    l := l1;
    l1 := l2;
    l2 := l;

    sign := -1;
  end;

  //end of strs
  pe1 := pc1 + l1;
  pe2 := pc2 + l2;

  sum1 := 0;
  sum2 := 0;

  nl1 := 0;
  nl2 := 0;

  while (pc1 < pe1) do
  begin
    if not (pc1^ in ['0'..'9']) or not (pc2^ in ['0'..'9']) then
    begin
      //Compare non-numbers
      if vCaseSensitive then
        d := pb1^ - pb2^
      else
        d := lowcase(pc1^) - lowcase(pc2^);//}

      if (d <> 0) then exit({CorrectedResult}(sign*d));
      sum1 := sum1 + pb1^;
      sum2 := sum2 + pb2^;
    end
    else
    begin
      //Convert a section of str1 to a number (correct for 16 digits)
      n1 := 0; nl1 := 0;
      repeat
        n1 := (n1 shl 4) or (pb1^ - Ord('0'));
        Inc(pb1); inc(nl1);
      until (pc1 >= pe1) or not (pc1^ in ['0'..'9']);

      //Convert a section of str2 to a number (correct for 16 digits)
      n2 := 0; nl2 := 0;
      repeat
        n2 := (n2 shl 4) or (pb2^ - Ord('0'));
        Inc(pb2); inc(nl2);
      until (pc2 >= pe2) or not (pc2^ in ['0'..'9']);

      //Compare numbers naturally
{      d := n1 - n2;
      if d <> 0 then
         exit(CorrectedResult(d))//}
      if n1>n2 then
        exit({CorrectedResult}(sign*1))
      else if n1<n2 then
        exit({CorrectedResult}(sign*-1))
      else
      begin
        //Switch to shortest string based of remaining characters
        if (pe1 - pc1) > (pe2 - pc2) then
        begin
          pc := pc1;
          pc1 := pc2;
          pc2 := pc;

          pc := pe1;
          pe1 := pe2;
          pe2 := pc;

          nl := nl1;
          nl1 := nl2;
          nl2 := nl;

          nl := sum1;
          sum1 := sum2;
          sum2 := nl;

          sign := -sign;
        end;
        Continue;
      end;
    end;
    Inc(pc1);
    Inc(pc2);
  end;
  //str with longer remaining part is bigger (abc1z>abc1)
  //Result := CorrectedResult((pe1 - pc1) - (pe2 - pc2));
  Result := (pe1 - pc1) - (pe2 - pc2);
  if Result=0 then
  begin
  //if strs are naturllay identical then:
  //consider str with longer last numerical section to be bigger (a01bc0001>a001bc1)
    Result := {CorrectedResult}(sign*(nl1-nl2));
    if Result = 0 then
    //if strs are naturllay identical and last numerical sections have same length then:
    //consider str with more capital letters smaller (aBc001d>aBC001D)
      Result := {CorrectedResult}(sign*(sum1-sum2));
  end
  else
    Result := {CorrectedResult}(sign*Result);
end;
function CompareNUMSTR(str1,str2:String):Boolean;
var
   i1,i2{,i}:Integer;
begin
     if (str1='')or(str2='') then
                                 result:=str1>str2
else
     begin
          i1:=GetDigitCount(str1);
          i2:=GetDigitCount(str2);
          if (i1=0)or(i2=0) then
                                result:=str1>str2
     else
          begin
               if i1<i2 then
                            str1:=dupestring('0',i2-i1)+str1
                        else
                            str2:=dupestring('0',i1-i2)+str2;
               result:=str1>str2
          end;
     end;
end;
function readspace(expr: String): String;
var
  i: Integer;
//  s:string;
begin
  //pointer(result):=nil;
  if expr='' then exit;

  i := 1;
  while not (expr[i] in ['@','{','}','a'..'z', 'A'..'Z', '0'..'9', '$', '(', ')', '+', '-', '*', '/', ':', '=','_', '''']) do
  begin
    if i = length(expr) then
      system.break;
    i := i + 1;
  end;
//  if i>1 then
//              i:=i;
  //programlog.LogOut(@expr[1],0);

  //expr:=expr;
  result := copy(expr, i, length(expr) - i + 1);
  //result :=s;// copy(expr, i, length(expr) - i + 1);
  //expr:=expr;
end;
function GetPredStr(var s: String; substr: String): String;
var i{, c,a}: Integer;
begin
  i:=pos(substr,s);
  if i<>0 then
             begin
                  result:=copy(s,1,i-1);
                  i:=i+length(substr);
                  s:=copy(s,i,length(s)-i+1);
             end
          else
             begin
                  result:=s;
                  s:='';
             end;
end;
function GetPredStr(var s: String; substrs: array of const; out nearestsubstr:string): String;
var i,current: Integer;
    substr:String;
    itstring:boolean;
    nearest: Integer;
procedure storecurrent;
begin
  nearest:=current;
  nearestsubstr:=substr;
end;
begin
  nearest:=Low(substrs)-1;
  nearestsubstr:='';
  for i:=Low(substrs) to High(substrs) do
  begin
    itstring:=true;
    case substrs[i].VType of
                   vtChar:substr:=substrs[i].VChar;
                 vtString:substr:=substrs[i].VString^;
             vtAnsiString:substr:=PAnsiString(substrs[i].VAnsiString)^;
          vtUnicodeString:substr:=PUnicodeString(substrs[i].VUnicodeString)^;
          else itstring:=False;
    end;
    if itstring then
    begin
      current:=pos(substr,s);
      if current>0 then
      begin
        if nearest=Low(substrs)-1 then begin
          storecurrent;
        end else begin
          if current<nearest then
            storecurrent;
        end;
      end;
    end;
  end;
  if nearest<>Low(substrs)-1 then //begin
  //if nearest<>0 then
             begin
                  result:=copy(s,1,nearest-1);
                  nearest:=nearest+length(nearestsubstr);
                  s:=copy(s,nearest,length(s)-nearest+1);
             end
          else
             begin
                  result:=s;
                  s:='';
             end;
  //end;
end;

function Ansi2CP(astr:AnsiString):String;
begin
     case CodePage of
                     CP_utf8:result:=
                                     Tria_AnsiToUtf8(astr);
                     CP_win:result:=astr;
     end;
end;
function Uni2CP(astr:AnsiString):String;
begin
     case CodePage of
                     CP_utf8:result:=astr;
                     CP_win:result:=Tria_Utf8ToAnsi(astr);
     end;
end;
function CP2Ansi(astr:AnsiString):String;
begin
case CodePage of
                CP_utf8:result:=
                                Tria_Utf8ToAnsi(astr);
                CP_win:result:=astr;
end;
end;

function CP2Uni(astr:AnsiString):String;
begin
case CodePage of
                CP_utf8:result:=astr;
                CP_win:result:=Tria_AnsiToUtf8(astr);
end;
end;

function Tria_Utf8ToAnsi(const s:string):string;
var i,n,j{, Len}:integer;
begin
  SetLength(Result,Length(s));
  j:=1; i:=1;
  While i<=Length(s) do begin
    Case s[i] of
    #1..#127://One byte and latin symbols
      begin
        Result[j]:=s[i];
      end;
    #194: begin
        Inc(i);
        Result[j]:=s[i];
      end;
    #208: begin
        Inc(i); //n:=ord(s[i]);
        Case s[i] of
        #129: Result[j]:=#168; //¨
        #130: Result[j]:=#128; //€
        #131: Result[j]:=#129; //
        #132: Result[j]:=#170; //ª
        #133: Result[j]:=#189; //½
        #134: Result[j]:=#178; //²
        #135: Result[j]:=#175; //¯
        #136: Result[j]:=#163; //£
        #137: Result[j]:=#138; //Š
        #138: Result[j]:=#140; //Œ
        #139: Result[j]:=#142; //Ž
        #140: Result[j]:=#141; //
        #142: Result[j]:=#161; //¡
        #143: Result[j]:=#143; //
        #144{$IFNDEF DELPHI}..#191{$ENDIF}:begin
          n:=ord(s[i]);
          Result[j]:=Char(n+48);//'À'..'ï'
                   end;
        end;
      end;
    #209: begin
        Inc(i);
        Case s[i] of
        #128..#143:begin
           n:=ord(s[i]);
           Result[j]:=Char(n+112);//'ð'..'ÿ'
                 end;
        #145: Result[j]:=#184;  //¸
        #146: Result[j]:=#144;  //
        #147: Result[j]:=#131;  //ƒ
        #148: Result[j]:=#186;  //º
        #149: Result[j]:=#190;  //¾
        #150: Result[j]:=#179;  //³
        #151: Result[j]:=#191;  //¿
        #152: Result[j]:=#188;  //¼
        #153: Result[j]:=#154;  //š
        #154: Result[j]:=#156;  //œ
        #155: Result[j]:=#158;  //ž
        #156: Result[j]:=#157;  //
        #158: Result[j]:=#162;  //¢
        #159: Result[j]:=#159;  //Ÿ
        end;
      end;
    #210: begin
        Inc(i);
        Case s[i] of
        #144: Result[j]:=#165;  //¥
        #145: Result[j]:=#180;  //´
        end;
      end;
    #226: begin
        Inc(i);
        Case s[i] of
        #128:begin
          Inc(i);
          Case s[i] of
          #147: Result[j]:=#150; //–
          #148: Result[j]:=#151; //—
          #152: Result[j]:=#145; //‘
          #153: Result[j]:=#146; //’
          #154: Result[j]:=#130; //‚
          #156: Result[j]:=#147; //“
          #157: Result[j]:=#148; //”
          #158: Result[j]:=#132; //„
          #160: Result[j]:=#134; //†
          #161: Result[j]:=#135; //‡
          #162: Result[j]:=#149; //•
          #166: Result[j]:=#133; //…
          #176: Result[j]:=#137; //‰
          #185: Result[j]:=#139; //‹
          #186: Result[j]:=#155; //›
          end;
            end;
        #130:begin
          Inc(i);
          Result[j]:=#136;//#172;  //ˆ
            end;
        #132:begin
          Inc(i);
          Case s[i] of
          #150: Result[j]:=#185; //¹
          #162: Result[j]:=#153; //™
          end;
            end;
         end;//Case
      end;
    end;
    Inc(j); Inc(i);
  end;//While

SetLength(Result,j-1);
end;
function Tria_AnsiToUtf8(const s:string):string;
var i,n,j{, Len}:integer;
begin
  SetLength(Result,Length(s)*3);
  j:=1;
  For i:=1 to Length(s) do begin
    n:=ord(s[i]);
    Case n of //One byte and russion symbols
    1..127:
      begin
        Result[j]:=s[i];
        Inc(j);
      end;
    128: begin Result[j]:=#208;  Inc(j); Result[j]:=#130;  Inc(j);  end; //€
    129: begin Result[j]:=#208;  Inc(j); Result[j]:=#131;  Inc(j);  end; //
    130: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#154;  Inc(j);  end; //‚
    131: begin Result[j]:=#209;  Inc(j); Result[j]:=#147;  Inc(j);  end; //ƒ
    132: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#158;  Inc(j);  end; //„
    133: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#166;  Inc(j);  end; //…
    134: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#160;  Inc(j);  end; //†
    135: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#161;  Inc(j);  end; //‡
    136: begin Result[j]:=#226;  Inc(j); Result[j]:=#130;  Inc(j); Result[j]:=#172;  Inc(j);  end; //ˆ
    137: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#176;  Inc(j);  end; //‰
    138: begin Result[j]:=#208;  Inc(j); Result[j]:=#137;  Inc(j);  end; //Š
    139: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#185;  Inc(j);  end; //‹
    140: begin Result[j]:=#208;  Inc(j); Result[j]:=#138;  Inc(j);  end; //Œ
    141: begin Result[j]:=#208;  Inc(j); Result[j]:=#140;  Inc(j);  end; //
    142: begin Result[j]:=#208;  Inc(j); Result[j]:=#139;  Inc(j);  end; //Ž
    143: begin Result[j]:=#208;  Inc(j); Result[j]:=#143;  Inc(j);  end; //
    144: begin Result[j]:=#209;  Inc(j); Result[j]:=#146;  Inc(j);  end; //
    145: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#152;  Inc(j);  end; //‘
    146: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#153;  Inc(j);  end; //’
    147: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#156;  Inc(j);  end; //“
    148: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#157;  Inc(j);  end; //”
    149: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#162;  Inc(j);  end; //•
    150: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#147;  Inc(j);  end; //–
    151: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#148;  Inc(j);  end; //—
    152: begin Result[j]:=#194;  Inc(j); Result[j]:=#152;  Inc(j);  end; //˜
    153: begin Result[j]:=#226;  Inc(j); Result[j]:=#132;  Inc(j); Result[j]:=#162;  Inc(j);  end; //™
    154: begin Result[j]:=#209;  Inc(j); Result[j]:=#153;  Inc(j);  end; //š
    155: begin Result[j]:=#226;  Inc(j); Result[j]:=#128;  Inc(j); Result[j]:=#186;  Inc(j);  end; //›
    156: begin Result[j]:=#209;  Inc(j); Result[j]:=#154;  Inc(j);  end; //œ
    157: begin Result[j]:=#209;  Inc(j); Result[j]:=#156;  Inc(j);  end; //
    158: begin Result[j]:=#209;  Inc(j); Result[j]:=#155;  Inc(j);  end; //ž
    159: begin Result[j]:=#209;  Inc(j); Result[j]:=#159;  Inc(j);  end; //Ÿ
    160: begin Result[j]:=#194;  Inc(j); Result[j]:=#160;  Inc(j);  end; //
    161: begin Result[j]:=#208;  Inc(j); Result[j]:=#142;  Inc(j);  end; //¡
    162: begin Result[j]:=#209;  Inc(j); Result[j]:=#158;  Inc(j);  end; //¢
    163: begin Result[j]:=#208;  Inc(j); Result[j]:=#136;  Inc(j);  end; //£
    164: begin Result[j]:=#194;  Inc(j); Result[j]:=#164;  Inc(j);  end; //¤
    165: begin Result[j]:=#210;  Inc(j); Result[j]:=#144;  Inc(j);  end; //¥
    166: begin Result[j]:=#194;  Inc(j); Result[j]:=#166;  Inc(j);  end; //¦
    167: begin Result[j]:=#194;  Inc(j); Result[j]:=#167;  Inc(j);  end; //§
    168: begin Result[j]:=#208;  Inc(j); Result[j]:=#129;  Inc(j);  end; //¨
    169: begin Result[j]:=#194;  Inc(j); Result[j]:=#169;  Inc(j);  end; //©
    170: begin Result[j]:=#208;  Inc(j); Result[j]:=#132;  Inc(j);  end; //ª
    171: begin Result[j]:=#194;  Inc(j); Result[j]:=#171;  Inc(j);  end; //«
    172: begin Result[j]:=#194;  Inc(j); Result[j]:=#172;  Inc(j);  end; //¬
    173: begin Result[j]:=#194;  Inc(j); Result[j]:=#173;  Inc(j);  end; //­
    174: begin Result[j]:=#194;  Inc(j); Result[j]:=#174;  Inc(j);  end; //®
    175: begin Result[j]:=#208;  Inc(j); Result[j]:=#135;  Inc(j);  end; //¯
    176: begin Result[j]:=#194;  Inc(j); Result[j]:=#176;  Inc(j);  end; //°
    177: begin Result[j]:=#194;  Inc(j); Result[j]:=#177;  Inc(j);  end; //±
    178: begin Result[j]:=#208;  Inc(j); Result[j]:=#134;  Inc(j);  end; //²
    179: begin Result[j]:=#209;  Inc(j); Result[j]:=#150;  Inc(j);  end; //³
    180: begin Result[j]:=#210;  Inc(j); Result[j]:=#145;  Inc(j);  end; //´
    181: begin Result[j]:=#194;  Inc(j); Result[j]:=#181;  Inc(j);  end; //µ
    182: begin Result[j]:=#194;  Inc(j); Result[j]:=#182;  Inc(j);  end; //¶
    183: begin Result[j]:=#194;  Inc(j); Result[j]:=#183;  Inc(j);  end; //·
    184: begin Result[j]:=#209;  Inc(j); Result[j]:=#145;  Inc(j);  end; //¸
    185: begin Result[j]:=#226;  Inc(j); Result[j]:=#132;  Inc(j); Result[j]:=#150;  Inc(j);  end; //¹
    186: begin Result[j]:=#209;  Inc(j); Result[j]:=#148;  Inc(j);  end; //º
    187: begin Result[j]:=#194;  Inc(j); Result[j]:=#187;  Inc(j);  end; //»
    188: begin Result[j]:=#209;  Inc(j); Result[j]:=#152;  Inc(j);  end; //¼
    189: begin Result[j]:=#208;  Inc(j); Result[j]:=#133;  Inc(j);  end; //½
    190: begin Result[j]:=#209;  Inc(j); Result[j]:=#149;  Inc(j);  end; //¾
    191: begin Result[j]:=#209;  Inc(j); Result[j]:=#151;  Inc(j);  end; //¿

    192..239://'À'..'ï'
      begin
        Result[j]:=#208;  Inc(j);
        Result[j]:=Char(n-48);  Inc(j);
      end;
    240..255://'ð'..'ÿ'
      begin
        Result[j]:=#209;  Inc(j);
        Result[j]:=Char(n-112);  Inc(j);
      end;
    end;//Case
  end;

SetLength(Result,j-1);
end;
function isNotUtf8(const s:RawByteString):boolean;
var i,n,j:integer;
begin
  i:=1;
  While i<=Length(s) do begin
    Case s[i] of
    #1..#127://One byte and latin symbols
      begin
        //Result[j]:=s[i];
      end;
    #194: begin
        Inc(i);
        //Result[j]:=s[i];
      end;
    #208: begin
        Inc(i); //n:=ord(s[i]);
        (*Case s[i] of
        #129: Result[j]:=#168; //¨
        #130: Result[j]:=#128; //€
        #131: Result[j]:=#129; //
        #132: Result[j]:=#170; //ª
        #133: Result[j]:=#189; //½
        #134: Result[j]:=#178; //²
        #135: Result[j]:=#175; //¯
        #136: Result[j]:=#163; //£
        #137: Result[j]:=#138; //Š
        #138: Result[j]:=#140; //Œ
        #139: Result[j]:=#142; //Ž
        #140: Result[j]:=#141; //
        #142: Result[j]:=#161; //¡
        #143: Result[j]:=#143; //
        #144{$IFNDEF DELPHI}..#191{$ENDIF}:begin
          n:=ord(s[i]);
          Result[j]:=Char(n+48);//'À'..'ï'
                   end;
        end;*)
      end;
    #209: begin
        Inc(i);
        (*Case s[i] of
        #128..#143:begin
           n:=ord(s[i]);
           Result[j]:=Char(n+112);//'ð'..'ÿ'
                 end;
        #145: Result[j]:=#184;  //¸
        #146: Result[j]:=#144;  //
        #147: Result[j]:=#131;  //ƒ
        #148: Result[j]:=#186;  //º
        #149: Result[j]:=#190;  //¾
        #150: Result[j]:=#179;  //³
        #151: Result[j]:=#191;  //¿
        #152: Result[j]:=#188;  //¼
        #153: Result[j]:=#154;  //š
        #154: Result[j]:=#156;  //œ
        #155: Result[j]:=#158;  //ž
        #156: Result[j]:=#157;  //
        #158: Result[j]:=#162;  //¢
        #159: Result[j]:=#159;  //Ÿ
        end;*)
      end;
    #210: begin
        Inc(i);
        (*Case s[i] of
        #144: Result[j]:=#165;  //¥
        #145: Result[j]:=#180;  //´
        end;*)
      end;
    #226: begin
        Inc(i);
        Case s[i] of
        #128:begin
          Inc(i);
          (*Case s[i] of
          #147: Result[j]:=#150; //–
          #148: Result[j]:=#151; //—
          #152: Result[j]:=#145; //‘
          #153: Result[j]:=#146; //’
          #154: Result[j]:=#130; //‚
          #156: Result[j]:=#147; //“
          #157: Result[j]:=#148; //”
          #158: Result[j]:=#132; //„
          #160: Result[j]:=#134; //†
          #161: Result[j]:=#135; //‡
          #162: Result[j]:=#149; //•
          #166: Result[j]:=#133; //…
          #176: Result[j]:=#137; //‰
          #185: Result[j]:=#139; //‹
          #186: Result[j]:=#155; //›
          end;*)
            end;
        #130:begin
          Inc(i);
          //Result[j]:=#136;//#172;  //ˆ
            end;
        #132:begin
          Inc(i);
          (*Case s[i] of
          #150: Result[j]:=#185; //¹
          #162: Result[j]:=#153; //™
          end;*)
            end;
         end;//Case
      end;
      else exit(true);
    end;
    Inc(j); Inc(i);
  end;//While
  result:=false;
end;

(*function sys2interf(s:String):String;
begin
     result:=s//{systoutf8}{WinToK8R}Tria_AnsiToUtf8(s);
end;*)

begin
CodePage:=CP_utf8;
end.
