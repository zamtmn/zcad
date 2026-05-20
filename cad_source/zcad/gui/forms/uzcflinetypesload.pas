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

procedure TLineTypesLoadForm.LoadFromFile(FileName:string);
var
  FileStream:TFileStream;
  Buffer:TBytes;
  BytesRead:integer;
  AEncoding:TEncoding;
  li:TListItem;
  ltd:TStringList;
  pdwg:PTSimpleDrawing;
  CurrentLine:integer;
  LTName,LTDesk,LTImpl:string;
begin
  AEncoding:=nil;
  ltd:=TStringList.Create;
  try
    FileStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
    try
      //пытаемся прочитать BOM
      SetLength(Buffer,4);
      BytesRead:=FileStream.Read(Buffer[0],4);
      if BytesRead>=2 then begin
        SetLength(Buffer,BytesRead);
        TEncoding.GetBufferEncoding(Buffer,AEncoding,nil);
      end;

      //если был BOM становимся за него, если нет выставляем системную кодировку
      if AEncoding=nil then begin
        AEncoding:={$IfDef WINDOWS}TEncoding.ANSI{$ElseIf}TEncoding.UTF8{$endif};
        FileStream.Seek(0,soBeginning);
      end else
        FileStream.Seek(Length(AEncoding.GetPreamble),soBeginning);

      ltd.LoadFromStream(FileStream,AEncoding);
    finally
      FileStream.Free;
    end;

    ListView1.BeginUpdate;
    ListView1.Clear;
    pdwg:=drawings.GetCurrentDWG;

    CurrentLine:=1;
    repeat
      pdwg^.GetLTypeTable.ParseStrings(ltd,CurrentLine,LTName,LTDesk,LTImpl);
      if (LTName<>'')and(LTImpl<>'') then
        if (length(LTName)<200)and(length(LTImpl)<200) then begin
          li:=ListView1.Items.Add;
          li.Caption:=LTName;
          li.SubItems.Add(LTDesk);
          li.SubItems.Add(LTImpl);
        end;
    until CurrentLine>ltd.Count;
    ListView1.EndUpdate;
  finally
    ltd.Free;
  end;
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
     //LoadFromFile(filename);
     FileNameEdit1.FileName:=filename;
     FileNameEdit1.InitialDir:=ExtractFilePath(filename);
     result:=TLCLModalResult2TZCMsgModalResult.Convert(showmodal);
end;

end.

