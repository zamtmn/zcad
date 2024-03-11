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
{$MODE OBJFPC}{$H+}
{$ModeSwitch advancedrecords}
{$INCLUDE zengineconfig.inc}
unit zUndoCmdChgVariable;
interface
uses
  zeundostack,zebaseundocommands,uzeentity,varmandef,
  uzcEnitiesVariablesExtender,gzUndoCmdChgData2,uzedrawingdef;

type
  TSharedData=record
    PEntity:PGDBObjEntity;
    constructor CreateRec(APEntity:PGDBObjEntity);
    procedure DestroyRec;
  end;
  TChangedDataDesc=record
    PDoData,PUnDoData:Pointer;
    PTD:PUserTypeDescriptor;
    VarName:String;
    procedure UnDo(sd:TSharedData);
    procedure Comit(sd:TSharedData);
    procedure ChangeProc(sd:TSharedData);
    constructor CreateRec(APTD:PUserTypeDescriptor;AVarName:String);
    procedure DestroyRec;
    procedure StoreUndoData(APUnDoData:Pointer);
    procedure StoreDoData(APDoData:Pointer);
  end;
  TAfterChangeDataDesc=record
    PDWG:PTDrawingDef;
    procedure AfterDo(sd:TSharedData);
    constructor CreateRec(APDWG:PTDrawingDef);
    procedure DestroyRec;
  end;

  UCmdChgVariable=specialize GUCmdChgData2<TChangedDataDesc,TSharedData,TAfterChangeDataDesc>;

implementation

constructor TSharedData.CreateRec(APEntity:PGDBObjEntity);
begin
  PEntity:=APEntity;
end;
procedure TSharedData.DestroyRec;
begin
end;

procedure TChangedDataDesc.UnDo(sd:TSharedData);
begin
  ChangeProc(sd);
end;

procedure TChangedDataDesc.Comit(sd:TSharedData);
begin
  ChangeProc(sd);
end;

procedure TChangedDataDesc.ChangeProc(sd:TSharedData);
var
  varext:TVariablesExtender;
  vd:pvardesk;
  p:pointer;
begin
  varext:=sd.PEntity^.specialize GetExtension<TVariablesExtender>;
  if varext<>nil then begin
    vd:=varext.entityunit.FindVariable(VarName);
    if vd<>nil then begin
      if vd^.data.ptd=PTD then begin
        PTD^.CopyInstanceTo(PUnDoData,vd^.data.Addr.GetInstance);
      end;
    end;
  end;
  p:=PDoData;
  PDoData:=PUnDoData;
  PUnDoData:=p;
end;

constructor TChangedDataDesc.CreateRec(APTD:PUserTypeDescriptor;AVarName:String);
begin
  PTD:=APTD;
  VarName:=AVarName;
  PDoData:=PTD^.AllocAndInitInstance;
  PUnDoData:=PTD^.AllocAndInitInstance;
end;
procedure TChangedDataDesc.DestroyRec;
begin
  VarName:='';
  PTD^.MagicFreeInstance(PDoData);
  Freemem(PDoData);
  PTD^.MagicFreeInstance(PUnDoData);
  Freemem(PUnDoData);
end;

procedure TAfterChangeDataDesc.AfterDo(sd:TSharedData);
begin
  sd.PEntity^.YouChanged(PDWG^);
end;
constructor TAfterChangeDataDesc.CreateRec(APDWG:PTDrawingDef);
begin
  PDWG:=APDWG;
end;
procedure TAfterChangeDataDesc.DestroyRec;
begin
end;

procedure TChangedDataDesc.StoreUndoData(APUnDoData:Pointer);
begin
  PTD^.CopyInstanceTo(APUnDoData,PUnDoData);
end;
procedure TChangedDataDesc.StoreDoData(APDoData:Pointer);
begin
  PTD^.CopyInstanceTo(APDoData,PDoData);
end;

end.
