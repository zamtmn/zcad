unit umainform;

{$mode objfpc}{$H+}
{define dxfio}
interface

uses
  LCLType,Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Spin,
  {From ZCAD}
  generalviewarea,zeentitiesmanager,gdbdrawcontext,uzglopenglviewarea,
  uzglabstractviewarea,zcadsysvars, {$ifdef dxfio}iodxf,{$endif}
  zcadinterface,zeentityfactory,UGDBLayerArray,geometry,
  GDBase, GDBasetypes,{UGDBDescriptor,}UGDBTextStyleArray,UGDBEntTree,GDB3DFace,
  GDBLWPolyLine,GDBPolyLine,GDBText,GDBLine,GDBCircle,GDBArc,ugdbsimpledrawing,
  {$ifdef dxfio}GDBMText,gdbgenericdimension,gdbaligneddimension,gdbrotateddimension,gdbsolid,{$endif}
  GDBEntity,{GDBManager,}gdbobjectsconstdef,ioshx,{gdbpalette,}uzglgdiviewarea;

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
    pdrawing1,pdrawing2:PTSimpleDrawing;
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

implementation

{$R *.lfm}
function GetCurrentDrawing:PTSimpleDrawing;
begin
     if Form1.ComboBox1.ItemIndex=0 then
                                        result:=Form1.pdrawing1
                                    else
                                        result:=Form1.pdrawing2;
end;
procedure redrawoglwnd;
var
   pdwg:PTSimpleDrawing;
   DC:TDrawContext;
begin
  //isOpenGLError;
  pdwg:=GetCurrentDrawing;
  if pdwg<>nil then
  begin
       DC:=pdwg^.CreateDrawingRC;
       pdwg^.GetCurrentRoot^.FormatAfterEdit(pdwg^,dc);
  pdwg^.wa.param.firstdraw := TRUE;
  pdwg^.wa.CalcOptimalMatrix;
  pdwg^.pcamera^.totalobj:=0;
  pdwg^.pcamera^.infrustum:=0;
  pdwg^.GetCurrentRoot^.CalcVisibleByTree(pdwg^.pcamera^.frustum,pdwg^.pcamera^.POSCOUNT,pdwg^.pcamera^.VISCOUNT,pdwg^.GetCurrentROOT^.ObjArray.ObjTree,pdwg^.pcamera^.totalobj,pdwg^.pcamera^.infrustum,@pdwg^.myGluProject2,pdwg^.pcamera^.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  pdwg^.ConstructObjRoot.calcvisible(GetCurrentDrawing^.pcamera^.frustum,GetCurrentDrawing^.pcamera^.POSCOUNT,GetCurrentDrawing^.pcamera^.VISCOUNT,pdwg^.pcamera^.totalobj,pdwg^.pcamera^.infrustum,@pdwg^.myGluProject2,pdwg^.getpcamera^.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
  pdwg^.wa.calcgrid;
  pdwg^.wa.draworinvalidate;
  end;
  //gdb.GetCurrentDWG.OGLwindow1.repaint;
end;
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
       GetCurrentDrawing^.SelObjArray.clearallobjects;
       GetCurrentDrawing^.GetCurrentROOT^.ObjArray.DeSelect(GetCurrentDrawing^.GetSelObjArray,GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount);
       redrawoglwnd;
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
    redrawoglwnd;
end;

procedure TForm1._FormCreate(Sender: TObject);
var
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
     sysvarDISPSystmGeometryDraw:=CheckBox1.Checked;

     //ugdbdescriptor.startup('','');

     pdrawing1:={gdb.}CreateSimpleDWG;
     //gdb.AddRef(pdrawing1^);
     //gdb.SetCurrentDWG(pointer(pdrawing1));
     for i:=1 to 10 do
     begin
          pdrawing1^.LayerTable.addlayer(inttostr(i),random(255),0,true,false,true,'',TLOMerge);
     end;


     wpowner:=TOpenGLViewArea.Create(PanelUp);
     oglwnd:=wpowner.getviewcontrol;
     pdrawing1^.wa:=wpowner;
     wpowner.PDWG:=pdrawing1;
     wpowner.getviewcontrol.align:=alClient;
     wpowner.getviewcontrol.Parent:=PanelUp;
     wpowner.getviewcontrol.Visible:=true;
     wpowner.PDWG:=pdrawing1;
     wpowner.getareacaps;
     //wpowner.WaResize(nil);
     oglwnd.show;
     wpowner.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                //создания или загрузки
     wpowner.param.firstdraw:=true;

     GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree:=createtree(GetCurrentDrawing^.pObjRoot^.ObjArray,GetCurrentDrawing^.pObjRoot^.vp.BoundingBox,@GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;


     pdrawing2:={gdb.}CreateSimpleDWG;
     //gdb.AddRef(pdrawing2^);
     //gdb.SetCurrentDWG(pointer(pdrawing2));
     for i:=1 to 10 do
     begin
          pdrawing2^.LayerTable.addlayer(inttostr(i),random(255),0,true,false,true,'',TLOMerge);
     end;


     wpowner:=TGDIViewArea.Create(Panel2);
     oglwnd:=wpowner.getviewcontrol;
     pdrawing2^.wa:=wpowner;
     wpowner.PDWG:=pdrawing2;
     wpowner.getviewcontrol.align:=alClient;
     wpowner.getviewcontrol.Parent:=Panel2;
     wpowner.getviewcontrol.Visible:=true;
     wpowner.PDWG:=pdrawing2;
     wpowner.getareacaps;
     //oglwnd.show;
     wpowner.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                //создания или загрузки
     wpowner.param.firstdraw:=true;
     GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree:=createtree(GetCurrentDrawing^.pObjRoot^.ObjArray,GetCurrentDrawing^.pObjRoot^.vp.BoundingBox,@GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;


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
     pobj^.vp.Layer:=GetCurrentDrawing^.LayerTable.getelement(random(GetCurrentDrawing^.LayerTable.Count));
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
   pobj:{PGDBObjLine}PGDBObjEntity;
   v1,v2:gdbvertex;
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add lines');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
  for i:=1 to SpinEdit1.Value do
  begin
    v1:=CreateRandomVertex(1000,500);
    v2:=geometry.VertexAdd(v1,CreateRandomVertex(1000,500));

    pobj := ENTF_CreateLine(GetCurrentDrawing^.GetCurrentRoot,@GetCurrentDrawing^.GetCurrentRoot^.ObjArray,[v1.x,v1.y,v1.z,v2.x,v2.y,v2.z]);

    {pobj := PGDBObjLine(CreateInitObjFree(GDBLineID,nil));
    pobj^.CoordInOCS.lBegin:=v1;
    pobj^.CoordInOCS.lEnd:=v2;
    gdb.GetCurrentRoot^.AddMi(@pobj);}
    processobj(pobj);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
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
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add lwpolylines');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
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
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
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
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add 3dfaces');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
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
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
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
  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        case pv^.vp.ID of
        GDBLineID:begin
                       l:=PGDBObjLine(pv)^.Length/10;
                       hl:=l/2;
                       PGDBObjLine(pv)^.CoordInOCS.lBegin:=geometry.VertexAdd(PGDBObjLine(pv)^.CoordInOCS.lBegin,CreateRandomVertex(l,hl));
                       PGDBObjLine(pv)^.CoordInOCS.lEnd:=geometry.VertexAdd(PGDBObjLine(pv)^.CoordInOCS.lEnd,CreateRandomVertex(l,hl));
                       pv^.YouChanged(GetCurrentDrawing^);
                  end;
        GDBCircleID:begin
                       l:=PGDBObjCircle(pv)^.Radius;
                       hl:=l/2;
                       PGDBObjCircle(pv)^.Local.P_insert:=geometry.VertexAdd(PGDBObjCircle(pv)^.Local.P_insert,CreateRandomVertex(l,hl));
                       PGDBObjCircle(pv)^.Radius:=PGDBObjCircle(pv)^.Radius+CreateRandomDouble(l)-hl;
                       if PGDBObjCircle(pv)^.Radius<=0 then PGDBObjCircle(pv)^.Radius:=CreateRandomDouble(9)+1;
                       pv^.YouChanged(GetCurrentDrawing^);
                  end;
        end;
  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  _EndLongProcess;

  redrawoglwnd;
end;

procedure TForm1.BtnAddCirclesClick(Sender: TObject);
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
    pobj := PGDBObjCircle(CreateInitObjFree(GDBCircleID,nil));
    v1:=CreateRandomVertex(1000,500);
    pobj^.Local.P_insert:=v1;
    pobj^.Radius:=CreateRandomDouble(9.9)+0.1;
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
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
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add 3dpolylines');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
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
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TForm1.BtnAddArcsClick(Sender: TObject);
var
   i:integer;
   pobj:PGDBObjArc;
   dc:TDrawContext;
begin
  _StartLongProcess(0,'Add arcs');
  dc:=GetCurrentDrawing^.CreateDrawingRC;
  for i:=1 to SpinEdit1.Value do
  begin
    pobj := PGDBObjArc(CreateInitObjFree(GDBArcID,nil));
    pobj^.Local.P_insert:=CreateRandomVertex(1000,500);
    pobj^.R:=CreateRandomDouble(10)+0.1;
    pobj^.StartAngle:=CreateRandomDouble(2*pi);
    pobj^.EndAngle:=CreateRandomDouble(2*pi);
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;


procedure TForm1.BtnRebuildClick(Sender: TObject);
var
   dc:TDrawContext;
begin
     _StartLongProcess(0,'Rebuild spatial tree');
     dc:=GetCurrentDrawing^.CreateDrawingRC;
     GetCurrentDrawing^.pObjRoot^.calcbb(dc);
     GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree:=createtree(GetCurrentDrawing^.pObjRoot^.ObjArray,GetCurrentDrawing^.pObjRoot^.vp.BoundingBox,@GetCurrentDrawing^.pObjRoot^.ObjArray.ObjTree,IninialNodeDepth,nil,TND_Root)^;
     _EndLongProcess;
     redrawoglwnd;
end;

procedure TForm1.BtnEraseSelClick(Sender: TObject);
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
  GetCurrentDrawing^.SelObjArray.clearallobjects;
  _EndLongProcess;
  redrawoglwnd;
end;
procedure TForm1.BtnAddTextsClick(Sender: TObject);
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
    pGDBObjEntity(pobj):=CreateInitObjFree(GDBTextID,nil);
    v1:=CreateRandomVertex(1000,500);
    pobj^.Local.P_insert:=v1;
    pobj^.TXTStyleIndex:=ts;
    pobj^.Template:='Hello word!';
    pobj^.textprop.size:=1+random(10);
    pobj^.textprop.justify:=b2j[1+random(11)];
    pobj^.textprop.wfactor:=0.3+random*0.7;
    pobj^.textprop.oblique:=(random(30)-15)*pi/180;
    angl:=pi*random{*0.5};
    pobj^.textprop.angle:=angl*180/pi;
    pobj^.local.basis.OX:=VectorTransform3D(PGDBObjText(pobj)^.local.basis.OX,geometry.CreateAffineRotationMatrix(PGDBObjText(pobj)^.Local.basis.oz,-angl));
    GetCurrentDrawing^.GetCurrentRoot^.AddMi(@pobj);
    processobj(pobj);
    pobj^.BuildGeometry(GetCurrentDrawing^);
    pobj^.formatEntity(GetCurrentDrawing^,dc);
  end;
  _EndLongProcess;
  //FormatEntitysAndRebuildTreeAndRedraw;
  BtnRebuildClick(self);
end;

procedure TForm1.BtnOpenDXFClick(Sender: TObject);
var
   dc:TDrawContext;
begin
     {$ifdef dxfio}
     if OpenDialog1.Execute then
     begin
          dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
          addfromdxf(OpenDialog1.FileName,@gdb.GetCurrentDWG^.pObjRoot^,TLOLoad,gdb.GetCurrentDWG^);
          gdb.GetCurrentDWG^.pObjRoot^.FormatEntity(gdb.GetCurrentDWG^,dc);
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
                           pv^.select(GetCurrentDrawing^.GetSelObjArray,GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount);

  pv:=GetCurrentDrawing^.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  _EndLongProcess;
  redrawoglwnd;
  //if assigned(updatevisibleproc) then updatevisibleproc;

end;

procedure TForm1. OffEntLayerClick(Sender: TObject);
begin
  begin
       if GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount=1 then
       begin
            if GetCurrentDrawing^.wa.param.SelDesc.LastSelectedObject<>nil then
            begin
                 pGDBObjEntity(GetCurrentDrawing^.wa.param.SelDesc.LastSelectedObject)^.vp.Layer^._on:=false;
                 pGDBObjEntity(GetCurrentDrawing^.wa.param.SelDesc.LastSelectedObject)^.DeSelect(GetCurrentDrawing^.GetSelObjArray,GetCurrentDrawing^.wa.param.SelDesc.Selectedobjcount);
            end;
            redrawoglwnd;
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
  ptd:=GetCurrentDrawing;
  if ptd<>nil then
  begin
  plp:=ptd^.LayerTable.beginiterate(ir);
  if plp<>nil then
  repeat
        plp^._on:=true;
  plp:=ptd^.LayerTable.iterate(ir);
  until plp=nil;
  redrawoglwnd;
  end;
end;



procedure TForm1.TreeChange(Sender: TObject);
begin
     sysvarDISPSystmGeometryDraw:=CheckBox1.Checked;
     redrawoglwnd;
end;

procedure TForm1._DestroyApp(Sender: TObject);
begin
     //ugdbdescriptor.finalize;
end;


end.

