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

unit uzctnrVectorBytesStream;

interface
uses gzctnrVector,sysutils{$IFNDEF DELPHI},LazUTF8{$ENDIF};
const
    syn_breacer=[#13,#10,' '];
    lineend:string=#13#10;
type
PTZctnrVectorBytes=^TZctnrVectorBytes;
TZctnrVectorBytes=object(GZVector{-}<byte>{//})
                      ReadPos:Integer;
                      name:AnsiString;
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
                      function ReadString3(break, ignore: AnsiString): AnsiString;inline;
                      function ReadString: AnsiString;inline;
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
                      procedure done;virtual;
                   end;
procedure WriteString_EOL(h: Integer; s: AnsiString);
implementation
//uses uzbstrproc;
procedure WriteString_EOL(h: Integer; s: AnsiString);
begin
  s := s + lineend;
     //writeln(s);
  FileWrite(h, s[1], length(s));
end;
procedure TZctnrVectorBytes.done;
begin
     name:='';
     inherited;
end;

procedure TZctnrVectorBytes.TXTAddStringEOL;
begin
     self.TXTAddString(s);
     self.TXTAddString(lineend);
end;
procedure TZctnrVectorBytes.TXTAddString;
begin
     self.AddData(@s[1],length(s));
end;
function TZctnrVectorBytes.GetChar;
var
  p:PT;
begin
     p:=@parray[0];
     inc(p,rp);
     result:=pansichar(p)^;
     //result:=pansichar(PtrUInt(parray)+rp)^;
end;
function TZctnrVectorBytes.readtoparser;
var
  s: String;
  s_len, s_pos: integer;
  scobcacount:Integer;
  mode:(parse,commenttoendline,commenttouncomment);
  lastbreak:Boolean;
  stringread:Boolean;

  procedure append_char(ch: AnsiChar); inline;
  const
    len_increment = 20;
  begin
    inc(s_pos);
    if s_pos>s_len then
    begin
      SetLength(s, s_len+len_increment);
      inc(s_len, len_increment)
    end;
    PByte(@s[s_pos])^:=Ord(ch);
  end;
  procedure append_string(const s_add: AnsiString); inline;
  var
    s_add_len: integer;
  begin
    s_add_len:=Length(s_add);

    if (s_pos+s_add_len)>s_len then
    begin
      SetLength(s, s_len+s_add_len);
      inc(s_len, s_add_len)
    end;

    Move(s_add[1], s[s_pos+1], s_add_len);

    inc(s_pos, s_add_len);
  end;
begin
  lastbreak:=false;
  scobcacount:=0;
  s:='';
  s_len:=0;
  s_pos:=0;
  //i:=1;
  mode:=parse;
  stringread:=false;
  begin
    while noteof do begin
      if (GetChar(readpos)='''')and(mode=parse) then begin
        stringread:=not stringread;
      end;
      if (GetChar(readpos)='{')and(mode=parse)and(not stringread) then begin
        mode:=commenttouncomment;
        inc(readpos);
      end
      else if (GetChar(readpos)='}')and(mode=commenttouncomment) then begin
        mode:=parse;
        append_char(' ');
        //s:= s+' ';
        lastbreak:=true;
        inc(readpos);
      end
      else if (GetChar(readpos)='/')and(mode=parse)and(GetChar(readpos+1)='/')and(not stringread) then begin
        if GetChar(readpos+1)='/'then begin
          mode:=commenttoendline;
          inc(readpos,2);
        end;
      end
      else if (GetChar(readpos)=#10)and(mode=commenttoendline) then begin
        mode:=parse;
        append_char(' ');
        //s:= s+' ';
        inc(readpos);
      end

      else if (mode=parse)and(pos(GetChar(readpos),break)=0) then
      begin
          //inc(i);
          if mode=parse then
          begin
               if GetChar(readpos)='(' then inc(scobcacount);
               if GetChar(readpos)=')' then dec(scobcacount);
                            if ((GetChar(readpos) in syn_breacer))and(not stringread) then
                                                 begin
                                                      if not lastbreak then
                                                                           append_char(' '); //s:=s+{bufer^[readpos]}' ';
                                                      lastbreak:=true;
                                                 end
                                             else
                                                 begin
                                                      append_char(GetChar(readpos));
                                                      //s:=s+GetChar(readpos);
                                                      lastbreak:=false;
                                                 end;
          end;
          inc(readpos);
          //inc(currentpos);
      end
      else if stringread then begin
        append_char(GetChar(readpos));
        //s:=s+GetChar(readpos);
        inc(readpos);
      end
      else
      begin
        if mode=parse then
                          begin
                               if GetChar(readpos)='(' then inc(scobcacount);
                               if GetChar(readpos)=')' then dec(scobcacount);
                               append_string(break);
                               //s:=s+break;
                               //result:=s;
                               inc(readpos);
                               //inc(currentpos);
                               {if readpos = buferread then
                                                           readtobufer;}
                               if scobcacount=0 then system.break;
//                                                else
//                                                     s:=s;
                          end
                      else inc(readpos);
      end;
    end;
    //readtobufer;
  end;
  //setlength(s,i-1);

  SetLength(s, s_pos);
  result := s;
end;
function readspace(const expr:String):String;
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
     result:=readspace(readString)
end;
function TZctnrVectorBytes.ReadString;
begin
     result:=ReadString3(#10,#13);
end;
function TZctnrVectorBytes.notEOF:Boolean;
begin
     result:=(readpos<(count))and(parray<>nil)
end;
function TZctnrVectorBytes.Jump;
var
  p:PT;
begin
     readpos:=readpos+offset;
     p:=@parray[0];
     inc(p,readpos);
     result:=p;
     //result:=pointer(PtrUInt(parray)+readpos);
end;
function TZctnrVectorBytes.GetCurrentReadAddres;
var
  p:PT;
begin
     p:=@parray[0];
     inc(p,readpos);
     result:=p;
     //result:=pointer(PtrUInt(parray)+readpos);
end;
function TZctnrVectorBytes.readbyte;
var
  p:PT;
begin
     p:=@parray[0];
     inc(p,readpos);
     result:=pbyte(p)^;
     //result:=pbyte(PtrUInt(parray)+readpos)^;
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
  myresult:ansistring;
  strlen:integer;
  p:PT;
procedure inci;
begin
 inc(i);
 if i>strlen then
                 begin
                   strlen:=strlen+255;
                   setlength(myresult,strlen);
                 end;
end;

begin
  //s := '';
  strlen:=255;
  setlength(myresult,strlen);
  lastbreak:=false;
  i:=0;
  p:=@parray[0];
  inc(p,readpos);
  addr:=pointer(p);
  //addr:=pointer(PtrUInt(parray)+readpos);
    while ReadPos <> count do
    begin
      if (pos(addr[0], break) = 0)or(({s=''}i=0)and(addr[0]=' ')) then
      begin
        if pos(addr[0], ignore) = 0 then
          begin
          //setlength(s,i);
          //s[i]:=bufer^[buferpos];
          //inc(i);
          if ({s<>''}i<>0)or(addr[0]<>' ') then

          if addr[0] in syn_breacer then
                                                 begin
                                                      if not lastbreak then
                                                                           begin
                                                                                //s:=s+addr[0];
                                                                                inci;
                                                                                myresult[i]:=addr[0];
                                                                           end;
                                                      lastbreak:=true;
                                                 end
                                             else
                                                 begin
                                                      //s:=s+addr[0];
                                                      inci;
                                                      myresult[i]:=addr[0];
                                                      lastbreak:=false;
                                                 end;

          end;
        inc(addr);
        inc(readpos);
      end
      else
      begin
        //myresult := s;
        setlength(myresult,i);
        result := myresult;
        //inc(addr);
        inc(readpos);
        //myresult := s;
        exit;
      end;
    end;
    setlength(myresult,i);
  //myresult := s;
  result := myresult;
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
var
  infile:Integer;
  fn,fp:RawByteString;
begin
  fn:={$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(FileName);
  fp:=ExtractFilePath(fn);
  if fp<>'' then
    ForceDirectories(ExtractFilePath(fn));
  infile:=filecreate(fn);
  if infile>0 then begin
    FileWrite(InFile,parray^,count);
    fileclose(infile);
    result:=count;
  end else
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
