unit umainform;

{$mode objfpc}{$H+}
{.$define dxfio}
interface

uses
  LCLType,Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Spin,
  {From ZCAD}
  openglviewarea,abstractviewarea,zcadsysvars, {$ifdef dxfio}iodxf,{$endif}varmandef, UUnitManager,
  zcadinterface,gdbentityfactory,UGDBLayerArray,geometry, GDBase, GDBasetypes,
  UGDBDescriptor,UGDBTextStyleArray,UGDBEntTree,GDB3DFace,
  GDBLWPolyLine,GDBPolyLine,GDBText,GDBLine,GDBCircle,GDBArc,ugdbsimpledrawing,
  GDBEntity,GDBManager,gdbobjectsconstdef,ioshx,gdbpalette;

type

  { TForm1 }

  TForm1 = class(TForm)
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
    procedure BtnAdd3DFaces1Click(Sender: TObject);
    //procedure FormatEntitysAndRebuildTreeAndRedraw;
    procedure BtnAdd3DpolyLinesClick(Sender: TObject);
    procedure BtnAddArcsClick(Sender: TObject);
    procedure BtnAddLinesClick(Sender: TObject);
    procedure BtnAddCirclesClick(Sender: TObject);
    procedure BtnAddLWPolylines1Click(Sender: TObject);
    procedure BtnProcessObjectsClick(Sender: TObject);
    procedure BtnRebuildClick(Sender: TObject);
    procedure BtnEraseSelClick(Sender: TObject);
    procedure BtnAddTextsClick(Sender: TObject);
    procedure BtnOpenDXFClick(Sender: TObject);
    procedure BtnSaveDXFClick(Sender: TObject);
    procedure BtnSelectAllClick(Sender: TObject);
    procedure OffEntLayerClick(Sender: TObject);
    procedure OnAllLayerClick(Sender: TObject);
    procedure TreeChange(Sender: TObject);
    procedure _DestroyApp(Sender: TObject);
    procedure _FormCreate(Sender: TObject);
    procedure _KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure _FormShow(Sender: TObject);

    procedure _StartLongProcess(a:integer;n:string);
    procedure _EndLongProcess;
  private
    oglwnd:TCADControl;
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1;
  snap:GDBSnap2D;
  grid:GDBvertex2D;
  LPTime:Tdatetime;
  pname:string;
  sgdraw:boolean;
  spath,altfont,temppath:gdbstring;
  bccolor:trgb;
  maxrendertime,cursorsize:GDBInteger;
  OSSize,CrosshairSize:GDBDouble;
  OSMode:TGDBOSMode;
  ZoomFactor:GDBDouble;
  //rm:trestoremode;

implementation

{$R *.lfm}
procedure TForm1._StartLongProcess(a:integer;n:string);
begin
     LPTime:=now;
     pname:=n;
end;
procedure TForm1._EndLongProcess;
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

procedure TForm1._KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_ESCAPE then
  begin
       gdb.GetCurrentDWG^.SelObjArray.clearallobjects;
       gdb.GetCurrentROOT^.ObjArray.DeSelect(gdb.GetCurrentDWG^.GetSelObjArray,gdb.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);
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
    _FormCreate(nil);
    UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1._FormCreate(Sender: TObject);
var
   ptd:PTSimpleDrawing;
   i:integer;
   wpowner:TAbstractViewArea;
begin
     {Настройка глобальных переменных необходимых для работы}
     {переменные не все, только минимально необходимые для работы}
     Snap.Base.x:=0;//смещение начала координат сетки\привязки к сетке
     Snap.Base.y:=0;
     Snap.Spacing.x:=1;//шаг привязки к сетке
     Snap.Spacing.y:=1;
     grid.x:=2;//шаг сетки
     grid.y:=2;

     sysvar.DWG.DWG_Snap:=@Snap;//привязка настроек сетки/привязки к потрохам зкада через соответствующий указатель
     sysvar.DWG.DWG_GridSpacing:=@grid;//привязка настроек сетки/привязки к потрохам зкада через соответствующий указатель
     sysvar.DWG.DWG_SystmGeometryDraw:=@sgdraw;//привязка настроек сетки/привязки к потрохам зкада через соответствующий указатель
     sysvar.DWG.DWG_SystmGeometryDraw^:=CheckBox1.Checked;

     sysvar.RD.RD_BackGroundColor:=@bccolor;
     sysvar.SYS.SYS_SystmGeometryColor:=@bccolor;
     maxrendertime:=0;
     sysvar.RD.RD_MaxRenderTime:=@maxrendertime;
     OSSize:=10;
     sysvar.DISP.DISP_OSSize:=@OSSize;
     cursorsize:=10;
     sysvar.DISP.DISP_CursorSize:=@cursorsize;
     CrosshairSize:=0.05;
     SysVar.DISP.DISP_CrosshairSize:=@CrosshairSize;
     ZoomFactor:=1.624;
     sysvar.DISP.DISP_ZoomFactor:=@ZoomFactor;

     spath:='';
     sysvar.PATH.Fonts_Path:=@spath;
     sysvar.PATH.Support_Path:=@spath;
     altfont:='blablabla';
     sysvar.SYS.SYS_AlternateFont:=@altfont;
     temppath:=GetTempDir;
     sysvar.PATH.Temp_files:=@temppath;

     sysvar.dwg.DWG_OSMode:=@OSMode;


     ugdbdescriptor.startup('','');

     ptd:={gdb.}CreateSimpleDWG;
     //ptd:=gdb.CreateDWG;
     gdb.AddRef(ptd^);
     gdb.SetCurrentDWG(pointer(ptd));
     for i:=1 to 10 do
     begin
          ptd^.LayerTable.addlayer(inttostr(i),random(255),0,true,false,true,'',TLOMerge);
     end;


     wpowner:=TOpenGLViewArea.Create(PanelUp);
     oglwnd:=wpowner.getviewcontrol;
     gdb.GetCurrentDWG^.wa:=wpowner;
     wpowner.PDWG:=ptd;
     wpowner.getviewcontrol.align:=alClient;
     wpowner.getviewcontrol.Parent:=PanelUp;
     wpowner.getviewcontrol.Visible:=true;
     wpowner.PDWG:=ptd;
     wpowner.getareacaps;
     //wpowner.WaResize(nil);
     oglwnd.show;
     wpowner.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                //создания или загрузки
     wpowner.param.firstdraw:=true;

     gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;



     ptd:={gdb.}CreateSimpleDWG;
     //ptd:=gdb.CreateDWG;
     gdb.AddRef(ptd^);
     gdb.SetCurrentDWG(pointer(ptd));
     for i:=1 to 10 do
     begin
          ptd^.LayerTable.addlayer(inttostr(i),random(255),0,true,false,true,'',TLOMerge);
     end;


     wpowner:=TCanvasViewArea.Create(Panel2);
     oglwnd:=wpowner.getviewcontrol;
     gdb.GetCurrentDWG^.wa:=wpowner;
     wpowner.PDWG:=ptd;
     wpowner.getviewcontrol.align:=alClient;
     wpowner.getviewcontrol.Parent:=Panel2;
     wpowner.getviewcontrol.Visible:=true;
     wpowner.PDWG:=ptd;
     wpowner.getareacaps;
     //oglwnd.show;
     wpowner.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                //создания или загрузки
     UGDBDescriptor.redrawoglwnd;
     gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;


     zcadinterface.StartLongProcessProc:=@_StartLongProcess;
     zcadinterface.EndLongProcessProc:=@_EndLongProcess;
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
procedure processobj(pobj:PGDBObjEntity);
begin
     pobj^.vp.Layer:=gdb.GetCurrentDWG^.LayerTable.getelement(random(gdb.GetCurrentDWG^.LayerTable.Count));
end;

function CreateRandomVertex2D(len,hanflen:GDBDouble):GDBVertex2D;
begin
     result.x:=CreateRandomDouble(len)-hanflen;
     result.y:=CreateRandomDouble(len)-hanflen;
end;
{procedure TForm1.FormatEntitysAndRebuildTreeAndRedraw;
begin
  _StartLongProcess(0,'Format entitys');
  gdb.GetCurrentDWG^.pObjRoot^.FormatEntity(gdb.GetCurrentDWG^);
  _EndLongProcess;
  BtnRebuildClick(self);
  //gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
  UGDBDescriptor.redrawoglwnd;
end;}

procedure TForm1.BtnAddLinesClick(Sender: TObject);
var
   i:integer;
   pobj:PGDBObjLine;
   v1,v2:gdbvertex;
begin
  _StartLongProcess(0,'Add lines');
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObjLine(CreateInitObjFree(GDBLineID,nil));
    v1:=CreateRandomVertex(1000,500);
    v2:=geometry.VertexAdd(v1,CreateRandomVertex(1000,500));
    pobj^.CoordInOCS.lBegin:=v1;
    pobj^.CoordInOCS.lEnd:=v2;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(gdb.GetCurrentDWG^);
    pobj^.formatEntity(gdb.GetCurrentDWG^);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TForm1.BtnAddLWPolylines1Click(Sender: TObject);
var
   i,j,vcount:integer;
   pobj:PGDBObjLWPolyline;
   v1:gdbvertex2d;
   lw:GLLWWidth;
begin
  _StartLongProcess(0,'Add lwpolylines');
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
    processobj(pobj);
    pobj^.BuildGeometry(gdb.GetCurrentDWG^);
    pobj^.formatEntity(gdb.GetCurrentDWG^);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;
procedure TForm1.BtnAdd3DFaces1Click(Sender: TObject);
var
   i,j:integer;
   istriangle:boolean;
   pobj:PGDBObj3DFace;
   v1:gdbvertex;
begin
  _StartLongProcess(0,'Add 3dfaces');
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObj3DFace(CreateInitObjFree(GDB3DFaceID,nil));
    istriangle:=random(10)>5;
    v1:=CreateRandomVertex(1000,500);
    for j:=0 to 2 do
    begin
         pobj^.PInOCS[j]:=v1;
         v1:=geometry.VertexAdd(v1,CreateRandomVertex(100,50));
    end;
    if istriangle then
                      pobj^.PInOCS[3]:=pobj^.PInOCS[2]
                  else
                      pobj^.PInOCS[3]:=v1;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(gdb.GetCurrentDWG^);
    pobj^.formatEntity(gdb.GetCurrentDWG^);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;
procedure TForm1.BtnProcessObjectsClick(Sender: TObject);
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    l,hl:double;
begin
  _StartLongProcess(0,'Move objects');
  pv:=gdb.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        case pv^.vp.ID of
        GDBLineID:begin
                       l:=PGDBObjLine(pv)^.Length/10;
                       hl:=l/2;
                       PGDBObjLine(pv)^.CoordInOCS.lBegin:=geometry.VertexAdd(PGDBObjLine(pv)^.CoordInOCS.lBegin,CreateRandomVertex(l,hl));
                       PGDBObjLine(pv)^.CoordInOCS.lEnd:=geometry.VertexAdd(PGDBObjLine(pv)^.CoordInOCS.lEnd,CreateRandomVertex(l,hl));
                       pv^.YouChanged(gdb.GetCurrentDWG^);
                  end;
        GDBCircleID:begin
                       l:=PGDBObjCircle(pv)^.Radius;
                       hl:=l/2;
                       PGDBObjCircle(pv)^.Local.P_insert:=geometry.VertexAdd(PGDBObjCircle(pv)^.Local.P_insert,CreateRandomVertex(l,hl));
                       PGDBObjCircle(pv)^.Radius:=PGDBObjCircle(pv)^.Radius+CreateRandomDouble(l)-hl;
                       if PGDBObjCircle(pv)^.Radius<=0 then PGDBObjCircle(pv)^.Radius:=CreateRandomDouble(9)+1;
                       pv^.YouChanged(gdb.GetCurrentDWG^);
                  end;
        end;
  pv:=gdb.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  _EndLongProcess;

  UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnAddCirclesClick(Sender: TObject);
var
   i:integer;
   pobj:PGDBObjCircle;
   v1:gdbvertex;
begin
  _StartLongProcess(0,'Add circles');
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObjCircle(CreateInitObjFree(GDBCircleID,nil));
    v1:=CreateRandomVertex(1000,500);
    pobj^.Local.P_insert:=v1;
    pobj^.Radius:=CreateRandomDouble(9.9)+0.1;
    gdb.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(gdb.GetCurrentDWG^);
    pobj^.formatEntity(gdb.GetCurrentDWG^);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TForm1.BtnAdd3DpolyLinesClick(Sender: TObject);
var
   i,j,vcount:integer;
   pobj:PGDBObjPolyline;
   v1:gdbvertex;
begin
  _StartLongProcess(0,'Add 3dpolylines');
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
    processobj(pobj);
    pobj^.BuildGeometry(gdb.GetCurrentDWG^);
    pobj^.formatEntity(gdb.GetCurrentDWG^);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TForm1.BtnAddArcsClick(Sender: TObject);
var
   i:integer;
   pobj:PGDBObjArc;
begin
  _StartLongProcess(0,'Add arcs');
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObjArc(CreateInitObjFree(GDBArcID,nil));
    pobj^.Local.P_insert:=CreateRandomVertex(1000,500);
    pobj^.R:=CreateRandomDouble(10)+0.1;
    pobj^.StartAngle:=CreateRandomDouble(2*pi);
    pobj^.EndAngle:=CreateRandomDouble(2*pi);
    gdb.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(gdb.GetCurrentDWG^);
    pobj^.formatEntity(gdb.GetCurrentDWG^);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;


procedure TForm1.BtnRebuildClick(Sender: TObject);
begin
     _StartLongProcess(0,'Rebuild spatial tree');
     gdb.GetCurrentDWG^.pObjRoot^.calcbb;
     gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
     _EndLongProcess;
     UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1.BtnEraseSelClick(Sender: TObject);
var pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if (gdb.GetCurrentROOT^.ObjArray.count = 0)or(GDB.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0) then exit;
  _StartLongProcess(0,'Erase entitys');
  pv:=gdb.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.YouDeleted(gdb.GetCurrentDWG^);
                             inc(count);
                        end;
  pv:=gdb.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  GDB.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount:=0;
  GDB.GetCurrentDWG^.wa.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject:=nil;
  GDB.GetCurrentDWG^.wa.param.lastonmouseobject:=nil;
  gdb.GetCurrentDWG^.OnMouseObj.Clear;
  gdb.GetCurrentDWG^.SelObjArray.clearallobjects;
  _EndLongProcess;
  UGDBDescriptor.redrawoglwnd;
end;
procedure TForm1.BtnAddTextsClick(Sender: TObject);
var
   i:integer;
   pobj:PGDBObjText;
   v1:gdbvertex;
   tp:GDBTextStyleProp;
   angl:double;
   ts:PGDBTextStyle;
begin
  if gdb.GetCurrentDWG^.TextStyleTable.count=0 then
  begin
       tp.size:=2.5;
       tp.oblique:=0;
       gdb.GetCurrentDWG^.TextStyleTable.addstyle('standart','txt.shx',tp,false);
  end;
  ts:= gdb.GetCurrentDWG^.TextStyleTable.getAddres('standart');
  _StartLongProcess(0,'Add texts');
  for i:=1 to SpinEdit1.Value do
  begin
    pGDBObjEntity(pobj):=CreateInitObjFree(GDBTextID,nil);
    v1:=CreateRandomVertex(1000,500);
    pobj^.Local.P_insert:=v1;
    pobj^.TXTStyleIndex:=ts;
    pobj^.Template:='Hello word!';
    pobj^.textprop.size:=1+random(10);
    pobj^.textprop.justify:=b2j[1+random(11)];
    pobj^.textprop.wfactor:=0.3+random*0.7;
    pobj^.textprop.oblique:=random(20);
    angl:=pi*random{*0.5};
    pobj^.textprop.angle:=angl*180/pi;
    pobj^.local.basis.OX:=VectorTransform3D(PGDBObjText(pobj)^.local.basis.OX,geometry.CreateAffineRotationMatrix(PGDBObjText(pobj)^.Local.basis.oz,-angl));
    gdb.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(gdb.GetCurrentDWG^);
    pobj^.formatEntity(gdb.GetCurrentDWG^);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TForm1.BtnOpenDXFClick(Sender: TObject);
begin
     {$ifdef dxfio}
     if OpenDialog1.Execute then
     begin
          addfromdxf(OpenDialog1.FileName,@gdb.GetCurrentDWG^.pObjRoot^,TLOLoad,gdb.GetCurrentDWG^);
          gdb.GetCurrentDWG^.pObjRoot^.FormatEntity(gdb.GetCurrentDWG^);
          gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot^.ObjArray,gdb.GetCurrentDWG^.pObjRoot^.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
          UGDBDescriptor.redrawoglwnd;
     end;
     {$endif}
end;

procedure TForm1.BtnSaveDXFClick(Sender: TObject);
begin
     {$ifdef dxfio}
     if SaveDialog1.Execute then
     begin
          savedxf2000(SaveDialog1.FileName, GDB.GetCurrentDWG^);
     end;
     {$endif}
end;

procedure TForm1.BtnSelectAllClick(Sender: TObject);
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if gdb.GetCurrentROOT^.ObjArray.Count = 0 then exit;
  GDB.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount:=0;

  count:=0;
  _StartLongProcess(0,'Select all');
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
                           pv^.select(gdb.GetCurrentDWG^.GetSelObjArray,gdb.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);

  pv:=gdb.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  _EndLongProcess;
  UGDBDescriptor.redrawoglwnd;
  //if assigned(updatevisibleproc) then updatevisibleproc;

end;

procedure TForm1. OffEntLayerClick(Sender: TObject);
begin
  begin
       if GDB.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount=1 then
       begin
            if GDB.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject<>nil then
            begin
                 pGDBObjEntity(GDB.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject)^.vp.Layer^._on:=false;
                 pGDBObjEntity(GDB.GetCurrentDWG^.wa.param.SelDesc.LastSelectedObject)^.DeSelect(gdb.GetCurrentDWG^.GetSelObjArray,gdb.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount);
            end;
            UGDBDescriptor.redrawoglwnd;
       end
       else
           application.MessageBox('Must be selected one entity','??',ID_OK);
  end;
end;

procedure TForm1.OnAllLayerClick(Sender: TObject);
var
   ptd:PTSimpleDrawing;
   ir:itrec;
   plp:PGDBLayerProp;
begin
  ptd:=gdb.GetCurrentDWG;
  if ptd<>nil then
  begin
  plp:=ptd^.LayerTable.beginiterate(ir);
  if plp<>nil then
  repeat
        plp^._on:=true;
  plp:=ptd^.LayerTable.iterate(ir);
  until plp=nil;
  UGDBDescriptor.redrawoglwnd;
  end;
end;



procedure TForm1.TreeChange(Sender: TObject);
begin
     sysvar.DWG.DWG_SystmGeometryDraw^:=CheckBox1.Checked;
     UGDBDescriptor.redrawoglwnd;
end;

procedure TForm1._DestroyApp(Sender: TObject);
begin
     ugdbdescriptor.finalize;
end;


end.

