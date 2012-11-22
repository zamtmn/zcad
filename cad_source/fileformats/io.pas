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
uses zcadstrconsts,intftranslations,UGDBSHXFont,strproc,FileUtil,LCLProc,GDBBlockDef,math,log{,strutils},strmy,sysutils,UGDBOpenArrayOfByte,gdbasetypes,SysInfo,{UGDBObjBlockdefArray,}gdbase,GDBManager,iodxf,memman,UGDBDescriptor,gdbobjectsconstdef;
const
  IgnoreSHP='() '#13;
  BreakSHP='*,'#10;
  fontdirect:array[0..$F,0..1] of GDBDouble=
  ((1,0),(1,0.5),(1,1),(0.5,1),(0,1),(-0.5,1),(-1,1),(-1,0.5),(-1,0),(-1,-0.5),(-1,-1),(-0.5,-1),(0,-1),(0.5,-1),(1,-1),(1,-0.5));
  rootblock:GDBString='ROOT_ENTRY';
type ptsyminfo=^tsyminfo;
     tsyminfo=packed record
                           number,size:word;
                     end;
procedure readpalette;
procedure loadblock(s:GDBString);
function createnewfontfromshx(name:GDBString;var pf:PGDBfont):GDBBoolean;
{
  var
     fontdirect:array[0..$F,0..1] of GDBDouble;
}

implementation
uses
    shared;

function createsymbol(pf:PGDBfont;symbol:GDBInteger;pshxdata:pbyte;{var pdata:pbyte;}datalen:integer;unicode:boolean;symname:gdbstring):GDBInteger;
var
  {temp,}psubsymbol:PGDBByte;
  ppolycount:longint;
  i,j,poz,code,sizeshp,sizeshx,stackheap:GDBInteger;
  baselen,ymin,ymax,xmin,xmax,x,y,x1,y1,xb,yb,r,startangle,angle,normal,hordlen,tgl:fontfloat;
  stack:array[0..4,0..1] of fontfloat;
  tr:array[1..3,0..1] of fontfloat;
  hi,lo,byt,byt2:GDBByte;
  subsymbol:GDBInteger;
  int:GDBInteger;
  dx,dy:GDBShortint;
  draw:GDBBoolean;
  ff:GDBInteger;
  onlyver:GDBInteger;
  psyminfo,psubsyminfo:PGDBsymdolinfo;
  inccounter:integer;
  tbool:boolean;
procedure ProcessMinMax(_x,_y:fontfloat);
begin
      if _y>ymax then
        ymax:=_y;
      if _y<ymin then
        ymin:=_y;
      if _x>xmax then
        xmax:=_x;
      if _x<xmin then
        xmin:=_x;
end;
procedure  incpshxdata;
begin
     inc(pshxdata);
     inc(inccounter);
end;
procedure createarc;
begin
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


     incpshxdata;
     int:=pShortint(pshxdata)^;
     {line:=f.readworld(breakshp,ignoreshp);
     int:=strtoint(line);}
     normal:=-int*hordlen/2/127;
     tr[3,0]:=x+x1*normal;
     tr[3,1]:=y+y1*normal;
     x:=tr[2,0];
     y:=tr[2,1];
     if draw then
       begin

                                    begin
                                         ProcessMinMax(tr[1,0],tr[1,1]);
                                         ProcessMinMax(tr[2,0],tr[2,1]);
                                         ProcessMinMax(tr[3,0],tr[3,1]);
                                      {if tr[1,1]>ymax then
                                        ymax:=tr[1,1];
                                      if tr[1,1]<ymin then
                                        ymin:=tr[1,1];
                                      if tr[3,1]>ymax then
                                        ymax:=tr[3,1];
                                      if tr[3,1]<ymin then
                                        ymin:=tr[3,1];
                                      if tr[2,1]>ymax then
                                        ymax:=tr[2,1];
                                      if tr[2,1]<ymin then
                                        ymin:=tr[2,1];}
                                    end;

         pf^.SHXdata.AddByteByVal(GDBLineID);//---------------------pGDBByte(pdata)^:=GDBLineID;
         //---------------------inc(pdata,sizeof(GDBLineID));
         pf^.SHXdata.AddFontFloat(@tr[1,0]);//---------------------pfontfloat(pdata)^:=tr[1,0];
         //---------------------inc(pdata,sizeof(fontfloat));
         pf^.SHXdata.AddFontFloat(@tr[1,1]);//---------------------pfontfloat(pdata)^:=tr[1,1];
         //---------------------inc(pdata,sizeof(fontfloat));
         pf^.SHXdata.AddFontFloat(@tr[3,0]);//---------------------pfontfloat(pdata)^:=tr[3,0];
         //---------------------inc(pdata,sizeof(fontfloat));
         pf^.SHXdata.AddFontFloat(@tr[3,1]);//---------------------pfontfloat(pdata)^:=tr[3,1];
         //---------------------inc(pdata,sizeof(fontfloat));
         inc(sizeshx);
         pf^.SHXdata.AddByteByVal(GDBLineID);//---------------------pGDBByte(pdata)^:=GDBLineID;
         //---------------------inc(pdata,sizeof(GDBLineID));
         pf^.SHXdata.AddFontFloat(@tr[3,0]);//---------------------pfontfloat(pdata)^:=tr[3,0];
         //---------------------inc(pdata,sizeof(fontfloat));
         pf^.SHXdata.AddFontFloat(@tr[3,1]);//---------------------pfontfloat(pdata)^:=tr[3,1];
         //---------------------inc(pdata,sizeof(fontfloat));
         pf^.SHXdata.AddFontFloat(@tr[2,0]);//---------------------pfontfloat(pdata)^:=tr[2,0];
         //---------------------inc(pdata,sizeof(fontfloat));
         pf^.SHXdata.AddFontFloat(@tr[2,1]);//---------------------pfontfloat(pdata)^:=tr[2,1];
         //---------------------inc(pdata,sizeof(fontfloat));
         inc(sizeshx);
       end;
end;
begin
            inccounter:=0;
            psyminfo:=pf^.GetOrCreateSymbolInfo(symbol);
            psyminfo{pf^.sym bolinfo[symbol]}.addr:={GDBPlatformint(pdata)-GDBPlatformint(pf)}pf^.SHXdata.Count;
            onlyver:=0;
            sizeshx:=0;
            draw:=true;
            baselen:=1/pf^.h;
            stackheap:=-1;
            x:=0;
            y:=0;
            ymin:=infinity;
            ymax:=NegInfinity;
            xmin:=infinity;
            xmax:=NegInfinity;
            while pshxdata^<>0 do
              begin
                {$IFDEF TOTALYLOG}programlog.logoutstr('shx command '+inttohex(pshxdata^,2),0);{$ENDIF}
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
                      incpshxdata;
                      if onlyver=0 then
                        begin
                          baselen:=baselen/pshxdata^;
                          {$IFDEF TOTALYLOG}programlog.logoutstr('('+inttostr(pshxdata^)+')',0);{$ENDIF}
                        end;
                    end;
                  004:
                    begin
                      incpshxdata;
                      if onlyver=0 then
                        begin
                          baselen:=baselen*pshxdata^;
                        end;
                        {$IFDEF TOTALYLOG}programlog.logoutstr('('+inttostr(pshxdata^)+')',0);{$ENDIF}
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
                      incpshxdata;
                      if unicode then
                                     begin
                                          subsymbol:=256*((pshxdata)^);
                                          incpshxdata;
                                          subsymbol:=subsymbol+((pshxdata)^);
                                     end
                                 else
                                     begin
                                          subsymbol:=pshxdata^;
                                     end;
                      {$IFDEF TOTALYLOG}programlog.logoutstr('('+inttostr(subsymbol)+')',0);{$ENDIF}
                      psubsyminfo:=pf^.GetOrCreateSymbolInfo(subsymbol);
                      psubsymbol:=pf.SHXdata.getelement(psubsyminfo.addr);
                      xb:=x;
                      yb:=y;
                      if (psubsymbol<>nil){and(subsymbol<>111)} then
                        for i:=1 to {pf^.symbo linfo[subsymbol]}psubsyminfo.size do
                          begin
                            pf^.SHXdata.AddByteByVal(pGDBByte(psubsymbol)^);//--------------------- pGDBByte(pdata)^:=pGDBByte(psubsymbol)^;
                            //---------------------inc(pdata,sizeof(GDBLineID));
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
                                         ProcessMinMax(x,y);
                                         ProcessMinMax(x1,y1);
                                      {if y>ymax then
                                        ymax:=y;
                                      if y<ymin then
                                        ymin:=y;
                                      if y1>ymax then
                                        ymax:=y1;
                                      if y1<ymin then
                                        ymin:=y1;}
                                    end;
                                                                                                                                                                                                                //pGDBByte(pdata)^:=GDBLineID;
                                                                                                                                                                                                                //inc(pdata,sizeof(GDBLineID));
                                  pf^.SHXdata.AddFontFloat(@x1);//---------------------pfontfloat(pdata)^:=x1;
                                  //---------------------inc(pdata,sizeof(fontfloat));
                                  pf^.SHXdata.AddFontFloat(@y1);//---------------------pfontfloat(pdata)^:=y1;
                                  //---------------------inc(pdata,sizeof(fontfloat));
                                  pf^.SHXdata.AddFontFloat(@x);//---------------------pfontfloat(pdata)^:=x;
                                  //---------------------inc(pdata,sizeof(fontfloat));
                                  pf^.SHXdata.AddFontFloat(@y);//---------------------pfontfloat(pdata)^:=y;
                                  //---------------------inc(pdata,sizeof(fontfloat));
                                  inc(sizeshx);
                                                                                                                                                                                                           //end;
                                end;
                              4:
                                begin
                                  inc(psubsymbol,sizeof(GDBLineID));
                                  sizeshp:=pGDBWord(psubsymbol)^;
                                  pf^.SHXdata.AddWord(@sizeshp);//---------------------pGDBWord(pdata)^:=sizeshp;
                                  inc(psubsymbol,sizeof(GDBWord));
                                  //---------------------inc(pdata,sizeof(GDBWord));

                                  x1:=pfontfloat(psubsymbol)^*baselen*pf^.h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y1:=pfontfloat(psubsymbol)^*baselen*pf^.h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  if draw then
                                    begin
                                         ProcessMinMax(x1,y1);
                                      {if y1>ymax then
                                        ymax:=y1;
                                      if y1<ymin then
                                        ymin:=y1;}
                                    end;//if draw then begin

                                  pf^.SHXdata.AddByteByVal(GDBLineID);//--------------------- pGDBByte(pdata)^:=GDBLineID;
                                  //--------------------- inc(pdata,sizeof(GDBLineID));
                                  pf^.SHXdata.AddFontFloat(@x1);//---------------------pfontfloat(pdata)^:=x1;
                                  //---------------------inc(pdata,sizeof(fontfloat));
                                  pf^.SHXdata.AddFontFloat(@y1);//---------------------pfontfloat(pdata)^:=y1;
                                  //---------------------inc(pdata,sizeof(fontfloat));

                                  j:=1;
                                  while j<>sizeshp do
                                    begin

                                      x:=pfontfloat(psubsymbol)^*baselen*pf^.h+xb;
                                      inc(psubsymbol,sizeof(fontfloat));
                                      y:=pfontfloat(psubsymbol)^*baselen*pf^.h+yb;
                                      inc(psubsymbol,sizeof(fontfloat));
                                      if draw then
                                        begin
                                        ProcessMinMax(x,y);
                                          {if y>ymax then
                                            ymax:=y;
                                          if y<ymin then
                                            ymin:=y;}
                                        end;//if draw then begin;
                                                                                                                                                                                                                        //if draw then begin

                                      pf^.SHXdata.AddFontFloat(@x);//---------------------pfontfloat(pdata)^:=x;
                                      //---------------------inc(pdata,sizeof(fontfloat));
                                      pf^.SHXdata.AddFontFloat(@y);//---------------------pfontfloat(pdata)^:=y;
                                      //---------------------inc(pdata,sizeof(fontfloat));
                                                                                                                                                                                                                                       //end;
                                      inc(j);
                                    end;
                                  inc(sizeshx);

                                end;
                                                                                                                                                             //                            end;

                            end;
                            x:=psubsyminfo.NextSymX+xb;
                            y:=psubsyminfo.SymMinY+yb;
                          end;
                      //dec(pshxdata);
                    end;
                  008:
                    begin
                      incpshxdata;
                      dx:=pShortint(pshxdata)^;
                      incpshxdata;
                      dy:=pShortint(pshxdata)^;
                      {$IFDEF TOTALYLOG}programlog.logoutstr('('+inttostr(dx)+','+inttostr(dy)+')',0);{$ENDIF}
                      if onlyver=0 then
                        begin
                          x1:=x+dx*baselen;
                          y1:=y+dy*baselen;
                          if draw then
                            begin
                              pf^.SHXdata.AddByteByVal(GDBLineID);//---------------------pGDBByte(pdata)^:=GDBLineID;
                              //---------------------inc(pdata,sizeof(GDBLineID));
                              pf^.SHXdata.AddFontFloat(@x);//---------------------pfontfloat(pdata)^:=x;
                              //---------------------inc(pdata,sizeof(fontfloat));
                              pf^.SHXdata.AddFontFloat(@y);//---------------------pfontfloat(pdata)^:=y;
                              //---------------------inc(pdata,sizeof(fontfloat));
                              pf^.SHXdata.AddFontFloat(@x1);//---------------------pfontfloat(pdata)^:=x1;
                              //---------------------inc(pdata,sizeof(fontfloat));
                              pf^.SHXdata.AddFontFloat(@y1);//---------------------pfontfloat(pdata)^:=y1;
                              //---------------------inc(pdata,sizeof(fontfloat));
                              inc(sizeshx);
                              if draw then
                                begin
                                ProcessMinMax(x,y);
                                ProcessMinMax(x1,y1);
                                  {if y>ymax then
                                    ymax:=y;
                                  if y<ymin then
                                    ymin:=y;
                                  if y1>ymax then
                                    ymax:=y1;
                                  if y1<ymin then
                                    ymin:=y1;}
                                end//if draw then begin

                            end;
                          x:=x1;
                          y:=y1;
                        end;
                      x:=x;
                    end;
                  009:
                    begin
                                incpshxdata;
                                dx:=pShortint(pshxdata)^;
                                incpshxdata;
                                dy:=pShortint(pshxdata)^;
                    if (dx<>0)or(dy<>0) then
                    begin
                      if symbol=107 then
                      symbol:=symbol;
                      if onlyver=0 then
                      begin
                      x1:=x+dx*baselen;
                      y1:=y+dy*baselen;
                      end;
                      if draw then
                            begin
                      pf^.SHXdata.AddByteByVal(GDBPolylineID);
                      ppolycount:=pf^.SHXdata.count;
                      pf^.SHXdata.AllocData(sizeof(GDBWord));
                      inc(sizeshx);
                      if (dx<>0)or(dy<>0) then
                                              sizeshp:=1
                                          else
                                              sizeshp:=0;
                      pf^.SHXdata.AddFontFloat(@x);
                      pf^.SHXdata.AddFontFloat(@y);
                            end;
                      while (dx<>0)or(dy<>0) do
                        begin
                        {$IFDEF TOTALYLOG}programlog.logoutstr('('+inttostr(dx)+','+inttostr(dy)+')',0);{$ENDIF}
                          if draw then
                            begin
                              pf^.SHXdata.AddFontFloat(@x1);
                              pf^.SHXdata.AddFontFloat(@y1);
                              inc(sizeshp);
                              if onlyver=0 then
                              begin
                                         ProcessMinMax(x1,y1);
                                {if y1>ymax then
                                  ymax:=y1;
                                if y1<ymin then
                                  ymin:=y1;}
                              end//if draw then begin

                            end;
                        if onlyver=0 then
                        begin
                          x:=x1;
                          y:=y1;
                        end;
                                incpshxdata;
                                dx:=pShortint(pshxdata)^;
                                incpshxdata;
                                dy:=pShortint(pshxdata)^;
                          x1:=x+dx*baselen;
                          y1:=y+dy*baselen;
                          if onlyver=0 then
                          begin
                          x:=x1;
                          y:=y1;

                          ProcessMinMax(x1,y1);
                          {if y1>ymax then
                            ymax:=y1;
                          if y1<ymin then
                            ymin:=y1;}
                          end;
                        end;
                        if draw then
                            begin
                      pGDBWord(pf^.SHXdata.getelement(ppolycount))^:=sizeshp;
                            end;
                      end;
                    end;
                  010:
                    begin
                         incpshxdata;
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
                      incpshxdata;
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

                      pf^.SHXdata.AddByteByVal(GDBPolylineID);//---------------------pGDBByte(pdata)^:=GDBPolylineID;
                      //---------------------inc(pdata,sizeof(GDBPolylineID));
                      ppolycount:=pf^.SHXdata.Count;
                      {ppolycount:=}pf^.SHXdata.AllocData(sizeof(GDBWord));//---------------------ppolycount:=pointer(pdata);
                      //---------------------inc(pdata,sizeof(GDBWord));
                      inc(sizeshx);
                      sizeshp:=1;
                      pf^.SHXdata.AddFontFloat(@x);//---------------------pfontfloat(pdata)^:=x;
                      //---------------------inc(pdata,sizeof(fontfloat));
                      pf^.SHXdata.AddFontFloat(@y);//---------------------pfontfloat(pdata)^:=y;
                      //---------------------inc(pdata,sizeof(fontfloat));
                      x1:=0;
                      y1:=0;
                      for i:=1 to arccount do
                        begin
                          x1:=xb+r*cos(startangle+i/arccount*angle);
                          y1:=yb+r*sin(startangle+i/arccount*angle);
                          if draw then
                            begin
                                         ProcessMinMax(x1,y1);
                              {if y1>ymax then
                                ymax:=y1;
                              if y1<ymin then
                                ymin:=y1;}
                              pf^.SHXdata.AddFontFloat(@x1);//---------------------pfontfloat(pdata)^:=x1;
                              //---------------------inc(pdata,sizeof(fontfloat));
                              pf^.SHXdata.AddFontFloat(@y1);//---------------------pfontfloat(pdata)^:=y1;
                              //---------------------inc(pdata,sizeof(fontfloat));
                              inc(sizeshp);
                            end;
                        end;
                      x:=x1;
                      y:=y1;
                      pGDBWord({ppolycount}pf^.SHXdata.getelement(ppolycount))^:=sizeshp;

                                                                                        {line:=f.readworld(breakshp,ignoreshp);
                                                                                        line:=f.readworld(breakshp,ignoreshp);}
                    end;
                  011:
                    begin
                      incpshxdata;
                      incpshxdata;
                      incpshxdata;
                      incpshxdata;
                      incpshxdata;
                      incpshxdata;
                      {line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);
                      line:=f.readworld(breakshp,ignoreshp);}
                    end;
                  012:
                    begin
                                incpshxdata;
                                dx:=pShortint(pshxdata)^;
                                incpshxdata;
                                dy:=pShortint(pshxdata)^;
                         createarc;

                    end;
                  013:
                    begin
                         tbool:=false;
                         repeat
                         incpshxdata;
                         dx:=pShortint(pshxdata)^;
                         incpshxdata;
                         dy:=pShortint(pshxdata)^;
                         if (dx=0)and(dy=0) then
                                                tbool:=true
                                            else
                                                begin
                                                     //incpshxdata;
                                                     //int:=pShortint(pshxdata)^;
                                                     createarc;
                                                end;
                         until tbool;
                      {incpshxdata;
                      incpshxdata;
                      incpshxdata;}
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
                                pf^.SHXdata.AddByteByVal(GDBLineID);//---------------------pGDBByte(pdata)^:=GDBLineID;
                                //---------------------inc(pdata,sizeof(GDBLineID));
                                pf^.SHXdata.AddFontFloat(@x);//---------------------pfontfloat(pdata)^:=x;
                                //---------------------inc(pdata,sizeof(fontfloat));
                                pf^.SHXdata.AddFontFloat(@y);//---------------------pfontfloat(pdata)^:=y;
                                //---------------------inc(pdata,sizeof(fontfloat));
                                pf^.SHXdata.AddFontFloat(@x1);//---------------------pfontfloat(pdata)^:=x1;
                                //---------------------inc(pdata,sizeof(fontfloat));
                                pf^.SHXdata.AddFontFloat(@y1);//---------------------pfontfloat(pdata)^:=y1;
                                //---------------------inc(pdata,sizeof(fontfloat));
                                inc(sizeshx);
                                ProcessMinMax(x,y);
                                ProcessMinMax(x1,y1);
                                {if y>ymax then
                                  ymax:=y;
                                if y<ymin then
                                  ymin:=y;
                                if y1>ymax then
                                  ymax:=y1;
                                if y1<ymin then
                                  ymin:=y1;}

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
                incpshxdata;
              end;
            psyminfo:=pf^.GetOrCreateSymbolInfo(symbol);
            {pf^.symbo linfo[symbol]}psyminfo.size:=sizeshx;
            {pf^.symbo linfo[symbol]}psyminfo.NextSymX:=x;
            {pf^.symbo linfo[symbol]}psyminfo.SymMaxY:=ymax;//-ymin;
            {pf^.symbo linfo[symbol]}psyminfo.SymMinY:=ymin;
                                     if symbol=32 then
                                                      symbol:=symbol;
                                    if xmax<>NegInfinity then
                                                           psyminfo.SymMaxX:=Xmax
                                                       else
                                                           psyminfo.SymMaxX:=psyminfo.NextSymX;
                                    if xmin<>infinity then
                                                          psyminfo.SymMinX:=Xmin
                                                      else
                                                          psyminfo.SymMinX:=0;
            if symbol=42 then
                             symbol:=symbol;
            psyminfo^.Name:=symname;
            psyminfo^.Number:=symbol;

            result:=inccounter;
          end;

procedure initfont(var pf:pgdbfont;name:gdbstring);
var i:integer;
begin
     //GDBGetMem({$IFDEF DEBUGBUILD}'{2D1F6D71-DF5C-46B1-9E3A-9975CC281FAC}',{$ENDIF}GDBPointer(pf),sizeof(gdbfont));
     pf^.init(name);
end;
function createnewfontfromshx(name:GDBString;var pf:PGDBfont):GDBBoolean;
var
   //f:filestream;
   line{,sub}:GDBANSIString;
   {symmin,}symcount,{symmax,}i,symnum,symlen,datalen,dataread,test:integer;
   memorybuf:GDBOpenArrayOfByte;
   psinfo:ptsyminfo;
   //pf:PGDBfont;
   pdata:pbyte;
begin
  result:=true;
  memorybuf.InitFromFile(name);
  line:=memorybuf.ReadString(#10,#13);
  line:=uppercase(line);
  if (line='AUTOCAD-86 SHAPES 1.0')or(line='AUTOCAD-86 SHAPES 1.1') then
  begin
    {$IFDEF TOTALYLOG}programlog.logoutstr('AUTOCAD-86 SHAPES 1.0',0);{$ENDIF}
  initfont(pf,extractfilename(name));
  pf^.fontfile:=name;
  pf^.unicode:=false;
  pf^.SHXdata.AllocData(2);
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

         if symnum=150 then
                        symnum:=symnum;

         line:=memorybuf.readstring(#0,'');
         datalen:=symlen-length(line)-2;

         if symnum=0 then
                         begin
                              pf^.Internalname:=line;
                              pf^.h:=memorybuf.readbyte;
                              pf^.u:=memorybuf.readbyte;
                              memorybuf.readbyte;
                              line:='';
                         end
                     else
                         begin
                              {$IFDEF TOTALYLOG}programlog.logoutstr('symbol '+inttostr(symnum),lp_IncPos);{$ENDIF}
                              dataread:=createsymbol(pf,symnum,memorybuf.GetCurrentReadAddres,{pdata,}datalen+1,false,line);
                              memorybuf.jump({datalen}dataread);
                              {$IFDEF TOTALYLOG}programlog.logoutstr('end',lp_DecPos);{$ENDIF}
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
        //pf.compiledsize:=pf.SHXdata.Count;
  end
else if line='AUTOCAD-86 UNIFONT 1.0' then
  begin
       {$IFDEF TOTALYLOG}programlog.logoutstr('AUTOCAD-86 UNIFONT 1.0',0);{$ENDIF}
       initfont(pf,extractfilename(name));
       pf^.fontfile:=name;
       pf^.unicode:=true;
       pf^.SHXdata.AllocData(2);
       pdata:=pointer(pf);
       inc(pdata,sizeof(GDBfont));
       {test:=}memorybuf.readbyte;
       symcount:=memorybuf.readword;

       {symmin:=}memorybuf.readword;
       {symmin:=}memorybuf.readword;

       pf^.internalname:=memorybuf.readstring(#0,'');
       pf^.h:=memorybuf.readbyte;
       pf^.u:=memorybuf.readbyte;
       memorybuf.readbyte;
       {test:=}memorybuf.readbyte;
       memorybuf.readbyte;
       memorybuf.readbyte;

  for i:=0 to symcount-2 do
    begin
         symnum:=memorybuf.readword;
         if symnum=49 then
                          symnum:=symnum;
         symlen:=memorybuf.readword;
         datalen:=memorybuf.readbyte;
         if datalen<>0 then
                           begin
                           line:=memorybuf.readstring(#0,'');
                           datalen:=symlen-length(line)-2;
                           end
                       else
                           begin
                           line:='';
                           datalen:=symlen-2;
                           end;

         //datalen:=symlen-length(line)-2;


         //if symnum>255 then
         begin
         test:={uch2ach}(symnum);
         end;
         {else
             test:=symnum;}
         if test=49 then
                         test:=test;
         //if (*pf^.GetOrCreateSymbolInfo(test)^.{ .symbo linfo[test].}addr=0*)symnum<2560000 then
         {$IFDEF TOTALYLOG}programlog.logoutstr('symbol '+inttostr(symnum),lp_IncPos);{$ENDIF}
         {if symnum<256 then }dataread:=createsymbol(pf,test{symnum},memorybuf.GetCurrentReadAddres,{pdata,}datalen+1,true,line);
         {$IFDEF TOTALYLOG}programlog.logoutstr('end',lp_DecPos);{$ENDIF}
         //                                                                 else
         //                                                                     pf:=pf;
         //end;
         memorybuf.jump({datalen}dataread);

                                              //setlength(sub,datalen);
                                              //memorybuf.readdata(@sub[1],datalen);
         {test:=}memorybuf.readbyte;

                                             {line:=strtohex(sub);
                                              line:=inttostr(symnum)+'='+inttostr(datalen)+':'+line;
                                              programlog.logoutstr(line,0);}
         //inc(psinfo);
    end;


  {psinfo:=}memorybuf.GetCurrentReadAddres;
  end
else
    result:=false;
  pf.compiledsize:=pf.SHXdata.Count;
  //pf^.compiledsize:=GDBPlatformint(pdata)-GDBPlatformint(pf);
  //result:=remapmememblock({$IFDEF DEBUGBUILD}'Compiled fonts',{$ENDIF}pf,pf^.compiledsize);
  memorybuf.done;
  //halt(0);
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
          sub:=GetPredStr(line,'=');
          //sub:=Copy(line,1,3);
          val(sub,i,code);

          sub:=GetPredStr(line,',');
          val(sub,palette[i].r,code);

          sub:=GetPredStr(line,',');
          val(sub,palette[i].g,code);

          sub:=GetPredStr(line,':');
          val(sub,palette[i].b,code);
          palette[i].a:=255;
          if line<>'' then
                          palette[i].name:=InterfaceTranslate('rgbcolorname~'+line,line)
                      else
                          palette[i].name:=format(rsColorNum,[i]);
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
  addfromdxf(sysparam.programpath+'block\'+s+'.dxf',pb,tlomerge,gdb.GetCurrentDWG^);
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
