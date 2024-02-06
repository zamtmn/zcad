
unit iolow;
{INCLUDE def.inc}

interface
uses {gdbasetypes,}sysutils;
type
  TMyString=AnsiString;
const
  eol: TMyString=#13 + #10;
  syn_breacer=[#13,#10,' '];
type
  popenarrayc = ^openarrayc;
  openarrayc = array[0..0] of ansichar;
{EXPORT+}
{REGISTEROBJECTTYPE filestream}
  filestream =  object
    name:TMyString;
    bufer:{-}popenarrayc{/Pointer/};
    filesize,
      filepos,
      currentpos,
      filemode,
      filehandle,
      bufersize,
      buferread,
      buferpos: {GDB}Integer;
    constructor init(bsize: {GDB}Integer);
    constructor ReadFromFile(filename:TMyString);
    procedure assign(const fname: TMyString; mode: {GDB}LongWord);
    procedure close;
    procedure readtobufer;
    procedure continuebufer(symbolcount:{GDB}Integer);
    function readString: TMyString;
    function ReadString2: TMyString;
    function ReadByte: {GDB}Byte;
    function ReadWord: {GDB}Word;
    function readworld(break, ignore: TMyString): shortString;
    function readtoparser(break:TMyString): TMyString;
    destructor done;
    destructor CloseAndDone;
  end;
{EXPORT-}
procedure WriteString_EOL(h: {GDB}Integer; s: TMyString);
implementation
constructor filestream.init(bsize: {GDB}Integer);
begin
  bufer := nil;
  GetMem({GDB}Pointer(bufer), bsize);
  bufersize := bsize;
end;
constructor filestream.ReadFromFile(filename:TMyString);
begin
     Init(1024*1024);
     Assign(filename, fmShareDenyNone);
end;

destructor filestream.done;
begin
  FreeMem({GDB}Pointer(bufer));
end;
destructor filestream.closeanddone;
begin
  close;
  done;
end;
procedure filestream.assign(const fname: TMyString; mode: {GDB}LongWord);
begin
  filehandle := fileopen(fname, mode);
  if filehandle > 0 then
                        begin
                             name:=fname;
                             filesize:=FileSeek(filehandle,0,2);
                             FileSeek(filehandle, 0, 0);
                             filemode := mode;
                             filepos := 0;
                             buferread := 0;
                             buferpos := 0;
                             currentpos := 0;
                        end
                    else
                        begin
                             name:=fname;
                             filesize:=-1;
                             filemode := mode;
                             filepos:=-1;
                             buferread:=-1;
                             buferpos:=-1;
                             currentpos:=-1;
                             //ShowError('Не могу открыть "'+fname+'"')
                        end;
end;

procedure filestream.close;
begin
  fileclose(filehandle);
end;

procedure filestream.readtobufer;
begin
  buferread := FileRead(filehandle, bufer^, bufersize);
  filepos := filepos + buferread;
  buferpos := 0;
end;
procedure filestream.continuebufer(symbolcount:{GDB}Integer);
var oldbr:{GDB}Integer;
begin
  oldbr:=buferread;
  Move(bufer^[oldbr-symbolcount],bufer^,symbolcount);
  buferread := FileRead(filehandle, bufer^[symbolcount], bufersize-symbolcount);
  filepos := filepos + buferread;
  buferread:=buferread+symbolcount;
  buferpos := 0;
end;
function readspace(expr: TMyString): TMyString;
var
  i: {GDB}Integer;
begin
  i := 1;
  while not (expr[i] in ['a'..'z', 'A'..'Z', '0'..'9', '$', '(', ')', '+', '-', '*', '/', ':', '=','_', '''']) do
  begin
    if i = length(expr) then
      system.break;
    i := i + 1;
  end;
  result := copy(expr, i, length(expr) - i + 1);
//  expr:=expr;
end;
function filestream.ReadString2: TMyString;
begin
     result:=readspace(readString)
end;
function filestream.readbyte: {GDB}Byte;
begin
     if buferread = 0 then
                          readtobufer;
     result:=byte(bufer^[buferpos]);
     inc(buferpos);
     inc(currentpos);

end;
function filestream.readword: {GDB}Word;
begin
     result:=readbyte+256*readbyte;
end;
function filestream.readString: TMyString;
var
  s: {shortString}TMyString {[100]};
  cr: {GDB}Boolean;
  var i:{GDB}Integer;
begin
  cr := false;
  //setlength(s,255);
  i:=1;
  s := '';
  if buferread = 0 then
    readtobufer;
  while buferread <> 0 do
  begin
    while buferpos <> buferread do
    begin
      if bufer^[buferpos] = {Chr($0D)}#13 then
      begin
        inc(buferpos);
        inc(currentpos);
        cr := true;
      end
      else
        if (bufer^[buferpos] = {Chr($0A)}#10) {and cr} then
        begin
          inc(buferpos);
          inc(currentpos);
          setlength(s,i-1);
          readString := s;
          exit;
        end
        else
        begin
          s := s + bufer^[buferpos];
          //s[i]:=bufer^[buferpos];
          inc(i);
          inc(buferpos);
          inc(currentpos);
        end;
    end;
    readtobufer;
  end;
  setlength(s,i-1);
  readString := s;
end;

function filestream.readworld(break, ignore: TMyString): shortString;
var
  s: {short}TMyString;
  i:{GDB}Integer;
  lastbreak:{GDB}Boolean;
begin
  s := '';
  lastbreak:=false;
  //setlength(s,255);
  i:=1;
  if buferread = 0 then
    readtobufer;
  while buferread <> 0 do
  begin
    while buferpos <> buferread do
    begin
      if (pos(bufer^[buferpos], break) = 0)or((s='')and(bufer^[buferpos]=' ')) then
      begin
        if pos(bufer^[buferpos], ignore) = 0 then
          begin
          //setlength(s,i);
          //s[i]:=bufer^[buferpos];
          inc(i);
          if (s<>'')or(bufer^[buferpos]<>' ') then

          if bufer^[buferpos] in syn_breacer then
                                                 begin
                                                      if not lastbreak then
                                                                           s:=s+bufer^[buferpos];
                                                      lastbreak:=true;
                                                 end
                                             else
                                                 begin
                                                      s:=s+bufer^[buferpos];
                                                      lastbreak:=false;
                                                 end;

          end;
        inc(buferpos);
        inc(currentpos);
      end
      else
      begin
        result := s;
        inc(buferpos);
        inc(currentpos);
        if buferpos = buferread then
          readtobufer;
        result := s;
        //setlength(s,i-1);
        exit;
      end;
    end;
    readtobufer;
  end;
  //setlength(s,i-1);
  result := s;
end;
function filestream.readtoparser(break:TMyString): TMyString;
var
  s: {short}TMyString;
  i:{GDB}Integer;
  scobcacount:{GDB}Integer;
  mode:(parse,commenttoendline,commenttouncomment);
  lastbreak:{GDB}Boolean;
begin
  lastbreak:=false;
  scobcacount:=0;
  s:='';
  i:=1;
  mode:=parse;
  if buferread = 0 then
                       readtobufer;
  while buferread <> 0 do
  begin
    while buferpos <> buferread do
    begin
      if buferpos=buferread-1 then
                                  self.continuebufer(1);
      if (bufer^[buferpos]='{')and(mode=parse) then
                                  begin
                                       mode:=commenttouncomment;
                                       inc(buferpos);
                                  end
      else if (bufer^[buferpos]='}')and(mode=commenttouncomment) then
                                  begin
                                       mode:=parse;
                                       s:= s+' ';
                                       lastbreak:=true;
                                       inc(buferpos);
                                  end
      else if (bufer^[buferpos]='/')and(mode=parse) then
                                  begin
                                       if buferpos<>buferread-1 then
                                       begin
                                            if bufer^[buferpos+1]='/'then
                                                                         begin
                                                                              mode:=commenttoendline;
                                                                              inc(buferpos,2);
                                                                         end;
                                       end;
                                  end
      else if (bufer^[buferpos]=#10)and(mode=commenttoendline) then
                                  begin
                                       mode:=parse;
                                       s:= s+' ';
                                       inc(buferpos);
                                  end

      else if (mode=parse)and(pos(bufer^[buferpos],break)=0) then
      begin
          inc(i);
          if mode=parse then
          begin
               if bufer^[buferpos]='(' then inc(scobcacount);
               if bufer^[buferpos]=')' then dec(scobcacount);
                            if bufer^[buferpos] in syn_breacer then
                                                 begin
                                                      if not lastbreak then
                                                                           s:=s+{bufer^[buferpos]}' ';
                                                      lastbreak:=true;
                                                 end
                                             else
                                                 begin
                                                      s:=s+bufer^[buferpos];
                                                      lastbreak:=false;
                                                 end;
          end;
          inc(buferpos);
          inc(currentpos);
      end
      else
      begin
        if mode=parse then
                          begin
                               if bufer^[buferpos]='(' then inc(scobcacount);
                               if bufer^[buferpos]=')' then dec(scobcacount);
                               s:=s+break;
                               result:=s;
                               inc(buferpos);
                               inc(currentpos);
                               if buferpos = buferread then
                                                           readtobufer;
                               if scobcacount=0 then exit;
//                                                else
//                                                     s:=s;
                          end
                      else inc(buferpos);
      end;
    end;
    readtobufer;
  end;
  //setlength(s,i-1);
  result := s;
end;
procedure WriteString_EOL(h: {GDB}Integer; s: TMyString);
begin
  s := s + eol;
     //writeln(s);
  FileWrite(h, s[1], length(s));
end;
begin
end.
