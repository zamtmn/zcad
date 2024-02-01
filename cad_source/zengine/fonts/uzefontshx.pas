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

unit uzefontshx;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzefontbase,uzctnrVectorBytes,sysutils,uzegeometry;
type
  SHXFont= class(BASEFont)
    h,u:Byte;
    constructor Create;
    destructor Destroy;override;
  end;
implementation
constructor SHXFont.Create;
begin
  inherited;
  u:=1;
  h:=1;
end;
destructor SHXFont.Destroy;
begin
  inherited;
end;
end.
