unit lineweightwnd;
{$INCLUDE def.inc}
interface

uses
  gdbase,zcadstrconsts,Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ButtonPanel, StdCtrls, types, lclintf,lcltype;

type

  { TLineWeightSelectWND }

  TLineWeightSelectWND = class(TForm)
    ButtonPanel1: TButtonPanel;
    ListBox1: TListBox;
    procedure _oncreate(Sender: TObject);
    procedure _onDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
      State: TOwnerDrawState);
    procedure _onSelChg(Sender: TObject; User: boolean);
  private
    { private declarations }
  public
    SelectedLW:Smallint;
    { public declarations }
  end;
const
  lwarray:array [1..24] of integer=(0,5,9,13,15,18,20,25,30,35,40,50,53,60,70,80,90,100,106,120,140,158,200,211);
  ColorBoxDifferent=258;
  ColorBoxSelColor=257;

var
  LineWeightSelectWND: TLineWeightSelectWND=nil;
  function GetLWNameFromN(num:integer):String;
  function GetLWNameFromLW(lw:integer):String;
  function GetColorNameFromIndex(index:integer):String;
implementation

function GetLWNameFromN(num:integer):String;
begin
     result:=FloatToStrF(lwarray[num]/100,ffFixed,4,2) + ' '+rsmm;
end;
function GetLWNameFromLW(lw:integer):String;
begin
 case lw of
              -3:
                result:=rsDefault;
              -2:
                result:=rsByBlock;
              -1:
                result:=rsByLayer;
ColorBoxDifferent-3:
                result:=rsDifferent;
              else
                  begin
                       result:=FloatToStrF(lw/100,ffFixed,4,2) + ' '+rsmm;;
                  end;
 end;
end;
function GetColorNameFromIndex(index:integer):String;
begin
case index of
             0:
               result:=rsByBlock;
           256:
               result:=rsByLayer;
        1..255:
               result:=palette[index].name;
ColorBoxSelColor:
               result:=rsSelectColor;
ColorBoxDifferent:
               result:=rsDifferent;
end;
end;

{ TLineWeightSelectWND }

procedure TLineWeightSelectWND._oncreate(Sender: TObject);
var i:integer;
begin
     ListBox1.items.AddObject(rsByLayer,TObject(2));
     ListBox1.items.AddObject(rsByBlock,TObject(1));
     ListBox1.items.AddObject(rsdefault,TObject(0));
     for i := low(lwarray) to high(lwarray) do
     begin
          ListBox1.items.AddObject(GetLWNameFromN(i),TObject(lwarray[i]+3));
     end;
     ListBox1.ItemIndex:=0;
end;

procedure TLineWeightSelectWND._onDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s:string;
  y,pw:integer;
const
    ll=120;
begin
 index:=integer(TListBox(Control).items.Objects[Index]);
 case index of
              0:
                s:=rsDefault;
              1:
                s:=rsByBlock;
              2:
                s:=rsByLayer;
{ColorBoxDifferent:
                s:=rsDifferent;}
              else
                  begin
                       s:=GetLWNameFromLW(index-3);
                  end;
 end;
  ARect.Left:=ARect.Left+2;
  if (index>2){and(index<ColorBoxDifferent)} then
   begin
        pw:=(index-3) div 10;
        if pw>12 then
                    pw:=12;
        TListBox(Control).canvas.Pen.Width:=pw;
        TListBox(Control).canvas.Pen.Style:=psSolid;
        TListBox(Control).canvas.Pen.EndCap:=pecFlat;
        pw:=pw div 2;
        y:=(ARect.Top+ARect.Bottom)div 2;
        TListBox(Control).canvas.Line(ARect.Left,y,ARect.Left+ll,y);
        ARect.Left:=ARect.Left+ll+5;
   end;
  DrawText(TListBox(Control).canvas.Handle,@s[1],length(s),arect,DT_LEFT or DT_VCENTER)
end;

procedure TLineWeightSelectWND._onSelChg(Sender: TObject; User: boolean);
begin
     SelectedLW:=integer(ListBox1.items.Objects[ListBox1.ItemIndex])-3;
end;

initialization
  {$I lineweightwnd.lrs}

end.

