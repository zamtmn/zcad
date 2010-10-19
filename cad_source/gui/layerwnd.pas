unit layerwnd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Grids;

type

  { TForm2 }

  TForm2 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    B1: TBitBtn;
    B2: TBitBtn;
    B3: TBitBtn;
    B4: TBitBtn;
    B5: TBitBtn;
    B6: TBitBtn;
    B7: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    IL: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    SGrid: TStringGrid;
    procedure B1Click(Sender: TObject);
    procedure B2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form2: TForm2; 

implementation

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject); // Процедура выполняется при отрисовке окна
begin
// Отрисовываем картинки на кнопках
IL.GetBitmap(0, B1.Glyph);
IL.GetBitmap(1, B2.Glyph);
IL.GetBitmap(2, B3.Glyph);
end;

procedure TForm2.B1Click(Sender: TObject); // Процедура добавления слоя
begin
  SGrid.RowCount:=SGrid.RowCount+1;
end;

procedure TForm2.B2Click(Sender: TObject); // Процедура удаления слоя
begin
  SGrid.RowCount:=SGrid.RowCount-1;
end;

initialization
  {$I layerwnd.lrs}

end.

