unit ViewCode;

interface

   uses
      DelphiCompat, LCLIntf, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, SynHighlighterPas, SynEdit, LCLType;

   type

      { TfrmViewCode }

      TfrmViewCode =
      class(TForm)
        SynEdit1: TSynEdit;
        SynPasSyn1: TSynPasSyn;
         procedure FormActivate(Sender: TObject);
         
         private
         { Private declarations }
         public
         { Public declarations }
      end;

implementation

   {$R *.lfm}

   procedure TfrmViewCode.FormActivate(Sender: TObject);
   var
      r  : TRect;
   begin
      {get size of desktop}
      {$ifdef LCLWin32}
      //todo: enable when SPI_GETWORKAREA is implemented
      SystemParametersInfo(SPI_GETWORKAREA, 0, @r, 0);
      Height := r.Bottom-Top;
      Width  := r.Right-Left;
      {$endif}
   end;

end.
