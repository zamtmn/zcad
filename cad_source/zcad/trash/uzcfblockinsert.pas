unit uzcfblockinsert;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  StdCtrls, EditBtn, ButtonPanel, Spin, ExtCtrls,

  UGDBObjBlockdefArray, //описание таблицы блоков
  uzeblockdef,          //описания блоков
  uzegeometrytypes,          //базовые типы
  uzbstrproc,               //билеберда для работы со стрингами
  gzctnrVectorTypes
  ;

type

  TZEBlockInsertParams=record            //объявление записи для сбора данных из формы
      PInsert,Scale:GDBVertex;
      Rotate:Double;
      BlockName:String;
  end;

  { TBlockInsertForm }

  TBlockInsertForm = class(TForm)
    MainButtonPanel: TButtonPanel;
    ExplodeCheckBox: TCheckBox;
    AngleOnScreen: TCheckBox;
    ScaleOnScreen: TCheckBox;
    InsertOnScreen: TCheckBox;
    UniformScale: TCheckBox;
    BlockNameComboBox: TComboBox;
    BlockInit: TComboBox;
    PathEdit: TFileNameEdit;
    InsertX: TFloatSpinEdit;
    InsertY: TFloatSpinEdit;
    InsertZ: TFloatSpinEdit;
    ScaleX: TFloatSpinEdit;
    ScaleY: TFloatSpinEdit;
    ScaleZ: TFloatSpinEdit;
    Angle: TFloatSpinEdit;
    BlockInitFactor: TFloatSpinEdit;
    InsertGroupBox: TGroupBox;
    ScaleGroupBox: TGroupBox;
    RotationGroupBox: TGroupBox;
    UnitsGroupBox: TGroupBox;
    BlockNameLabel: TLabel;
    FactorLabel: TLabel;
    PathLabel: TLabel;
    InsXLabel: TLabel;
    InsYLabel: TLabel;
    InsZLabel: TLabel;
    ScaleXLabel: TLabel;
    ScaleYLabel: TLabel;
    ScaleZLabel: TLabel;
    AngleLabel: TLabel;
    UnitLabel: TLabel;
    MainPanel: TPanel;
    PrewievPanel: TPanel;
    procedure AngleOnScreenChange(Sender: TObject);
    procedure ScaleOnScreenChange(Sender: TObject);
    procedure InsertOnScreenChange(Sender: TObject);
    procedure UniformScaleChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure _onShow(Sender: TObject);
  private
    { private declarations }
  public
    function Run(PBlockDefs:PGDBObjBlockdefArray;LastInsertedBlockName:String;out InsertParams:TZEBlockInsertParams):Integer;
    { public declarations }
  end;

var
  BlockInsertForm: TBlockInsertForm;

implementation
{$R *.lfm}

procedure TBlockInsertForm.FormCreate(Sender: TObject);
begin

end;

procedure TBlockInsertForm._onShow(Sender: TObject);
var
  n:Integer;
begin
n:=MainButtonPanel.Height+MainButtonPanel.BorderSpacing.Top+MainButtonPanel.BorderSpacing.Bottom
  +ExplodeCheckBox.Height+ExplodeCheckBox.BorderSpacing.Top+ExplodeCheckBox.BorderSpacing.Bottom
  +PathEdit.Height+PathEdit.BorderSpacing.Top+PathEdit.BorderSpacing.Bottom
  +BlockNameComboBox.Height+BlockNameComboBox.BorderSpacing.Top+BlockNameComboBox.BorderSpacing.Bottom;
if ScaleGroupBox.Height>PrewievPanel.Height then
  n:=n+ScaleGroupBox.Height+ScaleGroupBox.BorderSpacing.Top+ScaleGroupBox.BorderSpacing.Bottom
else
  n:=n+PrewievPanel.Height+PrewievPanel.BorderSpacing.Top+PrewievPanel.BorderSpacing.Bottom;
self.Constraints.MinHeight:=n;
end;

procedure TBlockInsertForm.InsertOnScreenChange(Sender: TObject);
begin
  if InsertOnScreen.Checked = True then
  begin
    InsertX.Enabled := False;
    InsertY.Enabled := False;
    InsertZ.Enabled := False;
  end
  else
  begin
    InsertX.Enabled := True;
    InsertY.Enabled := True;
    InsertZ.Enabled := True;
  end;
end;

procedure TBlockInsertForm.UniformScaleChange(Sender: TObject);
begin
  if ScaleOnScreen.Checked then exit;
  if UniformScale.Checked then
  begin
    ScaleY.Enabled := False;
    ScaleZ.Enabled := False;
  end
  else
  begin
    ScaleY.Enabled := True;
    ScaleZ.Enabled := True;
  end;
end;

procedure TBlockInsertForm.AngleOnScreenChange(Sender: TObject);
begin
  if AngleOnScreen.Checked then
  begin
    Angle.Enabled := False;
  end
  else
  begin
    Angle.Enabled := True;
  end;
end;

procedure TBlockInsertForm.ScaleOnScreenChange(Sender: TObject);
begin
  if ScaleOnScreen.Checked then
  begin
    ScaleX.Enabled := False;
    ScaleY.Enabled := False;
    ScaleZ.Enabled := False;
  end
  else
  begin
    if UniformScale.Checked then
    begin
      ScaleX.Enabled := True;
      ScaleY.Enabled := False;
      ScaleZ.Enabled := False;
      ScaleY.Value:= ScaleX.Value;
      ScaleZ.Value:= ScaleX.Value;
    end
    else
    begin
      ScaleX.Enabled := True;
      ScaleY.Enabled := True;
      ScaleZ.Enabled := True;
    end;
  end;
end;

function TBlockInsertForm.Run(
                             PBlockDefs:PGDBObjBlockdefArray;     //указатель на таблицу описаний блоков
                             LastInsertedBlockName:String;     //имя последнего (например в предидущем сеансе команды) вставленного блока, чтобы его выбрать "по умолчанию"
                                                                  //его нужно сохранять гденить в чертеже
                             out InsertParams:TZEBlockInsertParams//сюда возвращаем значения
                             ):Integer;                           //модальнвй результат

var
  p:PGDBObjBlockdef;              //указатель на описание блоков, им будем перебирать таблицу
  ir:itrec;                       //"счетчик" для перебора в таблице
  LastInsertedBlockIndex:integer; //индекс выделенного элемента в комбике
  //Record1:TZEBlockInsertParams; это я убрал, потому что параметры передаются-возвращаются в параметрах вызова

begin
  //mess
  BlockNameComboBox.Clear;//чистим на всякий пожарный

  LastInsertedBlockIndex:=-1;// заранее предполагаем что последнего вставленного блока мы ненайдем
  LastInsertedBlockName:=uppercase(LastInsertedBlockName); //искать будем case`независимо

  begin
    p:=PBlockDefs^.BeginIterate(ir);//начинаем перебирать описания в таблице
    if p<>nil then
    repeat
         BlockNameComboBox.AddItem(Tria_AnsiToUtf8(p^.Name),tobject(p));//загоняем имя и адрес найденного описания в комбик
                                                                //причем имена в описании лежат в анси кодировке, комбику они нужны в утф8
         if LastInsertedBlockName=uppercase(p^.Name) then       //если вдруг имя текущего блока совпало с ранее вставленным
          LastInsertedBlockIndex:=BlockNameComboBox.Items.Count-1;      //запоминаем его индекс

         p:=PBlockDefs^.iterate(ir);                            //выбираем следующее определение
    until p=nil;                                                //выходим если перебрали все определения
  end;
  BlockNameComboBox.ItemIndex:=LastInsertedBlockIndex;                  //присваиваем текущий выбраный в комбике элемент
                                                                //к возможно найденному ранее вставленному блоку
  BlockNameComboBox.Sorted:=true;                                       //сортируем

  result:=ShowModal;

  if result=mrOK then //возвращать параметры надо только если пользователь нажал ОК, если нет,
                      //пусть вернется то что пришло - движек всеравно ничего делать небудет
  begin
    InsertParams.PInsert.x := BlockInsertForm.InsertX.Value;
    InsertParams.PInsert.y := BlockInsertForm.InsertY.Value;
    InsertParams.PInsert.z := BlockInsertForm.InsertZ.Value;

    InsertParams.Scale.x := BlockInsertForm.ScaleX.Value;
    InsertParams.Scale.y := BlockInsertForm.ScaleY.Value;
    InsertParams.Scale.z := BlockInsertForm.ScaleZ.Value;

    InsertParams.Rotate:= BlockInsertForm.Angle.Value;
  end;
end;

initialization

end.

