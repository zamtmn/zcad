unit uvizualizer;

{$mode objfpc}{$H+}
{$define dxfio}
interface

uses
  LCLType,Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Spin,
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
  gzctnrvectortypes,uzeconsts;                                                           //some consts

type

  { TVizualiserForm }

  TVizualiserForm = class(TForm)
    BtnAdd3DFaces1: TButton;
    BtnAddCircles1: TButton;
    BtnAddLWPolyLines1: TButton;
    BtnAddLines: TButton;
    BtnAddCircles: TButton;
    BtnAdd3DpolyLines: TButton;
    BtnAdd3DFaces: TButton;
    BtnProcessObjects1: TButton;
    BtnProcessObjects2: TButton;
    BtnSelectAll: TButton;
    BtnRebuild: TButton;
    BtnEraseSel: TButton;
    BtnAddTexts: TButton;
    BtnOpenDXF: TButton;
    BtnSaveDXF: TButton;
    BtnProcessObjects: TButton;
    CheckBox1: TCheckBox;
    ChkBox3D: TCheckBox;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    PanelUp: TPanel;
    SaveDialog1: TSaveDialog;
    SpinEdit1: TSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure BtnAdd3DFaces1Click(Sender: TObject);    //Add 3dfaces to current drawing
    procedure BtnAdd3DpolyLinesClick(Sender: TObject); //Add 3dpolylines to current drawing
    procedure BtnAddArcsClick(Sender: TObject);        //Add arcs to current drawing
    procedure BtnAddLinesClick(Sender: TObject);       //Add lines to current drawing
    procedure BtnAddCirclesClick(Sender: TObject);     //Add circles to current drawing
    procedure BtnAddLWPolylines1Click(Sender: TObject);//Add lwpolylines to current drawing
    procedure BtnAddSplines1Click(Sender: TObject);
    procedure BtnProcessObjectsClick(Sender: TObject); //Move lines and circles in current drawing
    procedure BtnRebuildClick(Sender: TObject);        //Rebuild spatial tree in current drawing
    procedure BtnEraseSelClick(Sender: TObject);       //Erase selected ents in current drawing
    procedure BtnAddTextsClick(Sender: TObject);       //Add texts to current drawing
    procedure BtnOpenDXFClick(Sender: TObject);        //Load dxf file (if set $define dxfio)
    procedure BtnSaveDXFClick(Sender: TObject);        //Save dxf file (if set $define dxfio)
    procedure BtnSelectAllClick(Sender: TObject);      //Select all ents in current drawing
    procedure OffEntLayerClick(Sender: TObject);       //Off layers selected ents in current drawing
    procedure OnAllLayerClick(Sender: TObject);        //On all layer
    procedure TreeChange(Sender: TObject);             //"Show tree" checkbox click
    procedure _DestroyApp(Sender: TObject);
    procedure _FormCreate(Sender: TObject);
    procedure _KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure _FormShow(Sender: TObject);

    procedure _StartLongProcess(TotalProgressCount:Integer{unused in this example};ProcessName:string);//proc for start time interval measure
    procedure _EndLongProcess;//proc for end time interval measure
  private
    pdrawing1,pdrawing2:PTSimpleDrawing;
    { private declarations }
  public
    { public declarations }
  end; 

var
  VizualiserForm: TVizualiserForm;
  LPTime:Tdatetime;
  pname:string;

implementation

{$R *.lfm}
function GetCurrentDrawing:PTSimpleDrawing;//get current drawing (OPENGL or GDI) set in ComboBox1
begin
     if VizualiserForm.ComboBox1.ItemIndex=0 then
                                        result:=VizualiserForm.pdrawing1
                                    else
                                        result:=VizualiserForm.pdrawing2;
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
                   memo1.Append(format('Done.  %s second',[ts]))
               else
                   memo1.Append(pname+format(':  %s second',[ts]));
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
  if Key=VK_DELETE then
  begin
       BtnEraseSelClick(nil);
       Key:=0;
  end;
end;

procedure TVizualiserForm._FormShow(Sender: TObject);
begin
    //_FormCreate(nil);
end;

procedure TVizualiserForm._FormCreate(Sender: TObject);//Create drawings and view areas
var
   i:integer;
   ViewArea:TAbstractViewArea;
   WADrawControl:TCADControl;
begin
     FontManager.CreateBaseFont;//Load default font (gewind.shx - simply vector font in program resources)
     sysvarDISPSystmGeometryDraw:=CheckBox1.Checked;//Draw|notdraw help uzegeometry (insert points, bounding boxes...)

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


     ViewArea:=TOpenGLViewArea.Create(PanelUp);//Create view area (OPENGL)
     WADrawControl:=ViewArea.getviewcontrol;//Get window which will be drawing
     pdrawing1^.wa:=ViewArea;//associate drwing with window
     ViewArea.PDWG:=pdrawing1;//associate window with drawing

     WADrawControl.align:=alClient;
     WADrawControl.Parent:=PanelUp;
     WADrawControl.show;

     ViewArea.getareacaps;//setup internal view area params
     //ViewArea.Drawer.delmyscrbuf;
     pdrawing1^.HardReDraw;//redraw drawing on view area


     pdrawing2:=CreateSimpleDWG;//create drawing

     //Add 10 random layers
     for i:=1 to 10 do
     begin
          pdrawing2^.LayerTable.addlayer(inttostr(i),random(255),0,true,false,true,'',TLOMerge);
     end;


     ViewArea:=TGDIViewArea.Create(Panel2);//Create view area (GDI)
     WADrawControl:=ViewArea.getviewcontrol;//Get window which will be drawing
     pdrawing2^.wa:=ViewArea;//associate drwing with window
     ViewArea.PDWG:=pdrawing2;//associate window with drawing

     WADrawControl.align:=alClient;
     WADrawControl.Parent:=Panel2;
     WADrawControl.show;

     ViewArea.getareacaps;//setup internal view area params
     pdrawing2^.HardReDraw;//redraw drawing on view area
end;

function CreateRandomDouble(len:GDBDouble):GDBDouble;inline;//create random double in [0..len] interval
begin
     result:=random*len;
end;
function CreateRandomVertex(len,hanflen:GDBDouble;_3d:boolean):GDBVertex;//create random 3DVertex in [-hanflen..hanflen] interval
begin
     result.x:=CreateRandomDouble(len)-hanflen;
     result.y:=CreateRandomDouble(len)-hanflen;
     if _3d then
                result.z:=CreateRandomDouble(len)-hanflen
            else
                result.z:=0;
end;
procedure SetEntityLayer(pobj:PGDBObjEntity;CurrentDrawing:PTSimpleDrawing);//set random layer for entity
begin
     pobj^.vp.Layer:=CurrentDrawing^.LayerTable.getDataMutable(random(CurrentDrawing^.LayerTable.Count));
end;
function CreateRandomVertex2D(len,hanflen:GDBDouble):GDBVertex2D;//create random 2DVertex in [-hanflen..hanflen] interval
begin
     result.x:=CreateRandomDouble(len)-hanflen;
     result.y:=CreateRandomDouble(len)-hanflen;
end;

procedure TVizualiserForm.BtnAddLinesClick(Sender: TObject);         //Add lines to drawing
var
   i:integer;
   PLineEnt:PGDBObjLine;                                    //pointer to created line
   v1,v2:gdbvertex;
   dc:TDrawContext;                                         //drawing context
   CurrentDrawing:PTSimpleDrawing;                          //pointer to current drawing
   _3d:boolean;
begin
  _StartLongProcess(0,'Add lines');                         //just for time interval measure

  _3d:=VizualiserForm.ChkBox3D.Checked;
  CurrentDrawing:=GetCurrentDrawing;                        //get cirrent drawing
  dc:=CurrentDrawing^.CreateDrawingRC;                      //create drawing context, need for format entity
  for i:=1 to SpinEdit1.Value do
  begin
    v1:=CreateRandomVertex(1000,500,_3d);                       //line coord
    v2:=uzegeometry.VertexAdd(v1,CreateRandomVertex(1000,500,_3d));//line coord

    PLineEnt:=GDBObjLine.CreateInstance;                    //create line
    PLineEnt^.CoordInOCS.lBegin:=v1;                        //setup coord
    PLineEnt^.CoordInOCS.lEnd:=v2;                          //setup coord
    SetEntityLayer(PLineEnt,CurrentDrawing);                //Setup line propertues
    CurrentDrawing^.GetCurrentRoot^.AddMi(@PLineEnt);       //add line to drawing

    PLineEnt^.BuildGeometry(CurrentDrawing^);               //internal entity proc for create subentities,
                                                            //for line entity this unneed, but for complex entities
                                                            //like BlockInsert thes necessarily

    PLineEnt^.formatEntity(CurrentDrawing^,dc);             //internal entity proc for create graphix representation
  end;
  _EndLongProcess;                                          //end interval measure

  BtnRebuildClick(self);                                    //rebuild drawing spatial tree and redraw
end;

procedure TVizualiserForm.BtnAddLWPolylines1Click(Sender: TObject);         //Add lwpolylines to drawing
var
   i,j,vcount:integer;
   PLWPolyLineEnt:PGDBObjLWPolyline;                               //pointer to created lwpolyline
   v1:gdbvertex2d;                                                 //lwpolyline vertex
   lw:GLLWWidth;                                                   //lwpolyline vertex width props
   dc:TDrawContext;                                                //drawing context
   CurrentDrawing:PTSimpleDrawing;                                 //pointer to current drawing
begin
  _StartLongProcess(0,'Add lwpolylines');                          //just for time interval measure

  CurrentDrawing:=GetCurrentDrawing;                               //get cirrent drawing
  dc:=CurrentDrawing^.CreateDrawingRC;                             //create drawing context, need for format entity

  for i:=1 to SpinEdit1.Value do
  begin
    PLWPolyLineEnt := GDBObjLWPolyline.CreateInstance;             //create lwpolyline

    vcount:=random(8)+2;                                           //add add random polyline vertexs
    v1:=CreateRandomVertex2D(1000,500);
    for j:=1 to vcount do
    begin
         PLWPolyLineEnt^.Vertex2D_in_OCS_Array.PushBackData(v1);
         lw.endw:=CreateRandomDouble(10);
         lw.startw:=CreateRandomDouble(10);
         PLWPolyLineEnt^.Width2D_in_OCS_Array.PushBackData(lw);
         v1:=uzegeometry.Vertex2DAdd(v1,CreateRandomVertex2D(100,50));
    end;
    if vcount>2 then
                    PLWPolyLineEnt^.closed:=random(10)>5;          //random close lwpolyline

    CurrentDrawing^.GetCurrentRoot^.AddMi(@PLWPolyLineEnt);        //add lwpolyline to drawing
    SetEntityLayer(PLWPolyLineEnt,GetCurrentDrawing);              //Setup line propertues
    PLWPolyLineEnt^.BuildGeometry(CurrentDrawing^);                //internal entity proc for create subentities,
                                                                   //for line entity this unneed, but for complex entities
                                                                   //like BlockInsert thes necessarily

    PLWPolyLineEnt^.formatEntity(CurrentDrawing^,dc);              //internal entity proc for create graphix representation
  end;
  _EndLongProcess;                                                 //end interval measure

  BtnRebuildClick(self);                                           //rebuild drawing spatial tree and redraw
end;

procedure TVizualiserForm.BtnAddSplines1Click(Sender: TObject);
var
   i,j:integer;
   pobj:PGDBObjSpline;
   v1:gdbvertex;
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add splines');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := GDBObjSpline.CreateInstance;
    v1:=CreateRandomVertex(1000,500,VizualiserForm.ChkBox3D.Checked);
    for j:=0 to 4 do
    begin
         pobj^.VertexArrayInOCS.PushBackData(v1);
         v1:=uzegeometry.VertexAdd(v1,CreateRandomVertex(100,50,VizualiserForm.ChkBox3D.Checked));
    end;
    pobj^.Knots.PushBackData(0);
    pobj^.Knots.PushBackData(0);
    pobj^.Knots.PushBackData(0);
    pobj^.Knots.PushBackData(0);
    pobj^.Knots.PushBackData(1);
    pobj^.Knots.PushBackData(2);
    pobj^.Knots.PushBackData(2);
    pobj^.Knots.PushBackData(2);
    pobj^.Knots.PushBackData(2);
    pobj^.Degree:=3;
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    SetEntityLayer(pobj,GetCurrentDrawing);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TVizualiserForm.BtnAdd3DFaces1Click(Sender: TObject);
var
   i,j:integer;
   istriangle:boolean;
   pobj:PGDBObj3DFace;
   v1:gdbvertex;
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add 3dfaces');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := GDBObj3DFace.CreateInstance;
    istriangle:=random(10)>5;
    v1:=CreateRandomVertex(1000,500,VizualiserForm.ChkBox3D.Checked);
    for j:=0 to 2 do
    begin
         pobj^.PInOCS[j]:=v1;
         v1:=uzegeometry.VertexAdd(v1,CreateRandomVertex(100,50,VizualiserForm.ChkBox3D.Checked));
    end;
    if istriangle then
                      pobj^.PInOCS[3]:=pobj^.PInOCS[2]
                  else
                      pobj^.PInOCS[3]:=v1;
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    SetEntityLayer(pobj,GetCurrentDrawing);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;
procedure TVizualiserForm.BtnProcessObjectsClick(Sender: TObject);
var
    pv:pGDBObjEntity;
    ir:itrec;
    l,hl:double;
begin
  _StartLongProcess(0,'Move objects');
  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        case pv^.GetObjType of
        GDBLineID:begin
                       l:=Vertexlength(PGDBObjLine(pv)^.CoordInWCS.lbegin,PGDBObjLine(pv)^.CoordInWCS.lend)/10;
                       hl:=l/2;
                       PGDBObjLine(pv)^.CoordInOCS.lBegin:=uzegeometry.VertexAdd(PGDBObjLine(pv)^.CoordInOCS.lBegin,CreateRandomVertex(l,hl,VizualiserForm.ChkBox3D.Checked));
                       PGDBObjLine(pv)^.CoordInOCS.lEnd:=uzegeometry.VertexAdd(PGDBObjLine(pv)^.CoordInOCS.lEnd,CreateRandomVertex(l,hl,VizualiserForm.ChkBox3D.Checked));
                       pv^.YouChanged(GetCurrentDrawing^);
                  end;
        GDBCircleID:begin
                       l:=PGDBObjCircle(pv)^.Radius;
                       hl:=l/2;
                       PGDBObjCircle(pv)^.Local.P_insert:=uzegeometry.VertexAdd(PGDBObjCircle(pv)^.Local.P_insert,CreateRandomVertex(l,hl,VizualiserForm.ChkBox3D.Checked));
                       PGDBObjCircle(pv)^.Radius:=PGDBObjCircle(pv)^.Radius+CreateRandomDouble(l)-hl;
                       if PGDBObjCircle(pv)^.Radius<=0 then PGDBObjCircle(pv)^.Radius:=CreateRandomDouble(9)+1;
                       pv^.YouChanged(GetCurrentDrawing^);
                  end;
        end;
  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  _EndLongProcess;

  GetCurrentDrawing^.HardReDraw;
end;

procedure TVizualiserForm.BtnAddCirclesClick(Sender: TObject);
var
   i:integer;
   pobj:PGDBObjCircle;
   v1:gdbvertex;
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add circles');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := GDBObjCircle.CreateInstance ;
    v1:=CreateRandomVertex(1000,500,VizualiserForm.ChkBox3D.Checked);
    pobj^.Local.P_insert:=v1;
    pobj^.Radius:=CreateRandomDouble(9.9)+0.1;
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    SetEntityLayer(pobj,GetCurrentDrawing);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TVizualiserForm.BtnAdd3DpolyLinesClick(Sender: TObject);
var
   i,j,vcount:integer;
   pobj:PGDBObjPolyline;
   v1:gdbvertex;
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add 3dpolylines');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := GDBObjPolyline.CreateInstance;
    vcount:=random(8)+2;
    v1:=CreateRandomVertex(1000,500,VizualiserForm.ChkBox3D.Checked);
    for j:=1 to vcount do
    begin
         pobj^.AddVertex(v1);
         v1:=uzegeometry.VertexAdd(v1,CreateRandomVertex(100,50,VizualiserForm.ChkBox3D.Checked));
    end;
    if vcount>2 then
                    pobj^.closed:=random(10)>5;
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    SetEntityLayer(pobj,GetCurrentDrawing);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TVizualiserForm.BtnAddArcsClick(Sender: TObject);
var
   i:integer;
   pobj:PGDBObjArc;
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add arcs');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := GDBObjArc.CreateInstance;
    pobj^.Local.P_insert:=CreateRandomVertex(1000,500,VizualiserForm.ChkBox3D.Checked);
    pobj^.R:=CreateRandomDouble(10)+0.1;
    pobj^.StartAngle:=CreateRandomDouble(2*pi);
    pobj^.EndAngle:=CreateRandomDouble(2*pi);
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    SetEntityLayer(pobj,GetCurrentDrawing);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
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

procedure TVizualiserForm.BtnEraseSelClick(Sender: TObject);
var pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if (GetCurrentDrawing^.GetCurrentROOT^.ObjArray.count = 0)or(GetCurrentDrawing^.wa.param.seldesc.Selectedobjcount=0) then exit;
  _StartLongProcess(0,'Erase entitys');
  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.YouDeleted(GetCurrentDrawing^);
                             inc(count);
                        end;
  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  GetCurrentDrawing^.wa.param.seldesc.Selectedobjcount:=0;
  GetCurrentDrawing^.wa.param.seldesc.OnMouseObject:=nil;
  GetCurrentDrawing^.wa.param.seldesc.LastSelectedObject:=nil;
  GetCurrentDrawing^.wa.param.lastonmouseobject:=nil;
  GetCurrentDrawing^.OnMouseObj.Clear;
  GetCurrentDrawing^.SelObjArray.Free;
  _EndLongProcess;
  GetCurrentDrawing^.HardReDraw;
end;
procedure TVizualiserForm.BtnAddTextsClick(Sender: TObject);
var
   i:integer;
   pobj:PGDBObjText;
   v1:gdbvertex;
   tp:GDBTextStyleProp;
   angl:double;
   ts:PGDBTextStyle;
   dc:TDrawContext;
begin
  if GetCurrentDrawing^.TextStyleTable.count=0 then
  begin
       tp.size:=2.5;
       tp.oblique:=0;
       GetCurrentDrawing^.TextStyleTable.addstyle('standart','txt.shx',tp,false);
  end;
  ts:= GetCurrentDrawing^.TextStyleTable.getAddres('standart');
  _StartLongProcess(0,'Add texts');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
  for i:=1 to SpinEdit1.Value do
  begin
    pobj:=GDBObjText.CreateInstance;
    v1:=CreateRandomVertex(1000,500,VizualiserForm.ChkBox3D.Checked);
    pobj^.Local.P_insert:=v1;
    pobj^.TXTStyleIndex:=ts;
    pobj^.Template:='Hello word!';
    pobj^.textprop.size:=1+random(10);
    pobj^.textprop.justify:=b2j[1+random(11)];
    pobj^.textprop.wfactor:=0.3+random*0.7;
    pobj^.textprop.oblique:=(random(30)-15)*pi/180;
    angl:=pi*random;
    //pobj^.textprop.angle:=angl;
    pobj^.local.basis.OX:=VectorTransform3D(PGDBObjText(pobj)^.local.basis.OX,uzegeometry.CreateAffineRotationMatrix(PGDBObjText(pobj)^.Local.basis.oz,-angl));
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    SetEntityLayer(pobj,GetCurrentDrawing);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TVizualiserForm.BtnOpenDXFClick(Sender: TObject);
var
   dc:TDrawContext;
begin
     {$ifdef dxfio}
     if OpenDialog1.Execute then
     begin
          _StartLongProcess(0,'Load dxf file');
          dc:=GetCurrentDrawing^.CreateDrawingRC;
          addfromdxf(OpenDialog1.FileName,@GetCurrentDrawing^.pObjRoot^,TLOLoad,GetCurrentDrawing^);
          GetCurrentDrawing^.pObjRoot^.FormatEntity(GetCurrentDrawing^,dc);
          GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree.maketreefrom(GetCurrentDrawing^.pObjRoot^.ObjArray,GetCurrentDrawing^.pObjRoot^.vp.BoundingBox,nil);
          //GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree:=createtree(GetCurrentDrawing^.pObjRoot^.ObjArray,GetCurrentDrawing^.pObjRoot^.vp.BoundingBox,@GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
          GetCurrentDrawing^.HardReDraw;
          _EndLongProcess;
     end;
     {$endif}
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

procedure TVizualiserForm.BtnSelectAllClick(Sender: TObject);
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if GetCurrentDrawing^.GetCurrentROOT^.ObjArray.Count = 0 then exit;
  GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount:=0;

  count:=0;
  _StartLongProcess(0,'Select all');
  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    inc(count);
  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;


  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        if count>10000 then
                           pv^.SelectQuik
                       else
                           pv^.select(GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount,nil);

  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  _EndLongProcess;
  GetCurrentDrawing^.HardReDraw;
  //if assigned(updatevisibleproc) then updatevisibleproc;

end;

procedure TVizualiserForm. OffEntLayerClick(Sender: TObject);
begin
  begin
       if GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount=1 then
       begin
            if GetCurrentDrawing^.wa.param.SelDesc.LastSelectedObject<>nil then
            begin
                 pGDBObjEntity(GetCurrentDrawing^.wa.param.SelDesc.LastSelectedObject)^.vp.Layer^._on:=false;
                 pGDBObjEntity(GetCurrentDrawing^.wa.param.SelDesc.LastSelectedObject)^.DeSelect(GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount,nil);
            end;
            GetCurrentDrawing^.HardReDraw;
       end
       else
           application.MessageBox('Must be selected one entity','??',ID_OK);
  end;
end;

procedure TVizualiserForm.OnAllLayerClick(Sender: TObject);
var
   ptd:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBLayerProp;
begin
  ptd:=GetCurrentDrawing;
  if ptd<>nil then
  begin
  plp:=ptd^.LayerTable.beginiterate(ir);
  if plp<>nil then
  repeat
        plp^._on:=true;
  plp:=ptd^.LayerTable.iterate(ir);
  until plp=nil;
  GetCurrentDrawing^.HardReDraw;
  end;
end;



procedure TVizualiserForm.TreeChange(Sender: TObject);
begin
     sysvarDISPSystmGeometryDraw:=CheckBox1.Checked;
     GetCurrentDrawing^.HardReDraw;
end;

procedure TVizualiserForm._DestroyApp(Sender: TObject);
begin
 pdrawing1^.done;
 gdbfreemem(pdrawing1);
 pdrawing2^.done;
 gdbfreemem(pdrawing2);
end;


end.

