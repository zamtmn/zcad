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
unit zUndoCmdSaveEntityState;
interface
uses
  zeundostack,zebaseundocommands,uzeentity,uzcdrawings;

type
  TUndoCmdSaveEntityState=class(TUCmdBase)
    private
      var
        FContainer,FEntity:PGDBObjEntity;
        //procedure AfterDo;
    public
        constructor Create(PSavedEntity:PGDBObjEntity);
        constructor CreateAndPush(PSavedEntity:PGDBObjEntity;var us:TZctnrVectorUndoCommands);

        procedure UnDo;override;
        procedure Comit;override;
        destructor Destroy;override;
  end;

implementation

constructor TUndoCmdSaveEntityState.CreateAndPush(PSavedEntity:PGDBObjEntity;var us:TZctnrVectorUndoCommands);
begin
  Create(PSavedEntity);
  us.PushBackData(self);
  inc(us.CurrentCommand);
end;

constructor TUndoCmdSaveEntityState.Create(PSavedEntity:PGDBObjEntity);
begin
  FContainer:=PSavedEntity^.Clone(nil);
  FEntity:=PSavedEntity;
end;

procedure TUndoCmdSaveEntityState.UnDo;
begin
  FContainer^.rtsave(FEntity);
  drawings.AfterEnt(FEntity);
end;

procedure TUndoCmdSaveEntityState.Comit;
begin
end;

destructor TUndoCmdSaveEntityState.Destroy;
begin
  FContainer^.done;
  Freemem(FContainer);
  inherited;
end;

end.
