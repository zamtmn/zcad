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

unit uzccommand_stretch;
{$INCLUDE zcadconfig.inc}

interface
uses
 uzeconsts,zeundostack,uzcoimultiobjects,
 uzgldrawcontext,uzbpaths,uzeffmanager,
 uzestylesdim,uzeenttext,
 URecordDescriptor,uzefontmanager,uzedrawingsimple,uzcsysvars,uzccommandsmanager,
 TypeDescriptors,uzcctrlcontextmenu,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
 uzbstrproc,uzctreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,LazUTF8,Forms,Controls,Clipbrd,lclintf,
  uzcsysinfo,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  sysutils,
  varmandef,
  uzglviewareadata,
  uzctnrVectorBytes,
  uzeffdxf,
  uzcinterface,
  uzeentity,
 uzcdialogsfiles,
 UUnitManager,uzclog,Varman,
 uzegeometrytypes,uzcinfoform,
 uzeentpolyline,uzeentlwpolyline,UGDBSelectedObjArray,
 uzegeometry,uzelongprocesssupport,uzccommand_selectframe,uzccommand_ondrawinged;

implementation
type
  TStretchComMode=(SM_GetEnts,SM_FirstPoint,SM_SecondPoint);
var
  StretchComMode:TStretchComMode;
procedure finalize;
begin
end;
procedure Stretch_com_CommandStart(Operands:pansichar);
begin
  StretchComMode:=SM_GetEnts;
  FrameEdit_com_CommandStart(Operands);
end;

function Stretch_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
begin
  case StretchComMode of
    SM_GetEnts:
               result:=FrameEdit_com_BeforeClick(wc,mc,button,osp,mclick);
 SM_FirstPoint:
               if (button and MZW_LBUTTON)<>0 then begin
                  OnDrawingEd.BeforeClick(wc,mc,button,osp);
                  StretchComMode:=SM_SecondPoint;
                  result:=0;
               end;
 SM_SecondPoint:
               begin
               OnDrawingEd.mouseclic:=1;
               OnDrawingEd.AfterClick(wc,mc,button,osp);
               if (button and MZW_LBUTTON)<>0 then begin
                  commandmanager.ExecuteCommandEnd;
                  result:=0;
               end;
               end;
  end;
end;
procedure selectpoints;
var
  DC:TDrawContext;
begin
  dc:=drawings.GetCurrentDWG.wa.CreateRC;
  drawings.GetCurrentDWG.GetSelObjArray.remappoints(drawings.GetCurrentDWG.GetPcamera.POSCOUNT,drawings.GetCurrentDWG.wa.param.scrollmode,drawings.GetCurrentDWG.GetPcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
  drawings.GetCurrentDWG.GetSelObjArray.selectcontrolpointinframe(drawings.GetCurrentDWG.wa.param.seldesc.Frame1,drawings.GetCurrentDWG.wa.param.seldesc.Frame2);
end;

function Stretch_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
begin
  result:=0;
  if StretchComMode=SM_GetEnts then begin
    commandmanager.DisableExecuteCommandEnd;
    result:=FrameEdit_com_AfterClick(wc,mc,button,osp,mclick);
    commandmanager.EnableExecuteCommandEnd;
    //button:=0;
    drawings.GetCurrentDWG.wa.Clear0Ontrackpoint;//убираем нулевую точку трассировки
  end;

  if commandmanager.hasDisabledExecuteCommandEnd then begin
    commandmanager.resetDisabledExecuteCommandEnd;
    if (button and MZW_LBUTTON)<>0 then begin
      if StretchComMode=SM_GetEnts then begin
        drawings.GetCurrentDWG.wa.SetMouseMode(MGet3DPoint or {MGet3DPointWoOP or }MMoveCamera or MRotateCamera);
        StretchComMode:=SM_FirstPoint;
        selectpoints;
        ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedrawContent);
        //drawings.GetCurrentDWG.wa.Clear0Ontrackpoint;
        button:=0;//убираем нулевую точку трассировки, которая будет создана после выхода отсюда
      end;
      result:=0;
    end;
  end;

  if (StretchComMode=SM_SecondPoint)and((button and MZW_LBUTTON)<>0)then
    commandmanager.executecommandend;

end;

procedure startup;
begin
  CreateCommandRTEdObjectPlugin(@Stretch_com_CommandStart,
                                @FrameEdit_com_Command_End,
                                nil,nil,
                                @Stretch_com_BeforeClick,
                                @Stretch_com_AfterClick,nil,nil,'Stretch',0,0);
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
