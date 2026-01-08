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

unit uzctnrVectorStrings;

interface
uses gzctnrVectorTypes,gzctnrVectorStr,sysutils,uzctnrVectorPointers;
type

    PTZctnrVectorStrings=^TZctnrVectorStrings;
    TZctnrVectorStrings=object(GZVectorStr<String>)
    end;
    TZctnrVectorUnicodeStrings=object(GZVectorStr<UnicodeString>)
    end;
    PTEnumData=^TEnumData;
    TEnumData=record
                    Selected:Integer;
                    Enums:TZctnrVectorStrings;
              end;
    PTEnumDataWithOtherPointers=^TEnumDataWithOtherPointers;
    TEnumDataWithOtherPointers=record
                    Selected:Integer;
                    Enums:TZctnrVectorStrings;
                    Pointers:TZctnrVectorPointer;
              end;
    PTEnumDataWithOtherStrings=^TEnumDataWithOtherStrings;
    TEnumDataWithOtherStrings=record
                    Selected:Integer;
                    Enums:TZctnrVectorStrings;
                    Strings:TZctnrVectorStrings;
              end;

implementation
begin
end.

