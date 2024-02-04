unit uzcfnavigatordevices;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, ComCtrls,
  StdCtrls, ActnList, laz.VirtualTrees, LCLVersion,
  uzbtypes,gzctnrVectorTypes,uzegeometrytypes ,uzegeometry, uzccommandsmanager,
  uzcinterface,uzeconsts,uzeentity,uzcimagesmanager,uzcdrawings,
  varmandef,uzbstrproc,uzctreenode,
  uzcnavigatorsnodedesk,Varman,uzcstrconsts,uztoolbarsmanager,uzmenusmanager,
  uzccommandsimpl,uzccommandsabstract,uzcutils,uzcenitiesvariablesextender,
  GraphType,generics.collections,uzglviewareaabstract,Menus,
  uzcfnavigatordevicescxmenu,uzbpaths,Toolwin,uzcctrlpartenabler,StrUtils,
  uzctextenteditor,uzcinfoform,uzcsysparams,uzcsysvars,uzetextpreprocessor,
  uzelongprocesssupport,uzeentitiestypefilter,uzcuitypes,
  uzeparserenttypefilter,uzeparserentpropfilter,uzeparsernavparam,uzclog,uzcuidialogs,
  XMLConf,XMLPropStorage, EditBtn,LazConfigStorage,uzcdialogsfiles,
  Masks,garrayutils,LCLType,LCLIntf, Buttons,
  gzctnrSTL,uzcActionsManager;

resourcestring
  rsStandaloneDevices='Standalone devices';
  rsNavigatorParamsFileFilter='This navigator params files (*.%0:s)|*.%0:s|Xml files (*.xml)|*.xml|All files (*.*)|*.*';

const
  AllFilesWithExt='*.%s';
  TreeBuildMapSaveVarSuffix='_TreeBuildMap';
  IncludeEntitiesSaveVarSuffix='_IncludeEntities';
  IncludePropertiesSaveVarSuffix='_IncludeProperties';
  TreePropertiesSaveVarSuffix='_TreeProperties';
  TreeCreateRootNode='_TreeProperties';

  RefreshEqualy=0;
  RefreshSimilar=1;

type
  TCfgFileDesk=record
    FileName,FilePath:string;
  end;
  TCfgFilesDesks=TMyVector<TCfgFileDesk>;
  TCfgFileDeskCompare=class
    class function c(a,b:TCfgFileDesk):boolean;inline;
  end;
  TCfgFilesDesksSorter=TOrderingArrayUtils<TCfgFilesDesks,TCfgFileDesk,TCfgFileDeskCompare>;

  TCrutchForTEditButton=class helper for TEditButton
    procedure SetupEditButtonBorderStyle(bs:TBorderStyle);
  end;

  TMenuItemWithFileDesk=class(TMenuItem)
    public
      FilePath:string;
  end;

  TBuildParam=record
    TreeBuildMap:ansistring;
    IncludeEntities:ansistring;
    IncludeProperties:ansistring;
    TreeProperties:ansistring;
    UseMainFunctions:Boolean;
    NodeNameFormat:ansistring;
    CreateRootNode:Boolean;
  end;

  TStringPartEnabler=TPartEnabler<String>;
  TEnt2NodeMap=TDictionary<pGDBObjEntity,PVirtualNode>;

  { TNavigatorDevices }
  TNavigatorDevices = class(TForm)
    CollapseAll: TAction;
    ExpandAll: TAction;
    FilterBtn: TEditButton;
    SaveToFile: TAction;
    LoadFromFile: TAction;
    CoolBar1: TCoolBar;
    NavTree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};
    Ent2NodeMap:TEnt2NodeMap;
    RefreshToolButton: TToolButton;
    ExpandAllBtn: TSpeedButton;
    CollapseAllBtn: TSpeedButton;
    UMFToolButton: TToolButton;
    ActionList1:TActionList;
    Refresh:TAction;
    IncludeEnts:TAction;
    IncludeProps:TAction;
    TreeProps:TAction;
    procedure CollapseAllProc(Sender: TObject);
    function CreateEntityNode(Tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode;virtual;
    procedure ExpandAllProc(Sender: TObject);
    procedure Filter(Sender: TObject);
    function Match(node:PVirtualNode;pattern:AnsiString):boolean;
    function DoFilter(tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};node:PVirtualNode;pattern:AnsiString;var treeh:Integer):boolean;
    procedure AsyncLoadParamsFromFile(Data: PtrInt);
    procedure TEMenuPopUpClick(Sender: TObject);
    procedure TEMenuPopUp(Sender: TObject);
    procedure LoadFromFileProc(Sender: TObject);
    procedure PurgeFilter(Sender: TObject);
    procedure InternalRefreshTree(Dist:Integer);
    procedure RefreshTree(Sender: TObject);
    procedure SimilarRefreshTree(Sender: TObject);
    procedure PostProcessTree;virtual;
    procedure EditIncludeEnts(Sender: TObject);
    procedure EditIncludeProperties(Sender: TObject);
    procedure EditTreeProperties(Sender: TObject);
    procedure AutoRefreshTree(sender:TObject;GUIAction:TZMessageID);
    procedure AutoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SaveToFileProc(Sender: TObject);
    procedure TVDblClick(Sender: TObject);
    procedure TVOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VTOnContextMenu(Sender: TObject; MousePos: TPoint;
                                 var Handled: Boolean);
    procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);virtual;
    procedure VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure _onCreate(Sender: TObject);
    procedure NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);virtual;
    procedure NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                          var Ghosted: Boolean; var ImageIndex: Integer);
    procedure SetDefaultImagesIndex;
    procedure AfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; const CellRect: TRect);
    procedure DrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
        Column: TColumnIndex; const CellText: String; const CellRect: TRect; var DefaultDraw: Boolean) ;
    procedure MeasureTextWidth(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; const CellText: String; var Extent: Integer);
  private
    //CombinedNode:TBaseRootNodeDesk;//удаляем ее, ненужно!!!
    CombinedNodeStates:TNodesStates;
    StandaloneNode:TBaseRootNodeDesk;
    StandaloneNodeStates:TNodesStates;
    NavMX,NavMy:integer;
    umf:TmyVariableAction;
    MainFunctionIconIndex:integer;
    BuggyIconIndex:integer;
    SaveCellRectLeft:integer;
    TreeEnabler:TStringPartEnabler;
    EntsTypeFilter:TEntsTypeFilter;
    EntityIncluder:ParserEntityPropFilter.TGeneralParsedText;

  public
    CurrentSel:TNodeData;
    LastAutoselectedEnt:PGDBObjEntity;
    BP:TBuildParam;
    ExtTreeParam:TExtTreeParam;
    FileExt:String;
    {TreeBuildMap:string;
    IncludeEntities,IncludeProperties:string;
    UseMainFunctions:Boolean;}

    procedure CreateRoots;
    procedure CreateFilters;
    procedure EraseRoots;
    procedure FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure SetTreeProp;
    procedure VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);

    procedure AsyncRunCommand(Data: PtrInt);

    function EntsFilter(pent:pGDBObjEntity):Boolean;virtual;
    function TraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;virtual;

    function GetPartsCount(const parts:string):integer;
    function GetPartState(const parts:string;const nmax,n:integer; out _name:string;out _enabled:boolean):boolean;
    procedure SetPartState(var parts:string;const n:integer;state:boolean);
    procedure ReorganizeParts(var parts:string;const AFrom,ATo:integer;ABefore:boolean);
    function PartsEditor(var parts:string):boolean;

    destructor Destroy; override;

    procedure LoadAndSetParamsFromFile(Filename:string);
    procedure LoadParamsFromFile(Filename:string);
    procedure LoadParamsFromConfig(Config: TConfigStorage);
    procedure SaveParamsToFile(FileName:string);
    procedure SaveParamsToConfig(Config: TConfigStorage);

  end;

var
  NavigatorDevices: TNavigatorDevices;
  NavGroupIconIndex,NavAutoGroupIconIndex:integer;
  NDMsgCtx:TMessagesContext=nil;

  UseMainFunction:Boolean=false;
  //DevicesTreeBuildMap:string='+NMO_Prefix|+NMO_BaseName|+@@[NMO_Name]';

implementation
{todo: убрать когда TLazVirtualStringTree попадет в релиз лазаря}
{$IF DECLARED(TVirtualStringTree)}{$R olduzcfnavigatordevices.lfm}{$ELSE}{$R *.lfm}{$ENDIF}

procedure TNavigatorDevices.LoadParamsFromConfig(Config: TConfigStorage);
begin
  BP.TreeBuildMap:=Config.GetValue('TreeBuildMap','');
  BP.IncludeEntities:=Config.GetValue('IncludeEntities','');
  BP.IncludeProperties:=Config.GetValue('IncludeProperties','');
  BP.TreeProperties:=Config.GetValue('TreeProperties','');
  BP.UseMainFunctions:=Config.GetValue('UseMainFunctions',false);
  BP.CreateRootNode:=Config.GetValue('CreateRootNode',false);
  BP.NodeNameFormat:=Config.GetValue('NodeNameFormat','');
  BP.TreeProperties:=Config.GetValue('TreeProperties','');
end;

procedure TNavigatorDevices.LoadAndSetParamsFromFile(Filename:string);
begin
  LoadParamsFromFile(FileName);
  TreeEnabler.setup(BP.TreeBuildMap);
  if assigned(EntityIncluder) then
    FreeAndNil(EntityIncluder);
  EntityIncluder:=ParserEntityPropFilter.GetTokens(BP.IncludeProperties);
  SetTreeProp;
  InternalRefreshTree(RefreshEqualy);
end;

procedure TNavigatorDevices.LoadParamsFromFile(Filename:string);
var
  Config: TXMLConfigStorage;
begin
  try
    Config:=TXMLConfigStorage.Create(Filename,True);
    try
      Config.AppendBasePath('NavigatorParams/');
      LoadParamsFromConfig(Config);
      Config.UndoAppendBasePath;
    finally
      Config.Free;
    end;
  except
    on E: Exception do
      ZCMsgCallBackInterface.TextMessage('Error loading navigator params from file '+Filename+':'#13+E.Message,TMWOShowError);
  end;
end;

procedure TNavigatorDevices.SaveParamsToConfig(Config: TConfigStorage);
begin
  Config.SetDeleteValue('TreeBuildMap',BP.TreeBuildMap,'');
  Config.SetDeleteValue('IncludeEntities',BP.IncludeEntities,'');
  Config.SetDeleteValue('IncludeProperties',BP.IncludeProperties,'');
  Config.SetDeleteValue('TreeProperties',BP.TreeProperties,'');
  Config.SetDeleteValue('UseMainFunctions',BP.UseMainFunctions,false);
  Config.SetDeleteValue('CreateRootNode',BP.CreateRootNode,false);
  Config.SetDeleteValue('NodeNameFormat',BP.NodeNameFormat,'');
  Config.SetDeleteValue('TreeProperties',BP.TreeProperties,'');
end;

procedure TNavigatorDevices.SaveParamsToFile(Filename: string);
var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:=Filename;
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      Config.AppendBasePath('NavigatorParams/');
      SaveParamsToConfig(Config);
      Config.UndoAppendBasePath;
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;

destructor TNavigatorDevices.Destroy;
var
  i:integer;
begin
  for i:=low(ExtTreeParam.ExtColumnsParams) to high(ExtTreeParam.ExtColumnsParams) do
    if ExtTreeParam.ExtColumnsParams[i].SaveWidthVar<>'' then
      StoreIntegerToSavedUnit(ExtTreeParam.ExtColumnsParams[i].SaveWidthVar,SuffWidth,NavTree.Header.Columns[i].Width);

  StoreAnsiStringToSavedUnit(Name,TreeBuildMapSaveVarSuffix,BP.TreeBuildMap);
  StoreAnsiStringToSavedUnit(Name,IncludeEntitiesSaveVarSuffix,BP.IncludeEntities);
  StoreAnsiStringToSavedUnit(Name,IncludePropertiesSaveVarSuffix,BP.IncludeProperties);
  StoreAnsiStringToSavedUnit(Name,TreePropertiesSaveVarSuffix,BP.TreeProperties);

  if Assigned(EntsTypeFilter) then
    FreeAndNil(EntsTypeFilter);
  if Assigned(Ent2NodeMap) then
    FreeAndNil(Ent2NodeMap);
  if assigned (StandaloneNodeStates) then
    FreeAndNil(StandaloneNodeStates);
  if assigned (EntityIncluder) then
    FreeAndNil(EntityIncluder);
  inherited;
end;

function TNavigatorDevices.EntsFilter(pent:pGDBObjEntity):Boolean;
var
  //cn,an{,entname}:string;
  //match:boolean;
  //alreadyinclude:boolean;
  //operation:char;
  propdata:TPropFilterData;

{  function processproperty(cn:string):boolean;
  var
    operpos:integer;
    s1,s2,n1,n2:string;
  begin
    if cn='*' then
      exit(true);
    operpos:=pos('=',cn);
    if operpos>0 then begin
      s1:=copy(cn,1,operpos-1);
      s2:=copy(cn,operpos+1,length(cn)-operpos);
      n1:=textformat(s1,pent);
      n2:=textformat(s2,pent);
      result:=MatchesMask(n1,n2,false);
      exit;
    end;
    result:=false;
  end;}

begin
  {an:=IncludeEntities;
  if an<>'' then begin
    entname:=pent^.GetObjTypeName;
    alreadyinclude:=false;
    repeat
      GetPartOfPath(cn,an,'|');
      if cn<>'' then begin
        operation:=cn[1];
        if not((operation='+') and alreadyinclude) then begin
          cn:=(copy(cn,2,length(cn)-1));
          match:=MatchesMask(entname,cn,false);
          if (operation='+')and match then
            alreadyinclude:=true;
          if (operation='-')and match then
            exit(false);
        end;
      end;
    until an='';
    if not alreadyinclude then
      exit(false);
  end;}
  {if pent^.GetObjTypeName<>ObjN_GDBObjDevice then
      exit(false);}

  if not EntsTypeFilter.IsEntytyTypeAccepted(pent^.GetObjType)then
    exit(false);
  if assigned(EntityIncluder) then begin
    propdata.CurrentEntity:=pent;
    propdata.IncludeEntity:=T3SB_Default;
    EntityIncluder.Doit(PropData);
    exit(propdata.IncludeEntity=T3SB_True);
  end else
    exit(true);

  {an:=BP.IncludeProperties;
  if an<>'' then begin
    alreadyinclude:=false;
    repeat
      GetPartOfPath(cn,an,'|');
      if cn<>'' then begin
        operation:=cn[1];
        if not((operation='+') and alreadyinclude) then begin
          cn:=(copy(cn,2,length(cn)-1));
          match:=processproperty(cn);
          if (operation='+')and match then
            alreadyinclude:=true;
          if (operation='-')and match then
            exit(false);
        end;
      end;
    until an='';
    exit(alreadyinclude);
  end;
  exit(true);}
end;

function  TNavigatorDevices.TraceEntity(rootdesk:TBaseRootNodeDesk;pent:pGDBObjEntity;out name:string):PVirtualNode;
var
  BaseName:string;
  basenode:PVirtualNode;
  MainFunction:pGDBObjEntity;
  mainfuncnode:PVirtualNode;
  pnd:PTNodeData;
  cn,an:string;
begin
  if UseMainFunction then begin
    MainFunction:=GetMainFunction(pent);
    if mainfunction<>nil then
    begin
//       mainfunction:=mainfunction;
       if Ent2NodeMap.TryGetValue(MainFunction,mainfuncnode) then
         basenode:=mainfuncnode.Parent
       else begin
          StandaloneNode.ProcessEntity(self.CreateEntityNode,MainFunction,EntsFilter,TraceEntity);
          if Ent2NodeMap.TryGetValue(MainFunction,mainfuncnode) then
            basenode:=mainfuncnode.Parent
       end;
       if mainfuncnode<>nil then
       begin
         pnd:=rootdesk.Tree.GetNodeData(mainfuncnode);
         if pnd^.NodeMode<>TNMHardGroup then
           rootdesk.ConvertNameNodeToGroupNode(mainfuncnode);
         pnd^.NodeMode:=TNMHardGroup;
         exit(mainfuncnode);
       end;
    end;
  end;

  result:=nil;
  Name:='';
  basenode:=rootdesk.rootnode;
  an:=BP.TreeBuildMap;
  if an<>'' then
  repeat
    GetPartOfPath(cn,an,'|');
    if an<>'' then begin
      if cn<>'' then
        if cn[1]<>'-'then begin
          cn:=copy(cn,2,length(cn)-1);
          BaseName:=GetEntityVariableValue(pent,cn,rsTagMissingt);
          basenode:=rootdesk.find(BaseName,basenode);
        end;
    end else if cn<>'' then begin
      if cn[1]<>'-'then begin
       cn:=copy(cn,2,length(cn)-1);
       Name:=textformat(cn,pent)
      end else
       Name:=pent^.GetObjTypeName;
    end;
  until an='';
  if name='' then
    Name:=pent^.GetObjTypeName;

  result:=basenode;
end;


{ TNavigatorDevices }
procedure TNavigatorDevices.FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  pnd:PTNodeData;
begin
  pnd := Sender.GetNodeData(Node);
  if Assigned(pnd) then
     system.Finalize(pnd^);
end;

procedure TNavigatorDevices.SetTreeProp;
var
  data: TNavParamData;
  params: TParserNavParam.TGeneralParsedText;
begin
  NavTree.BeginUpdate;
  params:=ParserNavParam.GetTokens(bp.TreeProperties);
  try
    data.NavTree:=NavTree;
    data.ColumnCount:=0;
    data.PExtTreeParam:=@ExtTreeParam;
    NavTree.Header.Columns.Clear;
    NavTree.Header.AutoSizeIndex:=0;
    try
      if assigned(params) then
        params.Doit(data);
    except
      on E: Exception do
        ZCMsgCallBackInterface.TextMessage(format(rseGeneralEroror,['TNavigatorDevices.SetTreeProp',E.Message]),TMWOShowError);
    end;
  finally
    params.free;
    NavTree.EndUpdate;
  end;
end;

procedure TNavigatorDevices.AsyncRunCommand(Data: PtrInt);
var
  s:string;
begin
    PtrInt(s):=Data;
    commandmanager.executecommandsilent(@s[1],drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
end;

procedure TNavigatorDevices.VTFocuschanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  pnd:PTNodeData;
  s:string;
begin
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then begin
    if pnd^.Ident.pent<>nil then
      begin
       CurrentSel:=pnd^;
       if (LastAutoselectedEnt<>pnd^.Ident.pent)and( not pnd^.Ident.pent^.Selected) then begin
         s:='SelectObjectByAddres('+inttostr(PtrUInt(pnd^.Ident.pent))+')';
         //commandmanager.executecommandsilent(@s[1],drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
         Application.QueueAsyncCall(AsyncRunCommand,PtrInt(@s[1]));
         pointer(s):=nil;
         LastAutoselectedEnt:=pnd^.Ident.pent;
       end else begin
         //if not LastAutoselectedEnt^.Selected then
         //  LastAutoselectedEnt:=nil;
       end;
      end else
        CurrentSel.Ident.pent:=nil;
  end
end;
function TNavigatorDevices.GetPartsCount(const parts:string):integer;
begin
  result:=WordCount(parts,['|']);
end;

function TNavigatorDevices.GetPartState(const parts:string;const nmax,n:integer;out _name:string;out _enabled:boolean):boolean;
var
  partstartposition,nextpartstartposition:integer;
begin
  partstartposition:=WordPosition(n,parts,['|']);
  nextpartstartposition:=WordPosition(n+1,parts,['|']);
  if {nmax<>n}true then begin
    _enabled:=true;
    result:=parts[partstartposition]='+';
  end{ else begin
    _enabled:=false;
    result:=false;
  end};
  if nextpartstartposition<>0 then
    _name:=copy(parts,partstartposition+1,nextpartstartposition-partstartposition-2)
  else
    _name:=copy(parts,partstartposition+1,length(parts)-partstartposition+2);
end;

procedure TNavigatorDevices.SetPartState(var parts:string;const n:integer;state:boolean);
var
  partstartposition{,nextpartstartposition}:integer;
begin
  partstartposition:=WordPosition(n,parts,['|']);
  if state then
    parts[partstartposition]:='+'
  else
    parts[partstartposition]:='-';
end;
procedure TNavigatorDevices.ReorganizeParts(var parts:string;const AFrom,ATo:integer;ABefore:boolean);
var
  i,c,add:integer;
  partsarray:TMyVector<string>;
  name:string;
  en,state:boolean;
begin
  c:=GetPartsCount(parts);
  partsarray:=TMyVector<string>.create;
  for i:=1 to c do begin
    state:=GetPartState(parts,c,i,name,en);
    if state then
      partsarray.pushback('+'+name)
    else
      partsarray.pushback('-'+name)
  end;
  name:=partsarray[AFrom-1];
  partsarray.erase(AFrom-1);

  if AFrom<ATo then
    add:=-1
  else
    add:=0;

  if ABefore then
    add:=add-1;

  partsarray.Insert(ATo+Add,name);


  for i:=0 to partsarray.size-1 do begin
    if i=0 then
      parts:=partsarray[i]
    else
      parts:=parts+'|'+partsarray[i]
  end;
//  parts:=parts;
end;

function RunEditor(const cpt,BoundsSaveName:string;var AText:string):boolean;
var
   modalresult:integer;
   //astring:ansistring;
begin
  result:=false;
  if not assigned(InfoForm) then begin
    InfoForm:=TInfoForm.createnew(application.MainForm);
    InfoForm.BoundsRect:=GetBoundsFromSavedUnit(BoundsSaveName,SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny);
  end;
  InfoForm.caption:=cpt;
  InfoForm.memo.text:=AText;
  if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
    InfoForm.memo.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;
  modalresult:=ZCMsgCallBackInterface.DOShowModal(InfoForm);
  if modalresult=ZCMrOk then begin
    AText:=InfoForm.memo.text;
    StoreBoundsToSavedUnit(BoundsSaveName,InfoForm.BoundsRect);
    result:=true;
  end;
end;
function TNavigatorDevices.PartsEditor(var parts:string):boolean;
begin
  result:=RunEditor('Parts editor','PartsEdWND',parts);
end;

procedure TCrutchForTEditButton.SetupEditButtonBorderStyle(bs:TBorderStyle);
begin
  Edit.BorderStyle:=bs;
end;

procedure TNavigatorDevices._onCreate(Sender: TObject);
var
  po:TVTPaintOptions;
  //i:integer;
begin
  if FileExt='' then
    FileExt:='xml';
   umf:=TmyVariableAction.Create(self);
   umf.ActionList:=StandartActions;
   umf.AssignToVar('DSGN_NavigatorsUseMainFunction',0);
   umf.Caption:='Use main functions';

   ActionList1.Images:=ImagesManager.IconList;
   Refresh.ImageIndex:=ImagesManager.GetImageIndex('Refresh');
   CoolBar1.AutoSize:=true;

   ExpandAllBtn.Images:=ImagesManager.IconList;
   ExpandAll.ImageIndex:=ImagesManager.GetImageIndex('Minus');
   ExpandAllBtn.ShowCaption:=false;
   CollapseAllBtn.Images:=ImagesManager.IconList;
   CollapseAll.ImageIndex:=ImagesManager.GetImageIndex('Plus');
   CollapseAllBtn.ShowCaption:=false;

   FilterBtn.Button.Images:=ImagesManager.IconList;
   FilterBtn.Button.ImageIndex:=ImagesManager.GetImageIndex('purge');
   FilterBtn.SetupEditButtonBorderStyle(bsNone);
   FilterBtn.Spacing:=4;
   FilterBtn.TextHint:=rsFilterHint;


   TreeEnabler:=TStringPartEnabler.Create(self);
   TreeEnabler.EdgeBorders:=[{ebLeft,ebTop,ebRight,ebBottom}];
   TreeEnabler.AutoSize:=true;
   TreeEnabler.actns:=[PEMenuSubMenu,PEMenuSeparator,umf,PEMenuSeparator,IncludeEnts,IncludeProps,TreeProps,Refresh,nil,LoadFromFile,SaveToFile];

   TreeEnabler.OnMenuPopup:=TEMenuPopUp;
   TreeEnabler.OnPartChanged:=SimilarRefreshTree;
   TreeEnabler.GetCountFunc:=GetPartsCount;
   TreeEnabler.GetStateFunc:=GetPartState;
   TreeEnabler.SetStateProc:=SetPartState;
   TreeEnabler.PartsEditFunc:=PartsEditor;
   TreeEnabler.ReorganizeParts:=ReorganizeParts;

   TreeEnabler.setup(BP.TreeBuildMap);
   TreeEnabler.Parent:=CoolBar1;

   NavTree.BeginUpdate;
   //NavTree.columnclBeginUpdate;
   NavTree.OnGetText:=NavGetText;
   NavTree.OnGetImageIndex:=NavGetImage;
   NavTree.Images:=ImagesManager.IconList;
   NavTree.NodeDataSize:=sizeof(TNodeData);
   NavTree.OnFreeNode:=FreeNode;
   NavTree.OnFocusChanged:=VTFocuschanged;
   NavTree.OnCompareNodes:=VTCompareNodes;
   NavTree.OnAfterCellPaint:=AfterCellPaint;
   NavTree.OnMeasureTextWidth:=MeasureTextWidth;
   NavTree.OnDrawText:=DrawText;
   po:=NavTree.TreeOptions.PaintOptions;
   po:=po-[toShowFilteredNodes,toHideSelection]+[toPopupMode,toShowVertGridLines,toShowHorzGridLines];
   NavTree.TreeOptions.PaintOptions:=po;
   NavTree.TreeOptions.SelectionOptions:=NavTree.TreeOptions.SelectionOptions+[toFullRowSelect];
   MainFunctionIconIndex:=-1;
   BuggyIconIndex:=-1;

   bp.NodeNameFormat:='%0:s(%1:d,%2:d)';
   //bp.NodeNameFormat:='%0:s(%1:d,%2:d,%3:d)';
   //BP.NodeNameFormat:='%0:s';

   SetTreeProp;

   {NavTree.Header.AutoSizeIndex := 0;
   NavTree.Header.MainColumn := 1;
   NavTree.Header.SortColumn := 1;}


   OnShow:=RefreshTree;

   NavTree.OnContextPopup:=VTOnContextMenu;

   NavTree.EndUpdate;

   ZCMsgCallBackInterface.RegisterHandler_GUIAction(AutoRefreshTree);
   ZCMsgCallBackInterface.RegisterHandler_KeyDown(AutoKeyDown);
end;
procedure TNavigatorDevices.AfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; const CellRect: TRect);
var
  pnd:PTNodeData;
  EntVarExt:TVariablesExtender;
  myContentRect:TRect;
begin
  if Column>0 then exit;
  pnd:=Sender.GetNodeData(Node);
  if pnd<>nil then
  if pnd^.Ident.pent<>nil then
  begin
    EntVarExt:=pnd^.Ident.pent^.GetExtension<TVariablesExtender>;
    if EntVarExt<>nil then begin

    SetDefaultImagesIndex;

      myContentRect:=CellRect;
      myContentRect.Left:=SaveCellRectLeft;

      {if EntVarExt.isMainFunction then begin
        ImagesManager.IconList.Draw(TargetCanvas,myContentRect.Left,(myContentRect.Bottom-ImagesManager.IconList.Width) div 2,ImagesManager.GetImageIndex(GetVariableValue(EntVarExt,'ENTID_Function','bug'),BuggyIconIndex),gdeNormal);
        myContentRect.Left:=myContentRect.Left+ImagesManager.IconList.Width;
      end;}
      ImagesManager.IconList.Draw(TargetCanvas,myContentRect.Left,(myContentRect.Bottom-ImagesManager.IconList.Width) div 2,ImagesManager.GetImageIndex(GetVariableValue(EntVarExt,'ENTID_Representation','bug'),BuggyIconIndex),gdeNormal);
      myContentRect.Left:=myContentRect.Left+ImagesManager.IconList.Width;
    end;
  end;
end;
procedure TNavigatorDevices.DrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: TColumnIndex; const CellText: String; const CellRect: TRect; var DefaultDraw: Boolean);
var
  pnd:PTNodeData;
  EntVarExt:TVariablesExtender;
  myCellRect:TRect;
begin
  pnd:=Sender.GetNodeData(Node);
  if pnd<>nil then
  if pnd^.Ident.pent<>nil then
  begin
    EntVarExt:=pnd^.Ident.pent^.GetExtension<TVariablesExtender>;
    if EntVarExt<>nil then begin
      SaveCellRectLeft:=CellRect.Left;
      myCellRect:=CellRect;
      DefaultDraw:=false;
      if Column=0 then
        {if EntVarExt.isMainFunction then
          myCellRect.Left:=myCellRect.Left+2*ImagesManager.IconList.Width
        else}
          myCellRect.Left:=myCellRect.Left+ImagesManager.IconList.Width;
      TargetCanvas.TextRect(myCellRect,myCellRect.Left,myCellRect.Top,CellText);
    end;
  end;
end;
procedure TNavigatorDevices.MeasureTextWidth(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
Column: TColumnIndex; const CellText: String; var Extent: Integer);
var
  pnd:PTNodeData;
  pentvarext:TVariablesExtender;
begin
  pnd:=Sender.GetNodeData(Node);
  if pnd<>nil then
  if pnd^.Ident.pent<>nil then
  begin
    pentvarext:=pnd^.Ident.pent^.GetExtension<TVariablesExtender>;
    if pentvarext<>nil then
      Extent:=Extent+2*ImagesManager.IconList.Width;
  end;
end;

function TNavigatorDevices.CreateEntityNode(Tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};basenode:PVirtualNode;pent:pGDBObjEntity;Name:string):PVirtualNode;
var
  pnd:PTNodeData;
  pentvarext:TVariablesExtender;
begin
  pentvarext:=pent^.GetExtension<TVariablesExtender>;
  if (BP.UseMainFunctions)and(pentvarext<>nil) then begin
    if not Ent2NodeMap.trygetvalue(pent,result) then begin
      result:=StandaloneNode.CreateEntityNode(Tree,basenode,pent,Name);
      pentvarext:=pent^.GetExtension<TVariablesExtender>;
      {if pentvarext<>nil then} begin
        if pentvarext.isMainFunction then begin
          pnd:=Tree.GetNodeData(result);
          pnd^.NodeMode:=TNMHardGroup;
        end;
      end;
      Ent2NodeMap.add(pent,result);
    end;
  end else begin
    result:=StandaloneNode.CreateEntityNode(Tree,basenode,pent,Name);
  end;
end;

procedure TNavigatorDevices.ExpandAllProc(Sender: TObject);
begin
  NavTree.FullExpand();
end;

procedure TNavigatorDevices.CollapseAllProc(Sender: TObject);
begin
  NavTree.FullCollapse();
end;

function TNavigatorDevices.Match(node:PVirtualNode;pattern:AnsiString):boolean;
var
  i:integer;
  ColumnText:string;
begin
  for i:=low(ExtTreeParam.ExtColumnsParams) to high(ExtTreeParam.ExtColumnsParams) do begin
    NavGetText(NavTree,node,i,ttNormal,ColumnText);
    if MatchesMask(ColumnText,pattern) then
      exit(true);
  end;
  Result:=false;
end;

function TNavigatorDevices.DoFilter(tree:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};node:PVirtualNode;pattern:AnsiString;var treeh:Integer):boolean;
var
  SubNode:PVirtualNode;
  MatchInChildren:boolean;
begin
  result:=false;
  repeat
    SubNode := node.FirstChild;
    if assigned(SubNode) then
      MatchInChildren:=DoFilter(tree,SubNode,pattern,treeh)
    else
      MatchInChildren:=false;
    if MatchInChildren then
      Tree.Expanded[Node]:=true;
    if pattern='' then
      tree.IsFiltered[node]:=false
    else begin
      if MatchInChildren or Match(node,pattern) then begin
        tree.IsFiltered[node]:=false;
        result:=true;
        treeh:=treeh+node.NodeHeight;
      end else
        tree.IsFiltered[node]:=true;
    end;
    node:=node.NextSibling;
  until (node=nil)or(node=node.NextSibling);
end;

procedure TNavigatorDevices.Filter(Sender: TObject);
var
  Pattern:AnsiString;
  FiltredTreeH:Integer;
begin
  Pattern:=TEditButton(sender).Text;
  if Pattern<>'' then
    if (pos('*',Pattern)=0)and(pos('?',Pattern)=0) then
      Pattern:='*'+Pattern+'*';
  FiltredTreeH:=0;
  DoFilter(NavTree,NavTree.RootNode,Pattern,FiltredTreeH);
  if FiltredTreeH>0 then
    if (FiltredTreeH+NavTree.OffsetY)<0 then
      NavTree.OffsetY:=0;
  NavTree.Invalidate;
end;

procedure TNavigatorDevices.EditIncludeEnts(Sender: TObject);
begin
 if not isvisible then exit;
 if RunEditor('Included entities editor','IncludeEntsEdWND',BP.IncludeEntities) then begin
   InternalRefreshTree(RefreshEqualy);
 end;
end;
procedure TNavigatorDevices.EditIncludeProperties(Sender: TObject);
begin
 if not isvisible then exit;
 if RunEditor('Included properties editor','IncludePropertiesEdWND',BP.IncludeProperties) then begin
   if assigned(EntityIncluder) then
     FreeAndNil(EntityIncluder);
   EntityIncluder:=ParserEntityPropFilter.GetTokens(BP.IncludeProperties);
   InternalRefreshTree(RefreshEqualy);
 end;
end;
procedure TNavigatorDevices.EditTreeProperties(Sender: TObject);
begin
 if not isvisible then exit;
 if RunEditor('Tree properties editor','TreePropertiesEdWND',BP.TreeProperties) then begin
   SetTreeProp;
   InternalRefreshTree(RefreshEqualy);;
 end;
end;
procedure TNavigatorDevices.InternalRefreshTree(Dist:Integer);
var
  pv:pGDBObjEntity;
  ir:itrec;
  lpsh:TLPSHandle;
  HaveErrors:boolean;
  NScrollInfo:TScrollInfo;
begin
   if not isvisible then exit;
   HaveErrors:=false;

   //TreeEnabler.Height:=MainToolBar.Height;

   NavTree.BeginUpdate;

   lpsh:=LPS.StartLongProcess('NavigatorEntities.RefreshTree',@self);
   EraseRoots;
   CreateRoots;

   try
     if drawings.GetCurrentDWG<>nil then
     begin
       pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
       if pv<>nil then
       repeat
         {if assigned(CombinedNode)then
           CombinedNode.ProcessEntity(pv,EntsFilter,TraceEntity);}
         if assigned(StandaloneNode)then
           StandaloneNode.ProcessEntity(self.CreateEntityNode,pv,EntsFilter,TraceEntity);
         pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
       until pv=nil;
     end;
   except
     on
        E:Exception do begin
          programlog.LogOutStr('Error in TNavigatorDevices.RefreshTree '+E.Message,LM_Error);
          if NDMsgCtx=nil then
            NDMsgCtx:=TMessagesContext.create('TNavigatorDevices');
          {dr:=}zcMsgDlg('Error in TNavigatorDevices.RefreshTree '+E.Message,zcdiError,[],true,NDMsgCtx);
          HaveErrors:=true;
        end;
   end;
   if not HaveErrors then
     if assigned(NDMsgCtx) then
       NDMsgCtx.clear;

   if assigned(StandaloneNodeStates) then
   begin
     StandaloneNode.RestoreState(StandaloneNodeStates,Dist);
     NavTree.OffsetXY:=StandaloneNodeStates.SaveOffset;
     FreeAndNil(StandaloneNodeStates);
   end;
   PostProcessTree;
   Filter(FilterBtn);
   LPS.EndLongProcess(lpsh);
   NavTree.EndUpdate;
end;
procedure TNavigatorDevices.RefreshTree(Sender: TObject);
begin
  InternalRefreshTree(RefreshEqualy);
end;
procedure TNavigatorDevices.SimilarRefreshTree(Sender: TObject);
begin
  InternalRefreshTree(RefreshSimilar);
end;
procedure TNavigatorDevices.PostProcessTree;

  procedure CountLeaf(Leaf:PVirtualNode;MainFunction:Boolean);
  var
    CurrentParent:PVirtualNode;
    pnd:PTNodeData;
  begin
    if Leaf<>NavTree.RootNode then begin
      CurrentParent:=Leaf.Parent;
      while CurrentParent<>NavTree.RootNode do
      begin
        pnd:=NavTree.GetNodeData(CurrentParent);
        if pnd<>nil then begin
          inc(pnd^.ppp.subLeafCounter);
          if MainFunction then
            inc(pnd^.ppp.subLeafCounterWithMainFubction);
        end;
        CurrentParent:=CurrentParent.Parent;
      end;
    end;
  end;

  procedure ProcessChild(Node:PVirtualNode);
  var
    child:PVirtualNode;
    pnd:PTNodeData;
    mf:Boolean;
    entvarext:TVariablesExtender;
  begin
    pnd:=NavTree.GetNodeData(Node);
    child:=Node.FirstChild;
    if child=nil then begin
      mf:=false;
      if pnd<>nil then
        if pnd^.Ident.pent<>nil then begin
         entvarext:=pnd^.Ident.pent^.GetExtension<TVariablesExtender>;
         if entvarext<>nil then
           mf:=entvarext.isMainFunction;
        end;
      CountLeaf(Node,mf)
    end else
      while child<>nil do begin
        if pnd<>nil then
          inc(pnd.ppp.subNodesCounter);
        ProcessChild(child);
        child:=child^.NextSibling;
      end;
  end;

begin
  if assigned(StandaloneNode)then
    ProcessChild(StandaloneNode.RootNode);
end;

procedure TNavigatorDevices.AutoRefreshTree(sender:TObject;GUIAction:TZMessageID);
var
  sender_wa:TAbstractViewArea;
  devnode:PVirtualNode;
begin
  if GUIAction=ZMsgID_GUIActionRebuild then
    InternalRefreshTree(RefreshEqualy);
  if (sender is (TAbstractViewArea))and(GUIAction=ZMsgID_GUIActionSelectionChanged) then begin
    if (NavTree.Parent<>nil)and(NavTree.Parent.isVisible) then begin
      sender_wa:=sender as TAbstractViewArea;
      if sender_wa.param.SelDesc.LastSelectedObject<>nil then begin
        if (pGDBObjEntity(sender_wa.param.SelDesc.LastSelectedObject)^.GetObjType=GDBDeviceID)and(assigned(Ent2NodeMap)) then begin
          if Ent2NodeMap.TryGetValue(sender_wa.param.SelDesc.LastSelectedObject,devnode) then begin
            NavTree.Selected[devnode]:=true;
            NavTree.FocusedNode:=devnode;
            NavTree.VisiblePath[devnode]:=true;
            NavTree.ScrollIntoView(devnode,false);
          end;
        end
      end else begin
        LastAutoselectedEnt:=nil;
        CurrentSel.Ident.pent:=nil;
        NavTree.ClearSelection;
        if assigned (StandaloneNodeStates) then
          FreeAndNil(StandaloneNodeStates);
        if assigned (StandaloneNode) then
        StandaloneNodeStates:=StandaloneNode.SaveState(CurrentSel);
      end;
    end;
  end;
end;
procedure TNavigatorDevices.AutoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key=VK_ESCAPE then
    begin
      LastAutoselectedEnt:=nil;
      CurrentSel.Ident.pent:=nil;
    end;
end;

class function TCfgFileDeskCompare.c(a,b:TCfgFileDesk):boolean;
begin
  c:=a.FileName<b.FileName;
end;

procedure EnumerateCfgs(filename:String;pdata:pointer);
var
  fd:TCfgFileDesk;
begin
  fd.FilePath:=filename;
  fd.FileName:=ChangeFileExt(ExtractFileName(filename),'');
  TCfgFilesDesks(pdata).PushBack(fd);
end;

procedure TNavigatorDevices.AsyncLoadParamsFromFile(Data: PtrInt);
var
  FilePath:string;
begin
  PtrInt(FilePath):=Data;
  LoadAndSetParamsFromFile(FilePath);
end;

procedure TNavigatorDevices.TEMenuPopUpClick(Sender: TObject);
var
  FilePath:string;
begin
  if (sender is TMenuItemWithFileDesk) then begin
    FilePath:=(sender as TMenuItemWithFileDesk).FilePath;
    Application.QueueAsyncCall(AsyncLoadParamsFromFile,PtrInt(@FilePath[1]));
    Pointer(FilePath):=nil;
  end;
end;

procedure TNavigatorDevices.TEMenuPopUp(Sender: TObject);
var
  presets:TMenuItem;
  CfgFilesDesks:TCfgFilesDesks;
  CfgFileDesk:TCfgFileDesk;
  CreatedMenuItem:TMenuItemWithFileDesk;
begin
  if sender is TStringPartEnabler then
    if assigned(TStringPartEnabler(sender).submenus) then
      if TStringPartEnabler(sender).submenus.count>0 then begin
        presets:=TStringPartEnabler(sender).submenus.Items[0];
        presets.caption:='Presets';
        presets.Clear;
        CfgFilesDesks:=TCfgFilesDesks.Create;
        FromDirsIterator(SysVar.PATH.Program_Run^,format(AllFilesWithExt,[FileExt]),'',EnumerateCfgs,nil,CfgFilesDesks);
        if CfgFilesDesks.Size>0 then begin
          if CfgFilesDesks.Size>1 then
            TCfgFilesDesksSorter.Sort(CfgFilesDesks,CfgFilesDesks.Size-1);
          presets.Enabled:=True;
          for CfgFileDesk in CfgFilesDesks do begin
            CreatedMenuItem:=TMenuItemWithFileDesk.Create(presets);
            CreatedMenuItem.Caption:=CfgFileDesk.FileName;
            CreatedMenuItem.FilePath:=CfgFileDesk.FilePath;
            CreatedMenuItem.OnClick:=TEMenuPopUpClick;
            presets.add(CreatedMenuItem);
          end;
        end else begin
          presets.Enabled:=False;
        end;
        CfgFilesDesks.Free;
  end;
end;

procedure TNavigatorDevices.LoadFromFileProc(Sender: TObject);
var
  FileName,FileFilter:String;
begin
  FileFilter:=format(rsNavigatorParamsFileFilter,[FileExt]);
  if OpenFileDialog(FileName,FileExt,FileFilter,'',rsOpenSomething) then begin
    LoadAndSetParamsFromFile(FileName);
  end;
end;

procedure TNavigatorDevices.SaveToFileProc(Sender: TObject);
var
  FileName,FileFilter:String;
begin
  FileFilter:=format(rsNavigatorParamsFileFilter,[FileExt]);
  if SaveFileDialog(FileName,FileExt,FileFilter,'',rsSaveSomething) then
    SaveParamsToFile(FileName);
end;

procedure TNavigatorDevices.PurgeFilter(Sender: TObject);
begin
  FilterBtn.Text:='';
end;

procedure TNavigatorDevices.TVDblClick(Sender: TObject);
var
  pnode:PVirtualNode;
  pnd:PTNodeData;
  pc:gdbvertex;
  bb:TBoundingBox;
const
  scale=10;
begin
  pnode:=NavTree.GetNodeAt(NavMX,NavMy);
  if pnode<>nil then
  begin
    pnd:=NavTree.GetNodeData(pnode);
    if pnd<>nil then
    if pnd^.Ident.pent<>nil then
    begin
      pc:=Vertexmorph(pnd^.Ident.pent^.vp.BoundingBox.LBN,pnd^.Ident.pent^.vp.BoundingBox.RTF,0.5);
      bb.LBN:=VertexAdd(pc,VertexMulOnSc(VertexSub(pc,pnd^.Ident.pent^.vp.BoundingBox.LBN),scale));
      bb.RTF:=VertexAdd(pc,VertexMulOnSc(VertexSub(pc,pnd^.Ident.pent^.vp.BoundingBox.RTF),scale));
      drawings.GetCurrentDWG.wa.ZoomToVolume(bb);
    end;
  end;
end;

procedure TNavigatorDevices.TVOnMouseMove(Sender: TObject; Shift: TShiftState; X,
Y: Integer);
begin
  NavMX:=x;
  NavMy:=y;
end;
procedure TNavigatorDevices.VTOnContextMenu(Sender: TObject; MousePos: TPoint;
                             var Handled: Boolean);
var
  pnode:PVirtualNode;
  PopupMenu:TPopupMenu;
begin
  Handled:=true;
  pnode:=NavTree.GetNodeAt(MousePos.X,MousePos.Y);
  if pnode<>nil then
  begin
    NavTree.Selected[pnode]:=true;
    PopupMenu:=NavigatorDevicesMenuManager.GetPopupMenu('NAVIGATORNODECONTEXTMENU',CreateNavigatorDevicesContext(NavTree,pnode),NavigatorDevicesMacros);
    if assigned(PopupMenu) then begin
      CommandManager.ContextCommandParams:=NavTree;
      PopupMenu.PopUp;
    end;
  end;
end;
procedure TNavigatorDevices.VTCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
  Result := //WideCompareStr(NavTree.Text[Node1, Column], NavTree.Text[Node2, Column]);
            AnsiNaturalCompare(NavTree.Text[Node1, Column], NavTree.Text[Node2, Column],False);
end;

procedure TNavigatorDevices.VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo
  );
begin
  if HitInfo.Button = mbLeft then
  begin
    // Меняем индекс сортирующей колонки на индекс колонки,
    // которая была нажата.
    NavTree.Header.SortColumn := HitInfo.Column;
    // Сортируем всё дерево относительно этой колонки
    // и изменяем порядок сортировки на противополжный
    if NavTree.Header.SortDirection = sdAscending then
    begin
      NavTree.Header.SortDirection := sdDescending;
      NavTree.SortTree(HitInfo.Column, NavTree.Header.SortDirection);
    end
    else begin
      NavTree.Header.SortDirection := sdAscending;
      NavTree.SortTree(HitInfo.Column, NavTree.Header.SortDirection);
    end;
  end;
end;

procedure TNavigatorDevices.NavGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                         TextType: TVSTTextType; var CellText: String);
var
  pnd:PTNodeData;
begin
  if Column<0 then
    Column:=0;
  pnd := Sender.GetNodeData(Node);
  if assigned(pnd) then
  begin
    //celltext:=pnd^.name;
  if pnd^.Ident.pent=nil then begin
    if Column=0 then begin
      if pnd^.ppp.subLeafCounter>0 then
        celltext:=format(BP.NodeNameFormat,[pnd^.Ident.name,pnd^.ppp.subNodesCounter,pnd^.ppp.subLeafCounterWithMainFubction,pnd^.ppp.subLeafCounter])
      else
        celltext:=pnd^.Ident.name;
    end else
      celltext:='';
  end else
    celltext:=textformat(ExtTreeParam.ExtColumnsParams[Column].Pattern,pnd^.Ident.pent);
  end;
end;
procedure TNavigatorDevices.SetDefaultImagesIndex;
begin
  if MainFunctionIconIndex=-1 then
    MainFunctionIconIndex:=ImagesManager.GetImageIndex('basket');
  if BuggyIconIndex=-1 then
    BuggyIconIndex:=ImagesManager.GetImageIndex('bug');
  if NavGroupIconIndex=-1 then
                              NavGroupIconIndex:=ImagesManager.GetImageIndex('navmanualgroup');
  if NavAutoGroupIconIndex=-1 then
                              NavAutoGroupIconIndex:=ImagesManager.GetImageIndex('navautogroup');
end;

procedure TNavigatorDevices.NavGetImage(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                                 var Ghosted: Boolean; var ImageIndex: Integer);
var
  pnd:PTNodeData;
  pvd:pvardesk;
  EntVarExt:TVariablesExtender;
begin
  if Column>0 then begin
    ImageIndex:=-1;
    exit;
  end;

  SetDefaultImagesIndex;
  if (assigned(StandaloneNode))and(node=StandaloneNode.RootNode) then
    ImageIndex:=StandaloneNode.ficonindex
  else begin
    pnd := Sender.GetNodeData(Node);
    if (assigned(pnd))or(Column>0) then begin
        case pnd^.NodeMode of
          TNMGroup:ImageIndex:=NavGroupIconIndex;
          TNMAutoGroup:ImageIndex:=NavAutoGroupIconIndex;
          TNMData,TNMHardGroup:begin
            if pnd^.Ident.pent<>nil then begin
              EntVarExt:=pnd^.Ident.pent^.GetExtension<TVariablesExtender>;
              if EntVarExt<>nil then begin
                if EntVarExt.isMainFunction then begin
                  pvd:=GetPVD(EntVarExt,'ENTID_Function');
                  if pvd=nil then
                    ImageIndex:=BuggyIconIndex
                  else
                    ImageIndex:=ImagesManager.GetImageIndex(pvd.data.PTD^.GetValueAsString(pvd.data.Addr.Instance),MainFunctionIconIndex);
                end else
                  ImageIndex:=-1;
              end
              else
                ImageIndex:=BuggyIconIndex;
            end else
              ImageIndex:=BuggyIconIndex;
          end;
        end;
      end else
        ImageIndex:=1;
  end;
end;

procedure TNavigatorDevices.CreateFilters;
var
  pt:TParserEntityTypeFilter.TGeneralParsedText;
begin
  if EntsTypeFilter<>nil then
    EntsTypeFilter.ResetFilter
  else
    EntsTypeFilter:=TEntsTypeFilter.Create;
  pt:=ParserEntityTypeFilter.GetTokens(BP.IncludeEntities);
  pt.Doit(EntsTypeFilter);
  EntsTypeFilter.SetFilter;
  pt.Free;
  if assigned(EntityIncluder) then
    FreeAndNil(EntityIncluder);
  EntityIncluder:=ParserEntityPropFilter.GetTokens(BP.IncludeProperties);
end;

procedure TNavigatorDevices.CreateRoots;
begin
  CreateFilters;
  StandaloneNode:=TBaseRootNodeDesk.Create(self, NavTree,rsStandaloneDevices);
  StandaloneNode.ficonindex:=ImagesManager.GetImageIndex('basket');
  Ent2NodeMap:=TEnt2NodeMap.create;
end;

procedure TNavigatorDevices.EraseRoots;
begin
  {if assigned(CombinedNode) then
  begin
    CombinedNodeStates:=CombinedNode.SaveState(CurrentSel);
    FreeAndNil(CombinedNode);
  end;}
  if assigned(StandaloneNode) then
  begin
    if Assigned(StandaloneNodeStates)then
      FreeAndNil(StandaloneNodeStates);
    StandaloneNodeStates:=StandaloneNode.SaveState(CurrentSel);
    StandaloneNodeStates.SaveOffset:=NavTree.OffsetXY;
    FreeAndNil(StandaloneNode);
  end;
  if assigned(Ent2NodeMap) then
    FreeAndNil(Ent2NodeMap);
  if assigned(EntityIncluder) then
    FreeAndNil(EntityIncluder);
end;

procedure SelectSubNodes(nav:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};pnode:PVirtualNode);
var
  psubnode:PVirtualNode;
  pnd:PTNodeData;
  i:integer;
  //s:string;
begin
  if pnode^.ChildCount>0 then begin
    psubnode:=pnode^.FirstChild;
    for i:=1 to pnode^.ChildCount do begin
      SelectSubNodes(nav,psubnode);
      pnd:=nav.GetNodeData(psubnode);
      if pnd<>nil then
        if ((pnd.NodeMode=TNMData)or(pnd.NodeMode=TNMHardGroup))and(pnd^.Ident.pent<>nil) then
          zcSelectEntity(pnd^.Ident.pent);
      psubnode:=psubnode^.NextSibling;
    end;
  end;
end;

function NavSelectSubNodes_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pnode:PVirtualNode;
  nav:{$IF DECLARED(TVirtualStringTree)}TVirtualStringTree{$ELSE}TLazVirtualStringTree{$ENDIF};
begin
     if commandmanager.ContextCommandParams<>nil then begin
       nav:=commandmanager.ContextCommandParams;
       pnode:=nav.GetFirstSelected;
       SelectSubNodes(nav,pnode);
       ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
       result:=cmd_ok;
     end else
       ZCMsgCallBackInterface.TextMessage(rscmCommandOnlyCTXMenu,TMWOHistoryOut);
end;

initialization
  CreateZCADCommand(@NavSelectSubNodes_com,'NavSelectSubNodes',CADWG,0);
  NavGroupIconIndex:=-1;
  NavAutoGroupIconIndex:=-1;
finalization
  if assigned(NDMsgCtx) then
    freeandnil(NDMsgCtx);
end.

