{***********************************************************************  }
{ File: VTCheckList.pas                                                   }
{                                                                         }
{ Purpose:                                                                }
{       source file to demonstrate how to get started with VT (2)         }
{       <-- Generic CheckListbox selection Form - no node data used -->   }
{                                                                         }
{ Module Record:                                                          }
{                                                                         }
{ --------     --  --------------------------------------                 }
{ 05-Nov-2002  TC  Created  (tomc@gripsystems.com)                        }
{**********************************************************************}
unit VTCheckList;

{$mode delphi}
{$H+}

interface

   uses
      Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, VirtualTrees, ImgList, ExtCtrls, StdCtrls, Buttons, LResources;

   type
      TfrmVTCheckList =
      class(TForm)
         Panel1   : TPanel;
         VT       : TVirtualStringTree;
         panBase  : TPanel;
         btnOk: TButton;
         btnCancel: TButton;

         procedure FormCreate(Sender: TObject);
         procedure FormDestroy(Sender: TObject);
         procedure FormActivate(Sender: TObject);
         
         procedure VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
         procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
         Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
         procedure VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
         procedure btnOkClick(Sender: TObject);
    
         private
         FCaptions : TStringList;

         function GetSelections : string;
      end;

   procedure DoVTCheckListExample;
   function DoVTCheckList( sl : TStringList; var sSelections : string ) : boolean;
      
implementation
   {$R *.lfm}

   procedure DoVTCheckListExample;
   var
      sl : TStringList; 
      sSelections : string;
   begin
      sl := TStringList.Create; 
      try
         sl.Add( 'Willy Wonka'      );
         sl.Add( 'Bill Gates'       );
         sl.Add( 'Silly Billy'      );
         sl.Add( 'Homer Simpson'    );
         sl.Add( 'Harry Potty'      );
         sl.Add( 'Dilbert'          );
         sl.Add( 'Gandalf'          );
         sl.Add( 'Darth Laugh'      );
         sl.Add( 'Tim nice-but-dim' );
         
         if DoVTCheckList( sl, sSelections ) then
            ShowMessage( Format( 'You selected: %s', [sSelections] ));

      finally
         sl.Free;
      end;
   end;   
   
   function DoVTCheckList( sl : TStringList; var sSelections : string ) : boolean;
   begin
      Result := False;
      
      with TfrmVTCheckList.Create(Application) do
      begin
         try
            FCaptions.Assign(sl);
            if (ShowModal=mrOk) then
            begin
               Result      := True;
               sSelections := GetSelections;
            end;   
            
         finally
            Release;
         end;
      end;   
   
   end;   
                         
   procedure TfrmVTCheckList.FormCreate(Sender: TObject);
   begin
      {set up root values + turn on checklist support}
      FCaptions := TStringList.Create;
      VT.TreeOptions.MiscOptions := VT.TreeOptions.MiscOptions + [toCheckSupport];
   end;

   procedure TfrmVTCheckList.FormDestroy(Sender: TObject);
   begin
      FCaptions .Free;
   end;

   procedure TfrmVTCheckList.FormActivate(Sender: TObject);
   begin
      VT.RootNodeCount := FCaptions.Count;
   end;
   
   procedure TfrmVTCheckList.VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
   begin
      NodeDataSize := 0;                                           {note *** no node data used *** }
   end;

   procedure TfrmVTCheckList.VTInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
   begin
      Node.CheckType := ctCheckBox;                            {we will have checkboxes throughout}
   end;

   procedure TfrmVTCheckList.VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
     Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
   begin     
      Celltext := FCaptions[Node.Index];                                           {top-level} 
   end;
  
   procedure TfrmVTCheckList.btnOkClick(Sender: TObject);
   begin
      if GetSelections <> '' then
         ModalResult := mrOk
      else
         ShowMessage( 'Please select 1 or more options' );
   end;
  
   function TfrmVTCheckList.GetSelections : string;
   var
      node  : PVirtualNode;
   begin
      Result:= '';
      node  := VT.RootNode;
      while Assigned(Node) do
      begin
         if node.CheckState in [ csCheckedNormal, csMixedPressed ] then
            Result := Result + IntToStr( Node.Index ) + ',';

         node := VT.GetNext(node);
      end;

      {-------------------------------------------------------------
      example using 'selected' instead of testing for 'checked'
      
      Node  := VT.GetFirstSelected;
      while Assigned(Node) do
      begin
         Result := Result + ',' + IntToStr( Node.Index );
         Node := VT.GetNextSelected(Node);
      end;         
      ------------------------------------------------------------}
   end;   

end.

