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

unit zemathutils;
{$INCLUDE def.inc}

interface
uses gdbase,gdbasetypes, math;
implementation
function zeDoubleToString(const uformat:TLUnits; const uprec:TUPrec):GDBString;
begin
  case uformat of
     LUScientific:begin
                  end;
        LUDecimal:begin
                  end;
    LUEngineering:begin
                  end;
  LUArchitectural:begin
                  end;
     LUFractional:begin
                  end;
  end;
end;

end.
