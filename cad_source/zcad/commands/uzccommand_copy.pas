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
{$MODE OBJFPC}
unit uzccommand_copy;
{$INCLUDE def.inc}

interface
uses
  gzctnrvector,zcmultiobjectchangeundocommand,
  gzctnrvectortypes,zcmultiobjectcreateundocommand,uzgldrawercanvas,
  uzcoimultiobjects,uzcdrawing,uzepalette,
  uzgldrawcontext,
  uzeentpoint,uzeentityfactory,
  uzedrawingsimple,uzcsysvars,uzcstrconsts,uzccomdrawdase,
  printers,graphics,uzeentdevice,
  LazUTF8,Clipbrd,LCLType,classes,uzeenttext,
  uzccommandsabstract,uzbstrproc,
  uzbtypesbase,uzccommandsmanager,uzccombase,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzeutils,uzcutils,
  sysutils,
  varmandef,
  uzglviewareadata,
  uzeffdxf,
  uzcinterface,
  uzccommand_move,
  uzegeometry,
  uzbmemman,
  uzeconsts,
  uzbgeomtypes,uzeentity,uzeentcircle,uzeentline,uzeentgenericsubentry,uzeentmtext,
  uzcshared,uzeentsubordinated,uzeentblockinsert,uzeentpolyline,uzclog,gzctnrvectordata,
  uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray
  ,uzelongprocesssupport,LazLogger;
type
{EXPORT+}
  copy_com = {$IFNDEF DELPHI}packed{$ENDIF} object(move_com)
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function Copy(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
  end;
{EXPORT-}
var
   Copy:copy_com;
implementation
function Copy_com.Copy(dispmatr:DMatrix4D;UndoMaker:GDBString): GDBInteger;
var
    //dist:gdbvertex;
    //im:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    //m:tmethod;
    domethod,undomethod:tmethod;
    pcopyofcopyobj:pGDBObjEntity;
    dc:TDrawContext;
begin
  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker(UndoMaker);
  SetObjCreateManipulator(domethod,undomethod);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
     begin
     pcd:=pcoa^.beginiterate(ir);
     if pcd<>nil then
     repeat
                            begin
                            {}pcopyofcopyobj:=pcd^.obj^.Clone(pcd^.obj^.bp.ListPos.Owner);
                              pcopyofcopyobj^.TransformAt(pcd^.obj,@dispmatr);
                              pcopyofcopyobj^.formatentity(drawings.GetCurrentDWG^,dc);

                               begin
                                    AddObject(pcopyofcopyobj);
                               end;

                              //drawings.GetCurrentROOT^.AddObjectToObjArray{ObjArray.add}(addr(pcopyofcopyobj));
                            end;

          pcd:=pcoa^.iterate(ir);
     until pcd=nil;
     comit;
     end;
     PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
     result:=cmd_ok;
end;
function Copy_com.AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record): GDBInteger;
var
   dispmatr:DMatrix4D;
begin
      dispmatr:=CalcTransformMatrix(t3dp,wc);
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
      if (button and MZW_LBUTTON)<>0 then
      begin
           copy(dispmatr,self.CommandName);
           zcRedrawCurrentDrawing;
      end;
      result:=cmd_ok;
end;
procedure startup;
begin
  copy.init('Copy',0,0);
  move.init('Move',0,0);
end;
procedure Finalize;
begin
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
