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
{MODE OBJFPC}{H+}
unit uzeExtdrBaseEntityExtender;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzeExtdrAbstractEntityExtender,uzeentity;

type
  TBaseEntityExtender=class(TAbstractEntityExtender)
    protected
      fpThisEntity:PGDBObjEntity;
    public
      constructor Create(pEntity:Pointer);override;
      property pThisEntity:PGDBObjEntity read fpThisEntity{ write fpThisEntity};
  end;
implementation
constructor TBaseEntityExtender.Create(pEntity:Pointer);
begin
  fpThisEntity:=pEntity;
end;
initialization
finalization
end.

