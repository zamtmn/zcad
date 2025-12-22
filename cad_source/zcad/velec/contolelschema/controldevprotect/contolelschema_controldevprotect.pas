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
@author(Vladimir Bobrov)
}

unit contolelschema_controldevprotect;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls;

type
  { TFrame_ControlDevProtect }
  { Фрейм для управления устройствами защиты }
  TFrame_ControlDevProtect = class(TFrame)
    LabelControlDev: TLabel;
  private

  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.lfm}

{ TFrame_ControlDevProtect }

{ Конструктор фрейма управления устройствами защиты }
constructor TFrame_ControlDevProtect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

end.
