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

unit GDBConnected;
{$INCLUDE def.inc}
interface
Uses GDBEntity,GDBGenericSubEntry{,UGDBOpenArrayOfPV};
type
{Export+}
PGDBObjConnected=^GDBObjConnected;
GDBObjConnected=object(GDBObjGenericSubEntry)
                      procedure addtoconnect(pobj:pgdbobjEntity);virtual;
                      procedure connectedtogdb;virtual;abstract;
                end;
{Export-}
implementation
uses UGDBDescriptor,log;
procedure GDBObjConnected.addtoconnect(pobj:pgdbobjEntity);
begin
     gdb.GetCurrentROOT.ObjToConnectedArray.addnodouble(@pobj);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBConnected.initialization');{$ENDIF}
end.
