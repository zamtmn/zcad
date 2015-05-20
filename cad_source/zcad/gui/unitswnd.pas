unit unitswnd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ButtonPanel,
  gdbase,zemathutils;

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
    procedure ChangeInInterface(Sender: TObject);//Обработчик onChange комбиков

  private
    { private declarations }
    LocalUnitsFormat:TzeUnitsFormat;
    LocalInsUnits:TInsUnits;
  public
    { public declarations }
    function RunModal(var _UnitsFormat:TzeUnitsFormat; var _InsUnits:TInsUnits):Integer; virtual;
    procedure UpdateSample; //реализация с меня
    procedure LocalUnitsFormat2Intterface; //загоняем всё из LocalUnitsFormat в комбобоксы
    procedure Intterface2LocalUnitsFormat; //собираем всё в LocalUnitsFormat из комбобоксов
  end;

var
  UnitsWindow: TUnitsWindow;

implementation

{$R *.lfm}

{ TUnitsWindow }
procedure TUnitsWindow.Intterface2LocalUnitsFormat;
begin
     //собираем всё в LocalUnitsFormat из комбобоксов
     if LUnitsComboBox.ItemIndex<>-1 then
       LocalUnitsFormat.uformat:=TLUnits(LUnitsComboBox.ItemIndex);
     if LUPrecComboBox.ItemIndex<>-1 then
       LocalUnitsFormat.uprec:=TUPrec(LUPrecComboBox.ItemIndex);
     if AUnitsComboBox.ItemIndex<>-1 then
       LocalUnitsFormat.aformat:=TAUnits(AUnitsComboBox.ItemIndex);
     if AUPrecComboBox.ItemIndex<>-1 then
       LocalUnitsFormat.aprec:=TUPrec(AUPrecComboBox.ItemIndex);
     if UnitModeCheckBox.Checked then
                                     LocalUnitsFormat.umode:=UMWithSpaces
                                 else
                                     LocalUnitsFormat.umode:=UMWithoutSpaces;
     if AngDirCheckBox.Checked then
                                   LocalUnitsFormat.adir:=ADClockwise
                               else
                                   LocalUnitsFormat.adir:=ADCounterClockwise;
     if ComboBox5.ItemIndex<>-1 then
       LocalInsUnits:=TInsUnits(ComboBox5.ItemIndex);
end;

procedure TUnitsWindow.LocalUnitsFormat2Intterface;
begin
     //загоняем всё из LocalUnitsFormat в комбобоксы
     LUnitsComboBox.ItemIndex:=ord(LocalUnitsFormat.uformat);
     LUPrecComboBox.ItemIndex:=ord(LocalUnitsFormat.uprec);
     AUnitsComboBox.ItemIndex:=ord(LocalUnitsFormat.aformat);
     AUPrecComboBox.ItemIndex:=ord(LocalUnitsFormat.aprec);
     if LocalUnitsFormat.umode=UMWithSpaces then
                                                UnitModeCheckBox.Checked:=true
                                            else
                                                UnitModeCheckBox.Checked:=false;
     if LocalUnitsFormat.adir=ADClockwise then
                                              AngDirCheckBox.Checked:=true
                                          else
                                              AngDirCheckBox.Checked:=false;

     ComboBox5.ItemIndex:=ord(LocalInsUnits);
end;
procedure TUnitsWindow.UpdateSample;
begin
     //реализация с меня
     //здесь на основе LocalUnitsFormat обновляю поле примерного вывода
     Label1.Caption:=sysutils.Format('Coord(%s);Coeff(%s);Angle(%s)',
                                     [zeDimensionToString(123.456781234,LocalUnitsFormat),
                                      zeNonDimensionToString(123.456781234,LocalUnitsFormat),
                                      zeAngleToString(pi/2,LocalUnitsFormat)]);
end;

procedure TUnitsWindow.ChangeInInterface(Sender: TObject);
begin
     //Обработчик onChange комбиков
     Intterface2LocalUnitsFormat;
     UpdateSample;
end;

function TUnitsWindow.RunModal(var _UnitsFormat:TzeUnitsFormat; var _InsUnits:TInsUnits):Integer;
begin
     LocalUnitsFormat:=_UnitsFormat;
     LocalInsUnits:=_InsUnits;
     LocalUnitsFormat2Intterface;//загоняем всё из LocalUnitsFormat в комбобоксы;
     result:=ShowModal;
     if result=mrOk then
                        begin
                        _UnitsFormat:=LocalUnitsFormat;
                        _InsUnits:=LocalInsUnits;
                        end;
end;

end.

