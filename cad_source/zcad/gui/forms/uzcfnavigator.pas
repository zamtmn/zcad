unit uzcfnavigator;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ActnList, VirtualTrees;

type

  { TNavigator }

  TNavigator = class(TForm)
    MainToolBar: TToolBar;
    ToolButton1: TToolButton;
    RefreshToolButton: TToolButton;
    ToolButton3: TToolButton;
    NavTree: TVirtualStringTree;
    ActionList1:TActionList;
    Refresh:TAction;
  private

  public

  end;

var
  Navigator: TNavigator;

implementation

{$R *.lfm}
end.

