unit unitswnd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ButtonPanel;

type

  { TUnitsWindow }

  TUnitsWindow = class(TForm)
    Bevel1: TBevel;
    AngleDirectionBitBtn: TBitBtn;
    AngDirCheckBox: TCheckBox;
    ButtonPanel1: TButtonPanel;
    UnitModeCheckBox: TCheckBox;
    LUnitsComboBox: TComboBox;
    LUPrecComboBox: TComboBox;
    AUnitsComboBox: TComboBox;
    AUPrecComboBox: TComboBox;
    ComboBox5: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel1: TPanel;

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  UnitsWindow: TUnitsWindow;

implementation

{$R *.lfm}

{ TUnitsWindow }



end.

