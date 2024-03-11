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
interface
uses zeundostack,zebaseundocommands;

type
  generic GUCmdChgData2<GChangedDataDesc,GSharedData,GAfterChangeDataDesc>=class(TUCmdBase)
    private
      type
        TSelf=specialize GUCmdChgData2<GChangedDataDesc,GSharedData,GAfterChangeDataDesc>;
      var
        SharedData:GSharedData;
        AfterChangeData:GAfterChangeDataDesc;

        procedure AfterDo;
    public
        ChangedData:GChangedDataDesc;
        constructor Create(AChangedData:GChangedDataDesc;
                           ASharedData:GSharedData;
                           AAfterChangeData:GAfterChangeDataDesc);
        destructor Destroy;override;
        class function CreateAndPush(var us:TZctnrVectorUndoCommands;
                                     AChangedData:GChangedDataDesc;
                                     ASharedData:GSharedData;
                                     AAfterChangeData:GAfterChangeDataDesc):TSelf;

        procedure UnDo;override;
        procedure Comit;override;
  end;

implementation
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


end.

