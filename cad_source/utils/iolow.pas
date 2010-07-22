
unit iolow;
{$INCLUDE def.inc}

interface
uses gdbasetypes,sysutils;
const
  eol: GDBString=#13 + #10;
  syn_breacer=[#13,#10,' '];
type
  popenarrayc = ^openarrayc;
  openarrayc = array[0..0] of ansichar;
{EXPORT+}
  filestream = object
    name:GDBString;
    bufer:{-}popenarrayc{/GDBPointer/};
    filesize,
      filepos,
      currentpos,
      filemode,
      filehandle,
      bufersize,
      buferread,
      buferpos: GDBInteger;
    constructor init(bsize: GDBInteger);
    constructor ReadFromFile(filename:gdbstring);
    procedure assign(const fname: GDBString; mode: GDBLongword);
    procedure close;
    procedure readtobufer;
    procedure continuebufer(symbolcount:GDBInteger);
    function readGDBString: GDBString;
    function ReadString: GDBString;
    function ReadByte: GDBByte;
    function ReadWord: GDBWord;
    function readworld(break, ignore: GDBString): shortString;
    function readtoparser(break:GDBString): GDBString;
    destructor done;
    destructor CloseAndDone;
  end;
{EXPORT-}
procedure WriteString_EOL(h: GDBInteger; s: GDBString);
implementation
constructor filestream.init;
begin
  bufer := nil;
  GetMem(GDBPointer(bufer), bsize);
  bufersize := bsize;
end;
constructor filestream.ReadFromFile;
begin
     Init(1024*1024);
     Assign(filename, fmShareDenyNone);
end;

destructor filestream.done;
begin
  FreeMem(GDBPointer(bufer));
end;
destructor filestream.closeanddone;
begin
  close;
  done;
end;
procedure filestream.assign;
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
procedure filestream.continuebufer;
var oldbr:GDBInteger;
begin
  oldbr:=buferread;
  Move(bufer^[oldbr-symbolcount],bufer^,symbolcount);
  buferread := FileRead(filehandle, bufer^[symbolcount], bufersize-symbolcount);
  filepos := filepos + buferread;
  buferread:=buferread+symbolcount;
  buferpos := 0;
end;
function readspace(expr: GDBString): GDBString;
var
  i: GDBInteger;
begin
  i := 1;
  while not (expr[i] in ['a'..'z', 'A'..'Z', '0'..'9', '$', '(', ')', '+', '-', '*', '/', ':', '=','_', '''']) do
  begin
    if i = length(expr) then
      system.break;
    i := i + 1;
  end;
  result := copy(expr, i, length(expr) - i + 1);
  expr:=expr;
end;
function filestream.ReadString;
begin
     result:=readspace(readGDBString)
end;
function filestream.readbyte;
begin
     if buferread = 0 then
                          readtobufer;
     result:=byte(bufer^[buferpos]);
     inc(buferpos);
     inc(currentpos);

end;
function filestream.readword;
begin
     result:=readbyte+256*readbyte;
end;
function filestream.readGDBString;
var
  s: {shortGDBString}GDBString {[100]};
  cr: GDBBoolean;
  var i:GDBInteger;
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
          readGDBString := s;
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
  readGDBString := s;
end;

function filestream.readworld;
var
  s: {short}GDBString;
  i:GDBInteger;
  lastbreak:GDBBoolean;
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
function filestream.readtoparser;
var
  s: {short}GDBString;
  i:GDBInteger;
  scobcacount:GDBInteger;
  mode:(parse,commenttoendline,commenttouncomment);
  lastbreak:GDBBoolean;
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
                               if scobcacount=0 then exit
                                                else
                                                     s:=s;
                          end
                      else inc(buferpos);
      end;
    end;
    readtobufer;
  end;
  //setlength(s,i-1);
  result := s;
end;
procedure WriteString_EOL(h: GDBInteger; s: GDBString);
begin
  s := s + eol;
     //writeln(s);
  FileWrite(h, s[1], length(s));
end;
begin
end.
