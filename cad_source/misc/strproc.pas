{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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

unit strproc;
{$INCLUDE def.inc}

interface
uses zcadsysvars,{$IFNDEF DELPHI}fileutil,{$ENDIF}gdbasetypes,sysutils,sysinfo,strutils{$IFNDEF DELPHI},LCLProc{$ENDIF};
function GetPredStr(var s: GDBString; substr: GDBString): GDBString;
function ExpandPath(path:GDBString):GDBString;
function readspace(expr: GDBString): GDBString;

//function sys2interf(s:GDBString):GDBString;
function Tria_Utf8ToAnsi(const s:string):string;
function Tria_AnsiToUtf8(const s:string):string;

function Ansi2CP(astr:GDBAnsiString):GDBString;
function Uni2CP(astr:GDBAnsiString):GDBString;
function CP2Ansi(astr:GDBAnsiString):GDBString;
function CP2Uni(astr:GDBAnsiString):GDBString;

function uch2ach(uch:word):byte;
function ach2uch(ach:byte):word;

function CompareNUMSTR(str1,str2:GDBString):GDBBoolean;

function GetPartOfPath(out part:GDBString;var path:GDBString; const separator:GDBString):GDBString;
function FindInSupportPath(FileName:GDBString):GDBString;
function FindInPaths(Paths,FileName:GDBString):GDBString;

function ConvertFromDxfString(str:GDBString):GDBString;
function ConvertToDxfString(str:GDBString):GDBString;
function MakeHash(const s: GDBString): GDBLongword;

procedure KillString(var str:GDBString);inline;

type
  TCodePage=(CP_utf8,CP_win);

const
    syn_breacer=[#13,#10,' '];
    lineend:string=#13#10;
var
  CodePage:TCodePage;
implementation
uses
    {varmandef,}log;
procedure KillString(var str:GDBString);inline;
begin
     GDBPointer(str):=nil;
end;

function MakeHash(const s: GDBString): GDBLongword;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(s) do
    Result := ((Result shl 7) or (Result shr 25)) + Ord(s[I]);
end;

function ConvertFromDxfString(str:GDBString):GDBString;
begin
     result:=Tria_AnsiToUtf8(str);
     {$IFNDEF DELPHI}result:=StringsReplace(result, ['\P'],[LineEnding],[rfReplaceAll,rfIgnoreCase]);{$ENDIF}
end;

function ConvertToDxfString(str:GDBString):GDBString;
begin
     {$IFNDEF DELPHI}result:=StringsReplace(str, [LineEnding],['\P'],[rfReplaceAll,rfIgnoreCase]);{$ENDIF}
     result:=Tria_Utf8ToAnsi(result);
end;

function FindInSupportPath(FileName:GDBString):GDBString;
var
   s,ts:gdbstring;
begin
     log.programlog.LogOutStr({$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName),0);
     FileName:=ExpandPath(FileName);
     if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)) then
                                 begin
                                      result:=FileName;
                                      exit;
                                 end;
     {if gdb.GetCurrentDWG<>nil then
     begin
                                   s:=ExtractFilePath(gdb.GetCurrentDWG.FileName)+filename;
     if FileExists(s) then
                                 begin
                                      result:=s;
                                      exit;
                                 end;
     end;}
     if SysVar.PATH.Support_Path<>nil then
     begin
     s:=SysVar.PATH.Support_Path^;
     repeat
           GetPartOfPath(ts,s,'|');
           ts:=ExpandPath(ts)+FileName;
            if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)) then
                                 begin
                                      result:=ts;
                                      exit;
                                 end;
     until s='';
     end;
     result:='';
end;
function FindInPaths(Paths,FileName:GDBString):GDBString;
var
   s,ts:gdbstring;
begin
     FileName:=ExpandPath(FileName);
     if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)) then
                                 begin
                                      result:=FileName;
                                      exit;
                                 end;
     {if gdb.GetCurrentDWG<>nil then
     begin
                                   s:=ExtractFilePath(gdb.GetCurrentDWG.FileName)+filename;
     if FileExists(s) then
                                 begin
                                      result:=s;
                                      exit;
                                 end;
     end;}

     s:=Paths;
     repeat
           GetPartOfPath(ts,s,'|');
           ts:=ExpandPath(ts)+FileName;
            if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)) then
                                 begin
                                      result:=ts;
                                      exit;
                                 end;
     until s='';
     result:='';
end;
function GetPartOfPath(out part:GDBString;var path:GDBString;const separator:GDBString):GDBString;
var
   i:GDBInteger;
begin
           i:=pos(separator,path);
           if i<>0 then
                       begin
                            part:=copy(path,1,i-1);
                            path:=copy(path,i+1,length(path)-i);
                       end
                   else
                       begin
                            part:=path;
                            path:='';
                       end;
     result:=part;
end;
function uch2ach(uch:word):byte;
var s:gdbstring;
begin
     {$IFNDEF DELPHI}
     if uch=$412 then
                     uch:=uch;
     if uch=44064 then
                     uch:=uch;
     s:=UnicodeToUtf8(uch);
     if s='В' then
                  s:=s;
     s:={UTF8toANSI}Tria_Utf8ToAnsi(s);
     //if length(s)=1 then
                        result:=ord(s[1]);
     //               else
     //                   result:=0;
     //WideCharToMultiByte(CP_ACP,0,@uch, 1, @result, 1, nil, nil);
     if result=194 then
                     uch:=uch;
     {$ENDIF}
{$IFDEF TOTALYLOG}programlog.logoutstr(inttohex(uch,4)+'='+inttostr(result),0);{$ENDIF}

end;
function ach2uch(ach:byte):word;
var s:gdbstring;
    {$IFNDEF DELPHI}tstr:UTF16String;{$ENDIF}
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
function GetDigitCount(str1:GDBString):GDBInteger;
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
function CompareNUMSTR(str1,str2:GDBString):GDBBoolean;
var
   i1,i2{,i}:GDBInteger;
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
function readspace(expr: GDBString): GDBString;
var
  i: GDBInteger;
//  s:string;
begin
  //pointer(result):=nil;
  if expr='' then exit;

  i := 1;
  while not (expr[i] in ['{','}','a'..'z', 'A'..'Z', '0'..'9', '$', '(', ')', '+', '-', '*', '/', ':', '=','_', '''']) do
  begin
    if i = length(expr) then
      system.break;
    i := i + 1;
  end;
  if i>1 then
              i:=i;
  //programlog.LogOut(@expr[1],0);

  //expr:=expr;
  result := copy(expr, i, length(expr) - i + 1);
  //result :=s;// copy(expr, i, length(expr) - i + 1);
  //expr:=expr;
end;
function GetPredStr(var s: GDBString; substr: GDBString): GDBString;
var i{, c,a}: GDBInteger;
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
function ExpandPath(path:GDBString):GDBString;
begin
     if path='' then
                    result:=sysparam.programpath
else if path[1]='*' then
                    result:=sysparam.programpath+copy(path,2,length(path)-1)
else result:=path;
result:=StringReplace(result,'/', PathDelim,[rfReplaceAll, rfIgnoreCase]);
if DirectoryExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(result)) then
  if (result[length(result)]<>{'/'}PathDelim)
  //or (result[length(result)]<>'\')
  then
                                     result:=result+PathDelim;
end;
function Ansi2CP(astr:GDBAnsiString):GDBString;
begin
     case CodePage of
                     CP_utf8:result:=
                                     Tria_AnsiToUtf8(astr);
                     CP_win:result:=astr;
     end;
end;
function Uni2CP(astr:GDBAnsiString):GDBString;
begin
     case CodePage of
                     CP_utf8:result:=astr;
                     CP_win:result:=Tria_Utf8ToAnsi(astr);
     end;
end;
function CP2Ansi(astr:GDBAnsiString):GDBString;
begin
case CodePage of
                CP_utf8:result:=
                                Tria_Utf8ToAnsi(astr);
                CP_win:result:=astr;
end;
end;

function CP2Uni(astr:GDBAnsiString):GDBString;
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
(*function sys2interf(s:GDBString):GDBString;
begin
     result:=s//{systoutf8}{WinToK8R}Tria_AnsiToUtf8(s);
end;*)

begin
{$IFDEF DEBUGINITSECTION}log.LogOut('strproc.initialization');{$ENDIF}
CodePage:=CP_utf8;
end.
