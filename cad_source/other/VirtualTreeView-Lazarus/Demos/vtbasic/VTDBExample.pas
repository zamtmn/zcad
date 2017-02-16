{*********************************************************************** }
{ File: VTDBExample.pas                                                  }
{                                                                        }
{ Purpose:                                                               }
{       source file to illustrate how to get started with VT             }
{       <-- Database example 1. -->                                      }
{                                                                        }
{ Credits:                                                               }
{      taken + modified from example by Mike Lischke                     }
{                                                                        }
{ Module Record:                                                         }
{                                                                        }
{  Date        AP  Details                                               }
{ --------     --  --------------------------------------                }
{ 05-Nov-2002  TC  Created  (tomc@gripsystems.com)                       }
{**********************************************************************}
unit VTDBExample;

{$mode delphi}
{$H+}

interface

   uses
      delphicompat, LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, LCLType,
      VirtualTrees, StdCtrls, ExtCtrls, sqlite3ds, Menus, VTreeData, Buttons, LResources;

   type

      { TfrmVTDBExample }

      TfrmVTDBExample =
      class(TForm)
         Label1: TLabel;
         FDataset: TSqlite3Dataset;
         Panel1: TPanel;
         VT: TVirtualStringTree;
         imgMaster: TImageList;
         Panel2: TPanel;
         Label2: TLabel;
         ed: TEdit;
         AddOneButton: TButton;
         Button1: TButton;
         btnHasChildren: TButton;
         chkShowIDs: TCheckBox;
         Label3: TLabel;
         btnToggleVisibility: TButton;
         chkAllVisible: TCheckBox;
         chkDynHt: TCheckBox;
         Label4: TLabel;
         Bevel1: TBevel;
    Label5: TLabel;
         
         procedure FormClose(Sender: TObject; var Action: TCloseAction);
         procedure AddButtonClick(Sender: TObject);
         procedure FormCreate(Sender: TObject);
         procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
         var Text: String);
         procedure VTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
         procedure VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
         var InitialStates: TVirtualNodeInitStates);
         procedure FormActivate(Sender: TObject);
         procedure VTGetImageIndex(Sender: TBaseVirtualTree;
         Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
         var Ghosted: Boolean; var ImageIndex: Integer);
         procedure chkShowIDsClick(Sender: TObject);
         procedure VTPaintText(Sender: TBaseVirtualTree;
         const TargetCanvas: TCanvas; Node: PVirtualNode;
         Column: TColumnIndex; TextType: TVSTTextType);
         procedure VTHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
         Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
         procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1,
         Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
         procedure VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
         procedure VTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: String);
         procedure VTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
         procedure btnHasChildrenClick(Sender: TObject);
         procedure btnToggleVisibilityClick(Sender: TObject);
         procedure chkAllVisibleClick(Sender: TObject);
         procedure VTFocusChanging(Sender: TBaseVirtualTree; OldNode, NewNode: PVirtualNode; 
                   OldColumn, NewColumn: TColumnIndex; var Allowed: Boolean);
         procedure chkDynHtClick(Sender: TObject);
         procedure VTIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode; const SearchText: String;
         var Result: Integer);
            
         private
         procedure LoadDataset;

         procedure HideNodes(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
         
      end;
   
implementation

   {$R *.lfm}

   const
      FLDN_CustNo             = 0;
      FLDN_Company            = 1;
      FLDN_Addr1              = 2;
      FLDN_Addr2              = 3;
      FLDN_City               = 4;
      FLDN_State              = 5;
      FLDN_Zip                = 6;
      FLDN_Country            = 7;
      FLDN_Phone              = 8;
      FLDN_FAX                = 9;
      FLDN_TaxRate            = 10;
      FLDN_Contact            = 11;
      FLDN_LastInvoiceDate    = 12;

   procedure TfrmVTDBExample.FormActivate(Sender: TObject);
   var
      r  : TRect;
   begin
      {get size of desktop}
      {$ifdef LCLWin32}
      //todo: enable when SPI_GETWORKAREA is implemented
      SystemParametersInfo(SPI_GETWORKAREA, 0, @r, 0);
      Height := r.Bottom-Top;
      Width  := r.Right-Left;
      Application.ProcessMessages;
      {$endif}


      LoadDataset;
   end;

   procedure TfrmVTDBExample.FormClose(Sender: TObject; var Action: TCloseAction);
   begin
      Action := caFree;
   end;
   
   procedure TfrmVTDBExample.LoadDataset;
   var
      Node  : PVirtualNode;
   begin    
      with FDataset do
      begin
         VT.BeginUpdate;
         try
            FileName := 'customers.db';
            TableName:='customers';
            PrimaryKey := 'CustNo';
            Active := True;

            while not eof do
            begin
               {--------------------------------------------------------------------------------
               add a node, call validate to explicitly trigger InitNode *Now* rather than later
               as cds will be sitting on the current record in InitNode. Other options are to 
               'Findkey' as required, Bookmark, etc, etc. 

               I think that this actually goes against Mike's intention for this component and in
               fact this example uses both methods - ie. see cds.Lookup 
               --------------------------------------------------------------------------------}
               Node := VT.AddChild(nil); 
               VT.ValidateNode( Node, False ); 
               
               Next;      
            end;   
            
         finally
            VT.EndUpdate;
         end;
      end;   
   end;   

   procedure TfrmVTDBExample.VTGetNodeDataSize(Sender: TBaseVirtualTree;  var NodeDataSize: Integer);
   begin
      NodeDataSize := SizeOf(TBasicNodeRec);      // Let the tree know how much data space we need.
   end;
   
   procedure TfrmVTDBExample.VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
   var
      Data     : PBasicNodeRec;
      iCustNo  : integer;
      iImage   : integer;
   begin
      // setup our node data here. This event is triggered once for each node but
      // appears asynchronously, which means when the node is displayed not when it is added
      Data := Sender.GetNodeData(Node);
      
      iImage   := -1;
      if Sender.GetNodeLevel( Node ) = 0 then
      begin
         iImage   := 3;
         if (Node.Index < 10) then {as an example - see VTInitChildren}
         begin
            iImage   := 31;
            InitialStates := InitialStates + [ivsHasChildren];               // <- important line here
         end;   
      end;   
      Data.bnd := TBasicNodeAddData.Create( FDataset.Fields[FLDN_Company].AsString, FDataset.Fields[FLDN_CustNo].AsInteger, iImage );
   end;                                                                            

   procedure TfrmVTDBExample.VTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
   begin
      // here we only need to specify if, and how many, children this node has. This will then
      // put a checkbox mark on the parentnode. Node OnInitNode will be called for each of the 
      // children later - maybe much later - when it actually needs to be displayed/accessed.
      ChildCount := 1;
   end;
   
   procedure TfrmVTDBExample.VTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
   var
      Data: PBasicNodeRec;
   begin
      // Explicitely free memory, the VCL cannot know that there is one but needs to free it nonetheless. 
      // For more fields in such a record which must be freed use Finalize(Data^) instead touching
      // every member individually.
      Data := Sender.GetNodeData(Node);
      Data.bnd.Free;
      Finalize( Data^ );
   end;
   
   procedure TfrmVTDBExample.VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
        Column: TColumnIndex; TextType: TVSTTextType; var Text: String);
   var
      Data     : PBasicNodeRec;
      bnd      : TBasicNodeAddData;
      iLevel   : integer;
      iCustNo  : integer;
   begin    
      // A handler for the OnGetText event is always needed to provide tree with the string data to display.
      Text  := '';
      Data  := Sender.GetNodeData(Node);
      
      if Assigned(Data) and (Data.bnd <> nil) then with Data.bnd do
      begin
         iLevel := Sender.GetNodeLevel( Node );
      
         case Column of
            0: // main column + level 2 =  address
            begin
               case TextType of
                  ttNormal:
                  begin
                     {must have been a good reason why level is not stored in TVirtualNode -
                     if 255 is an acceptable limit then maybe dummy could be used?}
                     if iLevel = 0 then 
                     begin
                        if chkShowIDs.checked then
                           Text := Format( '%s [%d]', [Caption, ID] )
                        else   
                           Text := Caption;
                     end
                     else {we need to look it up}
                     begin
                        if FDataset.Locate('CustNo',ID,[]) then with FDataset do
                           Text     := Trim( Fields[ FLDN_Addr1   ].AsString + ' ' +
                                       Fields[ FLDN_Addr2   ].AsString + ' ' +
                                       Fields[ FLDN_City    ].AsString + ' ' +
                                       Fields[ FLDN_State   ].AsString + ' ' +
                                       Fields[ FLDN_Zip     ].AsString + ' ' +
                                       Fields[ FLDN_Country ].AsString );
                     //Text := bnd.Add1 + ', ' + bnd.Add2 + ', ' + bnd.Add3;
                     end;   
                        
                  end;   
                  
                  ttStatic:
                  begin
                     Text := '';
                     (*Text := Data.bnd.JobTitle;
                     if Text <> '' then 
                        Text := '(' + Data.bnd.JobTitle + ')';
                     *)   
                  end;
               end;
            end;   

            1: // contact
            begin
               bnd := TBasicNodeAddData( Data.bnd );
               case TextType of
                  ttNormal:
                  begin
                     if (iLevel = 0) and (FDataset.Locate('CustNo', ID, [] )) then with FDataset do
                        Text := Fields[ FLDN_Contact ].AsString;
                  end;   
               end;
            end;   

            2: // status in position 0 
            begin
               if TextType = ttNormal then
                  Text := ' ';
            end;   
               
         end;   
      end;
   end;

   procedure TfrmVTDBExample.VTPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
   var
      Data: PBasicNodeRec;
   begin
      Data := Sender.GetNodeData(Node);
      case Column of
         0: // main column
         begin
            case TextType of
               ttNormal:
               begin
                  if Sender.GetNodeLevel( Node ) > 0 then
                     TargetCanvas.Font.Color := clBlue;
               end;   
                  
               ttStatic:
                  begin
                     TargetCanvas.Font.Color := clBlue;
                  end;
            end;
         end;
      end;   
   end; 

   procedure TfrmVTDBExample.VTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
               Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
   var
      Data  : PBasicNodeRec;
      iLevel: integer;
   begin    
      ImageIndex := -1;
      Data  := Sender.GetNodeData(Node);
      iLevel:= Sender.GetNodeLevel( Node );
      
      if (Column = 2 ) then
      begin
         if ( Kind in [ ikNormal, ikSelected ] ) and (iLevel=0) then  // status in position 0 
            ImageIndex := 20
      end   
      else if Assigned(Data) and (Data.bnd <> nil) and (Column = 0) then // main column
         ImageIndex := Data.bnd.ImageIndex;
   end;

   procedure TfrmVTDBExample.chkShowIDsClick(Sender: TObject);
   begin
      VT.Refresh;
   end;

   procedure TfrmVTDBExample.VTHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
     Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
   begin
       if (VT.Header.SortColumn <> Column) then
         VT.Header.SortColumn := Column
       else if (VT.Header.SortDirection = sdAscending) then 
         VT.Header.SortDirection := sdDescending
      else            
         VT.Header.SortDirection := sdAscending;

       VT.SortTree( Column, VT.Header.SortDirection );
   end;

   procedure TfrmVTDBExample.VTCompareNodes(Sender: TBaseVirtualTree; Node1,
     Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
   var     
      Data1  : PBasicNodeRec;
      Data2  : PBasicNodeRec;
   begin
      Data1 := Sender.GetNodeData(Node1);
      Data2 := Sender.GetNodeData(Node2);

      case Column of
         0: Result := CompareText( Data1.bnd.Caption, Data2.bnd.Caption )
      end;
   end;

   procedure TfrmVTDBExample.VTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
     Column: TColumnIndex; NewText: String);
   var
      Data  : PBasicNodeRec;
   begin
      Data  := Sender.GetNodeData(Node);
      case Column of
         0: Data.bnd.Caption := Newtext;
      end;
   end;


   procedure TfrmVTDBExample.AddButtonClick(Sender: TObject);
   var
      i, Cnt: Cardinal;
      Node  : PVirtualNode;
      Data  : PBasicNodeRec;
   begin          
      with VT do
      begin
         Cnt := StrToInt(ed.text);
         case (Sender as TButton).Tag of
            0: // add to root
            begin
               // other method is RootNodeCount := RootNodeCount + Count;
               for i := 0 to Cnt-1 do
               begin
                  Node := VT.AddChild(VT.RootNode); // adds a node as the last child     
                  Data := VT.GetNodeData(Node);
                  Data.bnd := TBasicNodeAddData.Create('Root Child ' + IntToStr(i), 0, 0 );
               end;                                       
            end;
           
            1: // add as child
            if Assigned(FocusedNode) then
            begin
               // other method is ChildCount[FocusedNode] := ChildCount[FocusedNode] + Count;
               for i := 0 to Cnt-1 do
               begin
                  Node := VT.AddChild(VT.FocusedNode); // adds a node as the last child     
                  Data := VT.GetNodeData(Node);
                  Data.bnd := TBasicNodeAddData.Create('Child ' + IntToStr(i), 0, 0 );
                end;   
                Expanded[FocusedNode] := True;
                InvalidateToBottom(FocusedNode);
              end;
         end;
      end;
   end;

   procedure TfrmVTDBExample.FormCreate(Sender: TObject);
   begin
     FDataset:=TSqlite3Dataset.Create(Self);
   end;


   procedure TfrmVTDBExample.btnHasChildrenClick(Sender: TObject);
   begin
      VT.HasChildren[VT.focusedNode] := not VT.HasChildren[VT.focusedNode];
      VT.InvalidateNode(VT.focusedNode);
   end;

   procedure TfrmVTDBExample.btnToggleVisibilityClick(Sender: TObject);
   begin
      VT.IsVisible[VT.focusedNode] := not VT.IsVisible[VT.focusedNode];
   end;

   procedure TfrmVTDBExample.chkAllVisibleClick(Sender: TObject);
   begin
      if chkAllVisible.Checked then
      begin
          VT.BeginUpdate;
          try
            VT.IterateSubtree( nil, HideNodes, nil );
          finally
            VT.EndUpdate;
          end;
      end;   
   end;
   
   procedure TfrmVTDBExample.HideNodes(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
   begin
      Sender.IsVisible[Node] := True;
   end;   

   procedure TfrmVTDBExample.VTFocusChanging(Sender: TBaseVirtualTree; OldNode,  NewNode: PVirtualNode;
             OldColumn, NewColumn: TColumnIndex; var Allowed: Boolean);
   begin
      if chkDynHt.checked then with TVirtualStringTree(Sender) do
      begin
         NodeHeight[OldNode] := DefaultNodeHeight;
         NodeHeight[NewNode] := DefaultNodeHeight * 2;
      end;
   end;

   procedure TfrmVTDBExample.chkDynHtClick(Sender: TObject);
   begin
      {example of resetting dynamically changing node heights}
      with VT do
      begin
         if not Assigned(FocusedNode) then 
            ShowMessage( 'You need to select a node first' )
         else 
         begin
            if chkDynHt.checked then 
               NodeHeight[FocusedNode] := DefaultNodeHeight * 2
            else   
               NodeHeight[FocusedNode] := DefaultNodeHeight;

            InvalidateNode(FocusedNode);
         end;      
      end;  
   end;

   procedure TfrmVTDBExample.VTIncrementalSearch(Sender: TBaseVirtualTree;
      Node: PVirtualNode; const SearchText: String; var Result: Integer);

      function Min(const A, B: Integer): Integer;  {save us linking in math.pas}
      begin
        if A < B then
          Result := A
        else
          Result := B;
      end;
      
   var
      sCompare1, sCompare2 : string;
      DisplayText : String;
     
   begin
      VT.IncrementalSearchDirection := sdForward;   // note can be backward
   
      VTGetText( Sender, Node, 0 {Column}, ttNormal, DisplayText );
      sCompare1 := SearchText;
      sCompare2 := DisplayText;
     
     // By using StrLIComp we can specify a maximum length to compare. This allows us to find also nodes
     // which match only partially. Don't forget to specify the shorter string length as search length.
     Result := StrLIComp( pchar(sCompare1), pchar(sCompare2), Min(Length(sCompare1), Length(sCompare2)) )
   end;

end.
