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
uses uzbtypesbase,gzctnrvectordata,sysutils,uzbtypes,uzbmemman,
     gzctnrvectortypes,uzbgeomtypes,uzegeometry;
type
{Export+}
PZGLVertex3Sarray=^ZGLVertex3Sarray;
{REGISTEROBJECTTYPE ZGLVertex3Sarray}
ZGLVertex3Sarray= object(GZVectorData{-}<GDBvertex3S>{//})(*OpenArrayOfData=GDBvertex3S*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                function AddGDBVertex(const v:GDBvertex):TArrayIndex;virtual;
                function GetLength(const i:TArrayIndex):GDBFloat;virtual;
             end;
{Export-}
implementation
function ZGLVertex3Sarray.GetLength(const i:TArrayIndex):GDBFloat;
var
    pv1,pv2:PGDBvertex3S;
    v:GDBvertex3S;
begin
  pv1:=self.getDataMutable(i);
  pv2:={pv1}self.getDataMutable(i+1);;
  //inc(pv2);
  v.x:=pv2.x-pv1.x;
  v.y:=pv2.y-pv1.y;
  v.z:=pv2.z-pv1.z;
  result:=v.x*v.x+v.y*v.y+v.z*v.z;
end;

function ZGLVertex3Sarray.AddGDBVertex(const v:GDBvertex):TArrayIndex;
var
    vs:GDBvertex3S;
begin
     vs.x:=v.x;
     vs.y:=v.y;
     vs.z:=v.z;
     result:=PushBackData(vs);
end;

constructor ZGLVertex3Sarray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,sizeof(GDBvertex3S)});
end;
constructor ZGLVertex3Sarray.initnul;
begin
  inherited initnul;
  //size:=sizeof(GDBvertex3S);
end;
(*procedure ZGLVertex3Sarray.drawgeometry;
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
end;*)
begin
end.

