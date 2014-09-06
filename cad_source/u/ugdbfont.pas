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

unit ugdbfont;
{$INCLUDE def.inc}
interface
uses uzgltriangles3darray,ugdbshxfont,memman,UGDBPolyPoint3DArray,gdbobjectsconstdef,strproc,UGDBOpenArrayOfByte{,UGDBPoint3DArray},gdbasetypes,sysutils,gdbase,{UGDBVisibleOpenArray,}geometry{,gdbEntity,UGDBOpenArrayOfPV};
type
{EXPORT+}
PGDBfont=^GDBfont;
GDBfont={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObject)
    fontfile:GDBString;
    Internalname:GDBString;
    font:{PSHXFont}PBASEFont;
    constructor initnul;
    constructor init(n:GDBString);
    procedure ItSHX;
    procedure ItFFT;
    destructor done;virtual;
    function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;
    procedure CreateSymbol(var Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;var Triangles:ZGLTriangle3DArray;_symbol:GDBInteger;const objmatrix:DMatrix4D;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;ln:GDBInteger);
  end;
{EXPORT-}
var
   pbasefont: PGDBfont;
implementation
uses {math,}log;
procedure GDBfont.CreateSymbol(var Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;var Triangles:ZGLTriangle3DArray;_symbol:GDBInteger;const objmatrix:DMatrix4D;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;ln:GDBInteger);
var
  psymbol: GDBPointer;
  {i, }j, k: GDBInteger;
  len: GDBWord;
  //matr,m1: DMatrix4D;
  v:GDBvertex4D;
  v3:GDBVertex;
  //pv:GDBPolyVertex2D;
  pv3:GDBPolyVertex3D;

  //plp,plp2:pgdbvertex;
  //lp,tv:gdbvertex;
  //pl:GDBPoint3DArray;
  //ispl:gdbboolean;
  //ir:itrec;
  psyminfo:PGDBsymdolinfo;
  //deb:GDBsymdolinfo;
  TDInfo:TTrianglesDataInfo;
  PTriangles:PGDBFontVertex2D;
begin
  if _symbol=100 then
                      _symbol:=_symbol;
  {if _symbol<256 then
                    _symbol:=ach2uch(_symbol);}
  if _symbol=32 then
                      _symbol:=_symbol;

  psyminfo:=self.GetOrReplaceSymbolInfo(integer(_symbol),TDInfo);
  if tdinfo.TrianglesSize>0 then
  begin
       PTriangles:=self.font.GetTriangleDataAddr(TDInfo.TrianglesAddr);
       for j:=1 to tdinfo.TrianglesSize do
       begin
            v3.x:=PTriangles.x;
            v3.y:=PTriangles.y;
            v3.z:=0;
            v3:=VectorTransform3D(v3,matr);
            v3:=VectorTransform3D(v3,objmatrix);
            Triangles.Add(@v3);
            inc(PTriangles);
       end;
  end;
  //deb:=psyminfo^;
  psymbol := self.font.GetSymbolDataAddr(psyminfo.addr);
  if {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size <> 0 then
  begin;
    for j := 1 to {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size do
    begin
      case GDBByte(psymbol^) of
        SHXLine:
          begin
            inc(pGDBByte(psymbol), sizeof(SHXLine));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=0;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;

            v:=VectorTransform(v,objmatrix);

            pv3.coord:=PGDBvertex(@v)^;

            //tv:=pv3.coord;
            pv3.LineNumber:=ln;

            pv3.count:=0;
            Vertex3D_in_WCS_Array.add(@pv3);

            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=0;

            pv3.LineNumber:=ln;

            Vertex3D_in_WCS_Array.add(@pv3);


            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=0;
            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
          end;
        SHXPoly:
          begin
            inc(pGDBByte(psymbol), sizeof(SHXPoly));
            len := GDBWord(psymbol^);
            inc(pGDBByte(psymbol), sizeof(GDBWord));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=len;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=len;

            //tv:=pv3.coord;
            pv3.LineNumber:=ln;

            Vertex3D_in_WCS_Array.add(@pv3);


            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            k := 1;
            while k < len do //for k:=1 to len-1 do
            begin
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;

            v:=VectorTransform(v,matr);

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            //pv.coord:=PGDBvertex2D(@v)^;
            //pv.count:=-1;

            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:={-1}k-len+1;

            pv3.LineNumber:=ln;
            //tv:=pv3.coord;

            Vertex3D_in_WCS_Array.add(@pv3);


            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            inc(k);
            end;
          end;
      end;
    end;
  end
  end;
constructor GDBfont.initnul;
begin
     inherited;
     pointer(fontfile):=nil;
end;
destructor GDBfont.done;
begin
     fontfile:='';
     Internalname:='';
     if font<>nil then
                      begin
                           font.done;
                           GDBFreeMem(font);
                      end;
     inherited;
end;
procedure GDBfont.ItSHX;
begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{FB4B76DB-BD4E-449E-A505-9ABF79E7809A}',{$ENDIF}font,sizeof(SHXFont));
     PSHXFont(font)^.init;
end;
procedure GDBfont.ItFFT;
begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{638B5484-83D8-4FEA-AE47-918B8B0CBC08}',{$ENDIF}font,sizeof(TTFFont));
     PTTFFont(font)^.init;
end;
constructor GDBfont.Init;
begin
     initnul;
     inherited;
     font:=nil;
     {GDBGetMem(font,sizeof(SHXFont));
     font^.init;}
end;
function GDBfont.GetOrReplaceSymbolInfo(symbol:GDBInteger; var TrianglesDataInfo:TTrianglesDataInfo):PGDBsymdolinfo;
//var
   //usi:GDBUNISymbolInfo;
begin
     result:=font.GetOrReplaceSymbolInfo(symbol,TrianglesDataInfo);
end;
function GDBfont.GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
begin
     result:=font.GetOrCreateSymbolInfo(symbol);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBFont.initialization');{$ENDIF}
end.
