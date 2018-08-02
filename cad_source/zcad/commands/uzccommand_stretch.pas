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
{$INCLUDE def.inc}

interface
uses
 {$IFDEF DEBUGBUILD}strutils,{$ENDIF}
 uzglviewareageneral,zeundostack,uzcoimultiobjects,
 uzgldrawcontext,uzbpaths,uzeffmanager,
 uzestylesdim,uzeenttext,
 URecordDescriptor,uzefontmanager,uzedrawingsimple,uzcsysvars,uzccommandsmanager,
 TypeDescriptors,uzcutils,uzcstrconsts,uzcctrlcontextmenu,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
 uzbstrproc,uzctreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,LazUTF8,Forms,Controls,Clipbrd,lclintf,
  uzcsysinfo,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  sysutils,
  varmandef,
  uzglviewareadata,
  UGDBOpenArrayOfByte,
  uzeffdxf,
  uzcinterface,
  uzeconsts,
  uzeentity,
 uzcshared,
 uzbtypesbase,uzbmemman,uzcdialogsfiles,
 UUnitManager,uzclog,Varman,
 uzbgeomtypes,dialogs,uzcinfoform,
 uzeentpolyline,uzeentlwpolyline,UGDBSelectedObjArray,
 gzctnrvectortypes,uzegeometry,uzelongprocesssupport,uzccommand_selectframe;

implementation
type
  TStretchComMode=(SM_GetEnts,SM_FirstPoint);
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

function Stretch_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  case StretchComMode of
    SM_GetEnts:result:=FrameEdit_com_BeforeClick(wc,mc,button,osp,mclick);
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

function Stretch_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  case StretchComMode of
    SM_GetEnts:begin
      commandmanager.DisableExecuteCommandEnd;
        result:=FrameEdit_com_AfterClick(wc,mc,button,osp,mclick);
      commandmanager.EnableExecuteCommandEnd
    end;
  end;

  if commandmanager.hasDisabledExecuteCommandEnd then begin
    commandmanager.resetDisabledExecuteCommandEnd;
    if (button and MZW_LBUTTON)<>0 then begin
    case StretchComMode of
      SM_GetEnts:begin
                   StretchComMode:=SM_FirstPoint;
                   selectpoints;
                 end;
   SM_FirstPoint:
    end;
      result:=0;
    end;
  end;

end;

procedure startup;
begin
  CreateCommandRTEdObjectPlugin(@FrameEdit_com_CommandStart,
                                @FrameEdit_com_Command_End,
                                nil,nil,
                                @Stretch_com_BeforeClick,
                                @Stretch_com_AfterClick,nil,nil,'Stretch',0,0);
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
