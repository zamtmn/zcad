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
{$mode objfpc}{$H+}
{$modeswitch advancedrecords}
interface
uses
  SysUtils,
  uzbNamedHandles,uzbNamedHandlesWithData,gvector;

type
  TCLStringType=String;
  TCLStrings=specialize TVector<TCLStringType>;
  TOptionHandle=Integer;
  TOptionType=(AT_Flag,AT_Operand);
  PTOptionData=^TOptionData;
  TOptionData=record
    Present:Boolean;
    &Type:TOptionType;
    FirstOperand:TCLStringType;
    OtherOperands:TCLStrings;
    constructor CreateRec(AType:TOptionType);
  end;
  TParams=array of Integer;

  TOptions=specialize GTNamedHandlesWithData<TOptionHandle,specialize GTLinearIncHandleManipulator<TOptionHandle>,TCLStringType,specialize GTStringNamesCaseSensetive<TCLStringType>,TOptionData>;
  TCommandLineParser=object
    private
      Options:TOptions;
      Operands:TCLStrings;
      Params:TParams;
      function getParamsCount:Integer;
      function getParam(i:SizeUInt):Integer;
      function getOperand(i:SizeUInt):TCLStringType;
    public
      constructor Init;
      destructor Done;
      function RegisterArgument(const Option:TCLStringType;const OptionType:TOptionType):TOptionHandle;
      procedure ParseCommandLine;
      function HasOption(hdl:TOptionHandle):Boolean;
      function OptionOperand(hdl:TOptionHandle):TCLStringType;
      function GetOptionPData(hdl:TOptionHandle):PTOptionData;
      function GetOptionName(hdl:TOptionHandle):TCLStringType;
      property ParamsCount:Integer read getParamsCount;
      property Param[i:SizeUInt]:Integer read getParam;
      property Operand[i:SizeUInt]:TCLStringType read getOperand;
  end;

implementation

constructor TOptionData.CreateRec(AType:TOptionType);
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

function TCommandLineParser.RegisterArgument(const Option:TCLStringType;const OptionType:TOptionType):TOptionHandle;
var
  data:TOptionData;
begin
  data:=TOptionData.CreateRec(OptionType);
  result:=Options.CreateOrGetHandleAndSetData(Option,data);
end;

function TCommandLineParser.GetOptionPData(hdl:TOptionHandle):PTOptionData;
begin
  result:=Options.GetPLincedData(hdl);
end;
function TCommandLineParser.GetOptionName(hdl:TOptionHandle):TCLStringType;
begin
  result:=Options.GetHandleName(hdl);
end;
procedure TCommandLineParser.ParseCommandLine;
var
  i,pi:integer;
  s:string;
  ArgumentHandle:TOptionHandle;
  PArgumentData:PTOptionData;
begin
  PArgumentData:=nil;
  pi:=0;
  for i:=1 to ParamCount do begin
    Params[pi]:=0;
    s:=ParamStr(i);
    if PArgumentData<>nil then begin
      if PArgumentData^.FirstOperand='' then
        PArgumentData^.FirstOperand:=s
      else begin
        if PArgumentData^.OtherOperands=nil then
          PArgumentData^.OtherOperands:=TCLStrings.Create;
        PArgumentData^.OtherOperands.PushBack(s);
      end;
      PArgumentData:=nil
    end else if Options.TryGetHandle(s,ArgumentHandle) then begin
      Params[pi]:=ArgumentHandle;
      PArgumentData:=Options.GetPLincedData(ArgumentHandle);
      PArgumentData^.Present:=True;
      if PArgumentData^.&Type<>AT_Operand then
        PArgumentData:=nil;
    end else begin
      Operands.PushBack(s);
      Params[pi]:=-Operands.Size;
    end;
    Inc(pi);
  end;
end;

function TCommandLineParser.HasOption(hdl:TOptionHandle):Boolean;
begin
  result:=Options.GetPLincedData(hdl)^.Present;
end;

function TCommandLineParser.OptionOperand(hdl:TOptionHandle):TCLStringType;
begin
  result:=Options.GetPLincedData(hdl)^.FirstOperand;
end;

end.
