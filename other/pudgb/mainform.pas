unit mainform;

{$mode delphi}{$H+}
{$DEFINE CHECKLOOPS}

interface

uses
  LazUTF8,Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, ActnList, Menus, LCLIntf,

  zcobjectinspectorui,uzctypesdecorations,uzedimensionaltypes,zcobjectinspector,Varman,uzbtypes,uzemathutils,UUnitManager,varmandef,zcobjectinspectoreditors,UEnumDescriptor,


  {$IFDEF CHECKLOOPS}uchecker,{$ENDIF}
  uprojectoptions,uscaner,uscanresult,uwriter,yEdWriter,ulpiimporter,udpropener,uexplorer;
  {$INCLUDE revision.inc}
  type

  { TForm1 }

  TForm1 = class(TForm)
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
  private
    Options:TProjectOptions;//Record with params, show in object inspector
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
   Options:=DefaultOptions;
   UnitsFormat:=CreateDefaultUnitsFormat;
   INTFObjInspShowOnlyHotFastEditors:=false;

   RunTimeUnit:=units.CreateUnit('',nil,'RunTimeUnit');//create empty zscript unit

   //register TProjectOptions in zscript unit
   RunTimeUnit^.RegisterType(TypeInfo(TProjectOptions));
   //Set params names
   RunTimeUnit^.SetTypeDesk(TypeInfo(TProjectOptions),['Paths','Parser options','Graph bulding','Log']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TPaths),['File','Paths']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TParser),['Compiler options','Target OS','Target CPU']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TGraphBulding),['Circular graph','Full graph','Interface uses edge type',
                                                     'Implementation uses edge type',{'Calc edges weight',}
                                                     'Path clusters']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TCircularG),['Calc edges weight']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TFullG),['Include not founded units','Include interface uses',
                                              'Include implementation uses','Only looped edges',
                                              'Include to graph','Exclude from graph',
                                              'Source unit','Dest unit','Calc edges weight']);

   RunTimeUnit^.SetTypeDesk(TypeInfo(TLogger),['Scaner messages','Parser messages','Timer','Not founded units']);
   RunTimeUnit^.SetTypeDesk(TypeInfo(TEdgeType),['Continuous','Dotted']);

   //setup default options
   Options.Paths._File:=ExtractFileDir(ParamStr(0))+pathdelim+'passrcerrors.pas';
   Options.Paths._Paths:=ExtractFileDir(ParamStr(0));
   Options.Logger.ScanerMessages:=false;
   Options.Logger.ParserMessages:=false;
   Options.Logger.Timer:=true;
   Options.Logger.Notfounded:=false;

   Options.GraphBulding.FullG.IncludeToGraph:='';
   Options.GraphBulding.FullG.ExcludeFromGraph:='';

   //Add standart and 'fast' editors for types showed in object inspector
   AddEditorToType(RunTimeUnit^.TypeName2PTD('Integer'),TBaseTypesEditors.BaseCreateEditor);//register standart editor to integer type
   AddEditorToType(RunTimeUnit^.TypeName2PTD('Double'),TBaseTypesEditors.BaseCreateEditor);//register standart editor to double type
   AddEditorToType(RunTimeUnit^.TypeName2PTD('AnsiString'),TBaseTypesEditors.BaseCreateEditor);//register standart editor to string type
   AddEditorToType(RunTimeUnit^.TypeName2PTD('String'),TBaseTypesEditors.BaseCreateEditor);//register standart editor to string type
   AddEditorToType(RunTimeUnit^.TypeName2PTD('Boolean'),TBaseTypesEditors.GDBBooleanCreateEditor);//register standart editor to string type
   AddFastEditorToType(RunTimeUnit^.TypeName2PTD('Boolean'),@OIUI_FE_BooleanGetPrefferedSize,@OIUI_FE_BooleanDraw,@OIUI_FE_BooleanInverse);
   EnumGlobalEditor:=TBaseTypesEditors.EnumDescriptorCreateEditor;//register standart editor to all enum types

   GDBobjinsp1.setptr(nil,UnitsFormat,RunTimeUnit^.TypeName2PTD('TProjectOptions'),@Options,nil);//show data variable in inspector
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
     LPIImport(Options,od.FileName,DummyWriteToLog);
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
     DPROpen(Options,od.FileName,DummyWriteToLog);
   end;
   od.Free;
   _SetUIFromOption(nil);
end;
procedure TForm1._SaveGML(Sender: TObject);
begin
    //this not implemed yet
    WriteGML(Options,ScanResult,DummyWriteToLog);
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
 ExploreCode(Options,ScanResult,DummyWriteToLog);
end;

procedure TForm1._GenerateFullGraph(Sender: TObject);
begin
   //write full graph to memo
   WriteGraph(Options,ScanResult,DummyWriteToLog);
end;
procedure TForm1._Scan(Sender: TObject);
var
  cd:ansistring;
begin
   cd:=GetCurrentDir;
   SetCurrentDir(ExtractFileDir(Options.Paths._File));

   if assigned(ScanResult)then FreeAndNil(ScanResult);//clean last scan result
   ScanResult:=TScanResult.Create;//create new scan result
   DummyWriteToLog('Start scan sources!',[LD_Clear,LD_Report]);
   if FileExists(Options.Paths._File)then
    ScanModule(Options.Paths._File,Options,ScanResult,DummyWriteToLog)//try parse main sources file
   else
    ScanDirectory(Options.Paths._File,Options,ScanResult,DummyWriteToLog);//try parse sources folder

   SetCurrentDir(cd);
end;
procedure TForm1._Check(Sender: TObject);
begin
   {$IFDEF CHECKLOOPS}CheckGraph(Options,ScanResult,DummyWriteToLog);{$ENDIF}//check  result graph (for loops), and write loops to memo
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
   if LD_Clear in LogOpt then
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

