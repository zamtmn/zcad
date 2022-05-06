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

unit uzeenttext;
{$INCLUDE zengineconfig.inc}

interface
uses
    uzglgeometry,uzgldrawcontext,uzeobjectextender,uzetextpreprocessor,uzeentityfactory,
    uzedrawingdef,uzecamera,uzbstrproc,sysutils,uzefont,uzestyleslayers,
    uzeentabstracttext,uzeentity,UGDBOutbound2DIArray,uzctnrVectorBytes,uzbtypes,
    uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,uzeentsubordinated,LazLogger,
    uzegeometrytypes,uzestylestexts,uzeSnap;
type
{Export+}
PGDBObjText=^GDBObjText;
{REGISTEROBJECTTYPE GDBObjText}
GDBObjText= object(GDBObjAbstractText)
                 Content:TDXFEntsInternalStringType;
                 Template:TDXFEntsInternalStringType;(*saved_to_shd*)
                 TXTStyleIndex:{-}PGDBTextStyle{/PGDBTextStyleObjInsp/};(*saved_to_shd*)(*'Style'*)
                 obj_height:Double;(*oi_readonly*)(*hidden_in_objinsp*)
                 obj_width:Double;(*oi_readonly*)(*hidden_in_objinsp*)
                 obj_y:Double;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;c:TDXFEntsInternalStringType;p:GDBvertex;s,o,w,a:Double;j:TTextJustify);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure CalcGabarit(const drawing:TDrawingDef);virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 //procedure createpoint(const drawing:TDrawingDef);virtual;
                 //procedure CreateSymbol(_symbol:Integer;matr:DMatrix4D;var minx,miny,maxx,maxy:Double;pfont:pgdbfont;ln:Integer);
                 function Clone(own:Pointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:String;virtual;
                 destructor done;virtual;

                 function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 procedure rtsave(refp:Pointer);virtual;
                 function IsHaveObjXData:Boolean;virtual;
                 procedure SaveToDXFObjXData(var outhandle:{Integer}TZctnrVectorBytes;var IODXFContext:TIODXFContext);virtual;
                 function ProcessFromDXFObjXData(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef):Boolean;virtual;
                 class function GetDXFIOFeatures:TDXFEntIODataManager;static;

                 function CreateInstance:PGDBObjText;static;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}
var
jt: array[0..3, 0..4] of TTextJustify = ((jsbl, jsbc, jsbr, jsbl, jsmc), (jsbtl, jsbtc, jsbtr, jsbl, jsbl), (jsml, jsmc, jsmr, jsbl, jsbl), (jstl, jstc, jstr, jsbl, jsbl));
j2b: array[TTextJustify] of byte=(1,2,3,4,5,6,7,8,9,10,11,12);
b2j: array[1..12] of TTextJustify=(jstl,jstc,jstr,jsml,jsmc,jsmr,jsbl,jsbc,jsbr,jsbtl,jsbtc,jsbtr);
GDBObjTextDXFFeatures:TDXFEntIODataManager;
//function getsymbol(s:String; i:integer;out l:integer;const fontunicode:Boolean):word;
implementation
function acadvjustify(j:TTextJustify): Byte;
var
  t: Byte;
begin
  t := 3 - (({ord(j)}j2b[j] - 1) div 3);
  if t = 1 then
    result := 0
  else
    result := t;
end;
function GDBObjText.IsHaveObjXData:Boolean;
begin
     if  convertfromunicode(template)<>content then
                              result:=true
                          else
                              result:=false;
end;
function GDBObjText.GetObjTypeName;
begin
     result:=ObjN_GDBObjText;
end;
constructor GDBObjText.initnul;
begin
  inherited initnul(owner);
  //vp.ID := GDBtextID;
  Pointer(content) := nil;
  Pointer(template) := nil;
  textprop.size := 1;
  textprop.oblique := 0;
  textprop.wfactor := 1;
  textprop.justify := jstl;
  //Representation.SHX.init(100);
  //Vertex2D_in_DCS_Array.init({100);
  PProjoutbound:=nil;
end;
constructor GDBObjText.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID := GDBtextID;
  Pointer(content) := nil;
  Pointer(template) := nil;
  content := c;
  Local.p_insert := p;
  textprop.size := s;
  textprop.oblique := o;
  textprop.wfactor := w;
  textprop.justify := j;
  //Representation.SHX.init(1000);
  //Vertex2D_in_DCS_Array.init(100);
  PProjoutbound:=nil;
  //format;
end;
function GDBObjText.GetObjType;
begin
     result:=GDBtextID;
end;
procedure GDBObjText.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
var
      TCP:TCodePage;
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  Representation.Clear;

  TCP:=CodePage;
  CodePage:=CP_win;
     if template='' then
                      template:={UTF8Encode}(content);
  content:={utf8tostring}(textformat(template,@self));
       CodePage:=TCP;
  if (content='')and(template='') then content:=str_empty;
  lod:=0;
  P_drawInOCS:=NulVertex;
  CalcGabarit(drawing);
  case textprop.justify of
    jstl:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        P_drawInOCS.x := 0;
      end;
    jstc:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size / 2;
      end;
    jstr:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size;
      end;
    jsml:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size / 2;
        P_drawInOCS.x := 0;
      end;
    jsmc:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size / 2;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size / 2;
      end;
    jsmr:
      begin
        P_drawInOCS.y := P_drawInOCS.y - textprop.size / 2;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size;
      end;
    jsbl:
      begin
        P_drawInOCS.y := P_drawInOCS.y;
        P_drawInOCS.x := 0;
      end;
    jsbc:
      begin
        P_drawInOCS.y := P_drawInOCS.y;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size / 2;
      end;
    jsbr:
      begin
        P_drawInOCS.y := P_drawInOCS.y;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size;
      end;
    jsbtl:
      begin
        P_drawInOCS.y := P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x := 0;
      end;
    jsbtc:
      begin
        P_drawInOCS.y := P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size / 2;
      end;
     jsbtr:
      begin
        P_drawInOCS.y := P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x := -obj_width * textprop.wfactor * textprop.size;
      end;
  end;
    if (content='')and(template='') then content:=str_empty;
    calcobjmatrix;
    //getoutbound;
    //createpoint(drawing);
    Representation.DrawTextContent(dc.drawer,content,TXTStyleIndex^.pfont,DrawMatrix,objmatrix,textprop.size,Outbound);
    calcbb(dc);

    //P_InsertInWCS:=VectorTransform3D(local.P_insert,vp.owner^.GetMatrix^);
    if assigned(EntExtensions)then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjText.CalcGabarit;
var
  i: Integer;
  psyminfo:PGDBsymdolinfo;
  l:Integer;
  sym:word;
  //-ttf-//TDInfo:TTrianglesDataInfo;
begin
  obj_height:=1;
  obj_width:=0;
  obj_y:=0;
  i:=1;
   while i<=length(content) do
  //for i:=1 to length(content) do
  begin
    sym:=getsymbol_fromGDBText(content,i,l,PGDBTextStyle({gdb.GetCurrentDWG}(TXTStyleIndex))^.pfont^.font.unicode);
    //psyminfo:=PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getDataMutable(TXTStyleIndex))^.pfont^.GetOrReplaceSymbolInfo(ach2uch(Byte(content[i])));
    psyminfo:=PGDBTextStyle({gdb.GetCurrentDWG}(TXTStyleIndex))^.pfont^.GetOrReplaceSymbolInfo(sym{//-ttf-//,tdinfo});
    obj_width:=obj_width+psyminfo.NextSymX;
    if psyminfo.SymMaxY>obj_height then obj_height:=psyminfo.SymMaxY;
    if psyminfo.SymMinY<obj_y then obj_y:=psyminfo.SymMinY;
    inc(i,l);
  end;
  //obj_width:=obj_width-1/3;
end;
function GDBObjText.Clone;
var tvo: PGDBObjtext;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjText));
  tvo^.initnul(nil);
  tvo^.bp.ListPos.Owner:=own;
  //tvo^.vp:=vp;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local:=local;
  tvo^.Textprop:=textprop;
  tvo^.content:=content;
  tvo^.template:=template;
  tvo^.TXTStyleIndex:=TXTStyleIndex;
  //tvo^.Format;
  result := tvo;
end;

procedure GDBObjText.rtsave(refp:Pointer);
begin
  inherited;
  PGDBObjText(refp)^.textprop := textprop;
end;

destructor GDBObjText.done;
begin
  content:='';
  template:='';
  //Representation.SHX.Done;
  //Vertex2D_in_DCS_Array.Done;
  inherited done;
end;
procedure GDBObjText.getoutbound;
var
//  v:GDBvertex4D;
    t,b,l,r,n,f:Double;
    i:integer;

//pm:DMatrix4D;
//    tv:GDBvertex;
//    tpv:GDBPolyVertex2D;
//    ptpv:PGDBPolyVertex3D;
begin

                    (*ptpv:=Vertex3D_in_WCS_Array.parray;
                      l:=ptpv^.coord.x;
                      r:=ptpv^.coord.x;
                      t:=ptpv^.coord.y;
                      b:=ptpv^.coord.y;
                      n:=ptpv^.coord.z;
                      f:=ptpv^.coord.z;
                    pm:=gdb.GetCurrentDWG.pcamera^.modelMatrix;
                    for i:=0 to Vertex3D_in_WCS_Array.count-1 do
                    begin
                           if ptpv^.coord.x<l then
                                                 l:=ptpv^.coord.x;
                          if ptpv^.coord.x>r then
                                                 r:=ptpv^.coord.x;
                          if ptpv^.coord.y<b then
                                                 b:=ptpv^.coord.y;
                          if ptpv^.coord.y>t then
                                                 t:=ptpv^.coord.y;
                          if ptpv^.coord.z<n then
                                                 n:=ptpv^.coord.z;
                          if ptpv^.coord.z>f then
                                                 f:=ptpv^.coord.z;
                         inc(ptpv);
                    end;

                    {outbound[0]:=uzegeometry.CreateVertex(l,t,n);
                    outbound[1]:=uzegeometry.CreateVertex(r,t,n);
                    outbound[2]:=uzegeometry.CreateVertex(r,b,n);
                    outbound[3]:=uzegeometry.CreateVertex(l,b,n);}*)


  (*
  v.x:=0;
  v.y:=obj_y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,DrawMatrix);
  v:=VectorTransform(v,objMatrix);
  outbound[0]:=pgdbvertex(@v)^;
  v.x:=0;
  v.y:={obj_y}+obj_height;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,DrawMatrix);
  v:=VectorTransform(v,objMatrix);
  outbound[1]:=pgdbvertex(@v)^;
  v.x:=obj_width;
  v.y:={obj_y}+obj_height;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,DrawMatrix);
  v:=VectorTransform(v,objMatrix);
  outbound[2]:=pgdbvertex(@v)^;
  v.x:=obj_width;
  v.y:=obj_y;
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,DrawMatrix);
  v:=VectorTransform(v,objMatrix);
  outbound[3]:=pgdbvertex(@v)^;

  *)
  l:=outbound[0].x;
  r:=outbound[0].x;
  t:=outbound[0].y;
  b:=outbound[0].y;
  n:=outbound[0].z;
  f:=outbound[0].z;
  for i:=1 to 3 do
  begin
  if outbound[i].x<l then
                         l:=outbound[i].x;
  if outbound[i].x>r then
                         r:=outbound[i].x;
  if outbound[i].y<b then
                         b:=outbound[i].y;
  if outbound[i].y>t then
                         t:=outbound[i].y;
  if outbound[i].z<n then
                         n:=outbound[i].z;
  if outbound[i].z>f then
                         f:=outbound[i].z;
  end;


  vp.BoundingBox.LBN:=CreateVertex(l,B,n);
  vp.BoundingBox.RTF:=CreateVertex(r,T,f);


  if PProjoutbound=nil then
  begin
       Getmem(Pointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init(4);
  end;
end;
(*procedure GDBObjText.CreateSymbol(_symbol:Integer;matr:DMatrix4D;var minx,miny,maxx,maxy:Double;pfont:pgdbfont;ln:Integer);
var
  psymbol: Pointer;
  i, j, k: Integer;
  len: Word;
  //matr,m1: DMatrix4D;
  v:GDBvertex4D;
  pv:GDBPolyVertex2D;
  pv3:GDBPolyVertex3D;

  plp,plp2:pgdbvertex;
  lp,tv:gdbvertex;
  pl:GDBPoint3DArray;
  ispl:Boolean;
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

  psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(integer(_symbol));
  deb:=psyminfo^;
  psymbol := PGDBfont(pfont)^.SHXdata.getDataMutable({pgdbfont(pfont).symbo linfo[Byte(_symbol)]}psyminfo.addr);// Pointer(PtrInt(pfont)+ pgdbfont(pfont).symbo linfo[Byte(_symbol)].addr);
  if {pgdbfont(pfont)^.symbo linfo[Byte(_symbol)]}psyminfo.size <> 0 then
    for j := 1 to {pgdbfont(pfont)^.symbo linfo[Byte(_symbol)]}psyminfo.size do
    begin
      case Byte(psymbol^) of
        2:
          begin
            inc(PByte(psymbol), sizeof(SHXLine));
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

            //inc(PByte(psymbol), 2 * sizeof(Double));
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
            //inc(PByte(psymbol), 2 * sizeof(Double));
          end;
        4:
          begin
            inc(PByte(psymbol), sizeof(GDBPolylineID));
            len := Word(psymbol^);
            inc(PByte(psymbol), sizeof(Word));
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


            //inc(PByte(psymbol), 2 * sizeof(Double));
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


            //inc(PByte(psymbol), 2 * sizeof(Double));
            inc(k);
            end;
          end;
      end;
    end;
  end;*)
{procedure GDBObjText.createpoint;
begin
  Geom.DUMMYcreatepoint(content,TXTStyleIndex^.pfont,DrawMatrix,objmatrix,textprop.size,Outbound);
end;}
function GDBObjText.getsnap;
begin
     if onlygetsnapcount=1 then
     begin
          result:=false;
          exit;
     end;
     result:=true;
     case onlygetsnapcount of
     0:begin
            if (SnapMode and osm_inspoint)<>0
            then
            begin
            osp.worldcoord:=P_insert_in_WCS;
            osp.dispcoord:=ProjP_insert;
            osp.ostype:=os_textinsert;
            end
            else osp.ostype:=os_none;
       end;
     end;
     inc(onlygetsnapcount);
end;
procedure GDBObjText.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
  if rtmod.point.pointtype=os_point then
    Local.p_insert:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
end;
procedure GDBObjText.SaveToDXFObjXData;
begin
     GetDXFIOFeatures.RunSaveFeatures(outhandle,@self,IODXFContext);
     inherited;
end;
function z2dxftext(s:String):String;
var i:Integer;
begin
     result:=s;
     repeat
          i:=pos(#1,result);
          if i>0 then
                     begin
                          result:=copy(result,1,i-1)+'%%U'+copy(result,i+1,length(result)-i);
                     end;
     until i<=0;
end;
procedure GDBObjText.SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
var
  hv, vv,bw: Byte;
  tv:gdbvertex;
  s:String;
begin
  vv := acadvjustify(textprop.justify);
  hv := (j2b[textprop.justify]{ord(textprop.justify)} - 1) mod 3;
  SaveToDXFObjPrefix(outhandle,'TEXT','AcDbText',IODXFContext);
  tv:=Local.p_insert;
  tv.x:=tv.x+P_drawInOCS.x;
  tv.y:=tv.y+P_drawInOCS.y;
  tv.z:=tv.z+P_drawInOCS.z;
  if hv + vv = 0 then
  begin
    dxfvertexout(outhandle,10,Local.p_insert);
    dxfvertexout(outhandle,11,tv);
  end
  else
  begin
    dxfvertexout(outhandle,11,Local.p_insert);
    dxfvertexout(outhandle,10,tv);
  end;
  dxfDoubleout(outhandle,40,textprop.size);
  dxfDoubleout(outhandle,50,CalcRotate*180/pi);
  dxfDoubleout(outhandle,41,textprop.wfactor);
  dxfDoubleout(outhandle,51,textprop.oblique*180/pi);
  dxfIntegerout(outhandle,72,hv);
  bw:=0;
  if textprop.upsidedown then
                             bw:=bw+4;
  if textprop.backward then
                             bw:=bw+2;
  if bw<>0 then
               dxfIntegerout(outhandle,71,bw);
  dxfStringout(outhandle,7,PGDBTextStyle({gdb.GetCurrentDWG}(TXTStyleIndex))^.name);

  SaveToDXFObjPostfix(outhandle);


    if  convertfromunicode(template)=content then
                                               s := Tria_Utf8ToAnsi(UTF8Encode(template))
                                           else
                                               s := Tria_Utf8ToAnsi(UTF8Encode(content));


  dxfStringout(outhandle,1,z2dxftext({content}s));
  dxfStringout(outhandle,100,'AcDbText');
  dxfIntegerout(outhandle,73,vv);
end;
procedure GDBObjText.LoadFromDXF;
var //s{, layername}: String;
  byt{, code}: Integer;
  doublepoint,angleload: Boolean;
  angle:double;
  vv, gv, textbackward: Integer;
  style,tcontent:String;
begin
  //initnul;
  vv := 0;
  gv := 0;
  byt:=readmystrtoint(f);
  angleload:=false;
  doublepoint:=false;
  style:='';
  tcontent:='';
  textbackward:=0;
  angle:=0;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if not dxfvertexload(f,10,byt,Local.P_insert) then
          if dxfvertexload(f,11,byt,P_drawInOCS) then
                                                     doublepoint := true
else if not dxfDoubleload(f,40,byt,textprop.size) then
     if not dxfDoubleload(f,41,byt,textprop.wfactor) then
     if dxfDoubleload(f,50,byt,angle) then
                                             begin
                                               angleload := true;
                                               angle:=angle*pi/180;
                                             end
else if dxfDoubleload(f,51,byt,textprop.oblique) then
                                                        textprop.oblique:=textprop.oblique*pi/180
else if     dxfStringload(f,7,byt,style)then
                                             begin
                                                  TXTStyleIndex :={drawing.GetTextStyleTable^.getDataMutable}(drawing.GetTextStyleTable^.FindStyle(Style,false));
                                                  if TXTStyleIndex=nil then
                                                                      TXTStyleIndex:=pointer(drawing.GetTextStyleTable^.getDataMutable(0));
                                             end
else if not dxfIntegerload(f,72,byt,gv)then
     if not dxfIntegerload(f,73,byt,vv)then
     if not dxfIntegerload(f,71,byt,textbackward)then
     if not dxfStringload(f,1,byt,tcontent)then
                                               {s := }f.readString;
    byt:=readmystrtoint(f);
  end;
  if (textbackward and 4)<>0 then
                                 textprop.upsidedown:=true
                             else
                                 textprop.upsidedown:=false;
  if (textbackward and 2)<>0 then
                                 textprop.backward:=true
                             else
                                 textprop.backward:=false;
  if TXTStyleIndex=nil then
                           begin
                               TXTStyleIndex:=drawing.GetTextStyleTable^.FindStyle('Standard',false);
                               {if TXTStyleIndex=nil then
                                                        TXTStyleIndex:=sysvar.DWG.DWG_CTStyle^;}
                           end;
  OldVersTextReplace(Template);
  OldVersTextReplace(tcontent);
  content:=utf8tostring(Tria_AnsiToUtf8(tcontent));
  textprop.justify := jt[vv, gv];
  if doublepoint then Local.p_Insert := P_drawInOCS;
  //assert(angleload, 'GDBText отсутствует dxf код 50 (угол поворота)');
  if angleload then
  begin
     if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    Local.basis.ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    Local.basis.ox:=CrossVertex(ZWCS,Local.basis.oz);
  local.basis.OX:=VectorTransform3D(local.basis.OX,CreateAffineRotationMatrix(Local.basis.oz,-angle));
  end;
  {if not angleload then
  begin
  Local.ox.x:=cos(self.textprop.angle*pi/180);
  Local.ox.y:=sin(self.textprop.angle*pi/180);
  Local.ox.z:=0;
  end;}
  //format;
end;
function AllocText:PGDBObjText;
begin
  Getmem(result,sizeof(GDBObjText));
end;
function AllocAndInitText(owner:PGDBObjGenericWithSubordinated):PGDBObjText;
begin
  result:=AllocText;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
function GDBObjText.CreateInstance:PGDBObjText;
begin
  result:=AllocAndInitText(nil);
end;
class function GDBObjText.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjTextDXFFeatures;
end;
function GDBObjText.ProcessFromDXFObjXData;
var
   features:TDXFEntIODataManager;
   FeatureLoadProc:TDXFEntLoadFeature;
begin
  result:=false;
  features:=GetDXFIOFeatures;
  if assigned(features) then
  begin
       FeatureLoadProc:=features.GetLoadFeature(_Name);
       if assigned(FeatureLoadProc)then
       begin
            result:=FeatureLoadProc(_Name,_Value,ptu,drawing,@self);
       end;
  end;
  if not(result) then
  result:=inherited ProcessFromDXFObjXData(_Name,_Value,ptu,drawing);
end;
initialization
  RegisterDXFEntity(GDBTextID,'TEXT','Text',@AllocText,@AllocAndInitText);
  GDBObjTextDXFFeatures:=TDXFEntIODataManager.Create;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  GDBObjTextDXFFeatures.Destroy;
end.
