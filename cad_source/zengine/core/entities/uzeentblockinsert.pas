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
unit uzeentblockinsert;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
{$PointerMath ON}

interface

uses
  uzeentity,uzgldrawcontext,uzeentityfactory,uzedrawingdef,uzestyleslayers,Math,
  uzeentcomplex,SysUtils,UGDBObjBlockdefArray,uzeblockdef,uzbtypes,uzeTypes,
  uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,uzeentsubordinated,
  gzctnrVectorTypes,uzegeometrytypes,uzctnrVectorBytes,uzestrconsts,LCLProc,
  uzbLogIntf,uzMVReader,uzeentwithlocalcs,uzeSnap;

const
  zcadmetric='!!ZMODIFIER:';

type
  PGDBObjBlockInsert=^GDBObjBlockInsert;

  GDBObjBlockInsert=object(GDBObjComplex)
    scale:TzePoint3d;
    rotate:double;
    index:integer;
    Name:ansistring;
    pattrib:Pointer;
    BlockDesc:TBlockDesc;
    PDef:PGDBObjBlockdef;
    constructor initnul;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;

    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    destructor done;virtual;
    function GetObjTypeName:string;virtual;
    procedure correctobjects(powner:PGDBObjEntity;
      pinownerarray:integer);virtual;
    procedure BuildGeometry(var drawing:TDrawingDef);virtual;
    procedure BuildVarGeometry(var drawing:TDrawingDef);virtual;

    procedure TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);virtual;
    procedure ReCalcFromObjMatrix;virtual;
    procedure decomposite;
    procedure rtsave(refp:Pointer);virtual;

    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;

    function getrot:double;virtual;
    procedure setrot(r:double);virtual;

    property testrotate:double read getrot write setrot;(*'Rotate'*)
    function FromDXFPostProcessBeforeAdd(ptu:PExtensionData;
      const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
    class function CreateInstance:PGDBObjBlockInsert;static;
    function GetNameInBlockTable:string;virtual;
    function GetObjType:TObjID;virtual;
  end;

procedure SetBlockInsertGeomProps(PBlockInsert:PGDBObjBlockInsert;
  const args:array of const);

implementation

function GDBObjBlockInsert.GetNameInBlockTable:string;
begin
  Result:=Name;
end;

function GDBObjBlockInsert.FromDXFPostProcessBeforeAdd(ptu:PExtensionData;
  const drawing:TDrawingDef):PGDBObjSubordinated;
begin
  if pos(DevicePrefix,Name)=1 then begin
    AddExtAttrib^.upgrade:=1;
    Name:=Copy(Name,Length(DevicePrefix)+1,length(Name)-Length(DevicePrefix));
  end;
  Result:=inherited;
end;

procedure GDBObjBlockInsert.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  m:TzeTypedMatrix4d;
  scl:TzePoint3d;
begin
  m:=onematrix;
  if rtmod.point.pointtype=os_point then begin
    if rtmod.point.PDrawable=nil then
      Local:=GetPointInOCSByBasis(PzePoint3d(@objmatrix.mtr.v[0])^,
        PzePoint3d(@objmatrix.mtr.v[1])^,PzePoint3d(@objmatrix.mtr.v[2])^,VertexAdd(
        rtmod.point.worldcoord,rtmod.dist),scl)
    else
      Local:=GetPointInOCSByBasis(PzePoint3d(@objmatrix.mtr.v[0])^,
        PzePoint3d(@objmatrix.mtr.v[1])^,PzePoint3d(@objmatrix.mtr.v[2])^,VertexSub(
        VertexAdd(rtmod.point.worldcoord,rtmod.dist),rtmod.point.dcoord),scl);
  end;
end;


procedure GDBObjBlockInsert.decomposite;
var
  BX,BY,BZ,T:TzePoint3d;
  mtr:TzeTypedMatrix4d;
begin
  if PDef<>nil then begin
    Mtr:=MatrixMultiply(CreateTranslationMatrix(PDef.Base),objMatrix);
  end else
    Mtr:=objMatrix;

  BX:=PzePoint3d(@Mtr.mtr.v[0])^;
  BY:=PzePoint3d(@Mtr.mtr.v[1])^;
  BZ:=PzePoint3d(@Mtr.mtr.v[2])^;
  T:=PzePoint3d(@Mtr.mtr.v[3])^;
  Local:=GetPointInOCSByBasis(BX,BY,BZ,T,scale);
end;

procedure GDBObjBlockInsert.ReCalcFromObjMatrix;
var
  ox:TzePoint3d;
  tv:TzePoint3d;
begin
  inherited;
  decomposite;
  ox:=GetXfFromZ(Local.basis.oz);
  tv:=Local.basis.ox;
  if scale.x<-eps then
    tv:=VertexMulOnSc(tv,-1);
  rotate:=scalardot(tv,ox);
  rotate:=arccos(rotate);
  if scalardot(tv,VectorDot(Local.basis.oz,GetXfFromZ(Local.basis.oz)))<-eps then
    rotate:=2*pi-rotate;
end;

procedure GDBObjBlockInsert.setrot(r:double);
var
  m1:TzeTypedMatrix4d;
  sine,cosine:double;
begin
  m1:=CreateRotationMatrixZ(r);
  objMatrix:=MatrixMultiply(m1,objMatrix);
end;

function GDBObjBlockInsert.getrot:double;
begin
  Result:=arccos((objmatrix.mtr.v[0].v[0])/oneVertexlength(
    PzePoint3d(@objmatrix.mtr.v[0])^));
end;

procedure GDBObjBlockInsert.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  //inferited; //fix https://github.com/zamtmn/zcad/issues/17
  calcobjmatrix(@drawing);
  ConstObjArray.FormatEntity(drawing,dc);
  calcbb(dc);
  CalcActualVisible(dc.DrawingContext.VActuality);
  //self.BuildGeometry(drawing); //fix https://github.com/zamtmn/zcad/issues/17
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

procedure GDBObjBlockInsert.AddOnTrackAxis(var posr:os_record;
  const processaxis:taddotrac);
begin
  posr.arrayworldaxis.PushBackData(local.basis.OX);
  posr.arrayworldaxis.PushBackData(local.basis.OY);
end;

procedure GDBObjBlockInsert.rtsave;
begin
  inherited;
  PGDBObjBlockInsert(refp)^.rotate:=rotate;
  PGDBObjBlockInsert(refp)^.scale:=scale;
end;

procedure GDBObjBlockInsert.CalcObjMatrix;
var
  m1:TzeTypedMatrix4d;
begin
  inherited CalcObjMatrix;

  setrot(rotate);

  m1:=CreateScaleMatrix(scale);
  objMatrix:=MatrixMultiply(m1,objMatrix);

  PDef:=nil;

  if pdrawing<>nil then begin
    if index=-1 then
      index:=PGDBObjBlockdefArray(pdrawing^.GetBlockDefArraySimple).getindex(Name);
    PDef:=PGDBObjBlockdefArray(pdrawing^.GetBlockDefArraySimple).getDataMutable(index);
    if PDef<>nil then begin
      m1:=CreateTranslationMatrix(VertexMulOnSc(PDef.Base,-1));
      objMatrix:=MatrixMultiply(m1,objMatrix);
    end;
  end;
end;

procedure GDBObjBlockInsert.TransformAt;
begin
  inherited;
  ReCalcFromObjMatrix;
end;

procedure GDBObjBlockInsert.correctobjects;
var
  pobj:PGDBObjEntity;
  ir:itrec;
begin
  bp.ListPos.Owner:=powner;
  bp.ListPos.SelfIndex:=pinownerarray;
  pobj:=self.ConstObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      pobj^.correctobjects(@self,{ir.itp}ir.itc);
      pobj:=self.ConstObjArray.iterate(ir);
    until pobj=nil;
end;

function GDBObjBlockInsert.GetObjTypeName;
begin
  Result:=ObjN_GDBObjBlockInsert;
end;

constructor GDBObjBlockInsert.init;
begin
  inherited init(own,layeraddres,LW);
  POINTER(Name):=nil;
  bp.ListPos.Owner:=own;
  scale:=ScaleOne;
  rotate:=0;
  index:=-1;
  pattrib:=nil;
end;

constructor GDBObjBlockInsert.initnul;
begin
  inherited initnul;
  POINTER(Name):=nil;
  bp.ListPos.Owner:=nil;
  scale:=ScaleOne;
  rotate:=0;
  index:=-1;
  Pointer(Name):=nil;
  pattrib:=nil;
end;

function GDBObjBlockInsert.GetObjType;
begin
  Result:=GDBBlockInsertID;
end;

function GDBObjBlockInsert.Clone;
var
  tvo:PGDBObjBlockInsert;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjBlockInsert));
  tvo^.init(own,vp.Layer,vp.LineWeight);
  tvo^.scale:=scale;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  Pointer(tvo^.Name):=nil;
  tvo^.Name:=Name;
  tvo^.pattrib:=nil;
  tvo^.Local.p_insert:=Local.p_insert;
  tvo^.Local:=Local;
  tvo^.scale:=scale;
  tvo^.rotate:=rotate;
  tvo^.index:=index;
  tvo^.PDef:=PDef;
  tvo^.bp.ListPos.Owner:=own;
  if ConstObjArray.Count>0 then
    tvo.ConstObjArray.init(ConstObjArray.Count)
  else
    tvo.ConstObjArray.init(100);
  ConstObjArray.CloneEntityTo(@tvo.ConstObjArray,tvo);
  Result:=tvo;
end;

procedure GDBObjBlockInsert.BuildVarGeometry;
begin
end;

procedure GDBObjBlockInsert.BuildGeometry;
var
  pvisible,pvisible2:PGDBObjEntity;
  pblockdef:PGDBObjBlockdef;
  mainowner:PGDBObjSubordinated;
  dc:TDrawContext;
  ir:itrec;
begin
  if Name='' then
    Name:='_error_here';
  index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(Name);
  assert((index>=0) and
    (index<PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).Count),
    rsWrongBlockDefIndex);

  if not PGDBObjBlockdef(PGDBObjBlockdefArray(
    drawing.GetBlockDefArraySimple).parray)[index].Formated then begin
    dc:=drawing.CreateDrawingRC;
    PGDBObjBlockdef(
      PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).parray)
      [index].FormatEntity(drawing,dc);
  end;
  mainowner:=getmainowner;

  if mainowner<>nil then
    if typeof(mainowner^)=typeof(GDBObjBlockdef)then
      exit;
    //if mainowner.gettype=1 then
    //  exit;

  pblockdef:=PGDBObjBlockdefArray(
    drawing.GetBlockDefArraySimple).getDataMutable(index);

  ConstObjArray.Free;
  if pblockdef.ObjArray.Count>0 then begin
    dc:=drawing.CreateDrawingRC;

    ConstObjArray.SetSize(pblockdef.ObjArray.Count);
    pvisible:=pblockdef.ObjArray.beginiterate(ir);
    if pvisible<>nil then
      repeat
        pvisible:=pvisible^.Clone(@self);
        pvisible2:=pgdbobjEntity(pvisible.FromDXFPostProcessBeforeAdd(
          nil,drawing));
        if pvisible2=nil then begin
          pvisible^.correctobjects(@self,ir.itc);
          pvisible^.FormatEntity(drawing,dc);
          pvisible.BuildGeometry(drawing);
          ConstObjArray.AddPEntity(pvisible^);
        end else begin
          pvisible2^.correctobjects(@self,{i}ir.itc);
          pvisible2^.FormatEntity(drawing,dc);
          pvisible.BuildGeometry(drawing);
          ConstObjArray.AddPEntity(pvisible2^);
        end;
        pvisible:=pblockdef.ObjArray.iterate(ir);
      until pvisible=nil;

    ConstObjArray.Shrink;
  end;
  self.BlockDesc:=pblockdef.BlockDesc;
  self.getoutbound(dc);
  inherited;
end;

procedure GDBObjBlockInsert.LoadFromDXF;
var
  byt:integer;
  hlGDBWord:integer;
  attrcont:boolean;
begin
  hlGDBWord:=0;
  attrcont:=False;
  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if not dxfLoadGroupCodeVertex(rdr,10,byt,Local.P_insert) then
        if not dxfLoadGroupCodeVertex1(rdr,41,byt,scale) then
          if dxfLoadGroupCodeDouble(rdr,50,byt,rotate) then
            rotate:=DegToRad(rotate)
          else if dxfLoadGroupCodeInteger(rdr,71,byt,hlGDBWord) then begin
            if hlGDBWord=1 then
              attrcont:=True;
          end else if not dxfLoadGroupCodeString(rdr,2,byt,Name,context.header) then
            rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  if IsZero(scale.x) then
    scale.x:=1;
  if IsZero(scale.y) then
    scale.y:=1;
  if IsZero(scale.z) then
    scale.z:=1;
  if attrcont then;

  zTraceLn('{D}[DXF_CONTENTS]Name=%s',[Name]);
  index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(Name);
end;

procedure GDBObjBlockInsert.SaveToDXF(var outStream:TZctnrVectorBytes;
  var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
begin
  SaveToDXFObjPrefix(outStream,'INSERT','AcDbBlockReference',IODXFContext);
  dxfStringout(outStream,2,Name,IODXFContext.Header);
  dxfvertexout(outStream,10,Local.p_insert);
  dxfvertexout1(outStream,41,scale);
  dxfDoubleout(outStream,50,rotate*180/pi);
  SaveToDXFObjPostfix(outStream);
end;

destructor GDBObjBlockInsert.done;
begin
  Name:='';
  inherited done;
end;

function AllocBlockInsert:PGDBObjBlockInsert;
begin
  Getmem(pointer(Result),sizeof(GDBObjBlockInsert));
end;

function AllocAndInitBlockInsert(owner:PGDBObjGenericWithSubordinated):
PGDBObjBlockInsert;
begin
  Result:=AllocBlockInsert;
  Result.initnul;
  Result.bp.ListPos.Owner:=owner;
end;

procedure SetBlockInsertGeomProps(PBlockInsert:PGDBObjBlockInsert;
  const args:array of const);
var
  counter:integer;
  r:double;
begin
  counter:=low(args);
  PBlockInsert^.Local.P_insert:=CreateVertexFromArray(counter,args);
  PBlockInsert^.scale.x:=CreateDoubleFromArray(counter,args);
  PBlockInsert^.scale.y:=PBlockInsert^.scale.x;
  PBlockInsert^.scale.z:=PBlockInsert^.scale.x;
  r:=CreateDoubleFromArray(counter,args);
  PBlockInsert^.Name:=CreateStringFromArray(counter,args);
  PBlockInsert^.index:=-1;

  PBlockInsert^.CalcObjMatrix;
  PBlockInsert^.setrot(r);
  PBlockInsert^.rotate:=r;
end;

function AllocAndCreateBlockInsert(owner:PGDBObjGenericWithSubordinated;
  const args:array of const):PGDBObjBlockInsert;
begin
  Result:=AllocAndInitBlockInsert(owner);
  SetBlockInsertGeomProps(Result,args);
end;

class function GDBObjBlockInsert.CreateInstance:PGDBObjBlockInsert;
begin
  Result:=AllocAndInitBlockInsert(nil);
end;

begin
  RegisterDXFEntity(GDBBlockInsertID,'INSERT','BlockInsert',@AllocBlockInsert,@AllocAndInitBlockInsert,@SetBlockInsertGeomProps,@AllocAndCreateBlockInsert);
end.
