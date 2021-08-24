{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzcctrlcommandlineprompt;
{$ifdef fpc}{$mode delphi}{$H+}{$endif}

interface

uses
  Classes,StdCtrls,Graphics,Controls,
  LCLType,LCLProc,LCLIntf,Themes,Types,//System.Uitypes,
  Common.Graphics,uzeparsercmdprompt;

type
  TCommandLinePrompt=class(TCustomLabel)
    type
      TPromptResult=Integer;
      TPromptResults=array of TPromptResult;
    protected
      property Layout default tlCenter;
    public
      constructor Create(TheOwner: TComponent); override;
      procedure SetPrompt(const APrompt: String;ATPromptResults:TPromptResults);
      //procedure DoDrawText(var Rect: TRect; Flags: Longint);override;
      procedure Paint; override;
  end;

implementation

procedure TCommandLinePrompt.Paint;

var
  R: TRect;
  Highlight: THighlight;
  Item: THighlightItem;
  TestString:string;
begin
  //inherited;
  //exit;
  TestString:=GetLabelText;

  R := Rect(0,0,Width,Height);
  Canvas.Font.Color := clWindowText;
  //Canvas.Font.Size := 13;
  //DrawText(Canvas.Handle, PChar(TestString), Length(TestString), R, DT_SINGLELINE);

  //OffsetRect(R, 0, R.Height);
  //Canvas.Brush.Color := clBlack;
  //Canvas.FillRect(R);
 //Canvas.Font.Color := clWhite;
  Highlight := THighlight.Create;
  try
    // первая буква К
    Item := Highlight.AddHighlight;
    Item.FontColor := clRed;
    Item.Start := 3;
    Item.Len := 1;
    Item.BrushColor := clBtnFace;//RGB(112, 120, 129);
    Item.UseBrush := True;
    Item.FontUnderLine:=true;
    // оставшееся слово "оманда1"
    Item := Highlight.AddHighlight;
    Item.Start := 4;
    Item.Len := 7;
    Item.BrushColor := clBtnFace;//RGB(112, 120, 129);
    Item.UseBrush := True;

    // первая буква К
    Item := Highlight.AddHighlight;
    Item.FontColor := clRed;
    Item.Start := 12;
    Item.Len := 1;
    Item.BrushColor := clActiveCaption;//RGB(112, 120, 129);
    Item.UseBrush := True;
    Item.FontUnderLine:=true;
    // оставшееся слово "оманда2"
    Item := Highlight.AddHighlight;
    Item.Start := 13;
    Item.Len := 7;
    Item.BrushColor := clActiveCaption;//RGB(112, 120, 129);
    Item.UseBrush := True;

    // первая буква К
    Item := Highlight.AddHighlight;
    Item.FontColor := clRed;
    Item.Start := 21;
    Item.Len := 1;
    Item.BrushColor := clBtnFace;//RGB(112, 120, 129);
    Item.UseBrush := True;
    Item.FontUnderLine:=true;
    // оставшееся слово "оманда3"
    Item := Highlight.AddHighlight;
    Item.Start := 22;
    Item.Len := 7;
    Item.BrushColor := clBtnFace;//RGB(112, 120, 129);
    Item.UseBrush := True;

    // первая буква
    Item := Highlight.AddHighlight;
    Item.FontColor := clRed;
    Item.Start := 32;
    Item.Len := 1;
    Item.BrushColor := clBtnFace;//RGB(112, 120, 129);
    Item.UseBrush := True;
    // оставшееся слово
    Item := Highlight.AddHighlight;
    Item.Start := 33;
    Item.Len := 8;
    Item.BrushColor := clBtnFace;//RGB(112, 120, 129);
    Item.UseBrush := True;

    DrawHighlitedText(Canvas, TestString, R, DT_SINGLELINE, Highlight);
  finally
    Highlight.Free;
  end;
end;

constructor TCommandLinePrompt.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Layout:=tlCenter;
end;
procedure TCommandLinePrompt.SetPrompt(const APrompt: String;ATPromptResults:TPromptResults);
begin
  caption:=APrompt;
end;

end.
