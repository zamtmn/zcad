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

unit uzccombase;
{$INCLUDE def.inc}

interface
uses
 {$IFDEF DEBUGBUILD}strutils,{$ENDIF}
 uzcsysparams,zeundostack,zcchangeundocommand,uzcoimultiobjects,
 uzcenitiesvariablesextender,uzgldrawcontext,uzcdrawing,uzbpaths,uzeffmanager,
 uzeentdimension,uzestylesdim,uzestylestexts,uzeenttext,uzestyleslinetypes,
 URecordDescriptor,uzefontmanager,uzedrawingsimple,uzcsysvars,uzccommandsmanager,
 TypeDescriptors,uzcutils,uzcstrconsts,uzcctrlcontextmenu,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
 uzbstrproc,uzctreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,LazUTF8,Forms,Controls,Clipbrd,lclintf,
  uzcsysinfo,
  uzccommandsabstract,
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
 uzeentitiestree,
 uzbtypesbase,uzbmemman,uzcdialogsfiles,
 UUnitManager,uzclog,Varman,
 uzbgeomtypes,dialogs,uzcinfoform,
 uzeentpolyline,UGDBPolyLine2DArray,uzeentlwpolyline,UGDBSelectedObjArray,
 gzctnrvectortypes,uzegeometry,uzelongprocesssupport,usimplegenerics,gzctnrstl,
 uzccommand_selectframe;

implementation

function ChangeProjType_com(operands:TCommandOperands):TCommandResult;
begin
  if drawings.GetCurrentDWG.wa.param.projtype = projparalel then
  begin
    drawings.GetCurrentDWG.wa.param.projtype := projperspective;
  end
  else
    if drawings.GetCurrentDWG.wa.param.projtype = projPerspective then
    begin
    drawings.GetCurrentDWG.wa.param.projtype := projparalel;
    end;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

function RebuildTree_com(operands:TCommandOperands):TCommandResult;
var
   lpsh:TLPSHandle;
begin
  lpsh:=LPS.StartLongProcess(drawings.GetCurrentROOT.ObjArray.count,'Rebuild drawing spatial',nil);
  drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree.maketreefrom(drawings.GetCurrentDWG^.pObjRoot.ObjArray,drawings.GetCurrentDWG^.pObjRoot.vp.BoundingBox,nil);
  LPS.EndLongProcess(lpsh);
  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

procedure polytest_com_CommandStart(Operands:pansichar);
begin
  if drawings.GetCurrentDWG.GetLastSelected<>nil then
  if drawings.GetCurrentDWG.GetLastSelected.GetObjType=GDBlwPolylineID then
  begin
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPointWOOP) or (MMoveCamera) or (MRotateCamera) or (MGet3DPoint));
  //drawings.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := true;
  ZCMsgCallBackInterface.TextMessage('Click and test inside/outside of a 2D polyline:',TMWOHistoryOut);
  exit;
  end;
  //else
  begin
       ZCMsgCallBackInterface.TextMessage('Before run 2DPolyline must be selected',TMWOHistoryOut);
       commandmanager.executecommandend;
  end;
end;
function polytest_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
//var tb:PGDBObjSubordinated;
begin
  result:=mclick+1;
  if (button and MZW_LBUTTON)<>0 then
  begin
       if pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).isPointInside(wc) then
       ZCMsgCallBackInterface.TextMessage('Inside!',TMWOHistoryOut)
       else
       ZCMsgCallBackInterface.TextMessage('Outside!',TMWOHistoryOut)
  end;
end;

procedure finalize;
begin
     //Optionswindow.done;
     //Aboutwindow.{done}free;
     //Helpwindow.{done}free;

     //DWGPageCxMenu^.done;
     //gdbfreemem(pointer(DWGPageCxMenu));
end;
function SnapProp_com(operands:TCommandOperands):TCommandResult;
begin
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor,drawings.GetCurrentDWG,true);
  result:=cmd_ok;
end;
function StoreFrustum_com(operands:TCommandOperands):TCommandResult;
//var
   //p:PCommandObjectDef;
   //ps:pgdbstring;
   //ir:itrec;
   //clist:TZctnrVectorGDBString;
begin
   drawings.GetCurrentDWG.wa.param.debugfrustum:=drawings.GetCurrentDWG.pcamera.frustum;
   drawings.GetCurrentDWG.wa.param.ShowDebugFrustum:=true;
   result:=cmd_ok;
end;
(*function ScriptOnUses(Sender: TPSPascalCompiler; const Name: string): Boolean;
{ the OnUses callback function is called for each "uses" in the script.
  It's always called with the parameter 'SYSTEM' at the top of the script.
  For example: uses ii1, ii2;
  This will call this function 3 times. First with 'SYSTEM' then 'II1' and then 'II2'.
}
begin
  if Name = 'SYSTEM' then
  begin
    SIRegister_Std(Sender);
    { This will register the declarations of these classes:
      TObject, TPersisent. This can be found
      in the uPSC_std.pas unit. }
    SIRegister_Controls(Sender);
    { This will register the declarations of these classes:
      TControl, TWinControl, TFont, TStrings, TStringList, TGraphicControl. This can be found
      in the uPSC_controls.pas unit. }

    SIRegister_Forms(Sender);
    { This will register: TScrollingWinControl, TCustomForm, TForm and TApplication. uPSC_forms.pas unit. }

    SIRegister_stdctrls(Sender);
     { This will register: TButtonContol, TButton, TCustomCheckbox, TCheckBox, TCustomEdit, TEdit, TCustomMemo, TMemo,
      TCustomLabel and TLabel. Can be found in the uPSC_stdctrls.pas unit. }

    AddImportedClassVariable(Sender, 'Application', 'TApplication');
    // Registers the application variable to the script engine.
    {PGDBDouble=^GDBDouble;
    PGDBFloat=^GDBFloat;
    PGDBString=^GDBString;
    PGDBAnsiString=^GDBAnsiString;
    PGDBBoolean=^GDBBoolean;
    PGDBInteger=^GDBInteger;
    PGDBByte=^GDBByte;
    PGDBLongword=^GDBLongword;
    PGDBQWord=^GDBQWord;
    PGDBWord=^GDBWord;
    PGDBSmallint=^GDBSmallint;
    PGDBShortint=^GDBShortint;
    PGDBPointer=^GDBPointer;}
    Sender.AddType('GDBDouble',btDouble){: TPSType};
    Sender.AddType('GDBFloat',btSingle);
    Sender.AddType('GDBString',btString);
    Sender.AddType('GDBInteger',btS32);
    //Sender.AddType('GDBBoolean',btBoolean);

    sender.AddDelphiFunction('procedure test;');
    sender.AddDelphiFunction('procedure ShowError(errstr:GDBString);');

    Result := True;
  end else
    Result := False;
end;
*)

procedure startup;
//var
   //pmenuitem:pzmenuitem;
begin
  Randomize;
  CreateCommandFastObjectPlugin(@ChangeProjType_com,'ChangeProjType',CADWG,0);
  CreateCommandFastObjectPlugin(@RebuildTree_com,'RebuildTree',CADWG,0);

  CreateCommandRTEdObjectPlugin(@polytest_com_CommandStart,nil,nil,nil,@polytest_com_BeforeClick,@polytest_com_BeforeClick,nil,nil,'PolyTest',0,0);

  CreateCommandFastObjectPlugin(@SnapProp_com,'SnapProperties',CADWG,0).overlay:=true;

  CreateCommandFastObjectPlugin(@StoreFrustum_com,'StoreFrustum',CADWG,0).overlay:=true;
end;
initialization
  OSModeEditor.initnul;
  OSModeEditor.trace.ZAxis:=false;
  OSModeEditor.trace.Angle:=TTA45;
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
