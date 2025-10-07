unit LowVoltNav;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  TLowVoltNav = class(TFrame)
    Label1: TLabel;
  private

  public
    constructor Create(TheOwner: TComponent); override;
  end;

implementation

{$R *.lfm}

constructor TLowVoltNav.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Name := 'LowVoltNav';
  Caption := 'Low-Voltage Navigation';

  Label1 := TLabel.Create(Self);
  Label1.Parent := Self;
  Label1.Caption := 'Low-Current Systems.';
  Label1.Align := alClient;
  Label1.Alignment := taCenter;
  Label1.Layout := tlCenter;
end;

end.