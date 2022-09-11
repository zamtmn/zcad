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

unit uzbCommandLineParser;
{
Модуль парсер командной строки
utility_name [a] [b] [c option_argument1[,option_argument2]] [c option_argument3[,option_argument4]] [operand1] [operand2]
где
a, b - опции без аргументов, типа AT_Flag
c - опция с аргументами, типа AT_WithOperands
}


{$mode objfpc}{$H+}
{$modeswitch advancedrecords}
interface
uses
  SysUtils,
  uzbNamedHandles,uzbNamedHandlesWithData,gvector;

const
  OperandsSeparator=',';

type
  TCLStringType=String;
  TCLStrings=specialize TVector<TCLStringType>;
  TCLOptionHandle=Integer;
  TCLOptionType=(AT_Flag,AT_WithOperands);
  PTCLOptionData=^TCLOptionData;
  TCLOptionData=record
    Present:Boolean;
    &Type:TCLOptionType;
    FirstOperand:TCLStringType;
    OtherOperands:TCLStrings;
    constructor CreateRec(AType:TCLOptionType);
  end;
  TParams=array of Integer;

  TCLOptions=specialize GTNamedHandlesWithData<TCLOptionHandle,specialize GTLinearIncHandleManipulator<TCLOptionHandle>,TCLStringType,specialize GTStringNamesCaseSensetive<TCLStringType>,TCLOptionData>;
  TCommandLineParser=object
    private
      Options:TCLOptions;
      Operands:TCLStrings;
      Params:TParams;
      function getParamsCount:Integer;
      function getParam(i:SizeUInt):Integer;
      function getOperandsCount:Integer;
      function getOperand(i:SizeUInt):TCLStringType;
    public
      constructor Init;
      destructor Done;
      function RegisterArgument(const Option:TCLStringType;const OptionType:TCLOptionType):TCLOptionHandle;
      procedure ParseCommandLine;
      function HasOption(hdl:TCLOptionHandle):Boolean;
      function OptionOperandsCount(hdl:TCLOptionHandle):Integer;
      function OptionOperand(hdl:TCLOptionHandle;num:Integer):TCLStringType;
      function GetAllOptionOperands(hdl:TCLOptionHandle):TCLStringType;
      function GetOptionPData(hdl:TCLOptionHandle):PTCLOptionData;
      function GetOptionName(hdl:TCLOptionHandle):TCLStringType;
      property ParamsCount:Integer read getParamsCount;
      property Param[i:SizeUInt]:Integer read getParam;
      property OperandsCount:Integer read getOperandsCount;
      property Operand[i:SizeUInt]:TCLStringType read getOperand;
  end;

implementation

constructor TCLOptionData.CreateRec(AType:TCLOptionType);
begin
  Present:=False;
  &Type:=AType;
  FirstOperand:='';
  OtherOperands:=nil;
end;

function TCommandLineParser.getParam(i:SizeUInt):Integer;
begin
  result:=Params[i];
end;

function TCommandLineParser.getOperandsCount:Integer;
begin
  result:=Operands.Size;
end;

function TCommandLineParser.getOperand(i:SizeUInt):TCLStringType;
begin
  result:=Operands[i];
end;

function TCommandLineParser.getParamsCount:Integer;
begin
  result:=Length(Params);
end;

constructor TCommandLineParser.Init;
begin
  Options.init;
  Operands:=TCLStrings.Create;
  SetLength(Params,ParamCount);
end;

destructor TCommandLineParser.Done;
var
  i:integer;
begin
  for i:=0 to Options.HandleDataVector.Size-1 do
    Options.HandleDataVector.Mutable[i]^.D.OtherOperands.Free;
  Options.Done;
  Operands.Free;
  SetLength(Params,0);
end;

function TCommandLineParser.RegisterArgument(const Option:TCLStringType;const OptionType:TCLOptionType):TCLOptionHandle;
var
  data:TCLOptionData;
begin
  data:=TCLOptionData.CreateRec(OptionType);
  result:=Options.CreateOrGetHandleAndSetData(Option,data);
end;

function TCommandLineParser.GetOptionPData(hdl:TCLOptionHandle):PTCLOptionData;
begin
  result:=Options.GetPLincedData(hdl);
end;

function TCommandLineParser.GetOptionName(hdl:TCLOptionHandle):TCLStringType;
begin
  result:=Options.GetHandleName(hdl);
end;

procedure GetPart(out part:String;var path:String;const separator:String);
var
  i:Integer;
begin
  i:=pos(separator,path);
  if i<>0 then begin
    part:=copy(path,1,i-1);
    path:=copy(path,i+1,length(path)-i);
  end else begin
    part:=path;
    path:='';
  end;
end;

procedure addOperands(PArgumentData:PTCLOptionData;operands:TCLStringType);
begin
  if PArgumentData^.FirstOperand='' then
    PArgumentData^.FirstOperand:=operands
  else begin
    if PArgumentData^.OtherOperands=nil then
      PArgumentData^.OtherOperands:=TCLStrings.Create;
    PArgumentData^.OtherOperands.PushBack(operands);
  end;
end;

procedure TCommandLineParser.ParseCommandLine;
var
  i,pi:integer;
  s,op:TCLStringType;
  ArgumentHandle:TCLOptionHandle;
  PArgumentData:PTCLOptionData;
begin
  PArgumentData:=nil;
  pi:=0;
  for i:=1 to ParamCount do begin
    Params[pi]:=0;
    s:=ParamStr(i);
    if PArgumentData<>nil then begin

      if s<>'' then repeat
        GetPart(op,s,OperandsSeparator);
        addOperands(PArgumentData,op);
      until s='';

      PArgumentData:=nil
    end else if Options.TryGetHandle(s,ArgumentHandle) then begin
      PArgumentData:=Options.GetPLincedData(ArgumentHandle);
      if not PArgumentData^.Present then
        Params[pi]:=ArgumentHandle;
      PArgumentData^.Present:=True;
      if PArgumentData^.&Type<>AT_WithOperands then
        PArgumentData:=nil;
    end else begin
      Operands.PushBack(s);
      Params[pi]:=-Operands.Size;
    end;
    Inc(pi);
  end;
end;

function TCommandLineParser.HasOption(hdl:TCLOptionHandle):Boolean;
begin
  result:=Options.GetPLincedData(hdl)^.Present;
end;

function TCommandLineParser.OptionOperandsCount(hdl:TCLOptionHandle):Integer;
var
  PData:PTCLOptionData;
begin
  PData:=Options.GetPLincedData(hdl);
  if PData^.OtherOperands<>nil then
    result:=PData^.OtherOperands.Size+1
  else begin
    if PData^.FirstOperand<>'' then
      result:=1
    else
      result:=0;
  end;
end;

function TCommandLineParser.OptionOperand(hdl:TCLOptionHandle;num:Integer):TCLStringType;
begin
  if num=0 then
    result:=Options.GetPLincedData(hdl)^.FirstOperand
  else
    result:=Options.GetPLincedData(hdl)^.OtherOperands[num-1];
end;
function TCommandLineParser.GetAllOptionOperands(hdl:TCLOptionHandle):TCLStringType;
var
  PData:PTCLOptionData;
  i,strsize:integer;
begin
  PData:=Options.GetPLincedData(hdl);
  if PData^.OtherOperands<>nil then begin
    strsize:=PData^.OtherOperands.Size;
    for i:=0 to PData^.OtherOperands.Size-1 do
      strsize:=strsize+length(PData^.OtherOperands[i]);
    setlength(result,length(PData^.FirstOperand)+strsize);
    strsize:=1;
    Move(PData^.FirstOperand[1],result[strsize],length(PData^.FirstOperand)*sizeof(PData^.FirstOperand[1]));
    strsize:=strsize+length(PData^.FirstOperand);
    result[strsize]:=OperandsSeparator;
    inc(strsize);
    for i:=0 to PData^.OtherOperands.Size-1 do begin
      Move(PData^.OtherOperands.Mutable[i]^[1],result[strsize],length(PData^.OtherOperands.Mutable[i]^)*sizeof(PData^.FirstOperand[1]));
      strsize:=strsize+length(PData^.OtherOperands.Mutable[i]^);
      result[strsize]:=OperandsSeparator;
      inc(strsize);
    end;
  end else
    result:=PData^.FirstOperand;
end;

end.
