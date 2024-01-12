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
unit uzccommand_matchprop;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,uzgldrawcontext,uzcdrawing,uzeconsts,gzundoCmdChgData,
  URecordDescriptor,typedescriptors,Varman;

//type
implementation

type
  //** Тип данных для отображения в инспекторе опций команды MatchProp о текстовых примитивах, составная часть TMatchPropParam
  TMatchPropTextParam=record
    ProcessTextStyle:Boolean;(*'Process style'*)
    ProcessTextSize:Boolean;(*'Process size'*)
    ProcessTextOblique:Boolean;(*'Process oblique'*)
    ProcessTextWFactor:Boolean;(*'Process wfactor'*)
    ProcessTextJustify:Boolean;(*'Process justify'*)
  end;
  //** Тип данных для отображения в инспекторе опций команды MatchProp
  TMatchPropParam=record
    ProcessLayer:Boolean;(*'Process layer'*)
    ProcessLineWeight:Boolean;(*'Process line weight'*)
    ProcessLineType:Boolean;(*'Process line type'*)
    ProcessLineTypeScale:Boolean;(*'Process line type scale'*)
    ProcessColor:Boolean;(*'Process color'*)
    TextParams:TMatchPropTextParam;(*'Text params'*)
  end;

var
   MatchPropParam:TMatchPropParam; //**< Переменная содержащая опции команды MatchProp

function matchprop_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    ps,pd:PGDBObjEntity;
    SourceObjType:TObjID;
    isSourceObjText:boolean;
    dc:TDrawContext;
    UndoStartMarkerPlaced:boolean;
    drawing:PTZCADDrawing;
    EntChange:boolean;
const
    CommandName='MatchProp';
function isTextEnt(ObjType:TObjID):boolean;
begin
     if (ObjType=GDBtextID)
     or(ObjType=GDBMTextID)then
                               result:=true
                           else
                               result:=false;
end;

begin
    UndoStartMarkerPlaced:=false;
    if commandmanager.getentity(rscmSelectSourceEntity,ps) then
    begin
         zcShowCommandParams(SysUnit^.TypeName2PTD('TMatchPropParam'),@MatchPropParam);
         drawing:=PTZCADDrawing(drawings.GetCurrentDWG);
         dc:=drawing^.CreateDrawingRC;
         SourceObjType:=ps^.GetObjType;
         isSourceObjText:=isTextEnt(SourceObjType);
         while commandmanager.getentity(rscmSelectDestinationEntity,pd) do
         begin
              EntChange:=false;
              if MatchPropParam.ProcessLayer then
                if pd^.vp.Layer<>ps^.vp.Layer then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with TGDBPoinerChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,pd^.vp.Layer,nil,nil) do
                    begin
                         pd^.vp.Layer:=ps^.vp.Layer;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineType then
                if pd^.vp.LineType<>ps^.vp.LineType then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with TGDBPoinerChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,pd^.vp.LineType,nil,nil) do
                    begin
                         pd^.vp.LineType:=ps^.vp.LineType;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineWeight then
                if pd^.vp.LineWeight<>ps^.vp.LineWeight then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with TGDBTGDBLineWeightChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,pd^.vp.LineWeight,nil,nil) do
                    begin
                         pd^.vp.LineWeight:=ps^.vp.LineWeight;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessColor then
                if pd^.vp.color<>ps^.vp.Color then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with TGDBTGDBPaletteColorChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,pd^.vp.color,nil,nil) do
                    begin
                         pd^.vp.color:=ps^.vp.Color;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineTypeScale then
                if pd^.vp.LineTypeScale<>ps^.vp.LineTypeScale then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with TDoubleChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,pd^.vp.LineTypeScale,nil,nil) do
                    begin
                         pd^.vp.LineTypeScale:=ps^.vp.LineTypeScale;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if (isSourceObjText)and(isTextEnt(pd^.GetObjType))then
              begin
                if MatchPropParam.TextParams.ProcessTextStyle then
                  if PGDBObjText(pd)^.TXTStyleIndex<>PGDBObjText(ps)^.TXTStyleIndex then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with TGDBPoinerChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,PGDBObjText(pd)^.TXTStyleIndex,nil,nil) do
                      begin
                           PGDBObjText(pd)^.TXTStyleIndex:=PGDBObjText(ps)^.TXTStyleIndex;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextSize then
                  if PGDBObjText(pd)^.textprop.size<>PGDBObjText(ps)^.textprop.size then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with TDoubleChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,PGDBObjText(pd)^.textprop.size,nil,nil) do
                      begin
                           PGDBObjText(pd)^.textprop.size:=PGDBObjText(ps)^.textprop.size;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextOblique then
                  if PGDBObjText(pd)^.textprop.Oblique<>PGDBObjText(ps)^.textprop.Oblique then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with TDoubleChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,PGDBObjText(pd)^.textprop.Oblique,nil,nil) do
                      begin
                           PGDBObjText(pd)^.textprop.Oblique:=PGDBObjText(ps)^.textprop.Oblique;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextWFactor then
                  if PGDBObjText(pd)^.textprop.wfactor<>PGDBObjText(ps)^.textprop.wfactor then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with TDoubleChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,PGDBObjText(pd)^.textprop.wfactor,nil,nil) do
                      begin
                           PGDBObjText(pd)^.textprop.wfactor:=PGDBObjText(ps)^.textprop.wfactor;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextJustify then
                  if PGDBObjText(pd)^.textprop.justify<>PGDBObjText(ps)^.textprop.justify then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with TGDBTTextJustifyChangeCommand.CreateAndPushIfNeed(drawing.UndoStack,PGDBObjText(pd)^.textprop.justify,nil,nil) do
                      begin
                           PGDBObjText(pd)^.textprop.justify:=PGDBObjText(ps)^.textprop.justify;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
              end;
              if EntChange then
                begin
                  pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
                  zcRedrawCurrentDrawing;
                end;
         end;
         zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
         zcHideCommandParams;
    end;
    result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  MatchPropParam.ProcessLayer:=true;
  MatchPropParam.ProcessLineType:=true;
  MatchPropParam.ProcessLineWeight:=true;
  MatchPropParam.ProcessColor:=true;
  MatchPropParam.ProcessLineTypeScale:=true;
  MatchPropParam.TextParams.ProcessTextStyle:=true;
  MatchPropParam.TextParams.ProcessTextSize:=true;
  MatchPropParam.TextParams.ProcessTextOblique:=true;
  MatchPropParam.TextParams.ProcessTextWFactor:=true;
  MatchPropParam.TextParams.ProcessTextJustify:=true;

  SysUnit.RegisterType(TypeInfo(TMatchPropParam));//регистрируем тип данных в зкадном RTTI
  SysUnit.SetTypeDesk(TypeInfo(TMatchPropParam),['Process layer','Process line weight','Process line type','Process line type scale','Process color','Text params'],[FNProgram]);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел
  SysUnit.SetTypeDesk(TypeInfo(TMatchPropTextParam),['Process style','Process size','Process oblique','Process wfactor','Process justify'],[FNUser]);//Даем человечьи имена параметрам

  CreateZCADCommand(@matchprop_com,'MatchProp',  CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
