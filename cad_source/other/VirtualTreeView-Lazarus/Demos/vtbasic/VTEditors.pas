unit VTEditors;

{$mode delphi}
{$H+}

// Utility unit for the advanced Virtual Treeview demo application which contains the implementation of edit link
// interfaces used in other samples of the demo.

interface

   uses
      LCLIntf,LCLType, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
      StdCtrls, VirtualTrees, ExtDlgs, Buttons, ExtCtrls, ComCtrls, MaskEdit, LResources, EditBtn;

   type
      // Describes the type of value a property tree node stores in its data property.
      TValueType = 
      (
         vtNone,
         vtString,
         vtPickString,
         vtNumber,
         vtPickNumber,
         vtMemo,
         vtDate
      );

   type
      // Node data record for the the document properties treeview.
      TPropertyData = 
      record
         ValueType: TValueType;
         Value    : String;      // This value can actually be a date or a number too.
         Changed  : Boolean;
      end;
      PPropertyData = ^TPropertyData;

      // Our own edit link to implement several different node editors.

      { TPropertyEditLink }

      TPropertyEditLink =
      class(TInterfacedObject, IVTEditLink)
         private
         FEdit: TWinControl;        // One of the property editor classes.
         FTree: TVirtualStringTree; // A back reference to the tree calling.
         FNode: PVirtualNode;       // The node being edited.
         FColumn: Integer;          // The column of the node being edited.
         FOldEditProc: TWndMethod;  // Used to capture some important messages
                   // regardless of the type of edit control we use.
         FListItems  : TStringList;        // One of the property editor classes.
                   
         protected
         procedure EditWindowProc(var Message: TMessage);
         procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

         public
         constructor Create;
         destructor Destroy; override;

         function BeginEdit: Boolean; stdcall;
         function CancelEdit: Boolean; stdcall;
         function EndEdit: Boolean; stdcall;
         function GetBounds: TRect; stdcall;
         function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
         procedure ProcessMessage(var Message: TMessage); stdcall;
         procedure SetBounds(R: TRect); stdcall;
      end;

   type
      TPropertyTextKind = 
      (
         ptkText,
         ptkHint
      );

      TGridData = 
      record
         ValueType: array[0..3] of TValueType; // one for each column
         Value    : array[0..3] of Variant;
         Changed  : Boolean;
      end;
      PGridData = ^TGridData;

      // Our own edit link to implement several different node editors.
      TGridEditLink = 
      class(TPropertyEditLink, IVTEditLink)
         public
         function EndEdit: Boolean; stdcall;
         function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
      end;

   function ShowForm( afc : TFormClass; iLeft : integer = -1; iTop : integer = -1 ) : TForm;
   function FindAppForm ( afc : TFormClass ) : TForm;
   procedure ConvertToHighColor(ImageList: TImageList);
      
implementation

   //uses
   //   CommCtrl;
   (*
   uses
      PropertiesDemo, GridDemo;
   *)      

   {---------------------------------------------------------------
                     utility functions
   ---------------------------------------------------------------}
   function ShowForm( afc : TFormClass; iLeft : integer = -1; iTop : integer = -1 ) : TForm;
   begin        
      Result := FindAppForm( afc );
      if Result = nil then 
      begin
         Result := afc.Create(Application);
         if (iLeft <> -1) then Result.left  := iLeft;
         if (iTop  <> -1) then Result.top   := iTop ;
      end;   
      Result.Show;
   end;         

   
   function FindAppForm ( afc : TFormClass ) : TForm;
   var
      i : integer;
   begin
      Result := nil;
      for i := Screen.FormCount-1 downto 0 do
      begin
         if (Screen.Forms[i] is afc) then
         begin
            Result := Screen.Forms[i];
            break;
         end;   
      end;   
   end;   
   
   procedure ConvertToHighColor(ImageList: TImageList);
   // To show smooth images we have to convert the image list from 16 colors to high color.
   var
     IL: TImageList;
   begin
     //todo: properly implement
     // Have to create a temporary copy of the given list, because the list is cleared on handle creation.
     {
     IL := TImageList.Create(nil);
     IL.Assign(ImageList);


     //with ImageList do
     //  Handle := ImageList_Create(Width, Height, ILC_COLOR16 or ILC_MASK, Count, AllocBy);
     ImageList.Assign(IL);
     IL.Free;
     }
   end;
   
   (*-------------------------------------------------------------------
                        TPropertyEditLink
   -------------------------------------------------------------------*)
   // This implementation is used in VST3 to make a connection beween the tree
   // and the actual edit window which might be a simple edit, a combobox or a memo etc.
   constructor TPropertyEditLink.Create;
   begin
      inherited;
      FListItems  := TStringList.Create;        // One of the property editor classes.
   end;

   destructor TPropertyEditLink.Destroy;
   begin
      FEdit.Parent := nil;
      FEdit.Free;
      FListItems.Free;
      inherited;
   end;

   
   function TPropertyEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
   var
     Data: PPropertyData;
   begin
     Result := True;
     FTree := Tree as TVirtualStringTree;
     FNode := Node;
     FColumn := Column;

     // determine what edit type actually is needed
     FEdit.Free;
     FEdit := nil;
     Data := FTree.GetNodeData(Node);
     case Data.ValueType of
       vtString:
         begin
           FEdit := TEdit.Create(nil);
           with FEdit as TEdit do
           begin
             Visible := False;
             Parent := Tree;
             Text := Data.Value;
             BorderStyle := bsNone;
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtPickString:
         begin
           FEdit := TComboBox.Create(nil);
           with FEdit as TComboBox do
           begin
             //BorderStyle := bsNone;
             Visible := False;
             Parent := Tree;
             Text := Data.Value;
             Items.Add(Text);
             Items.Add('Standard');
             Items.Add('Additional');
             Items.Add('Win32');
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtNumber:
         begin
           FEdit := TMaskEdit.Create(nil);
           with FEdit as TMaskEdit do
           begin
             BorderStyle := bsNone;
             Visible := False;
             Parent := Tree;
             EditMask := '9999';
             Text := Data.Value;
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtPickNumber:
         begin
           FEdit := TComboBox.Create(nil);
           with FEdit as TComboBox do
           begin
             //BorderStyle := bsNone;
             Visible := False;
             Parent := Tree;
             Text := Data.Value;
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtMemo:
         begin
           FEdit := TComboBox.Create(nil);
           // In reality this should be a drop down memo but this requires a special control.
           with FEdit as TComboBox do
           begin
             //BorderStyle := bsNone;
             Visible := False;
             Parent := Tree;
             Text := Data.Value;
             Items.Add(Data.Value);
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtDate:
         begin
           FEdit := TDateEdit.Create(nil);
           with FEdit as TDateEdit do
           begin
             //BorderStyle := bsNone;
             Visible := False;
             Parent := Tree;

             {
             CalColors.MonthBackColor := clWindow;
             CalColors.TextColor := clBlack;
             CalColors.TitleBackColor := clBtnShadow;
             CalColors.TitleTextColor := clBlack;
             CalColors.TrailingTextColor := clBtnFace;
             }
             Date := StrToDate(Data.Value);
             OnKeyDown := EditKeyDown;
           end;

         end;
     else
       Result := False;
     end;
   end;

   
   procedure TPropertyEditLink.EditWindowProc(var Message: TMessage);
   // Here we can capture messages for keeping track of focus changes.
   begin
     case Message.Msg of
       WM_KILLFOCUS:
         if FEdit is TDateEdit then
         begin
           //todo
           {
           // When the user clicks on a dropped down calender we also get
           // the kill focus message.
           if not TDateTimePicker(FEdit).DroppedDown then}
             FTree.EndEditNode;
         end
         else
           FTree.EndEditNode;
     else
       FOldEditProc(Message);
     end;
   end;

   function TPropertyEditLink.BeginEdit: Boolean;
   begin
     Result := True;
     FEdit.Show;
     FEdit.SetFocus;
     // Set a window procedure hook (aka subclassing) to get notified about important messages.
     FOldEditProc := FEdit.WindowProc;
     FEdit.WindowProc := EditWindowProc;
   end;

   function TPropertyEditLink.CancelEdit: Boolean;
   begin
     Result := True;
     // Restore the edit's window proc.
     FEdit.WindowProc := FOldEditProc;
     FEdit.Hide;
   end;

   function TPropertyEditLink.EndEdit: Boolean;
   var
     Data: PPropertyData;
     Buffer: array[0..1024] of Char;
     S: String;
     P: TPoint;
     Dummy: Integer;
   begin
     // Check if the place the user click on yields another node as the one we
     // are currently editing. If not then do not stop editing.
     GetCursorPos(P);
     P := FTree.ScreenToClient(P);
     Result := FTree.GetNodeAt(P.X, P.Y, True, Dummy) <> FNode;

     if Result then
     begin
       // restore the edit's window proc
       FEdit.WindowProc := FOldEditProc;
       Data := FTree.GetNodeData(FNode);
       //original
       {
       if FEdit is TComboBox then
         S := TComboBox(FEdit).Text
       else
       begin
         GetWindowText(FEdit.Handle, Buffer, 1024);
         S := Buffer;
       end;
       }
       //lcl
       case Data.ValueType of
         vtString: S:= TEdit(FEdit).Text;
         vtPickString, vtMemo: S:= TComboBox(FEdit).Text;
         vtNumber: S:= TMaskEdit(FEdit).Text;
         vtDate: S:= TDateEdit(FEdit).Text;
         else
           S:='BUG - Error getting value';
       end;
       
       if S <> Data.Value then
       begin
         Data.Value := S;
         Data.Changed := True;
         FTree.InvalidateNode(FNode);
       end;
       FEdit.Hide;
     end;
   end;

   
   procedure TPropertyEditLink.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
   var
     CanAdvance: Boolean;
   begin
     case Key of
       VK_RETURN,
       VK_UP,
       VK_DOWN:
         begin
           // Consider special cases before finishing edit mode.
           CanAdvance := Shift = [];
           if FEdit is TComboBox then
             CanAdvance := CanAdvance and not TComboBox(FEdit).DroppedDown;
           //todo
           //if FEdit is TDateEdit then
           //  CanAdvance :=  CanAdvance and not TDateEdit(FEdit).DroppedDown;

           if CanAdvance then
           begin
             FTree.EndEditNode;
             with FTree do
             begin
               if Key = VK_UP then
                 FocusedNode := GetPreviousVisible(FocusedNode)
               else
                 FocusedNode := GetNextVisible(FocusedNode);
               Selected[FocusedNode] := True;
             end;
             Key := 0;
           end;
         end;
     end;
   end;

   procedure TPropertyEditLink.ProcessMessage(var Message: TMessage);
   begin
     FEdit.WindowProc(Message);
   end;

   function TPropertyEditLink.GetBounds: TRect;
   begin
     Result := FEdit.BoundsRect;
   end;

   procedure TPropertyEditLink.SetBounds(R: TRect);
   var
     Dummy: Integer;
   begin
     // Since we don't want to activate grid extensions in the tree (this would influence how the selection is drawn)
     // we have to set the edit's width explicitly to the width of the column.
     FTree.Header.Columns.GetColumnBounds(FColumn, Dummy, R.Right);
     FEdit.BoundsRect := R;
   end;

   (*-------------------------------------------------------------------
                           TGridEditLink 
   -------------------------------------------------------------------*)
   function TGridEditLink.EndEdit: Boolean;
   var
     Data: PGridData;
     Buffer: array[0..1024] of Char;
     S: String;
     I: Integer;
  
   begin
     Result := True;
     // Restore the edit's window proc.
     FEdit.WindowProc := FOldEditProc;
     Data := FTree.GetNodeData(FNode);
     if FEdit is TComboBox then
     begin
       S := TComboBox(FEdit).Text;
       if S <> Data.Value[FColumn - 1] then
       begin
         Data.Value[FColumn - 1] := S;
         Data.Changed := True;
       end;
     end
     else
       if FEdit is TMaskEdit then
       begin
         I := StrToInt(Trim(TMaskEdit(FEdit).EditText));
         if I <> Data.Value[FColumn - 1] then
         begin
           Data.Value[FColumn - 1] := I;
           Data.Changed := True;
         end;
       end
       else
         if FEdit is TCustomEdit then
         begin
           S := TCustomEdit(FEdit).Text;
           if S <> Data.Value[FColumn - 1] then
           begin
             Data.Value[FColumn - 1] := S;
             Data.Changed := True;
           end;
           {
           GetWindowText(FEdit.Handle, Buffer, 1024);
           S := Buffer;
           if S <> Data.Value[FColumn - 1] then
           begin
             Data.Value[FColumn - 1] := S;
             Data.Changed := True;
           end;
           }
         end;

     if Data.Changed then
       FTree.InvalidateNode(FNode);
     FEdit.Hide;
   end;

   function TGridEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
   var
     Data: PGridData;
     //todo: fpc does not accept variant to TTransLateString
     TempText: String;
   begin
     Result := True;
     FTree := Tree as TVirtualStringTree;
     FNode := Node;
     FColumn := Column;

     // Determine what edit type actually is needed.
     FEdit.Free;
     FEdit := nil;
     Data := FTree.GetNodeData(Node);
     case Data.ValueType[FColumn - 1] of
       vtString:
         begin
           FEdit := TEdit.Create(nil);
           with FEdit as TEdit do
           begin
             Visible := False;
             Parent := Tree;
             TempText:= Data.Value[FColumn - 1];
             Text := TempText;
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtPickString:
         begin
           FEdit := TComboBox.Create(nil);
           with FEdit as TComboBox do
           begin
             Visible := False;
             Parent := Tree;
              TempText:= Data.Value[FColumn - 1];
             Text := TempText;
             // Here you would usually do a lookup somewhere to get
             // values for the combobox. We only add some dummy values.
             case FColumn of
               2:
                 begin
                   Items.Add('John');
                   Items.Add('Mike');
                   Items.Add('Barney');
                   Items.Add('Tim');
                 end;
               3:
                 begin
                   Items.Add('Doe');
                   Items.Add('Lischke');
                   Items.Add('Miller');
                   Items.Add('Smith');
                 end;
             end;
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtNumber:
         begin
           FEdit := TMaskEdit.Create(nil);
           with FEdit as TMaskEdit do
           begin
             Visible := False;
             Parent := Tree;
             EditMask := '9999;0; ';
              TempText:= Data.Value[FColumn - 1];
             Text := TempText;
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtPickNumber:
         begin
           FEdit := TComboBox.Create(nil);
           with FEdit as TComboBox do
           begin
             Visible := False;
             Parent := Tree;
              TempText:= Data.Value[FColumn - 1];
             Text := TempText;
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtMemo:
         begin
           FEdit := TComboBox.Create(nil);
           // In reality this should be a drop down memo but this requires
           // a special control.
           with FEdit as TComboBox do
           begin
             Visible := False;
             Parent := Tree;
              TempText:= Data.Value[FColumn - 1];
             Text := TempText;
             Items.Add(Data.Value[FColumn - 1]);
             OnKeyDown := EditKeyDown;
           end;
         end;
       vtDate:
         begin
           FEdit := TDateEdit.Create(nil);
           with FEdit as TDateEdit do
           begin
             Visible := False;
             Parent := Tree;
             {
             CalColors.MonthBackColor := clWindow;
             CalColors.TextColor := clBlack;
             CalColors.TitleBackColor := clBtnShadow;
             CalColors.TitleTextColor := clBlack;
             CalColors.TrailingTextColor := clBtnFace;
             }
             Date := StrToDate(Data.Value[FColumn - 1]);
             OnKeyDown := EditKeyDown;
           end;

         end;
     else
       Result := False;
     end;
   end;



end.
