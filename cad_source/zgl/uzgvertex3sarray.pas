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

unit uzgvertex3sarray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
geometry;
type
{Export+}
ZGLVertex3Sarray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBvertex3S*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                procedure DrawGeometry;virtual;
             end;
{Export-}
implementation
uses OGLSpecFunc,log;
constructor ZGLVertex3Sarray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBvertex3S));
end;
constructor ZGLVertex3Sarray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBvertex3S);
end;
procedure ZGLVertex3Sarray.drawgeometry;
var p:PGDBVertex3S;
    i:GDBInteger;
begin
  //if count<2 then exit;
  p:=parray;
  oglsm.myglbegin(GL_LINES);
  for i:=0 to count-{3}1 do
  begin
     oglsm.myglVertex3fV(@p^);
     //oglsm.myglVertex3dV(@p^);

     inc(p);
  end;
  //oglsm.myglVertex3dV(@p^);
  oglsm.myglend;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzgvertex3sarray.initialization');{$ENDIF}
end.

