unit synchMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, ActnList, uzvmcdbconsts,
  velectrnav, lowvoltnav, specificationnav, dbnav;

type
  TFrameClass = class of TFrame;

  { TformSynch }

   TformSynch = class(TForm)
     ActionList1: TActionList;
     ActElectricalNav: TAction;
     ActLowVoltNav: TAction;
     ActSpecificationNav: TAction;
     ActDBNav: TAction;
     MainMenu1: TMainMenu;
     MenuItem1: TMenuItem;
     MenuItem2: TMenuItem;
     MenuItem3: TMenuItem;
     MenuItem4: TMenuItem;
     PanelSynchConrolMenu: TPanel;
     PanelSynch: TPanel;

     procedure FormCreate(Sender: TObject);
     procedure FormShow(Sender: TObject);
     procedure FormResize(Sender: TObject);

   private
     CurrentFrame: TFrame;
     procedure ShowFrame(AFrameClass: TFrameClass);
     procedure ActElectricalNavExecute(Sender: TObject);
     procedure ActLowVoltNavExecute(Sender: TObject);
     procedure ActSpecificationNavExecute(Sender: TObject);
     procedure ActDBNavExecute(Sender: TObject);
  public
    procedure ResetSplitterTo50;
  end;

var
  formSynch: TformSynch;

implementation

{$R *.lfm}

procedure TformSynch.FormCreate(Sender: TObject);
begin
   // Initialize actions
   ActElectricalNav.Caption := 'Electrical Navigation';
   ActElectricalNav.OnExecute := @ActElectricalNavExecute;

   ActLowVoltNav.Caption := 'Low-Voltage Navigation';
   ActLowVoltNav.OnExecute := @ActLowVoltNavExecute;

   ActSpecificationNav.Caption := 'Specification Navigation';
   ActSpecificationNav.OnExecute := @ActSpecificationNavExecute;

   ActDBNav.Caption := 'Database Navigation';
   ActDBNav.OnExecute := @ActDBNavExecute;

   // Set menu item actions
   MenuItem1.Action := ActElectricalNav;
   MenuItem2.Action := ActLowVoltNav;
   MenuItem3.Action := ActSpecificationNav;
   MenuItem4.Action := ActDBNav;

   ShowFrame(TVElectrNav);
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

procedure TformSynch.ActElectricalNavExecute(Sender: TObject);
begin
   ShowFrame(TVElectrNav);
end;

procedure TformSynch.ActLowVoltNavExecute(Sender: TObject);
begin
   ShowFrame(TLowVoltNav);
end;

procedure TformSynch.ActSpecificationNavExecute(Sender: TObject);
begin
   ShowFrame(TSpecificationNav);
end;

procedure TformSynch.ActDBNavExecute(Sender: TObject);
begin
   ShowFrame(TDBNav);
end;

end.

