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
unit uzctextpreprocessorimpl;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface
uses uzeentity,uzcvariablesutils,uzetextpreprocessor,sysutils,
     uzsbVarmanDef,uzeTypes,uzcenitiesvariablesextender,languade,
     uzcpropertiesutils,uzeparser,LazUTF8,uzcTextPreprocessorDXFImpl;
type
  TStr2VarProcessor=class(TMyParser.TParserTokenizer.TDynamicProcessor)
    function GetResult(const str:String;const operands:String;var NextSymbolPos:integer;pobj:Pointer):String;
  end;

  TNum2StrProcessor=class(TMyParser.TParserTokenizer.TStaticProcessor)
    class procedure StaticGetResult(const Source:TUnicodeStringManipulator.TStringType;
                                    const Token :TUnicodeStringManipulator.TCharRange;
                                    const Operands :TUnicodeStringManipulator.TCharRange;
                                    const ParsedOperands :specialize TAbstractParsedText<TUnicodeStringManipulator.TStringType,pointer>;
                                    InsideBracketParser:TObject;
                                    var Result:TUnicodeStringManipulator.TStringType;
                                    var ResultParam:TUnicodeStringManipulator.TCharRange;
                                    var data:pointer);override;
  end;

  TPointer2StrProcessor=class(TMyParser.TParserTokenizer.TDynamicProcessor)
    constructor vcreate(const Source:TUnicodeStringManipulator.TStringType;
                        const Token :TUnicodeStringManipulator.TCharRange;
                        const Operands :TUnicodeStringManipulator.TCharRange;
                        const ParsedOperands :specialize TAbstractParsedText<TUnicodeStringManipulator.TStringType,pointer>;
                        InsideBracketParser:TObject;
                        var Data:{TEntsTypeFilter}pointer);override;
    procedure GetResult(const Source:TUnicodeStringManipulator.TStringType;
                        const Token :TUnicodeStringManipulator.TCharRange;
                        const Operands :TUnicodeStringManipulator.TCharRange;
                        const ParsedOperands :specialize TAbstractParsedText<TUnicodeStringManipulator.TStringType,pointer>;
                        InsideBracketParser:TObject;
                        var Result:TUnicodeStringManipulator.TStringType;
                        var ResultParam:TUnicodeStringManipulator.TCharRange;
                        var data:pointer);override;
  end;
var
  TokenTextInfo:TMyParser.TParserTokenizer.TTokenTextInfo;
  pt:TMyParser.TGeneralParsedText;
  s:UnicodeString;
  p:pointer;

function SPFSzcad:TSPFSourceEnum;

implementation
var
  _SPFSzcad:TSPFSourceEnum;

function SPFSzcad:TSPFSourceEnum;
begin
  Result:=_SPFSzcad;
end;

function TStr2VarProcessor.GetResult(const str:String;const operands:String;var NextSymbolPos:integer;pobj:Pointer):String;
var
  pv:pvardesk;
begin
  pv:=nil;
  if pobj<>nil then
    pv:=FindVariableInEnt(PGDBObjEntity(pobj),operands);
  if pv<>nil then
    result:=pv^.data.ptd^.GetValueAsString(pv^.data.Addr.Instance)
  else
    result:='!!ERR('+operands+')!!';
end;
class procedure TNum2StrProcessor.StaticGetResult(const Source:TUnicodeStringManipulator.TStringType;
                                                  const Token :TUnicodeStringManipulator.TCharRange;
                                const Operands :TUnicodeStringManipulator.TCharRange;
                                const ParsedOperands :specialize TAbstractParsedText<TUnicodeStringManipulator.TStringType,pointer>;
                                InsideBracketParser:TObject;
                                var Result:TUnicodeStringManipulator.TStringType;
                                var ResultParam:TUnicodeStringManipulator.TCharRange;
                                var data:pointer);
begin
  ResultParam.L.CodeUnits:=2;
  if ResultParam.P.CodeUnitPos<>OnlyGetLength then begin
    Result[ResultParam.P.CodeUnitPos]:='9';
    Result[ResultParam.P.CodeUnitPos+1]:='9';
  end;
end;

constructor TPointer2StrProcessor.vcreate(const Source:TUnicodeStringManipulator.TStringType;
                                          const Token :TUnicodeStringManipulator.TCharRange;
                                          const Operands :TUnicodeStringManipulator.TCharRange;
                                          const ParsedOperands :specialize TAbstractParsedText<TUnicodeStringManipulator.TStringType,pointer>;
                                          InsideBracketParser:TObject;
                                          var Data:{TEntsTypeFilter}pointer);
begin

end;

procedure TPointer2StrProcessor.GetResult(const Source:TUnicodeStringManipulator.TStringType;
                                          const Token :TUnicodeStringManipulator.TCharRange;
                                          const Operands :TUnicodeStringManipulator.TCharRange;
                                          const ParsedOperands :specialize TAbstractParsedText<TUnicodeStringManipulator.TStringType,pointer>;
                                          InsideBracketParser:TObject;
                                          var Result:TUnicodeStringManipulator.TStringType;
                                          var ResultParam:TUnicodeStringManipulator.TCharRange;
                                          var data:pointer);
begin
  ResultParam.L.CodeUnits:=2;
  if ResultParam.P.CodeUnitPos<>OnlyGetLength then begin
    Result[ResultParam.P.CodeUnitPos]:='0';
    Result[ResultParam.P.CodeUnitPos+1]:='0';
  end;
end;

function prop2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;var SPA:TStrProcessAttributes;pobj:Pointer):String;
begin
  if GetProperty(pobj,operands,result) then
    else
      result:='!!ERRprop('+operands+')!!';
end;

function var2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;var SPA:TStrProcessAttributes;pobj:Pointer):String;
var
  pv:pvardesk;
begin
  pv:=nil;
  if pobj<>nil then
    pv:=FindVariableInEnt(PGDBObjEntity(pobj),operands);
  if pv<>nil then
    result:=pv^.data.ptd^.GetValueAsString(pv^.data.Addr.Instance)
  else
    result:='!!ERR('+operands+')!!';
end;
function IfVarPresent2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;var SPA:TStrProcessAttributes;pobj:Pointer):String;
var
  pv:pvardesk;
  value,prefix,variable,suffix:string;
  oldi,i:integer;
begin
  prefix:='';
  variable:='';
  suffix:='';
  i:=Pos('|',operands);
  if i>0 then begin
    oldi:=i;
    prefix:=copy(operands,1,i-1);
    i:=Pos('|',operands,i+1);
    if i>0 then begin
      variable:=copy(operands,oldi+1,i-oldi-1);
    end;
    suffix:=copy(operands,i+1,Length(operands)-i);
  end else
    variable:=operands;
  pv:=nil;
  if pobj<>nil then
    pv:=FindVariableInEnt(PGDBObjEntity(pobj),variable);
  if pv<>nil then begin
    value:=pv^.data.ptd^.GetValueAsString(pv^.data.Addr.Instance);
    if value<>'' then begin
      result:=prefix+pv^.data.ptd^.GetValueAsString(pv^.data.Addr.Instance)+suffix;
      include(spa,SPARecursive);
    end else
      result:='';
  end else
    result:='';
end;

function evaluatesubstr(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;var SPA:TStrProcessAttributes;pobj:Pointer):String;
var
  vd:vardesk;
  pentvarext:TVariablesExtender;
begin
  result:='';
  if operands<>'' then
  begin
    pentvarext:=PGDBObjEntity(pobj)^.specialize GetExtension<TVariablesExtender>;
    if pentvarext<>nil then begin
    vd:=evaluate(operands,@pentvarext.entityunit);
    if (assigned(vd.data.ptd))and(assigned(vd.data.Addr.GetInstance)) then
      result:=vd.GetValueAsString
    else
      result:='!!ERR('+operands+')!!';
    end;
  end;
end;

function date2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;var SPA:TStrProcessAttributes;pobj:Pointer):String;
begin
  result:=datetostr(date);
end;

initialization
  _SPFSzcad:=SPFSources.GetEnum;
  Prefix2ProcessFunc.RegisterProcessor('%%DATE',#0,#0,@date2value,_SPFSzcad,true);
  Prefix2ProcessFunc.RegisterProcessor('@@','[',']',@var2value,_SPFSzcad,true);
  {$Message Need remove @@if macro, use @@ifvar}
  {todo: Need remove @@if macro, use @@ifvar}
  Prefix2ProcessFunc.RegisterProcessor('@@if','<','>',@IfVarPresent2value,_SPFSzcad,true);
  Prefix2ProcessFunc.RegisterProcessor('@@ifvar','<','>',@IfVarPresent2value,_SPFSzcad,true);
  Prefix2ProcessFunc.RegisterProcessor('%%','[',']',@prop2value,_SPFSzcad,true);
  Prefix2ProcessFunc.RegisterProcessor('#calc','[',']',@evaluatesubstr,_SPFSzcad);

  Parser.RegisterToken('@@[','[',']',{@var2value}TStr2VarProcessor,nil,TGOIncludeBrackeOpen,ZCADToken);
  Parser.RegisterToken('NUM',#0,#0,TNum2StrProcessor,nil,0,ZCADToken);
  Parser.RegisterToken('PTR',#0,#0,TPointer2StrProcessor,nil,0,ZCADToken);
  //Parser.RegisterToken('%%[','[',']',@prop2value,[TOIncludeBrackeOpen,TOVariable]);
  //Parser.RegisterToken('\',#0,#0,@EscapeSeq);
  //Parser.RegisterToken('%%DATE',#0,#0,@date2value,[TOVariable]);
  parser.OptimizeTokens;
  pt:=Parser.GetTokens('(PTR-NUM)');
  //pt.SetOperands;
  //pt.SetData;
  p:=nil;
  s:=pt.GetResult(p);
  pt.Free;
 { a:=Parser.GetTokenFromSubStr('_@@[Layer]',1,TokenTextInfo);
  a:=Parser.GetTokenFromSubStr('_@@[Layer]',TokenTextInfo.NextPos,TokenTextInfo);
  a:=Parser.GetTokenFromSubStr('_@@[Layer]',TokenTextInfo.NextPos,TokenTextInfo);
  a:=Parser.GetTokenFromSubStr('_@@[Layer]',TokenTextInfo.NextPos,TokenTextInfo);
  vp:=TStr2VarProcessor.create;
  spc:=TStr2VarProcessor;}
end.
