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

unit uzeEntBase;
{$Mode objfpc}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeTypes,uzedrawingdef,uzgldrawcontext,
  SysUtils;

type

  PGDBObjBaseEntity=^GDBObjBaseEntity;

  GDBObjBaseEntity=object
    destructor Done;virtual;abstract;
    function GetObjType:TObjID;virtual;abstract;
    constructor initnul;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;abstract;
    procedure FormatAfterEdit(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;abstract;
  end;

implementation

constructor GDBObjBaseEntity.initnul;
begin
end;

begin
end.
