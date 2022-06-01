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

unit uzeStylesHatchPatterns;
{$INCLUDE zengineconfig.inc}
interface
uses LCLProc,LazUTF8,Classes,gzctnrVector,sysutils,uzbtypes,
     uzegeometry,gzctnrVectorObjects,
     gzctnrVectorTypes,uzbstrproc,uzeStylesLineTypes,uzegeometrytypes,
     uzctnrVectorBytes,
     uzeffdxfsupport;
type
{EXPORT+}
  PTPatStrokesArray=^TPatStrokesArray;
  {REGISTEROBJECTTYPE TStrokesArray}
  TPatStrokesArray=object(TStrokesArray)
    Angle:Double;(*'Angle'*)
    Base,Offset:GDBVertex2D;
    constructor init(m:Integer);
  end;

  PTHatchPattern=^THatchPattern;
  THatchPattern=object(GZVectorObjects<TPatStrokesArray>)
    procedure SaveToDXF(var outhandle:TZctnrVectorBytes);
  end;
{EXPORT-}

function LoadPatternFromDXF(var PPattern:PTHatchPattern;var f:TZctnrVectorBytes;dxfcod:Integer):Boolean;

implementation

constructor TPatStrokesArray.init(m:Integer);
begin
  inherited;
  Angle:=0;
  Base:=NulVertex2D;
  Offset:=YWCS2D;
end;

procedure THatchPattern.SaveToDXF(var outhandle:TZctnrVectorBytes);
var
   i,j: Integer;
   pv:PGDBvertex2D;
   psa:PTPatStrokesArray;
begin
  dxfIntegerout(outhandle,78,Count);
  for i:=0 to Count-1 do begin
    psa:=getDataMutable(i);
    dxfDoubleout(outhandle,53,psa^.Angle);
    dxfDoubleout(outhandle,43,psa^.Base.x);
    dxfDoubleout(outhandle,44,psa^.Base.y);
    dxfDoubleout(outhandle,45,psa^.Offset.x);
    dxfDoubleout(outhandle,46,psa^.Offset.y);
    dxfIntegerout(outhandle,79,psa^.Count);
    for j:=0 to psa^.Count-1 do begin
      dxfDoubleout(outhandle,49,psa^.getData(j));
    end;
  end;
end;


function LoadPatternFromDXF(var PPattern:PTHatchPattern;var f:TZctnrVectorBytes;dxfcod:Integer):Boolean;
var
  i,j,patternscount,dashcount:Integer;
  angle,dash:Double;
  base,offset:GDBvertex2D;
  psa:PTPatStrokesArray;
begin
  result:=dxfIntegerload(f,78,dxfcod,patternscount);
  if result then begin
    dxfcod:=readmystrtoint(f);
    for i:=1 to patternscount do begin
      if dxfdoubleload(f,53,dxfcod,angle) then dxfcod:=readmystrtoint(f);
      if dxfdoubleload(f,43,dxfcod,base.x) then dxfcod:=readmystrtoint(f);
      if dxfdoubleload(f,44,dxfcod,base.y) then dxfcod:=readmystrtoint(f);
      if dxfdoubleload(f,45,dxfcod,offset.x) then dxfcod:=readmystrtoint(f);
      if dxfdoubleload(f,46,dxfcod,offset.y) then dxfcod:=readmystrtoint(f);

      if PPattern=nil then begin
        PPattern:=GetMem(sizeof(THatchPattern));
        PPattern^.init(patternscount);
      end;

      if dxfintegerload(f,79,dxfcod,dashcount) then dxfcod:=readmystrtoint(f);
      psa:=PPattern^.CreateObject;
      psa^.init(dashcount);
      psa^.Angle:=angle;
      psa^.Base:=base;
      psa^.Offset:=offset;
      for j:=1 to dashcount do begin
        if dxfdoubleload(f,49,dxfcod,dash) then begin
          psa^.PushBackData(dash);
          dxfcod:=readmystrtoint(f);
        end;
      end;
    end;
  end;
end;

begin
end.
