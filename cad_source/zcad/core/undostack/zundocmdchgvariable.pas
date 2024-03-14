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
  uzcEnitiesVariablesExtender,gzUndoCmdChgData2,
  zUndoCmdChgTypes;

type
  TChangedDataDesc=record
    PDoData,PUnDoData:Pointer;
    PTD:PUserTypeDescriptor;
    VarName:String;
    procedure UnDo(sd:TSharedPEntityData);
    procedure Comit(sd:TSharedPEntityData);
    procedure ChangeProc(sd:TSharedPEntityData);
    constructor CreateRec(APTD:PUserTypeDescriptor;AVarName:String);
    procedure DestroyRec;
    procedure StoreUndoData(APUnDoData:Pointer);
    procedure StoreDoData(APDoData:Pointer);
  end;

  UCmdChgVariable=specialize GUCmdChgData2<TChangedDataDesc,TSharedPEntityData,TAfterChangePDrawing>;

implementation

procedure TChangedDataDesc.UnDo(sd:TSharedPEntityData);
begin
  ChangeProc(sd);
end;

procedure TChangedDataDesc.Comit(sd:TSharedPEntityData);
begin
  ChangeProc(sd);
end;

procedure TChangedDataDesc.ChangeProc(sd:TSharedPEntityData);
var
  varext:TVariablesExtender;
  vd:pvardesk;
  p:pointer;
begin
  varext:=sd.Data^.specialize GetExtension<TVariablesExtender>;
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

procedure TChangedDataDesc.StoreUndoData(APUnDoData:Pointer);
begin
  PTD^.CopyInstanceTo(APUnDoData,PUnDoData);
end;
procedure TChangedDataDesc.StoreDoData(APDoData:Pointer);
begin
  PTD^.CopyInstanceTo(APDoData,PDoData);
end;

end.
