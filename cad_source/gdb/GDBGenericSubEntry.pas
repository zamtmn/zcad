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

unit GDBGenericSubEntry;
{$INCLUDE def.inc}

interface
uses UGDBOpenArrayOfPV,gdbasetypes,{GDBWithLocalCS,}GDBWithMatrix,GDBSubordinated,gdbase,
gl,
geometry{,GDB3d},UGDBVisibleOpenArray,gdbEntity,gdbobjectsconstdef,varmandef,memman;
type
//GDBObjGenericSubEntry=object(GDBObjWithLocalCS)
//GDBObjGenericSubEntry=object(GDBObj3d)
{Export+}
PTDrawingPreCalcData=^TDrawingPreCalcData;
TDrawingPreCalcData=record
                          InverseObjMatrix:DMatrix4D;
                    end;
PGDBObjGenericSubEntry=^GDBObjGenericSubEntry;
GDBObjGenericSubEntry=object(GDBObjWithMatrix)
                            ObjArray:GDBObjEntityOpenArray;(*saved_to_shd*)
                            ObjCasheArray:GDBObjOpenArrayOfPV;
                            ObjToConnectedArray:GDBObjOpenArrayOfPV;
                            lstonmouse:PGDBObjEntity;
                            VisibleOBJBoundingBox:GDBBoundingBbox;
                            constructor initnul(owner:PGDBObjGenericWithSubordinated);
                            procedure DrawGeometry(lw:GDBInteger);virtual;
                            function CalcInFrustum(frustum:ClipArray):GDBBoolean;virtual;
                            function onmouse(popa:GDBPointer;const MF:ClipArray):GDBBoolean;virtual;
                            procedure Format;virtual;
                            procedure FormatAfterEdit;virtual;
                            procedure restructure;virtual;
                            procedure RenderFeedback;virtual;
                            procedure select;virtual;
                            function getowner:PGDBObjSubordinated;virtual;
                            function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;
                            function EubEntryType:GDBInteger;virtual;
                            function MigrateTo(new_sub:PGDBObjGenericSubEntry):GDBInteger;virtual;
                            function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger):GDBInteger;virtual;
                            {function SubMi(pobj:pGDBObjEntity):GDBInteger;virtual;}
                            function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;
                            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
                            function ReturnLastOnMouse:PGDBObjEntity;virtual;
                            procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;
                            destructor done;virtual;
                            procedure getoutbound;virtual;
                            procedure getonlyoutbound;virtual;

                            procedure DrawBB;

                            procedure RemoveInArray(pobjinarray:GDBInteger);virtual;
                            procedure DrawWithAttrib;virtual;

                            function CreatePreCalcData:PTDrawingPreCalcData;virtual;
                            procedure DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);virtual;
                      end;
{Export-}
implementation
uses UGDBDescriptor,OGLSpecFunc,log;
{function GDBObjGenericSubEntry.SubMi;
begin
     //pobj^.bp.PSelfInOwnerArray:=ObjArray.getelement(ObjArray.add(pobj));
     ObjArray.add(pobj);
     pGDBObjEntity(ppointer(pobj)^).bp.Owner:=@self;
end;}
function GDBObjGenericSubEntry.CreatePreCalcData:PTDrawingPreCalcData;
begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{1F00FCF0-E9C6-4A6B-8B98-FFCC5D163190}',{$ENDIF}GDBPointer(result),sizeof(TDrawingPreCalcData));
     result.InverseObjMatrix:=objmatrix;
     geometry.MatrixInvert(result.InverseObjMatrix);
end;
procedure GDBObjGenericSubEntry.DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);
begin
     gdbfreemem(pointer(PreCalcData));
end;
procedure GDBObjGenericSubEntry.DrawWithAttrib;
begin
     self.ObjArray.DrawWithattrib;
end;
procedure GDBObjGenericSubEntry.DrawBB;
begin
  inherited;
  if (sysvar.DWG.DWG_SystmGeometryDraw^){and(GDB.GetCurrentDWG.OGLwindow1.param.subrender=0)} then
  begin
  glcolor3ubv(@palette[sysvar.SYS.SYS_SystmGeometryColor^+2]);
  myglbegin(GL_LINE_LOOP);
     myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.LBN.Z);
     myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.LBN.Z);
     myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.LBN.Z);
     myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.LBN.Z);
  myglend();
  myglbegin(GL_LINE_LOOP);
     myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.RTF.Z);
     myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.RTF.Z);
     myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.RTF.Z);
     myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.RTF.Z);
  myglend();
  myglbegin(GL_LINES);
     myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.LBN.Z);
     myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.RTF.Z);
     myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.LBN.Z);
     myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.RTF.Z);
     myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.LBN.Z);
     myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.RTF.Z);
     myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.LBN.Z);
     myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.RTF.Z);
  myglend();
  end;
end;
procedure GDBObjGenericSubEntry.RemoveInArray(pobjinarray:GDBInteger);
begin
     ObjArray.deliteminarray(pobjinarray);
end;
function GDBObjGenericSubEntry.AddMi;
begin
     //pobj^.bp.PSelfInOwnerArray:=ObjArray.getelement(ObjArray.add(pobj));
     ObjArray.add(pobj);
     pGDBObjEntity(ppointer(pobj)^).bp.Owner:=@self;
end;
procedure GDBObjGenericSubEntry.correctobjects;
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     bp.Owner:=powner;
     bp.PSelfInOwnerArray:=pinownerarray;
     pobj:=self.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.correctobjects(@self,ir.itc);
           pobj:=self.ObjArray.iterate(ir);
     until pobj=nil;
end;
function GDBObjGenericSubEntry.EraseMi;
begin
     ObjArray.deliteminarray(pobjinarray);
     //if pobjinarray<>nil then     pobjinarray^:=nil;
     pobj^.done;
     memman.GDBFreeMem(GDBPointer(pobj));
     //format;
end;
function GDBObjGenericSubEntry.ImEdited;
begin
     ObjCasheArray.addnodouble(@pobj);
end;
function GDBObjGenericSubEntry.ReturnLastOnMouse;
begin
     if (sysvar.DWG.DWG_EditInSubEntry)^ then result:=lstonmouse
                                          else result:=@self;
end;
function GDBObjGenericSubEntry.MigrateTo;
var p:pGDBObjEntity;
//    i:GDBInteger;
        ir:itrec;
begin
     if objarray.Count=0 then exit;
     p:=objarray.beginiterate(ir);
     if p<>nil then
     repeat
           p^.bp.Owner:=new_sub;
           new_sub^.ObjArray.add(@p);
     p:=objarray.iterate(ir);
     until p=nil;
     {p:=objarray.parray;
     for i:=1 to objarray.Count do
     begin
          p^^.vp.Owner:=new_sub;
          new_sub^.ObjArray.add(p);
     inc(p);
     end;}
     objarray.count:=0;
end;
function GDBObjGenericSubEntry.EubEntryType;
begin
     result:=se_Abstract;
end;
function GDBObjGenericSubEntry.CanAddGDBObj;
begin
     result:=false;
end;

function GDBObjGenericSubEntry.getowner;
begin
     result:=@self;
     //result:=pointer(bp.owner);
end;
destructor GDBObjGenericSubEntry.done;
begin
     ObjArray.FreeAndDone;
     ObjCasheArray.FreeAndDone;
     inherited done;
end;
constructor GDBObjGenericSubEntry.initnul;
begin
     inherited initnul(owner);
     ObjArray.init({$IFDEF DEBUGBUILD}'{3EB0D466-D2B3-4F03-802A-8C995283688A}',{$ENDIF}10);
     ObjCasheArray.init({$IFDEF DEBUGBUILD}'{A6F0EFFD-8EBB-4DED-9051-D28BF8F9A93C}',{$ENDIF}10);
end;
procedure GDBObjGenericSubEntry.DrawGeometry;
begin
  ObjArray.DrawGeometry(CalculateLineWeight);
  DrawBB;
end;
function GDBObjGenericSubEntry.CalcInFrustum;
begin
     result:=ObjArray.calcvisible(frustum);
     self.VisibleOBJBoundingBox:=ObjArray.calcvisbb;
     {ObjArray.calcvisible;
     visible:=true;}
end;
procedure GDBObjGenericSubEntry.getoutbound;
begin
     vp.BoundingBox:=ObjArray.calcbb;
end;
procedure GDBObjGenericSubEntry.getonlyoutbound;
begin
     vp.BoundingBox:=ObjArray.getonlyoutbound;
end;
procedure GDBObjGenericSubEntry.format;
begin
  inherited format;
  ObjArray.Format;
  calcbb;
  restructure;
end;
procedure GDBObjGenericSubEntry.formatafteredit;
begin
  ObjCasheArray.Formatafteredit;
  ObjCasheArray.clear;
  calcbb;
  restructure;
end;
procedure GDBObjGenericSubEntry.restructure;
begin
end;
procedure GDBObjGenericSubEntry.renderfeedback;
begin
  ObjArray.renderfeedbac;
end;

function GDBObjGenericSubEntry.onmouse;
{var t,xx,yy:GDBDouble;
    i:GDBInteger;
    p:^pGDBObjEntity;
begin
  result:=false;
  for i:=0 to ObjArray.count-1 do
  begin
       p:=ObjArray.getelement(i);
       result:=p^.onmouse(popa);
       if result then
                     begin
                          exit;
                     end;
  end;
end;}
var //t,xx,yy:GDBDouble;
    i:GDBInteger;
    p:pGDBObjEntity;
    ot:GDBBoolean;
begin
  result:=false;
  //p:=GDBPointer(ObjArray.parray^);
  for i:=0 to ObjArray.count-1 do
  begin
       p:=pGDBPointer(ObjArray.getelement(i))^;
       if p<>nil then
       begin
       ot:=p^.onmouse(popa,mf);
       if ot then
                 begin
                      lstonmouse:=p;
                      PGDBObjOpenArrayOfPV(popa).add(addr(p));
                 end;
       result:=result or ot;
       end;
       //if result then exit;
       //inc(pGDBPointer(p));
  end;
end;
procedure GDBObjGenericSubEntry.select;
//var tdesc:pselectedobjdesc;
begin
     if selected=false then
     begin
          selected:=true;
          inc(GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount);
          {tdesc:=GDB.SelObjArray.addobject(@self);
          GDBGetMem(tdesc^.pcontrolpoint,sizeof(GDBControlPointArray));
          addcontrolpoints(tdesc);
          inc(poglwnd^.SelDesc.Selectedobjcount);}
     end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBSubEntry.initialization');{$ENDIF}
end.
