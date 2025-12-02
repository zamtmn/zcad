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
unit uzeentdimdiametric;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzgldrawcontext,uzeentityfactory,uzeentdimension,uzestylesdim,uzestyleslayers,
  uzegeometrytypes,uzedrawingdef,uzbstrproc,uzctnrVectorBytes,
  UGDBControlPointArray,uzegeometry,uzeentline,uzeentcomplex,SysUtils,
  UGDBSelectedObjArray,uzeentity,uzbtypes,uzeconsts,uzeffdxfsupport,
  uzeentsubordinated,uzglviewareadata,uzeSnap;
(*

Diametric dimension structure in DXF

    (11,21,31)
X<----X(text)----->X (10,20,30)
(15,25,35)

*)
type
  PGDBObjDiametricDimension=^GDBObjDiametricDimension;

  GDBObjDiametricDimension=object(GDBObjDimension)
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    function GetObjTypeName:string;virtual;

    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function GetDimStr(
      var drawing:TDrawingDef):TDXFEntsInternalStringType;virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;

    function P10ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P15ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    function P11ChangeTo(const tv:TzePoint3d):TzePoint3d;virtual;
    procedure DrawCenterMarker(const cp:TzePoint3d;r:double;
      var drawing:TDrawingDef;var DC:TDrawContext);
    procedure CalcDNVectors;virtual;

    function TextNeedOffset(const dimdir:TzePoint3d):boolean;virtual;
    function TextAlwaysMoved:boolean;virtual;
    function GetCenterPoint:TzePoint3d;virtual;
    procedure CalcTextInside;virtual;
    function GetRadius:double;virtual;
    function GetDIMTMOVE:TDimTextMove;virtual;

    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    function GetObjType:TObjID;virtual;
  end;

implementation

procedure GDBObjDiametricDimension.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'DIMENSION','AcDbDimension',IODXFContext);
  dxfvertexout(outStream,10,DimData.P10InWCS);
  dxfvertexout(outStream,11,DimData.P11InOCS);
  {if DimData.TextMoved then}
  dxfIntegerout(outStream,70,3+128)
                       {else
                           dxfIntegerout(outStream,70,3);};
  dxfStringout(outStream,3,PDimStyle^.Name);
  dxfStringout(outStream,100,'AcDbDiametricDimension');
  dxfvertexout(outStream,15,DimData.P15InWCS);
end;

function GDBObjDiametricDimension.GetDIMTMOVE:TDimTextMove;
begin
  Result:=DTMCreateLeader;
end;

procedure GDBObjDiametricDimension.CalcDNVectors;
begin
  vectorD:=vertexsub(DimData.P15InWCS,DimData.P10InWCS);
  vectorD:=normalizevertex(vectorD);
  vectorN.x:=-vectorD.y;
  vectorN.y:=vectorD.x;
  vectorN.z:=0;
  vectorN:=normalizevertex(vectorN);
end;

procedure GDBObjDiametricDimension.DrawCenterMarker(const cp:TzePoint3d;r:double;
  var drawing:TDrawingDef;var DC:TDrawContext);
var
  ls:double;
begin
  if PDimStyle.Lines.DIMCEN<>0 then begin
    ls:=abs(PDimStyle.Lines.DIMCEN);
    DrawExtensionLineLinePart(VertexSub(cp,createvertex(ls,0,0)),
      VertexAdd(cp,createvertex(ls,0,0)),drawing,0).FormatEntity(drawing,dc);
    DrawExtensionLineLinePart(VertexSub(cp,createvertex(0,ls,0)),
      VertexAdd(cp,createvertex(0,ls,0)),drawing,0).FormatEntity(drawing,dc);
    if PDimStyle.Lines.DIMCEN<0 then begin
      DrawExtensionLineLinePart(VertexSub(cp,createvertex(2*ls,0,0)),
        VertexSub(cp,createvertex(r+ls,0,0)),drawing,0).FormatEntity(drawing,dc);
      DrawExtensionLineLinePart(VertexSub(cp,createvertex(0,2*ls,0)),
        VertexSub(cp,createvertex(0,r+ls,0)),drawing,0).FormatEntity(drawing,dc);
      DrawExtensionLineLinePart(VertexAdd(cp,createvertex(2*ls,0,0)),
        VertexAdd(cp,createvertex(r+ls,0,0)),drawing,0).FormatEntity(drawing,dc);
      DrawExtensionLineLinePart(VertexAdd(cp,createvertex(0,2*ls,0)),
        VertexAdd(cp,createvertex(0,r+ls,0)),drawing,0).FormatEntity(drawing,dc);
    end;
  end;
end;

function GDBObjDiametricDimension.P10ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  dirv,center:TzePoint3d;
  d:double;
begin
  center:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
  d:=Vertexlength(center,tv);
  dirv:=vertexsub(tv,center);
  dirv:=normalizevertex(dirv);

  Result:=VertexDmorph(center,dirv,d);
  DimData.P15InWCS:=VertexDmorph(center,dirv,-d);
  d:=Vertexlength(center,DimData.P11InOCS);
  DimData.P11InOCS:=VertexDmorph(center,dirv,-d);
end;

function GDBObjDiametricDimension.P15ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  dirv,center:TzePoint3d;
  d:double;
begin
  center:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
  d:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS)/2;
  dirv:=vertexsub(tv,center);
  dirv:=normalizevertex(dirv);

  Result:=VertexDmorph(center,dirv,d);
  DimData.P10InWCS:=VertexDmorph(center,dirv,-d);
  d:=Vertexlength(center,DimData.P11InOCS);
  DimData.P11InOCS:=VertexDmorph(center,dirv,d);
end;

function GDBObjDiametricDimension.P11ChangeTo(const tv:TzePoint3d):TzePoint3d;
var
  dirv,center:TzePoint3d;
  d:double;
begin
  center:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
  d:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS)/2;
  dirv:=vertexsub(tv,center);
  dirv:=normalizevertex(dirv);
  DimData.P10InWCS:=VertexDmorph(center,dirv,-d);
  DimData.P15InWCS:=VertexDmorph(center,dirv,d);
  Result:=tv;
end;

procedure GDBObjDiametricDimension.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(4);

  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  pdesc.pointtype:=os_p10;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=DimData.P10InWCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_p11;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=DimData.P11InOCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_p15;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=DimData.P15InWCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;

function GDBObjDiametricDimension.Clone;
var
  tvo:PGDBObjDiametricDimension;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjDiametricDimension));
  tvo^.init(bp.ListPos.owner,vp.Layer,vp.LineWeight);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.DimData:=DimData;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PDimStyle:=PDimStyle;
  Result:=tvo;
end;

function GDBObjDiametricDimension.GetDimStr(
  var drawing:TDrawingDef):TDXFEntsInternalStringType;
begin
  Result:='%%C'+GetLinearDimStr(
    Vertexlength(DimData.P10InWCS,DimData.P15InWCS),drawing);
end;

function GDBObjDiametricDimension.GetCenterPoint:TzePoint3d;
begin
  Result:=VertexMulOnSc(vertexadd(DimData.P15InWCS,DimData.P10InWCS),0.5);
end;

function GDBObjDiametricDimension.GetRadius:double;
begin
  Result:=Vertexlength(DimData.P15InWCS,DimData.P10InWCS)/2;
end;

procedure GDBObjDiametricDimension.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  center:TzePoint3d;
  pl:pgdbobjline;
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  ConstObjArray.Free;
  CalcDNVectors;
  center:=GetCenterPoint;

  CalcTextParam(DimData.P10InWCS,DimData.P15InWCS);
  if not self.TextInside then
    DrawCenterMarker(center,GetRadius,drawing,dc);
  DrawDimensionText(DimData.P11InOCS,drawing,dc);
  if (self.TextInside)or(self.TextAngle=0) then begin
    DrawDimensionLine(
      DimData.P11InOCS,DimData.P15InWCS,True,False,False,drawing,dc);
    pl:=
      DrawDimensionLineLinePart(DimData.P11InOCS,VertexDmorph(
      DimData.P11InOCS,VectorT,getpsize),drawing);
    pl.FormatEntity(drawing,dc);
  end else begin
    DrawDimensionLine(
      uzegeometry.VertexDmorph(DimData.P11InOCS,vectord,Self.dimtextw),
      DimData.P15InWCS,True,False,False,drawing,dc);
  end;
  inherited;
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

function GDBObjDiametricDimension.TextNeedOffset(const dimdir:TzePoint3d):boolean;
begin
  Result:=True;
end;

procedure GDBObjDiametricDimension.CalcTextInside;
begin
  if SqrVertexlength(DimData.P15InWCS,DimData.P10InWCS)>
     SqrVertexlength(DimData.P10InWCS,DimData.P11InOCS) then
    TextInside:=True
  else
    TextInside:=False;
end;

function GDBObjDiametricDimension.TextAlwaysMoved:boolean;
begin
  Result:=True;
end;

constructor GDBObjDiametricDimension.initnul;
begin
  inherited initnul;
  bp.ListPos.Owner:=owner;
  DimData.P13InWCS:=createvertex(1,1,0);
  DimData.P14InWCS:=createvertex(300,1,0);
end;

constructor GDBObjDiametricDimension.init;
begin
  inherited init(own,layeraddres,lw);
  DimData.P13InWCS:=createvertex(1,1,0);
  DimData.P14InWCS:=createvertex(300,1,0);
end;

function GDBObjDiametricDimension.GetObjType;
begin
  Result:=GDBDiametricDimensionID;
end;

function GDBObjDiametricDimension.GetObjTypeName;
begin
  Result:=ObjN_ObjDiametricDimension;
end;

function AllocDiametricDimension:PGDBObjDiametricDimension;
begin
  Getmem(Result,sizeof(GDBObjDiametricDimension));
end;

function AllocAndInitDiametricDimension(owner:PGDBObjGenericWithSubordinated):
PGDBObjDiametricDimension;
begin
  Result:=AllocDiametricDimension;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

begin
  RegisterEntity(GDBDiametricDimensionID,'DiametricDimension',@AllocDiametricDimension,@AllocAndInitDiametricDimension);
end.
