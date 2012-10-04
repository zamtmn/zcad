unit colorwnd;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ColorBox, ButtonPanel, Spin;

type

  { TColorSelectWND }

  TColorSelectWND = class(TForm)
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    Label2: TLabel;
    SpinEdit1: TSpinEdit;
    procedure testsetcolor(Sender: TObject);
    procedure _onshow(Sender: TObject);
  private
    { private declarations }
  public
    ColorInfex:Integer;
    { public declarations }
  end;

var
  ColorSelectWND: TColorSelectWND;

implementation

{ TColorSelectWND }

procedure TColorSelectWND.testsetcolor(Sender: TObject);
begin
     ColorInfex:=SpinEdit1.Value;
end;

procedure TColorSelectWND._onshow(Sender: TObject);
begin
     testsetcolor(nil);
end;

initialization
  {$I colorwnd.lrs}

end.

