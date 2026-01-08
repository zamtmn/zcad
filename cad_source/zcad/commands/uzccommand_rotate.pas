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
  Math,
  gzctnrVectorTypes,
  uzcdrawing,
  uzgldrawcontext,
  uzcdrawings,
  uzeutils,
  uzglviewareadata,
  uzccommand_move,
  uzccommandsabstract,uzsbVarmanDef,uzccommandsmanager,uzcinterface,
  uzcstrconsts,uzegeometry,zcmultiobjectchangeundocommand,
  uzegeometrytypes,uzeentity,uzcLog;

type
  TRotate_com=object(move_com)
    function AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
    function CreateRotmatr(AAngle:double):TzeTypedMatrix4d;virtual;
    procedure CommandContinue(const Context:TZCADCommandContext);virtual;
    procedure rotate(const rotmatr:TzeTypedMatrix4d;button:byte);
    procedure showprompt(mklick:integer);virtual;
  end;

  TRotateX_com=object(TRotate_com)
    function CreateRotmatr(AAngle:double):TzeTypedMatrix4d;virtual;
  end;

  TRotateY_com=object(TRotate_com)
    function CreateRotmatr(AAngle:double):TzeTypedMatrix4d;virtual;
  end;

var
  Rotate_com:TRotate_com;
  RotateX_com:TRotateX_com;
  RotateY_com:TRotateY_com;

implementation

procedure TRotate_com.CommandContinue(const Context:TZCADCommandContext);
var
  v1:vardesk;
  td:double;
begin
  if (commandmanager.GetValueHeap{-vs})>0 then begin
    v1:=commandmanager.PopValue;
    td:=DegToRad(PDouble(v1.Data.Addr.Instance)^);
    rotate(CreateRotmatr(td),MZW_LBUTTON);
  end;
end;

procedure TRotate_com.showprompt(mklick:integer);
begin
  case mklick of
    0:inherited;
    1:zcUI.TextMessage(rscmPickOrEnterAngle,TMWOHistoryOut);
  end;
end;

procedure TRotate_com.rotate(const rotmatr:TzeTypedMatrix4d;button:byte);
var
  tmatr,dispmatr,tempmatr:TzeTypedMatrix4d;
  ir:itrec;
  pcd:PTCopyObjectDesc;
  m:tmethod;
  dc:TDrawContext;
  tr:TzePoint3d;
  RC:TDrawContext;
  FrPos:TzePoint3d;
begin
  //rotmatr:=uzegeometry.CreateRotationMatrixZ(a);
  if (button and MZW_LBUTTON)=0 then begin
    if (drawings.GetCurrentDWG^.GetPcamera^.notuseLCS) then
      tr:=t3dp
    else
      tr:=t3dp+drawings.GetCurrentDWG^.GetPcamera^.CamCSOffset;

    tempmatr:=uzegeometry.CreateTranslationMatrix(-t3dp);
    tempmatr:=uzegeometry.MatrixMultiply(tempmatr,rotmatr);
    FrPos.x:=t3dp.x+tempmatr.mtr.v[3].x;
    FrPos.y:=t3dp.y+tempmatr.mtr.v[3].y;
    FrPos.z:=t3dp.z+tempmatr.mtr.v[3].z;

    dispmatr:=uzegeometry.CreateTranslationMatrix(-tr);
    tmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
    dispmatr:=uzegeometry.CreateTranslationMatrix(tr);
    dispmatr:=uzegeometry.MatrixMultiply(tmatr,dispmatr);

    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
    drawings.GetCurrentDWG^.ConstructObjRoot.FrustumPosition:=FrPos;

    RC:=drawings.GetCurrentDWG^.CreateDrawingRC;
    drawings.GetCurrentDWG^.ConstructObjRoot.FormatEntity(drawings.GetCurrentDWG^,RC);
  end else begin
    dispmatr:=uzegeometry.CreateTranslationMatrix(-t3dp);
    tmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
    dispmatr:=uzegeometry.CreateTranslationMatrix(t3dp);
    dispmatr:=uzegeometry.MatrixMultiply(tmatr,dispmatr);
    tempmatr:=dispmatr;
    uzegeometry.MatrixInvert(tempmatr);
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Rotate');
    with PushCreateTGMultiObjectChangeCommand(@PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,tempmatr,pcoa^.Count) do begin
      pcd:=pcoa^.beginiterate(ir);
      if pcd<>nil then
        repeat
          m:=TMethod(@pcd^.sourceEnt^.Transform);
          AddMethod(m);
          Dec(pcd^.sourceEnt^.vp.LastCameraPos);
          pcd:=pcoa^.iterate(ir);
        until pcd=nil;
      comit;
    end;
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;

    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Free;
    commandmanager.executecommandend;
  end;
end;

function TRotate_com.CreateRotmatr(AAngle:double):TzeTypedMatrix4d;
begin
  Result:=uzegeometry.CreateRotationMatrixZ(AAngle);
end;

function TRotate_com.AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
var
  a:double;
  v1,v2:TzePoint2d;
begin
  v2.x:=wc.x;
  v2.y:=wc.y;
  v1.x:=t3dp.x;
  v1.y:=t3dp.y;
  a:=uzegeometry.Vertexangle(v1,v2);

  rotate(CreateRotmatr(a),button);

  Result:=cmd_ok;
end;

function TRotateX_com.CreateRotmatr(AAngle:double):TzeTypedMatrix4d;
begin
  Result:=uzegeometry.CreateRotationMatrixX(AAngle);
end;

function TRotateY_com.CreateRotmatr(AAngle:double):TzeTypedMatrix4d;
begin
  Result:=uzegeometry.CreateRotationMatrixY(AAngle);
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  Rotate_com.init('Rotate',0,0);
  Rotate_com.NotUseCommandLine:=False;

  RotateX_com.init('RotateX',0,0);
  RotateX_com.NotUseCommandLine:=False;

  RotateY_com.init('RotateY',0,0);
  RotateY_com.NotUseCommandLine:=False;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
