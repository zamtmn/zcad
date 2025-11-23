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
{$mode delphi}
unit uzcCommand_Duplicate;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  SysUtils,
  LCLType,LazUTF8,Clipbrd,
  uzbpaths,
  uzeentity,
  uzeffdxf,
  gzctnrVectorTypes,
  uzcdrawings,
  uzcstrconsts,
  uzccommandsabstract,uzccommandsimpl,UGDBVisibleOpenArray,
  uzegeometry,uzegeometrytypes,uzcinterface,uzccommandsmanager,
  uzcCommand_Copy,uzglviewareadata;

type
  duplicade_com=object(copy_com)
    procedure CommandStart(const Context:TZCADCommandContext;
      Operands:TCommandOperands);virtual;
    //function CalcTransformMatrix(p1,p2: GDBvertex):TzeTypedMatrix4d; virtual;
    function AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
      mc:TzePoint2i;var button:byte;osp:pos_record):integer;virtual;
    constructor init(cn:string;SA,DA:TCStartAttr);
  end;

var
  duplicade:duplicade_com;

function GetSelectedEntsAABB(constref ObjArray:GDBObjEntityOpenArray;
  out SelectedAABB:TBoundingBox):boolean;

implementation

function GetSelectedEntsAABB(constref ObjArray:GDBObjEntityOpenArray;
  out SelectedAABB:TBoundingBox):boolean;
var
  pobj:pGDBObjEntity;
  ir:itrec;
begin
  Result:=False;
  SelectedAABB:=default(TBoundingBox);

  pobj:=ObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj.selected then begin
        if Result then
          ConcatBB(SelectedAABB,pobj.vp.BoundingBox)
        else
          SelectedAABB:=pobj.vp.BoundingBox;
        Result:=True;
      end;
      pobj:=ObjArray.iterate(ir);
    until pobj=nil;
end;

constructor duplicade_com.init(cn:string;SA,DA:TCStartAttr);
begin
  inherited;
  CEndActionAttr:=CEndActionAttr-[CEDeSelect];
end;

procedure duplicade_com.CommandStart(const Context:TZCADCommandContext;
  Operands:TCommandOperands);
var
  SelectedAABB:TBoundingBox;
begin
  inherited;
  if drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.GetRealCount>0 then begin
    GetSelectedEntsAABB(drawings.GetCurrentROOT.ObjArray,SelectedAABB);
    t3dp:=SelectedAABB.LBN;
    Inc(mouseclic);
    SimulateMouseMove(Context);
  end else begin
    zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;

function duplicade_com.AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record):integer;
begin
  Result:=inherited;
  if (button and MZW_LBUTTON)<>0 then
    Commandmanager.executecommandend;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  duplicade.init('Duplicate',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
