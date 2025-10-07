unit SpecificationNav;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
  TSpecificationNav = class(TFrame)
    Label1: TLabel;
  private

  public
    constructor Create(TheOwner: TComponent); override;
  end;

implementation

{$R *.lfm}

constructor TSpecificationNav.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Name := 'SpecificationNav';
  Caption := 'Specification Navigation';

  Label1 := TLabel.Create(Self);
  Label1.Parent := Self;
  Label1.Caption := 'Specification.';
  Label1.Align := alClient;
  Label1.Alignment := taCenter;
  Label1.Layout := tlCenter;
end;

end.