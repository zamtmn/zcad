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

unit GDBWithMatrix;
{$INCLUDE def.inc}

interface
uses GDBEntity,gdbase,geometry,GDBSubordinated;
type
{EXPORT+}
PGDBObjWithMatrix=^GDBObjWithMatrix;
GDBObjWithMatrix=object(GDBObjEntity)
                       ObjMatrix:DMatrix4D;(*'Матрица OCS'*)
                       constructor initnul(owner:PGDBObjGenericWithSubordinated);
                       function GetMatrix:PDMatrix4D;virtual;
                       procedure CalcObjMatrix;virtual;
                       procedure Format;virtual;
                       procedure createfield;virtual;
                 end;
{EXPORT-}
implementation
uses
    log;
procedure GDBObjWithMatrix.createfield;
begin
     inherited;
     objmatrix:=onematrix;
end;
function GDBObjWithMatrix.GetMatrix;
begin
     result:=@ObjMatrix;
end;
procedure GDBObjWithMatrix.CalcObjMatrix;
begin
     ObjMatrix:=OneMatrix;
end;
procedure GDBObjWithMatrix.Format;
begin
     CalcObjMatrix;
end;
constructor GDBObjWithMatrix.initnul;
begin
     inherited initnul(owner);
     CalcObjMatrix;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBWithMatrix.initialization');{$ENDIF}
end.
