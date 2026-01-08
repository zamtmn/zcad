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
  zeundostack,zebaseundocommands,uzeentity,uzsbVarmanDef,
  uzcEnitiesVariablesExtender,gzUndoCmdChgData2,
  zUndoCmdChgTypes;

type
  generic GChangedTypedDataDesc<T>=record
    PUnDoData:Pointer;
    PTD:PUserTypeDescriptor;
    TypedDataID:T;
    procedure UnDo(sd:TSharedPEntityData);
    procedure Comit(sd:TSharedPEntityData);
    procedure ChangeProc(sd:TSharedPEntityData);
    constructor CreateRec(APTD:PUserTypeDescriptor;APValue:Pointer;ATypedDataID:T);
    procedure DestroyRec;
    procedure StoreUndoData(APUnDoData:Pointer);
  end;

  TChangedVariableDesc=specialize GChangedTypedDataDesc<string>;
  TChangedFieldDesc=specialize GChangedTypedDataDesc<pointer>;

  UCmdChgVariable=specialize GUCmdChgData2<TChangedVariableDesc,TSharedPEntityData,TAfterChangePDrawing>;
  UCmdChgField=specialize GUCmdChgData2<TChangedFieldDesc,TSharedPEntityData,TAfterChangePDrawing>;

procedure MyXchange(const source;var dest;count:SizeInt);
function DataID2Addr(sd:TSharedPEntityData;DataID:String):pointer;
function DataID2Addr(sd:TSharedPEntityData;DataID:pointer):pointer;

implementation

function DataID2Addr(sd:TSharedPEntityData;DataID:String):pointer;
var
  varext:TVariablesExtender;
  vd:pvardesk;
begin
  result:=nil;
  varext:=sd.Data^.specialize GetExtension<TVariablesExtender>;
  if varext<>nil then begin
    vd:=varext.entityunit.FindVariable(DataID);
    if vd<>nil then
      result:=vd^.data.Addr.GetInstance;
  end;
end;

function DataID2Addr(sd:TSharedPEntityData;DataID:pointer):pointer;
begin
  result:=DataID;
end;


procedure GChangedTypedDataDesc.UnDo(sd:TSharedPEntityData);
begin
  ChangeProc(sd);
end;

procedure GChangedTypedDataDesc.Comit(sd:TSharedPEntityData);
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

procedure GChangedTypedDataDesc.ChangeProc(sd:TSharedPEntityData);
var
  p:pointer;
begin
  p:=DataID2Addr(sd,TypedDataID);
  if p<>nil then
    MyXchange(p^,PUnDoData^,PTD^.SizeInBytes);
end;

constructor GChangedTypedDataDesc.CreateRec(APTD:PUserTypeDescriptor;APValue:Pointer;ATypedDataID:T);
begin
  PTD:=APTD;
  TypedDataID:=ATypedDataID;
  PUnDoData:=PTD^.AllocAndInitInstance;
  if APValue<>nil then
    PTD^.CopyValueToInstance(APValue,PUnDoData);
end;

procedure GChangedTypedDataDesc.DestroyRec;
begin
  TypedDataID:=default(T);
  PTD^.MagicFreeInstance(PUnDoData);
  Freemem(PUnDoData);
end;

procedure GChangedTypedDataDesc.StoreUndoData(APUnDoData:Pointer);
begin
  PTD^.CopyValueToInstance(APUnDoData,PUnDoData);
end;

end.
