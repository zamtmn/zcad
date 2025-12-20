unit uzcfunits;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, ExtCtrls,
  StdCtrls, Buttons, ButtonPanel,
  uzcuitypes,uzcuidialogs,uzcuilcl2zc,uzbUnits,uzbUnitsUtils;
resourcestring
  RSUTScientific='Scientific';
  RSUTDecimal='Decimal';
  RSUTEngineering='Engineering';
  RSUTArchitectural='Architectural';
  RSUTFractional='Fractional';

const
     UPrecByLUnits:array[TLUnits,0..8]of string=(
                                               ('0E+01',
                                                '0.0E+01',
                                                '0.00E+01',
                                                '0.000E+01',
                                                '0.0000E+01',
                                                '0.00000E+01',
                                                '0.000000E+01',
                                                '0.0000000E+01',
                                                '0.00000000E+01'),
                                               ('0',
                                                '0.0',
                                                '0.00',
                                                '0.000',
                                                '0.0000',
                                                '0.00000',
                                                '0.000000',
                                                '0.0000000',
                                                '0.00000000'),
                                               ('0''-0"',
                                                '0''-0.0"',
                                                '0''-0.00"',
                                                '0''-0.000"',
                                                '0''-0.0000"',
                                                '0''-0.00000"',
                                                '0''-0.000000"',
                                                '0''-0.0000000"',
                                                '0''-0.00000000"'),
                                               ('0''-0"',
                                                '0''-0 1/2"',
                                                '0''-0 1/4"',
                                                '0''-0 1/8"',
                                                '0''-0 1/16"',
                                                '0''-0 1/32"',
                                                '0''-0 1/64"',
                                                '0''-0 1/128"',
                                                '0''-0 1/256"'),
                                               ('0',
                                                '0 1/2',
                                                '0 1/4',
                                                '0 1/8',
                                                '0 1/16',
                                                '0 1/32',
                                                '0 1/64',
                                                '0 1/128',
                                                '0 1/256')
                                                );
     UPrecByAUnits:array[TAUnits,0..8]of string=(
                                               ('0',
                                                '0.0',
                                                '0.00',
                                                '0.000',
                                                '0.0000',
                                                '0.00000',
                                                '0.000000',
                                                '0.0000000',
                                                '0.00000000'),
                                               ('0d',
                                                '0d00''',
                                                '0d00''',
                                                '0d00''00"',
                                                '0d00''00"',
                                                '0d00''00.0"',
                                                '0d00''00.00"',
                                                '0d00''00.000"',
                                                '0d00''00.0000"'),
                                               ('0g',
                                                '0.0g',
                                                '0.00g',
                                                '0.000g',
                                                '0.0000g',
                                                '0.00000g',
                                                '0.000000g',
                                                '0.0000000g',
                                                '0.00000000g'),
                                               ('0r',
                                                '0.0r',
                                                '0.00r',
                                                '0.000r',
                                                '0.0000r',
                                                '0.00000r',
                                                '0.000000r',
                                                '0.0000000r',
                                                '0.00000000r'),
                                               ('N 0d E',
                                                'N 0d00'' E',
                                                'N 0d00'' E',
                                                'N 0d00''00" E',
                                                'N 0d00''00" E',
                                                'N 0d00''00.0" E',
                                                'N 0d00''00.00" E',
                                                'N 0d00''00.000" E',
                                                'N 0d00''00.0000" E')
                                                );

type

  { TUnitsForm }

  TUnitsForm = class(TForm)
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
    function RunModal(var _UnitsFormat:TzeUnitsFormat; var _InsUnits:TInsUnits):TZCMsgModalResult; virtual;
    procedure UpdateSample; //реализация с меня
    procedure SetLUprecFromLUnits;
    procedure SetAUprecFromAUnits;
    procedure LocalUnitsFormat2Intterface; //загоняем всё из LocalUnitsFormat в комбобоксы
    procedure Intterface2LocalUnitsFormat(Sender: TObject); //собираем всё в LocalUnitsFormat из комбобоксов
  end;

var
  UnitsForm: TUnitsForm;

implementation

{$R *.lfm}

{ TUnitsForm }
procedure TUnitsForm.Intterface2LocalUnitsFormat(Sender: TObject);
begin
     //собираем всё в LocalUnitsFormat из комбобоксов
     if (sender=LUnitsComboBox)or(sender=nil)then
     if LUnitsComboBox.ItemIndex<>-1 then
                                         begin
                                              LocalUnitsFormat.uformat:=TLUnits(LUnitsComboBox.ItemIndex);
                                              SetLUprecFromLunits;
                                         end;
     if (sender=LUPrecComboBox)or(sender=nil)then
     if LUPrecComboBox.ItemIndex<>-1 then
       LocalUnitsFormat.uprec:=TUPrec(LUPrecComboBox.ItemIndex);
     if (sender=AUnitsComboBox)or(sender=nil)then
     if AUnitsComboBox.ItemIndex<>-1 then
                                         begin
                                              LocalUnitsFormat.aformat:=TAUnits(AUnitsComboBox.ItemIndex);
                                              SetAUprecFromAunits;
                                         end;
     if (sender=AUPrecComboBox)or(sender=nil)then
     if AUPrecComboBox.ItemIndex<>-1 then
       LocalUnitsFormat.aprec:=TUPrec(AUPrecComboBox.ItemIndex);
     if (sender=UnitModeCheckBox)or(sender=nil)then
     if UnitModeCheckBox.Checked then
                                     LocalUnitsFormat.umode:=UMWithSpaces
                                 else
                                     LocalUnitsFormat.umode:=UMWithoutSpaces;
     if (sender=AngDirCheckBox)or(sender=nil)then
     if AngDirCheckBox.Checked then
                                   LocalUnitsFormat.adir:=ADClockwise
                               else
                                   LocalUnitsFormat.adir:=ADCounterClockwise;
     if (sender=ComboBox5)or(sender=nil)then
     if ComboBox5.ItemIndex<>-1 then
       LocalInsUnits:=TInsUnits(ComboBox5.ItemIndex);
end;
procedure TUnitsForm.SetLUprecFromLUnits;
var
  i,curr:integer;
begin
     curr:=LUPrecComboBox.ItemIndex;
     for i:=0 to LUPrecComboBox.Items.Count-1 do
      LUPrecComboBox.Items[i]:=UPrecByLUnits[LocalUnitsFormat.uformat,i];
     LUPrecComboBox.ItemIndex:=curr;
end;
procedure TUnitsForm.SetAUprecFromAUnits;
var
  i,curr:integer;
begin
     curr:=AUPrecComboBox.ItemIndex;
     for i:=0 to AUPrecComboBox.Items.Count-1 do
      AUPrecComboBox.Items[i]:=UPrecByAUnits[LocalUnitsFormat.aformat,i];
     AUPrecComboBox.ItemIndex:=curr;
end;
procedure TUnitsForm.LocalUnitsFormat2Intterface;
begin
  LUnitsComboBox.Clear;
  LUnitsComboBox.AddItem(RSUTScientific,nil);
  LUnitsComboBox.AddItem(RSUTDecimal,nil);
  LUnitsComboBox.AddItem(RSUTEngineering,nil);
  LUnitsComboBox.AddItem(RSUTArchitectural,nil);
  LUnitsComboBox.AddItem(RSUTFractional,nil);

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
procedure TUnitsForm.UpdateSample;
begin
     //реализация с меня
     //здесь на основе LocalUnitsFormat обновляю поле примерного вывода
     Label1.Caption:=sysutils.Format('Coords: %s,%s,%s'#13#10'Factor: %s'#13#10'Angle: %s',
                                     [zeDimensionToString(1.5,LocalUnitsFormat),zeDimensionToString(2.00390625,LocalUnitsFormat),zeDimensionToString(0,LocalUnitsFormat),
                                      zeNonDimensionToString(2.00390625,LocalUnitsFormat),
                                      zeAngleToString(pi/4,LocalUnitsFormat)]);
end;

procedure TUnitsForm.ChangeInInterface(Sender: TObject);
begin
     //Обработчик onChange комбиков
     Intterface2LocalUnitsFormat(sender);
     UpdateSample;
end;

function TUnitsForm.RunModal(var _UnitsFormat:TzeUnitsFormat; var _InsUnits:TInsUnits):Integer;
begin
     LocalUnitsFormat:=_UnitsFormat;
     LocalInsUnits:=_InsUnits;
     LocalUnitsFormat2Intterface;//загоняем всё из LocalUnitsFormat в комбобоксы;
     SetLUprecFromLUnits;
     SetAUprecFromAUnits;
     result:=ShowModal;
     if result=mrOk then
                        begin
                        _UnitsFormat:=LocalUnitsFormat;
                        _InsUnits:=LocalInsUnits;
                        end;
     result:=TLCLModalResult2TZCMsgModalResult.Convert(result);
end;

end.

