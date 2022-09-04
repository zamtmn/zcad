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
  uzbNamedHandles,uzbNamedHandlesWithData;

type
  TCLStringType=String;
  TOptionHandle=Integer;
  TOptionType=(AT_Flag,AT_Operand);
  PTOptionData=^TOptionData;
  TOptionData=record
    Present:Boolean;
    &Type:TOptionType;
    Operand:TCLStringType;
    constructor CreateRec(AType:TOptionType);
  end;

  TOptions=specialize GTNamedHandlesWithData<TOptionHandle,specialize GTLinearIncHandleManipulator<TOptionHandle>,TCLStringType,specialize GTStringNamesCaseSensetive<TCLStringType>,TOptionData>;
  TCommandLineParser=object
    Options:TOptions;
    constructor Init;
    destructor Done;
    function RegisterArgument(const Option:TCLStringType;const OptionType:TOptionType):TOptionHandle;
    procedure ParseCommandLine;
    function HasOption(hdl:TOptionHandle):Boolean;
    function OptionOperand(hdl:TOptionHandle):TCLStringType;
  end;

implementation

constructor TOptionData.CreateRec(AType:TOptionType);
begin
  Present:=False;
  &Type:=AType;
  Operand:='';
end;


constructor TCommandLineParser.Init;
begin
  Options.init;
end;

destructor TCommandLineParser.Done;
begin
  Options.done;
end;

function TCommandLineParser.RegisterArgument(const Option:TCLStringType;const OptionType:TOptionType):TOptionHandle;
var
  data:TOptionData;
begin
  data:=TOptionData.CreateRec(OptionType);
  result:=Options.CreateOrGetHandleAndSetData(Option,data);
end;

procedure TCommandLineParser.ParseCommandLine;
var
  i:integer;
  s:string;
  ArgumentHandle:TOptionHandle;
  PArgumentData:PTOptionData;
begin
  PArgumentData:=nil;
  for i:=1 to paramcount do begin
    s:=ParamStr(i);
    if PArgumentData<>nil then begin
      PArgumentData^.Operand:=ParamStr(i);
      PArgumentData:=nil
    end else if Options.TryGetHandle(ParamStr(i),ArgumentHandle) then begin
      PArgumentData:=Options.GetPLincedData(ArgumentHandle);
      PArgumentData^.Present:=True;
      if PArgumentData^.&Type<>AT_Operand then
        PArgumentData:=nil;
    end;
  end;
end;

function TCommandLineParser.HasOption(hdl:TOptionHandle):Boolean;
begin
  result:=Options.GetPLincedData(hdl)^.Present;
end;

function TCommandLineParser.OptionOperand(hdl:TOptionHandle):TCLStringType;
begin
  result:=Options.GetPLincedData(hdl)^.Operand;
end;

end.
