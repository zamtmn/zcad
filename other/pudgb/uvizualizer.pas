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
  uzeent3Dface,uzeentlwpolyline,uzeentpolyline,uzeenttext,uzeentellipse,uzeentline,uzeentcircle,uzeentarc,         //entitys created by program
  {$ifdef dxfio}
  uzeffdxf,                                                                        //dxf fileformat support
  uzeentmtext,uzeentdimensiongeneric,uzeentdimaligned,uzeentdimrotated,uzeentsolid,//some other entitys can be found in loaded files
  uzeentspline,
  {$endif}
  uzestyleslayers,uzestylestexts,                                            //layers and text steles support
  uzeentitiestree,                                                                  //entities spatial binary tree
  uzedrawingsimple,                                                            //drawing

  uprogramoptions,uzctnrvectorgdbdouble,gzctnrvectorsimple,math,

  gzctnrvectortypes,uzeconsts,laz2_xmlread, laz2_dom;                                                           //some consts

type

  { TVizualiserForm }
  TSVGPathModifier=(SVGPM_Space,SVGPM_Number,SVGPM_Frac,SVGPM_Coma,SVGPM_M,SVGPM_C,SVGPM_S);
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
    InFile:TMemoryStream;
    procedure CreateDrawingFromSVG;
    procedure CreateEntityFromNode(ANode: TDOMNode;var trans:DMatrix4D);
    procedure CreatePatchEnt(Node: TDOMNode;var trans:DMatrix4D);
    procedure ReadNode(Node: TDOMNode;var trans:DMatrix4D);
    procedure CreateTextEnt(Node: TDOMNode;var trans:DMatrix4D);
    procedure CreateEllipseEnt(Node: TDOMNode;var trans:DMatrix4D);
    procedure CreatePolygonEnt(Node: TDOMNode;var trans:DMatrix4D);
  end; 

var
  VizualiserForm: TVizualiserForm;

  LPTime:Tdatetime;
  pname:string;

implementation

{$R *.lfm}
procedure TVizualiserForm.CreateTextEnt(Node: TDOMNode;var trans:DMatrix4D);
var
   i:integer;
   pobj:PGDBObjText;
   v1:gdbvertex;
   tp:GDBTextStyleProp;
   size:double;
   ts:PGDBTextStyle;
   dc:TDrawContext;
   lNodeName, lNodeValue: DOMString;
begin

 for i := 0 to Node.Attributes.Length - 1 do
 begin
   lNodeName := Node.Attributes.Item[i].NodeName;
   lNodeValue := Node.Attributes.Item[i].NodeValue;
   if  lNodeName = 'x' then
     v1.x := strtofloat(lNodeValue)
   else if lNodeName = 'y' then
     v1.y := strtofloat(lNodeValue)
   else if lNodeName = 'font-size' then
     size := strtofloat(lNodeValue);
 end;
 lNodeValue:=Node.FirstChild.NodeValue;
 v1.z:=0;
 v1.y:=v1.y-size/2;
  if pdrawing1^.TextStyleTable.count=0 then
  begin
       tp.size:=2.5;
       tp.oblique:=0;
       pdrawing1^.TextStyleTable.addstyle('standart','txt.shx',tp,false);
  end;
  ts:=pdrawing1^.TextStyleTable.getAddres('standart');
  dc:=pdrawing1^.CreateDrawingRC;

    pobj:=GDBObjText.CreateInstance;
    pobj^.Local.P_insert:=VectorTransform3D(v1,trans);
    pobj^.TXTStyleIndex:=ts;
    pobj^.Template:=lNodeValue;
    pobj^.textprop.size:=size;
    pobj^.textprop.justify:=jsmc;
    pobj^.textprop.wfactor:=0.5;

    pdrawing1^.GetCurrentRoot^.AddMi(@pobj);

    pobj^.BuildGeometry(pdrawing1^);
    pobj^.formatEntity(pdrawing1^,dc);

end;

procedure TVizualiserForm.CreateEllipseEnt(Node: TDOMNode;var trans:DMatrix4D);
var
   i:integer;
   pobj:PGDBObjEllipse;
   v1:gdbvertex;
   dc:TDrawContext;
   lNodeName, lNodeValue: DOMString;
   rx,ry:double;
begin

 for i := 0 to Node.Attributes.Length - 1 do
 begin
   lNodeName := Node.Attributes.Item[i].NodeName;
   lNodeValue := Node.Attributes.Item[i].NodeValue;
   if  lNodeName = 'cx' then
     v1.x := strtofloat(lNodeValue)
   else if lNodeName = 'cy' then
     v1.y := strtofloat(lNodeValue)
   else if lNodeName = 'rx' then
     rx := strtofloat(lNodeValue)
   else if lNodeName = 'ry' then
     ry := strtofloat(lNodeValue);
 end;

  dc:=pdrawing1 ^.CreateDrawingRC;

    pobj := GDBObjEllipse.CreateInstance ;
    pobj^.Local.P_insert:=VectorTransform3D(v1,trans);
    pobj^.MajorAxis:=VectorTransform3D(createvertex(Rx,0,0),trans);
    pobj^.Ratio:=Ry/Rx;
    pdrawing1^.GetCurrentRoot^.AddMi(@pobj);
    //SetEntityLayer(pobj,GetCurrentDrawing);
    pobj^.BuildGeometry(pdrawing1^);
    pobj^.formatEntity(pdrawing1^,dc);

end;
function upperchar(ch:char):char;
begin
  if ch in ['a'..'z'] then result:=chr(ord(ch)-32)
                      else result:=ch;
end;

function readnumber(const s:string;var _pos:integer;out startpos,len:integer;prevTocen:TSVGPathModifier):TSVGPathModifier;
type
  TNumCharsSet=set of char;
var
  NumSet:TNumCharsSet;
  spcount:integer;
begin
    NumSet:=['0'..'9','+','-','.'];
    spcount:=0;
    if (prevTocen<>SVGPM_Space)or(_pos=1) then
    while (s[_pos]=' ')and(_pos<=length(s)) do
    begin
      inc(_pos);
      inc(spcount);
    end;
    if spcount>0 then dec(_pos);
    startpos:=_pos;
    if s[_pos] in NumSet then
    begin
      len:=0;
      while (s[_pos] in NumSet)and(_pos<=length(s)) do
      begin
        inc(_pos);
        inc(len);
        if len=1 then
        begin
         exclude(NumSet,'+');
         exclude(NumSet,'-');
        end;
      end;
      result:=SVGPM_Number;
    end
else if upperchar(s[_pos])='S' then
    begin
     len:=1;
     inc(_pos);
     result:=SVGPM_S;
    end
else if upperchar(s[_pos])='M' then
    begin
     len:=1;
     inc(_pos);
     result:=SVGPM_M;
    end
else if upperchar(s[_pos])='C' then
    begin
     len:=1;
     inc(_pos);
     result:=SVGPM_C;
    end
else if upperchar(s[_pos])=',' then
    begin
     len:=1;
     inc(_pos);
     result:=SVGPM_Coma;
    end
else if upperchar(s[_pos])=' ' then
    begin
     len:=1;
     inc(_pos);
     result:=SVGPM_Space;
    end;
end;
procedure TVizualiserForm.CreatePatchEnt(Node: TDOMNode;var trans:DMatrix4D);
var
  i,j,tocenstart,tocenlength,count:integer;
  prevtocen:TSVGPathModifier;
  lNodeName,lPointsStr:string;
  numberarray:TZctnrVectorGDBDouble;
  seperarray:specialize GZVectorSimple<TSVGPathModifier>;
  num:double;
  fillmode:string;
  dc:TDrawContext;
  p3dpoly:PGDBObjPolyline;
  pobj:PGDBObj3DFace;
  v1:gdbvertex;
  m,mm:TSVGPathModifier;
begin
 for i := 0 to Node.Attributes.Length - 1 do
 begin
   lNodeName := Node.Attributes.Item[i].NodeName;
   if lNodeName = 'd' then
     lPointsStr := Node.Attributes.Item[i].NodeValue;
 end;
 numberarray.init(8);
 seperarray.init(8);
 i:=1;
 count:=0;
 prevtocen:=SVGPM_Space;
 while i<length(lPointsStr) do
 begin
   prevtocen:=readnumber(lPointsStr,i,tocenstart,tocenlength,prevtocen);
   {if count=0 then
     begin
       if prevtocen=SVGPM_Number then
         seperarray.PushBackData(SVGPM_Space);
     end;}
   if prevtocen=SVGPM_C then
                            prevtocen:=prevtocen;
   if prevtocen=SVGPM_Number then
     begin
     num:=strtofloat(copy(lPointsStr,tocenstart,tocenlength));
     numberarray.PushBackData(strtofloat(copy(lPointsStr,tocenstart,tocenlength)));
     seperarray.PushBackData(prevtocen);
     end
   else
     seperarray.PushBackData(prevtocen);
   inc(count);
 end;
begin
          dc:=pdrawing1^.CreateDrawingRC;
          begin
            i:=0;
            j:=0;
            p3dpoly := GDBObjPolyline.CreateInstance;
            while j<=seperarray.Count-1 do
            begin
              if seperarray.getDataMutable(j)^<>SVGPM_Space then
                m:=seperarray.getDataMutable(j)^
              else
                inc(j);
              mm:=seperarray.getDataMutable(j)^;
              case m of
               SVGPM_M:begin
                 inc(j);
                 mm:=seperarray.getDataMutable(j)^;
                 inc(j);
                 mm:=seperarray.getDataMutable(j)^;
                 v1.x:=numberarray.getDataMutable(i)^;
                 inc(j);
                 mm:=seperarray.getDataMutable(j)^;
                 inc(j);
                 mm:=seperarray.getDataMutable(j)^;
                 v1.y:=numberarray.getDataMutable(i+1)^;
                 v1.z:=0;
                 i:=i+2;
                 v1:=VectorTransform3D(v1,trans);
                 p3dpoly^.AddVertex(v1);
                       end;
              SVGPM_C:begin
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                v1.x:=numberarray.getDataMutable(i)^;
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                v1.y:=numberarray.getDataMutable(i+1)^;
                v1.z:=0;
                i:=i+2;
                v1:=VectorTransform3D(v1,trans);
                p3dpoly^.AddVertex(v1);

                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                v1.x:=numberarray.getDataMutable(i)^;
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                v1.y:=numberarray.getDataMutable(i+1)^;
                v1.z:=0;
                i:=i+2;
                v1:=VectorTransform3D(v1,trans);
                p3dpoly^.AddVertex(v1);

                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                v1.x:=numberarray.getDataMutable(i)^;
                inc(j);
                mm:=seperarray.getDataMutable(j)^;
                inc(j);
                //mm:=seperarray.getDataMutable(j)^;
                v1.y:=numberarray.getDataMutable(i+1)^;
                v1.z:=0;
                i:=i+2;
                v1:=VectorTransform3D(v1,trans);
                p3dpoly^.AddVertex(v1);

                      end;
             end;
            end;

            pdrawing1^.GetCurrentRoot^.AddMi(@p3dpoly);
            p3dpoly^.BuildGeometry(pdrawing1^);
            p3dpoly^.formatEntity(pdrawing1^,dc);
          end;
          BtnRebuildClick(self);
end;

end;

procedure TVizualiserForm.CreatePolygonEnt(Node: TDOMNode;var trans:DMatrix4D);
var
  i,j,tocenstart,tocenlength,count:integer;
  prevtocen:TSVGPathModifier;
  lNodeName,lPointsStr:string;
  numberarray:TZctnrVectorGDBDouble;
  seperarray:specialize GZVectorSimple<TSVGPathModifier>;
  num:double;
  fillmode:string;
  dc:TDrawContext;
  p3dpoly:PGDBObjPolyline;
  pobj:PGDBObj3DFace;
  v1:gdbvertex;
begin
 for i := 0 to Node.Attributes.Length - 1 do
 begin
   lNodeName := Node.Attributes.Item[i].NodeName;
   if lNodeName = 'points' then
     lPointsStr := Node.Attributes.Item[i].NodeValue;
   if lNodeName = 'fill' then
     fillmode :=  Node.Attributes.Item[i].NodeValue;
 end;
 numberarray.init(8);
 seperarray.init(8);
 i:=1;
 count:=0;
 prevtocen:=SVGPM_Space;
 while i<length(lPointsStr) do
 begin
   prevtocen:=readnumber(lPointsStr,i,tocenstart,tocenlength,prevtocen);
   if count=0 then
     begin
       if prevtocen=SVGPM_Number then
         seperarray.PushBackData(SVGPM_Space);
     end;
   if prevtocen=SVGPM_Number then
     begin
     num:=strtofloat(copy(lPointsStr,tocenstart,tocenlength));
     numberarray.PushBackData(strtofloat(copy(lPointsStr,tocenstart,tocenlength)))
     end
   else
     seperarray.PushBackData(prevtocen);
   inc(count);
 end;
 case uppercase(fillmode) of
     'BLACK':begin
       dc:=pdrawing1^.CreateDrawingRC;
       begin
         pobj:=GDBObj3DFace.CreateInstance;
         for j:=0 to min((numberarray.Count div 2)-1,3) do
         begin
           v1.x:=numberarray.getDataMutable(j*2)^;
           v1.y:=numberarray.getDataMutable(j*2+1)^;
           v1.z:=0;
           v1:=VectorTransform3D(v1,trans);
           pobj^.PInOCS[j]:=v1;
         end;

         pdrawing1^.GetCurrentRoot^.AddMi(@pobj);
         pobj^.BuildGeometry(pdrawing1^);
         pobj^.formatEntity(pdrawing1^,dc);
       end;
             end
        else begin
          dc:=pdrawing1^.CreateDrawingRC;
          begin
            p3dpoly := GDBObjPolyline.CreateInstance;
            for j:=0 to (numberarray.Count div 2)-1 do
            begin
                 v1.x:=numberarray.getDataMutable(j*2)^;
                 v1.y:=numberarray.getDataMutable(j*2+1)^;
                 v1.z:=0;
                 v1:=VectorTransform3D(v1,trans);
                 p3dpoly^.AddVertex(v1);
            end;
            p3dpoly^.Closed:=true;
            pdrawing1^.GetCurrentRoot^.AddMi(@p3dpoly);
            p3dpoly^.BuildGeometry(pdrawing1^);
            p3dpoly^.formatEntity(pdrawing1^,dc);
          end;
          BtnRebuildClick(self);
             end;
end;
end;
procedure TVizualiserForm.CreateEntityFromNode(ANode: TDOMNode;var trans:DMatrix4D);
var
  lEntityName: DOMString;
begin
  lEntityName := LowerCase(ANode.NodeName);
  case lEntityName of
    'circle': {Result := ReadCircleFromNode(ANode, AData, ADoc)};
    'defs': {ReadDefsFromNode(ANode, AData, ADoc)};
    'ellipse':begin
              CreateEllipseEnt(ANode,trans);
              end;
    'frame': {Result := ReadFrameFromNode(ANode, AData, ADoc)};
    'g': {ReadLayerFromNode(ANode, AData, ADoc)};
    'image': {Result := ReadImageFromNode(ANode, AData, ADoc)};
    'line': {Result := ReadLineFromNode(ANode, AData, ADoc)};
    'path': CreatePatchEnt(ANode,trans);
    'polygon'{, 'polyline'}:CreatePolygonEnt(ANode,trans);
    'rect': {Result := ReadRectFromNode(ANode, AData, ADoc)};
    'symbol': {Result := ReadSymbolFromNode(ANode, AData, ADoc)};
    'text':begin
              CreateTextEnt(ANode,trans);
           end;
    'use': {Result := ReadUseFromNode(ANode, AData, ADoc)};
  end;
end;

procedure TVizualiserForm.ReadNode(Node: TDOMNode;var trans:DMatrix4D);
var
  lCurNode: TDOMNode;
  lNodeName:DOMString;
  i:integer;
begin
  if Node.NodeName='g' then
   begin
    for i := 0 to Node.Attributes.Length - 1 do
    begin
      lNodeName := Node.Attributes.Item[i].NodeName;
      if lNodeName = 'transform' then
        lNodeName := Node.Attributes.Item[i].NodeValue;
      if lNodeName = 'scale' then
              lNodeName := Node.Attributes.Item[i].NodeValue;
      if lNodeName = 'rotate' then
              lNodeName := Node.Attributes.Item[i].NodeValue;
    end;
   end;
  lCurNode := Node.FirstChild;
  while Assigned(lCurNode) do
  begin
    ReadNode(lCurNode,trans);
    CreateEntityFromNode(lCurNode,trans);
    lCurNode := lCurNode.NextSibling;
  end;

end;

procedure TVizualiserForm.CreateDrawingFromSVG;
var
  Doc: TXMLDocument = nil;
  lCurNode: TDOMNode;
  lNodeName: DOMString;
  trans:DMatrix4D;
begin
  trans:=OneMatrix;
  trans[1][1]:=-1;
  ReadXMLFile(Doc, InFile);
  lCurNode := Doc.DocumentElement.FirstChild;
  while Assigned(lCurNode) do
  begin
    lNodeName := lCurNode.NodeName;
    ReadNode(lCurNode,trans);
    CreateEntityFromNode(lCurNode,trans);
    lCurNode := lCurNode.NextSibling;
  end;
end;

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
     CreateDrawingFromSVG;
     BtnRebuildClick(self);
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

