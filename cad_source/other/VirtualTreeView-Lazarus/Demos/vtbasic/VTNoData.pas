{***********************************************************************}
{ File: VTNoData.pas                                                    }
{                                                                       }
{ Purpose:                                                              }
{       source file to demonstrate how to get started with VT (2)       }
{       <-- Basic VT as a Tree    (no node data used) -->               }
{                                                                       }
{ Module Record:                                                        }
{                                                                       }
{  Date        AP  Details                                              }
{ --------     --  --------------------------------------               }
{ 05-Nov-2002  TC  Created  (tomc@gripsystems.com)                      }
{**********************************************************************}
unit VTNoData;

{$mode delphi}
{$H+}

interface

   uses
      delphicompat, LCLIntf, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, VirtualTrees, ExtCtrls, StdCtrls, LResources, LCLType;

   type
      TfrmVTNoData =
      class(TForm)
         imgMaster: TImageList;
         Panel1   : TPanel;
         VT       : TVirtualStringTree;
         panBase  : TPanel;
         Label1   : TLabel;
         chkCheckBoxes: TCheckBox;
         chkFullExpand: TCheckBox;
         chkShowLevel: TCheckBox;

         procedure FormCreate(Sender: TObject);
         procedure FormDestroy(Sender: TObject);
         procedure FormActivate(Sender: TObject);
         
         procedure VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
         procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
         Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
         procedure VTGetImageIndex(Sender: TBaseVirtualTree;
         Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
         procedure VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
         procedure VTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
         procedure chkCheckBoxesClick(Sender: TObject);
         procedure chkFullExpandClick(Sender: TObject);
         procedure VTPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode;
         Column: TColumnIndex; TextType: TVSTTextType);
         procedure chkShowLevelClick(Sender: TObject);
         procedure FormClose(Sender: TObject; var AAction: TCloseAction);
    
         private
         FCaptions    : TStringList;
      end;

implementation

   {$R *.lfm}

   procedure TfrmVTNoData.FormCreate(Sender: TObject);
   begin
      {set up root values - level 0}
      FCaptions            := TStringList.Create;
      FCaptions.CommaText  := 'Animation,Auto,Miscellaneous,Paint,Selection,String';
      VT.RootNodeCount     := FCaptions.Count;
   end;

   procedure TfrmVTNoData.FormClose(Sender: TObject; var AAction: TCloseAction);
   begin
      AAction := caFree;
   end;

   procedure TfrmVTNoData.FormDestroy(Sender: TObject);
   begin
      FCaptions .Free;
   end;

   procedure TfrmVTNoData.VTGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
   begin
      NodeDataSize := 0;                                           // note *** no node data used ***
   end;

   procedure TfrmVTNoData.VTInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
   begin
      Node.CheckType := ctTriStateCheckBox;                    // we will have checkboxes throughout
      if ParentNode = nil then                                 // top-level node is being initialised
         InitialStates := InitialStates + [ivsHasChildren];               // <- important line here
   end;

   procedure TfrmVTNoData.VTInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
   begin
      case Node.Index of
         0: ChildCount := Ord( High( TVTAnimationOption  )) + 1;
         1: ChildCount := Ord( High( TVTAutoOption       )) + 1;
         2: ChildCount := Ord( High( TVTMiscOption       )) + 1;
         3: ChildCount := Ord( High( TVTPaintOption      )) + 1;
         4: ChildCount := Ord( High( TVTSelectionOption  )) + 1;
         5: ChildCount := Ord( High( TVTStringOption     )) + 1;
      end;         
   end;

   procedure TfrmVTNoData.VTGetImageIndex(Sender: TBaseVirtualTree;
     Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
     var Ghosted: Boolean; var ImageIndex: Integer);
   begin
      if Kind in [ ikNormal, ikSelected ] then 
      begin
         if Sender.GetNodeLevel( Node ) = 0 then
            ImageIndex := 30
         else   
            ImageIndex := 12;
      end;   
   end;

   procedure TfrmVTNoData.VTPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
   begin
      if TextType = ttStatic then 
      begin
         if Sender.GetNodeLevel( Node ) = 0 then
            TargetCanvas.Font.Color := clRed
         else   
            TargetCanvas.Font.Color := clBlue;
      end;   
   end;

   procedure TfrmVTNoData.VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
     Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
   const     
      aAnimOpts : array[0..Ord(High(TVTAnimationOption ))] of string[25] = 
      (  'Animated Toggle',
         'Advanced Animated Toggle' );

      aAutoOpts : array[0..Ord(High(TVTAutoOption ))] of string[25] = 
      ( 
         'DropExpand'                                                                              ,
         'Expand'                                                                                  ,
         'Scroll'                                                                                  ,
         'ScrollOnExpand'                                                                          ,
         'Sort'                                                                                    ,
         'SpanColumns'                                                                             ,
         'TristateTracking'                                                                        ,
         'HideButtons'                                                                             ,
         'DeleteMovedNodes'                                                                        ,
         'DisableAutoscrollOnFocus'                                                                ,
         'AutoChangeScale'                                                                         ,
         'AutoFreeOnCollapse'                                                                      ,
         'DisableAutoscrollOnEdit'                                                                 ,
         'AutoBidiColumnOrdering'
      );

      aMiscOpts : array[0..Ord(High(TVTMiscOption ))] of string[25] = 
      ( 
         'AcceptOLEDrop'                                                                           ,
         'CheckSupport'                                                                            ,
         'Editable'                                                                                ,
         'FullRepaintOnResize'                                                                     ,
         'GridExtensions'                                                                          ,
         'InitOnSave'                                                                              ,
         'ReportMode'                                                                              ,
         'ToggleOnDblClick'                                                                        ,
         'WheelPanning'                                                                            ,
         'ReadOnly'                                                                                ,
         'VariableNodeHeight',
         'FullRowDrag',
         'NodeHeightResize',
         'NodeHeightDblClickResize',
         'EditOnClick',
         'EditOnDblClick',
         'toReverseFullExpandHotKey'
      );

      aPaintOpts : array[0..Ord(High(TVTPaintOption ))] of string[25] = 
      (                                                                                            
         'HideFocusRect'                                                                           ,
         'HideSelection'                                                                           ,
         'HotTrack'                                                                                ,
         'PopupMode'                                                                               ,
         'ShowBackground'                                                                          ,
         'ShowButtons'                                                                             ,
         'ShowDropmark'                                                                            ,
         'ShowHorzGridLines'                                                                       ,
         'ShowRoot'                                                                                ,
         'ShowTreeLines'                                                                           ,
         'ShowVertGridLines'                                                                       ,
         'ThemeAware'                                                                              ,
         'UseBlendedImages'                                                                        ,
         'GhostedIfUnfocused',
         'FullVertGridLines',                               // This option only has an effect if toShowVertGridLines is enabled too.
         'AlwaysHideSelection',     // Do not draw node selection, regardless of focused state.
         'UseBlendedSelection',     // Enable alpha blending for node selections.
         'StaticBackground',
         'ChildrenAbove',
         'FixedIndent',
         'UseExplorerTheme',
         'toHideTreeLinesIfThemed',
         'toShowFilteredNodes'
      );

      aSelOpts : array[0..Ord(High(TVTSelectionOption))] of string[25] = 
      ( 
         'DisableDrawSelection'                                                                    ,
         'ExtendedFocus'                                                                           ,
         'FullRowSelect'                                                                           ,
         'LevelSelectConstraint'                                                                   ,
         'MiddleClickSelect'                                                                       ,
         'MultiSelect'                                                                             ,
         'RightClickSelect'                                                                        ,
         'SiblingSelectConstraint'                                                                 ,
         'CenterScrollIntoView',
         'SimpleDrawSelection',
         'toAlwaysSelectNode',
         'toRestoreSelection'
      );
      
      aStrOpts : array[0..Ord(High(TVTStringOption ))] of string[25] = 
      ( 
         'SaveCaptions'                                                                            ,
         'ShowStaticText'                                                                          ,
         'AutoAcceptEditChange'
      );
   var
      iLevel : integer;   
   begin
      iLevel := Sender.GetNodeLevel( Node );
      case iLevel of
         0: Celltext := FCaptions[Node.Index];                                           {top-level} 
         1: case Node.Parent.Index of                                                      {options}
               0: Celltext := aAnimOpts[Node.Index];
               1: Celltext := aAutoOpts[Node.Index];
               2: Celltext := aMiscOpts[Node.Index];
               3: Celltext := aPaintOpts[Node.Index];
               4: Celltext := aSelOpts[Node.Index];
               5: Celltext := aStrOpts[Node.Index];
            end;         
      end;
      if TextType = ttStatic then 
      begin
         if chkShowLevel.checked then
            Celltext := Format( ' Index:%d, Level:%d', [Node.Index, iLevel] )
         else   
            Celltext := Format( ' Index:%d', [Node.Index] );
      end;   
   end;
  
   procedure TfrmVTNoData.chkCheckBoxesClick(Sender: TObject);
   begin
      with VT.TreeOptions do 
      begin
         if chkCheckBoxes.checked then
            MiscOptions := MiscOptions + [toCheckSupport]
         else            
            MiscOptions := MiscOptions - [toCheckSupport];
            
         VT.Refresh;
      end;   
   end;

   procedure TfrmVTNoData.chkFullExpandClick(Sender: TObject);
   begin
      if chkFullExpand.Checked then
         VT.FullExpand
      else
         VT.FullCollapse;
   end;                   

   procedure TfrmVTNoData.chkShowLevelClick(Sender: TObject);
   begin
      VT.refresh;
   end;

   procedure TfrmVTNoData.FormActivate(Sender: TObject);
   var
      r  : TRect;
   begin
      {$ifdef LCLWin32}
      //todo: enable when SPI_GETWORKAREA is implemented
      {get size of desktop}
      SystemParametersInfo(SPI_GETWORKAREA, 0, @r, 0);
      Height := r.Bottom-Top;
      {$endif}
   end;


end.

