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
unit uzccommand_MatchProp;

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
  uzeentity,uzeenttext,uzgldrawcontext,uzcdrawing,uzeconsts,
  //gzUndoCmdChgData,zUndoCmdChgBaseTypes,
  URecordDescriptor,typedescriptors,Varman,
  uzeentabstracttext,uzepalette,
  zUndoCmdChgTypes,gzUndoCmdChgData2,zUndoCmdChgExtTypes;

implementation

type
  TChangedTextJustify=GChangedData<TTextJustify,TSharedPEntityData,TAfterChangePDrawing>;
  TUndoTextJustifyChangeCommand=GUCmdChgData2<TChangedTextJustify,
    TSharedPEntityData,TAfterChangePDrawing>;

  TChangedPaletteColor=GChangedData<TGDBPaletteColor,TSharedPEntityData,
    TAfterChangePDrawing>;
  TUndoPaletteColorChangeCommand=GUCmdChgData2<TChangedPaletteColor,
    TSharedPEntityData,TAfterChangePDrawing>;

  TChangedLineWeight=GChangedData<TGDBLineWeight,TSharedPEntityData,
    TAfterChangePDrawing>;
  TUndoLineWeightChangeCommand=GUCmdChgData2<TChangedLineWeight,
    TSharedPEntityData,TAfterChangePDrawing>;

  //** Тип данных для отображения в инспекторе опций команды MatchProp о текстовых примитивах, составная часть TMatchPropParam
  TMatchPropTextParam=record
    ProcessTextStyle:boolean;(*'Process style'*)
    ProcessTextSize:boolean;(*'Process size'*)
    ProcessTextOblique:boolean;(*'Process oblique'*)
    ProcessTextWFactor:boolean;(*'Process wfactor'*)
    ProcessTextJustify:boolean;(*'Process justify'*)
  end;
  //** Тип данных для отображения в инспекторе опций команды MatchProp
  TMatchPropParam=record
    ProcessLayer:boolean;(*'Process layer'*)
    ProcessLineWeight:boolean;(*'Process line weight'*)
    ProcessLineType:boolean;(*'Process line type'*)
    ProcessLineTypeScale:boolean;(*'Process line type scale'*)
    ProcessColor:boolean;(*'Process color'*)
    TextParams:TMatchPropTextParam;(*'Text params'*)
  end;

var
  MatchPropParam:TMatchPropParam;
  //**< Переменная содержащая опции команды MatchProp

function matchprop_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  ps,pd:PGDBObjEntity;
  SourceObjType:TObjID;
  isSourceObjText:boolean;
  dc:TDrawContext;
  UndoStartMarkerPlaced:boolean;
  drawing:PTZCADDrawing;
  EntChange:boolean;
  USharedEntity:TSharedPEntityData;
  USharedDrawing:TAfterChangePDrawing;
const
  CommandName='MatchProp';

  function isTextEnt(ObjType:TObjID):boolean;
  begin
    if (ObjType=GDBtextID)  or(ObjType=GDBMTextID) then
      Result:=True
    else
      Result:=False;
  end;

begin
  USharedDrawing.CreateRec(drawings.GetCurrentDWG);
  UndoStartMarkerPlaced:=False;
  if commandmanager.getentity(rscmSelectSourceEntity,ps)=IRNormal then begin
    zcShowCommandParams(SysUnit^.TypeName2PTD('TMatchPropParam'),@MatchPropParam);
    drawing:=PTZCADDrawing(drawings.GetCurrentDWG);
    dc:=drawing^.CreateDrawingRC;
    SourceObjType:=ps^.GetObjType;
    isSourceObjText:=isTextEnt(SourceObjType);
    while commandmanager.getentity(rscmSelectDestinationEntity,pd)=IRNormal do begin
      USharedEntity.CreateRec(pd);
      EntChange:=False;
      if MatchPropParam.ProcessLayer then
        if pd^.vp.Layer<>ps^.vp.Layer then begin
          zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
          with TPoinerInEntChangeCommand.CreateAndPushIfNeed(
              drawing.UndoStack,
              TChangedPointerInEnt.CreateRec(pd^.vp.Layer),
              USharedEntity,
              USharedDrawing) do begin
            pd^.vp.Layer:=ps^.vp.Layer;
            //ComitFromObj;
          end;
          EntChange:=True;
        end;
      if MatchPropParam.ProcessLineType then
        if pd^.vp.LineType<>ps^.vp.LineType then begin
          zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
          with TPoinerInEntChangeCommand.CreateAndPushIfNeed(
              drawing.UndoStack,
              TChangedPointerInEnt.CreateRec(pd^.vp.LineType),
              USharedEntity,
              USharedDrawing) do begin
            pd^.vp.LineType:=ps^.vp.LineType;
            //ComitFromObj;
          end;
          EntChange:=True;
        end;
      if MatchPropParam.ProcessLineWeight then
        if pd^.vp.LineWeight<>ps^.vp.LineWeight then begin
          zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
          with TUndoLineWeightChangeCommand.CreateAndPushIfNeed(
              drawing.UndoStack,
              TChangedLineWeight.CreateRec(pd^.vp.LineWeight),
              USharedEntity,
              USharedDrawing) do begin
            pd^.vp.LineWeight:=ps^.vp.LineWeight;
            //ComitFromObj;
          end;
          EntChange:=True;
        end;
      if MatchPropParam.ProcessColor then
        if pd^.vp.color<>ps^.vp.Color then begin
          zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
          with TUndoPaletteColorChangeCommand.CreateAndPushIfNeed(
              drawing.UndoStack,
              TChangedPaletteColor.CreateRec(pd^.vp.color),
              USharedEntity,
              USharedDrawing) do begin
            pd^.vp.color:=ps^.vp.Color;
            //ComitFromObj;
          end;
          EntChange:=True;
        end;
      if MatchPropParam.ProcessLineTypeScale then
        if pd^.vp.LineTypeScale<>ps^.vp.LineTypeScale then begin
          zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
          with TDoubleInEntChangeCommand.CreateAndPushIfNeed(
              drawing.UndoStack,
              TChangedDoubleInEnt.CreateRec(pd^.vp.LineTypeScale),
              USharedEntity,
              USharedDrawing) do begin
            pd^.vp.LineTypeScale:=ps^.vp.LineTypeScale;
            //ComitFromObj;
          end;
          EntChange:=True;
        end;
      if (isSourceObjText)and(isTextEnt(pd^.GetObjType)) then begin
        if MatchPropParam.TextParams.ProcessTextStyle then
          if PGDBObjText(pd)^.TXTStyle<>PGDBObjText(ps)^.TXTStyle then begin
            zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
            with TPoinerInEntChangeCommand.CreateAndPushIfNeed(
                drawing.UndoStack,
                TChangedPointerInEnt.CreateRec(PGDBObjText(pd)^.TXTStyle),
                USharedEntity,
                USharedDrawing) do begin
              PGDBObjText(pd)^.TXTStyle:=PGDBObjText(ps)^.TXTStyle;
              //ComitFromObj;
            end;
            EntChange:=True;
          end;
        if MatchPropParam.TextParams.ProcessTextSize then
          if PGDBObjText(pd)^.textprop.size<>PGDBObjText(ps)^.textprop.size then
          begin
            zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
            with TDoubleInEntChangeCommand.CreateAndPushIfNeed(
                drawing.UndoStack,
                TChangedDoubleInEnt.CreateRec(PGDBObjText(pd)^.textprop.size),
                USharedEntity,
                USharedDrawing) do begin
              PGDBObjText(pd)^.textprop.size:=
                PGDBObjText(ps)^.textprop.size;
              //ComitFromObj;
            end;
            EntChange:=True;
          end;
        if MatchPropParam.TextParams.ProcessTextOblique then
          if PGDBObjText(pd)^.textprop.Oblique<>PGDBObjText(
            ps)^.textprop.Oblique then begin
            zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
            with TDoubleInEntChangeCommand.CreateAndPushIfNeed(
                drawing.UndoStack,
                TChangedDoubleInEnt.CreateRec(PGDBObjText(pd)^.textprop.Oblique),
                USharedEntity,
                USharedDrawing) do begin
              PGDBObjText(pd)^.textprop.Oblique:=
                PGDBObjText(ps)^.textprop.Oblique;
              //ComitFromObj;
            end;
            EntChange:=True;
          end;
        if MatchPropParam.TextParams.ProcessTextWFactor then
          if PGDBObjText(pd)^.textprop.wfactor<>PGDBObjText(
            ps)^.textprop.wfactor then begin
            zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
            with TDoubleInEntChangeCommand.CreateAndPushIfNeed(
                drawing.UndoStack,
                TChangedDoubleInEnt.CreateRec(PGDBObjText(pd)^.textprop.wfactor),
                USharedEntity,
                USharedDrawing) do begin
              PGDBObjText(pd)^.textprop.wfactor:=
                PGDBObjText(ps)^.textprop.wfactor;
              //ComitFromObj;
            end;
            EntChange:=True;
          end;
        if MatchPropParam.TextParams.ProcessTextJustify then
          if PGDBObjText(pd)^.textprop.justify<>PGDBObjText(
            ps)^.textprop.justify then begin
            zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
            with TUndoTextJustifyChangeCommand.CreateAndPushIfNeed(
                drawing.UndoStack,
                TChangedTextJustify.CreateRec(PGDBObjText(pd)^.textprop.justify),
                USharedEntity,
                USharedDrawing) do begin
              PGDBObjText(pd)^.textprop.justify:=
                PGDBObjText(ps)^.textprop.justify;
              //ComitFromObj;
            end;
            EntChange:=True;
          end;
      end;
      if EntChange then begin
        pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
        zcRedrawCurrentDrawing;
      end;
    end;
    zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
    zcHideCommandParams;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  MatchPropParam.ProcessLayer:=True;
  MatchPropParam.ProcessLineType:=True;
  MatchPropParam.ProcessLineWeight:=True;
  MatchPropParam.ProcessColor:=True;
  MatchPropParam.ProcessLineTypeScale:=True;
  MatchPropParam.TextParams.ProcessTextStyle:=True;
  MatchPropParam.TextParams.ProcessTextSize:=True;
  MatchPropParam.TextParams.ProcessTextOblique:=True;
  MatchPropParam.TextParams.ProcessTextWFactor:=True;
  MatchPropParam.TextParams.ProcessTextJustify:=True;
  if SysUnit<>nil then begin
    SysUnit.RegisterType(TypeInfo(TMatchPropParam));
    //регистрируем тип данных в зкадном RTTI
    SysUnit.SetTypeDesk(TypeInfo(TMatchPropParam),['Process layer',
      'Process line weight','Process line type','Process line type scale',
      'Process color','Text params'],[FNProgram]);
    //Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел
    SysUnit.SetTypeDesk(TypeInfo(TMatchPropTextParam),
      ['Process style','Process size','Process oblique','Process wfactor','Process justify'],
      [FNUser]);//Даем человечьи имена параметрам
  end;

  CreateZCADCommand(@matchprop_com,'MatchProp',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
