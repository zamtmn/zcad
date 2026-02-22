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
  uzeentityfactory,uzedrawingdef,uzecamera,SysUtils,uzefont,
  uzestyleslayers,uzeentabstracttext,uzeentity,uzctnrVectorBytesStream,
  uzeTypes,uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,
  uzeentsubordinated,uzbLogIntf,uzegeometrytypes,uzestylestexts,uzeSnap,
  uzMVReader,uzcTextPreprocessorDXFImpl,uzefontbase;

const
  CLEFNotNeedSaveTemplate=1;

type
  PGDBObjText=^GDBObjText;

  GDBObjText=object(GDBObjAbstractText)
    Content:TDXFEntsInternalStringType;
    Template:TDXFEntsInternalStringType;
    TXTStyle:PGDBTextStyle;
    obj_height:double;
    obj_width:double;
    obj_y:double;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint;
      c:TDXFEntsInternalStringType;p:TzePoint3d;s,o,w,a:double;j:TTextJustify);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;
      var IODXFContext:TIODXFSaveContext);virtual;
    procedure CalcGabarit(const drawing:TDrawingDef);virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    function IsStagedFormatEntity:boolean;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    function GetObjTypeName:string;virtual;
    destructor done;virtual;

    function getsnap(var osp:os_record;var pdata:Pointer;const param:OGLWndtype;
      ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    procedure rtsave(refp:Pointer);virtual;
    procedure SaveToDXFObjXData(var outStream:TZctnrVectorBytes;
      var IODXFContext:TIODXFSaveContext);virtual;
    function ProcessFromDXFObjXData(const _Name,_Value:string;ptu:PExtensionData;
      const drawing:TDrawingDef):boolean;virtual;
    class function GetDXFIOFeatures:TDXFEntIODataManager;static;

    function CreateInstance:PGDBObjText;static;
    function GetObjType:TObjID;virtual;
  end;

const
  jt:array[0..3,0..4] of TTextJustify=
    ((jsbl,jsbc,jsbr,jsbl,jsmc),(jsbtl,jsbtc,jsbtr,jsbl,jsbl),
    (jsml,jsmc,jsmr,jsbl,jsbl),(jstl,jstc,jstr,jsbl,jsbl));
  j2b:array[TTextJustify] of byte=(1,2,3,4,5,6,7,8,9,10,11,12);
  b2j:array[1..12] of TTextJustify=
    (jstl,jstc,jstr,jsml,jsmc,jsmr,jsbl,jsbc,jsbr,jsbtl,jsbtc,jsbtr);

var
  GDBObjTextDXFFeatures:TDXFEntIODataManager;

implementation

function acadvjustify(j:TTextJustify):byte;
var
  t:byte;
begin
  t:=3-((j2b[j]-1) div 3);
  if t=1 then
    Result:=0
  else
    Result:=t;
end;

function GDBObjText.GetObjTypeName;
begin
  Result:=ObjN_GDBObjText;
end;

constructor GDBObjText.initnul;
begin
  inherited initnul(owner);
  Pointer(content):=nil;
  Pointer(template):=nil;
  textprop.size:=1;
  textprop.oblique:=0;
  textprop.wfactor:=1;
  textprop.justify:=jstl;
end;

constructor GDBObjText.init;
begin
  inherited init(own,layeraddres,lw);
  Pointer(content):=nil;
  Pointer(template):=nil;
  content:=c;
  Local.p_insert:=p;
  textprop.size:=s;
  textprop.oblique:=o;
  textprop.wfactor:=w;
  textprop.justify:=j;
end;

function GDBObjText.GetObjType;
begin
  Result:=GDBtextID;
end;

function GDBObjText.IsStagedFormatEntity:boolean;
begin
  Result:=True;
end;

procedure GDBObjText.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if EFCalcEntityCS in stage then begin
    calcobjmatrix;//расширениям нужны матрицы в OnBeforeEntityFormat
    if assigned(EntExtensions) then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  end;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin
    if template='' then
      template:=content;
    content:=textformat(template,SPFSources.GetFull,@self);
    if (content='')and(template='') then
      content:=str_empty;
    lod:=0;
    P_drawInOCS:=NulVertex;
    CalcGabarit(drawing);
    case textprop.justify of
      jstl:
      begin
        P_drawInOCS.y:=P_drawInOCS.y-textprop.size;
        P_drawInOCS.x:=0;
      end;
      jstc:
      begin
        P_drawInOCS.y:=P_drawInOCS.y-textprop.size;
        P_drawInOCS.x:=-obj_width*textprop.wfactor*textprop.size/2;
      end;
      jstr:
      begin
        P_drawInOCS.y:=P_drawInOCS.y-textprop.size;
        P_drawInOCS.x:=-obj_width*textprop.wfactor*textprop.size;
      end;
      jsml:
      begin
        P_drawInOCS.y:=P_drawInOCS.y-textprop.size/2;
        P_drawInOCS.x:=0;
      end;
      jsmc:
      begin
        P_drawInOCS.y:=P_drawInOCS.y-textprop.size/2;
        P_drawInOCS.x:=-obj_width*textprop.wfactor*textprop.size/2;
      end;
      jsmr:
      begin
        P_drawInOCS.y:=P_drawInOCS.y-textprop.size/2;
        P_drawInOCS.x:=-obj_width*textprop.wfactor*textprop.size;
      end;
      jsbl:
      begin
        P_drawInOCS.y:=P_drawInOCS.y;
        P_drawInOCS.x:=0;
      end;
      jsbc:
      begin
        P_drawInOCS.y:=P_drawInOCS.y;
        P_drawInOCS.x:=-obj_width*textprop.wfactor*textprop.size/2;
      end;
      jsbr:
      begin
        P_drawInOCS.y:=P_drawInOCS.y;
        P_drawInOCS.x:=-obj_width*textprop.wfactor*textprop.size;
      end;
      jsbtl:
      begin
        P_drawInOCS.y:=P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x:=0;
      end;
      jsbtc:
      begin
        P_drawInOCS.y:=P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x:=-obj_width*textprop.wfactor*textprop.size/2;
      end;
      jsbtr:
      begin
        P_drawInOCS.y:=P_drawInOCS.y+1/3*textprop.size;
        P_drawInOCS.x:=-obj_width*textprop.wfactor*textprop.size;
      end;
    end;
    if (content='')and(template='') then
      content:=str_empty;
    calcobjmatrix;
    if (not (ESTemp in State))and(DCODrawable in DC.Options) then begin
      Representation.Clear;
      Representation.DrawTextContent(dc.drawer,content,TXTStyle^.pfont,
        DrawMatrix,objmatrix,textprop.size,Outbound);
    end;
    calcbb(dc);

    if assigned(EntExtensions) then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;

procedure GDBObjText.CalcGabarit;
var
  i:integer;
  psyminfo:PGDBsymdolinfo;
  l:integer;
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
    if psyminfo.SymMaxY>obj_height then
      obj_height:=psyminfo.SymMaxY;
    if psyminfo.SymMinY<obj_y then
      obj_y:=psyminfo.SymMinY;
    Inc(i,l);
  end;
end;

function GDBObjText.Clone;
var
  tvo:PGDBObjtext;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjText));
  tvo^.initnul(nil);
  tvo^.bp.ListPos.Owner:=own;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local:=local;
  tvo^.Textprop:=textprop;
  tvo^.content:=content;
  tvo^.template:=template;
  tvo^.TXTStyle:=TXTStyle;
  Result:=tvo;
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
  t,b,l,r,n,f:double;
  i:integer;
begin
  l:=outbound[0].x;
  r:=outbound[0].x;
  t:=outbound[0].y;
  b:=outbound[0].y;
  n:=outbound[0].z;
  f:=outbound[0].z;
  for i:=1 to 3 do begin
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
    Result:=False;
    exit;
  end;
  Result:=True;
  case onlygetsnapcount of
    0:begin
      if (SnapMode and osm_inspoint)<>0 then begin
        osp.worldcoord:=P_insert_in_WCS;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_textinsert;
      end else
        osp.ostype:=os_none;
    end;
  end;
  Inc(onlygetsnapcount);
end;

procedure GDBObjText.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
  if rtmod.point.pointtype=os_point then
    Local.p_insert:=VertexAdd(rtmod.point.worldcoord,rtmod.dist);
end;

procedure GDBObjText.SaveToDXFObjXData;
begin
  GetDXFIOFeatures.RunSaveFeatures(outStream,@self,IODXFContext);
  inherited;
end;

function z2dxftext(s:string):string;
var
  i:integer;
begin
  Result:=StringReplace(s,#10,'\P',[rfReplaceAll]);
  repeat
    i:=pos(#1,Result);
    if i>0 then begin
      Result:=copy(Result,1,i-1)+'%%U'+copy(Result,i+1,length(Result)-i);
    end;
  until i<=0;
end;

procedure GDBObjText.SaveToDXF(var outStream:TZctnrVectorBytes;
  var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
var
  hv,vv,bw:byte;
  tv:TzePoint3d;
  s:string;
  ASourcesCounter:TSPFSourceSet;
  quotedcontent:TDXFEntsInternalStringType;
begin
  vv:=acadvjustify(textprop.justify);
  hv:=(j2b[textprop.justify]-1) mod 3;
  SaveToDXFObjPrefix(outStream,'TEXT','AcDbText',IODXFContext);
  tv:=Local.p_insert;
  tv.x:=tv.x+P_drawInOCS.x;
  tv.y:=tv.y+P_drawInOCS.y;
  tv.z:=tv.z+P_drawInOCS.z;
  if hv+vv=0 then begin
    dxfvertexout(outStream,10,Local.p_insert);
    dxfvertexout(outStream,11,tv);
  end else begin
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
  dxfStringout(outStream,7,PGDBTextStyle(TXTStyle)^.Name,IODXFContext.Header);

  SaveToDXFObjPostfix(outStream);

  //проверяем есть ли в шаблоне управляющие последовательности отсутствующие в dxf
  s:=TxtFormatAndCountSrcs(template,SPFSources.GetFull,ASourcesCounter,@Self);
  if (ASourcesCounter and (not SPFSdxf))<>0 then begin
    //шаблон dxf НЕсовместим, разворачиваем всё кроме dxf последовательностей
    //пишем dxf совместимое содержимое, шаблом сохраним отдельно
    quotedcontent:=TxtFormatAndCountSrcs(template,SPFSources.GetFull and
      (not SPFSdxf),ASourcesCounter,@Self);
    s:=UTF8Encode(quotedcontent);
  end else begin
    //шаблон dxf совместим, пишем сразу его, отдельно его дописывать в расширенные данные ненадо
    s:=UTF8Encode(template);
    IODXFContext.LocalEntityFlags:=IODXFContext.LocalEntityFlags or
      CLEFNotNeedSaveTemplate;
  end;
  s:=StringReplace(s,#10,'\P',[rfReplaceAll]);
  dxfStringout(outStream,1,z2dxftext(s),IODXFContext.Header);

  dxfStringWithoutEncodeOut(outStream,100,'AcDbText');
  dxfIntegerout(outStream,73,vv);
end;

procedure GDBObjText.LoadFromDXF;
var
  byt:integer;
  doublepoint,angleload:boolean;
  angle:double;
  vv,gv,textbackward:integer;
  style,tcontent:string;
begin
  vv:=0;
  gv:=0;
  byt:=rdr.ParseInteger;
  angleload:=False;
  doublepoint:=False;
  style:='';
  tcontent:='';
  textbackward:=0;
  angle:=0;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if not dxfLoadGroupCodeVertex(rdr,10,byt,Local.P_insert) then
        if dxfLoadGroupCodeVertex(rdr,11,byt,P_drawInOCS) then
          doublepoint:=True
        else if not dxfLoadGroupCodeDouble(rdr,40,byt,textprop.size) then
          if not dxfLoadGroupCodeDouble(rdr,41,byt,textprop.wfactor) then
            if dxfLoadGroupCodeDouble(rdr,50,byt,angle) then begin
              angleload:=True;
              angle:=angle*pi/180;
            end
            else if dxfLoadGroupCodeDouble(rdr,51,byt,textprop.oblique) then
              textprop.oblique:=
                textprop.oblique*pi/180
            else if dxfLoadGroupCodeString(rdr,7,byt,style,context.Header) then begin
              TXTStyle:=
                drawing.GetTextStyleTable^.FindStyle(Style,False);
              if TXTStyle=nil then
                TXTStyle:=
                  pointer(drawing.GetTextStyleTable^.getDataMutable(0));
            end
            else if not dxfLoadGroupCodeInteger(rdr,72,byt,gv) then
              if not dxfLoadGroupCodeInteger(rdr,73,byt,vv) then
                if not dxfLoadGroupCodeInteger(rdr,71,byt,textbackward) then
                  if not dxfLoadGroupCodeString(rdr,1,byt,tcontent,context.Header) then
                    {s := }rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  if (textbackward and 4)<>0 then
    textprop.upsidedown:=True
  else
    textprop.upsidedown:=False;
  if (textbackward and 2)<>0 then
    textprop.backward:=True
  else
    textprop.backward:=False;
  if TXTStyle=nil then begin
    TXTStyle:=
      drawing.GetTextStyleTable^.FindStyle('Standard',False);
  end;
  OldVersTextReplace(Template);
  OldVersTextReplace(tcontent);
  content:=utf8tostring(tcontent);
  textprop.justify:=jt[vv,gv];
  if doublepoint then
    Local.p_Insert:=P_drawInOCS;
  if angleload then begin
    Local.basis.ox:=GetXfFromZ(Local.basis.oz);
    local.basis.OX:=VectorTransform3D(local.basis.OX,CreateAffineRotationMatrix(
      Local.basis.oz,-angle));
  end;
end;

function AllocText:PGDBObjText;
begin
  Getmem(Result,sizeof(GDBObjText));
end;

function AllocAndInitText(owner:PGDBObjGenericWithSubordinated):PGDBObjText;
begin
  Result:=AllocText;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

function GDBObjText.CreateInstance:PGDBObjText;
begin
  Result:=AllocAndInitText(nil);
end;

class function GDBObjText.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  Result:=GDBObjTextDXFFeatures;
end;

function GDBObjText.ProcessFromDXFObjXData;
var
  features:TDXFEntIODataManager;
  FeatureLoadProc:TDXFEntLoadFeature;
begin
  Result:=False;
  features:=GetDXFIOFeatures;
  if assigned(features) then begin
    FeatureLoadProc:=features.GetLoadFeature(_Name);
    if assigned(FeatureLoadProc) then begin
      Result:=FeatureLoadProc(_Name,_Value,ptu,drawing,@self);
    end;
  end;
  if not(Result) then
    Result:=inherited ProcessFromDXFObjXData(_Name,_Value,ptu,drawing);
end;

initialization
  RegisterDXFEntity(GDBTextID,'TEXT','Text',@AllocText,@AllocAndInitText);
  GDBObjTextDXFFeatures:=TDXFEntIODataManager.Create;

finalization
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  GDBObjTextDXFFeatures.Destroy;
end.
