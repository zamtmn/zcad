unit colorwnd;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ColorBox, ButtonPanel;

type

  { TColorSelectWND }

  TColorSelectWND = class(TForm)
    ButtonPanel1: TButtonPanel;
    ColorBox1: TColorBox;
  private
    { private declarations }
  public
    ColorInfex:Integer;
    { public declarations }
  end;

var
  ColorSelectWND: TColorSelectWND;

implementation

initialization
  {$I colorwnd.lrs}

end.

