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
{$MODE DELPHI}
unit uzccommand_dataexport;
{$INCLUDE def.inc}

interface
uses
  CsvDocument,
  LazLogger,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,
  URecordDescriptor,typedescriptors,Varman,gzctnrvectortypes,
  uzeparserenttypefilter,uzeparserentpropfilter,uzeentitiestypefilter,
  uzelongprocesssupport,uzeparser,uzcoimultiproperties,uzedimensionaltypes,
  uzcoimultipropertiesutil,varmandef,uzcvariablesutils,Masks,uzcregother,uzbtypesbase;

type
  //** Тип данных для отображения в инспекторе опций
  TDataExportParam=record
    EntFilter:PGDBString;
    PropFilter:PGDBString;
    Exporter:PGDBString;
    FileName:PGDBString;
  end;

var
  DataExportParam:TDataExportParam; //**< Переменная содержащая опции команды ExportTextToCSVParam

implementation

type
  TDataExport=record
    FDoc:TCSVDocument;
    CurrentEntity:pGDBObjEntity;
  end;

  TParserExporterString=AnsiString;
  TParserExporterChar=AnsiChar;
  TExporterParser=TParser<TParserExporterString,TParserExporterChar,TDataExport,TCharToOptChar<TParserExporterChar>>;

  TExport=class(TExporterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserExporterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserExporterString,TDataExport>;
                               var Data:TDataExport);override;
  end;
  TGetEntParam=class(TExporterParser.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TParserExporterString;
    constructor vcreate(const Source:TParserExporterString;
                            const Token :TSubStr;
                            const Operands :TSubStr;
                            const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                            var Data:TDataExport);override;
    destructor Destroy;override;
    procedure GetResult(const Source:TParserExporterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                        var Result:TParserExporterString;
                        var ResultParam:TSubStr;
                        var data:TDataExport);override;
  end;
  TGetEntVariable=class(TExporterParser.TParserTokenizer.TDynamicProcessor)
    tempresult:TParserExporterString;
    variablename:string;
    constructor vcreate(const Source:TParserExporterString;
                            const Token :TSubStr;
                            const Operands :TSubStr;
                            const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                            var Data:TDataExport);override;
    destructor Destroy;override;
    procedure GetResult(const Source:TParserExporterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                        var Result:TParserExporterString;
                        var ResultParam:TSubStr;
                        var data:TDataExport);override;
  end;
  TSameMask=class(TExporterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TParserExporterString;
                                    const Token :TSubStr;
                                    const Operands :TSubStr;
                                    const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                                    var Result:TParserExporterString;
                                    var ResultParam:TSubStr;
                                    //var NextSymbolPos:integer;
                                    var data:TDataExport);override;
  end;

  TDoIf=class(TExporterParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserExporterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserExporterString,TDataExport>;
                               var Data:TDataExport);override;
  end;



var
  BracketTockenId:TParserEntityPropFilter.TParserTokenizer.TTokenId;
  ExporterParser:TExporterParser;
  VU:TObjectUnit;

class procedure TDoIf.StaticDoit(const Source:TParserExporterString;
                             const Token :TSubStr;
                             const Operands :TSubStr;
                             const ParsedOperands :TAbstractParsedText<TParserExporterString,TDataExport>;
                             var Data:TDataExport);
var
  op1:TParserExporterString;
  opResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
      and(ParsedOperands is TExporterParser.TParsedText)
      and((ParsedOperands as TExporterParser.TParsedText).Parts.size=3)then begin

        opResultParam.StartPos:=OnlyGetLength;
        opResultParam.Length:=0;
        TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
        SetLength(op1,opResultParam.Length);
        opResultParam.StartPos:=InitialStartPos;
        TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
         //op1:=(ParsedOperands as TExporterParser.TParsedText).Parts[0].GetResult(data);
         if op1='+' then
           TExporterParser.TGeneralParsedText.DoItWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[2]^,data);
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;


class procedure TSameMask.StaticGetResult(const Source:TParserExporterString;
                                          const Token :TSubStr;
                                          const Operands :TSubStr;
                                          const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                                          var Result:TParserExporterString;
                                          var ResultParam:TSubStr;
                                          //var NextSymbolPos:integer;
                                          var data:TDataExport);
var
  op1,op2:TParserExporterString;
  opResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TExporterParser.TParsedText)
     and((ParsedOperands as TExporterParser.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
         op1:=inttostr((ParsedOperands as TExporterParser.TParsedText).Parts.size);
         opResultParam.StartPos:=OnlyGetLength;
         opResultParam.Length:=0;
         TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
         SetLength(op1,opResultParam.Length);
         opResultParam.StartPos:=InitialStartPos;
         TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);

         opResultParam.StartPos:=OnlyGetLength;
         opResultParam.Length:=0;
         TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         SetLength(op2,opResultParam.Length);
         opResultParam.StartPos:=InitialStartPos;
         TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         ResultParam.Length:=1;
         if ResultParam.StartPos<>OnlyGetLength then begin
           if MatchesMask(op1,op2,false)
               or (AnsiCompareText(op1,op2)=0) then
             Result[ResultParam.StartPos]:='+'
           else
             Result[ResultParam.StartPos]:='-'
         end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;


class procedure TExport.StaticDoit(const Source:TParserExporterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserExporterString,TDataExport>;
                               var Data:TDataExport);
var
  op1,op2:TParserEntityPropFilterString;
  ResultParam:TSubStr;
  i,r,c:integer;
begin
  r:=-1;
  c:=1;
  if (ParsedOperands<>nil)and(not(ParsedOperands is TExporterParser.TParsedTextWithoutTokens)) then begin
    if ParsedOperands is TExporterParser.TParsedTextWithOneToken then begin
      ResultParam.StartPos:=OnlyGetLength;
      ResultParam.Length:=0;
      TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedTextwithOnetoken).Part,data,op1,ResultParam);
      SetLength(op1,ResultParam.Length);
      ResultParam.StartPos:=InitialStartPos;
      TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedTextwithOnetoken).Part,data,op1,ResultParam);
      Data.FDoc.AddRow(op1);
      r:=Data.FDoc.RowCount;
    end else
      for i:=0 to (ParsedOperands as TExporterParser.TParsedText).Parts.size-1 do
        if not(TOSeparator in(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[i]^.tokeninfo.Options)then
        begin
          ResultParam.StartPos:=OnlyGetLength;
          ResultParam.Length:=0;
          TExporterParser.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TExporterParser.TParsedText).Parts.Mutable[i]^,data,op1,ResultParam);
          SetLength(op1,ResultParam.Length);
          ResultParam.StartPos:=InitialStartPos;
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
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

procedure TGetEntParam.GetResult(const Source:TParserExporterString;
                    const Token :TSubStr;
                    const Operands :TSubStr;
                    const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                    var Result:TParserExporterString;
                    var ResultParam:TSubStr;
                    var data:TDataExport);
var
  i:integer;
  mpd:TMultiPropertyDataForObjects;
  f:TzeUnitsFormat;
  ChangedData:TChangedData;
begin
  if ResultParam.StartPos=OnlyGetLength then begin
    if mp<>nil then begin
      if mp.MPObjectsData.MyGetValue(0,mpd) then begin
        ChangedData:=CreateChangedData(data.CurrentEntity,mpd.GetValueOffset,mpd.SetValueOffset);
        if @mpd.EntBeforeIterateProc<>nil then
          mpd.EntBeforeIterateProc({bip}mp.PIiterateData,ChangedData);
        mpd.EntIterateProc({bip}mp.PIiterateData,ChangedData,mp,true,mpd.EntChangeProc,f);
        tempresult:=mp.MPType.GetDecoratedValueAsString(PTOneVarData({bip}mp.PIiterateData)^.PVarDesc.data.Instance,f);
      end else if mp.MPObjectsData.MyGetValue(PGDBObjEntity(data.CurrentEntity)^.GetObjType,mpd) then begin
        ChangedData:=CreateChangedData(data.CurrentEntity,mpd.GetValueOffset,mpd.SetValueOffset);
        if @mpd.EntBeforeIterateProc<>nil then
          mpd.EntBeforeIterateProc({bip}mp.PIiterateData,ChangedData);
        mpd.EntIterateProc({bip}mp.PIiterateData,ChangedData,mp,true,mpd.EntChangeProc,f);
        tempresult:=mp.MPType.GetDecoratedValueAsString(PTOneVarData({bip}mp.PIiterateData)^.PVarDesc.data.Instance,f);
      end else
        tempresult:='';
    end else
      tempresult:='';
  end;
  ResultParam.Length:=Length(tempresult);
  if ResultParam.StartPos<>OnlyGetLength then
    for i:=0 to tempresult.Length-1 do
      Result[ResultParam.StartPos+i]:=tempresult[i+1];
end;

constructor TGetEntParam.vcreate(const Source:TParserExporterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                        var Data:TDataExport);
var
  propertyname:string;
begin
  propertyname:=ParsedOperands.GetResult(Data);
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,mp) then begin
    {bip}mp.PIiterateData:=mp.BeforeIterateProc(mp,@VU);
  end else
    mp:=nil;
end;

destructor TGetEntParam.Destroy;
begin
  if mp<>nil then begin
    if @mp.AfterIterateProc<>nil then
      mp.AfterIterateProc({bip}mp.PIiterateData,mp);
    mp.Free;
  end;
  inherited;
end;

procedure TGetEntVariable.GetResult(const Source:TParserExporterString;
                    const Token :TSubStr;
                    const Operands :TSubStr;
                    const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                    var Result:TParserExporterString;
                    var ResultParam:TSubStr;
                    var data:TDataExport);
var
  pv:pvardesk;
  i:integer;
begin
  pv:=nil;
  if data.CurrentEntity<>nil then
    pv:=FindVariableInEnt(data.CurrentEntity,variablename);
  if pv<>nil then
    tempresult:=pv^.data.ptd^.GetValueAsString(pv^.data.Instance)
  else
    tempresult:='!!ERR('+variablename+')!!';
  ResultParam.Length:=Length(tempresult);
  if ResultParam.StartPos<>OnlyGetLength then
    for i:=0 to tempresult.Length-1 do
      Result[ResultParam.StartPos+i]:=tempresult[i+1];
end;

constructor TGetEntVariable.vcreate(const Source:TParserExporterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserExporterString,TDataExport>;
                        var Data:TDataExport);
begin
  variablename:=ParsedOperands.GetResult(Data);
end;

destructor TGetEntVariable.Destroy;
begin
  variablename:='';
  inherited;
end;


function DataExport_com(operands:TCommandOperands):TCommandResult;
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

begin
  zcShowCommandParams(SysUnit^.TypeName2PTD('TDataExportParam'),@DataExportParam);


  EntsTypeFilter:=TEntsTypeFilter.Create;
  pt:=ParserEntityTypeFilter.GetTokens(DataExportParam.EntFilter^);
  pt.Doit(EntsTypeFilter);
  EntsTypeFilter.SetFilter;
  pt.Free;

  pet:=ExporterParser.GetTokens(DataExportParam.Exporter^);

  EntityIncluder:=ParserEntityPropFilter.GetTokens(DataExportParam.PropFilter^);
  lpsh:=LPSHEmpty;

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

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');

  VU.init('test');
  VU.InterfaceUses.PushBackIfNotPresent(sysunit);

  DataExportParam.EntFilter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_EntFilter','GDBAnsiString');
  if DataExportParam.EntFilter^='' then
    DataExportParam.EntFilter^:='IncludeEntityName(''Cable'');'#13#10'IncludeEntityName(''Device'')';
  DataExportParam.PropFilter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_PropFilter','GDBAnsiString');
  //if DataExportParam.PropFilter^='' then
  //  DataExportParam.PropFilter:='';
  DataExportParam.Exporter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_Exporter','GDBAnsiString');
  if DataExportParam.Exporter^='' then
    DataExportParam.Exporter^:='DoIf(SameMask(%%(''EntityName''),''Device''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''Position'',@@(''Position'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Device''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''Power'',@@(''Power'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Cable''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''AmountD'',@@(''AmountD'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Cable''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''CABLE_Segment'',@@(''CABLE_Segment'')))';
  DataExportParam.FileName:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_FileName','GDBAnsiString');
  if DataExportParam.FileName^='' then
    DataExportParam.FileName^:='d:\test.csv';

  SysUnit^.RegisterType(TypeInfo(TDataExportParam));//регистрируем тип данных в зкадном RTTI
  SysUnit^.SetTypeDesk(TypeInfo(TDataExportParam),['EntFilter','PropFilter','Exporter','FileName'],[FNProgram]);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел

  CreateCommandFastObjectPlugin(@DataExport_com,'DataExport',  CADWG,0);


  ExporterParser:=TExporterParser.create;
  BracketTockenId:=ExporterParser.RegisterToken('(','(',')',nil,ExporterParser,[TONestedBracke,TOIncludeBrackeOpen,TOSeparator]);
  ExporterParser.RegisterToken('Export',#0,#0,TExport,nil,[TOWholeWordOnly],BracketTockenId);
  ExporterParser.RegisterToken('DoIf',#0,#0,TDoIf,ExporterParser,[TOWholeWordOnly],BracketTockenId);
  ExporterParser.RegisterToken('SameMask',#0,#0,TSameMask,ExporterParser,[TOWholeWordOnly],BracketTockenId);
  ExporterParser.RegisterToken('%%',#0,#0,TGetEntParam,ExporterParser,[TOWholeWordOnly],BracketTockenId);
  ExporterParser.RegisterToken('@@',#0,#0,TGetEntVariable,ExporterParser,[TOWholeWordOnly],BracketTockenId);
  ExporterParser.RegisterToken('''','''','''',ExporterParser.TParserTokenizer.TStringProcessor,nil,[TOIncludeBrackeOpen]);
  ExporterParser.RegisterToken(',',#0,#0,nil,nil,[TOSeparator]);
  ExporterParser.RegisterToken(';',#0,#0,nil,nil,[TOSeparator]);
  ExporterParser.RegisterToken(' ',#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ExporterParser.RegisterToken(#10,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);
  ExporterParser.RegisterToken(#13,#0,#0,nil,nil,[TOSeparator,TOCanBeOmitted]);

finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  ExporterParser.Free;
end.
