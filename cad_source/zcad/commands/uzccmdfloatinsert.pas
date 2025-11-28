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

unit uzccmdfloatinsert;
{$INCLUDE zengineconfig.inc}

interface

uses
  LCLProc,uzcLog,
  uzccommandsimpl,uzccommandsabstract,
  uzcdrawings,uzcdrawing,gzctnrVectorTypes,uzgldrawcontext,uzegeometrytypes,
  uzglviewareadata,uzeentity,uzegeometry,uzeentwithlocalcs,
  zcmultiobjectcreateundocommand,uzccommandsmanager;

type
  {EXPORT+}
  {REGISTEROBJECTTYPE FloatInsert_com}
  FloatInsert_com=object(CommandRTEdObject)
  protected
    FSelectInsertedEnts:boolean;
  public
    constructor init(cn:string;SA,DA:TCStartAttr;ASelectInsertedEnts:boolean=False);
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
      virtual;
    procedure Build(const Context:TZCADCommandContext;Operands:TCommandOperands);
      virtual;
    procedure Command(Operands:TCommandOperands);virtual;abstract;
    function DoEnd(Context:TZCADCommandContext;pdata:Pointer):boolean;virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
  end;
  {EXPORT-}

implementation

constructor FloatInsert_com.init(cn:string;SA,DA:TCStartAttr;
  ASelectInsertedEnts:boolean=False);
begin
  inherited init(cn,SA,DA);
  FSelectInsertedEnts:=ASelectInsertedEnts;
  if FSelectInsertedEnts then
    CEndActionAttr:=CEndActionAttr-[CEDeSelect];
end;

procedure FloatInsert_com.Build(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
begin
  Command(operands);
  if drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count-
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Deleted<=0 then
    commandmanager.executecommandend
  else
    SimulateMouseMove(context);
end;

procedure FloatInsert_com.CommandStart(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
begin
  inherited CommandStart(context,Operands);
  build(context,operands);
end;

function FloatInsert_com.DoEnd(Context:TZCADCommandContext;pdata:Pointer):boolean;
begin
  Result:=True;
end;

function FloatInsert_com.BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
var
  dist:TzePoint3d;
  dispmatr:TzeTypedMatrix4d;
  ir:itrec;
  tv,pobj:pGDBObjEntity;
  domethod,undomethod:tmethod;
  dc:TDrawContext;
begin
  dispmatr:=CreateTranslationMatrix(wc);
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;

  if (button and MZW_LBUTTON)<>0 then begin
    if FSelectInsertedEnts then begin
      {todo: выделение\развыделение примитивов в командах нужно кудато вынести отдельно}
      drawings.GetCurrentROOT.ObjArray.DeSelect(
        drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,
        drawings.GetCurrentDWG^.deselector);
      drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject:=nil;
      drawings.GetCurrentDWG.wa.param.SelDesc.OnMouseObject:=nil;
      drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
      drawings.GetCurrentDWG.SelObjArray.Free;
    end;

    pobj:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.beginiterate(ir);
    if pobj<>nil then
      repeat
        begin
          //if pobj^.selected then
          begin
            tv:=drawings.CopyEnt(drawings.GetCurrentDWG,drawings.GetCurrentDWG,pobj);
            if tv^.IsHaveLCS then
              PGDBObjWithLocalCS(tv)^.CalcObjMatrix;
            tv^.transform(dispmatr);
            tv^.build(drawings.GetCurrentDWG^);
            tv^.YouChanged(drawings.GetCurrentDWG^);

            SetObjCreateManipulator(domethod,undomethod);
            with PushMultiObjectCreateCommand(
                PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),
                tmethod(undomethod),1) do begin
              AddObject(tv);
              FreeArray:=False;
              //comit;
            end;

            if FSelectInsertedEnts then
              tv^.SelectQuik;

          end;
        end;
        pobj:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.iterate(ir);
      until pobj=nil;

    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    drawings.GetCurrentROOT^.calcbb(dc);

    //CopyToClipboard;

    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=onematrix;
    //commandend;
    if DoEnd(context,tv) then
      commandmanager.executecommandend;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
