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

unit uzeffshx;
{$INCLUDE zengineconfig.inc}
interface
uses uzgprimitivescreator,uzglvectorobject,uzefontmanager,uzefontshx,uzegeometry,
     uzefont,uzbstrproc,{$IFNDEF DELPHI}FileUtil,LCLProc,{$ENDIF}math,sysutils,
     uzegeometrytypes,uzctnrVectorBytes,uzbtypes,uzgprimitives,
     gzctnrVectorTypes,uzbLogIntf;
const
  arccount=16;
  fontdirect:array[0..$F,0..1] of Double=
  ((1,0),(1,0.5),(1,1),(0.5,1),(0,1),(-0.5,1),(-1,1),(-1,0.5),(-1,0),(-1,-0.5),(-1,-1),(-0.5,-1),(0,-1),(0.5,-1),(1,-1),(1,-0.5));
type ptsyminfo=^tsyminfo;
     tsyminfo=record
                           number,size:word;
                     end;
function createnewfontfromshx(name:String;var pf:PGDBfont):Boolean;

implementation

function createsymbol(pf:PGDBfont;symbol:Integer;pshxdata:system.pbyte;unicode:boolean;symname:String):Integer;
var
  i,sizeshp,sizeshx,stackheap:Integer;
  baselen,ymin,ymax,xmin,xmax,x,y,x1,y1,xb,yb,r,startangle,angle,normal,hordlen,tgl:fontfloat;
  stack:array[0..4,0..1] of fontfloat;
  tr:tarcrtmodify;
  hi,lo,byt,byt2,startoffset,endoffset:Byte;
  subsymbol:Integer;
  int:Integer;
  dx,dy:Shortint;
  draw:Boolean;
  onlyver:Integer;
  psyminfo,psubsyminfo:PGDBsymdolinfo;
  inccounter:integer;
  tbool:boolean;
  GeomDataIndex:integer;
  LLPolyLineIndexInArray:TArrayIndex;
  VDCopyParam,VDCopyResultParam:TZGLVectorDataCopyParam;
  symoutbound:TBoundingBox;
  offset:TEntIndexesOffsetData;
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
var
  ad:TArcData;
  j:integer;
begin
     tr.p1.x:=x;
     tr.p1.y:=y;
     tr.p3.x:=x+dx*baselen;
     tr.p3.y:=y+dy*baselen;
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
     normal:=-int*hordlen/2/127;
     tr.p2.x:=x+x1*normal;
     tr.p2.y:=y+y1*normal;
     if draw then
       begin
           ProcessMinMax(tr.p1.x,tr.p1.y);
           ProcessMinMax(tr.p2.x,tr.p2.y);
           ProcessMinMax(tr.p3.x,tr.p3.y);
           if GetArcParamFrom3Point2D(tr,ad) then
           begin
             startangle:=ad.startangle;
             angle:=ad.endangle-ad.startangle;
             if angle<0 then angle := 2*pi+angle;
             inc(sizeshx);

             sizeshp:=0;
             for j:=0 to arccount do
               begin
                 x1:=ad.p.x+(ad.r)*cos(startangle+j/arccount*angle);
                 y1:=ad.p.y+(ad.r)*sin(startangle+j/arccount*angle);
                 if draw then
                   begin
                     ProcessMinMax(x1,y1);
                     //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
                     //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);
                     inc(sizeshp);
                     if j=0 then
                                begin
                                   GeomDataIndex:=pf^.font.FontData.GeomData.Add2DPoint(x1,y1);
                                   DefaultLLPCreator.CreateLLPolyLine(pf^.font.FontData.LLprimitives,GeomDataIndex,arccount+1);
                                end
                            else
                                pf^.font.FontData.GeomData.Add2DPoint(x1,y1);
                   end;
               end;
             //----//pGDBWord(PSHXFont(pf^.font).SHXdata.getDataMutable(ppolycount))^:=sizeshp;
           end
         else
           begin
             {//----//PSHXFont(pf^.font).SHXdata.AddByteByVal(SHXLine);
             tf:=tr.p1.x;
             //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@tf);
             tf:=tr.p1.y;
             //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@tf);
             tf:=tr.p3.x;
             //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@tf);
             tf:=tr.p3.y;
             //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@tf);
             inc(sizeshx);}
           end;
       end;
       x:=tr.p3.x;
       y:=tr.p3.y;
end;
begin
            inccounter:=0;
//            if symbol=1055{П}then
//                                 symbol:=symbol;
            psyminfo:=pf^.GetOrCreateSymbolInfo(symbol);
            PSHXFont(pf^.font).FontData.LLprimitives.AlignDataSize;
            psyminfo.{addr}LLPrimitiveStartIndex:=PSHXFont(pf^.font).FontData.LLprimitives{SHXdata}.Count;//----//
            onlyver:=0;
            sizeshx:=0;
            draw:=true;
            baselen:=1/PSHXFont(pf^.font).h;
            stackheap:=-1;
            x:=0;
            y:=0;
            ymin:=infinity;
            ymax:=NegInfinity;
            xmin:=infinity;
            xmax:=NegInfinity;
            while pshxdata^<>0 do
              begin
                zTraceLn('{T}[SHX_CONTENTS]SHX command %x',[integer(pshxdata^)]);
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
                          zTraceLn('{T}[SHX_CONTENTS]%d',[integer(pshxdata^)]);

                          //programlog.LogOutFormatStr('%d',[integer(pshxdata^)],lp_OldPos,LM_Trace);
                        end;
                    end;
                  004:
                    begin
                      incpshxdata;
                      if onlyver=0 then
                        begin
                          baselen:=baselen*pshxdata^;
                        end;
                        zTraceLn('{T}[SHX_CONTENTS]%d',[integer(pshxdata^)]);

                        //programlog.LogOutFormatStr('%d',[integer(pshxdata^)],lp_OldPos,LM_Trace);
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
                      zTraceLn('{T}[SHX_CONTENTS](%d)',[integer(subsymbol)]);

                      //programlog.LogOutFormatStr('(%d)',[integer(subsymbol)],lp_OldPos,LM_Trace);
                      psubsyminfo:=pf^.GetOrCreateSymbolInfo(subsymbol);

                      if psubsyminfo.LLPrimitiveStartIndex<>-1 then
                      begin
                        VDCopyParam:=pf^.font.FontData.GetCopyParam(psubsyminfo.LLPrimitiveStartIndex,psubsyminfo.LLPrimitiveCount);
                        VDCopyResultParam:=pf^.font.FontData.CopyTo(pf^.font.FontData,VDCopyParam);
                        offset.GeomIndexOffset:=VDCopyResultParam.EID.GeomIndexMin-VDCopyParam.EID.GeomIndexMin;
                        offset.IndexsIndexOffset:=VDCopyResultParam.EID.IndexsIndexMin-VDCopyParam.EID.IndexsIndexMin;
                        pf^.font.FontData.CorrectIndexes(VDCopyResultParam.LLPrimitivesStartIndex,psyminfo.LLPrimitiveCount,VDCopyResultParam.EID.IndexsIndexMin,VDCopyResultParam.EID.IndexsIndexMax-VDCopyResultParam.EID.IndexsIndexMin+1,offset);
                        pf^.font.FontData.MulOnMatrix(VDCopyResultParam.EID.GeomIndexMin,VDCopyResultParam.EID.GeomIndexMax,MatrixMultiply(CreateScaleMatrix(CreateVertex(baselen*PSHXFont(pf^.font).h,baselen*PSHXFont(pf^.font).h,1)),CreateTranslationMatrix(CreateVertex(x,y,0))));
                        symoutbound:=pf^.font.FontData.GetBoundingBbox(VDCopyResultParam.EID.GeomIndexMin,VDCopyResultParam.EID.GeomIndexMax);
                        ProcessMinMax(symoutbound.LBN.x,symoutbound.LBN.y);
                        ProcessMinMax(symoutbound.RTF.x,symoutbound.RTF.y);
                        x:=psubsyminfo.NextSymX+x;
                        y:=psubsyminfo.SymMinY+y;
                        sizeshx:=sizeshx+psubsyminfo.LLPrimitiveCount;
                      end
                         else
                           begin
                             debugln('{E}IOSHX.CreateSymbol(%d), cannot find subform %d',[integer(symbol),integer(subsymbol)]);
                             //programlog.LogOutFormatStr('IOSHX.CreateSymbol(%d), cannot find subform %d',[integer(symbol),integer(subsymbol)],lp_OldPos,LM_Error);
                           end;

                      (*
                      psubsymbol:=PSHXFont(pf^.font).SHXdata.getDataMutable(psubsyminfo.addr);
                      xb:=x;
                      yb:=y;
                      if (psubsymbol<>nil){and(subsymbol<>111)} then
                        for i:=1 to {pf^.symbo linfo[subsymbol]}psubsyminfo.size do
                          begin
                            PSHXFont(pf^.font).SHXdata.AddByteByVal(PByte(psubsymbol)^);//--------------------- PByte(pdata)^:=PByte(psubsymbol)^;
                            //---------------------inc(pdata,sizeof(SHXLine));
                            case PByte(psubsymbol)^ of
                              SHXLine:
                                begin
                                  inc(psubsymbol,sizeof(SHXLine));
                                  x1:=pfontfloat(psubsymbol)^*baselen*PSHXFont(pf^.font).h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y1:=pfontfloat(psubsymbol)^*baselen*PSHXFont(pf^.font).h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  x:=pfontfloat(psubsymbol)^*baselen*PSHXFont(pf^.font).h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y:=pfontfloat(psubsymbol)^*baselen*PSHXFont(pf^.font).h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  if draw then
                                    begin
                                         ProcessMinMax(x,y);
                                         ProcessMinMax(x1,y1);
                                    end;
                                                                                                                                                                                                                //PByte(pdata)^:=SHXLine;
                                                                                                                                                                                                                //inc(pdata,sizeof(SHXLine));
                                  PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
                                  PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);
                                  PSHXFont(pf^.font).SHXdata.AddFontFloat(@x);
                                  PSHXFont(pf^.font).SHXdata.AddFontFloat(@y);
                                  inc(sizeshx);

                                  GeomDataIndex:=pf^.font.FontData.GeomData.Add2DPoint(x1,y1);
                                  pf^.font.FontData.GeomData.Add2DPoint(x,y);
                                  pf^.font.FontData.LLprimitives.AddLLPLine(GeomDataIndex);
                                                                                                                                                                                                           //end;
                                end;
                              SHXPoly:
                                begin
                                  inc(psubsymbol,sizeof(SHXLine));
                                  sizeshp:=pGDBWord(psubsymbol)^;
                                  PSHXFont(pf^.font).SHXdata.AddWord(@sizeshp);//---------------------pGDBWord(pdata)^:=sizeshp;
                                  inc(psubsymbol,sizeof(Word));
                                  //---------------------inc(pdata,sizeof(Word));

                                  x1:=pfontfloat(psubsymbol)^*baselen*PSHXFont(pf^.font).h+xb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  y1:=pfontfloat(psubsymbol)^*baselen*PSHXFont(pf^.font).h+yb;
                                  inc(psubsymbol,sizeof(fontfloat));
                                  if draw then
                                    begin
                                         ProcessMinMax(x1,y1);
                                    end;

                                  PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
                                  PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);

                                  GeomDataIndex:=pf^.font.FontData.GeomData.Add2DPoint(x1,y1);
                                  pf^.font.FontData.LLprimitives.AddLLPPolyLine(GeomDataIndex,sizeshp);

                                  j:=1;
                                  while j<>sizeshp do
                                    begin

                                      x:=pfontfloat(psubsymbol)^*baselen*PSHXFont(pf^.font).h+xb;
                                      inc(psubsymbol,sizeof(fontfloat));
                                      y:=pfontfloat(psubsymbol)^*baselen*PSHXFont(pf^.font).h+yb;
                                      inc(psubsymbol,sizeof(fontfloat));
                                      if draw then
                                        begin
                                        ProcessMinMax(x,y);
                                        end;
                                                                                                                                                                                                                        //if draw then begin

                                      PSHXFont(pf^.font).SHXdata.AddFontFloat(@x);
                                      PSHXFont(pf^.font).SHXdata.AddFontFloat(@y);

                                      pf^.font.FontData.GeomData.Add2DPoint(x,y);
                                                                                                                                                                                                                                       //end;
                                      inc(j);
                                    end;
                                  inc(sizeshx);

                                end;
                                                                                                                                                             //                            end;

                            end;
                            x:=psubsyminfo.NextSymX+xb;
                            y:=psubsyminfo.SymMinY+yb;
                          end;*)
                      //dec(pshxdata);*)
                    end;
                  008:
                    begin
                      incpshxdata;
                      dx:=pShortint(pshxdata)^;
                      incpshxdata;
                      dy:=pShortint(pshxdata)^;
                      zTraceLn('{T}[SHX_CONTENTS](%d,%d)',[integer(dx),integer(dy)]);

                      //programlog.LogOutFormatStr('(%d,%d)',[integer(dx),integer(dy)],lp_OldPos,LM_Trace);
                      if onlyver=0 then
                        begin
                          x1:=x+dx*baselen;
                          y1:=y+dy*baselen;
                          if draw then
                            begin
                              //----//PSHXFont(pf^.font).SHXdata.AddByteByVal(SHXLine);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@x);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@y);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);

                              GeomDataIndex:=pf^.font.FontData.GeomData.Add2DPoint(x,y);
                              pf^.font.FontData.GeomData.Add2DPoint(x1,y1);
                              DefaultLLPCreator.CreateLLLine(pf^.font.FontData.LLprimitives,GeomDataIndex);

                              inc(sizeshx);
                              if draw then
                                begin
                                ProcessMinMax(x,y);
                                ProcessMinMax(x1,y1);
                                end

                            end;
                          x:=x1;
                          y:=y1;
                        end;
//                      x:=x;
                    end;
                  009:
                    begin
                                incpshxdata;
                                dx:=pShortint(pshxdata)^;
                                incpshxdata;
                                dy:=pShortint(pshxdata)^;
                    if (dx<>0)or(dy<>0) then
                    begin
//                      if symbol=107 then
//                      symbol:=symbol;
                      if onlyver=0 then
                      begin
                      x1:=x+dx*baselen;
                      y1:=y+dy*baselen;
                      end;
                      if draw then
                            begin
                      inc(sizeshx);
                      if (dx<>0)or(dy<>0) then
                                              sizeshp:=1
                                          else
                                              sizeshp:=0;
                      ProcessMinMax(x,y);
                      GeomDataIndex:=pf^.font.FontData.GeomData.Add2DPoint(x,y);
                      LLPolyLineIndexInArray:=DefaultLLPCreator.CreateLLPolyLine(pf^.font.FontData.LLprimitives,GeomDataIndex,1{баба ягодка опять, кто считать будет?});

                            end;
                      while (dx<>0)or(dy<>0) do
                        begin
                          zTraceLn('{T}[SHX_CONTENTS](%d,%d)',[integer(dx),integer(dy)]);

                          //programlog.LogOutFormatStr('(%d,%d)',[integer(dx),integer(dy)],lp_OldPos,LM_Trace);
                          if draw then
                            begin
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);
                              inc(sizeshp);

                              pf^.font.FontData.GeomData.Add2DPoint(x1,y1);
                              inc(PTLLPolyLine(pf^.font.FontData.LLprimitives.getDataMutable(LLPolyLineIndexInArray))^.Count);

                              if onlyver=0 then
                              begin
                                         ProcessMinMax(x1,y1);
                              end

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
                      //----//pGDBWord(PSHXFont(pf^.font).SHXdata.getDataMutable(ppolycount))^:=sizeshp;
                            end;
                      end;
                    end;
                  010:
                    begin
                         incpshxdata;
                         r:=pshxdata^*baselen;
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

                      inc(sizeshx);
                      sizeshp:=1;

                      GeomDataIndex:=pf^.font.FontData.GeomData.Add2DPoint(x,y);
                      DefaultLLPCreator.CreateLLPolyLine(pf^.font.FontData.LLprimitives,GeomDataIndex,arccount);

                      x1:=0;
                      y1:=0;
                      for i:=1 to arccount do
                        begin
                          x1:=xb+r*cos(startangle+i/arccount*angle);
                          y1:=yb+r*sin(startangle+i/arccount*angle);
                          if draw then
                            begin
                              ProcessMinMax(x1,y1);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);

                              pf^.font.FontData.GeomData.Add2DPoint(x1,y1);

                              inc(sizeshp);
                            end;
                        end;
                      x:=x1;
                      y:=y1;
                      //----//pGDBWord(PSHXFont(pf^.font).SHXdata.getDataMutable(ppolycount))^:=sizeshp;
                    end;
                  011:
                    begin
                      incpshxdata;
                      startoffset:=pshxdata^;
                      incpshxdata;
                      endoffset:=pshxdata^;
//                      if (startoffset<>0)or(startoffset<>0)then
//                                                               startoffset:=startoffset;
                      incpshxdata;
                      r:=256*pshxdata^*baselen;

                      incpshxdata;
                      r:=r+pshxdata^*baselen;
                   incpshxdata;
                   byt:=pshxdata^;
                   hi:=byt div 16;
                   lo:=byt and $0F;
                   if lo=0 then
                               angle:=2*pi
                           else
                               angle:=sign(Shortint(byt))*lo*pi/4;
                   angle:=angle-sign(Shortint(byt))*pi/180*{round}((endoffset+startoffset)/256*45); { TODO : symbol & wrong in isocp.shx, see errors\5.dxf }
                   startangle:=hi*pi/4+sign(Shortint(byt))*pi/180*{round}(startoffset/256*45);
                   xb:=x-r*cos(startangle);
                   yb:=y-r*sin(startangle);
                   inc(sizeshx);
                   sizeshp:=1;

                   GeomDataIndex:=pf^.font.FontData.GeomData.Add2DPoint(x,y);
                   DefaultLLPCreator.CreateLLPolyLine(pf^.font.FontData.LLprimitives,GeomDataIndex,arccount);

                   x1:=0;
                   y1:=0;
                   for i:=1 to arccount do
                     begin
                       x1:=xb+r*cos(startangle+i/arccount*angle);
                       y1:=yb+r*sin(startangle+i/arccount*angle);
                       if draw then
                         begin
                              ProcessMinMax(x1,y1);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
                              //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);
                              inc(sizeshp);

                              pf^.font.FontData.GeomData.Add2DPoint(x1,y1);

                         end;
                     end;
                   x:=x1;
                   y:=y1;
                   //----//pGDBWord(PSHXFont(pf^.font).SHXdata.getDataMutable(ppolycount))^:=sizeshp;
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
                                //----//PSHXFont(pf^.font).SHXdata.AddByteByVal(SHXLine);
                                //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@x);
                                //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@y);
                                //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@x1);
                                //----//PSHXFont(pf^.font).SHXdata.AddFontFloat(@y1);
                                inc(sizeshx);

                                GeomDataIndex:=pf^.font.FontData.GeomData.Add2DPoint(x,y);
                                pf^.font.FontData.GeomData.Add2DPoint(x1,y1);
                                DefaultLLPCreator.CreateLLLine(pf^.font.FontData.LLprimitives,GeomDataIndex);

                                ProcessMinMax(x,y);
                                ProcessMinMax(x1,y1);
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
            psyminfo.LLPrimitiveCount{size}:=sizeshx;
            psyminfo.NextSymX:=x;
            psyminfo.SymMaxY:=ymax;//-ymin;
            psyminfo.SymMinY:=ymin;
//                                     if symbol=32 then
//                                                      symbol:=symbol;
                                    if xmax<>NegInfinity then
                                                           psyminfo.SymMaxX:=Xmax
                                                       else
                                                           psyminfo.SymMaxX:=psyminfo.NextSymX;
                                    if xmin<>infinity then
                                                          psyminfo.SymMinX:=Xmin
                                                      else
                                                          psyminfo.SymMinX:=0;
//            if symbol=166 then
//                             symbol:=symbol;
            psyminfo^.Name:=symname;
            psyminfo^.Number:=symbol;

            result:=inccounter;
          end;
function CreateSHXFontInstance:PSHXFont;
begin
     Getmem(result,sizeof(SHXFont));
     result^.init;
end;
function createnewfontfromshx(name:String;var pf:PGDBfont):Boolean;
var
   //f:filestream;
   line{,sub}:AnsiString;
   {symmin,}symcount,{symmax,}i,symnum,symlen,datalen,dataread,test:integer;
   memorybuf:TZctnrVectorBytes;
   psinfo:ptsyminfo;
   //pf:PGDBfont;
   pdata:pbyte;
   membufcreated:boolean;
begin
  result:=true;
  membufcreated:=true;
  memorybuf.InitFromFile(name);
  line:=memorybuf.ReadString3(#10,#13);
  line:=uppercase(line);
  if (line='AUTOCAD-86 SHAPES 1.0')or(line='AUTOCAD-86 SHAPES 1.1') then
  begin
    debugln('{D}[SHX]AUTOCAD-86 SHAPES 1.0');
    //programlog.LogOutStr('AUTOCAD-86 SHAPES 1.0',lp_OldPos,LM_Debug);
  initfont(pf,extractfilename(name));
  pf^.font:=CreateSHXFontInstance;
  //pf.ItSHX;
  pf^.fontfile:=name;
  pf^.font.unicode:=false;
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

//         if symnum=150 then
//                        symnum:=symnum;

         line:=memorybuf.readstring3(#0,'');
         datalen:=symlen-length(line)-2;

         if symnum=0 then
                         begin
                              pf^.Internalname:=line;
                              PSHXFont(pf^.font).h:=memorybuf.readbyte;
                              PSHXFont(pf^.font).u:=memorybuf.readbyte;
                              memorybuf.readbyte;
                              line:='';
                         end
                     else
                         begin
                              zTraceLn('{T+}[SHX]symbol %d',[integer(symnum)]);
//                              if symnum=135 then
//                                                symnum:=symnum;
                              //programlog.LogOutFormatStr('symbol %d',[integer(symnum)],lp_IncPos,LM_Trace);
                              dataread:=createsymbol(pf,symnum,memorybuf.GetCurrentReadAddres,false,line);
                              memorybuf.jump({datalen}dataread);
                              zTraceLn('{T-}[SHX]end');
                              //programlog.LogOutStr('end',lp_DecPos,LM_Trace);
                         end;

                                              //setlength(sub,datalen);
                                              //memorybuf.readdata(@sub[1],datalen);
         {test:=}memorybuf.readbyte;

                                             {line:=strtohex(sub);
                                              line:=inttostr(symnum)+'='+inttostr(datalen)+':'+line;
                                              programlog.logoutstr(line,0);}
         inc(psinfo);
    end;
        line:=memorybuf.readstring3('','');
        if membufcreated then
                             begin
                               memorybuf.done;
                               membufcreated:=false;
                             end;
        PSHXFont(pf^.font).FontData.Shrink;
        //pf.compiledsize:=pf.SHXdata.Count;
  end
else if line='AUTOCAD-86 UNIFONT 1.0' then
  begin
       debugln('{D}[SHX]AUTOCAD-86 UNIFONT 1.0');
       //programlog.LogOutStr('AUTOCAD-86 UNIFONT 1.0',lp_OldPos,LM_Debug);
       initfont(pf,extractfilename(name));
       pf^.font:=CreateSHXFontInstance;
       //pf.ItSHX;
       pf^.fontfile:=name;
       pf^.font.unicode:=true;
       pdata:=pointer(pf);
       inc(pdata,sizeof(GDBfont));
       {test:=}memorybuf.readbyte;
       symcount:=memorybuf.readword;

       {symmin:=}memorybuf.readword;
       {symmin:=}memorybuf.readword;

       pf^.internalname:=memorybuf.readstring3(#0,'');
       PSHXFont(pf^.font).h:=memorybuf.readbyte;
       PSHXFont(pf^.font).u:=memorybuf.readbyte;
       memorybuf.readbyte;
       {test:=}memorybuf.readbyte;
       memorybuf.readbyte;
       memorybuf.readbyte;

  for i:=0 to symcount-2 do
    begin
         symnum:=memorybuf.readword;
//         if symnum=49 then
//                          symnum:=symnum;
         symlen:=memorybuf.readword;
         datalen:=memorybuf.readbyte;
         if datalen<>0 then
                           begin
                           line:=memorybuf.readstring3(#0,'');
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
//         if test=49 then
//                         test:=test;
         //if (*pf^.GetOrCreateSymbolInfo(test)^.{ .symbo linfo[test].}addr=0*)symnum<2560000 then
         zTraceLn('{T+}[SHX]symbol %d',[integer(symnum)]);
//         if symnum=135 then
//                           symnum:=symnum;
         //programlog.LogOutFormatStr('symbol %d',[integer(symnum)],lp_IncPos,LM_Trace);
         {if symnum<256 then }dataread:=createsymbol(pf,test{symnum},memorybuf.GetCurrentReadAddres,true,line);
         zTraceLn('{T-}[SHX]end');
         //programlog.LogOutStr('end',lp_DecPos,LM_Trace);
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
  PSHXFont(pf^.font).FontData.Shrink;
  end
else
    result:=false;
  if pf.font<>nil then
  //PSHXFont(pf^.font).compiledsize:=PSHXFont(pf^.font).SHXdata.Count;
  if membufcreated then
                       begin
                         memorybuf.done;
                         membufcreated:=false;
                       end;
end;
initialization
  RegisterFontLoadProcedure('shx','Autocad SHX font',@createnewfontfromshx);
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
end.
