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

unit uzcuiutils;
{$INCLUDE zengineconfig.inc}
interface
uses
    Controls,LCLTaskDialog,SysUtils,Forms,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}
    uzclog,uzelongprocesssupport,uzcuitypes;

type

  TGSetConverter<TGEnumIn,TGSetIn,TGEnumOut,TGSetOut,TGEnumConverter>=class
    class function Convert(value:TGSetIn):TGSetOut;
  end;

  TGConverter<TGIn,TGOut,TGConverter>=class
    class function TryConvert(valueIn:TGIn; out valueOut:TGOut):boolean;
    //class function Convert(valueIn:TGIn;Converted:Boolean):TGOut;overload;
    class function Convert(valueIn:TGIn):TGOut;overload;
  end;

procedure CorrectButtons(var buttons:TZCMsgCommonButtons);
function getMsgID(MsgStr:TZCMsgStr):TZCMsgId;

implementation

procedure CorrectButtons(var buttons:TZCMsgCommonButtons);
begin
  if buttons=[] then
    buttons:=[zccbOK];
end;

function getMsgID(MsgStr:TZCMsgStr):TZCMsgId;
var
  quoted:boolean;
  count,i,j:integer;
begin
  result:='';
  quoted:=false;
  count:=0;
  for i:=1 to length(MsgStr) do begin
    if MsgStr[i]='"' then quoted:=not quoted;
    if not quoted then inc(count);
  end;
  setlength(result,count);
  quoted:=false;
  j:=1;
  for i:=1 to length(MsgStr) do begin
    if MsgStr[i]='"' then quoted:=not quoted;
    if not quoted then begin
      result[j]:=MsgStr[i];
      inc(j);
    end;
  end;
end;

class function TGSetConverter<TGEnumIn,TGSetIn,TGEnumOut,TGSetOut,TGEnumConverter>.Convert(value:TGSetIn):TGSetOut;
var
 CurrentEnumIn:TGEnumIn;
 CurrentEnumOut:TGEnumOut;
 tvalue:TGSetIn;
begin
  result:=[];
  CurrentEnumOut:=Default(TGEnumOut);
  for CurrentEnumIn:=low(TGEnumIn) to high(TGEnumIn) do begin
    tvalue:=value-[CurrentEnumIn];
    if tvalue<>value then begin
      if TGEnumConverter.TryConvert(CurrentEnumIn,CurrentEnumOut) then
        result:=result+[CurrentEnumOut];
      if tvalue=[] then exit;
      value:=tvalue;
    end;
  end;
end;

class function TGConverter<TGIn,TGOut,TGConverter>.TryConvert(valueIn:TGIn; out valueOut:TGOut):boolean;
begin
  result:=TGConverter.Tryconvert(valueIn,valueOut);
end;

{class function TGConverter<TGIn,TGOut,TGConverter>.Convert(valueIn:TGIn;Converted:Boolean):TGOut;overload;
begin
  Converted:=TGConverter.convert(valueIn,result);
end;}

class function TGConverter<TGIn,TGOut,TGConverter>.Convert(valueIn:TGIn):TGOut;overload;
begin
  TGConverter.Tryconvert(valueIn,result);
end;

begin
end.
