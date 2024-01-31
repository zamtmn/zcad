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
  PSHXFont=^SHXFont;
  SHXFont= object(BASEFont)
    h,u:Byte;
    constructor init;
    destructor done;virtual;
  end;
implementation
constructor SHXFont.init;
begin
  inherited;
  u:=1;
  h:=1;
end;
destructor SHXFont.done;
begin
  inherited;
end;
end.
