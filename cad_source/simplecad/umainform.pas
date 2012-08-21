unit umainform;

{$mode objfpc}{$H+}

interface

uses
  UGDBDrawingdef,LCLType, geometry, GDBase, GDBasetypes, ComCtrls, UGDBDescriptor,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Spin,
  {From ZCAD}
  zcadsysvars,{zcadinterface,} iodxf,varmandef, oglwindow,  UUnitManager,
  UGDBTextStyleArray,GDBCommandsDraw,UGDBEntTree,GDBLWPolyLine,GDBPolyLine,GDBText,GDBLine,GDBCircle,URegisterObjects,GDBEntity,GDBManager,gdbobjectsconstdef;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnAddLWPolyLines1: TButton;
    BtnAddLines: TButton;
    BtnAddCircles: TButton;
    BtnAdd3DpolyLines: TButton;
    BtnSelectAll: TButton;
    BtnRebuild: TButton;
    BtnEraseSel: TButton;
    BtnAddTexts: TButton;
    BtnOpenDXF: TButton;
    BtnSaveDXF: TButton;
    BtnProcessObjects: TButton;
    CheckBox1: TCheckBox;
    ChkBox3D: TCheckBox;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    PanelUp: TPanel;
    SaveDialog1: TSaveDialog;
    SpinEdit1: TSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure BtnAdd3DpolyLinesClick(Sender: TObject);
    procedure BtnAddLinesClick(Sender: TObject);
    procedure BtnAddCirclesClick(Sender: TObject);
    procedure BtnAddLWPolyLines1Click(Sender: TObject);
    procedure BtnProcessObjectsClick(Sender: TObject);
    procedure BtnRebuildClick(Sender: TObject);
    procedure BtnEraseSelClick(Sender: TObject);
    procedure BtnAddTextsClick(Sender: TObject);
    procedure BtnOpenDXFClick(Sender: TObject);
    procedure BtnSaveDXFClick(Sender: TObject);
    procedure BtnSelectAllClick(Sender: TObject);
    procedure TreeChange(Sender: TObject);
    procedure _FormCreate(Sender: TObject);
    procedure _KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure _FormShow(Sender: TObject);
  private
    oglwnd:TOGLWND;
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1;
  stepgrid,origingrid:GDBvertex2D;
  //rm:trestoremode;

implementation

{$R *.lfm}
procedure TForm1._KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_ESCAPE then
  begin
       gdb.GetCurrentDWG^.SelObjArray.clearallobjects;
       gdb.GetCurrentROOT^.ObjArray.DeSelect;
       UGDBDescriptor.redrawoglwnd;
       Key:=0;
  end;
  if Key=VK_DELETE then
  begin
       BtnEraseSelClick(nil);
       Key:=0;
  end;
end;

procedure TForm1._FormShow(Sender: TObject);
begin
    //_FormCreate(nil);
    UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1._FormCreate(Sender: TObject);
var
   ptd:PTAbstractDrawing;
   tn:GDBString;
   i:integer;
   pobj:PGDBObjEntity;
   v1,v2:gdbvertex;
begin
     stepgrid.x:=1;
     stepgrid.y:=1;
     origingrid.x:=0;
     origingrid.y:=0;

     sysvar.DWG.DWG_StepGrid:=@stepgrid;
     sysvar.DWG.DWG_OriginGrid:=@origingrid;
     ugdbdescriptor.startup;

     ptd:=gdb.CreateSimpleDWG;
     //ptd:=gdb.CreateDWG;
     gdb.AddRef(ptd^);
     gdb.SetCurrentDWG(pointer(ptd));

     oglwnd:=TOGLWnd.Create(PanelUp);
     oglwnd.AuxBuffers:=0;
     oglwnd.StencilBits:=8;
     oglwnd.DepthBits:=24;

     //rm:=WND_Texture;
     //sysvar.RD.RD_Restore_Mode:=@rm;



     gdb.GetCurrentDWG^.OGLwindow1:=oglwnd;
     oglwnd.PDWG:=ptd;
     oglwnd.align:=alClient;
     oglwnd.Parent:=PanelUp;
     oglwnd.init;
     oglwnd.PDWG:=ptd;
     oglwnd.GDBActivate;
     oglwnd._onresize(nil);

     gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;

     sysvar.DWG.DWG_SystmGeometryDraw^:=CheckBox1.Checked;

end;
function CreateRandomDouble(len:GDBDouble):GDBDouble;inline;
begin
     result:=random*len;
end;
function CreateRandomVertex(len,hanflen:GDBDouble):GDBVertex;
begin
     result.x:=CreateRandomDouble(len)-hanflen;
     result.y:=CreateRandomDouble(len)-hanflen;
     if Form1.ChkBox3D.Checked then
                                   result.z:=CreateRandomDouble(len)-hanflen
                               else
                                   result.z:=0;
end;
function CreateRandomVertex2D(len,hanflen:GDBDouble):GDBVertex2D;
begin
     result.x:=CreateRandomDouble(len)-hanflen;
     result.y:=CreateRandomDouble(len)-hanflen;
end;
procedure TForm1.BtnAddLinesClick(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i:integer;
   pobj:PGDBObjLine;
   v1,v2:gdbvertex;
begin
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObjLine(CreateInitObjFree(GDBLineID,nil));
    v1:=CreateRandomVertex(1000,500);
    v2:=geometry.VertexAdd(v1,CreateRandomVertex(100,50));
    pobj^.CoordInOCS.lBegin:=v1;
    pobj^.CoordInOCS.lEnd:=v2;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    pobj^.BuildGeometry;
    pobj^.format;
  end;
  gdb.GetCurrentDWG^.pObjRoot^.Format;
  gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
  UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnAddLWPolyLines1Click(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i,j,vcount:integer;
   pobj:PGDBObjLWPolyline;
   v1,v2:gdbvertex2d;
   lw:GLLWWidth;
begin
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObjLWPolyline(CreateInitObjFree(GDBLWPolyLineID,nil));
    vcount:=random(8)+2;
    v1:=CreateRandomVertex2D(1000,500);
    for j:=1 to vcount do
    begin
         pobj^.Vertex2D_in_OCS_Array.Add(@v1);
         lw.endw:=CreateRandomDouble(10);
         lw.startw:=CreateRandomDouble(10);
         pobj^.Width2D_in_OCS_Array.Add(@lw);
         v1:=geometry.Vertex2DAdd(v1,CreateRandomVertex2D(100,50));
    end;
    if vcount>2 then
                    pobj^.closed:=random(10)>5;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    pobj^.BuildGeometry;
    pobj^.format;
  end;
  gdb.GetCurrentDWG^.pObjRoot^.Format;
  gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
  UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnProcessObjectsClick(Sender: TObject);
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    l,hl:double;
begin
  pv:=gdb.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        case pv^.vp.ID of
        GDBLineID:begin
                       l:=PGDBObjLine(pv)^.Length/10;
                       hl:=l/2;
                       PGDBObjLine(pv)^.CoordInOCS.lBegin:=geometry.VertexAdd(PGDBObjLine(pv)^.CoordInOCS.lBegin,CreateRandomVertex(l,hl));
                       PGDBObjLine(pv)^.CoordInOCS.lEnd:=geometry.VertexAdd(PGDBObjLine(pv)^.CoordInOCS.lEnd,CreateRandomVertex(l,hl));
                       pv^.YouChanged;
                  end;
        GDBCircleID:begin
                       l:=PGDBObjCircle(pv)^.Radius;
                       hl:=l/2;
                       PGDBObjCircle(pv)^.Local.P_insert:=geometry.VertexAdd(PGDBObjCircle(pv)^.Local.P_insert,CreateRandomVertex(l,hl));
                       PGDBObjCircle(pv)^.Radius:=PGDBObjCircle(pv)^.Radius+CreateRandomDouble(l)-hl;
                       if PGDBObjCircle(pv)^.Radius<=0 then PGDBObjCircle(pv)^.Radius:=CreateRandomDouble(9)+1;
                       pv^.YouChanged;
                  end;
        end;
  pv:=gdb.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;


  UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnAddCirclesClick(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i:integer;
   pobj:PGDBObjCircle;
   v1,v2:gdbvertex;
begin
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObjCircle(CreateInitObjFree(GDBCircleID,nil));
    v1:=CreateRandomVertex(1000,500);
    pobj^.Local.P_insert:=v1;
    pobj^.Radius:=CreateRandomDouble(9.9)+0.1;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    pobj^.BuildGeometry;
    pobj^.format;
  end;
  gdb.GetCurrentDWG^.pObjRoot^.Format;
  gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
  UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnAdd3DpolyLinesClick(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i,j,vcount:integer;
   pobj:PGDBObjPolyline;
   v1,v2:gdbvertex;
begin
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObjPolyline(CreateInitObjFree(GDBPolyLineID,nil));
    vcount:=random(8)+2;
    v1:=CreateRandomVertex(1000,500);
    for j:=1 to vcount do
    begin
         pobj^.AddVertex(v1);
         v1:=geometry.VertexAdd(v1,CreateRandomVertex(100,50));
    end;
    if vcount>2 then
                    pobj^.closed:=random(10)>5;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    pobj^.BuildGeometry;
    pobj^.format;
  end;
  gdb.GetCurrentDWG^.pObjRoot^.Format;
  gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
  UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnRebuildClick(Sender: TObject);
begin
     gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
     UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnEraseSelClick(Sender: TObject);
var pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
    domethod,undomethod:tmethod;
begin
  if (gdb.GetCurrentROOT^.ObjArray.count = 0)or(GDB.GetCurrentDWG^.OGLwindow1.param.seldesc.Selectedobjcount=0) then exit;
  pv:=gdb.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.YouDeleted;
                             inc(count);
                        end;
  pv:=gdb.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  GDB.GetCurrentDWG^.OGLwindow1.param.seldesc.Selectedobjcount:=0;
  GDB.GetCurrentDWG^.OGLwindow1.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG^.OGLwindow1.param.seldesc.LastSelectedObject:=nil;
  GDB.GetCurrentDWG^.OGLwindow1.param.lastonmouseobject:=nil;
  gdb.GetCurrentDWG^.OnMouseObj.Clear;
  gdb.GetCurrentDWG^.SelObjArray.clearallobjects;
  UGDBDescriptor.redrawoglwnd;
end;
procedure TForm1.BtnAddTextsClick(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i:integer;
   pobj:PGDBObjText;
   v1,v2:gdbvertex;
   tp:GDBTextStyleProp;
   angl:double;
begin
  if gdb.GetCurrentDWG^.TextStyleTable.count=0 then
  begin
       tp.size:=2.5;
       tp.oblique:=0;
       gdb.GetCurrentDWG^.TextStyleTable.addstyle('standart','txt.shx',tp);
  end;
  for i:=1 to SpinEdit1.Value do
  begin
    pGDBObjEntity(pobj):=CreateInitObjFree(GDBTextID,nil);
    v1:=CreateRandomVertex(1000,500);
    pobj^.Local.P_insert:=v1;
    pobj^.TXTStyleIndex:=0;
    pobj^.Template:='Hello word!';
    pobj^.textprop.size:=1+random(10);
    pobj^.textprop.justify:=1+random(20);
    pobj^.textprop.wfactor:=0.3+random*0.7;
    pobj^.textprop.oblique:=random(20);
    angl:=pi*random{*0.5};
    pobj^.textprop.angle:=angl*180/pi;
    pobj^.local.basis.OX:=VectorTransform3D(PGDBObjText(pobj)^.local.basis.OX,geometry.CreateAffineRotationMatrix(PGDBObjText(pobj)^.Local.basis.oz,-angl));
    gdb.GetCurrentRoot^.AddMi(@pobj);
    pobj^.BuildGeometry;
    pobj^.format;
  end;
  gdb.GetCurrentDWG^.pObjRoot^.Format;
  gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
  UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnOpenDXFClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
          addfromdxf(OpenDialog1.FileName,@gdb.GetCurrentDWG^.pObjRoot^,TLOLoad);
          gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
          UGDBDescriptor.redrawoglwnd;
     end;
end;

procedure TForm1.BtnSaveDXFClick(Sender: TObject);
begin
     if SaveDialog1.Execute then
     begin
          savedxf2000(SaveDialog1.FileName, GDB.GetCurrentDWG);
     end;
end;

procedure TForm1.BtnSelectAllClick(Sender: TObject);
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if gdb.GetCurrentROOT^.ObjArray.Count = 0 then exit;
  GDB.GetCurrentDWG^.OGLwindow1.param.SelDesc.Selectedobjcount:=0;

  count:=0;

  pv:=gdb.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    inc(count);
  pv:=gdb.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;


  pv:=gdb.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        if count>10000 then
                           pv^.SelectQuik
                       else
                           pv^.select;

  pv:=gdb.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;

  UGDBDescriptor.redrawoglwnd;
  //if assigned(updatevisibleproc) then updatevisibleproc;

end;

procedure TForm1.TreeChange(Sender: TObject);
begin
     sysvar.DWG.DWG_SystmGeometryDraw^:=CheckBox1.Checked;
     UGDBDescriptor.redrawoglwnd;
end;


end.

