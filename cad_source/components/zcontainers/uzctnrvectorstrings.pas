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

unit uzctnrVectorStrings;

interface
uses gzctnrvectortypes,{uzbtypesbase,uzbtypes,}gzctnrVectorStr,sysutils;
type
{EXPORT+}
    PTZctnrVectorGDBString=^TZctnrVectorString;
    {REGISTEROBJECTTYPE TZctnrVectorString}
    TZctnrVectorString=object(GZVectorStr{-}<String>{//})(*OpenArrayOfData=GDBString*)
    end;
    {REGISTEROBJECTTYPE TZctnrVectorUnicodeString}
    TZctnrVectorUnicodeString=object(GZVectorStr{-}<UnicodeString>{//})(*OpenArrayOfData=TZctnrVectorUnicodeString*)
    end;
    PTEnumData=^TEnumData;
    {REGISTERRECORDTYPE TEnumData}
    TEnumData=record
                    Selected:Integer;
                    Enums:TZctnrVectorString;
              end;
    PTEnumDataWithOtherData=^TEnumDataWithOtherData;
    {REGISTERRECORDTYPE TEnumDataWithOtherData}
    TEnumDataWithOtherData=record
                    Selected:Integer;
                    Enums:TZctnrVectorString;
                    PData:Pointer;
              end;
{EXPORT-}
implementation
begin
end.

