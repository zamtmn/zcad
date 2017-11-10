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

  uzestylesdim, uzeentdimension,typinfo,

  uzbpaths,uzcinterface, uzcstrconsts, uzcsysinfo,uzbstrproc, uzcshared,UBaseTypeDescriptor,
  uzcimagesmanager, usupportgui, ZListView,uzefontmanager,varman,uzctnrvectorgdbstring,
  gzctnrvectortypes,uzeentity,uzeenttext,uzepalette, uzcflineweights,uzestyleslinetypes,Types;

type

  { TDimStyleEditForm }

  TDimStyleEditForm = class(TForm)
    arrowsDIMBLK1ComboBox: TComboBox;
    arrowsDIMBLK2ComboBox: TComboBox;
    arrowsDIMLDRBLKComboBox: TComboBox;
    arrowsDIMASZEdit: TFloatSpinEdit;
    arrowsDIMBLK1Label: TLabel;
    arrowsDIMBLK2Label: TLabel;
    arrowsDIMLDRBLKLabel: TLabel;
    arrowsDIMASZLabel: TLabel;
    DimPlacingSheet: TTabSheet;
    DimUnitsSheet: TTabSheet;
    TextSheet: TTabSheet;
    titelLabelLineExt: TLabel;
    lineExtLabelDIMEXE: TLabel;
    lineExtLabelDIMEXO: TLabel;
    lineExtSpinDIMEXE: TFloatSpinEdit;
    lineExtSpinDIMEXO: TFloatSpinEdit;
    lineExtColorComboBox: TComboBox;
    lineExtLT1ComboBox: TComboBox;
    lineExtLT2ComboBox: TComboBox;
    lineExtLWComboBox: TComboBox;
    dlineColor: TComboBox;
    dlineType: TComboBox;
    dlineWeight: TComboBox;
    titelLabelLineDim: TLabel;
    lineExtColorLabel: TLabel;
    lineExtLT1Label: TLabel;
    lineExtLT2Label: TLabel;
    lineExtLWLabel: TLabel;
    lineDimDLELabel: TLabel;
    lineDimCENLabel: TLabel;
    lineDimDLE: TFloatSpinEdit;
    lineDimCEN: TFloatSpinEdit;
    dlineColorLabel: TLabel;
    dlineTypeLabel: TLabel;
    GroupBox1: TGroupBox;
    dlineWeightLabel: TLabel;
    PageControl1: TPageControl;
    LineSheet: TTabSheet;
    ArrowsSheet: TTabSheet;

    procedure RefreshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ColorComboBoxCreate(Sender: TObject;var colorBox:TComboBox;coloritem:TGDBPaletteColor);
    function ColorComboBoxChange(Sender: TObject;colorBox:TComboBox;coloritemindex:integer):integer;

    procedure lineTypeComboBoxCreate(Sender: TObject;var lineTypeComboBox:TComboBox;itemtype:PGDBLtypeProp);
    function lineTypeComboBoxChange(Sender: TObject;lineTypeComboBox:TComboBox;index:integer):PGDBLtypeProp;

    procedure lineWeightComboBoxCreate(Sender: TObject;var lineWeightComboBox:TComboBox;itemLW:TGDBLineWeight);
    function lineWeightComboBoxChange(Sender: TObject;lineWeightComboBox:TComboBox;index:integer):TGDBLineWeight;

    ///********LINES**********///////
    procedure dlineColorComboBox(Sender: TObject);
    procedure dlineColorComboBoxChange(Sender: TObject);
    procedure dlineTypeComboBox(Sender: TObject);
    procedure dlineTypeComboBoxChange(Sender: TObject);
    procedure dlineWeightComboBoxCreate(Sender: TObject);
    procedure dlineWeightComboBoxChange(Sender: TObject);
    procedure lineDimDLEChange(Sender: TObject);
    procedure lineDimCENChange(Sender: TObject);

    procedure lineExtColorComboBoxCreate(Sender: TObject);
    procedure lineExtColorComboBoxChange(Sender: TObject);
    procedure lineExtLT1ComboBoxCreate(Sender: TObject);
    procedure lineExtLT1ComboBoxChange(Sender: TObject);  
    procedure lineExtLT2ComboBoxCreate(Sender: TObject);
    procedure lineExtLT2ComboBoxChange(Sender: TObject);
    procedure lineExtLWComboBoxCreate(Sender: TObject);
    procedure lineExtLWComboBoxChange(Sender: TObject);
    procedure lineExtSpinDIMEXEChange(Sender: TObject);
    procedure lineExtSpinDIMEXOChange(Sender: TObject);

    ///////********Arrows*********///////
    procedure ArrowsComboBoxCreate(Sender: TObject;var arrowsBox:TComboBox;arrowsIndex:TArrowStyle);
    procedure arrowsDIMBLK1ComboBoxCreate(Sender: TObject);
    procedure arrowsDIMBLK1ComboBoxChange(Sender: TObject);
    procedure arrowsDIMBLK2ComboBoxCreate(Sender: TObject);
    procedure arrowsDIMBLK2ComboBoxChange(Sender: TObject);
    procedure arrowsDIMLDRBLKComboBoxCreate(Sender: TObject);
    procedure arrowsDIMLDRBLKComboBoxChange(Sender: TObject);
    procedure arrowsDIMASZEditChange(Sender: TObject);


    procedure LineSheetContextPopup(Sender: TObject; MousePos: TPoint;
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

procedure TDimStyleEditForm.ColorComboBoxCreate(Sender: TObject;var colorBox:TComboBox;coloritem:TGDBPaletteColor);
var
    i:integer;
    isColor:boolean;
begin
    colorBox.Clear;
    colorBox.AddItem(GetColorNameFromIndex(256),Sender);
    colorBox.AddItem(GetColorNameFromIndex(0),Sender);
    for i:=1 to 7 do begin
       colorBox.AddItem(acadpalette[i].name,Sender);
    end;

    isColor:=true;
    for i:=0 to colorBox.Items.Count-1 do begin
       if GetColorNameFromIndex(coloritem) = colorBox.Items[i] then begin
          colorBox.ItemIndex := i;
          isColor:=false;
          end;
    end;

    if isColor then begin
       colorBox.AddItem(inttostr(coloritem),Sender);
       colorBox.ItemIndex := colorBox.Items.Count - 1;
    end;
    colorBox.AddItem('Other...',Sender);

end;
function TDimStyleEditForm.ColorComboBoxChange(Sender: TObject;colorBox:TComboBox;coloritemindex:integer):integer;
begin
    if colorBox.Items[coloritemindex] = 'Other...' then
      begin
         ZCMsgCallBackInterface.TextMessage('не работает',TMWOHistoryOut);
      end
    else
      case coloritemindex of
        0:
        //ZCMsgCallBackInterface.TextMessage('0',TMWOHistoryOut);
          result:= 256;
        1..8:
          //ZCMsgCallBackInterface.TextMessage('1-8',TMWOHistoryOut);
          result:= coloritemindex - 1;
      else
          result:= strtoint(string(colorBox.Items[coloritemindex]));
      end;

end;

procedure TDimStyleEditForm.lineTypeComboBoxCreate(Sender: TObject;var lineTypeComboBox:TComboBox;itemtype:PGDBLtypeProp);
var
   pdwg:PTSimpleDrawing;
   ir:itrec;
   pltp:PGDBLtypeProp;
   i:integer;
begin
    pdwg:=drawings.GetCurrentDWG;
     if (pdwg<>nil) then
     begin
       pltp:=pdwg^.LTypeStyleTable.beginiterate(ir);
       if pltp<>nil then
       repeat
            lineTypeComboBox.AddItem(Tria_AnsiToUtf8(pltp^.Name),Sender);
            pltp:=pdwg^.LTypeStyleTable.iterate(ir);
       until pltp=nil;
     end;

     for i:=0 to lineTypeComboBox.Items.Count-1 do begin
         if Tria_AnsiToUtf8(itemtype^.Name) = lineTypeComboBox.Items[i] then begin
            lineTypeComboBox.ItemIndex := i;
            end;
     end;

end;

function TDimStyleEditForm.lineTypeComboBoxChange(Sender: TObject;lineTypeComboBox:TComboBox;index:integer):PGDBLtypeProp;
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
            if Tria_AnsiToUtf8(pltp^.Name) = lineTypeComboBox.Items[index] then begin
               result := pltp;
               //ZCMsgCallBackInterface.TextMessage(dimStyle^.Lines.DIMLTYPE^.Name,TMWOHistoryOut);
            end;
            pltp:=pdwg^.LTypeStyleTable.iterate(ir);
       until pltp=nil;
     end;
end;

procedure TDimStyleEditForm.lineWeightComboBoxCreate(Sender: TObject;var lineWeightComboBox:TComboBox;itemLW:TGDBLineWeight);
var
   i:integer;
begin
     lineWeightComboBox.items.AddObject(rsByLayer,Sender);
     lineWeightComboBox.items.AddObject(rsByBlock,Sender);
     lineWeightComboBox.items.AddObject(rsdefault,Sender);
     for i := low(lwarray) to high(lwarray) do
     begin
          lineWeightComboBox.items.AddObject(GetLWNameFromN(i),Sender);
     end;


     lineWeightComboBox.ItemIndex:=0;

     for i := 0 to lineWeightComboBox.items.Count-1 do
     begin
          if lineWeightComboBox.items[i]=GetLWNameFromLW(itemLW) then
          begin
               lineWeightComboBox.ItemIndex:=i;
          end;
     end;
end;

function TDimStyleEditForm.lineWeightComboBoxChange(Sender: TObject;lineWeightComboBox:TComboBox;index:integer):TGDBLineWeight;
var
   i:integer;
begin
     //if rsByLayer = lineWeightComboBox.Items[index] then
               result:=-1;
     if rsByBlock = lineWeightComboBox.Items[index] then
               result:=-2;
     if rsdefault = lineWeightComboBox.Items[index] then
               result:=-3;

     for i := low(lwarray) to high(lwarray) do
       if GetLWNameFromN(i) = lineWeightComboBox.Items[index] then
                 result:=integer(lwarray[i]);
end;

procedure TDimStyleEditForm.ArrowsComboBoxCreate(Sender: TObject;var arrowsBox:TComboBox;arrowsIndex:TArrowStyle);
var
    i:integer;
    D: PTypeData;
    //i : integer;
  begin
    arrowsBox.Clear;
    D := GetTypeData(TypeInfo(TArrowStyle));
    for i := D^.MinValue to D^.MaxValue do
      arrowsBox.AddItem(GetEnumName(TypeInfo(TArrowStyle), i),Sender);
    arrowsBox.ItemIndex := Ord(arrowsIndex);
end;

procedure TDimStyleEditForm.dlineColorComboBox(Sender: TObject);
begin
    dlineColor.Clear;
    ColorComboBoxCreate(Sender,dlineColor,dimStyle^.Lines.DIMCLRD);
end;


procedure TDimStyleEditForm.dlineColorComboBoxChange(Sender: TObject);
begin
    dimStyle^.Lines.DIMCLRD:=ColorComboBoxChange(Sender,dlineColor,TComboBox(Sender).ItemIndex);
end;

procedure TDimStyleEditForm.lineExtColorComboBoxCreate(Sender: TObject);
begin
    lineExtColorComboBox.Clear;
    ColorComboBoxCreate(Sender,lineExtColorComboBox,dimStyle^.Lines.DIMCLRE);
end;

procedure TDimStyleEditForm.lineExtColorComboBoxChange(Sender: TObject);
begin
    dimStyle^.Lines.DIMCLRE:=ColorComboBoxChange(Sender,lineExtColorComboBox,TComboBox(Sender).ItemIndex);
end;

procedure TDimStyleEditForm.dlineTypeComboBox(Sender: TObject);
begin
    dlineType.Clear;
    lineTypeComboBoxCreate(Sender,dlineType,dimStyle^.Lines.DIMLTYPE);
end;

procedure TDimStyleEditForm.dlineTypeComboBoxChange(Sender: TObject);
begin
    dimStyle^.Lines.DIMLTYPE:= lineTypeComboBoxChange(Sender,dlineType,TComboBox(Sender).ItemIndex) ;
end;

procedure TDimStyleEditForm.lineExtLT1ComboBoxCreate(Sender: TObject);
begin
    lineExtLT1ComboBox.Clear;
    lineTypeComboBoxCreate(Sender,lineExtLT1ComboBox,dimStyle^.Lines.DIMLTEX1);
end;

procedure TDimStyleEditForm.lineExtLT1ComboBoxChange(Sender: TObject);
begin
    dimStyle^.Lines.DIMLTEX1:= lineTypeComboBoxChange(Sender,lineExtLT1ComboBox,TComboBox(Sender).ItemIndex) ;
end;

procedure TDimStyleEditForm.lineExtLT2ComboBoxCreate(Sender: TObject);
begin
    lineExtLT2ComboBox.Clear;
    lineTypeComboBoxCreate(Sender,lineExtLT2ComboBox,dimStyle^.Lines.DIMLTEX2);
end;

procedure TDimStyleEditForm.lineExtLT2ComboBoxChange(Sender: TObject);
begin
    dimStyle^.Lines.DIMLTEX2:= lineTypeComboBoxChange(Sender,lineExtLT2ComboBox,TComboBox(Sender).ItemIndex) ;
end;



procedure TDimStyleEditForm.dlineWeightComboBoxCreate(Sender: TObject);
begin
     dlineWeight.Clear;
     lineWeightComboBoxCreate(Sender,dlineWeight,dimStyle^.Lines.DIMLWD);
end;

procedure TDimStyleEditForm.dlineWeightComboBoxChange(Sender: TObject);
begin
      dimStyle^.Lines.DIMLWD:=lineWeightComboBoxChange(Sender,dlineWeight,TComboBox(Sender).ItemIndex);
end;



procedure TDimStyleEditForm.lineExtLWComboBoxCreate(Sender: TObject);
begin
     lineExtLWComboBox.Clear;
     lineWeightComboBoxCreate(Sender,lineExtLWComboBox,dimStyle^.Lines.DIMLWE);
end;

procedure TDimStyleEditForm.lineExtLWComboBoxChange(Sender: TObject);
begin
      dimStyle^.Lines.DIMLWE:=lineWeightComboBoxChange(Sender,lineExtLWComboBox,TComboBox(Sender).ItemIndex);
end;



procedure TDimStyleEditForm.lineDimDLEChange(Sender: TObject);
begin
     dimStyle^.Lines.DIMDLE:=lineDimDLE.Value;
end;

procedure TDimStyleEditForm.lineDimCENChange(Sender: TObject);
begin
     dimStyle^.Lines.DIMCEN:=lineDimCEN.Value;
end;

procedure TDimStyleEditForm.lineExtSpinDIMEXEChange(Sender: TObject);
begin
     dimStyle^.Lines.DIMEXE:=lineExtSpinDIMEXE.Value;
end;

procedure TDimStyleEditForm.lineExtSpinDIMEXOChange(Sender: TObject);
begin
     dimStyle^.Lines.DIMEXO:=lineExtSpinDIMEXO.Value;
end;


/////******arrows tab********///////
procedure TDimStyleEditForm.arrowsDIMBLK1ComboBoxCreate(Sender: TObject);
begin
     ArrowsComboBoxCreate(Sender,arrowsDIMBLK1ComboBox,dimStyle^.Arrows.DIMBLK1);
end;

procedure TDimStyleEditForm.arrowsDIMBLK1ComboBoxChange(Sender: TObject);
begin
  dimStyle^.Arrows.DIMBLK1:=TArrowStyle(TComboBox(Sender).ItemIndex);
end;

procedure TDimStyleEditForm.arrowsDIMBLK2ComboBoxCreate(Sender: TObject);
begin
     ArrowsComboBoxCreate(Sender,arrowsDIMBLK2ComboBox,dimStyle^.Arrows.DIMBLK2);
end;

procedure TDimStyleEditForm.arrowsDIMBLK2ComboBoxChange(Sender: TObject);
begin
  dimStyle^.Arrows.DIMBLK2:=TArrowStyle(TComboBox(Sender).ItemIndex);
end;

procedure TDimStyleEditForm.arrowsDIMLDRBLKComboBoxCreate(Sender: TObject);
begin
     ArrowsComboBoxCreate(Sender,arrowsDIMLDRBLKComboBox,dimStyle^.Arrows.DIMLDRBLK);
end;

procedure TDimStyleEditForm.arrowsDIMLDRBLKComboBoxChange(Sender: TObject);
begin
  dimStyle^.Arrows.DIMLDRBLK:=TArrowStyle(TComboBox(Sender).ItemIndex);
end;


procedure TDimStyleEditForm.arrowsDIMASZEditChange(Sender: TObject);
begin
     dimStyle^.Arrows.DIMASZ:=arrowsDIMASZEdit.Value;
end;

///******////


procedure TDimStyleEditForm.FormCreate(Sender: TObject);
//var
   //Transp : TStringList;
begin
   //TDimStyleEditForm.lineLayerView();

     LineSheet.Caption:='Lines';

     titelLabelLineDim.Caption:='Dimension lines:';

     dlineColorLabel.Caption:='Color:';
     dlineTypeLabel.Caption:='Linetype:';
     dlineWeightLabel.Caption:='Lineweight:';
     lineDimDLELabel.Caption:='Dimension line extension:';
     lineDimCENLabel.Caption:='Size of center mark:';

     dlineColorComboBox(Sender);
     dlineTypeComboBox(Sender);
     dlineWeightComboBoxCreate(Sender);
     lineDimDLE.Value:=dimStyle^.Lines.DIMDLE;
     lineDimCEN.Value:=dimStyle^.Lines.DIMCEN;

     titelLabelLineExt.Caption:='Extension lines:' ;

     lineExtColorLabel.Caption:='Color:';
     lineExtLT1Label.Caption:='Linetype ext line 1:';
     lineExtLT2Label.Caption:='Linetype ext line 2:';
     lineExtLWLabel.Caption:='Lineweight:';
     lineExtLabelDIMEXE.Caption:='Extend beyond dim lines:';
     lineExtLabelDIMEXO.Caption:='Offset from origin:';

     lineExtColorComboBoxCreate(Sender);
     lineExtLT1ComboBoxCreate(Sender);
     lineExtLT2ComboBoxCreate(Sender);
     lineExtLWComboBoxCreate(Sender);
     lineExtSpinDIMEXE.Value:=dimStyle^.Lines.DIMEXE;
     lineExtSpinDIMEXO.Value:=dimStyle^.Lines.DIMEXO;

     ///***Arrows***///
     ArrowsSheet.Caption:='Arrows';
     arrowsDIMBLK1Label.Caption:='Arrowheads first:';
     arrowsDIMBLK2Label.Caption:='Arrowheads second:';
     arrowsDIMLDRBLKLabel.Caption:='Arrowheads leader:';
     arrowsDIMASZLabel.Caption:='Arrow size';

     arrowsDIMBLK1ComboBoxCreate(Sender);
     arrowsDIMBLK2ComboBoxCreate(Sender);
     arrowsDIMLDRBLKComboBoxCreate(Sender);
     arrowsDIMASZEdit.Value:=dimStyle^.Arrows.DIMASZ;

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
      //ZCMsgCallBackInterface.TextMessage('1111111hf,jnftn',TMWOHistoryOut);
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


procedure TDimStyleEditForm.LineSheetContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

end.

