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

unit ugdbdrawing;
{$INCLUDE def.inc}
interface
uses
paths,ugdbdimstylearray,WindowsSpecific,LResources,zcadsysvars,zcadstrconsts,UGDBOpenArrayOfUCommands,strproc,GDBBlockDef,UUnitManager,
gdbase,varmandef,varman,
sysutils, memman, geometry, gdbobjectsconstdef,
gdbasetypes,sysinfo,ugdbsimpledrawing,
UGDBLayerArray,
GDBEntity,
UGDBFontManager,
UGDBOpenArrayOfPObjects,ugdbtrash,UGDBOpenArrayOfByte;
type
{EXPORT+}
{TDWGProps=packed record
                Name:GDBString;
                Number:GDBInteger;
          end;}
PTDrawing=^TDrawing;
TDrawing={$IFNDEF DELPHI}packed{$ENDIF} object(TSimpleDrawing)

           FileName:GDBString;
           Changed:GDBBoolean;
           attrib:GDBLongword;
           UndoStack:GDBObjOpenArrayOfUCommands;
           DWGUnits:TUnitManager;

           constructor init(num:PTUnitManager;preloadedfile1,preloadedfile2:GDBString);
           destructor done;virtual;
           function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;

           procedure SetCurrentDWG;virtual;
           function StoreOldCamerapPos:Pointer;virtual;
           procedure StoreNewCamerapPos(command:Pointer);virtual;
           //procedure SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
           procedure rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);virtual;
           procedure PushStartMarker(CommandName:GDBString);virtual;
           procedure PushEndMarker;virtual;
           procedure SetFileName(NewName:GDBString);virtual;
           function GetFileName:GDBString;virtual;
           procedure ChangeStampt(st:GDBBoolean);virtual;
           function GetChangeStampt:GDBBoolean;virtual;
           function GetUndoTop:TArrayIndex;virtual;
           function GetUndoStack:GDBPointer;virtual;
           function CanUndo:boolean;virtual;
           function CanRedo:boolean;virtual;
           function GetDWGUnits:{PTUnitManager}pointer;virtual;
           procedure AddBlockFromDBIfNeed(name:GDBString);virtual;
     end;
{EXPORT-}
//procedure standardization(PEnt:PGDBObjEntity;ObjType:TObjID);
implementation
 uses UGDBDescriptor,GDBText,GDBDevice,GDBBlockInsert,iodxf, GDBManager,shared,commandline,log;
procedure TDrawing.SetCurrentDWG();
begin
  gdb.SetCurrentDWG(@self);
end;
function TDrawing.StoreOldCamerapPos:Pointer;
begin
     result:=UndoStack.PushCreateTGChangeCommand(GetPcamera^.prop)
end;
procedure TDrawing.rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);
var
    tum:TUndableMethod;
begin
  tmethod(tum).Code:=pointer(obj.rtmodifyonepoint);
  tmethod(tum).Data:=obj;
  //tum:=tundablemethod(obj^.rtmodifyonepoint);
  with UndoStack.PushCreateTGObjectChangeCommand(rtmod,tmethod(tum))^ do
  begin
       comit;
       rtmod.wc:=rtmod.point.worldcoord;
       rtmod.dist:=nulvertex;
       StoreUndoData(rtmod);
  end;
end;
procedure TDrawing.StoreNewCamerapPos(command:Pointer);
begin
     if command<>nil then
                         PTGDBCameraBasePropChangeCommand(command).ComitFromObj;
end;
procedure TDrawing.PushStartMarker(CommandName:GDBString);
begin
     self.UndoStack.PushStartMarker(CommandName);
end;
procedure TDrawing.PushEndMarker;
begin
      self.UndoStack.PushEndMarker;
end;
procedure TDrawing.SetFileName(NewName:GDBString);
begin
     self.FileName:=NewName;
end;
function TDrawing.GetFileName:GDBString;
begin
     result:=FileName;
end;
procedure TDrawing.ChangeStampt;
begin
     self.Changed:={true}st;
     inherited;
end;
function TDrawing.GetChangeStampt:GDBBoolean;
begin
     result:=self.Changed;
end;
function TDrawing.GetUndoTop:TArrayIndex;
begin
     result:=UndoStack.CurrentCommand;
end;
function TDrawing.GetUndoStack:GDBPointer;
begin
     result:=@UndoStack;
end;
function TDrawing.CanUndo:boolean;
begin
     if UndoStack.CurrentCommand>0 then
                                       result:=true
                                   else
                                       result:=false;
end;
function TDrawing.CanRedo:boolean;
begin
     if UndoStack.CurrentCommand<UndoStack.Count then
                                                     result:=true
                                                 else
                                                     result:=false;
end;
function TDrawing.GetDWGUnits:{PTUnitManager}pointer;
begin
     result:=@DWGUnits;
end;
procedure TDrawing.AddBlockFromDBIfNeed(name:GDBString);
begin
     gdb.AddBlockFromDBIfNeed(@self,name);
end;
constructor TDrawing.init;
var {tp:GDBTextStyleProp;}
    //ts:PTGDBTableStyle;
    //cs:TGDBTableCellStyle;
    pvd:pvardesk;
    pcam:pointer;
    pdwgwarsunit:ptunit;
begin
  DWGUnits.init;
  DWGUnits.SetNextManager(num);
  if preloadedfile1<>'' then
  DWGUnits.loadunit(expandpath({'*rtl/dwg/DrawingDeviceBase.pas')}preloadedfile1),nil);
  if preloadedfile2<>'' then
  DWGUnits.loadunit(expandpath({'*rtl/dwg/DrawingVars.pas'}preloadedfile2),nil);
  DWGDBUnit:=DWGUnits.findunit(DrawingDeviceBaseUnitName);

  pcam:=nil;
  pvd:=nil;
  pdwgwarsunit:=DWGUnits.findunit('DrawingVars');
  if assigned(pdwgwarsunit) then
                                pvd:=pdwgwarsunit.InterfaceVariables.findvardesc('camera');
  if pvd<>nil then
                  pcam:=pvd^.data.Instance;
  inherited init(pcam);


  Pointer(FileName):=nil;
  FileName:=rsHardUnnamed;
  Changed:=False;
  UndoStack.init;


  //OGLwindow1.initxywh('oglwnd',nil,200,72,768,596,false);
  //OGLwindow1.show;
end;
destructor TDrawing.done;
begin
     inherited;
     undostack.done;
     DWGUnits.FreeAndDone;
     FileName:='';
end;
//procedure TDrawing.SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
//begin
//end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('ugdbdrawing.initialization');{$ENDIF}
end.
