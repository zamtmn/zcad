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

unit uzcoiwrapper;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzbtypes,uzclog;
type
{Export+}
  {REGISTEROBJECTTYPE TWrapper2ObjInsp}
  TWrapper2ObjInsp= object(GDBaseObject)
  end;
{Export-}
implementation
initialization
end.
