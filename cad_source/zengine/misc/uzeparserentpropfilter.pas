unit uzeparserentpropfilter;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,Masks,
  uzcoimultiproperties,
  uzbtypes,Varman,varmandef,uzcoimultipropertiesutil,uzcvariablesutils,
  uzbUnits;

type
  TPropFilterData=record
    CurrentEntity:PGDBObjEntity;
    IncludeEntity:TGDB3StateBool;
    f:TzeUnitsFormat;
  end;

  //TParserEntityPropFilterString=AnsiString;
  //TParserEntityPropFilterChar=AnsiChar;
  TParserEntityPropFilter=TGZParser<TRawByteStringManipulator,
                                    TRawByteStringManipulator.TStringType,
                                    TRawByteStringManipulator.TCharType,
                                    TCodeUnitPosition,
                                    TRawByteStringManipulator.TCharPosition,
                                    TRawByteStringManipulator.TCharLength,
                                    TRawByteStringManipulator.TCharInterval,
                                    TRawByteStringManipulator.TCharRange,
                                    TPropFilterData,
                                    TCharToOptChar<TRawByteStringManipulator.TCharType>>;

  TIncludeIfMask=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                               InsideBracketParser:TObject;
                               var Data:TPropFilterData);override;
  end;

  TIncludeIf=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                               const Token :TRawByteStringManipulator.TCharRange;
                               const Operands :TRawByteStringManipulator.TCharRange;
                               const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                               InsideBracketParser:TObject;
                               var Data:TPropFilterData);override;
  end;


  TSameMask=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TRawByteStringManipulator.TStringType;
                                    const Token :TRawByteStringManipulator.TCharRange;
                                    const Operands :TRawByteStringManipulator.TCharRange;
                                    const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                                    InsideBracketParser:TObject;
                                    var Result:TRawByteStringManipulator.TStringType;
                                    var ResultParam:TRawByteStringManipulator.TCharRange;
                                    //var NextSymbolPos:integer;
                                    var data:TPropFilterData);override;
  end;

  TOr=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TRawByteStringManipulator.TStringType;
                                    const Token :TRawByteStringManipulator.TCharRange;
                                    const Operands :TRawByteStringManipulator.TCharRange;
                                    const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                                    InsideBracketParser:TObject;
                                    var Result:TRawByteStringManipulator.TStringType;
                                    var ResultParam:TRawByteStringManipulator.TCharRange;
                                    //var NextSymbolPos:integer;
                                    var data:TPropFilterData);override;
  end;



  TGetEntParam=class(TParserEntityPropFilter.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TRawByteStringManipulator.TStringType;
    constructor vcreate(const Source:TRawByteStringManipulator.TStringType;
                            const Token :TRawByteStringManipulator.TCharRange;
                            const Operands :TRawByteStringManipulator.TCharRange;
                            const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                            InsideBracketParser:TObject;
                            var Data:TPropFilterData);override;
    destructor Destroy;override;
    procedure GetResult(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                        InsideBracketParser:TObject;
                        var Result:TRawByteStringManipulator.TStringType;
                        var ResultParam:TRawByteStringManipulator.TCharRange;
                        var data:TPropFilterData);override;
  end;
  TGetEntVariable=class(TParserEntityPropFilter.TParserTokenizer.TDynamicProcessor)
    tempresult:TRawByteStringManipulator.TStringType;
    variablename:string;
    constructor vcreate(const Source:TRawByteStringManipulator.TStringType;
                            const Token :TRawByteStringManipulator.TCharRange;
                            const Operands :TRawByteStringManipulator.TCharRange;
                            const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                            InsideBracketParser:TObject;
                            var Data:TPropFilterData);override;
    destructor Destroy;override;
    procedure GetResult(const Source:TRawByteStringManipulator.TStringType;
                        const Token :TRawByteStringManipulator.TCharRange;
                        const Operands :TRawByteStringManipulator.TCharRange;
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                        InsideBracketParser:TObject;
                        var Result:TRawByteStringManipulator.TStringType;
                        var ResultParam:TRawByteStringManipulator.TCharRange;
                        var data:TPropFilterData);override;
  end;

var
  ParserEntityPropFilter:TParserEntityPropFilter;

implementation

var
  BracketTockenId:TParserEntityPropFilter.TParserTokenizer.TTokenId;
  VU:TEntityUnit;

procedure TGetEntVariable.GetResult(const Source:TRawByteStringManipulator.TStringType;
                    const Token :TRawByteStringManipulator.TCharRange;
                    const Operands :TRawByteStringManipulator.TCharRange;
                    const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                    InsideBracketParser:TObject;
                    var Result:TRawByteStringManipulator.TStringType;
                    var ResultParam:TRawByteStringManipulator.TCharRange;
                    var data:TPropFilterData);
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
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                        InsideBracketParser:TObject;
                        var Data:TPropFilterData);
begin
  variablename:=ParsedOperands.GetResult(Data);
end;

destructor TGetEntVariable.Destroy;
begin
  variablename:='';
  inherited;
end;


class procedure TIncludeIfMask.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                           const Token :TRawByteStringManipulator.TCharRange;
                           const Operands :TRawByteStringManipulator.TCharRange;
                           const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                           InsideBracketParser:TObject;
                           var Data:TPropFilterData);
var
  op1,op2:TRawByteStringManipulator.TStringType;
  ResultParam:TRawByteStringManipulator.TCharRange;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TParserEntityPropFilter.TParsedText)
     and((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       if Data.IncludeEntity<>T3SB_Fale then begin
         op1:=inttostr((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size);
         op2:='';
         ResultParam.P.CodeUnitPos:=OnlyGetLength;
         ResultParam.L.CodeUnits:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
         SetLength(op1,ResultParam.L.CodeUnits);
         ResultParam.P.CodeUnitPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);

         ResultParam.P.CodeUnitPos:=OnlyGetLength;
         ResultParam.L.CodeUnits:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);
         SetLength(op2,ResultParam.L.CodeUnits);
         ResultParam.P.CodeUnitPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);
         if MatchesMask(op1,op2,false)
             or (AnsiCompareText(op1,op2)=0) then
               Data.IncludeEntity:=T3SB_True;
       end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

class procedure TIncludeIf.StaticDoit(const Source:TRawByteStringManipulator.TStringType;
                                      const Token :TRawByteStringManipulator.TCharRange;
                                      const Operands :TRawByteStringManipulator.TCharRange;
                                      const ParsedOperands :TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                                      InsideBracketParser:TObject;
                                      var Data:TPropFilterData);
var
  op1:TRawByteStringManipulator.TStringType;
begin
  if (ParsedOperands<>nil)
     and((ParsedOperands is TParserEntityPropFilter.TParsedTextWithOneToken)or(ParsedOperands is TParserEntityPropFilter.TParsedTextWithoutTokens))then begin
       if Data.IncludeEntity<>T3SB_Fale then begin
         op1:=ParsedOperands.GetResult(data);

            if op1='+' then
               Data.IncludeEntity:=T3SB_True;
       end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

class procedure TSameMask.StaticGetResult(const Source:TRawByteStringManipulator.TStringType;
                                          const Token :TRawByteStringManipulator.TCharRange;
                                          const Operands :TRawByteStringManipulator.TCharRange;
                                          const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                                          InsideBracketParser:TObject;
                                          var Result:TRawByteStringManipulator.TStringType;
                                          var ResultParam:TRawByteStringManipulator.TCharRange;
                                          //var NextSymbolPos:integer;
                                          var data:TPropFilterData);
var
  op1,op2:TRawByteStringManipulator.TStringType;
  opResultParam:TRawByteStringManipulator.TCharRange;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TParserEntityPropFilter.TParsedText)
     and((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       if Data.IncludeEntity<>T3SB_Fale then begin
         op1:=inttostr((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size);
         op2:='';
         opResultParam.P.CodeUnitPos:=OnlyGetLength;
         opResultParam.L.CodeUnits:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
         SetLength(op1,opResultParam.L.CodeUnits);
         opResultParam.P.CodeUnitPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);

         opResultParam.P.CodeUnitPos:=OnlyGetLength;
         opResultParam.L.CodeUnits:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         SetLength(op2,opResultParam.L.CodeUnits);
         opResultParam.P.CodeUnitPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         ResultParam.L.CodeUnits:=1;
         if ResultParam.P.CodeUnitPos<>OnlyGetLength then begin
           if MatchesMask(op1,op2,false)
               or (AnsiCompareText(op1,op2)=0) then
             Result[ResultParam.P.CodeUnitPos]:='+'
           else
             Result[ResultParam.P.CodeUnitPos]:='-'
         end;
       end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

class procedure TOr.StaticGetResult(const Source:TRawByteStringManipulator.TStringType;
                                  const Token :TRawByteStringManipulator.TCharRange;
                                  const Operands :TRawByteStringManipulator.TCharRange;
                                  const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                                  InsideBracketParser:TObject;
                                  var Result:TRawByteStringManipulator.TStringType;
                                  var ResultParam:TRawByteStringManipulator.TCharRange;
                                  //var NextSymbolPos:integer;
                                  var data:TPropFilterData);
var
  op1,op2:TRawByteStringManipulator.TStringType;
  opResultParam:TRawByteStringManipulator.TCharRange;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TParserEntityPropFilter.TParsedText)
     and((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       if Data.IncludeEntity<>T3SB_Fale then begin
         op1:=inttostr((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size);
         op2:='';
         opResultParam.P.CodeUnitPos:=OnlyGetLength;
         opResultParam.L.CodeUnits:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
         SetLength(op1,opResultParam.L.CodeUnits);
         opResultParam.P.CodeUnitPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);

         opResultParam.P.CodeUnitPos:=OnlyGetLength;
         opResultParam.L.CodeUnits:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         SetLength(op2,opResultParam.L.CodeUnits);
         opResultParam.P.CodeUnitPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         ResultParam.L.CodeUnits:=1;
         if ResultParam.P.CodeUnitPos<>OnlyGetLength then begin
           if (op1='+')
           or (op2='+') then
             Result[ResultParam.P.CodeUnitPos]:='+'
           else
             Result[ResultParam.P.CodeUnitPos]:='-'
         end;
       end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.P.CodeUnitPos]);
end;

procedure TGetEntParam.GetResult(const Source:TRawByteStringManipulator.TStringType;
                    const Token :TRawByteStringManipulator.TCharRange;
                    const Operands :TRawByteStringManipulator.TCharRange;
                    const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                    InsideBracketParser:TObject;
                    var Result:TRawByteStringManipulator.TStringType;
                    var ResultParam:TRawByteStringManipulator.TCharRange;
                    var data:TPropFilterData);
var
  i:integer;
  mpd:TMultiPropertyDataForObjects;
  //f:TzeUnitsFormat;
  ChangedData:TChangedData;
begin
  if ResultParam.P.CodeUnitPos=OnlyGetLength then begin
    if mp<>nil then begin
      if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(0,nil),mpd) then begin
        ChangedData:=CreateChangedData(data.CurrentEntity,mpd.GSData);
        if @mpd.EntBeforeIterateProc<>nil then
          mpd.EntBeforeIterateProc({bip}mp.PIiterateData,ChangedData);
        mpd.EntIterateProc({bip}mp.PIiterateData,ChangedData,mp,true,mpd.EntChangeProc,data.f);
        tempresult:=mp.MPType.GetDecoratedValueAsString(PVarDesk(PTOneVarData(mp.PIiterateData)^.VDAddr.Instance).data.Addr.Instance,data.f);
      end else if mp.MPObjectsData.tryGetValue(TObjIDWithExtender.Create(PGDBObjEntity(data.CurrentEntity)^.GetObjType,nil),mpd) then begin
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
                        const ParsedOperands:TAbstractParsedText<TRawByteStringManipulator.TStringType,TPropFilterData>;
                        InsideBracketParser:TObject;
                        var Data:TPropFilterData);
var
  propertyname:string;
  tmp:TMultiProperty;
begin
  propertyname:=ParsedOperands.GetResult(Data);
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,tmp) then begin
    mp:=TMultiProperty.CreateAndCloneFrom(tmp);
    {bip}mp.PIiterateData:=mp.MIPD.BeforeIterateProc(mp,@VU);
    //mp.Free;{ #todo : теперь сделал копию //нужно делать копию mp, но пока пусть так }
  end else
    mp:=nil;
end;

destructor TGetEntParam.Destroy;
begin
  if mp<>nil then begin
    if @mp.MIPD.AfterIterateProc<>nil then
      mp.MIPD.AfterIterateProc({bip}mp.PIiterateData,mp);
    mp.Free;{ #todo : теперь сделал копию //нужно делать копию mp, но пока пусть так }
  end;
end;

initialization
  VU.init('test');
  VU.InterfaceUses.PushBackIfNotPresent(sysunit);
  ParserEntityPropFilter:=TParserEntityPropFilter.create;
  BracketTockenId:=ParserEntityPropFilter.RegisterToken('(','(',')',nil,ParserEntityPropFilter,TGONestedBracke or TGOIncludeBrackeOpen or TGOSeparator);
  ParserEntityPropFilter.RegisterToken('IncludeIfMask',#0,#0,TIncludeIfMask,ParserEntityPropFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityPropFilter.RegisterToken('SameMask',#0,#0,TSameMask,ParserEntityPropFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityPropFilter.RegisterToken('Or',#0,#0,TOr,ParserEntityPropFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityPropFilter.RegisterToken('IncludeIfSame',#0,#0,TIncludeIf,ParserEntityPropFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityPropFilter.RegisterToken('%%',#0,#0,TGetEntParam,ParserEntityPropFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityPropFilter.RegisterToken('@@',#0,#0,TGetEntVariable,ParserEntityPropFilter,TGOWholeWordOnly,BracketTockenId);
  ParserEntityPropFilter.RegisterToken('''','''','''',ParserEntityPropFilter.TParserTokenizer.TStringProcessor,nil,TGOIncludeBrackeOpen);
  ParserEntityPropFilter.RegisterToken(',',#0,#0,nil,nil,TGOSeparator);
  ParserEntityPropFilter.RegisterToken(';',#0,#0,nil,nil,TGOSeparator);
  ParserEntityPropFilter.RegisterToken('\P',#0,#0,nil,nil,TGOSeparator);
  ParserEntityPropFilter.RegisterToken(' ',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserEntityPropFilter.RegisterToken(#10,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserEntityPropFilter.RegisterToken(#13,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
finalization;
  ParserEntityPropFilter.Free;
  VU.done;
end.

