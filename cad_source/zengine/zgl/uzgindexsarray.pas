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

unit uzgindexsarray;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,gzctnrvectordata,sysutils,uzbtypes,uzbmemman,
     gzctnrvectortypes,uzegeometry;
type
{Export+}
PZGLIndexsArray=^ZGLIndexsArray;
{REGISTEROBJECTTYPE ZGLIndexsArray}
ZGLIndexsArray= object(GZVectorData{-}<TArrayIndex>{//})(*OpenArrayOfData=TArrayIndex*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
             end;
{Export-}
implementation
//uses {glstatemanager,}log;
constructor ZGLIndexsArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,sizeof(TArrayIndex)});
end;
constructor ZGLIndexsArray.initnul;
begin
  inherited initnul;
  //size:=sizeof(TArrayIndex);
end;
begin
end.

