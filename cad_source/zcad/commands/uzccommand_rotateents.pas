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
unit uzccommand_rotateents;
{$INCLUDE def.inc}

interface
uses
  gzctnrvectortypes,
  uzcdrawing,
  uzcdrawings,
  uzeutils,
  uzeentwithlocalcs,
  uzccommandsabstract,
  uzegeometry,zcmultiobjectchangeundocommand,
  uzbgeomtypes,uzeentity,LazLogger,
  uzccommandsimpl;

implementation

function IsIt(PType,PChecedType:Pointer):Boolean;
type
  vmtRecPtr=^vmtRec;
  vmtRecPtrPtr=^vmtRecPtr;
  vmtRec=packed record
    size,negSize : sizeint;
    parent: {$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
  end;
var
  CurrParent:{$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
begin

  if PType=PChecedType then
    exit(true);
  CurrParent:=vmtRecPtr(PType)^.parent;
  if CurrParent=nil then
    exit(false);
  {$ifndef VER3_0}
  if CurrParent^=nil then
    exit(false);
  {$endif}
  result:=IsIt({$ifdef VER3_0}CurrParent{$else}CurrParent^{$endif},PChecedType);
end;


function RotateEnts_com(operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  ir:itrec;
  count:integer;
  dispmatr,im,rotmatr:DMatrix4D;
  pc:GDBvertex;
  m:TMethod;
  a:Double;
begin
  if operands='-' then
    a:=pi/2
  else
    a:=-pi/2;
  if (drawings.GetCurrentROOT^.ObjArray.count = 0)or(drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0) then exit;
  count:=0;
  pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
      inc(count)
    else
      pv^.DelSelectedSubitem(drawings.GetCurrentDWG^);
    pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  if count>0 then
  begin
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('R');
    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then begin
        if IsIt(typeof(pv^),typeof(GDBObjWithLocalCS)) then
          pc:=PGDBObjWithLocalCS(pv)^.P_insert_in_WCS
        else
          pc:=Vertexmorph(pv^.vp.BoundingBox.LBN,pv^.vp.BoundingBox.RTF,0.5);
        dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-pc.x,-pc.y,-pc.z));
        rotmatr:=uzegeometry.CreateRotationMatrixZ(sin(a),cos(a));
        rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
        dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(pc.x,pc.y,pc.z));
        dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr);

        im:=dispmatr;
        uzegeometry.MatrixInvert(im);

        with PushCreateTGMultiObjectChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,im,1)^ do
        begin
          m:=TMethod(@pv^.Transform);
          AddMethod(m);
          dec(pv^.vp.LastCameraPos);
          comit;
        end;
      end;
      pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
  end;
  result:=cmd_ok;
end;
procedure Finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@RotateEnts_com,'RotateEnts',CADWG or CASelEnts,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
