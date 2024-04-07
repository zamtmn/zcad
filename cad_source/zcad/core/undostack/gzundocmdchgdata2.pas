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
unit gzUndoCmdChgData2;
{$INCLUDE zengineconfig.inc}
{$ModeSwitch advancedrecords}
interface
uses zeundostack,zebaseundocommands;

type

  generic GSharedData<T>=record
    Data:T;
    constructor CreateRec(AData:T);
    procedure DestroyRec;
  end;

  generic GAfterChangeData<T,GSData,GAfterDoClass>=record
    Data:T;
    procedure AfterDo(SD:GSData);
    constructor CreateRec(AData:T);
    procedure DestroyRec;
  end;

  generic GChangedData<T,GSData,GASData>=record
    type
      PT=^T;
    var
      PChangedData:PT;
      Data:T;
    procedure UnDo(GSD:GSData);
    procedure Comit(GSD:GSData);
    procedure ChangeProc(GSD:GSData);
    constructor CreateRec(var AData:T);
    procedure DestroyRec;
    //procedure StoreUndoData(APUnDoData:Pointer);
    procedure StoreDoData(const AData:T);
  end;

  generic GDataByAddr<T>=record
    type
      TData=T;
      PData=^T;
    var
      PChangedData:PData;
    function GetAddr:PData;
    constructor CreateRec(var AData:T);
    procedure DestroyRec;
  end;

  generic GChangedDataByDesk<T,TDesk,GSData,GASData>=record
    type
      TData=T;
      PData=^T;
    var
      DataDesk:TDesk;
      Data:T;
    procedure UnDo(GSD:GSData);
    procedure Comit(GSD:GSData);
    procedure ChangeProc(GSD:GSData);
    constructor CreateRec(var AData:T);
    procedure DestroyRec;
    procedure StoreDoData(const AData:T);
  end;

  generic GUCmdChgData2<GChangedDataDesc,GSharedData,GAfterChangeDataDesc>=class(TUCmdBase)
    private
      var
        SharedData:GSharedData;
        AfterChangeData:GAfterChangeDataDesc;

        procedure AfterDo;
    public
      type
        TSelf=specialize GUCmdChgData2<GChangedDataDesc,GSharedData,GAfterChangeDataDesc>;
        TData=GChangedDataDesc;
        TSharedData=GSharedData;
        TAfterChangData=GAfterChangeDataDesc;
      var
        ChangedData:GChangedDataDesc;
        constructor Create(AChangedData:GChangedDataDesc;
                           ASharedData:GSharedData;
                           AAfterChangeData:GAfterChangeDataDesc);
        destructor Destroy;override;
        class function CreateAndPush(var us:TZctnrVectorUndoCommands;
                                     AChangedData:GChangedDataDesc;
                                     ASharedData:GSharedData;
                                     AAfterChangeData:GAfterChangeDataDesc):TSelf;
        class function CreateAndPushIfNeed(var us:TZctnrVectorUndoCommands;
                                           AChangedData:GChangedDataDesc;
                                           ASharedData:GSharedData;
                                           AAfterChangeData:GAfterChangeDataDesc):TSelf;
        procedure UnDo;override;
        procedure Comit;override;
  end;

implementation

procedure GChangedData.UnDo(GSD:GSData);
begin
  ChangeProc(GSD);
end;
procedure GChangedData.Comit(GSD:GSData);
begin
  ChangeProc(GSD);
end;
procedure GChangedData.ChangeProc(GSD:GSData);
var
  TD:T;
begin
  TD:=PChangedData^;
  PChangedData^:=Data;
  Data:=TD;
end;
constructor GChangedData.CreateRec(var AData:T);
begin
  PChangedData:=@AData;
  Data:=AData;
end;
procedure GChangedData.DestroyRec;
begin
  Data:=default(T);
end;
procedure GChangedData.StoreDoData(const AData:T);
begin
  Data:=AData;
end;

constructor GSharedData.CreateRec(AData:T);
begin
  Data:=AData;
end;
procedure GSharedData.DestroyRec;
begin
end;

procedure GAfterChangeData.AfterDo(SD:GSData);
begin
  GAfterDoClass.AfterDo(sd,self);
 end;
constructor GAfterChangeData.CreateRec(AData:T);
begin
  Data:=AData;
end;
procedure GAfterChangeData.DestroyRec;
begin
end;


destructor GUCmdChgData2.Destroy;
begin
  inherited;
  SharedData.DestroyRec;
  AfterChangeData.DestroyRec;
  ChangedData.DestroyRec;
end;

class function GUCmdChgData2.CreateAndPush(var us:TZctnrVectorUndoCommands;
                                           AChangedData:GChangedDataDesc;
                                           ASharedData:GSharedData;
                                           AAfterChangeData:GAfterChangeDataDesc):TSelf;
begin
  result:=TSelf.Create(AChangedData,ASharedData,AAfterChangeData);
  us.PushBackData(result);
  inc(us.CurrentCommand);
end;
class function GUCmdChgData2.CreateAndPushIfNeed(var us:TZctnrVectorUndoCommands;
                                                 AChangedData:GChangedDataDesc;
                                                 ASharedData:GSharedData;
                                                 AAfterChangeData:GAfterChangeDataDesc):TSelf;
begin
  result:=CreateAndPush(us,AChangedData,ASharedData,AAfterChangeData);
end;

constructor GUCmdChgData2.Create(AChangedData:GChangedDataDesc;
                                ASharedData:GSharedData;
                                AAfterChangeData:GAfterChangeDataDesc);
begin
  ChangedData:=AChangedData;
  SharedData:=ASharedData;
  AfterChangeData:=AAfterChangeData;
end;
procedure GUCmdChgData2.UnDo;
begin
  ChangedData.UnDo(SharedData);
  AfterDo;
end;
procedure GUCmdChgData2.Comit;
begin
  ChangedData.Comit(SharedData);
  AfterDo;
end;
procedure GUCmdChgData2.AfterDo;
begin
  AfterChangeData.AfterDo(SharedData);
end;



function GDataByAddr.GetAddr:PData;
begin
  result:=PChangedData;
end;
constructor GDataByAddr.CreateRec(var AData:T);
begin
  PChangedData:=@AData;
end;
procedure GDataByAddr.DestroyRec;
begin
end;

procedure GChangedDataByDesk.UnDo(GSD:GSData);
begin
  ChangeProc(GSD);
end;
procedure GChangedDataByDesk.Comit(GSD:GSData);
begin
  ChangeProc(GSD);
end;
procedure GChangedDataByDesk.ChangeProc(GSD:GSData);
var
  TD:T;
  PD:PData;
begin
  PD:=DataDesk.getAddr;
  TD:=PD^;
  PD^:=Data;
  Data:=TD;
end;
constructor GChangedDataByDesk.CreateRec(var AData:T);
begin
  //PChangedData:=@AData;
  Data:=AData;
end;
procedure GChangedDataByDesk.DestroyRec;
begin
  Data:=default(T);
end;
procedure GChangedDataByDesk.StoreDoData(const AData:T);
begin
  Data:=AData;
end;



end.

