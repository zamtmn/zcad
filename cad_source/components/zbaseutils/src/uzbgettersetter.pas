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
unit uzbGetterSetter;
{$mode delphi}

interface

uses sysutils;

type

  GGetterSetter<T>=record
    type
      TGetter=function:T of object;
      TSetter=procedure(const AValue:T) of object;
    var
      Getter:TGetter;
      Setter:TSetter;
    procedure Setup(const AGetter:TGetter;const ASetter:TSetter);
  end;

implementation

procedure GGetterSetter<T>.Setup(const AGetter:TGetter;const ASetter:TSetter);
begin
  Getter:=AGetter;
  Setter:=ASetter;
end;

begin
end.
