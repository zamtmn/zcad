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

unit uzeentconnected;
{$INCLUDE def.inc}
interface
Uses uzeentity,uzeentgenericsubentry,UGDBOpenArrayOfPV,uzedrawingdef;
type
{Export+}
PGDBObjConnected=^GDBObjConnected;
{REGISTEROBJECTTYPE GDBObjConnected}
GDBObjConnected= object(GDBObjGenericSubEntry)
                      procedure addtoconnect(pobj:pgdbobjEntity;var ConnectedArray:GDBObjOpenArrayOfPV);virtual;
                      procedure connectedtogdb(ConnectedArea:PGDBObjGenericSubEntry;var drawing:TDrawingDef);virtual;abstract;
                end;
{Export-}
implementation
//uses {UGDBDescriptor,}log;
procedure GDBObjConnected.addtoconnect(pobj:pgdbobjEntity;var ConnectedArray:GDBObjOpenArrayOfPV);
begin
     ConnectedArray.PushBackIfNotPresent(pobj);
end;
begin
end.
