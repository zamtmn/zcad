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
uses LCLProc,LazUTF8,Classes,gzctnrVector,sysutils,uzbtypes,
     uzegeometry,gzctnrVectorObjects,
     gzctnrVectorTypes,uzbstrproc,uzeStylesLineTypes,uzegeometrytypes,
     uzctnrVectorBytes,
     uzeffdxfsupport,uzMVReader,
     Math;
type
{EXPORT+}
  PTPatStrokesArray=^TPatStrokesArray;
  TPatStrokesArray=object(TStrokesArray)
    fAngle:Double;
    //fDir:GDBVertex2D;

    Base,Offset:GDBVertex2D;

    //procedure setAngle(AAngle:Double);

    constructor init(m:Integer);
    property Angle:Double read fAngle write fAngle{setAngle};
    function CopyTo(var dest:GZVector<Double>):Integer;virtual;
  end;

  PTHatchPattern=^THatchPattern;
  THatchPattern=object(GZVectorObjects<TPatStrokesArray>)
    procedure SaveToDXF(var outhandle:TZctnrVectorBytes;const MainAngle,MainScale:Double);
  end;
{EXPORT-}

function LoadPatternFromDXF(var PPattern:PTHatchPattern;var f:TZMemReader;DXFCode:Integer;const MainAngle,MainScale:Double):Boolean;

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
  inherited;
  if IsIt(TypeOf(dest),TypeOf(TPatStrokesArray)) then begin
    PTPatStrokesArray(@dest)^.fAngle:=fAngle;
    PTPatStrokesArray(@dest)^.Base:=Base;
    PTPatStrokesArray(@dest)^.Offset:=Offset;
  end;

end;

procedure THatchPattern.SaveToDXF(var outhandle:TZctnrVectorBytes;const MainAngle,MainScale:Double);
var
   i,j: Integer;
   //pv:PGDBvertex2D;
   psa:PTPatStrokesArray;
   angle:Double;
   sinA,cosA:Double;
begin
  dxfIntegerout(outhandle,78,Count);
  for i:=0 to Count-1 do begin
    psa:=getDataMutable(i);
    dxfDoubleout(outhandle,53,psa^.Angle+MainAngle);
    dxfDoubleout(outhandle,43,psa^.Base.x*MainScale);
    dxfDoubleout(outhandle,44,psa^.Base.y*MainScale);

    angle:=DegToRad(MainAngle);
    SinCos(angle,sinA,cosA);

    dxfDoubleout(outhandle,45,(psa^.offset.x*cosA-psa^.offset.y*sinA)*MainScale);
    dxfDoubleout(outhandle,46,(psa^.offset.y*cosA+psa^.offset.x*sinA)*MainScale);
    dxfIntegerout(outhandle,79,psa^.Count);
    for j:=0 to psa^.Count-1 do begin
      dxfDoubleout(outhandle,49,psa^.getData(j)*MainScale);
    end;
  end;
end;


function LoadPatternFromDXF(var PPattern:PTHatchPattern;var f:TZMemReader;DXFCode:Integer;const MainAngle,MainScale:Double):Boolean;
var
  i,j,patternscount,dashcount:Integer;
  angle,dash:Double;
  sinA,cosA:Double;
  base,offset:GDBvertex2D;
  psa:PTPatStrokesArray;
begin
  result:=dxfIntegerload(f,78,DXFCode,patternscount);
  if result then begin
    DXFCode:=f.ParseInteger;
    for i:=1 to patternscount do begin
      if dxfdoubleload(f,53,DXFCode,angle) then DXFCode:=f.ParseInteger;
      if dxfdoubleload(f,43,DXFCode,base.x) then DXFCode:=f.ParseInteger;
      if dxfdoubleload(f,44,DXFCode,base.y) then DXFCode:=f.ParseInteger;
      if dxfdoubleload(f,45,DXFCode,offset.x) then DXFCode:=f.ParseInteger;
      if dxfdoubleload(f,46,DXFCode,offset.y) then DXFCode:=f.ParseInteger;

      if PPattern=nil then begin
        PPattern:=GetMem(sizeof(THatchPattern));
        PPattern^.init(patternscount);
      end;

      if dxfintegerload(f,79,DXFCode,dashcount) then DXFCode:=f.ParseInteger;
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
        if dxfdoubleload(f,49,DXFCode,dash) then begin
          psa^.PushBackData(dash/MainScale);
          DXFCode:=f.ParseInteger;
        end;
      end;
      psa^.format;
      result:=false;
    end;
  end;
end;

begin
end.
