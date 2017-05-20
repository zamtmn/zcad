unit uvizualizer;

{$mode objfpc}{$H+}
{$define dxfio}
interface

uses
  LCLType,Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ActnList, ComCtrls,
  {From ZCAD}
  uzbmemman,                                                                       //zcad memorymanager
  uzbtypes, uzbtypesbase,uzbgeomtypes,                                              //zcad basetypes
  uzegeometry,                                                                     //some mathematical and geometrical support
  uzefontmanager,uzeffshx,                                                        //fonts manager and SHX fileformat support
  uzglviewareaabstract,uzglviewareageneral,uzgldrawcontext,                          //generic view areas support
  uzglviewareaogl,uzglviewareagdi,                                           //gdi and opengl wiewareas
  uzeentity,                                                                    //generic entitys objects parent
  uzeent3Dface,uzeentlwpolyline,uzeentpolyline,uzeenttext,uzeentline,uzeentcircle,uzeentarc,         //entitys created by program
  {$ifdef dxfio}
  uzeffdxf,                                                                        //dxf fileformat support
  uzeentmtext,uzeentdimensiongeneric,uzeentdimaligned,uzeentdimrotated,uzeentsolid,//some other entitys can be found in loaded files
  uzeentspline,
  {$endif}
  uzestyleslayers,uzestylestexts,                                            //layers and text steles support
  uzeentitiestree,                                                                  //entities spatial binary tree
  uzedrawingsimple,                                                            //drawing

  uprogramoptions,

  gzctnrvectortypes,uzeconsts;                                                           //some consts

type

  { TVizualiserForm }

  TVizualiserForm = class(TForm)
    SaveDXF: TAction;
    ActionList1: TActionList;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    procedure BtnRebuildClick(Sender: TObject);        //Rebuild spatial tree in current drawing
    procedure BtnSaveDXFClick(Sender: TObject);        //Save dxf file (if set $define dxfio)
    procedure _DestroyApp(Sender: TObject);
    procedure _FormCreate(Sender: TObject);
    procedure _KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure _StartLongProcess(TotalProgressCount:Integer{unused in this example};ProcessName:string);//proc for start time interval measure
    procedure _EndLongProcess;//proc for end time interval measure
  private
    pdrawing1:PTSimpleDrawing;
    { private declarations }
  public
    { public declarations }
    VisBackend:TVisBackend;
  end; 

var
  VizualiserForm: TVizualiserForm;
  LPTime:Tdatetime;
  pname:string;

implementation

{$R *.lfm}
function GetCurrentDrawing:PTSimpleDrawing;//get current drawing (OPENGL or GDI) set in ComboBox1
begin
 result:=VizualiserForm.pdrawing1
end;
procedure TVizualiserForm._StartLongProcess(TotalProgressCount:integer;ProcessName:string);//get current drawing (OPENGL or GDI) set in ComboBox1
begin
     LPTime:=now;
     pname:=ProcessName;
end;
procedure TVizualiserForm._EndLongProcess;
var
  Time:Tdatetime;
  ts:string;
begin
 time:=(now-LPTime)*10e4;
 str(time:3:4,ts);
  if pname='' then
                   {memo1.Append(format('Done.  %s second',[ts]))}
               else
                   {memo1.Append(pname+format(':  %s second',[ts]))};
  pname:=''
end;

procedure TVizualiserForm._KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);//key pressed handle, now unused in this example
begin
  if Key=VK_ESCAPE then
  begin
       GetCurrentDrawing^.SelObjArray.Free;
       GetCurrentDrawing^.GetCurrentROOT^.ObjArray.DeSelect(GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount,nil);
       GetCurrentDrawing^.HardReDraw;
       Key:=0;
  end;
end;

procedure TVizualiserForm._FormCreate(Sender: TObject);//Create drawings and view areas
var
   i:integer;
   ViewArea:TAbstractViewArea;
   WADrawControl:TCADControl;
begin
     FontManager.CreateBaseFont;//Load default font (gewind.shx - simply vector font in program resources)

     pdrawing1:=CreateSimpleDWG;//create drawing

     //Add 10 random layers
     for i:=1 to 10 do
     begin
          pdrawing1^.LayerTable.addlayer(inttostr(i),{name}
                                         random(255),{color index}
                                         0,          {lineweight}
                                         true,       {layer on}
                                         false,      {layer locked}
                                         true,       {layer printable}
                                         '',         {layer description}
                                         TLOMerge    {TLOMerge - if layer already created, ignore new layer properties
                                                      TLOLoad  - if layer already created, rewrite old layer properties});
     end;


     case VisBackend of
         VB_GDI:ViewArea:=TGDIViewArea.Create(Panel1);//Create view area (GDI)
         VB_Opengl:ViewArea:=TOpenGLViewArea.Create(Panel1);//Create view area (OPENGL)
     end;
     WADrawControl:=ViewArea.getviewcontrol;//Get window which will be drawing
     pdrawing1^.wa:=ViewArea;//associate drwing with window
     ViewArea.PDWG:=pdrawing1;//associate window with drawing

     WADrawControl.align:=alClient;
     WADrawControl.Parent:=Panel1;
     WADrawControl.show;

     ViewArea.getareacaps;//setup internal view area params
     //ViewArea.Drawer.delmyscrbuf;
     pdrawing1^.HardReDraw;//redraw drawing on view area

end;

procedure SetEntityLayer(pobj:PGDBObjEntity;CurrentDrawing:PTSimpleDrawing);//set random layer for entity
begin
     pobj^.vp.Layer:=CurrentDrawing^.LayerTable.getDataMutable(random(CurrentDrawing^.LayerTable.Count));
end;

procedure TVizualiserForm.BtnRebuildClick(Sender: TObject);
var
   dc:TDrawContext;
begin
     _StartLongProcess(0,'Rebuild spatial tree');
     dc:=GetCurrentDrawing^.CreateDrawingRC;
     GetCurrentDrawing^.pObjRoot^.calcbb(dc);
     GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree.maketreefrom(GetCurrentDrawing^.pObjRoot^.ObjArray,GetCurrentDrawing^.pObjRoot^.vp.BoundingBox,nil);
     //GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree:=createtree(GetCurrentDrawing^.pObjRoot^.ObjArray,GetCurrentDrawing^.pObjRoot^.vp.BoundingBox,@GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
     _EndLongProcess;
     GetCurrentDrawing^.HardReDraw;
end;

procedure TVizualiserForm.BtnSaveDXFClick(Sender: TObject);
begin
     {$ifdef dxfio}
     if SaveDialog1.Execute then
     begin
          savedxf2000(SaveDialog1.FileName, GetCurrentDrawing^);
     end;
     {$endif}
end;

procedure TVizualiserForm._DestroyApp(Sender: TObject);
begin
 pdrawing1^.done;
 gdbfreemem(pdrawing1);
end;


end.

