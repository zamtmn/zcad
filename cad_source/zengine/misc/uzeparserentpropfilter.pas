unit uzeparserentpropfilter;

{$mode delphi}

interface

uses
  SysUtils,
  uzeentity,uzeparser,Masks,
  uzcoimultiproperties,uzedimensionaltypes,
  uzbtypes,Varman,uzcoimultipropertiesutil;

type
  TPropFilterData=record
    CurrentEntity:PGDBObjEntity;
    IncludeEntity:TGDB3StateBool;
  end;

  TParserEntityPropFilterString=AnsiString;
  TParserEntityPropFilterChar=AnsiChar;
  TParserEntityPropFilter=TGZParser<TParserEntityPropFilterString,TParserEntityPropFilterChar,TPropFilterData,TCharToOptChar<AnsiChar>>;

  TIncludeIfMask=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserEntityPropFilterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                               var Data:TPropFilterData);override;
  end;

  TIncludeIf=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticDoit(const Source:TParserEntityPropFilterString;
                               const Token :TSubStr;
                               const Operands :TSubStr;
                               const ParsedOperands :TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                               var Data:TPropFilterData);override;
  end;


  TSameMask=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TParserEntityPropFilterString;
                                    const Token :TSubStr;
                                    const Operands :TSubStr;
                                    const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                                    var Result:TParserEntityPropFilterString;
                                    var ResultParam:TSubStr;
                                    //var NextSymbolPos:integer;
                                    var data:TPropFilterData);override;
  end;

  TOr=class(TParserEntityPropFilter.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TParserEntityPropFilterString;
                                    const Token :TSubStr;
                                    const Operands :TSubStr;
                                    const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                                    var Result:TParserEntityPropFilterString;
                                    var ResultParam:TSubStr;
                                    //var NextSymbolPos:integer;
                                    var data:TPropFilterData);override;
  end;



  TGetEntParam=class(TParserEntityPropFilter.TParserTokenizer.TDynamicProcessor)
    mp:TMultiProperty;
    tempresult:TParserEntityPropFilterString;
    constructor vcreate(const Source:TParserEntityPropFilterString;
                            const Token :TSubStr;
                            const Operands :TSubStr;
                            const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                            var Data:TPropFilterData);override;
    destructor Destroy;override;
    procedure GetResult(const Source:TParserEntityPropFilterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                        var Result:TParserEntityPropFilterString;
                        var ResultParam:TSubStr;
                        var data:TPropFilterData);override;
  end;
var
  ParserEntityPropFilter:TParserEntityPropFilter;

implementation

var
  BracketTockenId:TParserEntityPropFilter.TParserTokenizer.TTokenId;
  VU:TObjectUnit;

class procedure TIncludeIfMask.StaticDoit(const Source:TParserEntityPropFilterString;
                           const Token :TSubStr;
                           const Operands :TSubStr;
                           const ParsedOperands :TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                           var Data:TPropFilterData);
var
  op1,op2:TParserEntityPropFilterString;
  ResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TParserEntityPropFilter.TParsedText)
     and((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       if Data.IncludeEntity<>T3SB_Fale then begin
         op1:=inttostr((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size);
         ResultParam.StartPos:=OnlyGetLength;
         ResultParam.Length:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);
         SetLength(op1,ResultParam.Length);
         ResultParam.StartPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,ResultParam);

         ResultParam.StartPos:=OnlyGetLength;
         ResultParam.Length:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);
         SetLength(op2,ResultParam.Length);
         ResultParam.StartPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,ResultParam);
         if MatchesMask(op1,op2,false)
             or (AnsiCompareText(op1,op2)=0) then
               Data.IncludeEntity:=T3SB_True;
       end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

class procedure TIncludeIf.StaticDoit(const Source:TParserEntityPropFilterString;
                                      const Token :TSubStr;
                                      const Operands :TSubStr;
                                      const ParsedOperands :TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                                      var Data:TPropFilterData);
var
  op1:TParserEntityPropFilterString;
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
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

class procedure TSameMask.StaticGetResult(const Source:TParserEntityPropFilterString;
                                          const Token :TSubStr;
                                          const Operands :TSubStr;
                                          const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                                          var Result:TParserEntityPropFilterString;
                                          var ResultParam:TSubStr;
                                          //var NextSymbolPos:integer;
                                          var data:TPropFilterData);
var
  op1,op2:TParserEntityPropFilterString;
  opResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TParserEntityPropFilter.TParsedText)
     and((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       if Data.IncludeEntity<>T3SB_Fale then begin
         op1:=inttostr((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size);
         opResultParam.StartPos:=OnlyGetLength;
         opResultParam.Length:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
         SetLength(op1,opResultParam.Length);
         opResultParam.StartPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);

         opResultParam.StartPos:=OnlyGetLength;
         opResultParam.Length:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         SetLength(op2,opResultParam.Length);
         opResultParam.StartPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         ResultParam.Length:=1;
         if ResultParam.StartPos<>OnlyGetLength then begin
           if MatchesMask(op1,op2,false)
               or (AnsiCompareText(op1,op2)=0) then
             Result[ResultParam.StartPos]:='+'
           else
             Result[ResultParam.StartPos]:='-'
         end;
       end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

class procedure TOr.StaticGetResult(const Source:TParserEntityPropFilterString;
                                  const Token :TSubStr;
                                  const Operands :TSubStr;
                                  const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                                  var Result:TParserEntityPropFilterString;
                                  var ResultParam:TSubStr;
                                  //var NextSymbolPos:integer;
                                  var data:TPropFilterData);
var
  op1,op2:TParserEntityPropFilterString;
  opResultParam:TSubStr;
begin
  if (ParsedOperands<>nil)
     and(ParsedOperands is TParserEntityPropFilter.TParsedText)
     and((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size=3)
     {and((ParsedOperands as TEntityFilterParser.TParsedTextWithOneToken).Part.TextInfo.TokenId=StringId)} then begin
       if Data.IncludeEntity<>T3SB_Fale then begin
         op1:=inttostr((ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.size);
         opResultParam.StartPos:=OnlyGetLength;
         opResultParam.Length:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);
         SetLength(op1,opResultParam.Length);
         opResultParam.StartPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[0]^,data,op1,opResultParam);

         opResultParam.StartPos:=OnlyGetLength;
         opResultParam.Length:=0;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         SetLength(op2,opResultParam.Length);
         opResultParam.StartPos:=InitialStartPos;
         TParserEntityPropFilter.TGeneralParsedText.GetResultWithPart(Source,(ParsedOperands as TParserEntityPropFilter.TParsedText).Parts.Mutable[2]^,data,op2,opResultParam);
         ResultParam.Length:=1;
         if ResultParam.StartPos<>OnlyGetLength then begin
           if (op1='+')
           or (op2='+') then
             Result[ResultParam.StartPos]:='+'
           else
             Result[ResultParam.StartPos]:='-'
         end;
       end;
       //TEntsTypeFilter(Data).AddTypeNameMask(op1)
     end
  else
    Raise Exception.CreateFmt(rsRunTimeError,[Operands.StartPos]);
end;

procedure TGetEntParam.GetResult(const Source:TParserEntityPropFilterString;
                    const Token :TSubStr;
                    const Operands :TSubStr;
                    const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                    var Result:TParserEntityPropFilterString;
                    var ResultParam:TSubStr;
                    var data:TPropFilterData);
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

constructor TGetEntParam.vcreate(const Source:TParserEntityPropFilterString;
                        const Token :TSubStr;
                        const Operands :TSubStr;
                        const ParsedOperands:TAbstractParsedText<TParserEntityPropFilterString,TPropFilterData>;
                        var Data:TPropFilterData);
var
  propertyname:string;
  tmp:TMultiProperty;
begin
  propertyname:=ParsedOperands.GetResult(Data);
  if MultiPropertiesManager.MultiPropertyDictionary.MyGetValue(propertyname,tmp) then begin
    mp:=TMultiProperty.CreateAndCloneFrom(tmp);
    {bip}mp.PIiterateData:=mp.BeforeIterateProc(mp,@VU);
    //mp.Free;{ #todo : теперь сделал копию //нужно делать копию mp, но пока пусть так }
  end else
    mp:=nil;
end;

destructor TGetEntParam.Destroy;
begin
  if mp<>nil then begin
    if @mp.AfterIterateProc<>nil then
      mp.AfterIterateProc({bip}mp.PIiterateData,mp);
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
  ParserEntityPropFilter.RegisterToken('''','''','''',ParserEntityPropFilter.TParserTokenizer.TStringProcessor,nil,TGOIncludeBrackeOpen);
  ParserEntityPropFilter.RegisterToken(',',#0,#0,nil,nil,TGOSeparator);
  ParserEntityPropFilter.RegisterToken(';',#0,#0,nil,nil,TGOSeparator);
  ParserEntityPropFilter.RegisterToken(' ',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserEntityPropFilter.RegisterToken(#10,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ParserEntityPropFilter.RegisterToken(#13,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
finalization;
  ParserEntityPropFilter.Free;
  VU.done;
end.

