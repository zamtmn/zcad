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

unit uzctnrVectorBytes;

interface
uses gzctnrVector,sysutils{$IFNDEF DELPHI},LazUTF8{$ENDIF};
const
    syn_breacer=[#13,#10,' '];
    lineend:string=#13#10;
type
//// TAnsiRec SOURCE: fpcsrc\rtl\inc\astrings.inc
PAnsiRec = ^TAnsiRec;
TAnsiRec = Record
  CodePage    : TSystemCodePage;
  ElementSize : Word;
{$if not defined(VER3_0) and not defined(VER3_2)}
{$ifdef CPU64}
  Ref         : Longint;
{$else}
  Ref         : SizeInt;
{$endif}
{$else}
{$ifdef CPU64}
  { align fields  }
      Dummy       : DWord;
{$endif CPU64}
  Ref         : SizeInt;
{$endif}
  Len         : SizeInt;
end;
//// end TAnsiRec

TSetOfChar = set of char;
{Export+}
PTZctnrVectorBytes=^TZctnrVectorBytes;
{REGISTEROBJECTTYPE TZctnrVectorBytes}

{ TZctnrVectorBytes }

TZctnrVectorBytes=object(GZVector{-}<byte>{//})
                      ReadPos:Integer;
                      name:AnsiString;
                      shortstr:ShortString;
                      constructor init(m:Integer);
                      constructor initnul;
                      constructor InitFromFile(const FileName:Ansistring);
                      function AddByte(PData:Pointer):Integer;virtual;
                      function AddByteByVal(Data:Byte):Integer;virtual;
                      function AddWord(PData:Pointer):Integer;virtual;
                      //function AddFontFloat(PData:Pointer):Integer;virtual;
                      procedure TXTAddStringEOL(const s:AnsiString);virtual;
                      procedure TXTAddString(const s:AnsiString);virtual;
                      function ReadData(PData:Pointer;SData:Word):Integer;virtual;
                      //function PopData(PData:Pointer;SData:Word):Integer;virtual;
                      function ReadString3(const break: TSetOfChar; ignore: TSetOfChar): AnsiString;inline;

                      function ReadString3New(const skipLeft: TSetOfChar; lineendings: TSetOfChar): AnsiString;inline;
                      function ReadString4Temp(const skipLeft: TSetOfChar; lineendings: TSetOfChar): AnsiString;inline;

                      function ReadPAnsiChar3(const skipLeft: TSetOfChar; lineendings: TSetOfChar): PAnsiChar;inline;
                      function ReadPShortString3(const skipLeft: TSetOfChar; lineendings: TSetOfChar): PShortString;inline;

                      function ReadString: AnsiString;inline;
                      function ReadStringTemp: AnsiString;inline;

                      function ParseInteger(out Value: Integer): Integer; inline; overload;
                      function ParseDouble(out Value: Double): Integer; inline; overload;
                      function ParseInteger: Integer; inline; overload;
                      function ParseDouble: Double; inline; overload;

                      function ReadPAnsiChar: PAnsiChar;inline;
                      function ReadPShortString: PShortString;inline;

                      function ReadString2:AnsiString;inline;
                      function GetCurrentReadAddres:Pointer;virtual;
                      function Jump(offset:Integer):Pointer;virtual;
                      function SaveToFile(const FileName:Ansistring):Integer;
                      function ReadByte: Byte; inline;
                      function ReadWord: Word;
                      function GetChar(rp:integer): Ansichar; inline;
                      function Seek(pos:Integer):integer;
                      function notEOF:Boolean;
                      function readtoparser(const break:AnsiString):AnsiString;
                      destructor done;virtual;
                   end;
{Export-}
procedure WriteString_EOL(h: Integer; const s: AnsiString);

var
  cnt1:Integer=0;
  cnt2:Integer=0;
  cnt3:Integer=0;

implementation
//uses uzbstrproc;
procedure WriteString_EOL(h: Integer; const s: AnsiString);
begin
  //s := s + lineend;
     //writeln(s);
  FileWrite(h, s[1], length(s));
  FileWrite(h, lineend[1], length(lineend));
end;
destructor TZctnrVectorBytes.done;
begin
     SetLength(name,0);
     inherited;
end;

procedure TZctnrVectorBytes.TXTAddStringEOL(const s: AnsiString);
begin
     //s:=s+lineend;
     //self.TXTAddString(s);
     self.AddData(@s[1],length(s));
     self.AddData(@lineend[1],length(lineend));
end;
procedure TZctnrVectorBytes.TXTAddString(const s: AnsiString);
begin
     self.AddData(@s[1],length(s));
end;
function TZctnrVectorBytes.GetChar(rp: integer): Ansichar;
//var
//  p:PT;
begin
     {$PUSH}
     {$POINTERMATH ON}
     result:=pansichar(@parray[rp])^;
     {$POP}
     //result:=pansichar(PtrUInt(parray)+rp)^;
end;
function TZctnrVectorBytes.readtoparser(const break: AnsiString): AnsiString;
var
  s: String;
  scobcacount:Integer;
  mode:(parse,commenttoendline,commenttouncomment);
  lastbreak:Boolean;
  stringread:Boolean;
  currchar: AnsiChar;
begin
  lastbreak:=false;
  scobcacount:=0;
  result:='';
  //i:=1;
  mode:=parse;
  stringread:=false;
  begin
    while noteof do begin
      currchar:=GetChar(readpos);
      if (currchar='''')and(mode=parse) then begin
        stringread:=not stringread;
      end;
      if (currchar='{')and(mode=parse)and(not stringread) then begin
        mode:=commenttouncomment;
        inc(readpos);
        currchar:=GetChar(readpos);
      end
      else if (currchar='}')and(mode=commenttouncomment) then begin
        mode:=parse;
        result:=result+' ';
        lastbreak:=true;
        inc(readpos);
        currchar:=GetChar(readpos);
      end
      else if (currchar='/')and(mode=parse)and(GetChar(readpos+1)='/')and(not stringread) then begin
          mode:=commenttoendline;
          inc(readpos,2);
          currchar:=GetChar(readpos);
      end
      else if (currchar=#10)and(mode=commenttoendline) then begin
        mode:=parse;
        result:=result+' ';
        inc(readpos);
        currchar:=GetChar(readpos);
      end
      else if (mode=parse)and(pos(currchar,break)=0) then
      begin
          //inc(i);
          if currchar='(' then inc(scobcacount)
          else if currchar=')' then dec(scobcacount);
          if ((currchar in syn_breacer))and(not stringread) then
                               begin
                                    if not lastbreak then
                                    begin
                                      result:=result+{bufer^[readpos]}' ';
                                      lastbreak:=true;
                                    end;
                               end
                           else
                               begin
                                    result:=result+currchar;
                                    lastbreak:=false;
                               end;
          inc(readpos);
          currchar:=GetChar(readpos);
          //inc(currentpos);
      end
      else if stringread then
      begin
        result:=result+currchar;
        inc(readpos);
        currchar:=GetChar(readpos);
      end
      else
      begin
        inc(readpos);
        if mode=parse then
                          begin
                               if currchar='(' then inc(scobcacount)
                               else if currchar=')' then dec(scobcacount);
                               //inc(currentpos);
                               {if readpos = buferread then
                                                           readtobufer;}
                               if scobcacount=0 then exit(result+break);
//                                                else
//                                                     s:=s;
                          end;
      end;
    end;
    //readtobufer;
  end;
end;

function readspace(const expr:String):String; inline;
var
  i:Integer;
begin
  if expr='' then exit;
  i := 1;
  while not (expr[i] in ['@','{','}','a'..'z', 'A'..'Z', '0'..'9', '$', '(', ')', '+', '-', '*', '/', ':', '=','_', '''']) do
  begin
    if i = length(expr) then
      system.break;
    i := i + 1;
  end;
//  if i>1 then
//    i:=i;
  result := copy(expr, i, length(expr) - i + 1);
end;

function TZctnrVectorBytes.ReadString2: AnsiString;
begin
     result:=readspace(readString);
end;
function TZctnrVectorBytes.ReadString: AnsiString;
begin
     result:=ReadString3New([' '],[#13,#10]);
     //result:=ReadString3([#10],[#13]);
end;
function TZctnrVectorBytes.ReadStringTemp: AnsiString;
begin
     result:=ReadString4Temp([' '],[#13,#10]);
end;
function TZctnrVectorBytes.ReadPAnsiChar: PAnsiChar;
begin
     result:=ReadPAnsiChar3([' '],[#13,#10]);
end;
function TZctnrVectorBytes.ReadPShortString: PShortString;
begin
     result:=ReadPShortString3([' '],[#13,#10]);
end;

function TZctnrVectorBytes.ParseInteger(out Value: Integer): Integer;
begin
  Val(ReadPShortString()^,Value,Result);
end;

function TZctnrVectorBytes.ParseDouble(out Value: Double): Integer;
begin
  Val(ReadPShortString()^,Value,Result);
end;

function TZctnrVectorBytes.ParseInteger: Integer;
begin
  ParseInteger(Result);
end;

function TZctnrVectorBytes.ParseDouble: Double;
begin
  ParseDouble(Result);
end;

function TZctnrVectorBytes.notEOF:Boolean;
begin
     result:=(readpos<(count-1))and(parray<>nil)
end;
function TZctnrVectorBytes.Jump(offset: Integer): Pointer;
//var
//  p:PT;
begin
     {$PUSH}
     {$POINTERMATH ON}
     readpos:=readpos+offset;
     result:=@parray[readpos];
     {$POP}
     //result:=pointer(PtrUInt(parray)+readpos);
end;
function TZctnrVectorBytes.GetCurrentReadAddres: Pointer;
//var
  //p:PT;
begin
     {$PUSH}
     {$POINTERMATH ON}
     result:=@parray[readpos];
     {$POP}
     //result:=pointer(PtrUInt(parray)+readpos);
end;
function TZctnrVectorBytes.ReadByte: Byte;
//var
//  p:PT;
begin
     {$PUSH}
     {$POINTERMATH ON}
     result:=pbyte(@parray[readpos])^;
     {$POP}
     inc(readpos);
end;
function TZctnrVectorBytes.ReadWord: Word;
begin
     result:=readbyte;
     result:=result+256*readbyte;
end;
function TZctnrVectorBytes.ReadString3(const break: TSetOfChar; ignore: TSetOfChar): AnsiString;
var
  i:SizeInt=0;
  strlen:SizeInt = 16;
  addr:pansichar;
  lastbreak:Boolean = false;
procedure inci; inline;
begin
 inc(i);
 if i>strlen then
                 begin
                   strlen:=strlen+255;
                   setlength(result,strlen);
                 end;
end;

begin
inc(cnt3);
  setlength(result,strlen);
  {$PUSH}
  {$POINTERMATH ON}
  addr:=pointer(@parray[readpos]);
  {$POP}

  while (i=0) and not (addr^ in break) and (ReadPos <> count) do
  begin
    if not (addr^ in ignore) and (addr^<>' ') then
    begin
      if (addr^ in syn_breacer) then
      begin
           if not lastbreak then
                                begin
                                     inci;
                                     PChar(@result[i])^:=addr^;
                                     lastbreak:=true;
                                end;
      end
      else
      begin
           inci;
           PChar(@result[i])^:=addr^;
           lastbreak:=false;
      end;
    end;
    inc(addr);
    inc(readpos);
  end;

  while not (addr^ in break) and (ReadPos <> count) do
  begin
    if not (addr^ in ignore) then
    begin
      if (addr^ in syn_breacer) then
      begin
           if not lastbreak then
                                begin
                                     inci;
                                     PChar(@result[i])^:=addr^;
                                     lastbreak:=true;
                                end;
      end
      else
      begin
           inci;
           PChar(@result[i])^:=addr^;
           lastbreak:=false;
      end;
    end;
    inc(addr);
    inc(readpos);
  end;

  inc(readpos);
  setlength(result,i);
end;

function TZctnrVectorBytes.ReadString3New(const skipLeft: TSetOfChar; lineendings: TSetOfChar): AnsiString;
var
  i: SizeInt=0;
  strlen: SizeInt = 16;
  addr, start_addr, last_ptr: PAnsiChar;
begin
 inc(cnt2);
  {$PUSH}
  {$POINTERMATH ON}
  addr:=@parray[readpos];
  last_ptr:=@parray[count];
  {$POP}
  start_addr:=addr;

  SetLength(result, strlen);

  while (addr < last_ptr) and (addr^ in skipLeft) do inc(addr);
  while (addr < last_ptr) and not (addr^ in lineendings) do
  begin
    inc(i);
    if i>strlen then
    begin
      strlen:=strlen+255;
      SetLength(result,strlen);
    end;
    PChar(@result[i])^:=addr^;
    inc(addr);
  end;
  while (addr < last_ptr) and (addr^ in lineendings) do
  begin
    Exclude(lineendings, addr^);
    inc(addr);
  end;
  SetLength(Result, i);
  inc(readpos, addr-start_addr);
end;

var
  need_copy_cnt: integer=0;

function TZctnrVectorBytes.ReadString4Temp(const skipLeft: TSetOfChar; lineendings: TSetOfChar): AnsiString;
var
  i: SizeInt=0;
  strlen: SizeInt = 16;
  addr, start_addr, last_ptr: PAnsiChar;
  data_addr: PAnsiChar;
  need_copy: Boolean;
begin
(*
Использовать нужно осторожно - т.к. заголовок AnsiString весит 24 байта и уже не помещается в
символы перевода строки - поэтому может быть такая ситуация, когда происходит чтение строки
эта строка хранится в указателе, потом происходит вложенный вызов другой ф-ии, которая тоже читает
строку, возвращает управление в вызвавшую ф-ю, а в ней по ранее хранившемуся указателю на строку уже
поломанные данные т.к. эти две считанные строки были рядом
-> что теперь эта строка становится невалидной и если будет её использование - будет крах
в общем это нужно учитывать в ф-ях, которые вызывают другие ф-ии тоже читающие строки
и при этом если в вызывающей ф-ии планируется затем использовать объявленную строку
*)
 inc(cnt1);
  {$PUSH}
  {$POINTERMATH ON}
  addr:=@parray[readpos];
  last_ptr:=@parray[count];
  {$POP}
  start_addr:=addr;

  while (addr < last_ptr) and (addr^ in skipLeft) do inc(addr);
  data_addr:=addr;

  need_copy:=((data_addr-sizeof(TAnsiRec))<PAnsiChar(PArray));
  if need_copy then
  begin
    inc(need_copy_cnt);
    SetLength(result, strlen);
    while (addr < last_ptr) and not (addr^ in lineendings) do
    begin
      inc(i);
      if i>strlen then
      begin
        strlen:=strlen+255;
        SetLength(result,strlen);
      end;
      PChar(@result[i])^:=addr^;
      inc(addr);
    end;
  end else
  begin
    while (addr < last_ptr) and not (addr^ in lineendings) do inc(addr);
    strlen:=addr-PAnsiChar(data_addr);
  end;

  while (addr < last_ptr) and (addr^ in lineendings) do
  begin
    Exclude(lineendings, addr^);
    inc(addr);
  end;

  if need_copy then
  begin
    SetLength(Result, i);
  end else
  begin
    if strlen=0 then
    begin
      Result:='';
    end else
    begin
      PSizeInt(Result):=PSizeInt(data_addr); // prevent FPC_ANSISTR_ASSIGN call
      with PAnsiRec(@PByte(Result)[-sizeof(TAnsiRec)])^ do
      begin
        CodePage:=CP_ACP;
        ElementSize:=1;
        Ref:=-1; // const ansistring
        Len:=strlen;
      end;
      PByte(Result)[strlen]:=0; // prevent FPC_ANSISTR_UNIQUE call
    end;
  end;
  inc(readpos, addr-start_addr);
end;

function TZctnrVectorBytes.ReadPShortString3(const skipLeft: TSetOfChar; lineendings: TSetOfChar): PShortString;
var
  addr, start_addr, last_ptr: PAnsiChar;
  len: byte;
  tmp_readpos:Integer;
begin
  {$PUSH}
  {$POINTERMATH ON}
  addr:=@parray[readpos];
  last_ptr:=@parray[count];
  {$POP}
  start_addr:=addr;

  while (addr < last_ptr) and (addr^ in skipLeft) do inc(addr);
  Result:=PShortString(@PByte(addr)[-1]);
  while (addr < last_ptr) and not (addr^ in lineendings) do inc(addr);
  len:=addr-PAnsiChar(Result)-1;
  while (addr < last_ptr) and (addr^ in lineendings) do
  begin
    Exclude(lineendings, addr^);
    inc(addr);
  end;
  inc(readpos, addr-start_addr);
  if Result<PShortString(PArray) then begin
    Move(Result^[1], shortstr[1], len);
    Result:=@shortstr;
  end;
  PByte(Result)^:=len;
end;

function TZctnrVectorBytes.ReadPAnsiChar3(const skipLeft: TSetOfChar; lineendings: TSetOfChar): PAnsiChar;
var
  addr, start_addr, last_ptr, null_addr: PAnsiChar;
begin
  {$PUSH}
  {$POINTERMATH ON}
  addr:=@parray[readpos];
  last_ptr:=@parray[count];
  {$POP}
  start_addr:=addr;

  while (addr^ in skipLeft) and (addr < last_ptr) do inc(addr);
  Result:=addr;
  while not (addr^ in lineendings) and (addr < last_ptr) do inc(addr);
  null_addr:=addr;
  while (addr^ in lineendings) and (addr < last_ptr) do
  begin
    Exclude(lineendings, addr^);
    inc(addr);
  end;
  null_addr^:=#0;
  inc(readpos, addr-start_addr);
end;

function TZctnrVectorBytes.Seek(pos:Integer):integer;
begin
     result:=self.ReadPos;
     readpos:=pos;
end;
constructor TZctnrVectorBytes.InitFromFile(const FileName: Ansistring);
var infile,filelength:Integer;
begin
     //StringToWideChar(filename)
     initnul;
     infile:=fileopen({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(FileName),fmShareDenyNone);
     if infile<=0 then
                      //ShowError(sysutils.format(rsUnableToOpenFile,[FileName]))
     else
     begin
     pointer(name):=nil;
     name:=filename;
     filelength:=FileSeek(infile,0,2);
     init(filelength);
     FileSeek(infile,0,0);
     if parray=nil then
                       CreateArray;
     FileRead(InFile,parray^,filelength);
     count:=filelength;
     fileclose(infile);
     end;
end;
function TZctnrVectorBytes.SaveToFile(const FileName: Ansistring): Integer;
var infile:Integer;
begin
     infile:=filecreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}({ExpandPath}(FileName)));
     if infile>0 then
                     begin
                           FileWrite(InFile,PArray^,count);
                           fileclose(infile);
                           result:=count;
                     end
                 else
                     result:=infile;
end;
constructor TZctnrVectorBytes.init(m: Integer);
begin
  ReadPos:=0;
  inherited init(m);
end;
constructor TZctnrVectorBytes.initnul;
begin
  ReadPos:=0;
  //SizeOfData:=1;
  inherited initnul;
end;
function TZctnrVectorBytes.AddByteByVal(Data:Byte):Integer;
begin
     result:=adddata(@data,sizeof(Byte));
end;

function TZctnrVectorBytes.AddByte(PData:Pointer):Integer;
//var addr:PtrInt;
begin
     result:=adddata(pdata,sizeof(Byte));
end;
{function TZctnrVectorBytes.AddFontFloat(PData:Pointer):Integer;
//var addr:PtrInt;
begin
     result:=adddata(pdata,sizeof(fontfloat));
end;}
function TZctnrVectorBytes.AddWord(PData:Pointer):Integer;
begin
     result:=adddata(pdata,sizeof(Word));
end;
function TZctnrVectorBytes.ReadData(PData: Pointer; SData: Word): Integer;
{var addr:PtrInt;
    p:pt;}
begin
  {if count = max then
                     begin
                          parray := enlargememblock(parray, SizeOfData * max, 2*SizeOfData * max);
                          max:=2*max;
                     end;}
  begin
       {Pointer(addr) := parray;
       addr := addr + ReadPos;}
       Move({Pointer(addr)^}parray^[ReadPos],PData^,SData);
       result:=count;
       inc(ReadPos,SData);
  end;
end;
{function TZctnrVectorBytes.PopData;
var addr:PtrInt;
begin
  begin
       Pointer(addr) := parray;
       addr := addr + count-SData;
       Move(Pointer(addr)^,PData^,SData);
       result:=count;
       dec(count,SData);
  end;
end;}
begin
end.
