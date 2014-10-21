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

unit objinspdecorations;
{$INCLUDE def.inc}

interface

uses
  Objinsp,uinfoform,Forms,ugdbltypearray,sysutils,umytreenode,oswnd,gdbcommandsinterface,
  Graphics,LCLType,Themes,types,gdbobjectsconstdef,UGDBNamedObjectsArray,UGDBStringArray,
  varmandef,Varman,colorwnd,UGDBLayerArray,gdbase,lineweightwnd,gdbasetypes,usupportgui,
  StdCtrls,UGDBDescriptor,zcadstrconsts,Controls,Classes,strproc,zcadsysvars,commandline,
  zcadinterface;
type
    AsyncCommHelper=class
                         class procedure GetVertex(Pinstance:PtrInt);
                         class procedure GetLength(Pinstance:PtrInt);
    end;

procedure DecorateSysTypes;
implementation
uses
  mainwindow;
var
   count:integer;
function LWDecorator(PInstance:GDBPointer):GDBString;
begin
     result:=GetLWNameFromLW(PTGDBLineWeight(PInstance)^);
end;
function NamedObjectsDecorator(PInstance:GDBPointer):GDBString;
begin
     if PGDBLayerProp(PInstance^)<>nil then
                                           begin
                                           result:=Tria_AnsiToUtf8(PGDBNamedObject(ppointer(PInstance)^).Name)
                                           end
                                       else
                                           result:=rsUnassigned;
end;
function PaletteColorDecorator(PInstance:GDBPointer):GDBString;
begin
     result:=ColorIndex2Name(PTGDBPaletteColor(PInstance)^);
end;
procedure CreateComboPropEditor(TheOwner:TPropEditorOwner;pinstance:pointer;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;out propeditor:TPropEditor; out cbedit:TComboBox);
begin
  propeditor:=TPropEditor.Create(theowner,PInstance,ptd,FreeOnLostFocus);
  propeditor.byObjects:=true;
  propeditor.changed:=false;
  cbedit:=TComboBox.Create(propeditor);
  cbedit.Text:=PTD.GetValueAsString(pinstance);
  cbedit.OnChange:=propeditor.EditingProcess;
  SetComboSize(cbedit);
  {$IFNDEF DELPHI}
  cbedit.ReadOnly:=true;
  {$ENDIF}
end;

function NamedObjectsDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;NO:PGDBNamedObjectsArray):TEditorDesc;
var
    cbedit:TComboBox;
    ir:itrec;
    number:integer;
    p,pcurrent:PGDBLayerProp;
begin
     CreateComboPropEditor(TheOwner,pinstance,FreeOnLostFocus,PTD,result.editor,cbedit);

     pcurrent:=PGDBLayerProp(ppointer(pinstance)^);

                             p:=NO.beginiterate(ir);
                             if p<>nil then
                             repeat
                                   number:=cbedit.Items.AddObject(Tria_AnsiToUtf8(p^.Name),tobject(p));
                                   if pcurrent=p then
                                                     cbedit.ItemIndex:=number;
                                   p:=NO.iterate(ir);
                             until p=nil;

     result.mode:=TEM_Integrate;
end;
function LineWeightDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
var
    cbedit:TComboBox;
    i,seli:integer;
    currLW:TGDBLineWeight;
procedure addLWtoC(name:string;value:TGDBLineWeight);
begin
     cbedit.items.AddObject(name, TObject(value));
     if value=currLW then
                         seli:=cbedit.Items.Count-1;
end;

begin
     CreateComboPropEditor(TheOwner,pinstance,FreeOnLostFocus,PTD,result.editor,cbedit);
     SetComboSize(cbedit);
     cbedit.Style:=csOwnerDrawFixed;
     cbedit.OnDrawItem:=MainFormN.LineWBoxDrawItem;

     currLW:=PTGDBLineWeight(pinstance)^;
     seli:=0;

     addLWtoC(rsByLayer,LnWtByLayer);
     addLWtoC(rsByBlock,LnWtByBlock);
     addLWtoC(rsdefault,LnWtByLwDefault);
     for i := low(lwarray) to high(lwarray) do
     begin
          addLWtoC(GetLWNameFromN(i),lwarray[i]);
     end;
     cbedit.ItemIndex:=seli;
     result.mode:=TEM_Integrate;
end;
function LayersDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
begin
     result:=NamedObjectsDecoratorCreateEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,PTD,@gdb.GetCurrentDWG.LayerTable);
end;
function LTypeDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
var
    cbedit:TComboBox;
begin
     result:=NamedObjectsDecoratorCreateEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,PTD,@gdb.GetCurrentDWG.LTypeStyleTable);
     cbedit:=TComboBox(result.Editor.geteditor);
     SetComboSize(cbedit);
     cbedit.Style:=csOwnerDrawFixed;
     cbedit.OnDrawItem:=MainFormN.LTypeBoxDrawItem;
end;
function TextStyleDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
begin
     result:=NamedObjectsDecoratorCreateEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,PTD,@gdb.GetCurrentDWG.TextStyleTable);
end;
function DimStyleDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
begin
     result:=NamedObjectsDecoratorCreateEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,PTD,@gdb.GetCurrentDWG.DimStyleTable);
end;
procedure DecorateType(tn:string;getvalueasstring:TOnGetValueAsString;CreateEditor:TOnCreateEditor;DrawProperty:TOnDrawProperty);
var
   PT:PUserTypeDescriptor;
begin
     PT:=SysUnit.TypeName2PTD(tn);
     if PT<>nil then
                    begin
                         PT^.Decorators.OnGetValueAsString:=getvalueasstring;
                         PT^.Decorators.OnCreateEditor:=CreateEditor;
                         PT^.Decorators.OnDrawProperty:=DrawProperty;
                    end;
end;
function BooleanGetPrefferedFastEditorSize(PInstance:GDBPointer):TSize;
var
  Details: TThemedElementDetails;
  ComboElem:TThemedButton;
begin
     if assigned(PInstance) then
     begin
     ComboElem:=tbCheckBoxUncheckedNormal;
     Details:=ThemeServices.GetElementDetails(ComboElem);
     result:=ThemeServices.GetDetailSize(Details);
     end
     else
         result:=types.size(0,0);
end;
procedure BooleanDrawFastEditor(canvas:TCanvas;r:trect;PInstance:GDBPointer;state:TFastEditorState);
var
  Details: TThemedElementDetails;
  ComboElem:TThemedButton;
begin
     if pboolean(PInstance)^ then
                                 begin
                                 if state=TFES_Hot then
                                                       ComboElem:=tbCheckBoxCheckedHot
                                                   else if state=TFES_Pressed then
                                                       ComboElem:=tbCheckBoxCheckedPressed
                                                   else
                                                       ComboElem:=tbCheckBoxCheckedNormal
                                 end
                             else
                                 begin
                                 if state=TFES_Hot then
                                                       ComboElem:=tbCheckBoxUncheckedHot
                                                   else if state=TFES_Pressed then
                                                       ComboElem:=tbCheckBoxUncheckedPressed
                                                   else
                                                       ComboElem:=tbCheckBoxUncheckedNormal
                                 end;
     Details:=ThemeServices.GetElementDetails(ComboElem);
     ThemeServices.DrawElement(Canvas.Handle,Details,r);
end;
procedure _3SBooleanDrawFastEditor(canvas:TCanvas;r:trect;PInstance:GDBPointer;state:TFastEditorState);
var
  Details: TThemedElementDetails;
  ComboElem:TThemedButton;
begin
     case PTGDB3StateBool(PInstance)^ of
          T3SB_True:
                     begin
                     if state=TFES_Hot then
                                           ComboElem:=tbCheckBoxCheckedHot
                                       else if state=TFES_Pressed then
                                           ComboElem:=tbCheckBoxCheckedPressed
                                       else
                                           ComboElem:=tbCheckBoxCheckedNormal
                     end;
        T3SB_Fale:
                     begin
                     if state=TFES_Hot then
                                           ComboElem:=tbCheckBoxUncheckedHot
                                       else if state=TFES_Pressed then
                                           ComboElem:=tbCheckBoxUncheckedPressed
                                       else
                                           ComboElem:=tbCheckBoxUncheckedNormal
                     end;
        T3SB_Default:
                     begin
                     if state=TFES_Hot then
                                           ComboElem:=tbCheckBoxMixedHot
                                       else if state=TFES_Pressed then
                                           ComboElem:=tbCheckBoxMixedPressed
                                       else
                                           ComboElem:=tbCheckBoxMixedNormal
                     end;
     end;
     Details:=ThemeServices.GetElementDetails(ComboElem);
     ThemeServices.DrawElement(Canvas.Handle,Details,r);
end;

procedure ButtonDraw(canvas:TCanvas;r:trect;state:TFastEditorState;s:string);
var
  Details: TThemedElementDetails;
  ComboElem:TThemedButton;
begin
     if state=TFES_Hot then
                           ComboElem:=tbPushButtonHot
                       else if state=TFES_Pressed then
                           ComboElem:=tbPushButtonPressed
                       else
                           ComboElem:=tbPushButtonNormal;
     Details:=ThemeServices.GetElementDetails(ComboElem);
     ThemeServices.DrawElement(Canvas.Handle,Details,r);
     ThemeServices.DrawText(Canvas,Details,s,r,DT_CENTER or DT_VCENTER,0);
end;
procedure ButtonDrawFastEditor(canvas:TCanvas;r:trect;PInstance:GDBPointer;state:TFastEditorState);
begin
     ButtonDraw(canvas,r,state,'...');
end;
procedure ButtonCrossDrawFastEditor(canvas:TCanvas;r:trect;PInstance:GDBPointer;state:TFastEditorState);
begin
     ButtonDraw(canvas,r,state,'+');
end;
procedure ButtonHLineDrawFastEditor(canvas:TCanvas;r:trect;PInstance:GDBPointer;state:TFastEditorState);
begin
     ButtonDraw(canvas,r,state,'-');
end;
procedure ButtonTxtDrawFastEditor(canvas:TCanvas;r:trect;PInstance:GDBPointer;state:TFastEditorState);
begin
     ButtonDraw(canvas,r,state,'T');
end;
function ButtonGetPrefferedFastEditorSize(PInstance:GDBPointer):TSize;
var
  Details: TThemedElementDetails;
  ComboElem:TThemedButton;
begin
     if assigned(PInstance) then
     begin
     ComboElem:=tbCheckBoxCheckedNormal;
     Details:=ThemeServices.GetElementDetails(ComboElem);
     result:=ThemeServices.GetDetailSize(Details);
     end
     else
         result:=types.size(0,0);
     if assigned(sysvar.INTF.INTF_ObjInspRowH) then
                                                   begin
                                                        result.cx:=sysvar.INTF.INTF_ObjInspRowH^-6;
                                                        if result.cx<15 then
                                                                            result.cx:=15;
                                                        result.cy:=result.cx;
                                                   end
                                               else
                                                   begin
                                                        result.cx:=15;
                                                        result.cy:=15;
                                                   end

end;
procedure BooleanInverse(PInstance:GDBPointer);
begin
     pboolean(PInstance)^:=not pboolean(PInstance)^;
end;
procedure _3SBooleanInverse(PInstance:GDBPointer);
begin
     case PTGDB3StateBool(PInstance)^ of
         T3SB_Fale:PTGDB3StateBool(PInstance)^:=T3SB_True;
         T3SB_True:PTGDB3StateBool(PInstance)^:=T3SB_Default;
         T3SB_Default:PTGDB3StateBool(PInstance)^:=T3SB_Fale;
     end;
end;

procedure runlayerswnd(PInstance:GDBPointer);
begin
     layer_cmd;
end;
procedure runcolorswnd(PInstance:GDBPointer);
var
   mr:integer;
begin
     if not assigned(ColorSelectWND)then
     Application.CreateForm(TColorSelectWND, ColorSelectWND);
     SetHeightControl(ColorSelectWND,sysvar.INTF.INTF_ObjInspRowH^);
     if assigned(ShowAllCursorsProc) then
                                         ShowAllCursorsProc;
     mr:=ColorSelectWND.run(PTGDBPaletteColor(PInstance)^,true){showmodal};
     if mr=mrOk then
                    begin
                    PTGDBPaletteColor(PInstance)^:=ColorSelectWND.ColorInfex;
                    end;
     if assigned(RestoreAllCursorsProc) then
                                            RestoreAllCursorsProc;
     freeandnil(ColorSelectWND);
end;

procedure AddFastEditorToType(tn:string;GetPrefferedFastEditorSize:TGetPrefferedFastEditorSize;
                                        DrawFastEditor:TDrawFastEditor;
                                        RunFastEditor:TRunFastEditor;
                                        _UndoInsideFastEditor:GDBBoolean=false);
var
   PT:PUserTypeDescriptor;
begin
     PT:=SysUnit.TypeName2PTD(tn);
     if PT<>nil then
                    begin
                         PT^.FastEditor.OnGetPrefferedFastEditorSize:=GetPrefferedFastEditorSize;
                         PT^.FastEditor.OnDrawFastEditor:=DrawFastEditor;
                         PT^.FastEditor.OnRunFastEditor:=RunFastEditor;
                         PT^.FastEditor.UndoInsideFastEditor:=_UndoInsideFastEditor;
                    end;
end;
procedure drawLWProp(canvas:TCanvas;ARect:TRect;PInstance:GDBPointer);
var
   index:TGDBLineWeight;
   ll:integer;
   s:gdbstring;
begin
     index:=PTGDBLineWeight(PInstance)^;
     s:=GetLWNameFromLW(index);
    if (index<1) then
               ll:=0
           else
               ll:=30;
     ARect.Left:=ARect.Left+2;

     DrawLW(canvas,ARect,ll,(index) div 10,s);
end;
procedure drawIndexColorProp(canvas:TCanvas;ARect:TRect;PInstance:GDBPointer);
var
   index:TGDBLineWeight;
begin
     index:=PTGDBPaletteColor(PInstance)^;
     DrawColor(Canvas,Index,ARect);
end;
function CreateEmptyEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
begin
     result.mode:=TEM_Nothing;
     result.Editor:=nil;
end;
procedure runOSwnd(PInstance:GDBPointer);
begin
  OSWindow:=TOSWindow.Create(nil);
  SetHeightControl(OSWindow,sysvar.INTF.INTF_ObjInspRowH^);
  DOShowModal(OSWindow);
  Freeandnil(OSWindow);
end;
function ColorDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PGDBGDBStringArray;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
var
    cbedit:TComboBox;
    i,seli:integer;
    currColor:TGDBPaletteColor;
procedure addColorToC(name:string;value:TGDBPaletteColor);
begin
     cbedit.items.AddObject(name, TObject(value));
     if value=currColor then
                         seli:=cbedit.Items.Count-1;
end;

begin
     CreateComboPropEditor(TheOwner,pinstance,FreeOnLostFocus,PTD,result.editor,cbedit);
     SetComboSize(cbedit);
     cbedit.Style:=csOwnerDrawFixed;
     cbedit.OnDrawItem:=MainFormN.ColorDrawItem;

     currColor:=PTGDBPaletteColor(pinstance)^;
     seli:=-1;
     addColorToC(ColorIndex2Name(ClByBlock),ClByBlock);
     addColorToC(ColorIndex2Name(ClByLayer),ClByLayer);
     for i := 1 to 7 do
     begin
          addColorToC(ColorIndex2Name(i),i);
     end;
     if seli=-1 then
                    addColorToC(ColorIndex2Name(currColor),currColor);

     result.editor.CanRunFastEditor:=true;
     result.editor.RunFastEditorValue:=tobject(ClSelColor);
     addColorToC(rsSelectColor,ClSelColor);

     cbedit.ItemIndex:=seli;
     result.mode:=TEM_Integrate;
end;
procedure drawLTProp(canvas:TCanvas;ARect:TRect;PInstance:GDBPointer);
var
   PLT:PGDBLtypeProp;
   s:gdbstring;
begin
     PLT:=ppointer(PInstance)^;
     if plt<>nil then
                        begin
                             s:=Tria_AnsiToUtf8(plt^.Name);
                        end
                    else
                        begin
                            s:=rsDifferent;
                            if gdb.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                      exit;
                        end;

         ARect.Left:=ARect.Left+2;
         drawLT(canvas,ARect,s,plt);
end;
procedure RunStringEditor(PInstance:GDBPointer);
var
   modalresult:integer;
   InfoForm:TInfoForm=nil;
begin
     if not assigned(InfoForm) then
     begin
     InfoForm:=TInfoForm.createnew(application.MainForm);
     InfoForm.BoundsRect:=GetBoundsFromSavedUnit('TEdWND');
     end;
     InfoForm.caption:=(rsTextEdCaption);

     InfoForm.memo.text:=pgdbstring(PInstance)^;
     modalresult:=DOShowModal(InfoForm);
     if modalresult=MrOk then
                         begin
                              pgdbstring(PInstance)^:=InfoForm.memo.text;
                              StoreBoundsToSavedUnit('TEdWND',InfoForm.BoundsRect);
                         end;
end;
procedure RunAnsiStringEditor(PInstance:GDBPointer);
var
   modalresult:integer;
   InfoForm:TInfoForm=nil;
begin
     if not assigned(InfoForm) then
     begin
     InfoForm:=TInfoForm.createnew(application.MainForm);
     InfoForm.BoundsRect:=GetBoundsFromSavedUnit('TEdWND');
     end;
     InfoForm.caption:=(rsTextEdCaption);

     InfoForm.memo.text:=ConvertFromDxfString(pgdbstring(PInstance)^);
     modalresult:=DOShowModal(InfoForm);
     if modalresult=MrOk then
                         begin
                              pgdbstring(PInstance)^:=ConvertToDxfString(InfoForm.memo.text);
                              StoreBoundsToSavedUnit('TEdWND',InfoForm.BoundsRect);
                         end;
end;
class procedure AsyncCommHelper.GetVertex(Pinstance:PtrInt);
var
   p:pointer;
begin
     if count>0 then
                    begin
                        dec(count);
                        Application.QueueAsyncCall(GetVertex,PtrInt(PInstance));
                    end
                else
                    begin
                         commandmanager.PushValue('','PGDBVertex',@PInstance);
                         if GDBobjinsp.GDBobj then
                                                  commandmanager.PushValue('','PGDBObjEntity',@GDBobjinsp.pcurrobj)
                                              else
                                                  begin
                                                       p:=nil;
                                                       commandmanager.PushValue('','PGDBObjEntity',@p)
                                                  end;
                         commandmanager.executecommand('GetPoint',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
                         GDBobjinsp.UpdateObjectInInsp;
                    end;
end;
procedure GetVertexFromDrawing(PInstance:PGDBVertex);
begin
     commandmanager.executecommandtotalend;
     count:=1;
     Application.QueueAsyncCall(AsyncCommHelper.GetVertex,PtrInt(PInstance));
end;
class procedure AsyncCommHelper.GetLength(Pinstance:PtrInt);
var
   p:pointer;
begin
     if count>0 then
                    begin
                        dec(count);
                        Application.QueueAsyncCall(GetLength,PtrInt(PInstance));
                    end
                else
                    begin
                         commandmanager.PushValue('','PGDBLength',@PInstance);
                         if GDBobjinsp.GDBobj then
                                                  commandmanager.PushValue('','PGDBObjEntity',@GDBobjinsp.pcurrobj)
                                              else
                                                  begin
                                                       p:=nil;
                                                       commandmanager.PushValue('','PGDBObjEntity',@p)
                                                  end;
                         commandmanager.executecommand('GetLength',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
                         GDBobjinsp.UpdateObjectInInsp;
                    end;
end;
procedure GetLengthFromDrawing(PInstance:PGDBVertex);
begin
     commandmanager.executecommandtotalend;
     count:=1;
     Application.QueueAsyncCall(AsyncCommHelper.GetLength,PtrInt(PInstance));
end;
procedure DecorateSysTypes;
begin
     DecorateType('TGDBLineWeight',@LWDecorator,@LineWeightDecoratorCreateEditor,@drawLWProp);
     DecorateType('PGDBLayerPropObjInsp',@NamedObjectsDecorator,@LayersDecoratorCreateEditor,nil);
     DecorateType('PGDBLtypePropObjInsp',@NamedObjectsDecorator,@LTypeDecoratorCreateEditor,@drawLTProp);
     DecorateType('PGDBTextStyleObjInsp',@NamedObjectsDecorator,@TextStyleDecoratorCreateEditor,nil);
     DecorateType('PGDBDimStyleObjInsp',@NamedObjectsDecorator,@DimStyleDecoratorCreateEditor,nil);
     DecorateType('TGDBPaletteColor',@PaletteColorDecorator,@ColorDecoratorCreateEditor,@drawIndexColorProp);
     DecorateType('TGDBOSMode',nil,CreateEmptyEditor,nil);

     AddFastEditorToType('TGDBPaletteColor',@ButtonGetPrefferedFastEditorSize,@ButtonDrawFastEditor,@runcolorswnd);
     AddFastEditorToType('GDBBoolean',@BooleanGetPrefferedFastEditorSize,@BooleanDrawFastEditor,@BooleanInverse);
     AddFastEditorToType('TGDB3StateBool',@BooleanGetPrefferedFastEditorSize,@_3SBooleanDrawFastEditor,@_3SBooleanInverse);
     AddFastEditorToType('PGDBLayerPropObjInsp',@ButtonGetPrefferedFastEditorSize,@ButtonDrawFastEditor,@runlayerswnd);
     AddFastEditorToType('GDBString',@ButtonGetPrefferedFastEditorSize,@ButtonTxtDrawFastEditor,@RunStringEditor);
     AddFastEditorToType('GDBAnsiString',@ButtonGetPrefferedFastEditorSize,@ButtonTxtDrawFastEditor,@RunAnsiStringEditor);
     AddFastEditorToType('GDBCoordinates3D',@ButtonGetPrefferedFastEditorSize,@ButtonCrossDrawFastEditor,@GetVertexFromDrawing,true);
     AddFastEditorToType('GDBLength',@ButtonGetPrefferedFastEditorSize,@ButtonHLineDrawFastEditor,@GetLengthFromDrawing,true);
     AddFastEditorToType('TGDBOSMode',@ButtonGetPrefferedFastEditorSize,@ButtonDrawFastEditor,@runOSwnd);
end;
end.