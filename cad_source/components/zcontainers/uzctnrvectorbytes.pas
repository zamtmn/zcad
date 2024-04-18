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
TSetOfChar = set of char;
{Export+}
PTZctnrVectorBytes=^TZctnrVectorBytes;
{REGISTEROBJECTTYPE TZctnrVectorBytes}
TZctnrVectorBytes=object(GZVector{-}<byte>{//})
                      ReadPos:Integer;
                      name:AnsiString;
                      constructor init(m:Integer);
                      constructor initnul;
                      constructor InitFromFile(FileName:Ansistring);
                      function AddByte(PData:Pointer):Integer;virtual;
                      function AddByteByVal(Data:Byte):Integer;virtual;
                      function AddWord(PData:Pointer):Integer;virtual;
                      //function AddFontFloat(PData:Pointer):Integer;virtual;
                      procedure TXTAddStringEOL(s:AnsiString);virtual;
                      procedure TXTAddString(s:AnsiString);virtual;
                      function ReadData(PData:Pointer;SData:Word):Integer;virtual;
                      //function PopData(PData:Pointer;SData:Word):Integer;virtual;
                      function ReadString3(break, ignore: TSetOfChar): AnsiString;inline;
                      function ReadString: AnsiString;inline;
                      function ReadString2:AnsiString;inline;
                      function GetCurrentReadAddres:Pointer;virtual;
                      function Jump(offset:Integer):Pointer;virtual;
                      function SaveToFile(FileName:Ansistring):Integer;
                      function ReadByte: Byte; inline;
                      function ReadWord: Word;
                      function GetChar(rp:integer): Ansichar; inline;
                      function Seek(pos:Integer):integer;
                      function notEOF:Boolean;
                      function readtoparser(break:AnsiString):AnsiString;
                      destructor done;virtual;
                   end;
{Export-}
procedure WriteString_EOL(h: Integer; s: AnsiString);
implementation
//uses uzbstrproc;
procedure WriteString_EOL(h: Integer; s: AnsiString);
begin
  s := s + lineend;
     //writeln(s);
  FileWrite(h, s[1], length(s));
end;
destructor TZctnrVectorBytes.done;
begin
     name:='';
     inherited;
end;

procedure TZctnrVectorBytes.TXTAddStringEOL;
begin
     s:=s+lineend;
     self.TXTAddString(s);
end;
procedure TZctnrVectorBytes.TXTAddString;
begin
     self.AddData(@s[1],length(s));
end;
function TZctnrVectorBytes.GetChar;
//var
//  p:PT;
begin
     {$PUSH}
     {$POINTERMATH ON}
     result:=pansichar(@parray[rp])^;
     {$POP}
     //result:=pansichar(PtrUInt(parray)+rp)^;
end;
function TZctnrVectorBytes.readtoparser;
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

function readspace(expr:String):String; inline;
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

function TZctnrVectorBytes.ReadString2;
begin
     result:=readspace(readString);
end;
function TZctnrVectorBytes.ReadString;
begin
     result:=ReadString3([#10],[#13]);
end;
function TZctnrVectorBytes.notEOF:Boolean;
begin
     result:=(readpos<(count-1))and(parray<>nil)
end;
function TZctnrVectorBytes.Jump;
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
function TZctnrVectorBytes.GetCurrentReadAddres;
//var
  //p:PT;
begin
     {$PUSH}
     {$POINTERMATH ON}
     result:=@parray[readpos];
     {$POP}
     //result:=pointer(PtrUInt(parray)+readpos);
end;
function TZctnrVectorBytes.readbyte;
//var
//  p:PT;
begin
     {$PUSH}
     {$POINTERMATH ON}
     result:=pbyte(@parray[readpos])^;
     {$POP}
     inc(readpos);
end;
function TZctnrVectorBytes.readword;
begin
     result:=readbyte;
     result:=result+256*readbyte;
end;
function TZctnrVectorBytes.readstring3{(break, ignore: String): shortString};
var
  //{s,}myresult: shortString;
  i:Integer;
  lastbreak:Boolean;
  addr:pansichar;
  strlen:integer;
  //p:PT;
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
  //s := '';
  strlen:=16;
  setlength(result,strlen);
  lastbreak:=false;
  i:=0;
  {$PUSH}
  {$POINTERMATH ON}
  addr:=pointer(@parray[readpos]);
  {$POP}
  //addr:=pointer(PtrUInt(parray)+readpos);
    while ReadPos <> count do
    begin
      if not (addr^ in break)(*or(({s=''}i=0)and(addr[0]=' '))*) then
      begin
        if not (addr^ in ignore) then
          begin
          //setlength(s,i);
          //s[i]:=bufer^[buferpos];
          //inc(i);
          if (({s<>''}i<>0)or(addr[0]<>' ')) then

          if (addr[0] in syn_breacer) then
                                                 begin
                                                      if not lastbreak then
                                                                           begin
                                                                                //s:=s+addr[0];
                                                                                inci;
                                                                                PChar(@result[i])^:=addr[0];
                                                                                lastbreak:=true;
                                                                           end;
                                                 end
                                             else
                                                 begin
                                                      //s:=s+addr[0];
                                                      inci;
                                                      PChar(@result[i])^:=addr[0];
                                                      lastbreak:=false;
                                                 end;

          end;
        inc(addr);
        inc(readpos);
      end
      else
      begin
        //myresult := s;
        setlength(result,i);
        //inc(addr);
        inc(readpos);
        //myresult := s;
        exit;
      end;
    end;
    setlength(result,i);
  //myresult := s;
end;
function TZctnrVectorBytes.Seek(pos:Integer):integer;
begin
     result:=self.ReadPos;
     readpos:=pos;
end;
constructor TZctnrVectorBytes.InitFromFile;
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
     fileclose(infile)
     end;
end;
function TZctnrVectorBytes.SaveToFile;
var infile:Integer;
begin
     infile:=filecreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}({ExpandPath}(FileName)));
     if infile>0 then
                     begin
                           FileWrite(InFile,parray^,count);
                           fileclose(infile);
                           result:=count;
                     end
                 else
                     result:=infile;
end;
constructor TZctnrVectorBytes.init;
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
function TZctnrVectorBytes.ReadData;
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
