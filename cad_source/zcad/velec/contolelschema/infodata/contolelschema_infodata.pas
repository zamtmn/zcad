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

unit contolelschema_infodata;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls;

type
  { TFrame_InfoData }
  { Фрейм для отображения информационных данных }
  TFrame_InfoData = class(TFrame)
    LabelInfo: TLabel;
  private

  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.lfm}

{ TFrame_InfoData }

{ Конструктор фрейма информационных данных }
constructor TFrame_InfoData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

end.
