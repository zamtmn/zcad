{***********************************************************************                              }
{ File: VTPropEdit.pas                                                                                }
{                                                                                                     }
{ Purpose:                                                                                            }
{       source file to illustrate how to get started with VT                                          }
{       <-- general purpose property editor with ability to dynamically refresh -->                   }
{        see ShowExample procedure at base of this file                                               }
{                                                                                                     }
{                                                                                                     }
{ Note:                                                                                               }
{      This is an example only and time permitting I'd like to write a                                }
{      proper one. It is still useful, with the basic idea being that                                 }
{      the property editor may be used either modally or not. If not then it                          }
{      needs a quick and simple way to update itself.                                                 }
{                                                                                                     }
{      The display is treated as 2 parts:                                                             }
{      1. display of *1st column heading and sub-headings *                                           }
{      2. display of values                                                                           }
{                                                                                                     }
{      If the type of object does not change then the values *only* need to be updated, otherwise     }
{      completely different property headings need to be displayed.                                   }
{                                                                                                     }
{                                                                                                     }
{ Credits:                                                                                            }
{      taken + modified from hard-coded example by Mike Lischke                                       }
{                                                                                                     }
{                                                                                                     }
{  Date        AP  Details                                                                            }
{ --------     --  --------------------------------------                                             }
{ 05-Nov-2002  TC  Created  (tomc@gripsystems.com)                                                    }
{**********************************************************************}
unit VTPropEdit;

{$mode delphi}
{$H+}

interface

   uses
      LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
      StdCtrls, VirtualTrees, ExtCtrls, Contnrs, Buttons, LResources;

   type
      {-----------------------------------------------------------------------------------
                                 TVTPropEditData

      class for storing headings, sub-headings + values (holding datatypes in objects slot
      -----------------------------------------------------------------------------------}
      TVTPropEditData=
      class
         FHeading : string;                                         // heading
         FCaptions: TStringList;                                    // sub-headings
         FValues  : TStringList;                                    // list of values in string form

         public
         { Public declarations }
         constructor Create( const s : string );                                          
         destructor Destroy;                                                              override;

         property Heading  : string          read FHeading     write FHeading ;
         property Captions : TStringList     read FCaptions    write FCaptions;
         property Values   : TStringList     read FValues      write FValues;
      end;
   
      {--------------------------------------------------------------------------
                                 TfrmPropEdit
      --------------------------------------------------------------------------}
      TfrmVTPropEdit =
      class(TForm)
         Panel1: TPanel;
         VT: TVirtualStringTree;
         cmb: TComboBox;
         TreeImages: TImageList;
         panBase: TPanel;
         chkTriangleButtons: TCheckBox;
         btnDynamicallyUpdate: TButton;
         
         procedure FormCreate(Sender: TObject);
         procedure FormActivate(Sender: TObject);
         
         procedure VTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
         procedure VTCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
         procedure VTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
         procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
         var Text: String);
         procedure VTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
         procedure VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
         var InitialStates: TVirtualNodeInitStates);
         procedure VTPaintText(Sender: TBaseVirtualTree; const Canvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
         TextType: TVSTTextType);
         procedure VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
         procedure chkTriangleButtonsClick(Sender: TObject);
         procedure ShowExample(Sender: TObject);
         procedure cmbChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

         private
         { Private declarations }
         FDataList   : TObjectList;
         FExample    : integer;
         

         public
         { Public declarations }
         constructor Create( AOwner : TComponent );                                       override;
         destructor Destroy;                                                              override;

         procedure ConfigureVT( slCaptions, slVals : TStringlist );
      end;


implementation

   {$R *.lfm}

   uses
      VTEditors;
      
   {--------------------------------------------------------------------------
                              TVTPropEditData
   --------------------------------------------------------------------------}
   constructor TVTPropEditData.Create( const s : string ); 
   begin
      inherited Create;
      FCaptions:= TStringList.Create;
      FValues  := TStringList.Create;
      
      FCaptions.CommaText := s;                                          // string to list 
      FHeading := FCaptions[0];                                          // 1st element is caption
      FCaptions.Delete(0);                                               // can now delete it
   end;   
   
   destructor TVTPropEditData.Destroy;                                                              
   begin
      FValues  .Free;
      FCaptions.Free;
      inherited Destroy;
   end;   
   
   {--------------------------------------------------------------------------
                              TfrmPropEdit
   --------------------------------------------------------------------------}
   constructor TfrmVTPropEdit.Create( AOwner : TComponent );
   begin
      inherited Create(AOwner);
      FDataList:= TObjectList.Create;
   end;   
   
   destructor TfrmVTPropEdit.Destroy;
   begin
      FDataList.Free;
      inherited Destroy;
   end;

   procedure TfrmVTPropEdit.ConfigureVT( slCaptions, slVals : TStringlist );
   var
      i, j  : integer;
      iCnt  : integer;
      ped   : TVTPropEditData;
   begin
      with VT do
      begin
         BeginUpdate;
         try
            Clear;
            FDataList.Clear;
            
            iCnt := 0;
            for i := 0 to slCaptions.count-1 do
            begin
               // create dataobject, loading captions and parallel values
               ped := TVTPropEditData.Create( slCaptions[i] );

               // slVals is a linear list of *all* values for this page, 
               // so now need to get those vals associated with the captions
               for j := iCnt to iCnt + ped.Captions.Count-1 do
                  ped.Values.AddObject( slVals[j], slVals.Objects[j]  );   //object slot = datatype
                  
               // add to datalist
               FDataList.Add( ped );
               Inc( iCnt, ped.Captions.Count );
            end;   
            RootNodeCount := FDataList.Count;                                    // important call
            
         finally
            EndUpdate;
         end;
      end;   
   end;   
   
   procedure TfrmVTPropEdit.FormCreate(Sender: TObject);
   begin
     // The VCL (D6 and lower) still uses 16 color image lists. 
     // We create a high color version explicitely because it looks so much nicer.
     ConvertToHighColor(TreeImages);
   end;

   procedure TfrmVTPropEdit.FormActivate(Sender: TObject);
   begin
      {for this example}
      ShowExample(Sender);
   end;

   procedure TfrmVTPropEdit.FormClose(Sender: TObject; var Action: TCloseAction);
   begin
      Action := caFree;
   end;
   
   procedure TfrmVTPropEdit.VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
   begin
      NodeDataSize := SizeOf(TPropertyData);
   end;
   
   procedure TfrmVTPropEdit.VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
     var InitialStates: TVirtualNodeInitStates);
   var
      Data: PPropertyData;
      ped : TVTPropEditData;
   begin 
      Data  := Sender.GetNodeData(Node);
      if ParentNode = nil then
      begin
         InitialStates := InitialStates + [ivsHasChildren];
         if FExample = 0 then 
            InitialStates := InitialStates + [ivsExpanded];
                       
         ped   := TVTPropEditData( FDataList[Node.Index] );
         if ped.Captions.count>0 then
            Data.ValueType := vtNone;
      end     
      else
      begin
         ped   := TVTPropEditData( FDataList[Node.Parent.Index] );
         Data.ValueType := TValueType( PtrInt(ped.Values.Objects[Node.Index]) );
         Data.Value     := ped.Values[Node.Index];
      end;
   end;

   procedure TfrmVTPropEdit.VTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
   begin
      ChildCount := TVTPropEditData( FDataList[Node.Index] ).Captions.Count;
   end;
   
   procedure TfrmVTPropEdit.VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
     TextType: TVSTTextType; var Text: String);
   var
      Data: PPropertyData;
      ped : TVTPropEditData;
   begin
      Text := '';
      if TextType = ttNormal then
      begin
         case Column of
            0: begin
                  if Sender.GetNodeLevel( Node ) = 0 then
                     Text := TVTPropEditData( FDataList[Node.Index] ).Heading
                  else {find text}  
                  begin
                     ped   := TVTPropEditData( FDataList[Node.Parent.Index] );
                     Text := ped.Captions[Node.Index];
                  end;   
               end;   

            1: begin
                  if Sender.GetNodeLevel( Node ) > 0 then
                  begin
                     //Data := Sender.GetNodeData(Node);
                     ped   := TVTPropEditData( FDataList[Node.Parent.Index] );
                     Text := ped.Values[Node.Index];
                  end;
               end;
         end;
      end;   
   end;

   procedure TfrmVTPropEdit.VTEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
   var
     Data: PPropertyData;
   begin
     with Sender do
     begin
       Data := GetNodeData(Node);
       Allowed := (Node.Parent <> RootNode) and (Column = 1) and (Data.ValueType <> vtNone);
     end;
   end;

   procedure TfrmVTPropEdit.VTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
   begin
     // Start immediate editing as soon as another node gets focused.
     with Sender do
     begin
         if Assigned(Node) and (Node.Parent <> RootNode) and not (tsIncrementalSearching in TreeStates) then
         begin
            // Note: the test whether a node can really be edited is done in the OnEditing event.
            EditNode(Node, 1);
         end;
      end;
   end;

   procedure TfrmVTPropEdit.VTCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
     out EditLink: IVTEditLink);
   // This is the callback of the tree control to ask for an application defined edit link. Providing one here allows
   // us to control the editing process up to which actual control will be created.
   // TPropertyEditLink implements an interface and hence benefits from reference counting. We don't need to keep a
   // reference to free it. As soon as the tree finished editing the class will be destroyed automatically.
   begin
     EditLink := TPropertyEditLink.Create;
   end;

   procedure TfrmVTPropEdit.VTPaintText(Sender: TBaseVirtualTree; const Canvas: TCanvas; Node: PVirtualNode;
     Column: TColumnIndex; TextType: TVSTTextType);
   var
     Data: PPropertyData;
   begin
      if Node.Parent = Sender.RootNode then
         Canvas.Font.Style := [fsBold]
      else if Column = 0 then
         Canvas.Font.Color := clBlue
      else    
      begin                  
         Data := Sender.GetNodeData(Node);
         if Data.Changed then
            Canvas.Font.Color := clRed
         else
            Canvas.Font.Style := [];
      end;
   end;

   procedure TfrmVTPropEdit.chkTriangleButtonsClick(Sender: TObject);
   begin
      with VT do 
      begin
         if chkTriangleButtons.checked then
            ButtonStyle := bsTriangle
         else            
            ButtonStyle := bsRectangle;
            
         Refresh;
      end;   
   end;

   procedure TfrmVTPropEdit.cmbChange(Sender: TObject);
   begin
      ShowExample(Sender);
   end;
   
   procedure TfrmVTPropEdit.ShowExample(Sender: TObject);
   var
      slText   : TStringlist;
      slVals   : TStringlist;
      i        : integer;
   begin
      if FExample = 0 then 
         FExample := 1
      else   
         FExample := 0;
      
      slText := TStringlist.Create;
      slVals := TStringlist.Create;
      try
         case FExample of 
            0: begin
                  {each string has the heading first + sub-captions following}
                  slText.Add( 'Position,Left,Top,Width,Height'               );
                  slText.Add( 'Action,ChangeDelay,EditDelay,Enabled,Visible' );
                  slText.Add( 'Events,OnDblClick,OnGetText,OnInitNode'       );

                  {the values would be supplied seperately - in a list, string format}
                  slVals.CommaText := '1,2,3,4,11,22,33,True,01/01/2002,a,b';
                  for i := 0 to slVals.Count-1 do slVals.Objects[i] := Pointer(vtString);
                  slVals.Objects[8] := Pointer(vtdate);
               end;      
               
            1: begin
                  {second example for dynamic change illustration}
                  slText.Add( 'Test,OnTest1,OnTest2,OnTest3'                 );
                  slText.Add( 'Action,ChangeDelay,EditDelay,Enabled,Visible' );
                  slText.Add( 'Position,Left,Top,Width,Height'               );
                  slText.Add( 'Events,OnDblClick,OnGetText,OnInitNode'       );
                  
                  slVals.CommaText := 't1,t2,t3,1,2,3,4,11,22,33,True,False,a,b';
                  for i := 0 to slVals.Count-1 do slVals.Objects[i] := Pointer(vtString);
               end;      
         end;                  
         {reconfigure + update UI}
         ConfigureVT( slText, slVals );

      finally
         slText.Free;
         slVals.Free;
      end;
   end;


end.


