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
uses gdbasetypes,sysutils,UGDBOpenArray,memman,gdbase{,strmy};
const
     breacer=[#13,#10,' '];
  eol: GDBString=#13 + #10;
type
{Export+}
PGDBOpenArrayOfByte=^GDBOpenArrayOfByte;
GDBOpenArrayOfByte=object(GDBOpenArray)
                      ReadPos:GDBInteger;
                      name:GDBString;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      constructor InitFromFile(FileName:string);
                      function AddData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;
                      procedure TXTAddGDBStringEOL(s:GDBString);virtual;
                      procedure TXTAddGDBString(s:GDBString);virtual;
                      function AllocData(SData:GDBword):GDBPointer;virtual;
                      function ReadData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;
                      function PopData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;
                      function ReadString(break, ignore: GDBString): shortString;
                      function ReadGDBString: shortString;
                      function ReadString2:GDBString;
                      function GetCurrentReadAddres:GDBPointer;virtual;
                      function Jump(offset:GDBInteger):GDBPointer;virtual;
                      function SaveToFile(FileName:string):GDBInteger;
                      function ReadByte: GDBByte;
                      function ReadWord: GDBWord;
                      function GetChar(rp:integer): Ansichar;
                      function Seek(pos:GDBInteger):integer;
                      function notEOF:GDBBoolean;
                      function readtoparser(break:GDBString): GDBString;
                   end;
{Export-}
procedure WriteString_EOL(h: GDBInteger; s: GDBString);
implementation
uses strproc,log;
procedure WriteString_EOL(h: GDBInteger; s: GDBString);
begin
  s := s + eol;
     //writeln(s);
  FileWrite(h, s[1], length(s));
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
begin
     result:=pansichar(cardinal(parray)+rp)^;
end;
function GDBOpenArrayOfByte.readtoparser;
var
  s: String;
  //i:GDBInteger;
  scobcacount:GDBInteger;
  mode:(parse,commenttoendline,commenttouncomment);
  lastbreak:GDBBoolean;
begin
  lastbreak:=false;
  scobcacount:=0;
  s:='';
  //i:=1;
  mode:=parse;
  begin
    while noteof do
    begin
      if (GetChar(readpos)='{')and(mode=parse) then
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
      else if (GetChar(readpos)='/')and(mode=parse)and(GetChar(readpos+1)='/') then
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
                            if GetChar(readpos) in syn_breacer then
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
     result:=ReadString(#13,#10);
end;
function GDBOpenArrayOfByte.notEOF:GDBBoolean;
begin
     result:=readpos<(count-1)
end;
function GDBOpenArrayOfByte.Jump;
begin
     readpos:=readpos+offset;
     result:=pointer(cardinal(parray)+readpos);
end;
function GDBOpenArrayOfByte.GetCurrentReadAddres;
begin
     result:=pointer(cardinal(parray)+readpos);
end;
function GDBOpenArrayOfByte.readbyte;
begin
     result:=pbyte(cardinal(parray)+readpos)^;
     inc(readpos);
end;
function GDBOpenArrayOfByte.readword;
begin
     result:=readbyte+256*readbyte;
end;
function GDBOpenArrayOfByte.readstring(break, ignore: GDBString): shortString;
var
  s: {short}GDBString;
  //i:GDBInteger;
  lastbreak:GDBBoolean;
  addr:pansichar;
begin
  s := '';
  lastbreak:=false;
  //i:=1;
  addr:=pointer(cardinal(parray)+readpos);
    while ReadPos <> count do
    begin
      if (pos(addr[0], break) = 0)or((s='')and(addr[0]=' ')) then
      begin
        if pos(addr[0], ignore) = 0 then
          begin
          //setlength(s,i);
          //s[i]:=bufer^[buferpos];
          //inc(i);
          if (s<>'')or(addr[0]<>' ') then

          if addr[0] in breacer then
                                                 begin
                                                      if not lastbreak then
                                                                           s:=s+addr[0];
                                                      lastbreak:=true;
                                                 end
                                             else
                                                 begin
                                                      s:=s+addr[0];
                                                      lastbreak:=false;
                                                 end;

          end;
        inc(addr);
        inc(readpos);
      end
      else
      begin
        result := s;
        //inc(addr);
        inc(readpos);
        result := s;
        exit;
      end;
    end;
  result := s;
end;
function GDBOpenArrayOfByte.Seek(pos:GDBInteger):integer;
begin
     result:=self.ReadPos;
     readpos:=pos;
end;
constructor GDBOpenArrayOfByte.InitFromFile;
var infile,filelength:GDBInteger;
begin
     //StringToWideChar(filename)
     infile:=fileopen(FileName,fmShareDenyNone);
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
function GDBOpenArrayOfByte.SaveToFile;
var infile:GDBInteger;
begin
     infile:=filecreate(ExpandPath(FileName));
     FileWrite(InFile,parray^,count);
     fileclose(infile);
     result:=count;
end;
constructor GDBOpenArrayOfByte.init;
begin
  ReadPos:=0;
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,1);
end;
constructor GDBOpenArrayOfByte.initnul;
begin
  ReadPos:=0;
  size:=1;
  inherited initnul;
end;
function GDBOpenArrayOfByte.AddData;
var addr:cardinal;
begin
  if parray=nil then
                    createarray;
  if count+sdata>max then
                         Grow;
  {if count = max then
                     begin
                          parray := enlargememblock(parray, size * max, 2*size * max);
                          max:=2*max;
                     end;}
  begin
       //{IFDEF TOTALYLOG}programlog.logoutstr('Write '+inttostr(SData)+' bytes, offset '+inttostr(count),0);{$ENDIF}
       GDBPointer(addr) := parray;
       addr := addr + count;
       Move(PData^, GDBPointer(addr)^,SData);
       result:=count;
       inc(count,SData);
  end;
end;
function GDBOpenArrayOfByte.AllocData;
begin
  if parray=nil then
                    createarray;
  if count+sdata>max then
                         Grow;
  result:=pointer(integer(parray)+count);
  fillchar(result^,sdata,0);
  inc(count,SData);
end;
function GDBOpenArrayOfByte.ReadData;
var addr:cardinal;
begin
  {if count = max then
                     begin
                          parray := enlargememblock(parray, size * max, 2*size * max);
                          max:=2*max;
                     end;}
  begin
       {$IFDEF TOTALYLOG}programlog.logoutstr('Read '+inttostr(SData)+' bytes, offset '+inttostr(ReadPos),0);{$ENDIF}
       GDBPointer(addr) := parray;
       addr := addr + ReadPos;
       Move(GDBPointer(addr)^,PData^,SData);
       result:=count;
       inc(ReadPos,SData);
  end;
end;
function GDBOpenArrayOfByte.PopData;
var addr:cardinal;
begin
  begin
       {$IFDEF TOTALYLOG}programlog.logoutstr('Read '+inttostr(SData)+' bytes, offset '+inttostr(ReadPos),0);{$ENDIF}
       GDBPointer(addr) := parray;
       addr := addr + count-SData;
       Move(GDBPointer(addr)^,PData^,SData);
       result:=count;
       dec(count,SData);
       //if count<0 then
       //               count:=count;
  end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOpenArrayofByte.initialization');{$ENDIF}
end.
