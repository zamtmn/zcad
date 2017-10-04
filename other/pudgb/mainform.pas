unit mainform;

{$mode delphi}{$H+}
{$DEFINE CHECKLOOPS}
{.$DEFINE GRAPHVIZUALIZER}

interface

uses
  LazUTF8,Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, ActnList, Menus, LCLIntf, Process,

  zcobjectinspectorui,uzctypesdecorations,uzedimensionaltypes,zcobjectinspector,Varman,uzbtypes,uzemathutils,UUnitManager,varmandef,zcobjectinspectoreditors,UEnumDescriptor,


  {$IFDEF CHECKLOOPS}uchecker,{$ENDIF}
  {$IFDEF GRAPHVIZUALIZER}uvizualizer,{$ENDIF}uprojectoptions,uprogramoptions,
  uoptions,uscaner,uscanresult,uwriter,yEdWriter,ulpiimporter,udpropener,uexplorer;
  {$INCLUDE revision.inc}
  type

  { TForm1 }

  TForm1 = class(TForm)
    btnVizualize: TToolButton;
    Vizualize: TAction;
    Save: TAction;
    Check: TAction;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    OpenDPR: TAction;
    CodeExplorer: TAction;
    doExit: TAction;
    OpenWebGraphviz: TAction;
    PageControl1: TPageControl;
    SaveGML: TAction;
    ImportLPI: TAction;
    Scan: TAction;
    GenerateFullGraph: TAction;
    ActionList1: TActionList;
    GDBobjinsp1: TGDBobjinsp;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    mniFile: TMenuItem;
    mniScan: TMenuItem;
    mniGenerate: TMenuItem;
    mniSeparator: TMenuItem;
    mniImportLPI: TMenuItem;
    mniSeparator2: TMenuItem;
    mniExit: TMenuItem;
    mniOpenDPR: TMenuItem;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    TabAll: TTabSheet;
    TabReport: TTabSheet;
    TabCircularGraph: TTabSheet;
    TabFullGraph: TTabSheet;
    ToolBar1: TToolBar;
    btnScan: TToolButton;
    btnGenerateFullGraph: TToolButton;
    btnImportLPI: TToolButton;
    btnGenerateGML: TToolButton;
    btnOpenWebGraViz: TToolButton;
    btnCodeExplorer: TToolButton;
    btnOpenDPR: TToolButton;
    btnCheckCircularDependecies: TToolButton;
    btnSave: TToolButton;
    procedure _CodeExplorer(Sender: TObject);
    procedure _Exit(Sender: TObject);
    procedure _SaveCurrentGraph(Sender: TObject);
    procedure _SaveGML(Sender: TObject);
    procedure _ImportLPI(Sender: TObject);
    procedure _OpenDPR(Sender: TObject);
    procedure _onClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure _onCreate(Sender: TObject);
    procedure _GenerateFullGraph(Sender: TObject);
    procedure _Scan(Sender: TObject);
    procedure _Check(Sender: TObject);
    procedure _OpenWebGraphviz(Sender: TObject);
    procedure _SetOptionFromUI(Sender: TObject);
    procedure _SetUIFromOption(Sender: TObject);
    procedure ActionUpdate(AAction: TBasicAction; var Handled: Boolean);
    procedure _Vizualize(Sender: TObject);
  private
    Options:TOptions;//Record with PProject and PProgram params, show in object inspector
    ScanResult:TScanResult;

    RunTimeUnit:ptunit;//Need for register types in object inspector
    UnitsFormat:TzeUnitsFormat;//Need for object inspector (number formats)
  public
    procedure DummyWriteToLog(msg:string; const LogOpt:TLogOpt);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1._SetOptionFromUI(Sender: TObject);
begin
   //This procedure not need for object inspector
   //this need to old removed interface
   GDBobjinsp1.updateinsp;
end;
procedure TForm1._SetUIFromOption(Sender: TObject);
begin
   //This procedure not need for object inspector
   //this need to old removed interface
   GDBobjinsp1.updateinsp;
end;

procedure TForm1.ActionUpdate(AAction: TBasicAction; var Handled: Boolean);
begin
   Handled:=true;
   if AAction=Save then
     begin
       if (PageControl1.PageIndex=TabCircularGraph.TabIndex)or
          (PageControl1.PageIndex=TabFullGraph.TabIndex) then
                                                             TAction(AAction).Enabled:=true
                                                         else
                                                             TAction(AAction).Enabled:=false;
     end;
end;

procedure TForm1._onCreate(Sender: TObject);
begin
   Options.ProjectOptions:=DefaultOptions;
   UnitsFormat:=CreateDefaultUnitsFormat;
   INTFObjInspShowOnlyHotFastEditors:=false;

   RunTimeUnit:=units.CreateUnit('',nil,'RunTimeUnit');//create empty zscript unit

   //register TProgramOptions in zscript unit
   RunTimeUnit^.RegisterType(TypeInfo(TProgramOptions));

   //setup default ProgramOptions
   Options.ProgramOptions.ProgPaths._PathToDot:='E:\Program Files (x86)\Graphviz2.38\bin\dot.exe';
   Options.ProgramOptions.ProgPaths._Temp:=GetTempDir;
   Options.ProgramOptions.Behavior.AutoClearPages:=true;
   Options.ProgramOptions.Behavior.AutoSelectPages:=true;
   Options.ProgramOptions.Visualizer.VisBackend:=VB_GDI;
   Options.ProgramOptions.Logger.ScanerMessages:=false;
   Options.ProgramOptions.Logger.ParserMessages:=false;
   Options.ProgramOptions.Logger.Timer:=true;
   Options.ProgramOptions.Logger.Notfounded:=false;


   //register TProjectOptions in zscript unit
   RunTimeUnit^.RegisterType(TypeInfo(TProjectOptions));
   //Set params names
   RunTimeUnit^.SetTypeDesk(TypeInfo(TProgPaths),['PathToDot','Temp']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TBehavior),['AutoSelectPages:','AutoClearPages']);

   RunTimeUnit^.SetTypeDesk(TypeInfo(TProjectOptions),['Paths','Parser options','Graph bulding','Log']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TPasPaths),['File','Paths']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TParser),['Compiler options','Target OS','Target CPU']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TGraphBulding),['Circular graph','Full graph','Interface uses edge type',
                                                     'Implementation uses edge type',{'Calc edges weight',}
                                                     'Path clusters',
                                                     'Collapse clusters mask',
                                                     'Expand clusters mask',
                                                     'Label clusters edges']);

   RunTimeUnit^.SetTypeDesk(TypeInfo(TCircularG),['Calc edges weight']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TFullG),['Include not founded units','Include interface uses',
                                              'Include implementation uses','Only looped edges',
                                              'Include to graph','Exclude from graph',
                                              'Source unit','Dest unit','Calc edges weight']);

   RunTimeUnit^.SetTypeDesk(TypeInfo(TEdgeType),['Continuous','Dotted']);

   //setup default ProjectOptions
   Options.ProjectOptions.Paths._File:=ExtractFileDir(ParamStr(0))+pathdelim+'passrcerrors.pas';
   Options.ProjectOptions.Paths._Paths:=ExtractFileDir(ParamStr(0));

   Options.ProjectOptions.GraphBulding.FullG.IncludeToGraph:='';
   Options.ProjectOptions.GraphBulding.FullG.ExcludeFromGraph:='';

   //Add standart and 'fast' editors for types showed in object inspector
   AddEditorToType(RunTimeUnit^.TypeName2PTD('Integer'),TBaseTypesEditors.BaseCreateEditor);//register standart editor to integer type
   AddEditorToType(RunTimeUnit^.TypeName2PTD('Double'),TBaseTypesEditors.BaseCreateEditor);//register standart editor to double type
   AddEditorToType(RunTimeUnit^.TypeName2PTD('AnsiString'),TBaseTypesEditors.BaseCreateEditor);//register standart editor to string type
   AddEditorToType(RunTimeUnit^.TypeName2PTD('String'),TBaseTypesEditors.BaseCreateEditor);//register standart editor to string type
   AddEditorToType(RunTimeUnit^.TypeName2PTD('Boolean'),TBaseTypesEditors.GDBBooleanCreateEditor);//register standart editor to string type
   AddFastEditorToType(RunTimeUnit^.TypeName2PTD('Boolean'),@OIUI_FE_BooleanGetPrefferedSize,@OIUI_FE_BooleanDraw,@OIUI_FE_BooleanInverse);
   EnumGlobalEditor:=TBaseTypesEditors.EnumDescriptorCreateEditor;//register standart editor to all enum types

   //register TOptions in zscript unit
   RunTimeUnit^.RegisterType(TypeInfo(TOptions));
   RunTimeUnit^.SetTypeDesk(TypeInfo(TOptions),['Program options','Project options']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TLogger),['Scaner messages','Parser messages','Timer','Not founded units']);

   GDBobjinsp1.setptr(nil,UnitsFormat,RunTimeUnit^.TypeName2PTD('TOptions'),@Options,nil);//show data variable in inspector
   caption:='pudgb v 0.99 rev:'+RevisionStr;
end;

procedure TForm1._onClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //clean last scan result
  if assigned(ScanResult)then FreeAndNil(ScanResult);
end;

procedure TForm1._ImportLPI(Sender: TObject);
var
  od:TOpenDialog;
begin
   //Show open lpi file dialog
   od:=TOpenDialog.Create(nil);
   od.Title:='Import Lazarus project file';
   od.Filter:='Lazarus project files (*.lpi)|*.lpi|All files (*.*)|*.*';
   od.DefaultExt:='lpi';
   od.FilterIndex := 1;
   if od.Execute then
   begin
     LPIImport(Options.ProjectOptions,od.FileName,DummyWriteToLog);
   end;
   od.Free;
   _SetUIFromOption(nil);
end;

procedure TForm1._OpenDPR(Sender: TObject);
var
  od:TOpenDialog;
begin
   //Show open dpr file dialog
   od:=TOpenDialog.Create(nil);
   od.Title:='Open Dlphi project file';
   od.Filter:='Dlphi project files (*.dpr)|*.dpr|All files (*.*)|*.*';
   od.DefaultExt:='dpr';
   od.FilterIndex := 1;
   if od.Execute then
   begin
     DPROpen(Options.ProjectOptions,od.FileName,DummyWriteToLog);
   end;
   od.Free;
   _SetUIFromOption(nil);
end;
procedure TForm1._SaveGML(Sender: TObject);
begin
    //this not implemed yet
    WriteGML(Options.ProjectOptions,ScanResult,DummyWriteToLog);
end;

procedure TForm1._Vizualize(Sender: TObject);
var
  gvp:tprocess;
  AStringList:TStringList;
  infilename,outfilename:string;
begin
   {$IFDEF GRAPHVIZUALIZER}
   infilename:=options.ProgramOptions.ProgPaths._Temp+'pudgb.dot';
   outfilename:=options.ProgramOptions.ProgPaths._Temp+'pudgb.svg';
   memo3.Lines.SaveToFile(infilename);

   gvp:=TProcess.Create(nil);
   gvp.Executable:=Options.ProgramOptions.ProgPaths._PathToDot;
   gvp.Parameters.Add('-Tsvg');
   gvp.Parameters.Add('-o'+outfilename);
   gvp.Parameters.Add(infilename);
   gvp.Options := gvp.Options + [poUsePipes,poStderrToOutPut,poNoConsole,poWaitOnExit];
   gvp.Execute;
   gvp.Free;

   VizualiserForm:=TVizualiserForm(TVizualiserForm.NewInstance);
   VizualiserForm.InFile:=TMemoryStream.Create;
   VizualiserForm.InFile.LoadFromFile(outfilename);
   VizualiserForm.VisBackend:=Options.ProgramOptions.Visualizer.VisBackend;
   VizualiserForm.Create(nil);
   VizualiserForm.ShowModal;
   VizualiserForm.Free;
   {$ELSE}
   Application.MessageBox('Please set "GRAPHVIZUALIZER" conditional def in mainform.pas','');
   {$ENDIF}
end;

procedure TForm1._Exit(Sender: TObject);
begin
 close;
end;

procedure TForm1._SaveCurrentGraph(Sender: TObject);
var
  sd:TSaveDialog;
begin
   //Show save current graph dialog
   sd:=TSaveDialog.Create(nil);
   sd.Title:='Save *.dot graph file';
   sd.Filter:='Dot files (*.dot)|*.dot|All files (*.*)|*.*';
   sd.DefaultExt:='dot';
   sd.FilterIndex := 1;
   if sd.Execute then
   begin
     if PageControl1.PageIndex=TabCircularGraph.TabIndex then
       Memo3.Lines.SaveToFile(sd.FileName)
else if PageControl1.PageIndex=TabFullGraph.TabIndex then
       Memo4.Lines.SaveToFile(sd.FileName);
   end;
   sd.Free;
end;

procedure TForm1._CodeExplorer(Sender: TObject);
begin
 //this not implemed yet
 ExploreCode(Options.ProjectOptions,ScanResult,DummyWriteToLog);
end;

procedure TForm1._GenerateFullGraph(Sender: TObject);
begin
   //write full graph to memo
   if not assigned(ScanResult) then begin
     _Scan(nil);
     _Check(nil);
   end;
   if Options.ProgramOptions.Behavior.AutoSelectPages then
     Memo4.Show;
   WriteGraph(Options.ProjectOptions,ScanResult,DummyWriteToLog);
end;
procedure TForm1._Scan(Sender: TObject);
var
  cd:ansistring;
begin
   cd:=GetCurrentDir;
   SetCurrentDir(ExtractFileDir(Options.ProjectOptions.Paths._File));

   if assigned(ScanResult)then FreeAndNil(ScanResult);//clean last scan result
   ScanResult:=TScanResult.Create;//create new scan result
   DummyWriteToLog('Start scan sources!',[LD_Clear,LD_Report]);
   if FileExists(Options.ProjectOptions.Paths._File)then
    ScanModule(Options.ProjectOptions.Paths._File,Options,ScanResult,DummyWriteToLog)//try parse main sources file
   else
    ScanDirectory(Options.ProjectOptions.Paths._File,Options,ScanResult,DummyWriteToLog);//try parse sources folder

   SetCurrentDir(cd);
end;
procedure TForm1._Check(Sender: TObject);
begin
   {$IFDEF CHECKLOOPS}
   if not assigned(ScanResult) then
     _Scan(nil);
   if Options.ProgramOptions.Behavior.AutoSelectPages then
     Memo3.Show;
   CheckGraph(Options.ProjectOptions,ScanResult,DummyWriteToLog);
   {$ENDIF}
end;
procedure TForm1._OpenWebGraphviz(Sender: TObject);
begin
  OpenURL('http://www.webgraphviz.com');
end;
procedure TForm1.DummyWriteToLog(msg:string; const LogOpt:TLogOpt);
var
  NeedClear:boolean;
begin
   //remap log messages to memo`s
   if (LD_Clear in LogOpt)and(Options.ProgramOptions.Behavior.AutoClearPages) then
    NeedClear:=true
   else
    NeedClear:=false;

   Memo1.Append(msg);
   if LD_Report in LogOpt then
     begin
       if NeedClear then
         Memo2.Lines.Clear;
       Memo2.Append(msg);
     end;
   if LD_FullGraph in LogOpt then
     begin
       if NeedClear then
         Memo4.Lines.Clear;
       Memo4.Append(msg);
     end;
   if LD_CircGraph in LogOpt then
     begin
       if NeedClear then
         Memo3.Lines.Clear;
       Memo3.Append(msg);
     end;
end;
end.

