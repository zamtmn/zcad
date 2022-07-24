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
uses gzctnrVectorTypes,{uzbtypes,}gzctnrVectorStr,sysutils;
type
{EXPORT+}
    PTZctnrVectorStrings=^TZctnrVectorStrings;
    {REGISTEROBJECTTYPE TZctnrVectorStrings}
    TZctnrVectorStrings=object(GZVectorStr{-}<String>{//})(*OpenArrayOfData=String*)
    end;
    {REGISTEROBJECTTYPE TZctnrVectorUnicodeStrings}
    TZctnrVectorUnicodeStrings=object(GZVectorStr{-}<UnicodeString>{//})(*OpenArrayOfData=TZctnrVectorUnicodeString*)
    end;
    PTEnumData=^TEnumData;
    {REGISTERRECORDTYPE TEnumData}
    TEnumData=record
                    Selected:Integer;
                    Enums:TZctnrVectorStrings;
              end;
    PTEnumDataWithOtherData=^TEnumDataWithOtherData;
    {REGISTERRECORDTYPE TEnumDataWithOtherData}
    TEnumDataWithOtherData=record
                    Selected:Integer;
                    Enums:TZctnrVectorStrings;
                    PData:Pointer;
              end;
{EXPORT-}
implementation
begin
end.

