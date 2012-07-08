unit umainform;

{$mode objfpc}{$H+}

interface

uses
  LCLType,geometry,sharedgdb,GDBase,GDBasetypes,ComCtrls,UGDBDescriptor, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  {From ZCAD}
  oglwindow,  UUnitManager,
  GDBCommandsDraw,UGDBEntTree,GDBLine,GDBCircle,URegisterObjects,GDBEntity,GDBManager,gdbobjectsconstdef;

type

  { TForm1 }

  TForm1 = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
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
  end
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

     for i:=0 to 1000 do
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
     for i:=0 to 500 do
     begin
       pobj := CreateInitObjFree(GDBCircleID,nil);
       v1:=createvertex(random(1000)-500,random(1000)-500,{random(1000)-500}0);
       PGDBObjCircle(pobj)^.Local.P_insert:=v1;
       PGDBObjCircle(pobj)^.Radius:=random(10)+1;
       gdb.GetCurrentRoot^.AddMi(@pobj);
       PGDBObjEntity(pobj)^.BuildGeometry;
       PGDBObjEntity(pobj)^.format;
     end;
     gdb.GetCurrentRoot^.Format;
     gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,0,nil,TND_Root)^;

     oglwnd._onresize(nil);
     oglwnd.MakeCurrent(false);
     oglwnd.show;
     sharedgdb.redrawoglwnd;
end;


end.
