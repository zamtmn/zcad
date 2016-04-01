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

unit uzctnrvector;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,sysutils,uzbtypes;
type
{Export+}
TZctnrVector{-}<T>{//}={$IFNDEF DELPHI}packed{$ENDIF}
            object(GDBaseObject)
                  {-}type{//}
                      {-}PT=^T;{//}
                      {-}TArr=array[0..0] of T;{//}
                      {-}PTArr=^TArr;{//}
                  {-}var{//}
                  PArray:{-}PTArr{/GDBPointer/};(*hidden_in_objinsp*)
                  GUID:GDBString;(*hidden_in_objinsp*)
                  Count:TArrayIndex;(*hidden_in_objinsp*)
                  Max:TArrayIndex;(*hidden_in_objinsp*)
            end;
{Export-}
implementation
begin
end.
