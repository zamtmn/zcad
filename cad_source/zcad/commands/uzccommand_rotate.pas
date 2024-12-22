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
{$MODE OBJFPC}{$H+}
unit uzccommand_rotate;
{$INCLUDE zengineconfig.inc}

interface
uses
  math,
  gzctnrVectorTypes,
  uzcdrawing,
  uzgldrawcontext,
  
  uzcdrawings,
  uzeutils,
  uzglviewareadata,
  uzccommand_move,
  uzccommandsabstract,varmandef,uzccommandsmanager,uzcinterface,uzcstrconsts,uzegeometry,zcmultiobjectchangeundocommand,
  uzegeometrytypes,uzeentity,uzcLog;

type
  rotate_com =  object(move_com)
    function AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    procedure CommandContinue(const Context:TZCADCommandContext); virtual;
    procedure rot(a:Double; button: Byte);
    procedure showprompt(mklick:integer);virtual;
  end;

var
  rotate:rotate_com;

implementation

procedure rotate_com.CommandContinue(const Context:TZCADCommandContext);
var
  v1:vardesk;
  td:Double;
begin
  if (commandmanager.GetValueHeap{-vs})>0 then begin
    v1:=commandmanager.PopValue;
    td:=DegToRad(PDouble(v1.data.Addr.Instance)^);
    rot(td,MZW_LBUTTON);
  end;
end;
procedure rotate_com.showprompt(mklick:integer);
begin
  case mklick of
    0:inherited;
    1:ZCMsgCallBackInterface.TextMessage(rscmPickOrEnterAngle,TMWOHistoryOut);
  end;
end;
procedure rotate_com.rot(a:Double; button: Byte);
var
  dispmatr,tempmatr,rotmatr:DMatrix4D;
  ir:itrec;
  pcd:PTCopyObjectDesc;
  m:tmethod;
  dc:TDrawContext;
  tr:GDBvertex;
  RC:TDrawContext;
  FrPos:GDBvertex;
begin
  rotmatr:=uzegeometry.CreateRotationMatrixZ(a);
  if (button and MZW_LBUTTON)=0 then begin
    if (drawings.GetCurrentDWG^.GetPcamera^.notuseLCS) then
      tr:=t3dp
    else
      tr:=t3dp+drawings.GetCurrentDWG^.GetPcamera^.CamCSOffset;

    tempmatr:=uzegeometry.CreateTranslationMatrix(-t3dp);
    tempmatr:=uzegeometry.MatrixMultiply(tempmatr,rotmatr);
    FrPos.x:=t3dp.x+tempmatr.mtr[3].x;
    FrPos.y:=t3dp.y+tempmatr.mtr[3].y;
    FrPos.z:=t3dp.z+tempmatr.mtr[3].z;

    dispmatr:=uzegeometry.CreateTranslationMatrix(-tr);
    rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
    dispmatr:=uzegeometry.CreateTranslationMatrix(tr);
    dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr);

    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
    drawings.GetCurrentDWG^.ConstructObjRoot.FrustumPosition:=FrPos;

    RC:=drawings.GetCurrentDWG^.CreateDrawingRC;
    drawings.GetCurrentDWG^.ConstructObjRoot.FormatEntity(drawings.GetCurrentDWG^,RC);
  end else begin
    dispmatr:=uzegeometry.CreateTranslationMatrix(-t3dp);
    rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
    dispmatr:=uzegeometry.CreateTranslationMatrix(t3dp);
    dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr);
    tempmatr:=dispmatr;
    uzegeometry.MatrixInvert(tempmatr);
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Rotate');
    with PushCreateTGMultiObjectChangeCommand(@PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,tempmatr,pcoa^.Count) do begin
      pcd:=pcoa^.beginiterate(ir);
      if pcd<>nil then
      repeat
        m:=TMethod(@pcd^.sourceEnt^.Transform);
        AddMethod(m);
        dec(pcd^.sourceEnt^.vp.LastCameraPos);
        pcd:=pcoa^.iterate(ir);
      until pcd=nil;
      comit;
    end;
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;

    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
    commandmanager.executecommandend;
  end;
end;

function rotate_com.AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var
  a:double;
  v1,v2:GDBVertex2d;
begin
  v2.x:=wc.x;
  v2.y:=wc.y;
  v1.x:=t3dp.x;
  v1.y:=t3dp.y;
  a:=uzegeometry.Vertexangle(v1,v2);

  rot(a,button);

  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  rotate.init('Rotate',0,0);
  rotate.NotUseCommandLine:=false;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
