unit unitswnd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ButtonPanel,
  gdbase;

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
    LocalUnitsFormat:TzeUnitsFormat;
  public
    { public declarations }
    function RunModal(var _UnitsFormat:TzeUnitsFormat):Integer; virtual;
    procedure UpdateSample; //реализация с меня
  end;

var
  UnitsWindow: TUnitsWindow;

implementation

{$R *.lfm}

{ TUnitsWindow }
procedure TUnitsWindow.UpdateSample;
begin
     //реализация с меня
     //ты вызываешь эту процедуру после изменения комбобокса и синхронного обновления
     //LocalUnitsFormat, я здесь на основе LocalUnitsFormat обновляю поле примерного вывода
end;
function TUnitsWindow.RunModal(var _UnitsFormat:TzeUnitsFormat):Integer;
begin
     LocalUnitsFormat:=_UnitsFormat;
     //
     // тут на основе LocalUnitsFormat настраиваем комбики
     // далее внутри окна в обработчиках поддерживаем
     // LocalUnitsFormat синхронно с изменениями
     //
     result:=ShowModal;
     if result=mrOk then
                        _UnitsFormat:=LocalUnitsFormat;
end;

end.

