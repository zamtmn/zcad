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

unit uzeFontFileFormatSHX;
{$Mode objfpc}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  FileUtil,Math,SysUtils,
  uzefont,uzgprimitivescreator,uzglvectorobject,uzefontmanager,uzefontshx,uzegeometry,
  uzegeometrytypes,uzctnrVectorBytesStream,uzgprimitives,
  gzctnrVectorTypes,uzbLogIntf,uzefontbase;

function createnewfontfromshx(const Name:string;var pf:PGDBfont):boolean;

implementation

const
  arccount=8;
  fontdirect:array[0..$F] of TzeVector2d=(
  (x:1;y:0),(x:1;y:0.5),(x:1;y:1),(x:0.5;y:1),(x:0;y:1),(x:-0.5;y:1),(x:-1;y:1),(x:-1;y:0.5),
  (x:-1;y:0),(x:-1;y:-0.5),(x:-1;y:-1),(x:-0.5;y:-1),(x:0;y:-1),(x:0.5;y:-1),(x:1;y:-1),(x:1;y:-0.5));

type
  tsyminfo=record
    number,size:word;
  end;
  ptsyminfo=^tsyminfo;

function createsymbol(pf:PGDBfont;symbol:integer;pshxdata:pbyte;unicode:boolean;symname:string):integer;
var
  i,sizeshp,sizeshx,stackheap:integer;
  baselen,r,startangle,angle,normal,hordlen:fontfloat;
  d:TzeVector2FontFloat;
  p,p1,pb:TzePoint2FontFloat;
  br:TBoundingRect;
  stack:array[0..4] of TzePoint2FontFloat;
  tr:tarcrtmodify;
  hi,lo,byt,byt2,startoffset,endoffset:byte;
  subsymbol:integer;
  draw:boolean;
  onlyver:integer;
  psyminfo,psubsyminfo:PGDBsymdolinfo;
  inccounter:integer;
  tbool:boolean;
  GeomDataIndex:integer;
  LLPolyLineIndexInArray:TArrayIndex;
  VDCopyParam,VDCopyResultParam:TZGLVectorDataCopyParam;
  symoutbound:TBoundingBox;
  offset:TEntIndexesOffsetData;
  sine,cosine:double;

  procedure incpshxdata;
  begin
    Inc(pshxdata);
    Inc(inccounter);
  end;

  procedure createarc;
  var
    ad:TArcData;
    j:integer;
    sine,cosine:double;
    int:integer;
  begin
    tr.p1:=p;
    tr.p3:=p+d*baselen;
    p1:=(d*baselen).asPoint2d;
    hordlen:=p1.Length;
    p1:=p1/2;
    normal:=p1.Length;
    p:=p1+p.asVector;
    p1.Turn90L;
    p1.Normalize;
    incpshxdata;
    int:=pShortint(pshxdata)^;
    normal:=-int*hordlen/2/127;
    tr.p2:=p+(p1*normal).asVector;
    if draw then begin
      br.Concat(tr.p1);
      br.Concat(tr.p2);
      br.Concat(tr.p3);
      if GetArcParamFrom3Point2D(tr,ad) then begin
        startangle:=ad.startangle;
        angle:=ad.endangle-ad.startangle;
        if angle<0 then
          angle:=2*pi+angle;
        Inc(sizeshx);

        sizeshp:=0;
        for j:=0 to arccount do begin
          SinCos(startangle+j/arccount*angle,sine,cosine);
          p1:=ad.p+TzeVector2d.Make(cosine,sine)*ad.r;
          if draw then begin
            br.Concat(p1);
            Inc(sizeshp);
            if j=0 then begin
              GeomDataIndex:=pf^.font.FontData.GeomData.AddPoint2D(p1);
              DefaultLLPCreator.CreateLLPolyLine(pf^.font.FontData.LLprimitives,GeomDataIndex,arccount+1);
            end else
              pf^.font.FontData.GeomData.AddPoint2d(p1);
          end;
        end;
      end else begin
      end;
    end;
    p:=tr.p3;
  end;

begin
  inccounter:=0;
  psyminfo:=pf^.GetOrCreateSymbolInfo(symbol);
  TZESHXFontImpl(pf^.font).FontData.LLprimitives.AlignDataSize;
  psyminfo^.LLPrimitiveStartIndex:=TZESHXFontImpl(pf^.font).FontData.LLprimitives.Count;
  onlyver:=0;
  sizeshx:=0;
  draw:=True;
  baselen:=1/TZESHXFontImpl(pf^.font).h;
  stackheap:=-1;
  p1.Fill(0);
  p.Fill(0);
  br.Fill(Infinity,NegInfinity);
  while pshxdata^<>0 do begin
    zTraceLn('{T}[SHX_CONTENTS]SHX command %x',[integer(pshxdata^)]);
    case pshxdata^ of
      001:begin
        if onlyver=0 then begin
          draw:=True;
        end;
      end;
      002:begin
        if onlyver=0 then begin
          draw:=False;
        end;
      end;
      003:begin
        incpshxdata;
        if onlyver=0 then begin
          baselen:=baselen/pshxdata^;
          zTraceLn('{T}[SHX_CONTENTS]%d',[integer(pshxdata^)]);
        end;
      end;
      004:begin
        incpshxdata;
        if onlyver=0 then begin
          baselen:=baselen*pshxdata^;
        end;
        zTraceLn('{T}[SHX_CONTENTS]%d',[integer(pshxdata^)]);
      end;
      005:begin
        if onlyver=0 then begin
          Inc(stackheap);
          stack[stackheap]:=p;
        end;
      end;
      006:begin
        if (onlyver=0)and(stackheap>=0) then begin
          p:=stack[stackheap];
          Dec(stackheap);
        end;
      end;
      007:begin
        incpshxdata;
        if unicode then begin
          subsymbol:=256*((pshxdata)^);
          incpshxdata;
          subsymbol:=subsymbol+((pshxdata)^);
        end else begin
          subsymbol:=pshxdata^;
        end;
        zTraceLn('{T}[SHX_CONTENTS](%d)',[integer(subsymbol)]);
        psubsyminfo:=pf^.GetOrCreateSymbolInfo(subsymbol);

        if psubsyminfo^.LLPrimitiveStartIndex<>-1 then begin
          VDCopyParam:=pf^.font.FontData.GetCopyParam(psubsyminfo^.LLPrimitiveStartIndex,
            psubsyminfo^.LLPrimitiveCount);
          VDCopyResultParam:=pf^.font.FontData.CopyTo(pf^.font.FontData,VDCopyParam);
          offset.GeomIndexOffset:=VDCopyResultParam.EID.GeomIndexMin-VDCopyParam.EID.GeomIndexMin;
          offset.IndexsIndexOffset:=VDCopyResultParam.EID.IndexsIndexMin-VDCopyParam.EID.IndexsIndexMin;
          pf^.font.FontData.CorrectIndexes(VDCopyResultParam.LLPrimitivesStartIndex,
            psyminfo^.LLPrimitiveCount,VDCopyResultParam.EID.IndexsIndexMin,
            VDCopyResultParam.EID.IndexsIndexMax-VDCopyResultParam.EID.IndexsIndexMin+1,offset);
          pf^.font.FontData.MulOnMatrix(VDCopyResultParam.EID.GeomIndexMin,VDCopyResultParam.EID.GeomIndexMax,
            MatrixMultiply(CreateScaleMatrix(TzeVector3d.Make(baselen*TZESHXFontImpl(pf^.font).h,
                                                              baselen*TZESHXFontImpl(pf^.font).h,1)),
            CreateTranslationMatrix(TzeVector3d.Make(p.x,p.y,0))));
          symoutbound:=pf^.font.FontData.GetBoundingBbox(VDCopyResultParam.EID.GeomIndexMin,
            VDCopyResultParam.EID.GeomIndexMax);
          br.Concat(symoutbound.LBN.Slice);
          br.Concat(symoutbound.RTF.Slice);
          p:=p+TzeVector2d.Make(psubsyminfo^.NextSymX,psubsyminfo^.SymMinY);
          sizeshx:=sizeshx+psubsyminfo^.LLPrimitiveCount;
        end else begin
          zDebugLn('{E}IOSHX.CreateSymbol(%d), cannot find subform %d',[integer(symbol),integer(subsymbol)]);
        end;
      end;
      008:begin
        incpshxdata;
        d.x:=pShortint(pshxdata)^;
        incpshxdata;
        d.y:=pShortint(pshxdata)^;
        zTraceLn('{T}[SHX_CONTENTS](%e,%e)',[d.x,d.y]);
        if onlyver=0 then begin
          p1:=p+d*baselen;
          if draw then begin
            GeomDataIndex:=pf^.font.FontData.GeomData.AddPoint2D(p);
            pf^.font.FontData.GeomData.AddPoint2D(p1);
            DefaultLLPCreator.CreateLLLine(pf^.font.FontData.LLprimitives,GeomDataIndex);

            Inc(sizeshx);
            if draw then begin
              br.Concat(p);
              br.Concat(p1);
            end;

          end;
          p:=p1;
        end;
      end;
      009:begin
        incpshxdata;
        d.x:=pShortint(pshxdata)^;
        incpshxdata;
        d.y:=pShortint(pshxdata)^;
        if (d.x<>0)or(d.y<>0) then begin
          if onlyver=0 then begin
            p1:=p+d*baselen;
          end;
          if draw then begin
            Inc(sizeshx);
            if (d.x<>0)or(d.y<>0) then
              sizeshp:=1
            else
              sizeshp:=0;
            br.Concat(p);
            GeomDataIndex:=pf^.font.FontData.GeomData.AddPoint2d(p);
            LLPolyLineIndexInArray:=DefaultLLPCreator.CreateLLPolyLine(pf^.font.FontData.LLprimitives,
              GeomDataIndex,1);
          end;
          while (d.x<>0)or(d.y<>0) do begin
            zTraceLn('{T}[SHX_CONTENTS](%e,%e)',[d.x,d.y]);
            if draw then begin
              Inc(sizeshp);
              pf^.font.FontData.GeomData.AddPoint2D(p1);
              Inc(PTLLPolyLine(pf^.font.FontData.LLprimitives.getDataMutable(LLPolyLineIndexInArray))^.Count);

              if onlyver=0 then begin
                br.Concat(p1);
              end;

            end;
            if onlyver=0 then begin
              p:=p1;
            end;
            incpshxdata;
            d.x:=pShortint(pshxdata)^;
            incpshxdata;
            d.y:=pShortint(pshxdata)^;
            p1:=p+d*baselen;
            if onlyver=0 then begin
              p:=p1;
              br.Concat(p1);
            end;
          end;
          if draw then begin
          end;
        end;
      end;
      010:begin
        incpshxdata;
        r:=pshxdata^*baselen;
        incpshxdata;
        byt:=pshxdata^;
        hi:=byt div 16;
        lo:=byt and $0F;
        if lo=0 then
          angle:=2*pi
        else
          angle:=sign(shortint(byt))*lo*pi/4;
        startangle:=hi*pi/4;

        SinCos(startangle,sine,cosine);
        pb:=p-TzeVector2d.Make(cosine,sine)*r;
        Inc(sizeshx);
        sizeshp:=1;
        GeomDataIndex:=pf^.font.FontData.GeomData.AddPoint2D(p);
        DefaultLLPCreator.CreateLLPolyLine(pf^.font.FontData.LLprimitives,GeomDataIndex,arccount+1);
        for i:=1 to arccount do begin
          SinCos(startangle+i/arccount*angle,sine,cosine);
          p1:=pb+TzeVector2d.Make(cosine,sine)*r;
          if draw then begin
            br.Concat(p1);
            pf^.font.FontData.GeomData.AddPoint2D(p1);
            Inc(sizeshp);
          end;
        end;
        p:=p1;
      end;
      011:begin
        incpshxdata;
        startoffset:=pshxdata^;
        incpshxdata;
        endoffset:=pshxdata^;
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
        else begin
          { без (lo-1) символ "&" из isocp.shx рендерится неточно см. errors\shx.dxf }
          if endoffset=0 then
            angle:=sign(shortint(byt))*lo*pi/4
          else
            angle:=sign(shortint(byt))*(lo-1)*pi/4;
        end;

        angle:=angle+sign(shortint(byt))*pi/180*((endoffset-startoffset)/256*45);
        startangle:=hi*pi/4+sign(shortint(byt))*pi/180*(startoffset/256*45);
        SinCos(startangle,sine,cosine);
        pb:=p-TzeVector2d.Make(cosine,sine)*r;
        Inc(sizeshx);
        sizeshp:=1;
        GeomDataIndex:=pf^.font.FontData.GeomData.AddPoint2D(p);
        DefaultLLPCreator.CreateLLPolyLine(pf^.font.FontData.LLprimitives,GeomDataIndex,arccount+1);
        for i:=1 to arccount do begin
          SinCos(startangle+i/arccount*angle,sine,cosine);
          p1:=pb+TzeVector2d.Make(cosine,sine)*r;
          if draw then begin
            br.Concat(p1);
            Inc(sizeshp);
            pf^.font.FontData.GeomData.AddPoint2D(p1);
          end;
        end;
        p:=p1;
      end;
      012:begin
        incpshxdata;
        d.x:=pShortint(pshxdata)^;
        incpshxdata;
        d.y:=pShortint(pshxdata)^;
        createarc;

      end;
      013:begin
        tbool:=False;
        repeat
          incpshxdata;
          d.x:=pShortint(pshxdata)^;
          incpshxdata;
          d.y:=pShortint(pshxdata)^;
          if (d.x=0)and(d.y=0) then
            tbool:=True
          else begin
            createarc;
          end;
        until tbool;
      end;
      014:begin
        if onlyver=0 then
          onlyver:=2
        else
          Inc(onlyver);
      end;
      else
      begin
        begin
          if onlyver=0 then begin
            byt2:=pshxdata^div 16;
            p1:=fontdirect[(pshxdata^and $0F)].asPoint2d;
            p1:=p+p1.asVector*baselen*byt2;
            if draw then begin
              Inc(sizeshx);
              GeomDataIndex:=pf^.font.FontData.GeomData.AddPoint2D(p);
              pf^.font.FontData.GeomData.AddPoint2D(p1);
              DefaultLLPCreator.CreateLLLine(pf^.font.FontData.LLprimitives,GeomDataIndex);

              br.Concat(p);
              br.Concat(p1);
            end;
            p:=p1;
          end;
        end;
      end;
    end;
    if onlyver>0 then
      Dec(onlyver);
    incpshxdata;
  end;
  psyminfo:=pf^.GetOrCreateSymbolInfo(symbol);
  psyminfo^.LLPrimitiveCount:=sizeshx;
  psyminfo^.NextSymX:=p.x;
  psyminfo^.SymMaxY:=br.RTF.y;
  psyminfo^.SymMinY:=br.LBN.y;
  if br.RTF.x<>NegInfinity then
    psyminfo^.SymMaxX:=br.RTF.x
  else
    psyminfo^.SymMaxX:=psyminfo^.NextSymX;
  if br.LBN.x<>infinity then
    psyminfo^.SymMinX:=br.LBN.x
  else
    psyminfo^.SymMinX:=0;
  psyminfo^.Name:=symname;
  psyminfo^.Number:=symbol;

  Result:=inccounter;
end;

function createnewfontfromshx(const Name:string;var pf:PGDBfont):boolean;
var
  line:ansistring;
  symcount,i,symnum,symlen,datalen,dataread,test:integer;
  memorybuf:TZctnrVectorBytes;
  psinfo:ptsyminfo;
  pdata:pbyte;
  membufcreated:boolean;
begin
  Result:=True;
  membufcreated:=True;
  memorybuf.InitFromFile(Name);
  line:=memorybuf.ReadString3(#10,#13);
  line:=uppercase(line);
  if (line='AUTOCAD-86 SHAPES 1.0')or(line='AUTOCAD-86 SHAPES 1.1') then begin
    zDebugLn('{D}[SHX]AUTOCAD-86 SHAPES 1.0');
    initfont(pf,extractfilename(Name));
    pf^.font:=TZESHXFontImpl.Create;
    pf^.fontfile:=Name;
    pdata:=pointer(pf);
    Inc(pdata,sizeof(GDBfont));
    memorybuf.readbyte;

    memorybuf.readword;
    memorybuf.readword;
    symcount:=memorybuf.readword;

    psinfo:=memorybuf.GetCurrentReadAddres;

    for i:=0 to symcount-1 do begin
      memorybuf.readword;
      memorybuf.readword;
    end;
    for i:=0 to symcount-1 do begin
      symlen:=psinfo^.size;
      symnum:=psinfo^.number;
      line:=memorybuf.readstring3(#0,'');
      datalen:=symlen-length(line)-2;
      if symnum=0 then begin
        pf^.Internalname:=line;
        TZESHXFontImpl(pf^.font).h:=memorybuf.readbyte;
        TZESHXFontImpl(pf^.font).u:=memorybuf.readbyte;
        memorybuf.readbyte;
        line:='';
      end else begin
        zTraceLn('{T+}[SHX]symbol %d',[integer(symnum)]);
        dataread:=createsymbol(pf,symnum,memorybuf.GetCurrentReadAddres,False,line);
        memorybuf.jump(dataread);
        zTraceLn('{T-}[SHX]end');
      end;
      memorybuf.readbyte;
      Inc(psinfo);
    end;
    line:=memorybuf.readstring3('','');
    if membufcreated then begin
      memorybuf.done;
      membufcreated:=False;
    end;
    TZESHXFontImpl(pf^.font).FontData.Shrink;
  end else if line='AUTOCAD-86 UNIFONT 1.0' then begin
    zDebugLn('{D}[SHX]AUTOCAD-86 UNIFONT 1.0');
    initfont(pf,extractfilename(Name));
    pf^.font:=TZESHXFontImpl.Create;
    pf^.fontfile:=Name;
    TZESHXFontImpl(pf^.font).unicode:=True;
    pdata:=pointer(pf);
    Inc(pdata,sizeof(GDBfont));
    memorybuf.readbyte;
    symcount:=memorybuf.readword;

    memorybuf.readword;
    memorybuf.readword;

    pf^.internalname:=memorybuf.readstring3(#0,'');
    TZESHXFontImpl(pf^.font).h:=memorybuf.readbyte;
    TZESHXFontImpl(pf^.font).u:=memorybuf.readbyte;
    memorybuf.readbyte;
    memorybuf.readbyte;
    memorybuf.readbyte;
    memorybuf.readbyte;

    for i:=0 to symcount-2 do begin
      symnum:=memorybuf.readword;
      symlen:=memorybuf.readword;
      datalen:=memorybuf.readbyte;
      if datalen<>0 then begin
        line:=memorybuf.readstring3(#0,'');
        datalen:=symlen-length(line)-2;
      end else begin
        line:='';
        datalen:=symlen-2;
      end;

      test:=symnum;

      zTraceLn('{T+}[SHX]symbol %d',[integer(symnum)]);
      dataread:=createsymbol(pf,test,memorybuf.GetCurrentReadAddres,True,line);
      zTraceLn('{T-}[SHX]end');
      memorybuf.jump(dataread);
      memorybuf.readbyte;
    end;
    memorybuf.GetCurrentReadAddres;
    TZESHXFontImpl(pf^.font).FontData.Shrink;
  end else
    Result:=False;
  if pf^.font<>nil then
    if membufcreated then begin
      memorybuf.done;
      membufcreated:=False;
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
