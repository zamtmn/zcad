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

unit contolelschema_listfeeders;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls;

type
  { TFrame_listFeeders }
  { Фрейм для отображения списка фидеров }
  TFrame_listFeeders = class(TFrame)
    LabelFeeders: TLabel;
  private

  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.lfm}

{ TFrame_listFeeders }

{ Конструктор фрейма списка фидеров }
constructor TFrame_listFeeders.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

end.
