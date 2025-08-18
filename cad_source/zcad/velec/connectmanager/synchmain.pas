unit synchMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,uzvmcdbconsts,
  DispatcherConnectionManager;

type
  TFrameClass = class of TFrame;

  { TformSynch }

  TformSynch = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PanelSynchConrolMenu: TPanel;
    PanelSynch: TPanel;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);

  private
    CurrentFrame: TFrame;
    procedure ShowFrame(AFrameClass: TFrameClass);
  public
    procedure ResetSplitterTo50;
  end;

var
  formSynch: TformSynch;

implementation

{$R *.lfm}

procedure TformSynch.FormCreate(Sender: TObject);
begin
  ShowFrame(TDispatcherConnectionFrame);
  Constraints.MinWidth := 600;
  Constraints.MinHeight := 400;
end;

procedure TformSynch.FormShow(Sender: TObject);
begin
  //ShowFrame(TframeSynchDevice);
  //frameSynchDevice.RefreshGridFormatting;
end;

procedure TformSynch.FormResize(Sender: TObject);
begin
  // зарезервировано для управления пропорциями
end;

procedure TformSynch.ShowFrame(AFrameClass: TFrameClass);
begin
  if Assigned(CurrentFrame) then
    FreeAndNil(CurrentFrame);

  CurrentFrame := AFrameClass.Create(Self);
  with CurrentFrame do
  begin
    Parent := PanelSynch;
    Align := alClient;
    Show;

    //if CurrentFrame is TframeSynchDevice then
    //  TframeSynchDevice(CurrentFrame).Activate;
    //if CurrentFrame is TframeSynchDevice then
    //  TframeSynchDevice(CurrentFrame).RefreshGridFormatting;
  end;
end;

procedure TformSynch.ResetSplitterTo50;
begin
  // зарезервировано для сброса ширины панели
end;

procedure TformSynch.MenuItem1Click(Sender: TObject);
begin
  // зарезервировано для переключения фрейма
end;

procedure TformSynch.MenuItem2Click(Sender: TObject);
begin
  // зарезервировано для переключения фрейма
end;


end.

