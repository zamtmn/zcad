unit uzcfblockinsert;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ButtonPanel, Spin, ExtCtrls,

  UGDBObjBlockdefArray, //описание таблицы блоков
  uzeblockdef,          //описания блоков
  uzbtypesbase,          //базовые типы
  uzbstrproc               //билеберда для работы со стрингами
  ;


type

  { TBlockInsertForm }

  TBlockInsertForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit10: TFileNameEdit;
    FloatSpinEdit1: TFloatSpinEdit;
    FloatSpinEdit2: TFloatSpinEdit;
    FloatSpinEdit3: TFloatSpinEdit;
    FloatSpinEdit4: TFloatSpinEdit;
    FloatSpinEdit5: TFloatSpinEdit;
    FloatSpinEdit6: TFloatSpinEdit;
    FloatSpinEdit7: TFloatSpinEdit;
    FloatSpinEdit8: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox5Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    function Run(PBlockDefs:PGDBObjBlockdefArray;LastInsertedBlockName:GDBString):Integer;
    { public declarations }
  end;

var
  BlockInsertForm: TBlockInsertForm;

implementation
{$R *.lfm}

procedure TBlockInsertForm.FormCreate(Sender: TObject);
begin

end;

procedure TBlockInsertForm.CheckBox4Change(Sender: TObject);
begin
  if Checkbox4.Checked = True then
  begin
    FloatSpinEdit1.Enabled := False;
    FloatSpinEdit2.Enabled := False;
    FloatSpinEdit3.Enabled := False;
  end
  else
  begin
    FloatSpinEdit1.Enabled := True;
    FloatSpinEdit2.Enabled := True;
    FloatSpinEdit3.Enabled := True;
  end;
end;

procedure TBlockInsertForm.CheckBox5Change(Sender: TObject);
begin
  if Checkbox3.Checked then exit;
  if Checkbox5.Checked then
  begin
    FloatSpinEdit5.Enabled := False;
    FloatSpinEdit6.Enabled := False;
  end
  else
  begin
    FloatSpinEdit5.Enabled := True;
    FloatSpinEdit6.Enabled := True;
  end;
end;

procedure TBlockInsertForm.CheckBox2Change(Sender: TObject);
begin
  if CheckBox2.Checked then
  begin
    FloatSpinEdit7.Enabled := False;
  end
  else
  begin
    FloatSpinEdit7.Enabled := True;
  end;
end;

procedure TBlockInsertForm.CheckBox3Change(Sender: TObject);
begin
  if Checkbox3.Checked then
  begin
    FloatSpinEdit4.Enabled := False;
    FloatSpinEdit5.Enabled := False;
    FloatSpinEdit6.Enabled := False;
  end
  else
  begin
    if Checkbox5.Checked then
    begin
      FloatSpinEdit4.Enabled := True;
      FloatSpinEdit5.Enabled := False;
      FloatSpinEdit6.Enabled := False;
      FloatSpinEdit5.Value:= FloatSpinEdit4.Value;
      FloatSpinEdit6.Value:= FloatSpinEdit4.Value;
    end
    else
    begin
      FloatSpinEdit4.Enabled := True;
      FloatSpinEdit5.Enabled := True;
      FloatSpinEdit6.Enabled := True;
    end;
  end;
end;

function TBlockInsertForm.Run(
                             PBlockDefs:PGDBObjBlockdefArray; //указатель на таблицу описаний блоков
                             LastInsertedBlockName:GDBString  //имя последнего (например в предидущем сеансе команды) вставленного блока, чтобы его выбрать "по умолчанию"
                                                              //его нужно сохранять гденить в чертеже
                             ):Integer;                       //модальнвй результат
var
  p:PGDBObjBlockdef;              //указатель на описание блоков, им будем перебирать таблицу
  ir:itrec;                       //"счетчтк" для перебора в таблице
  LastInsertedBlockIndex:integer; //индекс выделенного элемента в комбике
begin
  //mess
  ComboBox1.Clear;//чистим на всякий пожарный

  LastInsertedBlockIndex:=-1;// заранее предполагаем что последнего вставленного блока мы ненайдем
  LastInsertedBlockName:=uppercase(LastInsertedBlockName); //искать будем case`независимо

  begin
    p:=PBlockDefs^.BeginIterate(ir);//начинаем перебирать описания в таблице
    if p<>nil then
    repeat
         ComboBox1.AddItem(Tria_AnsiToUtf8(p^.Name),tobject(p));//загоняем имя и адрес найденного описания в комбик
                                                                //причем имена в описании лежат в анси кодировке, комбику они нужны в утф8
         if LastInsertedBlockName=uppercase(p^.Name) then       //если вдруг имя текущего блока совпало с ранее вставленным
          LastInsertedBlockIndex:=ComboBox1.Items.Count-1;      //запоминаем его индекс

         p:=PBlockDefs^.iterate(ir);                            //выбираем следующее определение
    until p=nil;                                                //выходим если перебрали все определения
  end;
  ComboBox1.ItemIndex:=LastInsertedBlockIndex;                  //присваиваем текущий выбраный в комбике элемент
                                                                //к возможно найденному ранее вставленному блоку
  ComboBox1.Sorted:=true;                                       //сортируем

  result:=ShowModal;
end;

initialization

end.

