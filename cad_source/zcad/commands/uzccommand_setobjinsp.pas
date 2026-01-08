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
{$mode delphi}
unit uzccommand_setobjinsp;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzsbVarmanDef,Varman,
  uzeentity,
  uzcinterface,
  uzcdrawings,
  uzcsysvars,
  uzefontmanager,
  gzctnrVectorTypes;

implementation

function SetObjInsp_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  obj:ansistring;
  objt:PUserTypeDescriptor;
  pp:PGDBObjEntity;
  ir:itrec;
begin
  if Operands='VARS' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,drawings.GetCurrentDWG);
  end else if Operands='CAMERA' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBObjCamera'),
      drawings.GetCurrentDWG.pcamera,drawings.GetCurrentDWG);
  end else if Operands='CURRENT' then begin

    if (drawings.GetCurrentDWG.GetLastSelected<>nil)
    then begin
      obj:=
        pGDBObjEntity(drawings.GetCurrentDWG.GetLastSelected)^.GetObjTypeName;
      objt:=SysUnit.TypeName2PTD(obj);
      zcUI.Do_PrepareObject(
        drawings.GetUndoStack,drawings.GetUnitsFormat,objt,
        drawings.GetCurrentDWG.GetLastSelected,drawings.GetCurrentDWG);
    end else begin
      zcUI.TextMessage(
        'ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try SetObjInsp(SELECTED)...',
        TMWOShowError);
    end;
    SysVar.DWG.DWG_SelectedObjToInsp^:=False;
  end else if Operands='SELECTED' then begin
    begin
      //zcUI.TextMessage('ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try find selected in DRAWING...');
      pp:=
        drawings.GetCurrentROOT.objarray.beginiterate(ir);
      if pp<>nil then begin
        repeat
          if pp^.Selected then begin
            obj:=
              pp^.GetObjTypeName;
            objt:=
              SysUnit.TypeName2PTD(obj);
            zcUI.Do_PrepareObject(
              drawings.GetUndoStack,drawings.GetUnitsFormat,objt,pp,drawings.GetCurrentDWG);
            exit;
          end;
          pp:=
            drawings.GetCurrentROOT.objarray.iterate(ir);
        until pp=nil;
      end;
    end;
    SysVar.DWG.DWG_SelectedObjToInsp^:=False;
  end else if Operands='OGLWND_DEBUG' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('OGLWndtype'),@drawings.GetCurrentDWG.wa.param,drawings.GetCurrentDWG);
  end else if Operands='GDBDescriptor' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBDescriptor'),@drawings,drawings.GetCurrentDWG);
  end else if Operands='RELE_DEBUG' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('vardesk'),dbunit.FindVariable(
      'SEVCABLEkvvg'),drawings.GetCurrentDWG);
  end else if Operands='LAYERS' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('GDBLayerArray'),@drawings.GetCurrentDWG.LayerTable,drawings.GetCurrentDWG);
  end else if Operands='TSTYLES' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('GDBTextStyleArray'),@drawings.GetCurrentDWG.TextStyleTable,drawings.GetCurrentDWG);
  end else if Operands='FONTS' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('GDBFontManager'),@FontManager,drawings.GetCurrentDWG);
  end else if Operands='OSMODE' then begin
    OSModeEditor.GetState;
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor,drawings.GetCurrentDWG);
  end else if Operands='NUMERATORS' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBNumerator'),@drawings.GetCurrentDWG.Numerator,drawings.GetCurrentDWG);
  end else if Operands='LINETYPESTYLES' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBLtypeArray'),@drawings.GetCurrentDWG.LTypeStyleTable,drawings.GetCurrentDWG);
  end else if Operands='TABLESTYLES' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBTableStyleArray'),@drawings.GetCurrentDWG.TableStyleTable,drawings.GetCurrentDWG);
  end else if Operands='DIMSTYLES' then begin
    zcUI.Do_PrepareObject(
      nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBDimStyleArray'),@drawings.GetCurrentDWG.DimStyleTable,drawings.GetCurrentDWG);
  end;
  zcUI.Do_GUIaction(nil,zcMsgUISetDefaultObject);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@SetObjInsp_com,'SetObjInsp',CADWG,0).overlay:=True;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
