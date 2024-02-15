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
{$INCLUDE zengineconfig.inc}

interface
uses uzeentity,uzgldrawcontext,uzeentityfactory,uzedrawingdef,uzestyleslayers,math,
     uzeentcomplex,sysutils,UGDBObjBlockdefArray,uzeblockdef,uzbtypes,
     uzeconsts,uzglviewareadata,uzegeometry,uzeffdxfsupport,uzeentsubordinated,
     gzctnrVectorTypes,uzegeometrytypes,uzctnrVectorBytes,uzestrconsts,LCLProc,
     uzbLogIntf;
const zcadmetric='!!ZMODIFIER:';
type
{Export+}
{REGISTEROBJECTTYPE GDBObjBlockInsert}
PGDBObjBlockInsert=^GDBObjBlockInsert;
GDBObjBlockInsert= object(GDBObjComplex)
                     scale:GDBvertex;(*saved_to_shd*)
                     rotate:Double;(*saved_to_shd*)
                     index:Integer;(*saved_to_shd*)(*oi_readonly*)(*hidden_in_objinsp*)
                     Name:AnsiString;(*saved_to_shd*)(*oi_readonly*)
                     pattrib:Pointer;(*hidden_in_objinsp*)
                     BlockDesc:TBlockDesc;(*'Block params'*)(*saved_to_shd*)(*oi_readonly*)
                     constructor initnul;
                     constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt);
                     procedure LoadFromDXF(var f: TZctnrVectorBytes;ptu:PExtensionData;var drawing:TDrawingDef);virtual;

                     procedure SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                     procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
                     function Clone(own:Pointer):PGDBObjEntity;virtual;
                     //procedure rtmodifyonepoint(point:pcontrolpointdesc;tobj:PGDBObjEntity;dist,wc:gdbvertex;ptdata:Pointer);virtual;
                     destructor done;virtual;
                     function GetObjTypeName:String;virtual;
                     procedure correctobjects(powner:PGDBObjEntity;pinownerarray:Integer);virtual;
                     procedure BuildGeometry(var drawing:TDrawingDef);virtual;
                     procedure BuildVarGeometry(var drawing:TDrawingDef);virtual;

                     procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
                     procedure ReCalcFromObjMatrix;virtual;
                     procedure rtsave(refp:Pointer);virtual;

                     procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
                     procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;

                     function getrot:Double;virtual;
                     procedure setrot(r:Double);virtual;

                     property testrotate:Double read getrot write setrot;(*'Rotate'*)
                     function FromDXFPostProcessBeforeAdd(ptu:PExtensionData;const drawing:TDrawingDef):PGDBObjSubordinated;virtual;

                     class function CreateInstance:PGDBObjBlockInsert;static;
                     function GetNameInBlockTable:String;virtual;
                     function GetObjType:TObjID;virtual;
                  end;
{Export-}
procedure SetBlockInsertGeomProps(PBlockInsert:PGDBObjBlockInsert;args:array of const);
implementation
//uses log;
(*Procedure QDUDecomposition (const m:DMatrix4D; out kQ:DMatrix3D;out kD,kU:DVector3D);
var
   fInvLength,fDot,fDet,fInvD0:Double;
   kR:DMatrix3D;
   iRow,iCol:integer;
        // Factor M = QR = QDU where Q is orthogonal, D is diagonal,
        // and U is upper triangular with ones on its diagonal.  Algorithm uses
        // Gram-Schmidt orthogonalization (the QR algorithm).
        //
        // If M = [ m0 | m1 | m2 ] and Q = [ q0 | q1 | q2 ], then
        //
        //   q0 = m0/|m0|
        //   q1 = (m1-(q0*m1)q0)/|m1-(q0*m1)q0|
        //   q2 = (m2-(q0*m2)q0-(q1*m2)q1)/|m2-(q0*m2)q0-(q1*m2)q1|
        //
        // where |V| indicates length of vector V and A*B indicates dot
        // product of vectors A and B.  The matrix R has entries
        //
        //   r00 = q0*m0  r01 = q0*m1  r02 = q0*m2
        //   r10 = 0      r11 = q1*m1  r12 = q1*m2
        //   r20 = 0      r21 = 0      r22 = q2*m2
        //
        // so D = diag(r00,r11,r22) and U has entries u01 = r01/r00,
        // u02 = r02/r00, and u12 = r12/r11.

        // Q = rotation
        // D = scaling
        // U = shear

        // D stores the three diagonal entries r00, r11, r22
        // U stores the entries U[0] = u01, U[1] = u02, U[2] = u12

        // build orthogonal matrix Q
begin
        fInvLength:= m[0][0]*m[0][0] + m[1][0]*m[1][0] + m[2][0]*m[2][0];
    if  abs(fInvLength)>eps then fInvLength := 1/sqrt(fInvLength);

        kQ[0][0]:= m[0][0]*fInvLength;
        kQ[1][0]:= m[1][0]*fInvLength;
        kQ[2][0]:= m[2][0]*fInvLength;

        fDot:= kQ[0][0]*m[0][1] + kQ[1][0]*m[1][1] +
            kQ[2][0]*m[2][1];
        kQ[0][1] := m[0][1]-fDot*kQ[0][0];
        kQ[1][1] := m[1][1]-fDot*kQ[1][0];
        kQ[2][1] := m[2][1]-fDot*kQ[2][0];
    fInvLength:= kQ[0][1]*kQ[0][1] + kQ[1][1]*kQ[1][1] + kQ[2][1]*kQ[2][1];

    if  abs(fInvLength)>eps then fInvLength := 1/sqrt(fInvLength);

        kQ[0][1] *= fInvLength;
        kQ[1][1] *= fInvLength;
        kQ[2][1] *= fInvLength;

        fDot := kQ[0][0]*m[0][2] + kQ[1][0]*m[1][2] +
            kQ[2][0]*m[2][2];
        kQ[0][2] := m[0][2]-fDot*kQ[0][0];
        kQ[1][2] := m[1][2]-fDot*kQ[1][0];
        kQ[2][2] := m[2][2]-fDot*kQ[2][0];
        fDot := kQ[0][1]*m[0][2] + kQ[1][1]*m[1][2] +
            kQ[2][1]*m[2][2];
        kQ[0][2] -= fDot*kQ[0][1];
        kQ[1][2] -= fDot*kQ[1][1];
        kQ[2][2] -= fDot*kQ[2][1];
        fInvLength := kQ[0][2]*kQ[0][2] + kQ[1][2]*kQ[1][2] + kQ[2][2]*kQ[2][2];

    if  abs(fInvLength)>eps then fInvLength := 1/sqrt(fInvLength);

    kQ[0][2] *= fInvLength;
        kQ[1][2] *= fInvLength;
        kQ[2][2] *= fInvLength;

        // guarantee that orthogonal matrix has determinant 1 (no reflections)
        fDet := kQ[0][0]*kQ[1][1]*kQ[2][2] + kQ[0][1]*kQ[1][2]*kQ[2][0] +
            kQ[0][2]*kQ[1][0]*kQ[2][1] - kQ[0][2]*kQ[1][1]*kQ[2][0] -
            kQ[0][1]*kQ[1][0]*kQ[2][2] - kQ[0][0]*kQ[1][2]*kQ[2][1];

        if ( fDet < 0.0 ) then
        begin
            for iRow:= 0 to 2 do
                for iCol:= 0 to 2 do
                    kQ[iRow][iCol] := -kQ[iRow][iCol];
        end;

        // build "right" matrix R
        kR[0][0] := kQ[0][0]*m[0][0] + kQ[1][0]*m[1][0] +
            kQ[2][0]*m[2][0];
        kR[0][1] := kQ[0][0]*m[0][1] + kQ[1][0]*m[1][1] +
            kQ[2][0]*m[2][1];
        kR[1][1] := kQ[0][1]*m[0][1] + kQ[1][1]*m[1][1] +
            kQ[2][1]*m[2][1];
        kR[0][2] := kQ[0][0]*m[0][2] + kQ[1][0]*m[1][2] +
            kQ[2][0]*m[2][2];
        kR[1][2] := kQ[0][1]*m[0][2] + kQ[1][1]*m[1][2] +
            kQ[2][1]*m[2][2];
        kR[2][2] := kQ[0][2]*m[0][2] + kQ[1][2]*m[1][2] +
            kQ[2][2]*m[2][2];

        // the scaling component
        kD[0] := kR[0][0];
        kD[1] := kR[1][1];
        kD[2] := kR[2][2];

        // the shear component
        fInvD0 := 1/kD[0];
        kU[0] := kR[0][1]*fInvD0;
        kU[1] := kR[0][2]*fInvD0;
        kU[2] := kR[1][2]/kD[1];
end;*)
function GDBObjBlockInsert.GetNameInBlockTable:String;
begin
  result:=name;
end;

function GDBObjBlockInsert.FromDXFPostProcessBeforeAdd(ptu:PExtensionData;const drawing:TDrawingDef):PGDBObjSubordinated;
begin
  if pos(DevicePrefix,Name)=1 then
  begin
    AddExtAttrib^.upgrade:=1;
    Name:=Copy(Name,Length(DevicePrefix)+1,length(Name)-Length(DevicePrefix));
  end;
  result:=inherited;
end;
procedure GDBObjBlockInsert.ReCalcFromObjMatrix;
var
    ox:gdbvertex;
    tv:gdbvertex;
    //m1,m2:DMatrix4D;

    //kQ:DMatrix3D;
    //kD,kU:DVector3D;
    //Tran: TTransformations;
    //mmm:TMatrix;
begin
     inherited;
     Local.basis.ox:=PGDBVertex(@objmatrix[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix[1])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     Local.P_insert:=PGDBVertex(@objmatrix[3])^;

     scale.x:=oneVertexlength(PGDBVertex(@objmatrix[0])^)*sign(scale.x);
     scale.y:=oneVertexlength(PGDBVertex(@objmatrix[1])^)*sign(scale.y);
     scale.z:=oneVertexlength(PGDBVertex(@objmatrix[2])^)*sign(scale.z);

     {m1:=objmatrix;
     PGDBVertex(@m1[0])^.x:=(PGDBVertex(@m1[0])^.x/scale.x);
     PGDBVertex(@m1[1])^.y:=(PGDBVertex(@m1[1])^.y/scale.y);
     PGDBVertex(@m1[2])^.z:=(PGDBVertex(@m1[2])^.z/scale.z);
     PGDBVertex(@m1[3])^:=nulvertex;
     m2:=m1;
     uzegeometry.MatrixTranspose(m2);
     m1:=uzegeometry.MatrixMultiply(m1,m2);}

     //mmm[0,0]:=objmatrix[0,0];mmm[0,1]:=objmatrix[0,1];mmm[0,2]:=objmatrix[0,2];mmm[0,3]:=objmatrix[0,3];
     //mmm[1,0]:=objmatrix[1,0];mmm[1,1]:=objmatrix[1,1];mmm[1,2]:=objmatrix[1,2];mmm[1,3]:=objmatrix[1,3];
     //mmm[2,0]:=objmatrix[2,0];mmm[2,1]:=objmatrix[2,1];mmm[2,2]:=objmatrix[2,2];mmm[2,3]:=objmatrix[2,3];
     //mmm[3,0]:=objmatrix[3,0];mmm[3,1]:=objmatrix[3,1];mmm[3,2]:=objmatrix[3,2];mmm[3,3]:=objmatrix[3,3];
     {
     TTransType = (ttScaleX, ttScaleY, ttScaleZ,
                   ttShearXY, ttShearXZ, ttShearYZ,
                   ttRotateX, ttRotateY, ttRotateZ,
                   ttTranslateX, ttTranslateY, ttTranslateZ,
                   ttPerspectiveX, ttPerspectiveY, ttPerspectiveZ, ttPerspectiveW);
     }
     //MatrixDecompose(mmm,Tran);
     //QDUDecomposition (objmatrix,kQ,kD,kU);

     {tv:=uzegeometry.vectordot(PGDBVertex(@objmatrix[1])^,PGDBVertex(@objmatrix[2])^);
     tv:=normalizevertex(tv);
     if not IsPointEqual(tv,normalizevertex(PGDBVertex(@objmatrix[0])^)) then
                                                                             scale.x:=-scale.x;

     tv:=uzegeometry.vectordot(PGDBVertex(@objmatrix[2])^,PGDBVertex(@objmatrix[0])^);
     tv:=normalizevertex(tv);
     if IsPointEqual(tv,normalizevertex(PGDBVertex(@objmatrix[1])^)) then
                                                                             scale.y:=-scale.y;

     tv:=uzegeometry.vectordot(PGDBVertex(@objmatrix[0])^,PGDBVertex(@objmatrix[1])^);
     tv:=normalizevertex(tv);
     if IsPointEqual(tv,normalizevertex(PGDBVertex(@objmatrix[2])^)) then
                                                                             scale.z:=-scale.z;}

     {if abs(local.OX.x)>eps then
                                scale.x:=PGDBVertex(@objmatrix[0])^.x/local.OX.x
                            else
                                scale.x:=1;
     if abs(local.Oy.y)>eps then
                                scale.y:=PGDBVertex(@objmatrix[1])^.y/local.Oy.y
     else
         scale.y:=1;

     if abs(local.Oz.z)>eps then
                                scale.z:=PGDBVertex(@objmatrix[2])^.z/local.Oz.z
     else
         scale.z:=1;
     }

     if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    ox:=CrossVertex(ZWCS,Local.basis.oz);
     normalizevertex(ox);
     tv:=Local.basis.ox;
     if scale.x<-eps then
                      tv:=VertexMulOnSc(tv,-1);
     rotate:=scalardot(tv,ox);
     rotate:=arccos(rotate);
     if tv.y<-eps then rotate:=2*pi-rotate;
end;
procedure GDBObjBlockInsert.setrot(r:Double);
var m1:DMatrix4D;
begin
m1:=onematrix;
m1[0].v[0]:=cos(r);
m1[1].v[1]:=cos(r);
m1[1].v[0]:=-sin(r);
m1[0].v[1]:=sin(r);
objMatrix:=MatrixMultiply(m1,objMatrix);
end;
function GDBObjBlockInsert.getrot:Double;
begin
     result:=arccos((objmatrix[0].v[0])/oneVertexlength(PGDBVertex(@objmatrix[0])^))
end;

procedure GDBObjBlockInsert.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  //inferited; //fix https://github.com/zamtmn/zcad/issues/17
  calcobjmatrix(@drawing);
  ConstObjArray.FormatEntity(drawing,dc);
  calcbb(dc);
  //self.BuildGeometry(drawing); //fix https://github.com/zamtmn/zcad/issues/17
  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;
procedure GDBObjBlockInsert.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
//var tv:gdbvertex;
begin
     posr.arrayworldaxis.PushBackData(local.basis.OX);
     posr.arrayworldaxis.PushBackData(local.basis.OY);
end;
procedure GDBObjBlockInsert.rtsave;
//var m:DMatrix4D;
begin
  inherited;
  PGDBObjBlockInsert(refp)^.rotate := rotate;
  PGDBObjBlockInsert(refp)^.scale := scale;
end;
procedure GDBObjBlockInsert.CalcObjMatrix;
var
  m1:DMatrix4D;
  pblockdef:PGDBObjBlockdef;
begin
  inherited CalcObjMatrix;

  setrot(rotate);

  m1:=CreateScaleMatrix(scale);
  objMatrix:=MatrixMultiply(m1,objMatrix);

  if pdrawing<>nil then begin
    if index=-1 then
      index:=PGDBObjBlockdefArray(pdrawing^.GetBlockDefArraySimple).getindex(name);
    pblockdef:=PGDBObjBlockdefArray(pdrawing^.GetBlockDefArraySimple).getDataMutable(index);
    if pblockdef<>nil then begin
      m1:=CreateTranslationMatrix(VertexMulOnSc(pblockdef.Base,-1));
      objMatrix:=MatrixMultiply(m1,objMatrix);
    end;
  end;
end;
procedure GDBObjBlockInsert.TransformAt;
//var
    //ox:gdbvertex;
begin
     inherited;
     ReCalcFromObjMatrix;
end;
procedure GDBObjBlockInsert.correctobjects;
var pobj:PGDBObjEntity;
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
     result:=ObjN_GDBObjBlockInsert;
end;
constructor GDBObjBlockInsert.init;
begin
  inherited init(own,layeraddres,LW);
  POINTER(name):=nil;
  //Getmem(self.varman,sizeof(varmanager));
  bp.ListPos.Owner:=own;
  //vp.ID:=GDBBlockInsertID;
  scale:=ScaleOne;
  rotate:=0;
  index:=-1;
  pattrib:=nil;
  pprojoutbound:=nil;
end;
constructor GDBObjBlockInsert.initnul;
begin
  inherited initnul;
  POINTER(name):=nil;
  //Getmem(self.varman,sizeof(varmanager));
  bp.ListPos.Owner:=nil;
  //vp.ID:=GDBBlockInsertID;
  scale:=ScaleOne;
  rotate:=0;
  index:=-1;
  Pointer(Name):=nil;
  pattrib:=nil;
  //ConstObjArray.init(100);
  //varman.init('Block_Variable');
  //varman.mergefromfile(programpath+'components\defaultblockvar.ini');
  pprojoutbound:=nil;
end;
function GDBObjBlockInsert.GetObjType;
begin
     result:=GDBBlockInsertID;
end;
function GDBObjBlockInsert.Clone;
var tvo: PGDBObjBlockInsert;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjBlockInsert));
  //tvo^.ObjMatrix:=objmatrix;;
  tvo^.init({bp.owner}own,vp.Layer, vp.LineWeight);
  tvo^.scale:=scale;
  //tvo^.vp.id := GDBBlockInsertID;
  //tvo^.vp.layer :=vp.layer;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  Pointer(tvo^.name) := nil;
  tvo^.name := name;
  tvo^.pattrib := nil;
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.scale := scale;
  tvo^.rotate := rotate;
  tvo.index := index;
  tvo^.bp.ListPos.Owner:=own;
  if ConstObjArray.count>0 then
                               tvo.ConstObjArray.init(ConstObjArray.count)
                           else
                               tvo.ConstObjArray.init(100);
  ConstObjArray.CloneEntityTo(@tvo.ConstObjArray,tvo);
  //tvo^.format;
  result := tvo;
end;
procedure GDBObjBlockInsert.BuildVarGeometry;
{var pblockdef:PGDBObjBlockdef;
    //pvisible,pvisible2:PGDBObjEntity;
    //freelayer:PGDBLayerProp;
    //i:Integer;
    //varobject:Boolean;}
begin
{
     //index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
     index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(pansichar(name));
     //pblockdef:=gdb.GetCurrentDWG.BlockDefArray.getDataMutable(index);
     pblockdef:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getDataMutable(index);
     PTObjectUnit(pblockdef^.ou.Instance)^.copyto(PTObjectUnit(ou.Instance));
}
end;
procedure GDBObjBlockInsert.BuildGeometry;
var
    pvisible,pvisible2:PGDBObjEntity;
    pblockdef:PGDBObjBlockdef;
    mainowner:PGDBObjSubordinated;
    dc:TDrawContext;
    ir:itrec;
begin
          if name='' then
                         name:='_error_here';
          //index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
          index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex({pansichar(}name{)});
//          if index<0 then
//                         index:=index;
          assert((index>=0) and (index<PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).count), rsWrongBlockDefIndex);

          if not PBlockDefArray(PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).parray)^[index].Formated then
                                                                               begin
                                                                                dc:=drawing.CreateDrawingRC;
                                                                                PBlockDefArray(PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).parray)^[index].FormatEntity(drawing,dc);
                                                                               end;
          mainowner:=getmainowner;
          if mainowner<>nil then
          if mainowner.gettype=1 then
                                   exit;
          pblockdef:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getDataMutable(index);

          ConstObjArray.free;
          if pblockdef.ObjArray.count>0 then
          begin
          dc:=drawing.CreateDrawingRC;

          ConstObjArray.SetSize(pblockdef.ObjArray.Count);
          pvisible:=pblockdef.ObjArray.beginiterate(ir);
          if pvisible<>nil then
          repeat
               pvisible:=pvisible^.Clone(@self);
               pvisible2:=pgdbobjEntity(pvisible.FromDXFPostProcessBeforeAdd(nil,drawing));
               if pvisible2=nil then
                                     begin
                                          pvisible^.correctobjects(@self,ir.itc);
                                          pvisible^.FormatEntity(drawing,dc);
                                          pvisible.BuildGeometry(drawing);
                                          ConstObjArray.AddPEntity(pvisible^);
                                     end
                                 else
                                     begin
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
  //s: String;
  byt{, code, i}: Integer;
  hlGDBWord: Integer;
  attrcont: Boolean;
begin
  hlGDBWord:=0;
  attrcont := false;
  byt:=readmystrtoint(f);
  while byt <> 0 do
  begin
     if not LoadFromDXFObjShared(f,byt,ptu,drawing) then
     if not dxfvertexload(f,10,byt,Local.P_insert) then
     if not dxfvertexload1(f,41,byt,scale) then
     if dxfDoubleload(f,50,byt,rotate) then begin
                                                    rotate:=rotate*pi/180;
                                               end
else if dxfIntegerload(f,71,byt,hlGDBWord)then begin if hlGDBWord = 1 then attrcont := true; end
else if not dxfStringload(f,2,byt,name)then {s := }f.readString;
    byt:=readmystrtoint(f);
  end;
  if attrcont then ;
      {begin
        Getmem(PGDBBlockInsert(temp)^.pattrib, attrmemsize);
        PGDBBlockInsert(temp)^.pattrib^.count := 0;
        s := f.readworld(#10, #13);
        repeat
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).angle := 0;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).oblique := 0;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).wfactor := 0.65;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).size := 10;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).linespace := 10 * 1.66;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).ptext := nil;
          Pointer(GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).content) := nil;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).content := '';
          ux.x := 1;
          ux.y := 0;
          ux.z := 0;
          vv := 0;
          gv := 0;
          doublepoint := false;
          Pointer(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].tag) := nil;
          Pointer(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].value) := nil;
          Pointer(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].prompt) := nil;

          s := f.readworld(#10, #13);
          val(s, byt, code);
          while byt <> 0 do
          begin
            case byt of
              1:
                begin
                  s := f.readworld(#10, #13);
                  PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].value := s;
                end;
              2:
                begin
                  s := f.readworld(#10, #13);
                  PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].tag := s;
                end;

              10:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_insert.x, code);
                end;
              20:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_insert.y, code);
                end;
              30:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_insert.z, code);
                end;
              11:
                begin
                  doublepoint := true;
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_draw.x, code);
                end;
              21:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_draw.y, code);
                end;
              31:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_draw.z, code);
                end;

              40:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).size, code);
                end;
              44:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).linespace, code);
                  GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).linespace :=
                  GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).size * GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).linespace * 5 / 3
                end;
              50:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).angle, code);
                end;
              51:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).oblique, code);
                end;
              72:
                begin
                  s := f.readworld(#10, #13);
                  val(s, gv, code);
                end;
              73:
                begin
                  s := f.readworld(#10, #13);
                  val(s, vv, code);
                end;
              41:
                begin
                  s := f.readworld(#10, #13);
                  val(s, GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).width, code);
                end;
            else
              s := f.readworld(#10, #13);
            end;
            s := f.readworld(#10, #13);
            val(s, byt, code);
          end;
          if doublepoint then
            GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_insert := GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).p_draw;
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).justify := jt[vv, gv];
          GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt).content := PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].value;
          reformatmtext(@GDBMtext(PGDBBlockInsert(temp)^.pattrib^.attrarray[PGDBBlockInsert(temp)^.pattrib^.count].mt));
          inc(PGDBBlockInsert(temp)^.pattrib^.count);
          s := f.readworld(#10, #13);
        until s = 'SEQEND'
      end;}
  zTraceLn('{D}[DXF_CONTENTS]Name='+name);
//  if name='EL_LIGHT_SWIITH' then
//    name:=name;
      //programlog.LogOutFormatStr('BlockInsert name="%s" loaded',[name],lp_OldPos,LM_Debug);
      //index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(name));
      index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(pansichar(name));
      //format;
end;
procedure GDBObjBlockInsert.SaveToDXF(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);
//var
  //i, j: Integer;
  //hv, vv: Byte;
  //s: String;
begin
  SaveToDXFObjPrefix(outhandle,'INSERT','AcDbBlockReference',IODXFContext);
  dxfStringout(outhandle,2,name);
  dxfvertexout(outhandle,10,Local.p_insert);
  dxfvertexout1(outhandle,41,scale);
  dxfDoubleout(outhandle,50,rotate*180/pi);
  SaveToDXFObjPostfix(outhandle);
end;
destructor GDBObjBlockInsert.done;
begin
     name:='';
     inherited done;
end;
function AllocBlockInsert:PGDBObjBlockInsert;
begin
  Getmem(pointer(result),sizeof(GDBObjBlockInsert));
end;
function AllocAndInitBlockInsert(owner:PGDBObjGenericWithSubordinated):PGDBObjBlockInsert;
begin
  result:=AllocBlockInsert;
  result.initnul{(owner)};
  result.bp.ListPos.Owner:=owner;
end;
procedure SetBlockInsertGeomProps(PBlockInsert:PGDBObjBlockInsert;args:array of const);
var
   counter:integer;
   r:Double;
begin
  counter:=low(args);
  PBlockInsert^.Local.P_insert:=CreateVertexFromArray(counter,args);
  PBlockInsert^.scale.x:=CreateDoubleFromArray(counter,args);
  PBlockInsert^.scale.y:=PBlockInsert^.scale.x;
  PBlockInsert^.scale.z:=PBlockInsert^.scale.x;
  r:=CreateDoubleFromArray(counter,args);
  PBlockInsert^.name:=CreateStringFromArray(counter,args);
  PBlockInsert^.index:=-1;

  PBlockInsert^.CalcObjMatrix;
  PBlockInsert^.setrot(r);
  PBlockInsert^.rotate:=r;
end;
function AllocAndCreateBlockInsert(owner:PGDBObjGenericWithSubordinated;args:array of const):PGDBObjBlockInsert;
begin
  result:=AllocAndInitBlockInsert(owner);
  //owner^.AddMi(@result);
  SetBlockInsertGeomProps(result,args);
end;
class function GDBObjBlockInsert.CreateInstance:PGDBObjBlockInsert;
begin
  result:=AllocAndInitBlockInsert(nil);
end;
begin
  RegisterDXFEntity(GDBBlockInsertID,'INSERT','BlockInsert',@AllocBlockInsert,@AllocAndInitBlockInsert,@SetBlockInsertGeomProps,@AllocAndCreateBlockInsert);
end.
