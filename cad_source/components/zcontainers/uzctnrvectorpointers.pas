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

unit uzctnrVectorPointers;

interface
uses gzctnrVectorP;
type
{Export+}
  PTZctnrVectorPointer=^TZctnrVectorPointer;
  {REGISTEROBJECTTYPE TZctnrVectorPointer}
  TZctnrVectorPointer=object(GZVectorP{-}<Pointer>{//}) //TODO:почемуто не работают синонимы с объектами, приходится наследовать
                                                        //TODO:надо тут поменять GZVectorP на GZVectorSimple
                      end;
{Export-}
implementation
begin
end.
