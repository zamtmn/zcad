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

unit uzgeomline3d;
{$INCLUDE zengineconfig.inc}
interface
uses
     sysutils,uzbtypes,uzegeometry,uzgeomentity3d,uzegeometrytypes;
type
{Export+}
  {REGISTEROBJECTTYPE TGeomLine3D}
  TGeomLine3D=object(TGeomEntity3D)
    LineData:GDBLineProp;
    StartParam:Double;
    constructor init(const p1,p2:TzePoint3d;const sp:Double);
    function GetBB:TBoundingBox;virtual;
  end;
  {REGISTEROBJECTTYPE TGeomPLine3D}
  TGeomPLine3D=object(TGeomEntity3D)
    PLineData:PGDBLineProp;
    StartParam:Double;
    constructor init(constref LD:GDBLineProp;const sp:Double);
    function GetBB:TBoundingBox;virtual;
  end;
{Export-}
implementation
constructor TGeomLine3D.init(const p1,p2:TzePoint3d;const sp:Double);
begin
  LineData.lBegin:=p1;
  LineData.lEnd:=p2;
  StartParam:=sp;
end;
function TGeomLine3D.GetBB:TBoundingBox;
begin
  result:=CreateBBFrom2Point(LineData.lBegin,LineData.lEnd);
end;
constructor TGeomPLine3D.init(constref LD:GDBLineProp;const sp:Double);
begin
  PLineData:=@LD;
  StartParam:=sp;
end;
function TGeomPLine3D.GetBB:TBoundingBox;
begin
  result:=CreateBBFrom2Point(PLineData^.lBegin,PLineData^.lEnd);
end;
begin
end.

