unit uzcfdimedit;


{$INCLUDE def.inc}
{$mode objfpc}{$H+}

interface

uses
  uzcutils,zcchangeundocommand,zcobjectchangeundocommand2,uzcdrawing,LMessages,uzefont,
  uzclog,uzedrawingsimple,uzcsysvars,Classes, SysUtils,
  FileUtil, LResources, Forms, Controls, Graphics, Dialogs,GraphType,
  Buttons, ExtCtrls, StdCtrls, ComCtrls,LCLIntf,lcltype, ActnList, Spin,

  uzeconsts,uzestylestexts,uzcdrawings,uzbtypesbase,uzbtypes,varmandef,
  uzcsuptypededitors,

  uzestylesdim, uzeentdimension,

  uzbpaths,uzcinterface, uzcstrconsts, uzcsysinfo,uzbstrproc, uzcshared,UBaseTypeDescriptor,
  uzcimagesmanager, usupportgui, ZListView,uzefontmanager,varman,uzctnrvectorgdbstring,
  gzctnrvectortypes,uzeentity,uzeenttext,uzepalette, uzcflineweights,uzestyleslinetypes,Types;

type

  { TDimStyleEditForm }

  TDimStyleEditForm = class(TForm)
    //dimStyle:PGDBDimStyle;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    dlineColor: TComboBox;
    dlineType: TComboBox;
    ComboBox3: TComboBox;
    FloatSpinEdit1: TFloatSpinEdit;
    FloatSpinEdit2: TFloatSpinEdit;
    dlineColorLabel: TLabel;
    dlineTypeLabel: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure RefreshClick(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dlineColorComboBox(Sender: TObject);
    procedure dlineColorComboBoxChange(Sender: TObject);
    procedure dlineTypeComboBox(Sender: TObject);
    procedure dlineTypeComboBoxChange(Sender: TObject);
    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private

  public

  end;


var
  DimStyleEditForm: TDimStyleEditForm;
  dimStyle:PGDBDimStyle;


implementation

{$R *.lfm}

{ TDimStyleEditForm }


procedure TDimStyleEditForm.CheckBox1Change(Sender: TObject);
begin

end;


procedure TDimStyleEditForm.dlineColorComboBox(Sender: TObject);
var
    i:integer;
    isColor:boolean;
begin
    dlineColor.Clear;
    dlineColor.AddItem(GetColorNameFromIndex(256),Sender);
    dlineColor.AddItem(GetColorNameFromIndex(0),Sender);
    for i:=1 to 7 do begin
       dlineColor.AddItem(acadpalette[i].name,Sender);
    end;

    isColor:=true;
    for i:=0 to dlineColor.Items.Count-1 do begin
       if GetColorNameFromIndex(dimStyle^.Lines.DIMCLRD) = dlineColor.Items[i] then begin
          dlineColor.ItemIndex := i;
          isColor:=false;
          end;
    end;

    if isColor then begin
       dlineColor.AddItem(inttostr(dimStyle^.Lines.DIMCLRD),Sender);
       dlineColor.ItemIndex := dlineColor.Items.Count - 1;
    end;

    dlineColor.AddItem('Other...',Sender);


    //dimStyle^.Lines.DIMCLRD:=;
    //GetColorNameFromIndex(colorindex);
    //ZCMsgCallBackInterface.TextMessage(GetColorNameFromIndex(dimStyle^.Lines.DIMCLRD),TMWOHistoryOut);


    //ZCMsgCallBackInterface.TextMessage(GetColorNameFromIndex(dimStyle^.Lines.DIMCLRE),TMWOHistoryOut);
    //with dlineColor.Items do
    //begin
    //  AddObject('самолет', TObject(2000));
    //  AddObject('поезд', TObject(1500));
    //  AddObject('автобус', TObject(1500));
    //end;
    //dlineColor.ItemIndex := 0;
end;


//**Решил в лоб наверное неправильно перебераю всю палитру
procedure TDimStyleEditForm.dlineColorComboBoxChange(Sender: TObject);
//var
//    i:integer;
//    indexCB:integer;
//    isColor:boolean;
begin
    //indexCB:=TComboBox(Sender).Items.Count;
    if dlineColor.Items[TComboBox(Sender).ItemIndex] = 'Other...' then
      begin
         ZCMsgCallBackInterface.TextMessage('не работает',TMWOHistoryOut);
      end
    else
      case TComboBox(Sender).ItemIndex of
        0:
        //ZCMsgCallBackInterface.TextMessage('0',TMWOHistoryOut);
          dimStyle^.Lines.DIMCLRD:= 256;
        1..8:
          //ZCMsgCallBackInterface.TextMessage('1-8',TMWOHistoryOut);
          dimStyle^.Lines.DIMCLRD:= TComboBox(Sender).ItemIndex - 1;
      else
          dimStyle^.Lines.DIMCLRD:= strtoint(string(dlineColor.Items[TComboBox(Sender).ItemIndex]));
      end;
    //ZCMsgCallBackInterface.TextMessage(inttostr(TComboBox(Sender).ItemIndex),TMWOHistoryOut);
end;

procedure TDimStyleEditForm.dlineTypeComboBox(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   pltp:PGDBLtypeProp;
   i:integer;
   //isDLType:boolean;
begin
    dlineType.Clear;
    pdwg:=drawings.GetCurrentDWG;
     if (pdwg<>nil) then
     begin
       pltp:=pdwg^.LTypeStyleTable.beginiterate(ir);
       if pltp<>nil then
       repeat
            dlineType.AddItem(Tria_AnsiToUtf8(pltp^.Name),Sender);
            pltp:=pdwg^.LTypeStyleTable.iterate(ir);
       until pltp=nil;
     end;

     for i:=0 to dlineType.Items.Count-1 do begin
         if Tria_AnsiToUtf8(dimStyle^.Lines.DIMLTYPE^.Name) = dlineType.Items[i] then begin
            dlineType.ItemIndex := i;
            end;
     end;


     //ZCMsgCallBackInterface.TextMessage('стили-',TMWOHistoryOut);
     //ZCMsgCallBackInterface.TextMessage(dimStyle^.Lines.DIMLTYPE^.Name,TMWOHistoryOut);

end;
//**Решил в лоб наверное неправильно перебераю всю палитру
procedure TDimStyleEditForm.dlineTypeComboBoxChange(Sender: TObject);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   pltp:PGDBLtypeProp;
begin
     pdwg:=drawings.GetCurrentDWG;
     if (pdwg<>nil) then
     begin
       pltp:=pdwg^.LTypeStyleTable.beginiterate(ir);
       if pltp<>nil then
       repeat
            if Tria_AnsiToUtf8(pltp^.Name) = dlineType.Items[TComboBox(Sender).ItemIndex] then begin
               dimStyle^.Lines.DIMLTYPE := pltp;
               //ZCMsgCallBackInterface.TextMessage(dimStyle^.Lines.DIMLTYPE^.Name,TMWOHistoryOut);
            end;
            pltp:=pdwg^.LTypeStyleTable.iterate(ir);
       until pltp=nil;
     end;
end;


    //dlineColor.AddItem(GetColorNameFromIndex(256),Sender);
    //dlineColor.AddItem(GetColorNameFromIndex(0),Sender);
    //for i:=1 to 7 do begin
    //   dlineColor.AddItem(acadpalette[i].name,Sender);
    //end;
    //
    //isColor:=true;
    //for i:=0 to dlineColor.Items.Count-1 do begin
    //   if GetColorNameFromIndex(dimStyle^.Lines.DIMCLRD) = dlineColor.Items[i] then begin
    //      dlineColor.ItemIndex := i;
    //      isColor:=false;
    //      end;
    //end;
    //
    //if isColor then begin
    //   dlineColor.AddItem(inttostr(dimStyle^.Lines.DIMCLRD),Sender);
    //   dlineColor.ItemIndex := dlineColor.Items.Count - 1;
    //end;
    //
    //dlineColor.AddItem('Other...',Sender);
//end;

procedure TDimStyleEditForm.FormCreate(Sender: TObject);
var
   Transp : TStringList;
begin
   //TDimStyleEditForm.lineLayerView();



     //Transp := TStringList.Create;
     //with Transp do
     //begin
     //   AddObject('самолет', TObject(2000));
     //   AddObject('поезд', TObject(1500));
     //   AddObject('автобус', TObject(1500));
     //end;
     //dlineColor.Items.Assign(Transp);
     //dlineColor.ItemIndex := 0;
     //
     //Transp.Clear;
      ZCMsgCallBackInterface.TextMessage('1111111hf,jnftn',TMWOHistoryOut);
      //dlineColor.AddItem('123',Sender);
      //dlineColor.AddItem('222',Sender);
      //dlineColor.AddItem('333',Sender);

end;

procedure TDimStyleEditForm.RefreshClick(Sender: TObject);
var
   i:integer;
begin
     //ZCMsgCallBackInterface.TextMessage(dimStyle^.Text.DIMTXSTY^.GetFullName,TMWOHistoryOut);
     dlineColorLabel.Caption:='Цвет';
     dlineTypeLabel.Caption:='Тип линии';
     dlineColorComboBox(Sender);
     dlineTypeComboBox(Sender);

     //with dlineColor.Items do
   //begin
   //   AddObject('самолет', TObject(2000));
   //   AddObject('поезд', TObject(1500));
   //   AddObject('автобус', TObject(1500));
   //end;
   //     dlineColor.AddItem('123',Sender);

    //for i:=0 to 7 do begin
    //   dlineColor.AddItem(acadpalette[i].name,Sender);
    //   //dlineColor.Items[1];
    //end;
    //


    //dlineColor.ItemIndex := 1;
end;


procedure TDimStyleEditForm.TabSheet1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

end.

