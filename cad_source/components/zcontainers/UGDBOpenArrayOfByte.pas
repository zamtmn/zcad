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

unit UGDBOpenArrayOfByte;
{$INCLUDE def.inc}
interface
uses gzctnrvector,{uzbtypesbase,}uzbgeomtypes,sysutils,uzbtypes{$IFNDEF DELPHI},LazUTF8{$ENDIF};
const
     breacer=[#13,#10,' '];
  eol: AnsiString=#13 + #10;
type
{Export+}
PGDBOpenArrayOfByte=^GDBOpenArrayOfByte;
{REGISTEROBJECTTYPE GDBOpenArrayOfByte}
GDBOpenArrayOfByte=object(GZVector{-}<byte>{//})
                      ReadPos:Integer;
                      name:AnsiString;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:Integer);
                      constructor initnul;
                      constructor InitFromFile(FileName:Ansistring);
                      function AddByte(PData:Pointer):Integer;virtual;
                      function AddByteByVal(Data:Byte):Integer;virtual;
                      function AddWord(PData:Pointer):Integer;virtual;
                      function AddFontFloat(PData:Pointer):Integer;virtual;
                      procedure TXTAddGDBStringEOL(s:AnsiString);virtual;
                      procedure TXTAddGDBString(s:AnsiString);virtual;
                      function ReadData(PData:Pointer;SData:Word):Integer;virtual;
                      //function PopData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;
                      function ReadString(break, ignore: AnsiString): AnsiString;inline;
                      function ReadGDBString: AnsiString;inline;
                      function ReadString2:AnsiString;inline;
                      function GetCurrentReadAddres:Pointer;virtual;
                      function Jump(offset:Integer):Pointer;virtual;
                      function SaveToFile(FileName:Ansistring):Integer;
                      function ReadByte: Byte;
                      function ReadWord: Word;
                      function GetChar(rp:integer): Ansichar;
                      function Seek(pos:Integer):integer;
                      function notEOF:Boolean;
                      function readtoparser(break:AnsiString):AnsiString;
                      destructor done;virtual;
                   end;
{Export-}
procedure WriteString_EOL(h: Integer; s: AnsiString);
implementation
uses uzbstrproc;
procedure WriteString_EOL(h: Integer; s: AnsiString);
begin
  s := s + eol;
     //writeln(s);
  FileWrite(h, s[1], length(s));
end;
destructor GDBOpenArrayOfByte.done;
begin
     name:='';
     inherited;
end;

procedure GDBOpenArrayOfByte.TXTAddGDBStringEOL;
begin
     s:=s+eol;
     self.TXTAddGDBString(s);
end;
procedure GDBOpenArrayOfByte.TXTAddGDBString;
begin
     self.AddData(@s[1],length(s));
end;
function GDBOpenArrayOfByte.GetChar;
var
  p:PT;
begin
     p:=@parray[0];
     inc(p,rp);
     result:=pansichar(p)^;
     //result:=pansichar(GDBPlatformUInt(parray)+rp)^;
end;
function GDBOpenArrayOfByte.readtoparser;
var
  s: String;
  //i:GDBInteger;
  scobcacount:Integer;
  mode:(parse,commenttoendline,commenttouncomment);
  lastbreak:Boolean;
  stringread:Boolean;
begin
  lastbreak:=false;
  scobcacount:=0;
  s:='';
  //i:=1;
  mode:=parse;
  stringread:=false;
  begin
    while noteof do
    begin
      if (GetChar(readpos)='''')and(mode=parse) then
                                  begin
                                       stringread:=not stringread;
                                  end;
      if (GetChar(readpos)='{')and(mode=parse)and(not stringread) then
                                  begin
                                       mode:=commenttouncomment;
                                       inc(readpos);
                                  end
      else if (GetChar(readpos)='}')and(mode=commenttouncomment) then
                                  begin
                                       mode:=parse;
                                       s:= s+' ';
                                       lastbreak:=true;
                                       inc(readpos);
                                  end
      else if (GetChar(readpos)='/')and(mode=parse)and(GetChar(readpos+1)='/')and(not stringread) then
                                  begin
                                       //if readpos<>buferread-1 then
                                       begin
                                            if GetChar(readpos+1)='/'then
                                                                         begin
                                                                              mode:=commenttoendline;
                                                                              inc(readpos,2);
                                                                         end;
                                       end;
                                  end
      else if (GetChar(readpos)=#10)and(mode=commenttoendline) then
                                  begin
                                       mode:=parse;
                                       s:= s+' ';
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
                                                                           s:=s+{bufer^[readpos]}' ';
                                                      lastbreak:=true;
                                                 end
                                             else
                                                 begin
                                                      s:=s+GetChar(readpos);
                                                      lastbreak:=false;
                                                 end;
          end;
          inc(readpos);
          //inc(currentpos);
      end
      else
      begin
        if mode=parse then
                          begin
                               if GetChar(readpos)='(' then inc(scobcacount);
                               if GetChar(readpos)=')' then dec(scobcacount);
                               s:=s+break;
                               result:=s;
                               inc(readpos);
                               //inc(currentpos);
                               {if readpos = buferread then
                                                           readtobufer;}
                               if scobcacount=0 then exit
                                                else
                                                     s:=s;
                          end
                      else inc(readpos);
      end;
    end;
    //readtobufer;
  end;
  //setlength(s,i-1);
  result := s;
end;
function GDBOpenArrayOfByte.ReadString2;
begin
     result:=readspace(readGDBString)
end;
function GDBOpenArrayOfByte.ReadGDBString;
begin
     result:=ReadString(#10,#13);
end;
function GDBOpenArrayOfByte.notEOF:Boolean;
begin
     result:=(readpos<(count-1))and(parray<>nil)
end;
function GDBOpenArrayOfByte.Jump;
var
  p:PT;
begin
     readpos:=readpos+offset;
     p:=@parray[0];
     inc(p,readpos);
     result:=p;
     //result:=pointer(GDBPlatformUInt(parray)+readpos);
end;
function GDBOpenArrayOfByte.GetCurrentReadAddres;
var
  p:PT;
begin
     p:=@parray[0];
     inc(p,readpos);
     result:=p;
     //result:=pointer(GDBPlatformUInt(parray)+readpos);
end;
function GDBOpenArrayOfByte.readbyte;
var
  p:PT;
begin
     p:=@parray[0];
     inc(p,readpos);
     result:=pbyte(p)^;
     //result:=pbyte(GDBPlatformUInt(parray)+readpos)^;
     inc(readpos);
end;
function GDBOpenArrayOfByte.readword;
begin
     result:=readbyte;
     result:=result+256*readbyte;
end;
function GDBOpenArrayOfByte.readstring{(break, ignore: GDBString): shortString};
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
  //addr:=pointer(GDBPlatformUInt(parray)+readpos);
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

          if addr[0] in breacer then
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
function GDBOpenArrayOfByte.Seek(pos:Integer):integer;
begin
     result:=self.ReadPos;
     readpos:=pos;
end;
constructor GDBOpenArrayOfByte.InitFromFile;
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
     init({$IFDEF DEBUGBUILD}'{90D77E3A-2C96-44F8-BCE9-A981808F2486}',{$ENDIF}filelength);
     FileSeek(infile,0,0);
     if parray=nil then
                       CreateArray;
     FileRead(InFile,parray^,filelength);
     count:=filelength;
     fileclose(infile)
     end;
end;
function GDBOpenArrayOfByte.SaveToFile;
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
constructor GDBOpenArrayOfByte.init;
begin
  ReadPos:=0;
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,1});
end;
constructor GDBOpenArrayOfByte.initnul;
begin
  ReadPos:=0;
  //SizeOfData:=1;
  inherited initnul;
end;
function GDBOpenArrayOfByte.AddByteByVal(Data:Byte):Integer;
begin
     result:=adddata(@data,sizeof(Byte));
end;

function GDBOpenArrayOfByte.AddByte(PData:Pointer):Integer;
//var addr:GDBPlatformint;
begin
     result:=adddata(pdata,sizeof(Byte));
end;
function GDBOpenArrayOfByte.AddFontFloat(PData:Pointer):Integer;
//var addr:GDBPlatformint;
begin
     result:=adddata(pdata,sizeof(fontfloat));
end;
function GDBOpenArrayOfByte.AddWord(PData:Pointer):Integer;
begin
     result:=adddata(pdata,sizeof(Word));
end;
function GDBOpenArrayOfByte.ReadData;
{var addr:GDBPlatformint;
    p:pt;}
begin
  {if count = max then
                     begin
                          parray := enlargememblock(parray, SizeOfData * max, 2*SizeOfData * max);
                          max:=2*max;
                     end;}
  begin
       {GDBPointer(addr) := parray;
       addr := addr + ReadPos;}
       Move({GDBPointer(addr)^}parray^[ReadPos],PData^,SData);
       result:=count;
       inc(ReadPos,SData);
  end;
end;
{function GDBOpenArrayOfByte.PopData;
var addr:GDBPlatformint;
begin
  begin
       GDBPointer(addr) := parray;
       addr := addr + count-SData;
       Move(GDBPointer(addr)^,PData^,SData);
       result:=count;
       dec(count,SData);
  end;
end;}
begin
end.
