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

unit io;
{$INCLUDE def.inc}
interface
uses strproc,FileUtil,LCLProc,GDBBlockDef,math,log,strutils,strmy,sysutils,UGDBOpenArrayOfByte,gdbasetypes,SysInfo,UGDBObjBlockdefArray,gdbase,GDBManager,iodxf,memman,UGDBDescriptor,gdbobjectsconstdef;
const
  IgnoreSHP='() '#13;
  BreakSHP='*,'#10;
  fontdirect:array[0..$F,0..1] of GDBDouble=
  ((1,0),(1,0.5),(1,1),(0.5,1),(0,1),(-0.5,1),(-1,1),(-1,0.5),(-1,0),(-1,-0.5),(-1,-1),(-0.5,-1),(0,-1),(0.5,-1),(1,-1),(1,-0.5));
  rootblock:GDBString='ROOT_ENTRY';
type fontfloat=GDBFloat;
     pfontfloat=^fontfloat;
     ptsyminfo=^tsyminfo;
     tsyminfo=packed record
                           number,size:word;
                     end;
function createnewfontfromshp(name:GDBString):GDBPointer;
procedure readpalette;
procedure loadblock(s:GDBString);
function createnewfontfromshx(name:GDBString):GDBPointer;
{
  var
     fontdirect:array[0..$F,0..1] of GDBDouble;
}

implementation
uses
    shared;
procedure createsymbol(pf:PGDBfont;symbol:byte;pshxdata:pbyte;var pdata:pbyte;datalen:integer;unicode:boolean);
var
  temp,ppolycount,psubsymbol:PGDBByte;
  i,j,poz,code,sizeshp,sizeshx,stackheap:GDBInteger;
  baselen,ymin,ymax,x,y,x1,y1,xb,yb,r,startangle,angle,normal,hordlen,tgl:fontfloat;
  stack:array[0..4,0..1] of fontfloat;
  tr:array[1..3,0..1] of fontfloat;
  hi,lo,byt,byt2,subsymbol:GDBByte;
  int:GDBInteger;
  dx,dy:GDBShortint;
  draw:GDBBoolean;
  ff:GDBInteger;
  onlyver:GDBInteger;
begin
            pf^.symbolinfo[symbol].addr:=longint(pdata)-longint(pf);
            onlyver:=0;
            sizeshx:=0;
            draw:=true;
            baselen:=1/pf^.h;
            stackheap:=-1;
            x:=0;
            y:=0;
            ymin:=0;
            ymax:=0;
            while pshxdata^<>0 do
              begin
                case pshxdata^ of
                  001:
                    begin
                      if onlyver=0 then
                        begin
                          draw:=true;
                        end;
                    end;
                  002:
                    begin
                      if onlyver=0 then
                        begin
                          draw:=false;
                        end;
                    end;
                  003:
                    begin
                      inc(pshxdata);
                      if onlyver=0 then
                        begin
                          baselen:=baselen/pshxdata^;
                        end;
                    end;
                  004:
                    begin
                      inc(pshxdata);
                      if onlyver=0 then
                        begin
                          baselen:=baselen*pshxdata^;
                        end;
                    end;
                  005:
                    begin
                      if onlyver=0 then
                        begin
                          inc(stackheap);
                          stack[stackheap,0]:=x;
                          stack[stackheap,1]:=y;
                        end;
                    end;
                  006:
                    begin
                      if onlyver=0 then
                        begin
                          x:=stack[stackheap,0];
                          y:=stack[stackheap,1];
                          dec(stackheap);
                        end;
                    end;
                  007:
                    begin
                      inc(pshxdata);
                      if unicode then
                                     begin
                                          subsymbol:=uch2ach(pword(pshxdata)^);
                                          inc(pshxdata);
                                          inc(pshxdata);
                                     end
                                 else
                                     begin
                                          subsymbol:=pshxdata^;
                                          inc(pshxdata);
                                     end;
                      psubsymbol:=GDBPointer(longint(pf)+pf^.symbolinfo[subsymbol].addr);
                      xb:=x;
                      yb:=y;
                      if psubsymbol<>nil then
                        for i:=1 to pf^.symbolinfo[subsymbol].size do
                          begin
                            pGDBByte(pdata)^:=pGDBByte(psubsymbol)^;
                            inc(pdata,sizeof(GDBLineID));
                            case pGDBByte(psubsymbol)^ of
                              2:
                                begin
                                  inc(psubsymbol,sizeof(GDBLineID));
                                  x1:=pfontfloat(psubsymbol)^*baselen*pf^.h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y1:=pfontfloat(psubsymbol)^*baselen*pf^.h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  x:=pfontfloat(psubsymbol)^*baselen*pf^.h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y:=pfontfloat(psubsymbol)^*baselen*pf^.h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  if draw then
                                    begin
                                      if y>ymax then
                                        ymax:=y;
                                      if y<ymin then
                                        ymin:=y;
                                      if y1>ymax then
                                        ymax:=y1;
                                      if y1<ymin then
                                        ymin:=y1;
                                    end;
                                                                                                                                                                                                                //pGDBByte(pdata)^:=GDBLineID;
                                                                                                                                                                                                                //inc(pdata,sizeof(GDBLineID));
                                  pfontfloat(pdata)^:=x1;
                                  inc(pdata,sizeof(fontfloat));
                                  pfontfloat(pdata)^:=y1;
                                  inc(pdata,sizeof(fontfloat));
                                  pfontfloat(pdata)^:=x;
                                  inc(pdata,sizeof(fontfloat));
                                  pfontfloat(pdata)^:=y;
                                  inc(pdata,sizeof(fontfloat));
                                  inc(sizeshx);
                                                                                                                                                                                                           //end;
                                end;
                              4:
                                begin
                                  inc(psubsymbol,sizeof(GDBLineID));
                                  sizeshp:=pGDBWord(psubsymbol)^;
                                  pGDBWord(pdata)^:=sizeshp;
                                  inc(psubsymbol,sizeof(GDBWord));
                                  inc(pdata,sizeof(GDBWord));

                                  x1:=pfontfloat(psubsymbol)^*baselen*pf^.h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y1:=pfontfloat(psubsymbol)^*baselen*pf^.h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  if draw then
                                    begin
                                      if y1>ymax then
                                        ymax:=y1;
                                      if y1<ymin then
                                        ymin:=y1;
                                    end;//if draw then begin

                                  pGDBByte(pdata)^:=GDBLineID;
                                  inc(pdata,sizeof(GDBLineID));
                                  pfontfloat(pdata)^:=x1;
                                  inc(pdata,sizeof(fontfloat));
                                  pfontfloat(pdata)^:=y1;
                                  inc(pdata,sizeof(fontfloat));

                                  j:=1;
                                  while j<>sizeshp do
                                    begin

                                      x:=pfontfloat(psubsymbol)^*baselen*pf^.h+xb;
                                      inc(psubsymbol,sizeof(fontfloat));
                                      y:=pfontfloat(psubsymbol)^*baselen*pf^.h+yb;
                                      inc(psubsymbol,sizeof(fontfloat));
                                      if draw then
                                        begin
                                          if y>ymax then
                                            ymax:=y;
                                          if y<ymin then
                                            ymin:=y;
                                        end;//if draw then begin;
                                                                                                                                                                                                                        //if draw then begin

                                      pfontfloat(pdata)^:=x;
                                      inc(pdata,sizeof(fontfloat));
                                      pfontfloat(pdata)^:=y;
                                      inc(pdata,sizeof(fontfloat));
                                                                                                                                                                                                                                       //end;
                                      inc(j);
                                    end;
                                  inc(sizeshx);

                                end;
                                                                                                                                                             //                            end;

                            end;
                            x:=pf^.symbolinfo[subsymbol].dx+xb;
                            y:=pf^.symbolinfo[subsymbol].dy+yb;
                          end;

                    end;
                  008:
                    begin
                      inc(pshxdata);
                      dx:=pshxdata^;
                      inc(pshxdata);
                      dy:=pshxdata^;
                      if onlyver=0 then
                        begin
                          x1:=x+dx*baselen;
                          y1:=y+dy*baselen;
                          if draw then
                            begin
                              pGDBByte(pdata)^:=GDBLineID;
                              inc(pdata,sizeof(GDBLineID));
                              pfontfloat(pdata)^:=x;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=y;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=x1;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=y1;
                              inc(pdata,sizeof(fontfloat));
                              inc(sizeshx);
                              if draw then
                                begin
                                  if y>ymax then
                                    ymax:=y;
                                  if y<ymin then
                                    ymin:=y;
                                  if y1>ymax then
                                    ymax:=y1;
                                  if y1<ymin then
                                    ymin:=y1;
                                end//if draw then begin

                            end;
                          x:=x1;
                          y:=y1;
                        end;
                      x:=x;
                    end;
                  009:
                    begin
                                inc(pshxdata);
                                dx:=pshxdata^;
                                inc(pshxdata);
                                dy:=pshxdata^;
{                          repeat
                                line:=f.readworld(breakshp,ignoreshp);
                          until line<>'';
                          val(line,dx,code);
                          repeat
                                line:=f.readworld(breakshp,ignoreshp);
                          until line<>'';
                          val(line,dy,code);}
                      x1:=x+dx*baselen;
                      y1:=y+dy*baselen;
                      pGDBByte(pdata)^:=GDBPolylineID;
                      inc(pdata,sizeof(GDBPolylineID));
                      ppolycount:=pointer(pdata);
                      inc(pdata,sizeof(GDBWord));
                      inc(sizeshx);
                      sizeshp:=1;
                      pfontfloat(pdata)^:=x;
                      inc(pdata,sizeof(fontfloat));
                      pfontfloat(pdata)^:=y;
                      inc(pdata,sizeof(fontfloat));
                      while (dx<>0)or(dy<>0) do
                        begin
                          if draw then
                            begin
                              pfontfloat(pdata)^:=x1;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=y1;
                              inc(pdata,sizeof(fontfloat));
                              inc(sizeshp);
                              begin
                                if y1>ymax then
                                  ymax:=y1;
                                if y1<ymin then
                                  ymin:=y1;
                              end//if draw then begin

                            end;
                          x:=x1;
                          y:=y1;
                                inc(pshxdata);
                                dx:=pshxdata^;
                                inc(pshxdata);
                                dy:=pshxdata^;
                          {repeat
                                line:=f.readworld(breakshp,ignoreshp);
                          until line<>'';
                          val(line,dx,code);
                          repeat
                                line:=f.readworld(breakshp,ignoreshp);
                          until line<>'';
                          val(line,dy,code);}
                          x1:=x+dx*baselen;
                          y1:=y+dy*baselen;

                        end;
                      pGDBWord(ppolycount)^:=sizeshp;
                    end;
                  010:
                    begin
                         inc(pshxdata);
                         r:=pshxdata^*baselen;
                         {line:=f.readworld(breakshp,ignoreshp);
                      if line[1]='-' then
                        begin
                          line:=copy(line,2,length(line)-1);
                          angle:=-1;
                        end
                      else
                        angle:=1;
                      line:='$'+line;
                      byt:=strtoint(line);}
                      inc(pshxdata);
                      byt:=pshxdata^;
                      hi:=byt div 16;
                      lo:=byt and $0F;
                      if lo=0 then
                        angle:=2*pi
                      else
                        angle:=sign(Shortint(byt))*lo*pi/4;
                      startangle:=hi*pi/4;
                      xb:=x-r*cos(startangle);
                      yb:=y-r*sin(startangle);

                      pGDBByte(pdata)^:=GDBPolylineID;
                      inc(pdata,sizeof(GDBPolylineID));
                      ppolycount:=pointer(pdata);
                      inc(pdata,sizeof(GDBWord));
                      inc(sizeshx);
                      sizeshp:=1;
                      pfontfloat(pdata)^:=x;
                      inc(pdata,sizeof(fontfloat));
                      pfontfloat(pdata)^:=y;
                      inc(pdata,sizeof(fontfloat));
                      x1:=0;
                      y1:=0;
                      for i:=1 to arccount do
                        begin
                          x1:=xb+r*cos(startangle+i/arccount*angle);
                          y1:=yb+r*sin(startangle+i/arccount*angle);
                          if draw then
                            begin
                              if y1>ymax then
                                ymax:=y1;
                              if y1<ymin then
                                ymin:=y1;
                              pfontfloat(pdata)^:=x1;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=y1;
                              inc(pdata,sizeof(fontfloat));
                              inc(sizeshp);
                            end;
                        end;
                      x:=x1;
                      y:=y1;
                      pGDBWord(ppolycount)^:=sizeshp;

                                                                                        {line:=f.readworld(breakshp,ignoreshp);
                                                                                        line:=f.readworld(breakshp,ignoreshp);}
                    end;
                  011:
                    begin
                      inc(pshxdata);
                      inc(pshxdata);
                      inc(pshxdata);
                      inc(pshxdata);
                      inc(pshxdata);
                      inc(pshxdata);
                      {line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);}
                    end;
                  012:
                    begin
                                inc(pshxdata);
                                dx:=pshxdata^;
                                inc(pshxdata);
                                dy:=pshxdata^;
                      {ine:=f.readworld(breakshp,ignoreshp);
                      dx:=strtoint(line);
                      line:=f.readworld(breakshp,ignoreshp);
                      dy:=strtoint(line);}
                      tr[1,0]:=x;
                      tr[1,1]:=y;
                      tr[2,0]:=x+dx*baselen;
                      tr[2,1]:=y+dy*baselen;
                      x1:=dx*baselen;
                      y1:=dy*baselen;
                      hordlen:=sqrt(sqr(x1)+sqr(y1));
                      x1:=x1/2;
                      y1:=y1/2;
                      normal:=sqrt(sqr(x1)+sqr(y1));
                      x:=x1+x;
                      y:=y1+y;
                      tgl:=y1;
                      y1:=x1/normal;
                      x1:=-tgl/normal;


                      inc(pshxdata);
                      int:=pshxdata^;
                      {line:=f.readworld(breakshp,ignoreshp);
                      int:=strtoint(line);}
                      normal:=int*hordlen/2/127;
                      tr[3,0]:=x+x1*normal;
                      tr[3,1]:=y+y1*normal;
                      tr[3,1]:=y+y1*normal;
                      x:=tr[2,0];
                      y:=tr[2,1];
                      if draw then
                        begin
                          pGDBByte(pdata)^:=GDBLineID;
                          inc(pdata,sizeof(GDBLineID));
                          pfontfloat(pdata)^:=tr[1,0];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[1,1];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[3,0];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[3,1];
                          inc(pdata,sizeof(fontfloat));
                          inc(sizeshx);
                          pGDBByte(pdata)^:=GDBLineID;
                          inc(pdata,sizeof(GDBLineID));
                          pfontfloat(pdata)^:=tr[3,0];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[3,1];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[2,0];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[2,1];
                          inc(pdata,sizeof(fontfloat));
                          inc(sizeshx);
                        end;

                    end;
                  013:
                    begin
                      inc(pshxdata);
                      inc(pshxdata);
                      inc(pshxdata);
                      {line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);}

                    end;
                  014:
                    begin
                      if onlyver=0 then
                        onlyver:=2
                      else
                        inc(onlyver);
                        {if onlyver=0 then
                        onlyver:=1
                      else
                        onlyver:=0;}
                    end;
                else
                  begin
                      begin
                        if onlyver=0 then
                          begin
                            byt2:=pshxdata^ div 16;
                            x1:=fontdirect[(pshxdata^ and $0F),0];
                            y1:=fontdirect[(pshxdata^ and $0F),1];
                            x1:=x+byt2*x1*baselen;
                            y1:=y+byt2*y1*baselen;
                            if draw then
                              begin
                                pGDBByte(pdata)^:=GDBLineID;
                                inc(pdata,sizeof(GDBLineID));
                                pfontfloat(pdata)^:=x;
                                inc(pdata,sizeof(fontfloat));
                                pfontfloat(pdata)^:=y;
                                inc(pdata,sizeof(fontfloat));
                                pfontfloat(pdata)^:=x1;
                                inc(pdata,sizeof(fontfloat));
                                pfontfloat(pdata)^:=y1;
                                inc(pdata,sizeof(fontfloat));
                                inc(sizeshx);
                                if y>ymax then
                                  ymax:=y;
                                if y<ymin then
                                  ymin:=y;
                                if y1>ymax then
                                  ymax:=y1;
                                if y1<ymin then
                                  ymin:=y1;

                              end;
                            x:=x1;
                            y:=y1;
                          end;
                      end;

                  end;
                end;
                if onlyver>0 then dec(onlyver);
                {byt:=0;
                repeat
                line:=f.readworld(breakshp,ignoreshp);
                until line<>'';
                if line<>'' then
                  if line[1]<>'0' then val(line,byt,code)
                                  else if line<>'0' then
                                                        begin
                                                             line[1]:='$';
                                                             byt:=strtoint(line);
                                                        end;}
                inc(pshxdata);
              end;
            pf^.symbolinfo[symbol].size:=sizeshx;
            pf^.symbolinfo[symbol].dx:=x;
            pf^.symbolinfo[symbol].dy:=ymax;//-ymin;
            pf^.symbolinfo[symbol]._dy:=ymin;
          end;

procedure initfont(var pf:pgdbfont);
var i:integer;
begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{2D1F6D71-DF5C-46B1-9E3A-9975CC281FAC}',{$ENDIF}GDBPointer(pf),1024*1024);
     for i:=0 to 255 do
     begin
      pf^.symbolinfo[i].addr:=0;
      pf^.symbolinfo[i].size:=0;
     end;
     GDBPointer(pf^.fontfile) := nil;
     GDBPointer(pf^.name) := nil;
end;
function createnewfontfromshx(name:GDBString):GDBPointer;
var
   //f:filestream;
   line{,sub}:GDBString;
   test:word;
   {symmin,}symcount,{symmax,}i,symnum,symlen,datalen:integer;
   memorybuf:GDBOpenArrayOfByte;
   psinfo:ptsyminfo;
   pf:PGDBfont;
   pdata:pbyte;
begin
  memorybuf.InitFromFile(name);
  line:=memorybuf.ReadString(#10,#13);
  line:=uppercase(line);
  if line='AUTOCAD-86 SHAPES 1.0' then
  begin
  initfont(pf);
  pf^.fontfile:=extractfilename(name);
  pdata:=pointer(pf);
  inc(pdata,sizeof(GDBfont));
  {test:=}memorybuf.readbyte;

  {symmin:=}memorybuf.readword;
  {symmax:=}memorybuf.readword;
  symcount:=memorybuf.readword;

  psinfo:=memorybuf.GetCurrentReadAddres;

  for i:=0 to symcount-1 do
    begin
         {symnum:=}memorybuf.readword;
         {symlen:=}memorybuf.readword;
    end;
  for i:=0 to symcount-1 do
    begin
         symlen:=psinfo^.size;
         symnum:=psinfo^.number;
         line:=memorybuf.readstring(#0,'');
         datalen:=symlen-length(line)-2;
         if symnum=0 then
                         begin
                              pf^.name:=line;
                              pf^.h:=memorybuf.readbyte;
                              pf^.u:=memorybuf.readbyte;
                              memorybuf.readbyte;
                         end
                     else
                         begin
                              createsymbol(pf,symnum,memorybuf.GetCurrentReadAddres,pdata,datalen+1,false);
                              memorybuf.jump(datalen);
                         end;

                                              //setlength(sub,datalen);
                                              //memorybuf.readdata(@sub[1],datalen);
         {test:=}memorybuf.readbyte;

                                             {line:=strtohex(sub);
                                              line:=inttostr(symnum)+'='+inttostr(datalen)+':'+line;
                                              programlog.logoutstr(line,0);}
         inc(psinfo);
    end;
        line:=memorybuf.readstring('','');
        memorybuf.done;
  end
else if line='AUTOCAD-86 UNIFONT 1.0' then
  begin
       initfont(pf);
       pf^.fontfile:=extractfilename(name);
       pdata:=pointer(pf);
       inc(pdata,sizeof(GDBfont));
       {test:=}memorybuf.readbyte;
       symcount:=memorybuf.readword;

       {symmin:=}memorybuf.readword;
       {symmin:=}memorybuf.readword;

       pf^.name:=memorybuf.readstring(#0,'');
       pf^.h:=memorybuf.readbyte;
       pf^.u:=memorybuf.readbyte;
       memorybuf.readbyte;
       {test:=}memorybuf.readbyte;
       memorybuf.readbyte;
       memorybuf.readbyte;

  for i:=0 to symcount-2 do
    begin
         symnum:=memorybuf.readword;
         symlen:=memorybuf.readword;
         line:=memorybuf.readstring(#0,'');
         datalen:=symlen-length(line)-2;
         //if symnum>255 then
         begin

         test:=uch2ach(symnum);
         if pf^.symbolinfo[test].addr=0 then

         {if symnum<256 then }createsymbol(pf,test{symnum},memorybuf.GetCurrentReadAddres,pdata,datalen+1,true);
         end;
         memorybuf.jump(datalen);

                                              //setlength(sub,datalen);
                                              //memorybuf.readdata(@sub[1],datalen);
         {test:=}memorybuf.readbyte;

                                             {line:=strtohex(sub);
                                              line:=inttostr(symnum)+'='+inttostr(datalen)+':'+line;
                                              programlog.logoutstr(line,0);}
         //inc(psinfo);
    end;


  {psinfo:=}memorybuf.GetCurrentReadAddres;
  end;
  pf^.compiledsize:=cardinal(pdata)-cardinal(pf);
  result:=remapmememblock({$IFDEF DEBUGBUILD}'Compiled fonts',{$ENDIF}pf,pf^.compiledsize);
  memorybuf.done;
  //halt(0);
end;
function createnewfontfromshp(name:GDBString):GDBPointer;
var
  temp,pfont,pdata,ppolycount,psubsymbol:PGDBByte;
  i,j,poz,code,sizeshp,sizeshx,stackheap:GDBInteger;
  baselen,ymin,ymax,x,y,x1,y1,xb,yb,r,startangle,angle,normal,hordlen,tgl:fontfloat;
  stack:array[0..4,0..1] of fontfloat;
  tr:array[1..3,0..1] of fontfloat;
  hi,lo,byt,byt2,subsymbol:GDBByte;
  symbol:GDBInteger;
  int:GDBInteger;
  dx,dy:GDBShortint;
  line,sub:GDBString;
  draw:GDBBoolean;
  f:GDBOpenArrayOfByte;
  ff:GDBInteger;
  onlyver:GDBInteger;
begin

  pfont:=nil;
  symbol:=0;
  GDBGetMem({$IFDEF DEBUGBUILD}'{8908D757-20C6-44FC-A2CC-3E4908A18FBE}',{$ENDIF}GDBPointer(pfont),1024*1024);
  temp:=pfont;
  //onlyver:=0;
  for i:=0 to 255 do
    begin
      PGDBfont(pfont)^.symbolinfo[i].addr:=0;
      PGDBfont(pfont)^.symbolinfo[i].size:=0;
    end;
  pdata:=pfont;
  inc(pdata,sizeof(GDBfont));
  GDBPointer(PGDBfont(pfont)^.fontfile) := nil;
  GDBPointer(PGDBfont(pfont)^.name) := nil;
  //{GDBPointer(}PGDBfont(pfont)^.fontfile[0]:=chr(0);
  //fillchar(PGDBfont(pfont)^.fontfile[0],sizeof(PGDBfont(pfont)^.fontfile),0);
  PGDBfont(pfont)^.fontfile:=extractfilename(name);

  //f.init(10000);
  f.InitFromFile(name);
  line:=f.readstring('*','');
  while f.notEOF do
    begin
      line:=f.readstring(breakshp,ignoreshp);
               //if (line<>'')and(line[1]<>';')then
      begin
                if line<>'' then
                  if line[1]<>'0' then val(line,symbol,code)
                                  else if line<>'0' then
                                                        begin
                                                             line[1]:='$';
                                                             symbol:=strtoint(line);
                                                        end
                                                    else symbol:=0;
        if symbol=0 then
          begin
            line:=f.readstring(breakshp,ignoreshp);
            line:=f.readstring(breakshp,ignoreshp);
        //GDBPointer(PGDBfont(pfont)^.name) := nil;
            PGDBfont(pfont)^.name:=line;
            line:=f.readstring(breakshp,ignoreshp);
            val(line,PGDBfont(pfont)^.h,code);
            line:=f.readstring(breakshp,ignoreshp);
            val(line,PGDBfont(pfont)^.u,code);
            line:=f.readstring(breakshp,ignoreshp);
            line:=f.readstring(breakshp,ignoreshp);
          end
        else
          begin
            symbol:=symbol and $ff;
            //log.programlog.logoutstr(inttostr(symbol),0);
            if symbol=255 then
                              symbol:=symbol;

        //PGDBfont(pfont)^.symbolinfo[symbol].addr := pdata;
            PGDBfont(pfont)^.symbolinfo[symbol].addr:=longint(pdata)-longint(pfont);
            onlyver:=0;
            sizeshx:=0;
            draw:=true;
            baselen:=1/PGDBfont(pfont)^.h;
            stackheap:=-1;
            x:=0;
            y:=0;
            ymin:=0;
            ymax:=0;
            line:=f.readstring({breakshp}'*'#10,ignoreshp);
            //val(line,sizeshp,code);
            line:=f.readstring(breakshp,ignoreshp);
            if line[1]<>'0' then
              val(line,byt,code)
            else
              begin
                line[1]:='$';
                byt:=strtoint(line);
              end;
            while byt<>0 do
              begin
                case byt of
                  001:
                    begin
                      if onlyver=0 then
                        begin
                          draw:=true;
                        end;
                    end;
                  002:
                    begin
                      if onlyver=0 then
                        begin
                          draw:=false;
                        end;
                    end;
                  003:
                    begin
                      line:=f.readstring(breakshp,ignoreshp);
                      byt2:=strtoint(line);
                      if onlyver=0 then
                        begin
                          baselen:=baselen/byt2;
                        end;
                    end;
                  004:
                    begin
                      line:=f.readstring(breakshp,ignoreshp);
                      byt2:=strtoint(line);
                      if onlyver=0 then
                        begin
                          baselen:=baselen*byt2;
                        end;
                    end;
                  005:
                    begin
                      if onlyver=0 then
                        begin
                          inc(stackheap);
                          stack[stackheap,0]:=x;
                          stack[stackheap,1]:=y;
                        end;
                    end;
                  006:
                    begin
                      if onlyver=0 then
                        begin
                          x:=stack[stackheap,0];
                          y:=stack[stackheap,1];
                          dec(stackheap);
                        end;
                    end;
                  007:
                    begin
                      line:=f.readstring(breakshp,ignoreshp);
                      if line[1]='0' then
                        line:='$'+line;
                      subsymbol:=strtoint(line);
                      psubsymbol:=GDBPointer(longint(pfont)+PGDBfont(pfont)^.symbolinfo[subsymbol].addr);
                      xb:=x;
                      yb:=y;
                      if psubsymbol<>nil then
                        for i:=1 to PGDBfont(pfont)^.symbolinfo[subsymbol].size do
                          begin
                            pGDBByte(pdata)^:=pGDBByte(psubsymbol)^;
                            inc(pdata,sizeof(GDBLineID));
                            case pGDBByte(psubsymbol)^ of
                              2:
                                begin
                                  inc(psubsymbol,sizeof(GDBLineID));
                                  x1:=pfontfloat(psubsymbol)^*baselen*PGDBfont(pfont)^.h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y1:=pfontfloat(psubsymbol)^*baselen*PGDBfont(pfont)^.h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  x:=pfontfloat(psubsymbol)^*baselen*PGDBfont(pfont)^.h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y:=pfontfloat(psubsymbol)^*baselen*PGDBfont(pfont)^.h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  if draw then
                                    begin
                                      if y>ymax then
                                        ymax:=y;
                                      if y<ymin then
                                        ymin:=y;
                                      if y1>ymax then
                                        ymax:=y1;
                                      if y1<ymin then
                                        ymin:=y1;
                                    end;//if draw then begin
                                                                                                                                                                                                                //pGDBByte(pdata)^:=GDBLineID;
                                                                                                                                                                                                                //inc(pdata,sizeof(GDBLineID));
                                  pfontfloat(pdata)^:=x1;
                                  inc(pdata,sizeof(fontfloat));
                                  pfontfloat(pdata)^:=y1;
                                  inc(pdata,sizeof(fontfloat));
                                  pfontfloat(pdata)^:=x;
                                  inc(pdata,sizeof(fontfloat));
                                  pfontfloat(pdata)^:=y;
                                  inc(pdata,sizeof(fontfloat));
                                  inc(sizeshx);
                                                                                                                                                                                                           //end;
                                end;
                              4:
                                begin
                                  inc(psubsymbol,sizeof(GDBLineID));
                                  sizeshp:=pGDBWord(psubsymbol)^;
                                  pGDBWord(pdata)^:=sizeshp;
                                  inc(psubsymbol,sizeof(GDBWord));
                                  inc(pdata,sizeof(GDBWord));

                                  x1:=pfontfloat(psubsymbol)^*baselen*PGDBfont(pfont)^.h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y1:=pfontfloat(psubsymbol)^*baselen*PGDBfont(pfont)^.h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  if draw then
                                    begin
                                      if y1>ymax then
                                        ymax:=y1;
                                      if y1<ymin then
                                        ymin:=y1;
                                    end;//if draw then begin

                                  pGDBByte(pdata)^:=GDBLineID;
                                  inc(pdata,sizeof(GDBLineID));
                                  pfontfloat(pdata)^:=x1;
                                  inc(pdata,sizeof(fontfloat));
                                  pfontfloat(pdata)^:=y1;
                                  inc(pdata,sizeof(fontfloat));

                                  j:=1;
                                  while j<>sizeshp do
                                    begin

                                      x:=pfontfloat(psubsymbol)^*baselen*PGDBfont(pfont)^.h+xb;
                                      inc(psubsymbol,sizeof(fontfloat));
                                      y:=pfontfloat(psubsymbol)^*baselen*PGDBfont(pfont)^.h+yb;
                                      inc(psubsymbol,sizeof(fontfloat));
                                      if draw then
                                        begin
                                          if y>ymax then
                                            ymax:=y;
                                          if y<ymin then
                                            ymin:=y;
                                        end;//if draw then begin;
                                                                                                                                                                                                                        //if draw then begin

                                      pfontfloat(pdata)^:=x;
                                      inc(pdata,sizeof(fontfloat));
                                      pfontfloat(pdata)^:=y;
                                      inc(pdata,sizeof(fontfloat));
                                                                                                                                                                                                                                       //end;
                                      inc(j);
                                    end;
                                  inc(sizeshx);

                                end;
                                                                                                                                                             //                            end;

                            end;
                            x:=PGDBfont(pfont)^.symbolinfo[subsymbol].dx+xb;
                            y:=PGDBfont(pfont)^.symbolinfo[subsymbol].dy+yb;
                          end;

                    end;
                  008:
                    begin
                      line:=f.readstring(breakshp,ignoreshp);
                      val(line,dx,code);
                      line:=f.readstring(breakshp,ignoreshp);
                      val(line,dy,code);
                      if onlyver=0 then
                        begin
                          x1:=x+dx*baselen;
                          y1:=y+dy*baselen;
                          if draw then
                            begin
                              pGDBByte(pdata)^:=GDBLineID;
                              inc(pdata,sizeof(GDBLineID));
                              pfontfloat(pdata)^:=x;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=y;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=x1;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=y1;
                              inc(pdata,sizeof(fontfloat));
                              inc(sizeshx);
                              if draw then
                                begin
                                  if y>ymax then
                                    ymax:=y;
                                  if y<ymin then
                                    ymin:=y;
                                  if y1>ymax then
                                    ymax:=y1;
                                  if y1<ymin then
                                    ymin:=y1;
                                end//if draw then begin

                            end;
                          x:=x1;
                          y:=y1;
                        end;
                      x:=x;
                    end;
                  009:
                    begin
                          repeat
                                line:=f.readstring(breakshp,ignoreshp);
                          until line<>'';
                          val(line,dx,code);
                          repeat
                                line:=f.readstring(breakshp,ignoreshp);
                          until line<>'';
                          val(line,dy,code);
                      x1:=x+dx*baselen;
                      y1:=y+dy*baselen;
                      pGDBByte(pdata)^:=GDBPolylineID;
                      inc(pdata,sizeof(GDBPolylineID));
                      ppolycount:=pdata;
                      inc(pdata,sizeof(GDBWord));
                      inc(sizeshx);
                      sizeshp:=1;
                      pfontfloat(pdata)^:=x;
                      inc(pdata,sizeof(fontfloat));
                      pfontfloat(pdata)^:=y;
                      inc(pdata,sizeof(fontfloat));
                      while (dx<>0)or(dy<>0) do
                        begin
                          if draw then
                            begin
                              pfontfloat(pdata)^:=x1;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=y1;
                              inc(pdata,sizeof(fontfloat));
                              inc(sizeshp);
                              begin
                                if y1>ymax then
                                  ymax:=y1;
                                if y1<ymin then
                                  ymin:=y1;
                              end//if draw then begin

                            end;
                          x:=x1;
                          y:=y1;
                          repeat
                                line:=f.readstring(breakshp,ignoreshp);
                          until line<>'';
                          val(line,dx,code);
                          repeat
                                line:=f.readstring(breakshp,ignoreshp);
                          until line<>'';
                          val(line,dy,code);
                          x1:=x+dx*baselen;
                          y1:=y+dy*baselen;

                        end;
                      pGDBWord(ppolycount)^:=sizeshp;
                    end;
                  010:
                    begin
                      line:=f.readstring(breakshp,ignoreshp);
                      r:=strtoint(line)*baselen;
                      line:=f.readstring(breakshp,ignoreshp);
                      if line[1]='-' then
                        begin
                          line:=copy(line,2,length(line)-1);
                          angle:=-1;
                        end
                      else
                        angle:=1;
                      line:='$'+line;
                      byt:=strtoint(line);
                      hi:=byt div 16;
                      lo:=byt and $0F;
                      if lo=0 then
                        angle:=2*pi
                      else
                        angle:=angle*lo*pi/4;
                      startangle:=hi*pi/4;
                      xb:=x-r*cos(startangle);
                      yb:=y-r*sin(startangle);

                      pGDBByte(pdata)^:=GDBPolylineID;
                      inc(pdata,sizeof(GDBPolylineID));
                      ppolycount:=pdata;
                      inc(pdata,sizeof(GDBWord));
                      inc(sizeshx);
                      sizeshp:=1;
                      pfontfloat(pdata)^:=x;
                      inc(pdata,sizeof(fontfloat));
                      pfontfloat(pdata)^:=y;
                      inc(pdata,sizeof(fontfloat));
                      x1:=0;
                      y1:=0;
                      for i:=1 to arccount do
                        begin
                          x1:=xb+r*cos(startangle+i/arccount*angle);
                          y1:=yb+r*sin(startangle+i/arccount*angle);
                          if draw then
                            begin
                              if y1>ymax then
                                ymax:=y1;
                              if y1<ymin then
                                ymin:=y1;
                              pfontfloat(pdata)^:=x1;
                              inc(pdata,sizeof(fontfloat));
                              pfontfloat(pdata)^:=y1;
                              inc(pdata,sizeof(fontfloat));
                              inc(sizeshp);
                            end;
                        end;
                      x:=x1;
                      y:=y1;
                      pGDBWord(ppolycount)^:=sizeshp;

                                                                                        {line:=f.readstring(breakshp,ignoreshp);
                                                                                        line:=f.readstring(breakshp,ignoreshp);}
                    end;
                  011:
                    begin
                      line:=f.readstring(breakshp,ignoreshp);
                      line:=f.readstring(breakshp,ignoreshp);
                      line:=f.readstring(breakshp,ignoreshp);
                      line:=f.readstring(breakshp,ignoreshp);
                      line:=f.readstring(breakshp,ignoreshp);
                      line:=f.readstring(breakshp,ignoreshp);
                    end;
                  012:
                    begin
                      line:=f.readstring(breakshp,ignoreshp);
                      dx:=strtoint(line);
                      line:=f.readstring(breakshp,ignoreshp);
                      dy:=strtoint(line);
                      tr[1,0]:=x;
                      tr[1,1]:=y;
                      tr[2,0]:=x+dx*baselen;
                      tr[2,1]:=y+dy*baselen;
                      x1:=dx*baselen;
                      y1:=dy*baselen;
                      hordlen:=sqrt(sqr(x1)+sqr(y1));
                      x1:=x1/2;
                      y1:=y1/2;
                      normal:=sqrt(sqr(x1)+sqr(y1));
                      x:=x1+x;
                      y:=y1+y;
                      tgl:=y1;
                      y1:=x1/normal;
                      x1:=-tgl/normal;

                      line:=f.readstring(breakshp,ignoreshp);
                      int:=strtoint(line);
                      normal:=int*hordlen/2/127;
                      tr[3,0]:=x+x1*normal;
                      tr[3,1]:=y+y1*normal;
                      tr[3,1]:=y+y1*normal;
                      x:=tr[2,0];
                      y:=tr[2,1];
                      if draw then
                        begin
                          pGDBByte(pdata)^:=GDBLineID;
                          inc(pdata,sizeof(GDBLineID));
                          pfontfloat(pdata)^:=tr[1,0];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[1,1];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[3,0];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[3,1];
                          inc(pdata,sizeof(fontfloat));
                          inc(sizeshx);
                          pGDBByte(pdata)^:=GDBLineID;
                          inc(pdata,sizeof(GDBLineID));
                          pfontfloat(pdata)^:=tr[3,0];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[3,1];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[2,0];
                          inc(pdata,sizeof(fontfloat));
                          pfontfloat(pdata)^:=tr[2,1];
                          inc(pdata,sizeof(fontfloat));
                          inc(sizeshx);
                        end;

                    end;
                  013:
                    begin
                      line:=f.readstring(breakshp,ignoreshp);
                      line:=f.readstring(breakshp,ignoreshp);
                      line:=f.readstring(breakshp,ignoreshp);

                    end;
                  014:
                    begin
                      if onlyver=0 then
                        onlyver:=2
                      else
                        inc(onlyver);
                        {if onlyver=0 then
                        onlyver:=1
                      else
                        onlyver:=0;}
                    end;
                else
                  begin
                    if line[1]<>'$' then
                      begin
                        line:='$'+line;
                        byt:=strtoint(line);
                      end;
                    if line[1]='$' then
                      begin
                        if onlyver=0 then
                          begin
                            byt2:=byt div 16;
                            x1:=fontdirect[(byt and $0F),0];
                            y1:=fontdirect[(byt and $0F),1];
                            x1:=x+byt2*x1*baselen;
                            y1:=y+byt2*y1*baselen;
                            if draw then
                              begin
                                pGDBByte(pdata)^:=GDBLineID;
                                inc(pdata,sizeof(GDBLineID));
                                pfontfloat(pdata)^:=x;
                                inc(pdata,sizeof(fontfloat));
                                pfontfloat(pdata)^:=y;
                                inc(pdata,sizeof(fontfloat));
                                pfontfloat(pdata)^:=x1;
                                inc(pdata,sizeof(fontfloat));
                                pfontfloat(pdata)^:=y1;
                                inc(pdata,sizeof(fontfloat));
                                inc(sizeshx);
                                if y>ymax then
                                  ymax:=y;
                                if y<ymin then
                                  ymin:=y;
                                if y1>ymax then
                                  ymax:=y1;
                                if y1<ymin then
                                  ymin:=y1;

                              end;
                            x:=x1;
                            y:=y1;
                          end;
                      end;

                  end;
                end;
                if onlyver>0 then dec(onlyver);
                byt:=0;
                repeat
                line:=f.readstring(breakshp,ignoreshp);
                until line<>'';
                if line<>'' then
                  if line[1]<>'0' then val(line,byt,code)
                                  else if line<>'0' then
                                                        begin
                                                             line[1]:='$';
                                                             byt:=strtoint(line);
                                                        end;
              end;
            PGDBfont(pfont)^.symbolinfo[symbol].size:=sizeshx;
            PGDBfont(pfont)^.symbolinfo[symbol].dx:=x;
            PGDBfont(pfont)^.symbolinfo[symbol].dy:=ymax;//-ymin;
            PGDBfont(pfont)^.symbolinfo[symbol]._dy:=ymin;
          end;
        line:=f.readstring('*','');

        //line:=f.readstring(breakshp,ignoreshp);
        //val(line,byt,code);
      end;
    end;
  //f.close;
  f.done;
  PGDBfont(pfont)^.compiledsize:=longint(pdata)-longint(pfont);
  {ff:=filecreate('C:\file.my');
  FileWrite(ff, Pfont^,PGDBfont(pfont)^.compiledsize);
  fileclose(ff);}

  result:=remapmememblock({$IFDEF DEBUGBUILD}'Compiled fonts',{$ENDIF}pfont,PGDBfont(pfont)^.compiledsize);

end;

procedure readpalette;
var
  i,poz,code:GDBInteger;
  //byt:GDBByte;
  line,sub:GDBString;
  f:GDBOpenArrayOfByte;
begin
  //f.init(10000);
  f.InitFromFile(sysparam.programpath+'components/palette.rgb');
  while f.notEOF do
    begin
      line:=f.readGDBString;
      if (line[1]<>';')and(line[1]<>'') then
        begin
          sub:=Copy(line,1,3);
          val(sub,i,code);
          line:=Copy(line,5,length(line)-4);
          poz:=Pos(',',line);
          sub:=Copy(line,1,poz-1);
          val(sub,palette[i].r,code);
          line:=Copy(line,poz+1,length(line)-poz);
          poz:=Pos(',',line);
          sub:=Copy(line,1,poz-1);
          val(sub,palette[i].g,code);
          line:=Copy(line,poz+1,length(line)-poz);
          sub:=Copy(line,1,length(line));
          val(sub,palette[i].b,code);
          palette[i].a:=255;
        end;
    end;
  //f.close;
  f.done;
end;

procedure loadblock(s:GDBString);
var
  //bc:GDBInteger;
  pb:PGDBObjBlockdef;
begin
  pb:=gdb.GetCurrentDWG.BlockDefArray.create(s);
  addfromdxf(sysparam.programpath+'block\'+s+'.dxf',pb);
end;
initialization
begin
  {$IFDEF DEBUGINITSECTION}LogOut('io.initialization');{$ENDIF}
  {fontdirect[ 0,0]:=cos(  0*pi/180);fontdirect[ 0,1]:=sin(  0*pi/180);
  fontdirect[ 1,0]:=cos( 30*pi/180);fontdirect[ 1,1]:=sin( 30*pi/180);
  fontdirect[ 2,0]:=cos( 45*pi/180);fontdirect[ 2,1]:=sin( 45*pi/180);
  fontdirect[ 3,0]:=cos( 60*pi/180);fontdirect[ 3,1]:=sin( 60*pi/180);
  fontdirect[ 4,0]:=cos( 90*pi/180);fontdirect[ 4,1]:=sin( 90*pi/180);
  fontdirect[ 5,0]:=cos(120*pi/180);fontdirect[ 5,1]:=sin(120*pi/180);
  fontdirect[ 6,0]:=cos(135*pi/180);fontdirect[ 6,1]:=sin(135*pi/180);
  fontdirect[ 7,0]:=cos(150*pi/180);fontdirect[ 7,1]:=sin(150*pi/180);
  fontdirect[ 8,0]:=cos(180*pi/180);fontdirect[ 8,1]:=sin(180*pi/180);
  fontdirect[ 9,0]:=cos(210*pi/180);fontdirect[ 9,1]:=sin(210*pi/180);
  fontdirect[10,0]:=cos(225*pi/180);fontdirect[10,1]:=sin(225*pi/180);
  fontdirect[11,0]:=cos(240*pi/180);fontdirect[11,1]:=sin(240*pi/180);
  fontdirect[12,0]:=cos(270*pi/180);fontdirect[12,1]:=sin(270*pi/180);
  fontdirect[13,0]:=cos(300*pi/180);fontdirect[13,1]:=sin(300*pi/180);
  fontdirect[14,0]:=cos(315*pi/180);fontdirect[14,1]:=sin(315*pi/180);
  fontdirect[15,0]:=cos(330*pi/180);fontdirect[15,1]:=sin(330*pi/180);}
end;
end.
