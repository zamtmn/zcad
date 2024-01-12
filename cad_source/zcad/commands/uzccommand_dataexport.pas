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
{$IFDEF FPC}
  {$CODEPAGE UTF8}
  {$MODE DELPHI}
{$ENDIF}
unit uzccommand_dataexport;
{$INCLUDE zengineconfig.inc}

interface
uses
  CsvDocument,
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,
  URecordDescriptor,typedescriptors,Varman,gzctnrVectorTypes,
  uzeparserenttypefilter,uzeparserentpropfilter,uzeentitiestypefilter,
  uzelongprocesssupport,uzeparser,uzcoimultiproperties,uzedimensionaltypes,
  uzcoimultipropertiesutil,varmandef,uzcvariablesutils,Masks,uzcregother,
  uzeparsercmdprompt,uzcinterface,uzcdialogsfiles;

resourcestring
  RSCLPDataExportWaitFile                ='Configure export ${"&[p]arams",Keys[p],StrId[CLPIdOptions]}, run ${"&[f]ile dialog",Keys[f],StrId[CLPIdFileDialog]} or enter file name (empty for default):';
  RSCLPDataExportOptions                 ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Set ${"&[e]ntities",Keys[o],StrId[CLPIdUser1]}/${"&[p]roperties",Keys[o],StrId[CLPIdUser2]} filter or export ${"&[s]cript",Keys[o],StrId[CLPIdUser3]}';
  RSCLPDataExportEntsFilterCurrentValue  ='Entities filter current value:';
  RSCLPDataExportEntsFilterNewValue      ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new entities filter:';
  RSCLPDataExportPropsFilterCurrentValue ='Properties filter current value:';
  RSCLPDataExportPropsFilterNewValue     ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new properties filter:';
  RSCLPDataExportExportScriptCurrentValue='Properties export script current value:';
  RSCLPDataExportExportScriptNewValue    ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new export script:';

type
  //** Тип данных для отображения в инспекторе опций
  TDataExportParam=record
    EntFilter:PString;
    PropFilter:PString;
    Exporter:PString;
    FileName:PString;
  end;

var
  DataExportParam:TDataExportParam; //**< Переменная содержащая опции команды ExportTextToCSVParam

implementation

type
  TDataExport=record
    FDoc:TCSVDocument;
    f:TzeUnitsFormat;
    CurrentEntity:pGDBObjEntity;
  end;

  //TParserExporterString=AnsiString;
  //TParserExporterChar=AnsiChar;
  //TExporterParser=TGZParser<TRawByteStringManipulator,TParserExporterString,TParserExporterChar,TRawByteStringManipulator.TCharIndex,TRawByteStringManipulator.TCharLength,TRawByteStringManipulator.TCharRange,TDataExport,TCharToOptChar<TParserExporterChar>>;
  TExporterParser=TGZParser<TRawByteStringManipulator,
                                    TRawByteStringManipulator.TStringType,
                                    TRawByteStringManipulator.TCharType,
                                    TCodeUnitPosition,
                                    TRawByteStringManipulator.TCharPosition,
                                    TRawByteStringManipulator.TCharLength,
                                    TRawByteStringManipulator.TCharInterval,
                                    TRawByteStringManipulator.TCharRange,
                                    TDataExport,
                                    TCharToOptChar<TRawByteStringManipulator.TCharType>>;

  TExport=class(TExporterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                               InsideBracketParser:TObject;
                               var Data:TDataExport);override;
  end;
  TGetEntParam=class(TExporterParser.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TRawByteStringManipulator.TStringType;
    constructor vcreate(const Source:TRawByteStringManipulator.TStringType;
                            const Token :TRawByteStringManipulator.TCharRange;
                            const Operands :TRawByteStringManipulator.TCharRange;
                            const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                            InsideBracketParser:TObject;
                            var Data:TDataExport);override;
    destructor Destroy;override;
    procedure GetResult(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                        InsideBracketParser:TObject;
                        var Result:TRawByteStringManipulator.TStringType;
                        var ResultParam:TRawByteStringManipulator.TCharRange;
                        var data:TDataExport);override;
  end;
  TGetEntVariable=class(TExporterParser.TParserTokenizer.TDynamicProcessor)
    tempresult:TRawByteStringManipulator.TStringType;
    variablename:string;
    constructor vcreate(const Source:TRawByteStringManipulator.TStringType;
                            const Token :TRawByteStringManipulator.TCharRange;
                            const Operands :TRawByteStringManipulator.TCharRange;
                            const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                            InsideBracketParser:TObject;
                            var Data:TDataExport);override;
    destructor Destroy;override;
    procedure GetResult(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                        InsideBracketParser:TObject;
                        var Result:TRawByteStringManipulator.TStringType;
                        var ResultParam:TRawByteStringManipulator.TCharRange;
                        var data:TDataExport);override;
  end;
  TSameMask=class(TExporterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TRawByteStringManipulator.TStringType;
                                    const Token :TRawByteStringManipulator.TCharRange;
                                    const Operands :TRawByteStringManipulator.TCharRange;
                                    const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                                    InsideBracketParser:TObject;
                                    var Result:TRawByteStringManipulator.TStringType;
                                    var ResultParam:TRawByteStringManipulator.TCharRange;
                                    //var NextSymbolPos:integer;
                                    var data:TDataExport);override;
  end;

  TDoIf=class(TExporterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                               InsideBracketParser:TObject;
                               var Data:TDataExport);override;
  end;



var
  BracketTockenId:TParserEntityPropFilter.TParserTokenizer.TTokenId;
  ExporterParser:TExporterParser;
  VU:TEntityUnit;
  clFilePrompt:CMDLinePromptParser.TGeneralParsedText=nil;
  clOptionsPrompt:CMDLinePromptParser.TGeneralParsedText=nil;
  clOptionsPrompt1:CMDLinePromptParser.TGeneralParsedText=nil;
  clOptionsPrompt2:CMDLinePromptParser.TGeneralParsedText=nil;
  clOptionsPrompt3:CMDLinePromptParser.TGeneralParsedText=nil;

class procedure TDoIf.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                             const Token :TRawByteStringManipulator.TCharRange;
                             const Operands :TRawByteStringManipulator.TCharRange;
                             const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                             InsideBracketParser:TObject;
                             var Data:TDataExport);
var
  op1:TRawByteStringManipulator.TStringType;
  opResultParam:TRawByteStringManipulator.TCharRange;
begin
  if (ParsedOperands<>nil)
      and(ParsedOperands is TExporterParser.TParsedText)
      and((ParsedOperands as TExporterParser.TParsedText).Parts.size=3)then begin
        op1:='';
        opResultParam.P.CodeUnitPos:=OnlyGetLength;
        opResultParam.L.CodeUnits:=0;
        TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
        SetLength(op1,opResultParam.L.CodeUnits);
        opResultParam.P.CodeUnitPos:=InitialStartPos;
        TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
         //op1:=(ParsedOperands as TExporterParser.TParsedText).Parts[0].GetResult(data);
         if op1='+' then
           TExporterParser.TGeneralParsedText.DoItWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[2]^,data);
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;


class procedure TSameMask.StaticGetResult(const Source:TRawByteStringManipulator.TStringType;
                                          const Token :TRawByteStringManipulator.TCharRange;
                                          const Operands :TRawByteStringManipulator.TCharRange;
                                          const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                                          InsideBracketParser:TObject;
                                          var Result:TRawByteStringManipulator.TStringType;
                                          var ResultParam:TRawByteStringManipulator.TCharRange;
                                          //var NextSymbolPos:integer;
                                          var data:TDataExport);
var
  op1,op2:TRawByteStringManipulator.TStringType;
  opResultParam:TRawByteStringManipulator.TCharRange;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TExporterParser.TParsedText)
     and((ParsedOperands as TExporterParser.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
         op1:=inttostr((ParsedOperands as TExporterParser.TParsedText).Parts.size);
         op2:='';
         opResultParam.P.CodeUnitPos:=OnlyGetLength;
         opResultParam.L.CodeUnits:=0;
         TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
         SetLength(op1,opResultParam.L.CodeUnits);
         opResultParam.P.CodeUnitPos:=InitialStartPos;
         TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);

         opResultParam.P.CodeUnitPos:=OnlyGetLength;
         opResultParam.L.CodeUnits:=0;
         TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         SetLength(op2,opResultParam.L.CodeUnits);
         opResultParam.P.CodeUnitPos:=InitialStartPos;
         TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         ResultParam.L.CodeUnits:=1;
         if ResultParam.P.CodeUnitPos<>OnlyGetLength then begin
           if MatchesMask(op1,op2,false)
               or (AnsiCompareText(op1,op2)=0) then
             Result[ResultParam.P.CodeUnitPos]:='+'
           else
             Result[ResultParam.P.CodeUnitPos]:='-'
         end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;


class procedure TExport.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                               InsideBracketParser:TObject;
                               var Data:TDataExport);
var
  op1{,op2}:TRawByteStringManipulator.TStringType;
  ResultParam:TRawByteStringManipulator.TCharRange;
  i,r,c:integer;
begin
  r:=-1;
  c:=1;
  if (ParsedOperands<>nil)and(not(ParsedOperands is TExporterParser.TParsedTextWithoutTokens)) then begin
    if ParsedOperands is TExporterParser.TParsedTextWithOneToken then begin
      op1:='';
      ResultParam.P.CodeUnitPos:=OnlyGetLength;
      ResultParam.L.CodeUnits:=0;
      TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedTextwithOnetoken).Part,data,op1,ResultParam);
      SetLength(op1,ResultParam.L.CodeUnits);
      ResultParam.P.CodeUnitPos:=InitialStartPos;
      TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedTextwithOnetoken).Part,data,op1,ResultParam);
      Data.FDoc.AddRow(op1);
      r:=Data.FDoc.RowCount;
    end else
      for i:=0 to (ParsedOperands as TExporterParser.TParsedText).Parts.size-1 do
        if not(TTokenOptions.IsAllPresent((ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[i]^.tokeninfo.Options,TGOSeparator))then
        begin
          ResultParam.P.CodeUnitPos:=OnlyGetLength;
          ResultParam.L.CodeUnits:=0;
          TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[i]^,data,op1,ResultParam);
          SetLength(op1,ResultParam.L.CodeUnits);
          ResultParam.P.CodeUnitPos:=InitialStartPos;
          TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[i]^,data,op1,ResultParam);
          if r=-1 then begin
            Data.FDoc.AddRow(op1);
            r:=Data.FDoc.RowCount-1;
          end else begin
            Data.FDoc.Cells[c,r]:=op1;
            inc(c);
          end;
        end;
    end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

procedure TGetEntParam.GetResult(const Source:TRawByteStringManipulator.TStringType;
                    const Token :TRawByteStringManipulator.TCharRange;
                    const Operands :TRawByteStringManipulator.TCharRange;
                    const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                    InsideBracketParser:TObject;
                    var Result:TRawByteStringManipulator.TStringType;
                    var ResultParam:TRawByteStringManipulator.TCharRange;
                    var data:TDataExport);
var
  i:integer;
  mpd:TMultiPropertyDataForObjects;
  //f:TzeUnitsFormat;
  ChangedData:TChangedData;
begin
  if ResultParam.P.CodeUnitPos=OnlyGetLength then begin
    if mp<>nil then begin
      if mp.MPObjectsData.MyGetValue(TObjIDWithExtender.Create(0,nil),mpd) then begin
        ChangedData:=CreateChangedData(data.CurrentEntity,mpd.GSData);
        if @mpd.EntBeforeIterateProc<>nil then
          mpd.EntBeforeIterateProc({bip}mp.PIiterateData,ChangedData);
        mpd.EntIterateProc({bip}mp.PIiterateData,ChangedData,mp,true,mpd.EntChangeProc,data.f);
        tempresult:=mp.MPType.GetDecoratedValueAsString(PVarDesk(PTOneVarData(mp.PIiterateData)^.VDAddr.Instance).data.Addr.Instance,data.f);
      end else if mp.MPObjectsData.MyGetValue(TObjIDWithExtender.Create(PGDBObjEntity(data.CurrentEntity)^.GetObjType,nil),mpd) then begin
        ChangedData:=CreateChangedData(data.CurrentEntity,mpd.GSData);
        if @mpd.EntBeforeIterateProc<>nil then
          mpd.EntBeforeIterateProc({bip}mp.PIiterateData,ChangedData);
        mpd.EntIterateProc({bip}mp.PIiterateData,ChangedData,mp,true,mpd.EntChangeProc,data.f);
        tempresult:=mp.MPType.GetDecoratedValueAsString(PVarDesk(PTOneVarData(mp.PIiterateData)^.VDAddr.Instance).data.Addr.Instance,data.f);
      end else
        tempresult:='';
    end else
      tempresult:='';
  end;
  ResultParam.L.CodeUnits:=Length(tempresult);
  if ResultParam.P.CodeUnitPos<>OnlyGetLength then
    for i:=0 to Length(tempresult)-1 do
      Result[ResultParam.P.CodeUnitPos+i]:=tempresult[i+1];
end;

constructor TGetEntParam.vcreate(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                        InsideBracketParser:TObject;
                        var Data:TDataExport);
var
  propertyname:string;
begin
  propertyname:=ParsedOperands.GetResult(Data);
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then begin
    {bip}mp.PIiterateData:=mp.MIPD.BeforeIterateProc(mp,@VU);
    { #todo : нужно делать копию mp, но пока пусть так }
  end else
    mp:=nil;
end;

destructor TGetEntParam.Destroy;
begin
  if mp<>nil then begin
    if @mp.MIPD.AfterIterateProc<>nil then
      mp.MIPD.AfterIterateProc({bip}mp.PIiterateData,mp);
    //mp.Free;{ #todo : нужно делать копию mp, но пока пусть так }
  end;
  inherited;
end;

procedure TGetEntVariable.GetResult(const Source:TRawByteStringManipulator.TStringType;
                    const Token :TRawByteStringManipulator.TCharRange;
                    const Operands :TRawByteStringManipulator.TCharRange;
                    const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                    InsideBracketParser:TObject;
                    var Result:TRawByteStringManipulator.TStringType;
                    var ResultParam:TRawByteStringManipulator.TCharRange;
                    var data:TDataExport);
var
  pv:pvardesk;
  i:integer;
begin
  pv:=nil;
  if data.CurrentEntity<>nil then
    pv:=FindVariableInEnt(data.CurrentEntity,variablename);
  if pv<>nil then
    tempresult:=pv^.data.ptd^.GetValueAsString(pv^.data.Addr.Instance)
  else
    tempresult:='!!ERR('+variablename+')!!';
  ResultParam.L.CodeUnits:=Length(tempresult);
  if ResultParam.P.CodeUnitPos<>OnlyGetLength then
    for i:=0 to Length(tempresult)-1 do
      Result[ResultParam.P.CodeUnitPos+i]:=tempresult[i+1];
end;

constructor TGetEntVariable.vcreate(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TDataExport>;
                        InsideBracketParser:TObject;
                        var Data:TDataExport);
begin
  variablename:=ParsedOperands.GetResult(Data);
end;

destructor TGetEntVariable.Destroy;
begin
  variablename:='';
  inherited;
end;


function DataExport_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
type
  TCmdMode=(CMEmpty,CMWaitFile,CMOptions,CMOptions1,CMOptions2,CMOptions3,CMExport);
var
  EntsTypeFilter:TEntsTypeFilter;
  EntityIncluder:ParserEntityPropFilter.TGeneralParsedText;
  pt:TParserEntityTypeFilter.TGeneralParsedText;

  pet:TExporterParser.TGeneralParsedText;

  pv:pGDBObjEntity;
  propdata:TPropFilterData;
  ir:itrec;
  lpsh:TLPSHandle;
  Data:TDataExport;
  inpt:String;
  gr:TGetResult;
  CmdMode:TCmdMode;
  filename:string;
  procedure SetCmdMode(Mode:TCmdMode);
  begin
    if CmdMode=Mode then
      exit;
    case Mode of
      CMWaitFile:begin
                   if clFilePrompt=nil then
                     clFilePrompt:=CMDLinePromptParser.GetTokens(RSCLPDataExportWaitFile);
                   commandmanager.SetPrompt(clFilePrompt);               //выставляет результат парсинга в командную строчку
                   commandmanager.ChangeInputMode([IPEmpty],[]);
                 end;
       CMOptions:begin
                   if clOptionsPrompt=nil then
                     clOptionsPrompt:=CMDLinePromptParser.GetTokens(RSCLPDataExportOptions);
                   commandmanager.SetPrompt(clOptionsPrompt);
                   commandmanager.ChangeInputMode([IPEmpty],[]);
                 end;
      CMOptions1:begin
                   ZCMsgCallBackInterface.TextMessage(RSCLPDataExportEntsFilterCurrentValue,TMWOHistoryOut);
                   ZCMsgCallBackInterface.TextMessage(DataExportParam.EntFilter^,TMWOHistoryOut);
                   if clOptionsPrompt1=nil then
                     clOptionsPrompt1:=CMDLinePromptParser.GetTokens(RSCLPDataExportEntsFilterNewValue);
                   commandmanager.SetPrompt(clOptionsPrompt1);
                   commandmanager.ChangeInputMode([IPEmpty],[]);
                 end;
      CMOptions2:begin
                   ZCMsgCallBackInterface.TextMessage(RSCLPDataExportPropsFilterCurrentValue,TMWOHistoryOut);
                   ZCMsgCallBackInterface.TextMessage(DataExportParam.PropFilter^,TMWOHistoryOut);
                   if clOptionsPrompt2=nil then
                     clOptionsPrompt2:=CMDLinePromptParser.GetTokens(RSCLPDataExportPropsFilterNewValue);
                   commandmanager.SetPrompt(clOptionsPrompt2);
                   commandmanager.ChangeInputMode([IPEmpty],[]);
                 end;
      CMOptions3:begin
                   ZCMsgCallBackInterface.TextMessage(RSCLPDataExportExportScriptCurrentValue,TMWOHistoryOut);
                   ZCMsgCallBackInterface.TextMessage(DataExportParam.Exporter^,TMWOHistoryOut);
                   if clOptionsPrompt3=nil then
                     clOptionsPrompt3:=CMDLinePromptParser.GetTokens(RSCLPDataExportExportScriptNewValue);
                   commandmanager.SetPrompt(clOptionsPrompt3);
                   commandmanager.ChangeInputMode([IPEmpty],[]);
                 end;
    end;
    CmdMode:=Mode;
  end;

begin
  zcShowCommandParams(SysUnit^.TypeName2PTD('TDataExportParam'),@DataExportParam);
  CmdMode:=CMEmpty;
  SetCmdMode(CMWaitFile);
  repeat
    gr:=commandmanager.GetInput('',inpt);
       case gr of
             GRId:case commandmanager.GetLastId of
                                      CLPIdOptions:SetCmdMode(CMOptions);
                                         CLPIdBack:if CmdMode=CMOptions then
                                                     SetCmdMode(CMWaitFile)
                                                   else
                                                     SetCmdMode(CMOptions);
                                        CLPIdUser1:SetCmdMode(CMOptions1);
                                        CLPIdUser2:SetCmdMode(CMOptions2);
                                        CLPIdUser3:SetCmdMode(CMOptions3);
                                   CLPIdFileDialog:begin
                                                     filename:='';
                                                     if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Export data...') then begin
                                                       DataExportParam.FileName^:=filename;
                                                       CmdMode:=CMExport;
                                                       system.break;
                                                     end;

                                                   end;
                  end;
         GRNormal:case CmdMode of
                       CMWaitFile:begin
                                    if inpt<>'' then
                                      DataExportParam.FileName^:=inpt;
                                    CmdMode:=CMExport;
                                    system.break;
                                  end;
                       CMOptions1:begin
                                    if inpt<>'' then
                                      DataExportParam.EntFilter^:=inpt;
                                    SetCmdMode(CMOptions);
                                  end;
                       CMOptions2:begin
                                    if inpt<>'' then
                                      DataExportParam.PropFilter^:=inpt;
                                    SetCmdMode(CMOptions);
                                  end;
                       CMOptions3:begin
                                    if inpt<>'' then
                                      DataExportParam.Exporter^:=inpt;
                                    SetCmdMode(CMOptions);
                                  end;
                  end;
       end;
  until gr=GRCancel;

  if CmdMode=CMExport then begin
    EntsTypeFilter:=TEntsTypeFilter.Create;
    pt:=ParserEntityTypeFilter.GetTokens(DataExportParam.EntFilter^);
    pt.Doit(EntsTypeFilter);
    EntsTypeFilter.SetFilter;
    pt.Free;

    pet:=ExporterParser.GetTokens(DataExportParam.Exporter^);

    EntityIncluder:=ParserEntityPropFilter.GetTokens(DataExportParam.PropFilter^);
    lpsh:=LPSHEmpty;

     Data.f:=drawings.GetUnitsFormat;
     propdata.f:=Data.f;
     Data.FDoc:=TCSVDocument.Create;
       if drawings.GetCurrentDWG<>nil then
       begin
         lpsh:=LPS.StartLongProcess('DataExport',@DataExport_com,drawings.GetCurrentROOT^.ObjArray.Count);
         pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
         if pv<>nil then
         repeat
           if EntsTypeFilter.IsEntytyTypeAccepted(pv^.GetObjType) then begin
             if assigned(EntityIncluder) then begin
               propdata.CurrentEntity:=pv;
               propdata.IncludeEntity:=T3SB_Default;
               EntityIncluder.Doit(PropData);
             end else
               propdata.IncludeEntity:=T3SB_True;

             if propdata.IncludeEntity=T3SB_True then begin
               Data.CurrentEntity:=pv;
               if assigned(pet) then
                 pet.Doit(data);
             end;
           end;

           pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
           LPS.ProgressLongProcess(lpsh,ir.itc);
         until pv=nil;
       end;
    if lpsh<>LPSHEmpty then
      LPS.EndLongProcess(lpsh);
    Data.FDoc.Delimiter:=';';
    Data.FDoc.SaveToFile(DataExportParam.FileName^);
    Data.FDoc.Free;
    EntsTypeFilter.Free;
    EntityIncluder.Free;
  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  VU.init('test');
  VU.InterfaceUses.PushBackIfNotPresent(sysunit);

  DataExportParam.EntFilter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_EntFilter','AnsiString').data.Addr.Instance;
  if DataExportParam.EntFilter^='' then
    DataExportParam.EntFilter^:='IncludeEntityName(''Cable'');'#13#10'IncludeEntityName(''Device'')';
  DataExportParam.PropFilter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_PropFilter','AnsiString').data.Addr.Instance;
  //if DataExportParam.PropFilter^='' then
  //  DataExportParam.PropFilter:='';
  DataExportParam.Exporter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_Exporter','AnsiString').data.Addr.Instance;
  if DataExportParam.Exporter^='' then
    DataExportParam.Exporter^:='DoIf(SameMask(%%(''EntityName''),''Device''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''Position'',@@(''Position'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Device''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''Power'',@@(''Power'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Cable''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''AmountD'',@@(''AmountD'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Cable''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''CABLE_Segment'',@@(''CABLE_Segment'')))';
  DataExportParam.FileName:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_FileName','AnsiString').data.Addr.Instance;
  if DataExportParam.FileName^='' then
    DataExportParam.FileName^:='d:\test.csv';

  SysUnit^.RegisterType(TypeInfo(TDataExportParam));//регистрируем тип данных в зкадном RTTI
  SysUnit^.SetTypeDesk(TypeInfo(TDataExportParam),['EntFilter','PropFilter','Exporter','FileName'],[FNProgram]);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел

  CreateZCADCommand(@DataExport_com,'DataExport',  CADWG,0);


  ExporterParser:=TExporterParser.create;
  BracketTockenId:=ExporterParser.RegisterToken('(','(',')',nil,ExporterParser,TGONestedBracke or TGOIncludeBrackeOpen or TGOSeparator);
  ExporterParser.RegisterToken('Export',#0,#0,TExport,nil,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('DoIf',#0,#0,TDoIf,ExporterParser,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('SameMask',#0,#0,TSameMask,ExporterParser,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('%%',#0,#0,TGetEntParam,ExporterParser,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('@@',#0,#0,TGetEntVariable,ExporterParser,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('''','''','''',ExporterParser.TParserTokenizer.TStringProcessor,nil,TGOIncludeBrackeOpen);
  ExporterParser.RegisterToken(',',#0,#0,nil,nil,TGOSeparator);
  ExporterParser.RegisterToken(';',#0,#0,nil,nil,TGOSeparator);
  ExporterParser.RegisterToken('\P',#0,#0,nil,nil,TGOSeparator);
  ExporterParser.RegisterToken(' ',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ExporterParser.RegisterToken(#10,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ExporterParser.RegisterToken(#13,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ExporterParser.Free;
  VU.done;
  if clFilePrompt<>nil then
    clFilePrompt.Free;
  if clOptionsPrompt<>nil then
    clOptionsPrompt.Free;
end.
