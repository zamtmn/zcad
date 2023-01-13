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

unit gzctnrVectorClass;

interface
uses gzctnrVector;
type
{Export+}
{----REGISTEROBJECTTYPE GZVectorClass}
GZVectorClass{-}<T:class>{//}=object
                               (GZVector{-}<T>{//})
                                 end;
{Export-}
implementation
begin
end.
