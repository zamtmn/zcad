{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Vladimir Bobrov)
}

unit contolelschema_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, Graphics, Types,
  contolelschema_listshields,
  contolelschema_controldevprotect,
  contolelschema_infodata,
  contolelschema_listfeeders,
  Varman;

const
  // Константы для имён сохраняемых параметров панелей
  PANEL2_PARAM_NAME = 'ContolelSchema_Panel2';
  PANEL3_PARAM_NAME = 'ContolelSchema_Panel3';
  PANEL4_PARAM_NAME = 'ContolelSchema_Panel4';
  PANEL5_PARAM_NAME = 'ContolelSchema_Panel5';

  // Размеры по умолчанию
  DEFAULT_PANEL1_HEIGHT = 50;
  DEFAULT_PANEL2_WIDTH = 250;
  DEFAULT_PANEL3_WIDTH = 300;
  DEFAULT_PANEL4_WIDTH = 250;
  DEFAULT_PANEL5_HEIGHT = 200;

type
  { TFormContolelSchemaMain }
  { Главная форма управления электрическими однолинейными схемами }
  TFormContolelSchemaMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure Splitter2Moved(Sender: TObject);
    procedure Splitter3Moved(Sender: TObject);
    procedure Splitter4Moved(Sender: TObject);
  private
    FFrameListShields: TFrame_listShields;
    FFrameControlDevProtect: TFrame_ControlDevProtect;
    FFrameInfoData: TFrame_InfoData;
    FFrameListFeeders: TFrame_listFeeders;

    procedure InitializePanels;
    procedure LoadPanelSizes;
    procedure SavePanelSizes;
    procedure CreateFrames;
    procedure DestroyFrames;
  public

  end;

var
  FormContolelSchemaMain: TFormContolelSchemaMain;

implementation

{$R *.lfm}

{ TFormContolelSchemaMain }

{ Обработчик создания формы }
procedure TFormContolelSchemaMain.FormCreate(Sender: TObject);
begin
  InitializePanels;
  LoadPanelSizes;
  CreateFrames;
end;

{ Обработчик уничтожения формы }
procedure TFormContolelSchemaMain.FormDestroy(Sender: TObject);
begin
  SavePanelSizes;
  DestroyFrames;
end;

{ Инициализация панелей и сплиттеров }
procedure TFormContolelSchemaMain.InitializePanels;
begin
  // Панель 1 - верхняя, фиксированная высота
  Panel1.Align := alTop;
  Panel1.Height := DEFAULT_PANEL1_HEIGHT;

  // Панель 5 - нижняя
  Panel5.Align := alBottom;
  Panel5.Height := DEFAULT_PANEL5_HEIGHT;

  // Сплиттер 4 - под панелью 5
  Splitter4.Align := alBottom;
  Splitter4.Height := 5;

  // Панель 2 - слева
  Panel2.Align := alLeft;
  Panel2.Width := DEFAULT_PANEL2_WIDTH;

  // Сплиттер 1 - справа от панели 2
  Splitter1.Align := alLeft;
  Splitter1.Width := 5;

  // Панель 4 - справа
  Panel4.Align := alRight;
  Panel4.Width := DEFAULT_PANEL4_WIDTH;

  // Сплиттер 3 - слева от панели 4
  Splitter3.Align := alRight;
  Splitter3.Width := 5;

  // Панель 3 - центральная, заполняет оставшееся пространство
  Panel3.Align := alClient;

  // Сплиттер 2 не используется в данной конфигурации
  Splitter2.Visible := False;
end;

{ Загрузка сохранённых размеров панелей }
procedure TFormContolelSchemaMain.LoadPanelSizes;
var
  BoundsRect: TRect;
begin
  // Загружаем размеры панели 2
  BoundsRect := GetBoundsFromSavedUnit(PANEL2_PARAM_NAME,
                                       Screen.Width,
                                       Screen.Height);
  if BoundsRect.Right > BoundsRect.Left then
    Panel2.Width := BoundsRect.Right - BoundsRect.Left;

  // Загружаем размеры панели 3
  BoundsRect := GetBoundsFromSavedUnit(PANEL3_PARAM_NAME,
                                       Screen.Width,
                                       Screen.Height);
  // Панель 3 имеет Align = alClient, размеры применяются автоматически

  // Загружаем размеры панели 4
  BoundsRect := GetBoundsFromSavedUnit(PANEL4_PARAM_NAME,
                                       Screen.Width,
                                       Screen.Height);
  if BoundsRect.Right > BoundsRect.Left then
    Panel4.Width := BoundsRect.Right - BoundsRect.Left;

  // Загружаем размеры панели 5
  BoundsRect := GetBoundsFromSavedUnit(PANEL5_PARAM_NAME,
                                       Screen.Width,
                                       Screen.Height);
  if BoundsRect.Bottom > BoundsRect.Top then
    Panel5.Height := BoundsRect.Bottom - BoundsRect.Top;
end;

{ Сохранение текущих размеров панелей }
procedure TFormContolelSchemaMain.SavePanelSizes;
begin
  StoreBoundsToSavedUnit(PANEL2_PARAM_NAME, Panel2.BoundsRect);
  StoreBoundsToSavedUnit(PANEL3_PARAM_NAME, Panel3.BoundsRect);
  StoreBoundsToSavedUnit(PANEL4_PARAM_NAME, Panel4.BoundsRect);
  StoreBoundsToSavedUnit(PANEL5_PARAM_NAME, Panel5.BoundsRect);
end;

{ Создание и размещение фреймов на панелях }
procedure TFormContolelSchemaMain.CreateFrames;
begin
  // Создаём фрейм для панели 2 - Список щитов
  FFrameListShields := TFrame_listShields.Create(Self);
  FFrameListShields.Parent := Panel2;
  FFrameListShields.Align := alClient;

  // Создаём фрейм для панели 3 - Управление устройствами защиты
  FFrameControlDevProtect := TFrame_ControlDevProtect.Create(Self);
  FFrameControlDevProtect.Parent := Panel3;
  FFrameControlDevProtect.Align := alClient;

  // Создаём фрейм для панели 4 - Информационные данные
  FFrameInfoData := TFrame_InfoData.Create(Self);
  FFrameInfoData.Parent := Panel4;
  FFrameInfoData.Align := alClient;

  // Создаём фрейм для панели 5 - Список фидеров
  FFrameListFeeders := TFrame_listFeeders.Create(Self);
  FFrameListFeeders.Parent := Panel5;
  FFrameListFeeders.Align := alClient;
end;

{ Освобождение фреймов }
procedure TFormContolelSchemaMain.DestroyFrames;
begin
  if Assigned(FFrameListShields) then
    FreeAndNil(FFrameListShields);

  if Assigned(FFrameControlDevProtect) then
    FreeAndNil(FFrameControlDevProtect);

  if Assigned(FFrameInfoData) then
    FreeAndNil(FFrameInfoData);

  if Assigned(FFrameListFeeders) then
    FreeAndNil(FFrameListFeeders);
end;

{ Обработчик перемещения сплиттера 1 (между панелями 2 и 3) }
procedure TFormContolelSchemaMain.Splitter1Moved(Sender: TObject);
begin
  StoreBoundsToSavedUnit(PANEL2_PARAM_NAME, Panel2.BoundsRect);
end;

{ Обработчик перемещения сплиттера 2 (не используется) }
procedure TFormContolelSchemaMain.Splitter2Moved(Sender: TObject);
begin
  // Не используется в текущей конфигурации
end;

{ Обработчик перемещения сплиттера 3 (между панелями 3 и 4) }
procedure TFormContolelSchemaMain.Splitter3Moved(Sender: TObject);
begin
  StoreBoundsToSavedUnit(PANEL4_PARAM_NAME, Panel4.BoundsRect);
end;

{ Обработчик перемещения сплиттера 4 (между панелями 3/2/4 и 5) }
procedure TFormContolelSchemaMain.Splitter4Moved(Sender: TObject);
begin
  StoreBoundsToSavedUnit(PANEL5_PARAM_NAME, Panel5.BoundsRect);
end;

end.
