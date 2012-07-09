unit umainform;

{$mode objfpc}{$H+}

interface

uses
  LCLType, geometry, sharedgdb, GDBase, GDBasetypes, ComCtrls, UGDBDescriptor,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Spin,
  {From ZCAD}
  iodxf,varmandef, oglwindow,  UUnitManager,
  UGDBTextStyleArray,GDBCommandsDraw,UGDBEntTree,GDBText,GDBLine,GDBCircle,URegisterObjects,GDBEntity,GDBManager,gdbobjectsconstdef;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    CheckBox1: TCheckBox;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    SpinEdit1: TSpinEdit;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
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

implementation

{$R *.lfm}
procedure TForm1._KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_ESCAPE then
  begin
       gdb.GetCurrentDWG^.SelObjArray.clearallobjects;
       gdb.GetCurrentROOT^.ObjArray.DeSelect;
       sharedgdb.redrawoglwnd;
       Key:=0;
  end;
  if Key=VK_DELETE then
  begin
       Button4Click(nil);
       Key:=0;
  end;
end;

procedure TForm1._FormShow(Sender: TObject);
begin
    sharedgdb.redrawoglwnd;
end;

procedure TForm1._FormCreate(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i:integer;
   pobj:PGDBObjEntity;
   v1,v2:gdbvertex;
begin
     ugdbdescriptor.startup;

     ptd:=gdb.CreateDWG;
     gdb.AddRef(ptd^);
     gdb.SetCurrentDWG(ptd);

     oglwnd:=TOGLWnd.Create(Panel1);
     oglwnd.AuxBuffers:=0;
     oglwnd.StencilBits:=8;
     oglwnd.DepthBits:=24;



     gdb.GetCurrentDWG^.OGLwindow1:=oglwnd;
     oglwnd.PDWG:=ptd;
     oglwnd.align:=alClient;
     oglwnd.Parent:=Panel1;
     oglwnd.init;
     oglwnd.PDWG:=ptd;
     oglwnd.GDBActivate;

     gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;

     sysvar.DWG.DWG_SystmGeometryDraw^:=CheckBox1.Checked;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i:integer;
   pobj:PGDBObjEntity;
   v1,v2:gdbvertex;
begin
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := CreateInitObjFree(GDBLineID,nil);
    v1:=createvertex(random(1000)-500,random(1000)-500,{random(1000)-500}0);
    v2:=geometry.VertexAdd(v1,createvertex(random(50)-25,random(50)-25,{random(50)-25}0));
    PGDBObjLine(pobj)^.CoordInOCS.lBegin:=v1;
    PGDBObjLine(pobj)^.CoordInOCS.lEnd:=v2;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    PGDBObjEntity(pobj)^.BuildGeometry;
    PGDBObjEntity(pobj)^.format;
  end;
  gdb.GetCurrentDWG^.pObjRoot^.Format;
  gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
  sharedgdb.redrawoglwnd;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i:integer;
   pobj:PGDBObjEntity;
   v1,v2:gdbvertex;
begin
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := CreateInitObjFree(GDBCircleID,nil);
    v1:=createvertex(random(1000)-500,random(1000)-500,{random(1000)-500}0);
    PGDBObjCircle(pobj)^.Local.P_insert:=v1;
    PGDBObjCircle(pobj)^.Radius:=random(10)+1;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    PGDBObjEntity(pobj)^.BuildGeometry;
    PGDBObjEntity(pobj)^.format;
  end;
  gdb.GetCurrentDWG^.pObjRoot^.Format;
  gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
   sharedgdb.redrawoglwnd;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
     gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
     sharedgdb.redrawoglwnd;
end;

procedure TForm1.Button4Click(Sender: TObject);
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
  sharedgdb.redrawoglwnd;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
   ptd:PTDrawing;
   tn:GDBString;
   i:integer;
   pobj:PGDBObjEntity;
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
    pobj := CreateInitObjFree(GDBTextID,nil);
    v1:=createvertex(random(1000)-500,random(1000)-500,{random(1000)-500}0);
    PGDBObjText(pobj)^.Local.P_insert:=v1;
    PGDBObjText(pobj)^.TXTStyleIndex:=0;
    PGDBObjText(pobj)^.Template:='Hello word!';
    PGDBObjText(pobj)^.textprop.size:=1+random(10);
    PGDBObjText(pobj)^.textprop.oblique:=random(20);
    angl:=pi*random/2;
    PGDBObjText(pobj)^.textprop.angle:=angl*180/pi;
    PGDBObjText(pobj)^.local.basis.OX:=VectorTransform3D(PGDBObjText(pobj)^.local.basis.OX,geometry.CreateAffineRotationMatrix(PGDBObjText(pobj)^.Local.basis.oz,-angl));
    gdb.GetCurrentRoot^.AddMi(@pobj);
    PGDBObjText(pobj)^.BuildGeometry;
    PGDBObjText(pobj)^.format;
  end;
  gdb.GetCurrentDWG^.pObjRoot^.Format;
  gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
   sharedgdb.redrawoglwnd;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
          addfromdxf(OpenDialog1.FileName,@gdb.GetCurrentDWG^.pObjRoot^,TLOLoad);
          gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;
          sharedgdb.redrawoglwnd;
     end;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
     if SaveDialog1.Execute then
     begin
          savedxf2000(SaveDialog1.FileName, GDB.GetCurrentDWG);
     end;
end;

procedure TForm1.TreeChange(Sender: TObject);
begin
     sysvar.DWG.DWG_SystmGeometryDraw^:=CheckBox1.Checked;
     sharedgdb.redrawoglwnd;
end;


end.

