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

procedure finalize;
begin
end;

procedure startup;
begin
  CreateCommandRTEdObjectPlugin(@FrameEdit_com_CommandStart,@FrameEdit_com_Command_End,nil,nil,@FrameEdit_com_BeforeClick,@FrameEdit_com_AfterClick,nil,nil,'Stretch',0,0);
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
