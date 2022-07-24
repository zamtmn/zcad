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

unit gzctnrVectorPObjects;

interface
uses gzctnrVectorPData,gzctnrVector,
     typinfo;
type
{Export+}
{------------REGISTEROBJECTTYPE GZVectorPObects}
GZVectorPObects{-}<PTObj,TObj>{//}
                             =object(GZVectorPData{-}<PTObj>{//})
                             function CreateObject:PTObj;
                end;
{Export-}
implementation
function GZVectorPObects<PTObj,TObj>.CreateObject;
begin
  Getmem(result,sizeof(TObj));
  if PTypeInfo(TypeInfo(TObj))^.kind in TypesNeedToInicialize
          then fillchar(pointer(result)^,sizeof(TObj),0);
  PushBackData(result);
end;
begin
end.
