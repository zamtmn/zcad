{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit UGDBDescriptor;
{$INCLUDE def.inc}
interface
uses
UGDBOpenArrayOfUCommands,strproc,GDBBlockDef,UGDBDrawingdef,UGDBObjBlockdefArray,UGDBTableStyleArray,UUnitManager,
UGDBNumerator, gdbase,varmandef,varman{, oglwindowdef, math, UGDBOpenArrayOfByte},
sysutils, memman, geometry, gdbobjectsconstdef{, strmy,dxflow},
{UOpenArray,}gdbasetypes,sysinfo,
GDBGenericSubEntry,
//UGDBOpenArray,
//UGDBOutbound2DIArray,
//UGDBPoint3DArray,
//UGDBPolyLine2DArray,
//UGDBPolyPoint2DArray,
//UGDBPolyPoint3DArray,
UGDBLayerArray,
//UGDBControlPointArray,
GDBEntity,
//UGDBVisibleOpenArray,
UGDBSelectedObjArray,
UGDBTextStyleArray,
UGDBFontManager,
GDBCamera,
UGDBOpenArrayOfPV,
GDBRoot,UGDBSHXFont,
{GDBNet,}OGLWindow,UGDBOpenArrayOfPObjects,UGDBVisibleOpenArray;
const ls = $AAAA;
      ps:array [0..31] of LONGWORD=(
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC
                                  );
      UnnamedWindowTitle='unnamed';
type
{EXPORT+}
GDBObjTrash=object(GDBObjEntity)
                 function GetHandle:GDBPlatformint;virtual;
                 function GetMatrix:PDMatrix4D;virtual;
                 constructor initnul;
                 destructor done;virtual;
           end;
TDWGProps=record
                Name:GDBString;
                Number:GDBInteger;
          end;
PTDrawing=^TDrawing;
TDrawing=object(TAbstractDrawing)
           pObjRoot:PGDBObjGenericSubEntry;
           mainObjRoot:GDBObjRoot;(*saved_to_shd*)
           LayerTable:GDBLayerArray;(*saved_to_shd*)
           ConstructObjRoot:GDBObjRoot;
           SelObjArray:GDBSelectedObjArray;
           pcamera:PGDBObjCamera;
           OnMouseObj:GDBObjOpenArrayOfPV;
           DWGUnits:TUnitManager;

           OGLwindow1:toglwnd;

           UndoStack:GDBObjOpenArrayOfUCommands;

           TextStyleTable:GDBTextStyleArray;(*saved_to_shd*)
           BlockDefArray:GDBObjBlockdefArray;(*saved_to_shd*)
           Numerator:GDBNumerator;(*saved_to_shd*)
           TableStyleTable:GDBTableStyleArray;(*saved_to_shd*)
           FileName:GDBString;
           Changed:GDBBoolean;
           attrib:GDBLongword;

           function myGluProject2(objcoord:GDBVertex; out wincoord:GDBVertex):Integer;
           function myGluUnProject(win:GDBVertex;out obj:GDBvertex):Integer;


           constructor init(num:PTUnitManager);
           destructor done;virtual;
           function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
           function GetLastSelected:PGDBObjEntity;virtual;
           //procedure SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
     end;
PGDBDescriptor=^GDBDescriptor;
GDBDescriptor=object(GDBOpenArrayOfPObjects)
                    CurrentDWG:PTDrawing;
                    ProjectUnits:TUnitManager;
                    constructor init;
                    constructor initnul;
                    destructor done;virtual;
                    function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;

                    function GetCurrentROOT:PGDBObjGenericSubEntry;

                    function GetCurrentDWG:PTDrawing;
                    procedure SetCurrentDWG(PDWG:PTDrawing);

                    function CreateDWG:PTDrawing;
                    procedure eraseobj(ObjAddr:PGDBaseObject);virtual;

                    procedure CopyBlock(_from,_to:PTDrawing;_source:PGDBObjBlockdef);
                    function CopyEnt(_from,_to:PTDrawing;_source:PGDBObjEntity):PGDBObjEntity;
                    procedure AddBlockFromDBIfNeed(_to:PTDrawing;name:GDBString);
                    procedure rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;
              end;
{EXPORT-}
var GDB: GDBDescriptor;
    BlockBaseDWG:PTDrawing;
    ClipboardDWG:PTDrawing;
    GDBTrash:GDBObjTrash;
    FontManager:GDBFontManager;
    pbasefont: PGDBfont;
    palette: gdbpalette;
procedure CalcZ(z:GDBDouble);
procedure RemapAll(_from,_to:PTDrawing;_source,_dest:PGDBObjEntity);
procedure startup;
procedure finalize;
implementation
 uses {GDBSubordinated,}GDBText,GDBDevice,GDBBlockInsert,io,iodxf, GDBManager,shared{,mainwindow},commandline,log;
function TDrawing.GetLastSelected:PGDBObjEntity;
begin
     result:=OGLwindow1.param.SelDesc.LastSelectedObject;
end;
function TDrawing.myGluProject2;
begin
      objcoord:=vertexadd(objcoord,pcamera^.CamCSOffset);
     _myGluProject(objcoord.x,objcoord.y,objcoord.z,@pcamera^.modelMatrixLCS,@pcamera^.projMatrixLCS,@pcamera^.viewport,wincoord.x,wincoord.y,wincoord.z);
end;
function TDrawing.myGluUnProject(win:GDBVertex;out obj:GDBvertex):Integer;
begin
     _myGluUnProject(win.x,win.y,win.z,@pcamera^.modelMatrixLCS,@pcamera^.projMatrixLCS,@pcamera^.viewport, obj.x,obj.y,obj.z);
     OBJ:=vertexsub(OBJ,pcamera^.CamCSOffset);
end;
procedure GDBDescriptor.rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);
var i:GDBInteger;
    point:pcontrolpointdesc;
    p:GDBPointer;
    var m:DMatrix4D;
    t:gdbvertex;
    tt:dvector4d;
    rtmod:TRTModifyData;
    tum:TUndableMethod;
begin
     if PSelectedObjDesc(md).pcontrolpoint^.count=0 then exit;
     if PSelectedObjDesc(md).ptempobj=nil then
     begin
          PSelectedObjDesc(md).ptempobj:=obj^.Clone(nil);
          //PSelectedObjDesc(md).ptempobj.BuildGeometry;
          PSelectedObjDesc(md).ptempobj^.bp.Owner:=obj^.bp.Owner;
          PSelectedObjDesc(md).ptempobj.format;
     end;
     p:=obj^.beforertmodify;
     if save then PSelectedObjDesc(md).pcontrolpoint^.SelectedCount:=0;
     point:=PSelectedObjDesc(md).pcontrolpoint^.parray;
     for i:=1 to PSelectedObjDesc(md).pcontrolpoint^.count do
     begin
          if point.selected then
          begin
               if save then
                           save:=save;
               m:=PSelectedObjDesc(md).objaddr^.getownermatrix^;
               tt:=m[3];
               //dist.x:=0;
               MatrixInvert(m);
               m[3,0]:=0;
               m[3,1]:=0;
               m[3,2]:=0;

               {t.x:=m[0,0];
               t.y:=m[0,1];
               t.z:=m[0,2];
               t:=normalizevertex(t);
               m[0,0]:=t.x;
               m[0,1]:=t.y;
               m[0,2]:=t.z;

               t.x:=m[1,0];
               t.y:=m[1,1];
               t.z:=m[1,2];
               t:=normalizevertex(t);
               m[1,0]:=t.x;
               m[1,1]:=t.y;
               m[1,2]:=t.z;

               t.x:=m[2,0];
               t.y:=m[2,1];
               t.z:=m[2,2];
               t:=normalizevertex(t);
               m[2,0]:=t.x;
               m[2,1]:=t.y;
               m[2,2]:=t.z;}







               //geometry.NormalizeVertex(tt)

               t:=VectorTransform3D(dist,m);

               rtmod.point:=point^;
               rtmod.dist:=VectorTransform3D(dist,m);
               rtmod.wc:=VectorTransform3D(wc,m);

               if save then
                           begin
                                if obj^.IsRTNeedModify(point,p)then
                                                                   begin
                                                                        tmethod(tum).Code:=pointer(obj.rtmodifyonepoint);
                                                                        tmethod(tum).Data:=obj;
                                                                        //tum:=tundablemethod(obj^.rtmodifyonepoint);
                                                                        with GetCurrentDWG.UndoStack.PushCreateTGObjectChangeCommand(rtmod,tmethod(tum))^ do
                                                                        begin
                                                                             comit;
                                                                             rtmod.wc:=rtmod.point.worldcoord;
                                                                             rtmod.dist:=nulvertex;
                                                                             StoreUndoData(rtmod);
                                                                        end;
                                                                        //obj^.rtmodifyonepoint(rtmod);
                                                                   end;
                                point.selected:=false;
                           end
                       else
                           begin
                                if PSelectedObjDesc(md).ptempobj^.IsRTNeedModify(point,p)then
                                 PSelectedObjDesc(md).ptempobj^.rtmodifyonepoint(rtmod);

                           end;
          end;
          inc(point);
     end;
     if save then
     begin
          //--------------(PSelectedObjDesc(md).ptempobj).rtsave(@self);

          //PGDBObjGenericWithSubordinated(obj^.bp.owner)^.ImEdited({@self}obj,obj^.bp.PSelfInOwnerArray);
          PSelectedObjDesc(md).ptempobj^.done;
          GDBFreeMem(GDBPointer(PSelectedObjDesc(md).ptempobj));
          PSelectedObjDesc(md).ptempobj:=nil;
     end
     else
     begin
          PSelectedObjDesc(md).ptempobj.format;
          //PSelectedObjDesc(md).ptempobj.renderfeedback;
     end;
     obj^.afterrtmodify(p);
end;


function GDBDescriptor.GetCurrentROOT;
begin
     if CurrentDWG<>nil then
                            result:=CurrentDWG.pObjRoot
                        else
                            result:=nil;
end;
function GDBDescriptor.GetCurrentDWG;
begin
 result:=CurrentDWG;
end;
procedure GDBDescriptor.SetCurrentDWG(PDWG:PTDrawing);
begin
 commandmanager.executecommandend;
 CurrentDWG:=PDWG;
end;

function GDBObjTrash.GetHandle;
begin
     result:=H_Trash;
end;
function GDBObjTrash.GetMatrix;
begin
     result:=@onematrix;
end;
constructor GDBObjTrash.initnul;
begin
end;
destructor GDBObjTrash.done;
begin
end;
procedure CalcZ(z:GDBDouble);
begin
     if z<gdb.GetCurrentDWG.pcamera^.obj_zmax then
     gdb.GetCurrentDWG.pcamera^.obj_zmax:=z;
     if z>gdb.GetCurrentDWG.pcamera^.obj_zmin then
     gdb.GetCurrentDWG.pcamera^.obj_zmin:=z;
end;
constructor TDrawing.init;
var tp:GDBTextStyleProp;
    ts:PTGDBTableStyle;
    cs:TGDBTableCellStyle;
begin
  LayerTable.init({$IFDEF DEBUGBUILD}'{6AFCB58D-9C9B-4325-A00A-C2E8BDCBE1DD}',{$ENDIF}200);
  DWGUnits.init;
  DWGUnits.SetNextManager(num);
  DWGUnits.loadunit(expandpath('*rtl/dwg/DrawingDeviceBase.pas'),nil);
  DWGDBUnit:=DWGUnits.findunit('DrawingDeviceBase');
  DWGUnits.loadunit(expandpath('*rtl/dwg/DrawingVars.pas'),nil);
  DWGUnits.findunit('DrawingVars').AssignToSymbol(pcamera,'camera');
  //pcamera^.initnul;
  mainobjroot.initnul;
  pObjRoot:=@mainobjroot;
  //ConstructObjRoot.init({$IFDEF DEBUGBUILD}'{B1036F20-562D-4B17-A33A-61CF3F5F2A90} - ConstructObjRoot',{$ENDIF}1);
  ConstructObjRoot.initnul;
  SelObjArray.init({$IFDEF DEBUGBUILD}'{0CC3A9A3-B9C2-4FB5-BFB1-8791C261C577} - SelObjArray',{$ENDIF}65535);
  OnMouseObj.init({$IFDEF DEBUGBUILD}'{85654C90-FF49-4272-B429-4D134913BC26} - OnMouseObj',{$ENDIF}20);


  Pointer(FileName):=nil;
  FileName:=UnnamedWindowTitle;
  Changed:=True;

  TextStyleTable.init({$IFDEF DEBUGBUILD}'{146FC836-1490-4046-8B09-863722570C9F}',{$ENDIF}200);
  tp.size:=2.5;
  tp.oblique:=0;
  //TextStyleTable.addstyle('Standart','normal.shp',tp);

  //TextStyleTable.addstyle('R2_5','romant.shx',tp);
  //TextStyleTable.addstyle('standart','txt.shx',tp);

  BlockDefArray.init({$IFDEF DEBUGBUILD}'{E5CE9274-01D8-4D19-AF2E-D1AB116B5737}',{$ENDIF}10000);
  Numerator.init(10);

  TableStyleTable.init({$IFDEF DEBUGBUILD}'{E5CE9274-01D8-4D19-AF2E-D1AB116B5737}',{$ENDIF}10);

  ts:=TableStyleTable.AddStyle('Standart');

  ts.rowheight:=4;
  ts.textheight:=2.5;

  cs.Width:=10;
  cs.TextWidth:={cf.Width-2}0;
  cs.CF:=jcm;
  ts.tblformat.Add(@cs);

  ts:=TableStyleTable.AddStyle('Spec');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_SPEC_HEAD';

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=130;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=60;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=35;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=45;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=40;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcr;
     ts.tblformat.Add(@cs);

  ts:=TableStyleTable.AddStyle('ShRaspr');

  ts.rowheight:=10;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_PSRS_HEAD';

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=33;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=33;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=17;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=23;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=16;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=12;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=12;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=35;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcl;
     ts.tblformat.Add(@cs);




  ts:=TableStyleTable.AddStyle('KZ');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_KZ_HEAD';

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=46;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=46;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=40;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     {cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);}

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);


     UndoStack.init;


  //OGLwindow1.initxywh('oglwnd',nil,200,72,768,596,false);
  //OGLwindow1.show;
end;
procedure GDBDescriptor.eraseobj(ObjAddr:PGDBaseObject);
begin
     inherited eraseobj(objaddr);
     if objaddr=pointer(CurrentDWG) then
                               CurrentDWG:=nil;
     
end;
function GDBDescriptor.CreateDWG:PTDrawing;
var
   ptd:PTDrawing;
begin
     gdBGetMem({$IFDEF DEBUGBUILD}'{2A28BFB9-661F-4331-955A-C6F18DE67A19}',{$ENDIF}GDBPointer(result),sizeof(TDrawing));
     ptd:=currentdwg;
     currentdwg:=result;
     result^.init(@units);
     //self.AddRef(result^);
     currentdwg:=ptd;
end;
constructor GDBDescriptor.init;
//var //tp:GDBTextStyleProp;
    //ts:PTGDBTableStyle;
    //cs:TGDBTableCellStyle;
begin
   inherited init({$IFDEF DEBUGBUILD}'{F5A454F1-CB6B-43AA-AD8D-AF3B9D781ED0}',{$ENDIF}100);
  //LayerTable.addlayer('EL_WIRES',CGDBGreen,40,true,false,true);








  ProjectUnits.init;
  ProjectUnits.SetNextManager(@units);

  CurrentDWG:=nil;
  //gdBGetMem({$IFDEF DEBUGBUILD}'{E197C531-C543-4FAF-AF4A-37B8F278E8A2}',{$ENDIF}GDBPointer(CurrentDWG),sizeof(TDrawing));
  if CurrentDWG<>nil then
  begin
       CurrentDWG.init(@ProjectUnits);
       CurrentDWG.pObjRoot^.Format;
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_connector.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_nok.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_OPS.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'sample\test_dxf\teapot.dxf',@CurrentDWG.ObjRoot);
       //addfromdxf(sysvar.path.Program_Run^+'sample\test_dxf\shema_Poly_Line_Text_Circle_Arc.dxf',@CurrentDWG.ObjRoot);
  end;
end;
constructor GDBDescriptor.initnul;
//var tp:GDBTextStyleProp;
begin
  //Pointer(FileName):=nil;
  //Changed:=True;
  CurrentDWG.DWGUnits.init;
  inherited initnul;
end;
function GDBDescriptor.AfterDeSerialize;
begin
     CurrentDWG.pcamera:=SysUnit.InterfaceVariables.findvardesc('camera').data.Instance;
     //CurrentDWG.ConstructObjRoot.init({$IFDEF DEBUGBUILD}'{B1036F20-56klhj2D-4B17-A33A-61CF3F5F2A90}',{$ENDIF}65535);
     CurrentDWG.ConstructObjRoot.initnul;
     CurrentDWG.SelObjArray.init({$IFDEF DEBUGBUILD}'{0CC3A9A3-B9C2-4FkjhB5-BFB1-8791C261C577}',{$ENDIF}65535);
     CurrentDWG.OnMouseObj.init({$IFDEF DEBUGBUILD}'{85654C90-FF49-427длро2-B429-4D134913BC26}',{$ENDIF}100);
     //BlockDefArray.init({$IFDEF DEBUGBUILD}'{E5CE9274-01D8-fgjhfgh9-AF2E-D1AB116B5737}',{$ENDIF}1000);
end;
destructor TDrawing.done;
begin
     undostack.done;
     mainObjRoot.done;
     LayerTable.FreeAndDone;
     //ConstructObjRoot.ObjArray.FreeAndDone;
     ConstructObjRoot.done;
     SelObjArray.FreeAndDone;
     DWGUnits.FreeAndDone;
     OnMouseObj.ClearAndDone;
     TextStyleTable.FreeAndDone;
     BlockDefArray.FreeAndDone;
     Numerator.FreeAndDone;
     TableStyleTable.FreeAndDone;

     FileName:='';
end;
//procedure TDrawing.SetEntFromOriginal(_dest,_source:PGDBObjEntity;PCD_dest,PCD_source:PTDrawingPreCalcData);
//begin
//end;
destructor GDBDescriptor.done;
begin

    inherited;
    // gdbfreemem(pointer(currentdwg));
     ProjectUnits.done;
end;
procedure GDBDescriptor.AddBlockFromDBIfNeed(_to:PTDrawing;name:GDBString);
var
   {_dest,}td:PGDBObjBlockdef;
   //tn:gdbstring;
   //ir:itrec;
   //pvisible,pvisible2:PGDBObjEntity;
  // pl:PGDBLayerProp;
begin
     td:=_to.BlockDefArray.getblockdef(name);
     if td=nil then
     begin
          td:=BlockBaseDWG.BlockDefArray.getblockdef(name);
          CopyBlock(BlockBaseDWG,_to,td);
     end;
end;
procedure createtstyleifneed(_from,_to:PTDrawing;_source,_dest:PGDBObjEntity);
var
   {_dest,}td:PGDBObjBlockdef;
   oldti,newti:TArrayIndex;
   tsname:gdbstring;
   poldstyle,pnevstyle:PGDBTextStyle;
   ir:itrec;
   {pvisible,}pvisible2:PGDBObjEntity;
   //pl:PGDBLayerProp;
begin
               if (_source^.vp.ID=GDBTextID)
               or (_source^.vp.ID=GDBMtextID) then
               begin
                    oldti:=PGDBObjText(_source)^.TXTStyleIndex;
                    poldstyle:=PGDBTextStyle(_from.TextStyleTable.getelement(oldti));
                    tsname:=poldstyle^.name;
                    newti:=_to.TextStyleTable.FindStyle(tsname);
                    if newti<0 then
                                   begin
                                        newti:=_to.TextStyleTable.addstyle(poldstyle.name,poldstyle.pfont.Name,poldstyle.prop);
                                        pnevstyle:=PGDBTextStyle(_to.TextStyleTable.getelement(newti));
                                        pnevstyle^:=poldstyle^;
                                   end
               end;
      oldti:=_to.TextStyleTable.FindStyle(tsname);
      PGDBObjText(_dest)^.TXTStyleIndex:=newti;
end;
procedure createblockifneed(_from,_to:PTDrawing;_source:PGDBObjEntity);
var
   {_dest,}td:PGDBObjBlockdef;
   tn:gdbstring;
   ir:itrec;
   {pvisible,}pvisible2:PGDBObjEntity;
   //pl:PGDBLayerProp;
begin
               if (_source^.vp.ID=GDBBlockInsertID)
               or (_source^.vp.ID=GDBDeviceID) then
               begin
                    tn:=PGDBObjBlockInsert(_source)^.name;
                    if (_source^.vp.ID=GDBDeviceID) then
                                                         tn:='DEVICE_'+tn;
                    td:=_to.BlockDefArray.getblockdef(tn);
                    if td=nil then
                                   begin
                                        td:=_from.BlockDefArray.getblockdef(tn);
                                        pvisible2:=td.ObjArray.beginiterate(ir);
                                        if pvisible2<>nil then
                                        repeat
                                              createblockifneed(_from,_to,pvisible2);

                                              pvisible2:=td.ObjArray.iterate(ir);
                                        until pvisible2=nil;
                                        if (_source^.vp.ID=GDBDeviceID) then
                                        begin
                                        pvisible2:=PGDBObjDevice(_source)^.VarObjArray.beginiterate(ir);
                                        if pvisible2<>nil then
                                        repeat
                                              createblockifneed(_from,_to,pvisible2);

                                              pvisible2:=PGDBObjDevice(_source)^.VarObjArray.iterate(ir);
                                        until pvisible2=nil;

                                        end;



                                        gdb.CopyBlock(_from,_to,td);
                                   end;

               end;
end;
function createlayerifneed(_from,_to:PTDrawing;_source:PGDBLayerProp):PGDBLayerProp;
begin
           result:=_to.LayerTable.getAddres(_source.Name);
           if result=nil then
           begin
                result:=_to.LayerTable.addlayer(_source.Name,
                                        _source.color,
                                        _source.lineweight,
                                        _source._on,
                                        _source._lock,
                                        _source._print);
           end;
end;
procedure RemapLayer(_from,_to:PTDrawing;_source,_dest:PGDBObjEntity);
begin
           _dest.vp.Layer:=createlayerifneed(_from,_to,_source.vp.Layer);
end;
procedure RemapEntArray(_from,_to:PTDrawing;const _source,_dest:GDBObjEntityOpenArray);
var
   irs,ird:itrec;
   s,d:PGDBObjEntity;
begin
  s:=_source.beginiterate(irs);
  d:=_dest.beginiterate(ird);
  if (d<>nil)and(s<>nil) then
  repeat
         remapall(_from,_to,s,d);
       s:=_source.iterate(irs);
       d:=_dest.iterate(ird);
  until (s=nil)or(d=nil);
end;

procedure RemapAll(_from,_to:PTDrawing;_source,_dest:PGDBObjEntity);
begin
  RemapLayer(_from,_to,_source,_dest);
  case _source.vp.ID of
                        GDBTextID,GDBMtextID:begin
                                             createtstyleifneed(_from,_to,_source,_dest);
                                             end;
                        GDBDeviceID:begin
                                         RemapEntArray(_from,_to,PGDBObjDevice(_source).VarObjArray,PGDBObjDevice(_dest).VarObjArray);
                                         RemapEntArray(_from,_to,PGDBObjDevice(_source).ConstObjArray,PGDBObjDevice(_dest).ConstObjArray);
                                    end;
                        GDBBlockInsertID:begin
                                         RemapEntArray(_from,_to,PGDBObjBlockInsert(_source).ConstObjArray,PGDBObjBlockInsert(_dest).ConstObjArray);
                                    end;
                    end;
end;
function GDBDescriptor.CopyEnt(_from,_to:PTDrawing;_source:PGDBObjEntity):PGDBObjEntity;
var
   tv: pGDBObjEntity;
begin
    createblockifneed(_from,_to,_source);
    tv := _source^.Clone(_to.pObjRoot);
    if tv<>nil then
    begin
        _to.pObjRoot.ObjArray.add(addr(tv));
        RemapAll(_from,_to,_source,tv);
    end;
    result:=tv;
end;
procedure GDBDescriptor.CopyBlock(_from,_to:PTDrawing;_source:PGDBObjBlockdef);
var
   _dest{,td}:PGDBObjBlockdef;
   //tn:gdbstring;
   ir:itrec;
   pvisible,pvisible2,pv:PGDBObjEntity;
   pl:PGDBLayerProp;

begin
      if pos('DEVICE_',_source.Name)=1 then
                                         CopyBlock(_from,_to,_from.BlockDefArray.getblockdef(copy(_source.Name,8,length(_source.Name)-7)));

     _dest:=_to.BlockDefArray.create(_source.Name);
     _dest.VarFromFile:='';
     _dest.Base:=_source.Base;
     _dest.BlockDesc:=_source.BlockDesc;

     _source.OU.CopyTo(@_dest.OU);

     pvisible:=_source.ObjArray.beginiterate(ir);
     if pvisible<>nil then
     repeat
           //pl:=createlayerifneed(_from,_to,pvisible.vp.layer);

           createblockifneed(_from,_to,pvisible);

               //pvisible:=CopyEnt(_from,_to,pvisible);
               pv:=pvisible;
               pvisible2:=pvisible^.Clone(_dest);
               RemapAll(_from,_to,pvisible,pvisible2);
               //pvisible2:=nil;
                                      begin
                                          pvisible2^.correctobjects(_dest,ir.itc);
                                          pvisible2^.format;
                                          pvisible2.BuildGeometry;
                                          _dest.ObjArray.add(@pvisible2);
                                     end;
          pvisible:=_source.ObjArray.iterate(ir);
     until pvisible=nil;


     _dest.format;
end;
procedure addf(fn:gdbstring);
begin
     FontManager.addFonf(fn);
end;

procedure startup;
begin
  FontManager.init({$IFDEF DEBUGBUILD}'{9D0E081C-796F-4EB1-98A9-8B6EA9BD8640}',{$ENDIF}100);

  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\times.shx');
  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\GENISO.SHX');
  //FontManager.addFonf('C:\Program Files\AutoCAD 2010\Fonts\amgdt.shx');

  //FromDirIterator({sysparam.programpath+'fonts/'}'C:\Program Files\AutoCAD 2010\Fonts\','*.shx','',addf,nil);

  FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,sysvar.SYS.SYS_AlternateFont^));
  pbasefont:=FontManager.getAddres(sysvar.SYS.SYS_AlternateFont^);
  if pbasefont=nil then
                       shared.FatalError('Альтернативный шрифт "'+sysvar.SYS.SYS_AlternateFont^+
                                         '" не найден в "'+ sysvar.PATH.Fonts_Path^+'"');

  //FontManager.addFonf(sysparam.programpath+'fonts/gewind.shx');
  //FontManager.addFonf('gothice.shx');
  //FontManager.addFonf('romant.shx');

  //pbasefont:=FontManager.getAddres('gewind.shx');
  //pbasefont:=FontManager.{FindFonf}getAddres('amgdt.shx');
  //pbasefont:=FontManager.getAddres('gothice.shx');
  gdb.init;
  BlockBaseDWG:=gdb.CreateDWG;
  ClipboardDWG:=gdb.CreateDWG;
  //gdb.currentdwg:=BlockBaseDWG;
  GDBTrash.initnul;
end;
procedure finalize;
begin
  gdb.done;
  BlockBaseDWG.done;
  GDBFreemem(pointer(BlockBaseDWG));
  ClipboardDWG.done;
  GDBFreemem(pointer(ClipboardDWG));
  pbasefont:=nil;
  FontManager.FreeAndDone;
  GDBTrash.done;
end;
begin
  programlog.logoutstr('UGDBDescriptor.startup',lp_IncPos);
  {$IFDEF DEBUGINITSECTION}LogOut('GDBDescriptor.initialization');{$ENDIF}
  programlog.logoutstr('UGDBDescriptor.startup',lp_DecPos);
end.
