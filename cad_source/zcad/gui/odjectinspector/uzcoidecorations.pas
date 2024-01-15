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

unit uzcoidecorations;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,Graphics,LCLType,Themes,Forms,
  zcobjectinspectorui,uzctypesdecorations,uzccommandsabstract,uzepalette,
  zcobjectinspectoreditors,UEnumDescriptor,zcobjectinspector,uzcinfoform,
  uzestyleslinetypes,uzctreenode,uzcfsnapeditor,
  uzeconsts,UGDBNamedObjectsArray,uzctnrvectorstrings,
  varmandef,Varman,uzcfcolors,uzestyleslayers,uzbtypes,uzcflineweights,usupportgui,
  StdCtrls,uzcdrawings,uzcstrconsts,Controls,Classes,uzbstrproc,uzcsysvars,uzccommandsmanager,
  uzcsysparams,gzctnrVectorTypes,uzegeometrytypes,uzcinterface,uzcoimultiobjects,
  uzcgui2color,uzcgui2linewidth,uzcgui2linetypes,
  uzccommand_layer,uzcuitypes,uzeNamedObject,uzccommandsimpl,uzedimensionaltypes;
type
    AsyncCommHelper=class
                         class procedure GetVertex(Pinstance:PtrInt);
                         class procedure GetLength(Pinstance:PtrInt);
                         class procedure GetVertexX(Pinstance:PtrInt);
                         class procedure GetVertexY(Pinstance:PtrInt);
                         class procedure GetVertexZ(Pinstance:PtrInt);
    end;
procedure DecorateSysTypes;
procedure ButtonTxtDrawFastEditor(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure RunAnsiStringEditor(PInstance:Pointer);
implementation
var
   count:integer;
function LWDecorator(PInstance:Pointer):String;
begin
     result:=GetLWNameFromLW(PTGDBLineWeight(PInstance)^);
end;
function NamedObjectsDecorator(PInstance:Pointer):String;
begin
     if PGDBLayerProp(PInstance^)<>nil then
                                           begin
                                           result:=Tria_AnsiToUtf8(PGDBNamedObject(ppointer(PInstance)^).Name)
                                           end
                                       else
                                           result:=rsUnassigned;
end;
function PaletteColorDecorator(PInstance:Pointer):String;
begin
     result:=ColorIndex2Name(PTGDBPaletteColor(PInstance)^);
end;
procedure CreateComboPropEditor(TheOwner:TPropEditorOwner;pinstance:pointer;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;out propeditor:TPropEditor; out cbedit:TComboBox;f:TzeUnitsFormat);
begin
  propeditor:=TPropEditor.Create(theowner,PInstance,ptd^,FreeOnLostFocus,f);
  propeditor.byObjects:=true;
  propeditor.changed:=false;
  cbedit:=TComboBox.Create(propeditor);
  cbedit.Text:=PTD.GetValueAsString(pinstance);
  cbedit.OnChange:=propeditor.EditingProcess;
  SetComboSize(cbedit,sysvar.INTF.INTF_DefaultControlHeight^-6,CBReadOnly);
  {$IFNDEF DELPHI}
  {cbedit.ReadOnly:=true;//now it deprecated, see in SetComboSize}
  {$ENDIF}
end;

function NamedObjectsDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;NO:PTGenericNamedObjectsArray;f:TzeUnitsFormat):TEditorDesc;
var
    cbedit:TComboBox;
    ir:itrec;
    number:integer;
    p,pcurrent:PGDBLayerProp;
begin
     CreateComboPropEditor(TheOwner,pinstance,FreeOnLostFocus,PTD,result.editor,cbedit,f);

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
function LineWeightDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;f:TzeUnitsFormat):TEditorDesc;
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
     CreateComboPropEditor(TheOwner,pinstance,FreeOnLostFocus,PTD,result.editor,cbedit,f);
     SetComboSize(cbedit,sysvar.INTF.INTF_DefaultControlHeight^-6,CBReadOnly);
     cbedit.Style:=csOwnerDrawFixed;
     cbedit.OnDrawItem:=TSupportLineWidthCombo.LineWBoxDrawItem;

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
function LayersDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;f:TzeUnitsFormat):TEditorDesc;
begin
     result:=NamedObjectsDecoratorCreateEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,PTD,@drawings.GetCurrentDWG.LayerTable,f);
end;
function LTypeDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;f:TzeUnitsFormat):TEditorDesc;
var
    cbedit:TComboBox;
begin
     result:=NamedObjectsDecoratorCreateEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,PTD,@drawings.GetCurrentDWG.LTypeStyleTable,f);
     cbedit:=TComboBox(result.Editor.geteditor);
     SetComboSize(cbedit,sysvar.INTF.INTF_DefaultControlHeight^-6,CBReadOnly);
     cbedit.Style:=csOwnerDrawFixed;
     cbedit.OnDrawItem:=TSupportLineTypeCombo.LTypeBoxDrawItem;
end;
function TextStyleDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;f:TzeUnitsFormat):TEditorDesc;
begin
     result:=NamedObjectsDecoratorCreateEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,PTD,@drawings.GetCurrentDWG.TextStyleTable,f);
end;
function DimStyleDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;f:TzeUnitsFormat):TEditorDesc;
begin
     result:=NamedObjectsDecoratorCreateEditor(TheOwner,rect,pinstance,psa,FreeOnLostFocus,PTD,@drawings.GetCurrentDWG.DimStyleTable,f);
end;
procedure _3SBooleanDrawFastEditor(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
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
     ThemeServices.DrawElement(Canvas.Handle,Details,r,@boundr);
end;
procedure ButtonXDrawFastEditor(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'x',boundr);
end;
procedure ButtonYDrawFastEditor(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'y',boundr);
end;
procedure ButtonZDrawFastEditor(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'z',boundr);
end;
procedure ButtonTxtDrawFastEditor(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'T',boundr);
end;
procedure _3SBooleanInverse(PInstance:Pointer);
begin
     case PTGDB3StateBool(PInstance)^ of
         T3SB_Fale:PTGDB3StateBool(PInstance)^:=T3SB_True;
         T3SB_True:PTGDB3StateBool(PInstance)^:=T3SB_Default;
         T3SB_Default:PTGDB3StateBool(PInstance)^:=T3SB_Fale;
     end;
end;

procedure runlayerswnd(PInstance:Pointer);
begin
     layer_cmd(TZCADCommandContext.CreateRec,EmptyCommandOperands);
end;
procedure runcolorswnd(PInstance:Pointer);
var
   mr:integer;
begin
     if not assigned(ColorSelectForm)then
     Application.CreateForm(TColorSelectForm, ColorSelectForm);
     SetHeightControl(ColorSelectForm,sysvar.INTF.INTF_DefaultControlHeight^);
     ZCMsgCallBackInterface.Do_BeforeShowModal(ColorSelectForm);
     mr:=ColorSelectForm.run(PTGDBPaletteColor(PInstance)^,true){showmodal};
     if mr=ZCmrOk then
                    begin
                    PTGDBPaletteColor(PInstance)^:=ColorSelectForm.ColorInfex;
                    end;
     ZCMsgCallBackInterface.Do_AfterShowModal(ColorSelectForm);
     freeandnil(ColorSelectForm);
end;
procedure drawLWProp(canvas:TCanvas;ARect:TRect;PInstance:Pointer);
var
   index:TGDBLineWeight;
   ll:integer;
   s:String;
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
procedure drawIndexColorProp(canvas:TCanvas;ARect:TRect;PInstance:Pointer);
var
   index:TGDBLineWeight;
begin
     index:=PTGDBPaletteColor(PInstance)^;
     DrawColor(Canvas,Index,ARect);
end;
function CreateEmptyEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor):TEditorDesc;
begin
     result.mode:=TEM_Nothing;
     result.Editor:=nil;
end;
procedure runOSwnd(PInstance:Pointer);
begin
  SnapEditorForm:=TSnapEditorForm.Create(nil);
  SetHeightControl(SnapEditorForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(SnapEditorForm);
  Freeandnil(SnapEditorForm);
end;
function ColorDecoratorCreateEditor(TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;PTD:PUserTypeDescriptor;f:TzeUnitsFormat):TEditorDesc;
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
     CreateComboPropEditor(TheOwner,pinstance,FreeOnLostFocus,PTD,result.editor,cbedit,f);
     SetComboSize(cbedit,sysvar.INTF.INTF_DefaultControlHeight^-6,CBReadOnly);
     cbedit.Style:=csOwnerDrawFixed;
     cbedit.OnDrawItem:=TSupportColorCombo.ColorDrawItem;

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
procedure drawLTProp(canvas:TCanvas;ARect:TRect;PInstance:Pointer);
var
   PLT:PGDBLtypeProp;
   s:String;
begin
     PLT:=ppointer(PInstance)^;
     if plt<>nil then
                        begin
                             s:=Tria_AnsiToUtf8(plt^.Name);
                        end
                    else
                        begin
                            s:=rsDifferent;
                            if drawings.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                      exit;
                        end;

         ARect.Left:=ARect.Left+2;
         drawLT(canvas,ARect,s,plt);
end;
procedure RunStringEditor(PInstance:Pointer);
var
   modalresult:integer;
   InfoForm:TInfoForm=nil;
begin
     if not assigned(InfoForm) then
     begin
     InfoForm:=TInfoForm.createnew(application.MainForm);
     InfoForm.BoundsRect:=GetBoundsFromSavedUnit('TEdWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny);
     end;
     InfoForm.caption:=(rsTextEdCaption);
     if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
        InfoForm.memo.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;

     InfoForm.memo.text:=pString(PInstance)^;
     modalresult:=ZCMsgCallBackInterface.DOShowModal(InfoForm);
     if modalresult=ZCMrOk then
                         begin
                              pString(PInstance)^:=InfoForm.memo.text;
                              StoreBoundsToSavedUnit('TEdWND',InfoForm.BoundsRect);
                         end;
end;
procedure RunAnsiStringEditor(PInstance:Pointer);
var
   modalresult:integer;
   InfoForm:TInfoForm=nil;
begin
     if not assigned(InfoForm) then
     begin
     InfoForm:=TInfoForm.createnew(application.MainForm);
     InfoForm.BoundsRect:=GetBoundsFromSavedUnit('TEdWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny);
     end;
     InfoForm.caption:=(rsTextEdCaption);
     if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
        InfoForm.memo.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;

     InfoForm.memo.text:=ConvertFromDxfString(UnicodeString(pString(PInstance)^));
     modalresult:=ZCMsgCallBackInterface.DOShowModal(InfoForm);
     if modalresult=ZCMrOk then
                         begin
                              pString(PInstance)^:=String(ConvertToDxfString(InfoForm.memo.text));
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
                                                  commandmanager.PushValue('','PGDBObjEntity',@GDBobjinsp.CurrPObj)
                                              else
                                                  begin
                                                       p:=nil;
                                                       commandmanager.PushValue('','PGDBObjEntity',@p)
                                                  end;
                         commandmanager.executecommand('GetPoint',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
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
                                                  commandmanager.PushValue('','PGDBObjEntity',@GDBobjinsp.CurrPObj)
                                              else
                                                  begin
                                                       p:=nil;
                                                       commandmanager.PushValue('','PGDBObjEntity',@p)
                                                  end;
                         commandmanager.executecommand('GetLength',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                         GDBobjinsp.UpdateObjectInInsp;
                    end;
end;
class procedure AsyncCommHelper.GetVertexX(Pinstance:PtrInt);
var
   p:pointer;
begin
     if count>0 then
                    begin
                        dec(count);
                        Application.QueueAsyncCall(GetVertexX,PtrInt(PInstance));
                    end
                else
                    begin
                         commandmanager.PushValue('','PGDBXCoordinate',@PInstance);
                         if GDBobjinsp.GDBobj then
                                                  commandmanager.PushValue('','PGDBObjEntity',@GDBobjinsp.CurrPObj)
                                              else
                                                  begin
                                                       p:=nil;
                                                       commandmanager.PushValue('','PGDBObjEntity',@p)
                                                  end;
                         commandmanager.executecommand('GetVertexX',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                         GDBobjinsp.UpdateObjectInInsp;
                    end;
end;
class procedure AsyncCommHelper.GetVertexY(Pinstance:PtrInt);
var
   p:pointer;
begin
     if count>0 then
                    begin
                        dec(count);
                        Application.QueueAsyncCall(GetVertexY,PtrInt(PInstance));
                    end
                else
                    begin
                         commandmanager.PushValue('','PGDBYCoordinate',@PInstance);
                         if GDBobjinsp.GDBobj then
                                                  commandmanager.PushValue('','PGDBObjEntity',@GDBobjinsp.CurrPObj)
                                              else
                                                  begin
                                                       p:=nil;
                                                       commandmanager.PushValue('','PGDBObjEntity',@p)
                                                  end;
                         commandmanager.executecommand('GetVertexY',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                         GDBobjinsp.UpdateObjectInInsp;
                    end;
end;
class procedure AsyncCommHelper.GetVertexZ(Pinstance:PtrInt);
var
   p:pointer;
begin
     if count>0 then
                    begin
                        dec(count);
                        Application.QueueAsyncCall(GetVertexZ,PtrInt(PInstance));
                    end
                else
                    begin
                         commandmanager.PushValue('','PGDBZCoordinate',@PInstance);
                         if GDBobjinsp.GDBobj then
                                                  commandmanager.PushValue('','PGDBObjEntity',@GDBobjinsp.CurrPObj)
                                              else
                                                  begin
                                                       p:=nil;
                                                       commandmanager.PushValue('','PGDBObjEntity',@p)
                                                  end;
                         commandmanager.executecommand('GetVertexZ',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                         GDBobjinsp.UpdateObjectInInsp;
                    end;
end;
procedure GetLengthFromDrawing(PInstance:PGDBVertex);
begin
     commandmanager.executecommandtotalend;
     count:=1;
     Application.QueueAsyncCall(AsyncCommHelper.GetLength,PtrInt(PInstance));
end;
procedure GetXFromDrawing(PInstance:PGDBVertex);
begin
     commandmanager.executecommandtotalend;
     count:=1;
     Application.QueueAsyncCall(AsyncCommHelper.GetVertexX,PtrInt(PInstance));
end;
procedure GetYFromDrawing(PInstance:PGDBVertex);
begin
     commandmanager.executecommandtotalend;
     count:=1;
     Application.QueueAsyncCall(AsyncCommHelper.GetVertexY,PtrInt(PInstance));
end;
procedure GetZFromDrawing(PInstance:PGDBVertex);
begin
     commandmanager.executecommandtotalend;
     count:=1;
     Application.QueueAsyncCall(AsyncCommHelper.GetVertexZ,PtrInt(PInstance));
end;
procedure DecorateSysTypes;
begin
     AddEditorToType(SysUnit.TypeName2PTD('Boolean'),TBaseTypesEditors.BooleanCreateEditor);
     //AddEditorToType(SysUnit.TypeName2PTD('Boolean'),TBaseTypesEditors.BooleanCreateEditor);


     AddEditorToType(SysUnit.TypeName2PTD('ShortInt'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('Byte'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('SmallInt'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('Word'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('LongInt'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('LongWord'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('QWord'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('Double'),TBaseTypesEditors.BaseCreateEditor);
     //AddEditorToType(SysUnit.TypeName2PTD('Double'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('GDBNonDimensionDouble'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('GDBAngleDouble'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('GDBAngleDegDouble'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('String'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('AnsiString'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('UnicodeString'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('Single'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('Pointer'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('PtrUInt'),TBaseTypesEditors.BaseCreateEditor);
     AddEditorToType(SysUnit.TypeName2PTD('TEnumDataDescriptor'),TBaseTypesEditors.TEnumDataCreateEditor);
     EnumGlobalEditor:=TBaseTypesEditors.EnumDescriptorCreateEditor;


     DecorateType(SysUnit.TypeName2PTD('TGDBLineWeight'),@LWDecorator,@LineWeightDecoratorCreateEditor,@drawLWProp);
     DecorateType(SysUnit.TypeName2PTD('PGDBLayerPropObjInsp'),@NamedObjectsDecorator,@LayersDecoratorCreateEditor,nil);
     DecorateType(SysUnit.TypeName2PTD('PGDBLtypePropObjInsp'),@NamedObjectsDecorator,@LTypeDecoratorCreateEditor,@drawLTProp);
     DecorateType(SysUnit.TypeName2PTD('PGDBTextStyleObjInsp'),@NamedObjectsDecorator,@TextStyleDecoratorCreateEditor,nil);
     DecorateType(SysUnit.TypeName2PTD('PGDBDimStyleObjInsp'),@NamedObjectsDecorator,@DimStyleDecoratorCreateEditor,nil);
     DecorateType(SysUnit.TypeName2PTD('TGDBPaletteColor'),@PaletteColorDecorator,@ColorDecoratorCreateEditor,@drawIndexColorProp);
     DecorateType(SysUnit.TypeName2PTD('TGDBOSMode'),nil,CreateEmptyEditor,nil);

     AddFastEditorToType(SysUnit.TypeName2PTD('Integer'),@OIUI_FE_HalfButtonGetPrefferedSize,@OIUI_FE_ButtonGreatThatDraw,@OIUI_FE_IntegerInc);
     AddFastEditorToType(SysUnit.TypeName2PTD('Integer'),@OIUI_FE_HalfButtonGetPrefferedSize,@OIUI_FE_ButtonLessThatDraw,@OIUI_FE_IntegerDec);

     AddFastEditorToType(SysUnit.TypeName2PTD('TArrayIndex'),@OIUI_FE_HalfButtonGetPrefferedSize,@OIUI_FE_ButtonGreatThatDraw,@OIUI_FE_IntegerInc);
     AddFastEditorToType(SysUnit.TypeName2PTD('TArrayIndex'),@OIUI_FE_HalfButtonGetPrefferedSize,@OIUI_FE_ButtonLessThatDraw,@OIUI_FE_IntegerDec);

     AddFastEditorToType(SysUnit.TypeName2PTD('TGDBPaletteColor'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonDraw,@runcolorswnd);
     AddFastEditorToType(SysUnit.TypeName2PTD('Boolean'),@OIUI_FE_BooleanGetPrefferedSize,@OIUI_FE_BooleanDraw,@OIUI_FE_BooleanInverse);
     AddFastEditorToType(SysUnit.TypeName2PTD('TGDB3StateBool'),@OIUI_FE_BooleanGetPrefferedSize,@_3SBooleanDrawFastEditor,@_3SBooleanInverse);
     AddFastEditorToType(SysUnit.TypeName2PTD('PGDBLayerPropObjInsp'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonDraw,@runlayerswnd);
     AddFastEditorToType(SysUnit.TypeName2PTD('String'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunStringEditor);
     AddFastEditorToType(SysUnit.TypeName2PTD('AnsiString'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunAnsiStringEditor);
     AddFastEditorToType(SysUnit.TypeName2PTD('GDBCoordinates3D'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonCrossDraw,@GetVertexFromDrawing,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('GDBLength'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonHLineDraw,@GetLengthFromDrawing,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('GDBXCoordinate'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonXDrawFastEditor,@GetXFromDrawing,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('GDBYCoordinate'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonYDrawFastEditor,@GetYFromDrawing,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('GDBZCoordinate'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonZDrawFastEditor,@GetZFromDrawing,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('TGDBOSMode'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonDraw,@runOSwnd);
     AddFastEditorToType(SysUnit.TypeName2PTD('TMSPrimitiveDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonHLineDraw,@DeselectEnts,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('TMSPrimitiveDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonMultiplyDraw,@SelectOnlyThisEnts,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('TMSBlockNamesDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonHLineDraw,@DeselectBlocsByName,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('TMSBlockNamesDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonMultiplyDraw,@SelectOnlyThisBlocsByName,true);

     AddFastEditorToType(SysUnit.TypeName2PTD('TMSTextsStylesDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonHLineDraw,@DeselectTextsByStyle,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('TMSTextsStylesDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonMultiplyDraw,@SelectOnlyThisTextsByStyle,true);

     AddFastEditorToType(SysUnit.TypeName2PTD('TMSEntsLayersDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonHLineDraw,@DeselectEntsByLayer,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('TMSEntsLayersDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonMultiplyDraw,@SelectOnlyThisEntsByLayer,true);

     AddFastEditorToType(SysUnit.TypeName2PTD('TMSEntsLinetypesDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonHLineDraw,@DeselectEntsByLinetype,true);
     AddFastEditorToType(SysUnit.TypeName2PTD('TMSEntsLinetypesDetector'),@OIUI_FE_ButtonGetPrefferedSize,@OIUI_FE_ButtonMultiplyDraw,@SelectOnlyThisEntsByLinetype,true);

end;
end.
