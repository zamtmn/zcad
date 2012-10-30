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

unit UGDBSHXFont;
{$INCLUDE def.inc}
interface
uses UGDBPolyPoint3DArray,gdbobjectsconstdef,UGDBPoint3DArray,strproc,UGDBOpenArrayOfByte{,UGDBPoint3DArray},gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,{UGDBVisibleOpenArray,}geometry{,gdbEntity,UGDBOpenArrayOfPV};
type
{EXPORT+}
PGDBsymdolinfo=^GDBsymdolinfo;
GDBsymdolinfo=record
    addr: GDBInteger;
    size: GDBWord;
    NextSymX, SymMaxY,SymMinY, SymMaxX,SymMinX, w, h: GDBDouble;
    Name:GDBString;
    Number:GDBInteger;
  end;
PGDBUNISymbolInfo=^GDBUNISymbolInfo;
GDBUNISymbolInfo=record
    symbol:GDBInteger;
    symbolinfo:GDBsymdolinfo;
  end;
TSymbolInfoArray=array [0..255] of GDBsymdolinfo;
PGDBfont=^GDBfont;
GDBfont=object(GDBNamedObject)
    fontfile:GDBString;
    Internalname:GDBString;
    compiledsize:GDBInteger;
    h,u:GDBByte;
    unicode:GDBBoolean;
    symbolinfo:TSymbolInfoArray;
    SHXdata:GDBOpenArrayOfByte;
    unisymbolinfo:GDBOpenArrayOfData;

    constructor initnul;
    constructor init(n:GDBString);
    destructor done;virtual;
    function GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function GetOrReplaceSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
    function findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
    procedure CreateSymbol(var Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;_symbol:GDBInteger;const objmatrix:DMatrix4D;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;ln:GDBInteger);
  end;
{EXPORT-}
var
   pbasefont: PGDBfont;
implementation
uses {math,}log;
procedure GDBfont.CreateSymbol(var Vertex3D_in_WCS_Array:GDBPolyPoint3DArray;_symbol:GDBInteger;const objmatrix:DMatrix4D;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;ln:GDBInteger);
var
  psymbol: GDBPointer;
  i, j, k: GDBInteger;
  len: GDBWord;
  //matr,m1: DMatrix4D;
  v:GDBvertex4D;
  pv:GDBPolyVertex2D;
  pv3:GDBPolyVertex3D;

  plp,plp2:pgdbvertex;
  lp,tv:gdbvertex;
  pl:GDBPoint3DArray;
  ispl:gdbboolean;
  ir:itrec;
  psyminfo:PGDBsymdolinfo;
  deb:GDBsymdolinfo;
begin
  if _symbol=100 then
                      _symbol:=_symbol;
  {if _symbol<256 then
                    _symbol:=ach2uch(_symbol);}
  if _symbol=32 then
                      _symbol:=_symbol;

  psyminfo:=self.GetOrReplaceSymbolInfo(integer(_symbol));
  deb:=psyminfo^;
  psymbol := self.SHXdata.getelement({pgdbfont(pfont).symbo linfo[GDBByte(_symbol)]}psyminfo.addr);// GDBPointer(GDBPlatformint(pfont)+ pgdbfont(pfont).symbo linfo[GDBByte(_symbol)].addr);
  if {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size <> 0 then
    for j := 1 to {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size do
    begin
      case GDBByte(psymbol^) of
        2:
          begin
            inc(pGDBByte(psymbol), sizeof(GDBLineID));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);
            pv.coord:=PGDBvertex2D(@v)^;
            pv.count:=0;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;

            v:=VectorTransform(v,objmatrix);

            pv3.coord:=PGDBvertex(@v)^;

            tv:=pv3.coord;
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


            pv.coord:=PGDBvertex2D(@v)^;
            pv.count:=0;
            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
          end;
        4:
          begin
            inc(pGDBByte(psymbol), sizeof(GDBPolylineID));
            len := GDBWord(psymbol^);
            inc(pGDBByte(psymbol), sizeof(GDBWord));
            PGDBvertex2D(@v)^.x:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            PGDBvertex2D(@v)^.y:=pfontfloat(psymbol)^;
            inc(pfontfloat(psymbol));
            v.z:=0;
            v.w:=1;
            v:=VectorTransform(v,matr);
            pv.coord:=PGDBvertex2D(@v)^;
            pv.count:=len;

            if v.x<minx then minx:=v.x;
            if v.y<miny then miny:=v.y;
            if v.x>maxx then maxx:=v.x;
            if v.y>maxy then maxy:=v.y;


            v:=VectorTransform(v,objmatrix);
            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:=len;

            tv:=pv3.coord;
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
            pv.coord:=PGDBvertex2D(@v)^;
            pv.count:=-1;

            pv3.coord:=PGDBvertex(@v)^;
            pv3.count:={-1}k-len+1;

            pv3.LineNumber:=ln;
            tv:=pv3.coord;

            Vertex3D_in_WCS_Array.add(@pv3);


            //inc(pGDBByte(psymbol), 2 * sizeof(GDBDouble));
            inc(k);
            end;
          end;
      end;
    end;
  end;
constructor GDBfont.initnul;
begin
     inherited;
     pointer(fontfile):=nil;
end;
destructor GDBfont.done;
var i:integer;
    pobj:PGDBUNISymbolInfo;
    ir:itrec;


begin
     fontfile:='';
     Internalname:='';
     for i:=0 to 255 do
     begin
      symbolinfo[i].Name:='';
     end;
          pobj:=unisymbolinfo.beginiterate(ir);
          if pobj<>nil then
          repeat
                pobj^.symbolinfo.Name:='';
                pobj:=unisymbolinfo.iterate(ir);
          until pobj=nil;
     SHXdata.done;
     unisymbolinfo.{FreeAnd}Done;
     inherited;
end;
constructor GDBfont.Init;
var i:integer;
begin
     initnul;
     inherited;
     for i:=0 to 255 do
     begin
      symbolinfo[i].addr:=0;
      symbolinfo[i].size:=0;
     end;
     self.u:=1;
     self.h:=1;
     unicode:=false;
     SHXdata.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1024);
     unisymbolinfo.init({$IFDEF DEBUGBUILD}'{700B6312-B792-4FFE-B514-2F2CD4B47CC2}',{$ENDIF}1000,sizeof(GDBUNISymbolInfo));
end;
function GDBfont.findunisymbolinfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   pobj:PGDBUNISymbolInfo;
   ir:itrec;
   debug:GDBInteger;
begin
     pobj:=unisymbolinfo.beginiterate(ir);
     if pobj<>nil then
     repeat
           debug:=pobj^.symbol;
           debug:=pobj^.symbolinfo.addr;
           if pobj^.symbol=symbol then
                                      begin
                                           result:=@pobj^.symbolinfo;
                                           exit;
                                      end;
           pobj:=unisymbolinfo.iterate(ir);
     until pobj=nil;
     result:=nil;
end;
function GDBfont.GetOrReplaceSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   usi:GDBUNISymbolInfo;
begin
     if symbol=49 then
                        symbol:=symbol;
     if symbol<256 then
                       begin
                       result:=@self.symbolinfo[symbol];
                       if result^.addr=0 then
                                        result:=@self.symbolinfo[ord('?')];
                       end
                   else
                       //result:=@self.symbolinfo[ord('?')]
                       begin
                            result:=findunisymbolinfo(symbol);
                            //result:=@symbolinfo[ord('?')];
                            //usi.symbolinfo:=result^;;
                            if result=nil then
                            begin
                                 result:=@self.symbolinfo[ord('?')];
                                 exit;
                            end;
                            if result^.addr=0 then
                                             result:=@self.symbolinfo[ord('?')];

                       end;
end;
function GDBfont.GetOrCreateSymbolInfo(symbol:GDBInteger):PGDBsymdolinfo;
var
   usi:GDBUNISymbolInfo;
begin
     if symbol<256 then
                       result:=@self.symbolinfo[symbol]
                   else
                       //result:=@self.symbolinfo[0]
                       begin
                            result:=findunisymbolinfo(symbol);
                            if result=nil then
                            begin
                                 usi.symbol:=symbol;
                                 usi.symbolinfo.addr:=0;
                                 usi.symbolinfo.NextSymX:=0;
                                 usi.symbolinfo.SymMaxY:=0;
                                 usi.symbolinfo.h:=0;
                                 usi.symbolinfo.size:=0;
                                 usi.symbolinfo.w:=0;
                                 usi.symbolinfo.SymMinY:=0;
                                 killstring(usi.symbolinfo.Name);
                                 unisymbolinfo.Add(@usi);

                                 result:=@(PGDBUNISymbolInfo(unisymbolinfo.getelement(unisymbolinfo.Count-1))^.symbolinfo);
                            end;
                       end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBGraf.initialization');{$ENDIF}
end.
