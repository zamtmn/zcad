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
    procedure shoftedform(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  sltexteditor1: Tsltexteditor1;

implementation

{ Tsltexteditor1 }

procedure Tsltexteditor1.shoftedform(Sender: TObject);
begin
     EditField.SelectAll;
end;

initialization
  {$I sltexteditor.lrs}

end.

