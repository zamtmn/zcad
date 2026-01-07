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
unit uzbUsable;
{$mode delphi}

interface

uses sysutils;

type

  GUsable<T>=record
    public type
      PT=^T;
      TSelfType=GUsable<T>;
    private
      FValue:T;
      FUsable:Boolean;
    Public
      function ValueOrDefault(const ADefaultValue:T):T;
      Property Value:T  read FValue write FValue;
      Property Usable:Boolean read FUsable write FUsable;
  end;

implementation

function GUsable<T>.ValueOrDefault(const ADefaultValue:T):T;
begin
  if FUsable then
    result:=FValue
  else
    result:=ADefaultValue
end;

begin
end.
