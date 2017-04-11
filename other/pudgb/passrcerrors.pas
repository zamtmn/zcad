program test;
procedure TFMain_SelectFontEditorClick(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    FEditors.Editors.Font.Assign(FontDialog1.Font);
    FTune.SpinEditSizeFont.Value:=FontDialog1.Font.Size;
    Color3:=FontDialog1.Font.Color;
  end  else begin end;
end;

begin
end.
