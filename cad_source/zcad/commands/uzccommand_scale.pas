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
unit uzccommand_scale;
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
  {REGISTEROBJECTTYPE scale_com}
  scale_com =  object(move_com)
    function AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    procedure scale(a:Double; button: Byte);
    procedure showprompt(mklick:integer);virtual;
    procedure CommandContinue(const Context:TZCADCommandContext); virtual;
  end;
var
  scale:Scale_com;
implementation
procedure scale_com.CommandContinue(const Context:TZCADCommandContext);
var v1:vardesk;
    td:Double;
begin
   if (commandmanager.GetValueHeap{-vs})>0 then
   begin
   v1:=commandmanager.PopValue;
   td:=PDouble(v1.data.Addr.Instance)^;
   scale(td,MZW_LBUTTON);
   end;
end;

procedure scale_com.showprompt(mklick:integer);
begin
     case mklick of
     0:inherited;
     1:ZCMsgCallBackInterface.TextMessage(rscmPickOrEnterScale,TMWOHistoryOut);
     end;
end;
procedure scale_com.scale(a:Double; button: Byte);
var
    dispmatr,im,rotmatr:DMatrix4D;
    ir:itrec;
    pcd:PTCopyObjectDesc;
    //v:GDBVertex;
    m:tmethod;
    dc:TDrawContext;
begin
if a<eps then a:=1;

dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(-t3dp.x,-t3dp.y,-t3dp.z));

rotmatr:=onematrix;
rotmatr[0].v[0]:=a;
rotmatr[1].v[1]:=a;
rotmatr[2].v[2]:=a;

rotmatr:=uzegeometry.MatrixMultiply(dispmatr,rotmatr);
dispmatr:=uzegeometry.CreateTranslationMatrix(createvertex(t3dp.x,t3dp.y,t3dp.z));
dispmatr:=uzegeometry.MatrixMultiply(rotmatr,dispmatr);
dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
{pcd:=pcoa^.beginiterate(ir);
if pcd<>nil then
repeat
  pcd.clone^.TransformAt(pcd.obj,@dispmatr);
  pcd.clone^.format;
  if button = 1 then
                    begin
                    pcd.clone^.rtsave(pcd.obj);
                    pcd.obj^.Format;
                    end;

  pcd:=pcoa^.iterate(ir);
until pcd=nil;}
if (button and MZW_LBUTTON)=0 then
                  begin
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
                   PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Scale');
                   with PushCreateTGMultiObjectChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,dispmatr,im,pcoa^.Count) do
                   begin
                    pcd:=pcoa^.beginiterate(ir);
                   if pcd<>nil then
                   repeat
                       m:=TMEthod(@pcd^.sourceEnt^.Transform);
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

function scale_com.AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var
    //dispmatr,im,rotmatr:DMatrix4D;
    //ir:itrec;
    //pcd:PTCopyObjectDesc;
    a:double;
    //v:GDBVertex;
    //m:tmethod;
begin
      //v:=uzegeometry.VertexSub(t3dp,wc);
      a:=uzegeometry.Vertexlength(t3dp,wc);
      scale(a,button);
      result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  scale.init('Scale',0,0);
  scale.NotUseCommandLine:=false;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
