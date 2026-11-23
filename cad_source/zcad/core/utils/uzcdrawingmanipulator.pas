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
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
unit uzcDrawingManipulator;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeutils,LCLProc,uzepalette,uzeentityfactory,
  uzgldrawcontext,uzcdrawing,uzestyleslinetypes,uzcsysvars,uzestyleslayers,
  SysUtils,uzeTypes,uzsbVarmanDef,uzeconsts,
  UGDBVisibleOpenArray,uzeentgenericsubentry,uzeentity,uzegeometrytypes,
  uzeentblockinsert,uzcinterface,
  uzeentdevice,uzeentline,uzbBaseUtils,uzcutils,uzeEntSpline,uzeEntTable,uzestylestables;

type
  TDrawingAction=(DBRedraw,DBUndo);
  TDrawingBehavior=set of TDrawingAction;

  TDrawingContextOptions=record
  private
    fBehavior:TDrawingBehavior;
    fEnadleRedrawCounter:integer;
  public
    constructor CreateRec(ABhv:TDrawingBehavior);
    function NeedRedaraw:Boolean;
    function NeedUndo:Boolean;
    function BehaviorSetReset(const ASetBhv,AReSetBhv:TDrawingBehavior):TDrawingBehavior;

    property Behavior:TDrawingBehavior read fBehavior write fBehavior;
  end;

  TDrawingManipulator=class
  private
    fRoot:PGDBObjGenericSubEntry;
    fOptions:TDrawingContextOptions;
    fDWG:PTZCADDrawing;
  public
    constructor Create;

    procedure AddEntityToDWG(const AEnt:PGDBObjEntity);
    function AddLine(const APt1,APt2:TzePoint3d):PGDBObjLine;
    function AddSpline(const ADegree:integer;const AClosed:boolean;APts:array of TzePoint3d;
      AKts:array of Single):PGDBObjSpline;
    function AddZTable(APTStyle:PTGDBTableStyle):PGDBObjTable;
    procedure ZTableAddRow(APTable:PGDBObjTable;ARow:array of string;ANeedBuild:boolean=false);

    procedure EnadleRedraw;
    procedure DisableRedraw;

    procedure setDWG(AOptions:TDrawingContextOptions;var ADWG:TZCADDrawing;ARoot:PGDBObjGenericSubEntry);
    property DWG:PTZCADDrawing read fDWG write fDWG;
    property Root:PGDBObjGenericSubEntry read fRoot write fRoot;
    property Options:TDrawingContextOptions read fOptions write fOptions;
  end;

implementation

constructor TDrawingContextOptions.CreateRec(ABhv:TDrawingBehavior);
begin
  fEnadleRedrawCounter:=1;
  fBehavior:=ABhv;
end;

function TDrawingContextOptions.NeedRedaraw:Boolean;
begin
  if DBRedraw in fBehavior then
    result:=fEnadleRedrawCounter>0
  else
    result:=false;
end;
function TDrawingContextOptions.NeedUndo:Boolean;
begin
  result:=DBUndo in fBehavior;
end;
function TDrawingContextOptions.BehaviorSetReset(const ASetBhv,AReSetBhv:TDrawingBehavior):TDrawingBehavior;
begin
  Result:=fBehavior;
  fBehavior:=fBehavior+ASetBhv;
  fBehavior:=fBehavior-AReSetBhv;
end;

constructor TDrawingManipulator.Create;
begin
  fOptions:=TDrawingContextOptions.CreateRec([]);
  fDWG:=nil;
  fRoot:=nil;
end;

procedure TDrawingManipulator.setDWG(AOptions:TDrawingContextOptions;var ADWG:TZCADDrawing;ARoot:PGDBObjGenericSubEntry);
 begin
  fOptions:=AOptions;
  fDWG:=@ADWG;
  fRoot:=ARoot;
end;

procedure TDrawingManipulator.EnadleRedraw;
begin
  inc(fOptions.fEnadleRedrawCounter);
end;

procedure TDrawingManipulator.DisableRedraw;
begin
  dec(fOptions.fEnadleRedrawCounter);
end;

procedure TDrawingManipulator.AddEntityToDWG(const AEnt:PGDBObjEntity);
begin
  //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
  zeSetEntPropFromDrawingProp(AEnt,DWG^);
  //zcSetEntPropFromCurrentDrawingProp(pline);

  //добавляем в чертеж
  if fOptions.NeedUndo then
    zcAddEntToDrawingWithUndo(AEnt,DWG^)
  else begin
    if Root=nil then
      zcAddEntToDrawingWithOutUndo(AEnt,DWG^)
    else begin
      if IsObjectIt(typeof(Root^),typeof(GDBObjDevice)) then begin
        PGDBObjDevice(Root).VarObjArray.AddPEntity(AEnt^)
      end else begin
        Root^.GoodAddObjectToObjArray(AEnt);
      end;
      AEnt^.YouChanged(DWG^);
    end;
  end;

  //перерисовываем
  if fOptions.NeedRedaraw then
    zcRedrawCurrentDrawing;
end;


function TDrawingManipulator.AddLine(const APt1,APt2:TzePoint3d):PGDBObjLine;
begin
  result:=AllocEnt(GDBLineID);
  result^.init(Root,nil,LnWtByLayer,APt1,APt2);
  AddEntityToDWG(result);
end;

function TDrawingManipulator.AddSpline(const ADegree:integer;const AClosed:boolean;
  APts:array of TzePoint3d;AKts:array of Single):PGDBObjSpline;
var
  i:integer;
begin
  result:=AllocEnt(GDBSplineID);
  result^.init(Root,nil,LnWtByLayer,AClosed);

  result^.Degree:=ADegree;

  result^.vertexarrayinocs.SetCount(length(APts));
  for i:=low(APts) to high(APts) do
    result^.vertexarrayinocs.getDataMutable(i)^:=APts[i];

  result^.Knots.SetCount(length(AKts));
  for i:=low(AKts) to high(AKts) do
    result^.Knots.getDataMutable(i)^:=AKts[i];

  AddEntityToDWG(result);
end;

function TDrawingManipulator.AddZTable(APTStyle:PTGDBTableStyle):PGDBObjTable;
begin
  Getmem(result,sizeof(GDBObjTable));
  result^.initnul;
  result^.bp.ListPos.Owner:=Root;
  result^.ptablestyle:=APTStyle;
  result^.tbl.free;
  AddEntityToDWG(result);
end;

procedure TDrawingManipulator.ZTableAddRow(APTable:PGDBObjTable;ARow:array of string;ANeedBuild:boolean=false);
 var
  i:integer;
  psl:PDXFEntsInternalVectorStrings;
  DC:TDrawContext;
begin
  psl:=APTable^.tbl.CreateObject;
  psl.init(length(ARow));
  for i:=low(ARow) to high(ARow) do
    psl^.PushBackData(ARow[i]);
  if ANeedBuild then begin
    APTable^.Build(DWG^);
    dc:=DWG^.CreateDrawingRC;
    APTable^.FormatEntity(DWG^,dc);
  end;
end;

begin
end.
