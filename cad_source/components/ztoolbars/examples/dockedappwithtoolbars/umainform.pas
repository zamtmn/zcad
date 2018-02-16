unit umainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Menus, ActnList, StdCtrls,TypInfo,Laz2_DOM,XMLPropStorage, XMLConf,
  StdActns, AnchorDocking, AnchorDockOptionsDlg, AnchorDockPanel, AnchorDockStr,
  ButtonPanel,
  Generics.Collections,
  uztoolbarsmanager,uformsmanager;

type

  { TMainForm }

  TMainForm = class(TForm)
    AcnList: TActionList;
    DockPanel: TAnchorDockPanel;
    CoolBarUp: TCoolBar;
    CoolBarLeft: TCoolBar;
    CoolBarDown: TCoolBar;
    CoolBarRight: TCoolBar;
    StatusBar: TStatusBar;
    AcnFileExit: TFileExit;
    AcnFileOpen: TFileOpen;
    AcnLoadLayout: TAction;
    AcnSaveLayout: TAction;
    function CreateControl(aName: string;DoDisableAlign:boolean=false):TControl;
    procedure DockMasterCreateControl(Sender: TObject; aName: string;
                                      var AControl: TControl;
                                      DoDisableAutoSizing: boolean);
    procedure onCreateHandler(Sender: TObject);

    procedure AsyncLoadTBLayout(Sender: TObject);
    procedure DoLoadLayout(Data: PtrInt);

    procedure LoadLayout(Sender: TObject);
    procedure SaveLayout(Sender: TObject);

  private
    procedure CreateYourOwnTBitem(aNode: TDomNode; TB:TToolBar);
    procedure EnumerateRegistredForms(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
    procedure DefaultShowForm(Sender: TObject);
  public
    procedure LoadToolBars;
    procedure LoadDockedForms;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

function ShowAnchorDockOptions(ADockMaster: TAnchorDockMaster): TModalResult;
var
  Dlg: TForm;
  OptsFrame: TAnchorDockOptionsFrame;
  BtnPanel: TButtonPanel;
begin
  Dlg:=TForm.Create(nil);
  try
    Dlg.DisableAutoSizing;
    Dlg.Position:=poScreenCenter;
    Dlg.AutoSize:=true;
    Dlg.Caption:=adrsGeneralDockingOptions;

    OptsFrame:=TAnchorDockOptionsFrame.Create(Dlg);
    OptsFrame.Align:=alClient;
    OptsFrame.Parent:=Dlg;
    OptsFrame.Master:=ADockMaster;

    BtnPanel:=TButtonPanel.Create(Dlg);
    BtnPanel.ShowButtons:=[pbOK, pbCancel];
    BtnPanel.OKButton.OnClick:=@OptsFrame.OkClick;
    BtnPanel.Parent:=Dlg;
    Dlg.EnableAutoSizing;
    Result:=Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

function TMainForm.CreateControl(aName: string;DoDisableAlign:boolean=false):TControl;
var
  ta:TAction;
  PFID:PTFormInfoData;
  errmsg:string;
begin
  ta:=taction(AcnList.ActionByName(FormNameToActionName(aname)));
  if ta<>nil then
                 ta.Checked:=true;
  if FormsManager.GetFormInfo(aname,PFID) then
  begin
       result:=Tform(PFID^.FormClass.NewInstance);
       if assigned(PFID^.PInstanceVariable)then
         tobject(PFID^.PInstanceVariable^):=result;
       if DoDisableAlign then
         if result is TWinControl then
           TWinControl(result).DisableAlign;
       result.Create(Application);
       if PFID^.SetupProc<>nil then
         PFID^.SetupProc(result);
  end
  else
  begin
    errmsg:=format('Form "%s" not registred, create empty form',[aName]);
    Application.MessageBox(pchar(errmsg),'Warning!');

    result:=Tform(tform.NewInstance);
    if DoDisableAlign then
      TWinControl(result).DisableAlign;
    result.Create(Application);
  end;
  result.Name:=aname;
end;


procedure TMainForm.DockMasterCreateControl(Sender: TObject; aName: string; var
  AControl: TControl; DoDisableAutoSizing: boolean);
  procedure CreateForm(Caption: string; NewBounds: TRect);
  begin
       begin
           AControl:=tform.create(Application);
           AControl.Name:=aname;
           Acontrol.Caption:=caption;
           Acontrol.BoundsRect:=NewBounds;
       end;
  end;
begin
  // first check if the form already exists
  // the LCL Screen has a list of all existing forms.
  // Note: Remember that the LCL allows as form names only standard
  // pascal identifiers and compares them case insensitive
  AControl:=Screen.FindForm(aName);
  if acontrol=nil then
                      begin
                           acontrol:=DockMaster.FindControl(aname);
                      end;
  if AControl<>nil then begin
    // if it already exists, just disable autosizing if requested
    if DoDisableAutoSizing then
      AControl.DisableAutoSizing;
    exit;
  end;
  aControl:=CreateControl(aName,true);
  if assigned(aControl)then
  if not DoDisableAutoSizing then
                               Acontrol.EnableAutoSizing;
end;


procedure TMainForm.onCreateHandler(Sender: TObject);
begin
  //Setup LCL DragManager
  DragManager.DragImmediate:=false;
  DragManager.DragThreshold:=32;

  //Create ToolBarsManager
  ToolBarsManager:=TToolBarsManager.create(self{mainform},AcnList{main AcnList},-1{default button height});

  //Register 'Separator' node handler for create toolbar content proc
  ToolBarsManager.RegisterTBItemCreateFunc('Separator',@ToolBarsManager.CreateDefaultSeparator);

  //Register 'Action' node handler for create toolbar content proc
  ToolBarsManager.RegisterTBItemCreateFunc('Action',@ToolBarsManager.CreateDefaultAction);

  //Register 'YourOwnTBitem' node fake handler for create toolbar content proc
  ToolBarsManager.RegisterTBItemCreateFunc('YourOwnTBitem',@CreateYourOwnTBitem);

  //Register 'ToolBar' create proc
  ToolBarsManager.RegisterTBCreateFunc('ToolBar',@ToolBarsManager.CreateDefaultToolBar);

  //Load toolbars content from toolbarscontent.xml
  ToolBarsManager.LoadToolBarsContent('toolbarscontent.xml');

  ToolBarsManager.RegisterMenuCreateFunc('MainMenuItem',@ToolBarsManager.DefaultMainMenuItemReader);
  ToolBarsManager.RegisterMenuCreateFunc('Action',@ToolBarsManager.CreateDefaultMenuAction);
  ToolBarsManager.RegisterMenuCreateFunc('Separator',@ToolBarsManager.CreateDefaultMenuSeparator);
  ToolBarsManager.RegisterMenuCreateFunc('CreateMenu',@ToolBarsManager.CreateDefaultMenu);
  ToolBarsManager.RegisterMenuCreateFunc('SetMainMenu',@ToolBarsManager.DefaultSetMenu);
  ToolBarsManager.RegisterMenuCreateFunc('ToolBars',@ToolBarsManager.DefaultAddToolbars);
  ToolBarsManager.RegisterMenuCreateFunc('Forms',@EnumerateRegistredForms);


  //Enumerate all toolbars and add them to view\tooldars menu
  //ToolBarsManager.EnumerateToolBars(@ToolBarsManager.DefaultAddToolBarToMenu,pointer(MenuItem6));

  //Load menus content from menuscontent.xml
  ToolBarsManager.LoadMenus('menuscontent.xml');

  DockMaster.ManagerClass:=TAnchorDockManager;
  DockMaster.OnCreateControl:=@DockMasterCreateControl;
  DockMaster.MakeDockPanel(DockPanel,admrpChild);
  DockMaster.OnShowOptions:=@ShowAnchorDockOptions;

  //Load toolbars layout
  LoadLayout(nil);
end;

//Save current toolbars layout
procedure TMainForm.SaveLayout(Sender: TObject);
var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:='toolbarslayout.xml';
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      ToolBarsManager.SaveToolBarsToConfig(self,Config);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;

  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:='formslayout.xml';
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      DockMaster.SaveLayoutToConfig(Config);
      DockMaster.SaveSettingsToConfig(Config);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;

//load toolbar procedure
procedure TMainForm.DoLoadLayout(Data: PtrInt);
begin
    LoadToolBars;
    LoadDockedForms;
end;

//async wrapper for load toolbar procedure
//this is necessary because of the of all existing
//toolbars destroy before new loading
//and if call LoadTBLayout by load button clicked - app crashed
//this used in actions
procedure TMainForm.AsyncLoadTBLayout(Sender: TObject);
begin
 Application.QueueAsyncCall(@DoLoadLayout, 0);
end;

//sync wrapper for load toolbar procedure
//this used in code
procedure TMainForm.LoadLayout(Sender: TObject);
begin
    DoLoadLayout(0);
end;

//'YourOwnTBitem' node fake handler
procedure TMainForm.CreateYourOwnTBitem(aNode: TDomNode; TB:TToolBar);
begin
   //you need read aNode params to create your own toolbar item
   //but because of laziness, I'll just create a empty button ))
    with TToolButton.Create(tb) do
    begin
      Caption:='Empty';
      Hint:='Empty button from "YourOwnTBitem" node fake handler';
      ShowCaption:=true;
      ShowHint:=true;
      Parent:=tb;
      Visible:=true;
    end;
end;

procedure TMainForm.LoadToolBars;
var
  XMLConfig: TXMLConfigStorage;
begin
  XMLConfig:=TXMLConfigStorage.Create('toolbarslayout.xml', True);
  try
    ToolBarsManager.RestoreToolBarsFromConfig(self, XMLConfig);
  finally
    XMLConfig.Free;
  end;
end;

procedure TMainForm.LoadDockedForms;
var
  XMLConfig: TXMLConfigStorage;
begin
  try
    // load the xml config file
    XMLConfig:=TXMLConfigStorage.Create('formslayout.xml',True);
    try
      // restore the layout
      // this will close unneeded forms and call OnCreateControl for all needed

      {if assigned(ZCADMainWindow.updatesbytton) then
        ZCADMainWindow.updatesbytton.Clear;
      if assigned(ZCADMainWindow.updatescontrols) then
        ZCADMainWindow.updatescontrols.Clear;}

      DockMaster.LoadLayoutFromConfig(XMLConfig,false);
      DockMaster.LoadSettingsFromConfig(XMLConfig);
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      {MessageDlg('Error',
        'Error loading layout from file '+Filename+':'#13+E.Message,mtError,
        [mbCancel],0);}
    end;
  end;
end;

procedure TMainForm.DefaultShowForm(Sender: TObject);
begin
  if sender is TAction then
    DockMaster.ShowControl((Sender as TAction).Caption,true)
end;

procedure TMainForm.EnumerateRegistredForms(aName: string;aNode: TDomNode;actlist:TActionList;RootMenuItem:TMenuItem);
var
  FormData:specialize TPair<string,TFormInfoData>;
  pm1:TMenuItem;
  aaction:taction;
begin
  for FormData in FormsManager.FormsInfo do
  begin
    aaction:=TAction.Create(self);
    aaction.Name:=FormNameToActionName(FormData.Value.FormName);
    aaction.Caption:=FormData.Value.FormName;
    aaction.OnExecute:=@DefaultShowForm;
    aaction.DisableIfNoHandler:=false;
    aaction.ActionList:=AcnList;

    pm1:=TMenuItem.Create(RootMenuItem);
    pm1.Action:=aaction;
    RootMenuItem.Add(pm1);
  end;
end;

end.

