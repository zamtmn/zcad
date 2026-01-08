unit uzcflinetypesload;
{$INCLUDE zengineconfig.inc}
interface

uses
  uzcdrawings,Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ButtonPanel, lclintf,lcltype, EditBtn, ComCtrls,uzedrawingsimple, uzcuilcl2zc;

type

  { TLineTypesLoadForm }

  TLineTypesLoadForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    FileNameEdit1: TFileNameEdit;
    ListView1: TListView;
    procedure _changefile(Sender: TObject);
    procedure _oncreate(Sender: TObject);
    function run(filename:string):integer;
    procedure LoadFromFile(filename:string);
    procedure _onSelect(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    { private declarations }
  public
    text:String;
    { public declarations }
  end;

var
  LineTypesLoadForm: TLineTypesLoadForm=nil;
implementation

{$R *.lfm}

{ TLineTypesLoadForm }
procedure TLineTypesLoadForm.LoadFromFile(filename:string);
var
   li:TListItem;
   ltd:TStringList;
   pdwg:PTSimpleDrawing;
   CurrentLine:integer;
   LTName,LTDesk,LTImpl:String;
begin
     ltd:=TStringList.Create;
     ltd.LoadFromFile(filename);
     ListView1.BeginUpdate;
     ListView1.Clear;
     pdwg:=drawings.GetCurrentDWG;

     CurrentLine:=1;
     repeat
     pdwg^.GetLTypeTable.ParseStrings(ltd,CurrentLine,LTName,LTDesk,LTImpl);
     LTName:={Tria_AnsiToUtf8}(LTName);
     LTDesk:={Tria_AnsiToUtf8}(LTDesk);
     LTImpl:={Tria_AnsiToUtf8}(LTImpl);
     if (LTName<>'')and(LTImpl<>'')then
     if (length(LTName)<200)and(length(LTImpl)<200)then
     begin
     li:=ListView1.Items.Add;
     li.Caption:=LTName;
     li.SubItems.Add(LTDesk);
     li.SubItems.Add(LTImpl);
     end;
     until CurrentLine>ltd.Count;
     ListView1.EndUpdate;
end;

procedure TLineTypesLoadForm._onSelect(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if selected then
  begin
       text:='*'+Item.Caption+','+Item.SubItems[0]+#13#10+'A,'+Item.SubItems[1];
  end
end;

procedure TLineTypesLoadForm._oncreate(Sender: TObject);
//var i:integer;
begin
     {ListBox1.items.AddObject(rsByLayer,TObject(2));
     ListBox1.items.AddObject(rsByBlock,TObject(1));
     ListBox1.items.AddObject(rsdefault,TObject(0));
     for i := low(lwarray) to high(lwarray) do
     begin
          ListBox1.items.AddObject(GetLWNameFromN(i),TObject(lwarray[i]+3));
     end;
     ListBox1.ItemIndex:=0;}
end;

procedure TLineTypesLoadForm._changefile(Sender: TObject);
begin
     text:='';
     LoadFromFile(FileNameEdit1.FileName);
end;

function TLineTypesLoadForm.run(filename:string):integer;
begin
     LoadFromFile(filename);
     FileNameEdit1.FileName:=filename;
     FileNameEdit1.InitialDir:=ExtractFilePath(filename);
     result:=TLCLModalResult2TZCMsgModalResult.Convert(showmodal);
end;

end.

