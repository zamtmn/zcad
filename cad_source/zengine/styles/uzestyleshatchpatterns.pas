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

unit uzeStylesHatchPatterns;
{$INCLUDE zengineconfig.inc}
interface
uses
  LCLProc,LazUTF8,Classes,gzctnrVector,SysUtils,
  uzbBaseUtils,
  uzegeometry,gzctnrVectorObjects,
  gzctnrVectorTypes,uzeStylesLineTypes,uzegeometrytypes,
  uzctnrVectorBytesStream,
  uzeffdxfsupport,uzMVReader,
  Math;
type
  PTPatStrokesArray=^TPatStrokesArray;
  TPatStrokesArray=object(TStrokesArray)
    fAngle:Double;
    //fDir:GDBVertex2D;

    Base,Offset:TzePoint2d;

    //procedure setAngle(AAngle:Double);

    constructor init(m:Integer);
    property Angle:Double read fAngle write fAngle{setAngle};
    function CopyTo(var dest:GZVector<Double>):Integer;virtual;
  end;

  PTHatchPattern=^THatchPattern;
  THatchPattern=object(GZVectorObjects<TPatStrokesArray>)
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;const MainAngle,MainScale:Double);
  end;

function LoadPatternFromDXF(var PPattern:PTHatchPattern;var rdr:TZMemReader;DXFCode:Integer;const MainAngle,MainScale:Double):Boolean;

implementation

{procedure TPatStrokesArray.setAngle(AAngle:Double);
var
  rAngle:Double;
begin
  fAngle:=AAngle;
  rAngle:=DegToRad(AAngle);
  fDir.x:=cos(rAngle);
  fDir.y:=Sin(rAngle);
end;}

constructor TPatStrokesArray.init(m:Integer);
begin
  inherited;
  Angle:=0;
  Base:=NulVertex2D;
  Offset:=YWCS2D;
end;
function TPatStrokesArray.CopyTo(var dest:GZVector<Double>):Integer;
begin
  result:=inherited;
  if IsObjectIt(TypeOf(dest),TypeOf(TPatStrokesArray)) then begin
    PTPatStrokesArray(@dest)^.fAngle:=fAngle;
    PTPatStrokesArray(@dest)^.Base:=Base;
    PTPatStrokesArray(@dest)^.Offset:=Offset;
  end;

end;

procedure THatchPattern.SaveToDXF(var outStream:TZctnrVectorBytes;const MainAngle,MainScale:Double);
var
   i,j: Integer;
   //pv:PGDBvertex2D;
   psa:PTPatStrokesArray;
   angle:Double;
   sinA,cosA:Double;
begin
  dxfIntegerout(outStream,78,Count);
  for i:=0 to Count-1 do begin
    psa:=getDataMutable(i);
    dxfDoubleout(outStream,53,psa^.Angle+MainAngle);
    dxfDoubleout(outStream,43,psa^.Base.x*MainScale);
    dxfDoubleout(outStream,44,psa^.Base.y*MainScale);

    angle:=DegToRad(MainAngle);
    SinCos(angle,sinA,cosA);

    dxfDoubleout(outStream,45,(psa^.offset.x*cosA-psa^.offset.y*sinA)*MainScale);
    dxfDoubleout(outStream,46,(psa^.offset.y*cosA+psa^.offset.x*sinA)*MainScale);
    dxfIntegerout(outStream,79,psa^.Count);
    for j:=0 to psa^.Count-1 do begin
      dxfDoubleout(outStream,49,psa^.getData(j)*MainScale);
    end;
  end;
end;


function LoadPatternFromDXF(var PPattern:PTHatchPattern;var rdr:TZMemReader;DXFCode:Integer;const MainAngle,MainScale:Double):Boolean;
var
  i,j,patternscount,dashcount:Integer;
  angle,dash:Double;
  sinA,cosA:Double;
  base,offset:TzePoint2d;
  psa:PTPatStrokesArray;
begin
  result:=dxfLoadGroupCodeInteger(rdr,78,DXFCode,patternscount);
  if result then begin
    DXFCode:=rdr.ParseInteger;
    for i:=1 to patternscount do begin
      if dxfLoadGroupCodeDouble(rdr,53,DXFCode,angle) then DXFCode:=rdr.ParseInteger;
      if dxfLoadGroupCodeDouble(rdr,43,DXFCode,base.x) then DXFCode:=rdr.ParseInteger;
      if dxfLoadGroupCodeDouble(rdr,44,DXFCode,base.y) then DXFCode:=rdr.ParseInteger;
      if dxfLoadGroupCodeDouble(rdr,45,DXFCode,offset.x) then DXFCode:=rdr.ParseInteger;
      if dxfLoadGroupCodeDouble(rdr,46,DXFCode,offset.y) then DXFCode:=rdr.ParseInteger;

      if PPattern=nil then begin
        PPattern:=GetMem(sizeof(THatchPattern));
        PPattern^.init(patternscount);
      end;

      if dxfLoadGroupCodeInteger(rdr,79,DXFCode,dashcount) then DXFCode:=rdr.ParseInteger;
      psa:=PPattern^.CreateObject;
      psa^.init(dashcount);
      psa^.Angle:=angle-MainAngle;

      angle:=DegToRad(MainAngle);
      SinCos(-angle,sinA,cosA);
      psa^.Base.x:=base.x/MainScale;
      psa^.Base.y:=base.y/MainScale;

      psa^.Offset.x:=(offset.x*cosA-offset.y*sinA)/MainScale;
      psa^.Offset.y:=(offset.y*cosA+offset.x*sinA)/MainScale;
      //psa^.Offset:=offset;

      for j:=1 to dashcount do begin
        if dxfLoadGroupCodeDouble(rdr,49,DXFCode,dash) then begin
          psa^.PushBackData(dash/MainScale);
          DXFCode:=rdr.ParseInteger;
        end;
      end;
      psa^.format;
      result:=false;
    end;
  end;
end;

begin
end.
