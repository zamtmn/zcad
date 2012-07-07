unit umainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  {From ZCAD}
  oglwindow;

type

  { TForm1 }

  TForm1 = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

end.

