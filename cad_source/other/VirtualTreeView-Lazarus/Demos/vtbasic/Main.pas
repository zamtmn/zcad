{***********************************************************************   }
{ File: Main.pas                                                           }
{                                                                          }
{ Purpose:                                                                 }
{           main source file to demonstrate how to get started with VT (1) }
{           <--  Basic VT as a Listbox (no node data used) -->             }
{                                                                          }
{ Module Record:                                                           }
{                                                                          }
{  Date        AP  Details                                                 }
{ --------     --  --------------------------------------                  }
{ 05-Nov-2002  TC  Created  (tomc@gripsystems.com)                         }
{**********************************************************************}
unit Main;

{$mode delphi}
{$H+}

interface

   uses
      LCLIntf, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, VirtualTrees, ExtCtrls, StdCtrls, Buttons, LResources;

   type
TfrmMain =
      class(TForm)
         imgMaster: TImageList;
         panMain: TPanel;
         VT: TVirtualStringTree;
         panBase: TPanel;
         chkRadioButtons: TCheckBox;
         chkChangeHeight: TCheckBox;
         chkHotTrack: TCheckBox;
         Label1: TLabel;
         btnViewCode: TSpeedButton;
         
         procedure FormCreate(Sender: TObject);
         procedure FormDestroy(Sender: TObject);
         
         procedure VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
         procedure VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
         procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
         var CellText: String);
         procedure VTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
         Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
         procedure VTDblClick(Sender: TObject);
         procedure chkRadioButtonsClick(Sender: TObject);
         procedure VTFocusChanging(Sender: TBaseVirtualTree; OldNode, NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
         var Allowed: Boolean);
         procedure chkChangeHeightClick(Sender: TObject);
         procedure chkHotTrackClick(Sender: TObject);
         procedure btnViewCodeClick(Sender: TObject);
    
         private
         FCaptions   : TStringList;
      end;

   var
      frmMain: TfrmMain;

implementation

   {$R *.lfm}


   uses
      VTNoData, VTCheckList, VTPropEdit, VTDBExample, VTEditors, ViewCode;

   procedure TfrmMain.FormCreate(Sender: TObject);
   begin
      Top := 0;
      Left:= 0;
      

      {let's make some data to display - it's going to come from somewhere}
      FCaptions   := TStringList.Create;
      
      FCaptions.Add( 'Basic VT as a Listbox (no node data used)'              );
      FCaptions.Add( 'Basic VT as a Tree    (no node data used)'              );
      FCaptions.Add( 'Generic CheckListbox selection Form (no node data used)');
      FCaptions.Add( 'Dynamic Property Editor example 1.'                     );
      FCaptions.Add( 'Database example 1.'                                    );

      {this is first important value to set, 0 is ok if you want to use AddChild later}
      VT.RootNodeCount := FCaptions.Count;
   end;

   procedure TfrmMain.FormDestroy(Sender: TObject);
   begin
      FCaptions.Free;
   end;
   
   procedure TfrmMain.VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
   {--------------------------------------------------------------------------------------------
   note zero node data size - you don't *have* to store data in the node. Maybe this is very likely 
   if you are dealing with a list with no children that can be directly indexed into via Node.Index
   ---------------------------------------------------------------------------------------------}
   begin
      NodeDataSize := 0;     
   end;

   procedure TfrmMain.VTInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
   begin
      Node.CheckType := ctRadioButton;  {must enable toCheckSupport in TreeOptions.MiscOptions}
   end;
   
   procedure TfrmMain.VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
     Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
   begin
      Celltext := FCaptions[Node.Index];           {this is where we say what the text to display}
   end;

   procedure TfrmMain.VTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; 
         Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
   begin
      ImageIndex  := Node.Index;                       {this is where we say what image to display}
   end;         

   procedure TfrmMain.VTDblClick(Sender: TObject);
   begin 
      //showform is a utility routine for this app - in vteditors.pas
      case VT.FocusedNode.Index of
         0: ShowMessage( 'This is it...!' );                                 // Main.pas
         1: ShowForm( TfrmVTNoData, Left, Height );                          // VTNoData.pas
         2: DoVTCheckListExample;                                            // VTCheckList.pas
         3: ShowForm( TfrmVTPropEdit,  Left + Width, Top );                  // VTPropEdit.pas
         4: ShowForm( TfrmVTDBExample, Left + Width, Top );                  // VTDBExample.pas      
      end;         
   end;
   
   procedure TfrmMain.chkHotTrackClick(Sender: TObject);
   begin
      with VT.TreeOptions do 
      begin
         if chkHotTrack.checked then
            PaintOptions := PaintOptions + [toHotTrack]
         else            
            PaintOptions := PaintOptions - [toHotTrack];
            
         VT.Refresh;
      end;   
   end;
   
   procedure TfrmMain.chkRadioButtonsClick(Sender: TObject);
   begin
      with VT.TreeOptions do 
      begin
         if chkRadioButtons.checked then
            MiscOptions := MiscOptions + [toCheckSupport]
         else            
            MiscOptions := MiscOptions - [toCheckSupport];
            
         VT.Refresh;
      end;   
   end;

   procedure TfrmMain.VTFocusChanging(Sender: TBaseVirtualTree; OldNode,
     NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
     var Allowed: Boolean);
   begin
      {example of dynamically changing height of node}
      if chkChangeHeight.checked then
      begin
         Sender.NodeHeight[OldNode] := 20;
         Sender.NodeHeight[NewNode] := 40;
      end;   
   end;

   procedure TfrmMain.chkChangeHeightClick(Sender: TObject);
   begin   
      {example of resetting dynamically changing node heights}
      if not chkChangeHeight.checked then with VT do
      begin
         NodeHeight[FocusedNode] := 20;
         InvalidateNode(FocusedNode);
      end;   
   end;


   procedure TfrmMain.btnViewCodeClick(Sender: TObject);
   var
      sFile : string;
      f     : TForm;
   begin
      if VT.FocusedNode = nil then
        Exit;
      case VT.FocusedNode.Index of
         0: sFile := 'Main'        ;
         1: sFile := 'VTNoData'    ;
         2: sFile := 'VTCheckList' ;
         3: sFile := 'VTPropEdit'  ;
         4: sFile := 'VTDBExample' ;
      end;
      f := ShowForm( TfrmViewCode, Left, Height );                            // ViewCode.pas      
      TfrmViewCode(f).SynEdit1.Lines.LoadFromFile( ExtractFilePath(ParamStr(0)) + sFile + '.pas' );
   end;


end.

