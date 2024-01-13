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
  {REGISTEROBJECTTYPE rotate_com}
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
var v1:vardesk;
    td:Double;
begin
   if (commandmanager.GetValueHeap{-vs})>0 then
   begin
   v1:=commandmanager.PopValue;
   td:=PDouble(v1.data.Addr.Instance)^*pi/180;
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
    dispmatr,im,rotmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    //v1,v2:GDBVertex2d;
    m:tmethod;
    dc:TDrawContext;
begin
  dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-t3dp.x,-t3dp.y,-t3dp.z));
  rotmatr:=uzegeometry.CreateRotationMatrixZ(sin(a),cos(a));
  rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
  dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(t3dp.x,t3dp.y,t3dp.z));
  dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

if (button and MZW_LBUTTON)=0 then
                 begin
                      //drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
                      drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;
                       {pcd:=pcoa^.beginiterate(ir);
                       if pcd<>nil then
                       repeat
                            pcd.clone^.TransformAt(pcd.obj,@dispmatr);
                            pcd.clone^.format;
                            pcd:=pcoa^.iterate(ir);
                       until pcd=nil;}
                 end
            else
                begin
                  im:=dispmatr;
                  uzegeometry.MatrixInvert(im);
                  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Rotate');
                  with PushCreateTGMultiObjectChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,im,pcoa^.Count) do
                  begin
                   pcd:=pcoa^.beginiterate(ir);
                  if pcd<>nil then
                  repeat
                      m:=TMethod(@pcd^.sourceEnt^.Transform);
                      {m.Data:=pcd.obj;
                      m.Code:=pointer(pcd.obj^.Transform);}
                      AddMethod(m);

                      dec(pcd^.sourceEnt^.vp.LastCameraPos);
                      //pcd.obj^.Format;

                      pcd:=pcoa^.iterate(ir);
                  until pcd=nil;
                  comit;
                  end;
                  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
                end;
if (button and MZW_LBUTTON)<>0 then
begin
drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
//commandend;
commandmanager.executecommandend;
end;

end;

function rotate_com.AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var
    //dispmatr,im,rotmatr:DMatrix4D;
    //ir:itrec;
    //pcd:PTCopyObjectDesc;
    a:double;
    v1,v2:GDBVertex2d;
    //m:tmethod;
begin
      v2.x:=wc.x;
      v2.y:=wc.y;
      v1.x:=t3dp.x;
      v1.y:=t3dp.y;
      a:=uzegeometry.Vertexangle(v1,v2);

      rot(a,button);

      //dispmatr:=onematrix;
      result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  rotate.init('Rotate',0,0);
  rotate.NotUseCommandLine:=false;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
