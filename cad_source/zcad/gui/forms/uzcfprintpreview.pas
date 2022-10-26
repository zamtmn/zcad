unit uzcfPrintPreview;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uzcinterface, uzccommandsabstract, uzbtypes, uzccommandsimpl;

type

  { TPreviewForm }

  TPreviewForm = class(TForm)
    Image1: TImage;
  private

  public

  end;

var
  PreviewForm: TPreviewForm;

implementation

{$R *.lfm}

end.

