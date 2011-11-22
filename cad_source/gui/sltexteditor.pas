unit sltexteditor;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { Tsltexteditor1 }

  Tsltexteditor1 = class(TForm)
    OkButton: TButton;
    EditField: TEdit;
    helptext: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  sltexteditor1: Tsltexteditor1;

implementation

initialization
  {$I sltexteditor.lrs}

end.

