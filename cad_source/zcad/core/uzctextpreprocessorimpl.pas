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
unit uzctextpreprocessorimpl;
{$INCLUDE zcadconfig.inc}
{$mode objfpc}{$H+}

interface
uses uzeentity,uzcvariablesutils,uzetextpreprocessor,uzbstrproc,sysutils,
     varmandef,uzbtypes,uzcenitiesvariablesextender,
     uzcpropertiesutils,uzeparser,LazUTF8;
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
implementation
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

function prop2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;pobj:Pointer):String;
begin
  if GetProperty(pobj,operands,result) then
    else
      result:='!!ERRprop('+operands+')!!';
end;

function var2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;pobj:Pointer):String;
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
{function evaluatesubstr(var str:String;var startpos:integer;pobj:PGDBObjGenericWithSubordinated):String;
var
  endpos:integer;
  varname:String;
  //pv:pvardesk;
  vd:vardesk;
  pentvarext:TVariablesExtender;
  NextSymbolPos:integer;
begin
  NextSymbolPos:=startpos+1;
  if startpos>0 then
  begin
    endpos:=pos(']',str);
    if endpos<NextSymbolPos-1 then exit;
    varname:=copy(str,NextSymbolPos-1+3,endpos-NextSymbolPos-1-3);
    pentvarext:=pobj^.GetExtension(TVariablesExtender);
    vd:=evaluate(varname,@pentvarext.entityunit);
    if (assigned(vd.data.ptd))and(assigned(vd.Instance)) then
                                                                  str:=copy(str,1,NextSymbolPos-1-1)+vd.data.ptd^.GetValueAsString(vd.Instance)+copy(str,endpos+1,length(str)-endpos)
                                                              else
                                                                  str:=copy(str,1,NextSymbolPos-1-1)+'!!ERR('+varname+')!!'+copy(str,endpos+1,length(str)-endpos)
  end;
  startpos:=NextSymbolPos-1;
end;}

function EscapeSeq(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;pobj:Pointer):String;
var
  sym:char;
  value:TDXFEntsInternalStringType;
  num,code:integer;
begin
  result:='';
  if NextSymbolPos>0 then
  if NextSymbolPos<length(str) then
  begin
    sym:=str[NextSymbolPos];
    case sym of
      'L','l':result:=Chr(1);
      'P','p':result:=Chr(10);
      'U','u':begin
                value:='$'+copy(str,NextSymbolPos+2,4);
                val(value,num,code);
                result:={Chr(uch2ach(num))}{Tria_Utf8ToAnsi}(UnicodeToUtf8(num));
                NextSymbolPos:=NextSymbolPos+5;
              end
    else
      result:=sym;
    end;
    inc(NextSymbolPos);
  end;
end;

function date2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;pobj:Pointer):String;
begin
  result:=datetostr(date);
end;

initialization
  Prefix2ProcessFunc.RegisterProcessor('@@','[',']',@var2value,true);
  Prefix2ProcessFunc.RegisterProcessor('%%','[',']',@prop2value,true);
  //Prefix2ProcessFunc.RegisterProcessor('##','[',']',@evaluatesubstr);
  Prefix2ProcessFunc.RegisterProcessor('\',#0,#0,@EscapeSeq);
  Prefix2ProcessFunc.RegisterProcessor('%%DATE',#0,#0,@date2value,true);

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
