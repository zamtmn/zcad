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
    PUnDoData:Pointer;
    PTD:PUserTypeDescriptor;
    VarName:String;
    procedure UnDo(sd:TSharedPEntityData);
    procedure Comit(sd:TSharedPEntityData);
    procedure ChangeProc(sd:TSharedPEntityData);
    constructor CreateRec(APTD:PUserTypeDescriptor;APValue:Pointer;AVarName:String);
    procedure DestroyRec;
    procedure StoreUndoData(APUnDoData:Pointer);
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

procedure MyXchange(const source;var dest;count:SizeInt);
var
  tbuf:QWord;
  i:integer;
begin
  case count of
    sizeof(Byte):begin
      pByte(@tbuf)^:=pByte(@source)^;
      pByte(@source)^:=pByte(@dest)^;
      pByte(@dest)^:=pByte(@tbuf)^;
    end;
    sizeof(Word):begin
      pWord(@tbuf)^:=pWord(@source)^;
      pWord(@source)^:=pWord(@dest)^;
      pWord(@dest)^:=pWord(@tbuf)^;
    end;
    sizeof(LongWord):begin
      pLongWord(@tbuf)^:=pLongWord(@source)^;
      pLongWord(@source)^:=pLongWord(@dest)^;
      pLongWord(@dest)^:=pLongWord(@tbuf)^;
    end;
    sizeof(QWord):begin
      pQWord(@tbuf)^:=pQWord(@source)^;
      pQWord(@source)^:=pQWord(@dest)^;
      pQWord(@dest)^:=pQWord(@tbuf)^;
    end;
    else begin
      for i:=0 to count-1 do begin
        pByte(@tbuf)^:=pByte(@source)[i];
        pByte(@source)[i]:=pByte(@dest)[i];
        pByte(@dest)[i]:=pByte(@tbuf)^;
      end;
    end;
  end;
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
        MyXchange(vd^.data.Addr.GetInstance^,PUnDoData^,vd^.data.ptd^.SizeInBytes);
      end;
    end;
  end;
end;

constructor TChangedDataDesc.CreateRec(APTD:PUserTypeDescriptor;APValue:Pointer;AVarName:String);
begin
  PTD:=APTD;
  VarName:=AVarName;
  PUnDoData:=PTD^.AllocAndInitInstance;
  if APValue<>nil then
    PTD^.CopyInstanceTo(APValue,PUnDoData);
end;

procedure TChangedDataDesc.DestroyRec;
begin
  VarName:='';
  PTD^.MagicFreeInstance(PUnDoData);
  Freemem(PUnDoData);
end;

procedure TChangedDataDesc.StoreUndoData(APUnDoData:Pointer);
begin
  PTD^.CopyInstanceTo(APUnDoData,PUnDoData);
end;

end.
