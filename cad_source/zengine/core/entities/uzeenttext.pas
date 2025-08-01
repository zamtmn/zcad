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

unit uzeenttext;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses
  uzglgeometry,uzgldrawcontext,uzeobjectextender,uzetextpreprocessor,
  uzeentityfactory,uzedrawingdef,uzecamera,uzbstrproc,sysutils,uzefont,
  uzestyleslayers,uzeentabstracttext,uzeentity,UGDBOutbound2DIArray,
  uzctnrVectorBytes,uzbtypes,uzeconsts,uzglviewareadata,uzegeometry,
  uzeffdxfsupport,uzeentsubordinated,uzbLogIntf,uzegeometrytypes,uzestylestexts,
  uzeSnap,uzMVReader,uzcTextPreprocessorDXFImpl;
const
  CLEFNotNeedSaveTemplate=1;
type
  PGDBObjText=^GDBObjText;
  GDBObjText=object(GDBObjAbstractText)
    Content:TDXFEntsInternalStringType;
    Template:TDXFEntsInternalStringType;
    TXTStyle:PGDBTextStyle;
    obj_height:Double;
    obj_width:Double;
    obj_y:Double;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;c:TDXFEntsInternalStringType;p:GDBvertex;s,o,w,a:Double;j:TTextJustify);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure CalcGabarit(const drawing:TDrawingDef);virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    function IsStagedFormatEntity:boolean;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    function GetObjTypeName:String;virtual;
    destructor done;virtual;

    function getsnap(var osp:os_record; var pdata:Pointer; const param:OGLWndtype; ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):Boolean;virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    procedure rtsave(refp:Pointer);virtual;
    procedure SaveToDXFObjXData(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext);virtual;
    function ProcessFromDXFObjXData(const _Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef):Boolean;virtual;
    class function GetDXFIOFeatures:TDXFEntIODataManager;static;

    function CreateInstance:PGDBObjText;static;
    function GetObjType:TObjID;virtual;
  end;
const
  jt: array[0..3, 0..4] of TTextJustify = ((jsbl, jsbc, jsbr, jsbl, jsmc), (jsbtl, jsbtc, jsbtr, jsbl, jsbl), (jsml, jsmc, jsmr, jsbl, jsbl), (jstl, jstc, jstr, jsbl, jsbl));
  j2b: array[TTextJustify] of byte=(1,2,3,4,5,6,7,8,9,10,11,12);
  b2j: array[1..12] of TTextJustify=(jstl,jstc,jstr,jsml,jsmc,jsmr,jsbl,jsbc,jsbr,jsbtl,jsbtc,jsbtr);
var
  GDBObjTextDXFFeatures:TDXFEntIODataManager;
implementation
function acadvjustify(j:TTextJustify): Byte;
var
  t: Byte;
begin
  t := 3 - ((j2b[j] - 1) div 3);
  if t = 1 then
    result := 0
  else
    result := t;
end;

function GDBObjText.GetObjTypeName;
begin
     result:=ObjN_GDBObjText;
end;
constructor GDBObjText.initnul;
begin
  inherited initnul(owner);
  Pointer(content) := nil;
  Pointer(template) := nil;
  textprop.size := 1;
  textprop.oblique := 0;
  textprop.wfactor := 1;
  textprop.justify := jstl;
end;
constructor GDBObjText.init;
begin
  inherited init(own,layeraddres, lw);
  Pointer(content) := nil;
  Pointer(template) := nil;
  content := c;
  Local.p_insert := p;
  textprop.size := s;
  textprop.oblique := o;
  textprop.wfactor := w;
  textprop.justify := j;
end;
function GDBObjText.GetObjType;
begin
  result:=GDBtextID;
end;
function GDBObjText.IsStagedFormatEntity:boolean;
begin
  result:=true;
end;
procedure GDBObjText.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  TCP:TCodePage;
begin
  if EFCalcEntityCS in stage then begin
  calcobjmatrix;//расширениям нужны матрицы в OnBeforeEntityFormat
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  end;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin
  TCP:=CodePage;
  CodePage:=CP_win;
     if template='' then
                      template:={UTF8Encode}(content);
  content:={utf8tostring}(textformat(template,SPFSources.GetFull,@self));
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
    if (not (ESTemp in State))and(DCODrawable in DC.Options) then begin
      Representation.Clear;
      Representation.DrawTextContent(dc.drawer,content,TXTStyle^.pfont,DrawMatrix,objmatrix,textprop.size,Outbound);
    end;
    calcbb(dc);

    //P_InsertInWCS:=VectorTransform3D(local.P_insert,vp.owner^.GetMatrix^);
    if assigned(EntExtensions)then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;
procedure GDBObjText.CalcGabarit;
var
  i: Integer;
  psyminfo:PGDBsymdolinfo;
  l:Integer;
  sym:word;
begin
  obj_height:=1;
  obj_width:=0;
  obj_y:=0;
  i:=1;
  while i<=length(content) do begin
    sym:=getsymbol_fromGDBText(content,i,l,TXTStyle^.pfont^.font.IsUnicode);
    psyminfo:=TXTStyle^.pfont^.GetOrReplaceSymbolInfo(sym);
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
  tvo^.TXTStyle:=TXTStyle;
  //tvo^.Format;
  result := tvo;
end;

procedure GDBObjText.rtsave(refp:Pointer);
begin
  inherited;
  PGDBObjText(refp)^.Content:=Content;
  PGDBObjText(refp)^.Template:=Template;
  PGDBObjText(refp)^.TXTStyle:=TXTStyle;
  PGDBObjText(refp)^.obj_height:=obj_height;
  PGDBObjText(refp)^.obj_width:=obj_width;
  PGDBObjText(refp)^.obj_y:=obj_y;
end;

destructor GDBObjText.done;
begin
  content:='';
  template:='';
  inherited done;
end;
procedure GDBObjText.getoutbound;
var
  t,b,l,r,n,f:Double;
  i:integer;
begin
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
end;

function GDBObjText.getsnap;
begin
  if onlygetsnapcount=1 then begin
      result:=false;
      exit;
  end;
  result:=true;
  case onlygetsnapcount of
    0:begin
      if (SnapMode and osm_inspoint)<>0 then begin
        osp.worldcoord:=P_insert_in_WCS;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        //osp.dispcoord:=ProjP_insert;
        osp.ostype:=os_textinsert;
      end else
        osp.ostype:=os_none;
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
  GetDXFIOFeatures.RunSaveFeatures(outStream,@self,IODXFContext);
  inherited;
end;
function z2dxftext(s:String):String;
var i:Integer;
begin
  result:=StringReplace(s,#10,'\P',[rfReplaceAll]);
  repeat
    i:=pos(#1,result);
    if i>0 then begin
      result:=copy(result,1,i-1)+'%%U'+copy(result,i+1,length(result)-i);
    end;
  until i<=0;
end;
procedure GDBObjText.SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
var
  hv, vv,bw: Byte;
  tv:gdbvertex;
  s:String;
  ASourcesCounter:TSPFSourceSet;
  quotedcontent:TDXFEntsInternalStringType;
begin
  vv := acadvjustify(textprop.justify);
  hv := (j2b[textprop.justify]{ord(textprop.justify)} - 1) mod 3;
  SaveToDXFObjPrefix(outStream,'TEXT','AcDbText',IODXFContext);
  tv:=Local.p_insert;
  tv.x:=tv.x+P_drawInOCS.x;
  tv.y:=tv.y+P_drawInOCS.y;
  tv.z:=tv.z+P_drawInOCS.z;
  if hv + vv = 0 then
  begin
    dxfvertexout(outStream,10,Local.p_insert);
    dxfvertexout(outStream,11,tv);
  end
  else
  begin
    dxfvertexout(outStream,11,Local.p_insert);
    dxfvertexout(outStream,10,tv);
  end;
  dxfDoubleout(outStream,40,textprop.size);
  dxfDoubleout(outStream,50,CalcRotate*180/pi);
  dxfDoubleout(outStream,41,textprop.wfactor);
  dxfDoubleout(outStream,51,textprop.oblique*180/pi);
  dxfIntegerout(outStream,72,hv);
  bw:=0;
  if textprop.upsidedown then
                             bw:=bw+4;
  if textprop.backward then
                             bw:=bw+2;
  if bw<>0 then
               dxfIntegerout(outStream,71,bw);
  dxfStringout(outStream,7,PGDBTextStyle({gdb.GetCurrentDWG}(TXTStyle))^.name);

  SaveToDXFObjPostfix(outStream);

  //проверяем есть ли в шаблоне управляющие последовательности отсутствующие в dxf
  s:=TxtFormatAndCountSrcs(template,SPFSources.GetFull,ASourcesCounter,@Self);
  if (ASourcesCounter and (not SPFSdxf))<>0 then begin
    //шаблон dxf НЕсовместим, разворачиваем всё кроме dxf последовательностей
    //пишем dxf совместимое содержимое, шаблом сохраним отдельно
    quotedcontent:=TxtFormatAndCountSrcs(template,SPFSources.GetFull and (not SPFSdxf),ASourcesCounter,@Self);
    s:=Tria_Utf8ToAnsi(UTF8Encode(quotedcontent));
  end else begin
    //шаблон dxf совместим, пишем сразу его, отдельно его дописывать в расширенные данные ненадо
    s:=Tria_Utf8ToAnsi(UTF8Encode(template));
    IODXFContext.LocalEntityFlags:=IODXFContext.LocalEntityFlags or CLEFNotNeedSaveTemplate;
  end;
  s:=StringReplace(s,#10,'\P',[rfReplaceAll]);
  dxfStringout(outStream,1,z2dxftext(s));

  dxfStringout(outStream,100,'AcDbText');
  dxfIntegerout(outStream,73,vv);
end;
procedure GDBObjText.LoadFromDXF;
var
  byt:Integer;
  doublepoint,angleload:Boolean;
  angle:double;
  vv, gv,textbackward:Integer;
  style,tcontent:String;
begin
  vv := 0;
  gv := 0;
  byt:=rdr.ParseInteger;
  angleload:=false;
  doublepoint:=false;
  style:='';
  tcontent:='';
  textbackward:=0;
  angle:=0;
  while byt <> 0 do
  begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing) then
       if not dxfvertexload(rdr,10,byt,Local.P_insert) then
          if dxfvertexload(rdr,11,byt,P_drawInOCS) then
                                                     doublepoint := true
else if not dxfDoubleload(rdr,40,byt,textprop.size) then
     if not dxfDoubleload(rdr,41,byt,textprop.wfactor) then
     if dxfDoubleload(rdr,50,byt,angle) then
                                             begin
                                               angleload := true;
                                               angle:=angle*pi/180;
                                             end
else if dxfDoubleload(rdr,51,byt,textprop.oblique) then
                                                        textprop.oblique:=textprop.oblique*pi/180
else if     dxfStringload(rdr,7,byt,style)then
                                             begin
                                                  TXTStyle :={drawing.GetTextStyleTable^.getDataMutable}(drawing.GetTextStyleTable^.FindStyle(Style,false));
                                                  if TXTStyle=nil then
                                                                      TXTStyle:=pointer(drawing.GetTextStyleTable^.getDataMutable(0));
                                             end
else if not dxfIntegerload(rdr,72,byt,gv)then
     if not dxfIntegerload(rdr,73,byt,vv)then
     if not dxfIntegerload(rdr,71,byt,textbackward)then
     if not dxfStringload(rdr,1,byt,tcontent,context.Header)then
                                               {s := }rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  if (textbackward and 4)<>0 then
                                 textprop.upsidedown:=true
                             else
                                 textprop.upsidedown:=false;
  if (textbackward and 2)<>0 then
                                 textprop.backward:=true
                             else
                                 textprop.backward:=false;
  if TXTStyle=nil then
                           begin
                               TXTStyle:=drawing.GetTextStyleTable^.FindStyle('Standard',false);
                               {if TXTStyle=nil then
                                                        TXTStyle:=sysvar.DWG.DWG_CTStyle^;}
                           end;
  OldVersTextReplace(Template);
  OldVersTextReplace(tcontent);
  content:=utf8tostring(tcontent);
  textprop.justify := jt[vv, gv];
  if doublepoint then Local.p_Insert := P_drawInOCS;
  //assert(angleload, 'GDBText отсутствует dxf код 50 (угол поворота)');
  if angleload then
  begin
     Local.basis.ox:=GetXfFromZ(Local.basis.oz);
     //if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
     //                                                               Local.basis.ox:=VectorDot(YWCS,Local.basis.oz)
     //                                                           else
     //                                                               Local.basis.ox:=VectorDot(ZWCS,Local.basis.oz);
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
  if assigned(features) then begin
    FeatureLoadProc:=features.GetLoadFeature(_Name);
    if assigned(FeatureLoadProc)then begin
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
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  GDBObjTextDXFFeatures.Destroy;
end.
