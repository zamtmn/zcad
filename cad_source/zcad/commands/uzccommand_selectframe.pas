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

unit uzccommand_selectframe;
{$INCLUDE zengineconfig.inc}

interface
uses
 uzglviewareageneral,
 uzgldrawcontext,
 uzccommandsmanager,
 uzcstrconsts,
  uzccommandsabstract,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzglviewareadata,
  uzcinterface,
  uzeconsts,
  uzeentity,
 uzclog,
 uzegeometrytypes,
 gzctnrVectorTypes,uzegeometry;
var
  selframecommand:PCommandObjectDef;

procedure FrameEdit_com_CommandStart(const Context:TZCADCommandContext;Operands:pansichar);
procedure FrameEdit_com_Command_End;
function FrameEdit_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
function FrameEdit_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;

implementation
procedure FrameEdit_com_CommandStart(const Context:TZCADCommandContext;Operands:pansichar);
begin
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPointWOOP) or (MMoveCamera));
  ZCMsgCallBackInterface.TextMessage(rscmFirstPoint,TMWOHistoryOut);
end;
procedure FrameEdit_com_Command_End;
begin
  drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;
end;

function FrameEdit_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
begin
  result:=0;
  if (button and MZW_LBUTTON)<>0 then
  begin
    drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameON := true;
    ZCMsgCallBackInterface.TextMessage(rscmSecondPoint,TMWOHistoryOut);
    drawings.GetCurrentDWG.wa.param.seldesc.Frame1 := mc;
    drawings.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
    drawings.GetCurrentDWG.wa.param.seldesc.Frame13d := wc;
    drawings.GetCurrentDWG.wa.param.seldesc.Frame23d := wc;
  end
end;
function FrameEdit_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
  ti: Integer;
  x,y,w,h:Double;
  pv:PGDBObjEntity;
  ir:itrec;
  r:TInBoundingVolume;
  DC:TDrawContext;
  glmcoord1:gdbpiece;
  OnlyOnScreenSelect:boolean;
begin
  result:=mclick;
  OnlyOnScreenSelect:=(button and MZW_CONTROL)=0;
  if drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameON then
    begin
      glmcoord1:= drawings.GetCurrentDWG.wa.param.md.mouseraywithoutos;
      drawings.GetCurrentDWG^.myGluProject2(drawings.GetCurrentDWG.wa.param.seldesc.Frame13d,
                                       glmcoord1.lbegin);
      drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x := round(glmcoord1.lbegin.x);
      drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y := drawings.GetCurrentDWG.wa.getviewcontrol.clientheight - round(glmcoord1.lbegin.y);
      if OnlyOnScreenSelect then
      begin
      if drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x < 0 then drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x := 0
      else if drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x > (drawings.GetCurrentDWG.wa.getviewcontrol.clientwidth - 1) then drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x := drawings.GetCurrentDWG.wa.getviewcontrol.clientwidth - 1;
      if drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y < 0 then drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y := 1
      else if drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y > (drawings.GetCurrentDWG.wa.getviewcontrol.clientheight - 1) then drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y := drawings.GetCurrentDWG.wa.getviewcontrol.clientheight - 1;
      end;
    end;

  drawings.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
  drawings.GetCurrentDWG.wa.param.seldesc.Frame23d := wc;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
      drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;

         //if assigned(sysvarDSGNSelNew) then
         if sysvarDSGNSelNew then
         begin
               drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
               drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject := nil;
               drawings.GetCurrentDWG.wa.param.SelDesc.OnMouseObject := nil;
               drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
               drawings.GetCurrentDWG.GetSelObjArray.Free;
         end;

      //mclick:=-1;
      if drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x > drawings.GetCurrentDWG.wa.param.seldesc.Frame2.x then
      begin
        ti := drawings.GetCurrentDWG.wa.param.seldesc.Frame2.x;
        drawings.GetCurrentDWG.wa.param.seldesc.Frame2.x := drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x;
        drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x := ti;
        drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse:=true;
      end
         else drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse:=false;
      if drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y < drawings.GetCurrentDWG.wa.param.seldesc.Frame2.y then
      begin
        ti := drawings.GetCurrentDWG.wa.param.seldesc.Frame2.y;
        drawings.GetCurrentDWG.wa.param.seldesc.Frame2.y := drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y;
        drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y := ti;
      end;
      drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y := drawings.GetCurrentDWG.wa.param.height - drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y;
      drawings.GetCurrentDWG.wa.param.seldesc.Frame2.y := drawings.GetCurrentDWG.wa.param.height - drawings.GetCurrentDWG.wa.param.seldesc.Frame2.y;
      //ugdbdescriptor.poglwnd^.seldesc.Selectedobjcount:=0;

      x:=(drawings.GetCurrentDWG.wa.param.seldesc.Frame2.x+drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x)/2;
      y:=(drawings.GetCurrentDWG.wa.param.seldesc.Frame2.y+drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y)/2;
      w:=drawings.GetCurrentDWG.wa.param.seldesc.Frame2.x-drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x;
      h:=drawings.GetCurrentDWG.wa.param.seldesc.Frame2.y-drawings.GetCurrentDWG.wa.param.seldesc.Frame1.y;

      if (w=0) or (h=0)  then
                             begin
                                  commandmanager.executecommandend;
                                  exit;
                             end;

      drawings.GetCurrentDWG.wa.param.seldesc.BigMouseFrustum:=CalcDisplaySubFrustum(x,y,w,h,drawings.getcurrentdwg.pcamera.modelMatrix,drawings.getcurrentdwg.pcamera.projMatrix,drawings.getcurrentdwg.pcamera.viewport);

      pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
            if (pv^.Visible=drawings.GetCurrentDWG.pcamera.VISCOUNT)or(not OnlyOnScreenSelect) then
            if (pv^.infrustum=drawings.GetCurrentDWG.pcamera.POSCOUNT)or(not OnlyOnScreenSelect) then
            begin
                 r:=pv^.CalcTrueInFrustum(drawings.GetCurrentDWG.wa.param.seldesc.BigMouseFrustum,drawings.GetCurrentDWG.pcamera.VISCOUNT);

                 if drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse
                    then
                        begin
                             if r<>IREmpty then
                                               begin
                                               pv^.RenderFeedbackIFNeed(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
                                               if (button and MZW_SHIFT)=0 then
                                                                               pv^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector)
                                                                           else
                                                                               pv^.deselect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.deselector);
                                               drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject:=pv;
                                               end;
                        end
                    else
                        begin
                             if r=IRFully then
                                              begin
                                               pv^.RenderFeedbackIFNeed(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
                                               if (button and MZW_SHIFT)=0 then
                                                                               pv^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector)
                                                                           else
                                                                               pv^.deselect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.deselector);
                                               drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject:=pv;
                                              end;
                        end
            end;

            pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;

      {if drawings.GetCurrentDWG.ObjRoot.ObjArray.count = 0 then exit;
      ti:=0;
      for i := 0 to drawings.GetCurrentDWG.ObjRoot.ObjArray.count - 1 do
      begin
        if PGDBObjEntityArray(drawings.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i]<>nil then
        begin
        if PGDBObjEntityArray(drawings.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].visible then
        begin
          PGDBObjEntityArray(drawings.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].feedbackinrect;
        end;
        if PGDBObjEntityArray(drawings.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].selected then
                                                                                       begin
                                                                                            inc(ti);
                                                                                            ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject:=PGDBObjEntityArray(drawings.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i];
                                                                                       end;
        end;
        ugdbdescriptor.poglwnd^.seldesc.Selectedobjcount:=ti;
      end;}
      commandmanager.executecommandend;
      //OGLwindow1.SetObjInsp;
      //redrawoglwnd;
      ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
      //if assigned(updatevisibleProc) then updatevisibleProc(ZMsgID_GUIActionRedraw);
    end;
  end
  else
  begin
    //if mouseclic = 1 then
    begin
      drawings.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
      if drawings.GetCurrentDWG.wa.param.seldesc.Frame1.x > drawings.GetCurrentDWG.wa.param.seldesc.Frame2.x then
      begin
        drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse:=true;
      end
        else drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameInverse:=false;
    end
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  selframecommand:=CreateCommandRTEdObjectPlugin(@FrameEdit_com_CommandStart,@FrameEdit_com_Command_End,nil,nil,@FrameEdit_com_BeforeClick,@FrameEdit_com_AfterClick,nil,nil,'SelectFrame',0,0);
  selframecommand^.overlay:=true;
  selframecommand.CEndActionAttr:=[];
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
