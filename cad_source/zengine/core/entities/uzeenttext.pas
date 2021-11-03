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
{$INCLUDE def.inc}

interface
uses
    uzglgeometry,uzgldrawcontext,uzeobjectextender,uzetextpreprocessor,uzeentityfactory,
    uzedrawingdef,uzecamera,uzbstrproc,sysutils,uzefont,uzestyleslayers,uzbtypesbase,
    uzeentabstracttext,uzeentity,UGDBOutbound2DIArray,UGDBOpenArrayOfByte,uzbtypes,
    uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,uzbmemman,uzeentsubordinated,LazLogger,
    uzbgeomtypes,uzestylestexts;
type
{Export+}
PGDBObjText=^GDBObjText;
{REGISTEROBJECTTYPE GDBObjText}
GDBObjText= object(GDBObjAbstractText)
                 Content:TDXFEntsInternalStringType;
                 Template:TDXFEntsInternalStringType;(*saved_to_shd*)
                 TXTStyleIndex:{-}PGDBTextStyle{/PGDBTextStyleObjInsp/};(*saved_to_shd*)(*'Style'*)
                 obj_height:GDBDouble;(*oi_readonly*)(*hidden_in_objinsp*)
                 obj_width:GDBDouble;(*oi_readonly*)(*hidden_in_objinsp*)
                 obj_y:GDBDouble;(*oi_readonly*)(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint;c:TDXFEntsInternalStringType;p:GDBvertex;s,o,w,a:GDBDouble;j:TTextJustify);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure LoadFromDXF(var f: GDBOpenArrayOfByte;ptu:PExtensionData;var drawing:TDrawingDef);virtual;
                 procedure SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure CalcGabarit(const drawing:TDrawingDef);virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 //procedure createpoint(const drawing:TDrawingDef);virtual;
                 //procedure CreateSymbol(_symbol:GDBInteger;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;pfont:pgdbfont;ln:GDBInteger);
                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 function GetObjTypeName:GDBString;virtual;
                 destructor done;virtual;

                 function getsnap(var osp:os_record; var pdata:GDBPointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):GDBBoolean;virtual;
                 procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
                 procedure rtedit(refp:GDBPointer;mode:GDBFloat;dist,wc:gdbvertex);virtual;
                 function IsHaveObjXData:GDBBoolean;virtual;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var IODXFContext:TIODXFContext);virtual;
                 function ProcessFromDXFObjXData(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef):GDBBoolean;virtual;
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
//function getsymbol(s:gdbstring; i:integer;out l:integer;const fontunicode:gdbboolean):word;
implementation
function acadvjustify(j:TTextJustify): GDBByte;
var
  t: GDBByte;
begin
  t := 3 - (({ord(j)}j2b[j] - 1) div 3);
  if t = 1 then
    result := 0
  else
    result := t;
end;
function GDBObjText.IsHaveObjXData:GDBBoolean;
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
  GDBPointer(content) := nil;
  GDBPointer(template) := nil;
  textprop.size := 1;
  textprop.oblique := 0;
  textprop.wfactor := 1;
  textprop.justify := jstl;
  //Representation.SHX.init({$IFDEF DEBUGBUILD}'{08E35ED5-B4A7-4210-A3C9-0645E8F27ABA}-GDBText.Vertex3D_in_WCS_Array',{$ENDIF}100);
  //Vertex2D_in_DCS_Array.init({$IFDEF DEBUGBUILD}'{116E3B21-8230-44E8-B7A5-9CEED4B886D2}',{$ENDIF}100);
  PProjoutbound:=nil;
end;
constructor GDBObjText.init;
begin
  inherited init(own,layeraddres, lw);
  //vp.ID := GDBtextID;
  GDBPointer(content) := nil;
  GDBPointer(template) := nil;
  content := c;
  Local.p_insert := p;
  textprop.size := s;
  textprop.oblique := o;
  textprop.wfactor := w;
  textprop.justify := j;
  //Representation.SHX.init({$IFDEF DEBUGBUILD}'{8776360E-8115-4773-917D-83ED1843FF9C}',{$ENDIF}1000);
  //Vertex2D_in_DCS_Array.init({$IFDEF DEBUGBUILD}'{EDC6D76B-DDFF-41A0-ACCC-48804795A3F5}',{$ENDIF}100);
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
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing);

  Representation.Clear;

  TCP:=CodePage;
  CodePage:=CP_win;
     if template='' then
                      template:={UTF8Encode}(content);
  content:=utf8tostring(textformat(template,@self));
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
end;
procedure GDBObjText.CalcGabarit;
var
  i: GDBInteger;
  psyminfo:PGDBsymdolinfo;
  l:GDBInteger;
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
    //psyminfo:=PGDBTextStyle(gdb.GetCurrentDWG.TextStyleTable.getDataMutable(TXTStyleIndex))^.pfont^.GetOrReplaceSymbolInfo(ach2uch(GDBByte(content[i])));
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
  GDBGetMem({$IFDEF DEBUGBUILD}'{4098811D-F8A9-4562-8803-38AAEA1A0D64}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjText));
  tvo^.initnul(nil);
  tvo^.bp.ListPos.Owner:=own;
  //tvo^.vp:=vp;
  CopyVPto(tvo^);
  tvo^.Local:=local;
  tvo^.Textprop:=textprop;
  tvo^.content:=content;
  tvo^.template:=template;
  tvo^.TXTStyleIndex:=TXTStyleIndex;
  //tvo^.Format;
  result := tvo;
end;

procedure GDBObjText.rtedit;
begin
  if mode = os_textinsert then
  begin
    Local.p_insert := VertexAdd(pgdbobjtext(refp)^.Local.p_insert, dist);
    calcobjmatrix;
    //format;
  end
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
    t,b,l,r,n,f:GDBDouble;
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
       GDBGetMem({$IFDEF DEBUGBUILD}'{4C06C975-C569-4020-8DA7-27CD949B9298}',{$ENDIF}GDBPointer(PProjoutbound),sizeof(GDBOOutbound2DIArray));
       PProjoutbound^.init({$IFDEF DEBUGBUILD}'{AB29B448-057C-4018-BC57-E8C67A3765AF}',{$ENDIF}4);
  end;
end;
(*procedure GDBObjText.CreateSymbol(_symbol:GDBInteger;matr:DMatrix4D;var minx,miny,maxx,maxy:GDBDouble;pfont:pgdbfont;ln:GDBInteger);
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

  psyminfo:=pgdbfont(pfont)^.GetOrReplaceSymbolInfo(integer(_symbol));
  deb:=psyminfo^;
  psymbol := PGDBfont(pfont)^.SHXdata.getDataMutable({pgdbfont(pfont).symbo linfo[GDBByte(_symbol)]}psyminfo.addr);// GDBPointer(GDBPlatformint(pfont)+ pgdbfont(pfont).symbo linfo[GDBByte(_symbol)].addr);
  if {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size <> 0 then
    for j := 1 to {pgdbfont(pfont)^.symbo linfo[GDBByte(_symbol)]}psyminfo.size do
    begin
      case GDBByte(psymbol^) of
        2:
          begin
            inc(pGDBByte(psymbol), sizeof(SHXLine));
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
//var m:DMatrix4D;
begin
     //m:=bp.owner.getmatrix^;
     //MatrixInvert(m);
          case rtmod.point.pointtype of
               os_point:begin
                             Local.p_insert:=VertexAdd(rtmod.point.worldcoord, rtmod.dist);
                        end;
          end;
end;
procedure GDBObjText.SaveToDXFObjXData;
begin
     GetDXFIOFeatures.RunSaveFeatures(outhandle,@self,IODXFContext);
     inherited;
end;
function z2dxftext(s:gdbstring):gdbstring;
var i:GDBInteger;
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
procedure GDBObjText.SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
var
  hv, vv,bw: GDBByte;
  tv:gdbvertex;
  s:GDBString;
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
  dxfGDBDoubleout(outhandle,40,textprop.size);
  dxfGDBDoubleout(outhandle,50,CalcRotate*180/pi);
  dxfGDBDoubleout(outhandle,41,textprop.wfactor);
  dxfGDBDoubleout(outhandle,51,textprop.oblique*180/pi);
  dxfGDBIntegerout(outhandle,72,hv);
  bw:=0;
  if textprop.upsidedown then
                             bw:=bw+4;
  if textprop.backward then
                             bw:=bw+2;
  if bw<>0 then
               dxfGDBIntegerout(outhandle,71,bw);
  dxfGDBStringout(outhandle,7,PGDBTextStyle({gdb.GetCurrentDWG}(TXTStyleIndex))^.name);

  SaveToDXFObjPostfix(outhandle);


    if  convertfromunicode(template)=content then
                                               s := Tria_Utf8ToAnsi(UTF8Encode(template))
                                           else
                                               s := Tria_Utf8ToAnsi(UTF8Encode(content));


  dxfGDBStringout(outhandle,1,z2dxftext({content}s));
  dxfGDBStringout(outhandle,100,'AcDbText');
  dxfGDBIntegerout(outhandle,73,vv);
end;
procedure GDBObjText.LoadFromDXF;
var //s{, layername}: GDBString;
  byt{, code}: GDBInteger;
  doublepoint,angleload: GDBBoolean;
  angle:double;
  vv, gv, textbackward: GDBInteger;
  style,tcontent:GDBString;
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
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
       if not dxfvertexload(f,10,byt,Local.P_insert) then
          if dxfvertexload(f,11,byt,P_drawInOCS) then
                                                     doublepoint := true
else if not dxfGDBDoubleload(f,40,byt,textprop.size) then
     if not dxfGDBDoubleload(f,41,byt,textprop.wfactor) then
     if dxfGDBDoubleload(f,50,byt,angle) then
                                             begin
                                               angleload := true;
                                               angle:=angle*pi/180;
                                             end
else if dxfGDBDoubleload(f,51,byt,textprop.oblique) then
                                                        textprop.oblique:=textprop.oblique*pi/180
else if     dxfGDBStringload(f,7,byt,style)then
                                             begin
                                                  TXTStyleIndex :={drawing.GetTextStyleTable^.getDataMutable}(drawing.GetTextStyleTable^.FindStyle(Style,false));
                                                  if TXTStyleIndex=nil then
                                                                      TXTStyleIndex:=pointer(drawing.GetTextStyleTable^.getDataMutable(0));
                                             end
else if not dxfGDBIntegerload(f,72,byt,gv)then
     if not dxfGDBIntegerload(f,73,byt,vv)then
     if not dxfGDBIntegerload(f,71,byt,textbackward)then
     if not dxfGDBStringload(f,1,byt,tcontent)then
                                               {s := }f.readgdbstring;
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
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocText}',{$ENDIF}result,sizeof(GDBObjText));
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
