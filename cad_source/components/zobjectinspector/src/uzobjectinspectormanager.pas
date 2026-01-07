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

unit uzObjectInspectorManager;

{$MODE DELPHI}

interface

uses
  SysUtils,
  Graphics,
  uzbtypes,uzbUsable;
type
  TUsableInteger=GUsable<integer>;
  PTUsableInteger=^TUsableInteger;

  TObjInspsManager=object
    private
      fPropertyRowName:string;
      fValueRowName:string;
      fDifferentName:string;

      fOpenNodeIdent:integer;
      fDefaultRowHeight:integer;
      fWhiteBackground:boolean;
      fShowHeaders:boolean;
      fShowSeparator:boolean;
      fOldStyleDraw:boolean;
      fShowFastEditors:boolean;
      fShowOnlyHotFastEditors:boolean;
      fRowHeightOverride:TUsableInteger;
      fLevel0HeaderColor:TColor;
      fBorderColor:TColor;
      fButtonSizeReducing:integer;
      fShowEmptySections:boolean;
    public
      function getOpenNodeIdent:integer;
      procedure setOpenNodeIdent(const AValue:integer);

      function getDefaultRowHeight:integer;
      procedure setDefaultRowHeight(const AValue:integer);

      function getWhiteBackground:boolean;
      procedure setWhiteBackground(const AValue:boolean);

      function getShowHeaders:boolean;
      procedure setShowHeaders(const AValue:boolean);

      function getShowSeparator:boolean;
      procedure setShowSeparator(const AValue:boolean);

      function getOldStyleDraw:boolean;
      procedure setOldStyleDraw(const AValue:boolean);

      function getShowFastEditors:boolean;
      procedure setShowFastEditors(const AValue:boolean);

      function getShowOnlyHotFastEditors:boolean;
      procedure setShowOnlyHotFastEditors(const AValue:boolean);

      function getRowHeightOverride:TUsableInteger;
      procedure setRowHeightOverride(const AValue:TUsableInteger);
      function getRowHeightOverrideValue:integer;
      procedure setRowHeightOverrideValue(const AValue:integer);
      function getRowHeightOverrideUsable:boolean;
      procedure setRowHeightOverrideUsable(const AValue:boolean);

      function getLevel0HeaderColor:TColor;
      procedure setLevel0HeaderColor(const AValue:TColor);

      function getBorderColor:TColor;
      procedure setBorderColor(const AValue:TColor);

      function getButtonSizeReducing:integer;
      procedure setButtonSizeReducing(const AValue:integer);

      function getShowEmptySections:boolean;
      procedure setShowEmptySections(const AValue:boolean);


      constructor Init;
      destructor Done;virtual;

      property PropertyRowName:string read fPropertyRowName write fPropertyRowName;
      property ValueRowName:string read fValueRowName write fValueRowName;
      property DifferentName:string read fDifferentName write fDifferentName;

      property INTFObjInspSpaceHeight:integer read getOpenNodeIdent write setOpenNodeIdent;
      property INTFObjInspWhiteBackground:boolean read getWhiteBackground write setWhiteBackground;
      property INTFObjInspShowHeaders:boolean read getShowHeaders write setShowHeaders;
      property INTFObjInspShowSeparator:boolean read getShowSeparator write setShowSeparator;
      property INTFObjInspOldStyleDraw:boolean read getOldStyleDraw write setOldStyleDraw;
      property INTFObjInspShowFastEditors:boolean read getShowFastEditors write setShowFastEditors;
      property INTFObjInspShowOnlyHotFastEditors:boolean read getShowOnlyHotFastEditors write setShowOnlyHotFastEditors;
      property INTFObjInspLevel0HeaderColor:TColor read getLevel0HeaderColor write setLevel0HeaderColor;
      property INTFObjInspBorderColor:TColor read getBorderColor write setBorderColor;
      property INTFObjInspButtonSizeReducing:Integer  read getButtonSizeReducing write setButtonSizeReducing;
      property INTFObjInspShowEmptySections:boolean read getShowEmptySections write setShowEmptySections;

      property DefaultRowHeight:integer read getDefaultRowHeight write setDefaultRowHeight;
      property RowHeightOverride:TUsableInteger read getRowHeightOverride write setRowHeightOverride;
  end;

var
  OIManager:TObjInspsManager;

implementation
function TObjInspsManager.getOpenNodeIdent:integer;
begin
  result:=fOpenNodeIdent;
end;
procedure TObjInspsManager.setOpenNodeIdent(const AValue:integer);
begin
  fOpenNodeIdent:=AValue;
end;

function TObjInspsManager.getDefaultRowHeight:integer;
begin
  result:=fDefaultRowHeight;
end;
procedure TObjInspsManager.setDefaultRowHeight(const AValue:integer);
begin
  fDefaultRowHeight:=AValue;
end;

function TObjInspsManager.getButtonSizeReducing:integer;
begin
  result:=fButtonSizeReducing;
end;
procedure TObjInspsManager.setButtonSizeReducing(const AValue:integer);
begin
  fButtonSizeReducing:=AValue;
end;

function TObjInspsManager.getWhiteBackground:boolean;
begin
  result:=fWhiteBackground;
end;
procedure TObjInspsManager.setWhiteBackground(const AValue:boolean);
begin
  fWhiteBackground:=AValue;
end;

function TObjInspsManager.getShowHeaders:boolean;
begin
  result:=fShowHeaders;
end;
procedure TObjInspsManager.setShowHeaders(const AValue:boolean);
begin
  fShowHeaders:=AValue;
end;

function TObjInspsManager.getShowSeparator:boolean;
begin
  result:=fShowSeparator;
end;
procedure TObjInspsManager.setShowSeparator(const AValue:boolean);
begin
  fShowSeparator:=AValue;
end;

function TObjInspsManager.getOldStyleDraw:boolean;
begin
  result:=fOldStyleDraw;
end;
procedure TObjInspsManager.setOldStyleDraw(const AValue:boolean);
begin
  fOldStyleDraw:=AValue;
end;

function TObjInspsManager.getShowFastEditors:boolean;
begin
  result:=fShowFastEditors;
end;
procedure TObjInspsManager.setShowFastEditors(const AValue:boolean);
begin
  fShowFastEditors:=AValue;
end;

function TObjInspsManager.getShowOnlyHotFastEditors:boolean;
begin
  result:=fShowOnlyHotFastEditors;
end;
procedure TObjInspsManager.setShowOnlyHotFastEditors(const AValue:boolean);
begin
  fShowOnlyHotFastEditors:=AValue;
end;

function TObjInspsManager.getRowHeightOverride:TUsableInteger;
begin
  result:=fRowHeightOverride;
end;
procedure TObjInspsManager.setRowHeightOverride(const AValue:TUsableInteger);
begin
  fRowHeightOverride:=AValue;
end;
function TObjInspsManager.getRowHeightOverrideValue:integer;
begin
  result:=fRowHeightOverride.Value;
end;
procedure TObjInspsManager.setRowHeightOverrideValue(const AValue:integer);
begin
  fRowHeightOverride.Value:=AValue;
end;
function TObjInspsManager.getRowHeightOverrideUsable:boolean;
begin
  result:=fRowHeightOverride.Usable;
end;
procedure TObjInspsManager.setRowHeightOverrideUsable(const AValue:boolean);
begin
  fRowHeightOverride.Usable:=AValue;
end;

function TObjInspsManager.getLevel0HeaderColor:TColor;
begin
  result:=fLevel0HeaderColor;
end;
procedure TObjInspsManager.setLevel0HeaderColor(const AValue:TColor);
begin
  fLevel0HeaderColor:=AValue;
end;

function TObjInspsManager.getBorderColor:TColor;
begin
  result:=fBorderColor;
end;
procedure TObjInspsManager.setBorderColor(const AValue:TColor);
begin
  fBorderColor:=AValue;
end;

function TObjInspsManager.getShowEmptySections:boolean;
begin
  result:=fShowEmptySections;
end;
procedure TObjInspsManager.setShowEmptySections(const AValue:boolean);
begin
  fShowEmptySections:=AValue;
end;


constructor TObjInspsManager.Init;
begin
  fPropertyRowName:='Property';
  fValueRowName:='Value';
  fDifferentName:='Different';
  fRowHeightOverride.value:=21;
  fRowHeightOverride.Usable:=false;

  fWhiteBackground:=false;
  fShowHeaders:=true;
  fShowSeparator:=true;
  fOldStyleDraw:=false;
  fShowFastEditors:=true;
  fShowOnlyHotFastEditors:=true;
  fDefaultRowHeight:=21;
  fLevel0HeaderColor:=clDefault;
  fBorderColor:=clDefault;
  fOpenNodeIdent:=0;
  fButtonSizeReducing:=4;
  fShowEmptySections:=false;
end;
destructor TObjInspsManager.Done;
begin
end;

initialization
  OIManager.Init;
finalization
  OIManager.Done;
end.
