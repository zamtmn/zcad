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

unit UGDBDrawingdef;
interface
uses //gdbase,gdbasetypes,
zcadsysvars,zcadinterface,zcadstrconsts,GDBWithLocalCS,UGDBOpenArrayOfUCommands,strproc,GDBBlockDef,UGDBObjBlockdefArray,UGDBTableStyleArray,UUnitManager,
UGDBNumerator, gdbase,varmandef,varman,
sysutils, memman, geometry, gdbobjectsconstdef,
gdbasetypes,sysinfo,
GDBGenericSubEntry,
UGDBLayerArray,
GDBEntity,
UGDBSelectedObjArray,
UGDBTextStyleArray,
UGDBFontManager,
GDBCamera,
UGDBOpenArrayOfPV,
GDBRoot,UGDBSHXFont,
OGLWindow,UGDBOpenArrayOfPObjects,UGDBVisibleOpenArray;
type
{EXPORT+}
PTAbstractDrawing=^TAbstractDrawing;
TAbstractDrawing=object(GDBaseobject)
                       UndoStack:GDBObjOpenArrayOfUCommands;
                       pObjRoot:PGDBObjGenericSubEntry;
                       mainObjRoot:GDBObjRoot;(*saved_to_shd*)
                       LayerTable:GDBLayerArray;(*saved_to_shd*)
                       ConstructObjRoot:GDBObjRoot;
                       SelObjArray:GDBSelectedObjArray;
                       pcamera:PGDBObjCamera;
                       OnMouseObj:GDBObjOpenArrayOfPV;
                       DWGUnits:TUnitManager;

                       OGLwindow1:toglwnd;

                       TextStyleTable:GDBTextStyleArray;(*saved_to_shd*)
                       BlockDefArray:GDBObjBlockdefArray;(*saved_to_shd*)
                       Numerator:GDBNumerator;(*saved_to_shd*)
                       TableStyleTable:GDBTableStyleArray;(*saved_to_shd*)

                       function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
                       constructor init(pcam:PGDBObjCamera);
                 end;
{EXPORT-}
implementation
uses GDBTable,GDBText,GDBDevice,GDBBlockInsert,io,iodxf, GDBManager,shared,commandline,log,OGLSpecFunc;
constructor TAbstractDrawing.init;
var {tp:GDBTextStyleProp;}
    ts:PTGDBTableStyle;
    cs:TGDBTableCellStyle;
begin
  pcamera:=pcam;
  if pcamera=nil then
                     begin
                     GDBGetMem(pcamera, sizeof(GDBObjCamera));
                     pcamera^.initnul;

                       pcamera.fovy:=35.0;
                       pcamera.prop.point.x:=0.0;
                       pcamera.prop.point.y:=0.0;
                       pcamera.prop.point.z:=50.0;
                       pcamera.prop.look.x:=0.0;
                       pcamera.prop.look.y:=0.0;
                       pcamera.prop.look.z:=-1.0;
                       pcamera.prop.ydir.x:=0.0;
                       pcamera.prop.ydir.y:=1.0;
                       pcamera.prop.ydir.z:=0.0;
                       pcamera.prop.xdir.x:=-1.0;
                       pcamera.prop.xdir.y:=0.0;
                       pcamera.prop.xdir.z:=0.0;
                       pcamera.anglx:=-3.14159265359;
                       pcamera.angly:=-1.570796326795;
                       pcamera.zmin:=1.0;
                       pcamera.zmax:=100000.0;
                       pcamera.fovy:=35.0;
                     end;

  LayerTable.init({$IFDEF DEBUGBUILD}'{6AFCB58D-9C9B-4325-A00A-C2E8BDCBE1DD}',{$ENDIF}200);
  mainobjroot.initnul;
  pObjRoot:=@mainobjroot;
  ConstructObjRoot.initnul;
  SelObjArray.init({$IFDEF DEBUGBUILD}'{0CC3A9A3-B9C2-4FB5-BFB1-8791C261C577} - SelObjArray',{$ENDIF}65535);
  OnMouseObj.init({$IFDEF DEBUGBUILD}'{85654C90-FF49-4272-B429-4D134913BC26} - OnMouseObj',{$ENDIF}20);

  //pcamera^.initnul;
  //ConstructObjRoot.init({$IFDEF DEBUGBUILD}'{B1036F20-562D-4B17-A33A-61CF3F5F2A90} - ConstructObjRoot',{$ENDIF}1);

  TextStyleTable.init({$IFDEF DEBUGBUILD}'{146FC836-1490-4046-8B09-863722570C9F}',{$ENDIF}200);
  //tp.size:=2.5;
  //tp.oblique:=0;

  //TextStyleTable.addstyle('Standart','normal.shp',tp);

  //TextStyleTable.addstyle('R2_5','romant.shx',tp);
  //TextStyleTable.addstyle('standart','txt.shx',tp);

  BlockDefArray.init({$IFDEF DEBUGBUILD}'{D53DA395-A6A2-4FDD-842D-A52E6385E2DD}',{$ENDIF}100);
  Numerator.init(10);

  TableStyleTable.init({$IFDEF DEBUGBUILD}'{E5CE9274-01D8-4D19-AF2E-D1AB116B5737}',{$ENDIF}10);

  PTempTableStyle:=TableStyleTable.AddStyle('Temp');

  PTempTableStyle.rowheight:=4;
  PTempTableStyle.textheight:=2.5;

  cs.Width:=1;
  cs.TextWidth:={cf.Width-2}0;
  cs.CF:=TTableCellJustify.jcc;
  PTempTableStyle.tblformat.Add(@cs);

  ts:=TableStyleTable.AddStyle('Standart');

  ts.rowheight:=4;
  ts.textheight:=2.5;

  cs.Width:=20;
  cs.TextWidth:={cf.Width-2}0;
  cs.CF:=jcc;
  ts.tblformat.Add(@cs);

  ts:=TableStyleTable.AddStyle('Spec');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_SPEC_HEAD';

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=130;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={UGDBTableStyleArray.TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=60;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={UGDBTableStyleArray.TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=35;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=45;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=40;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcc;
     ts.tblformat.Add(@cs);

  ts:=TableStyleTable.AddStyle('ShRaspr');

  ts.rowheight:=10;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_PSRS_HEAD';

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=33;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=33;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=17;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=23;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=16;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=12;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=12;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=35;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);




  ts:=TableStyleTable.AddStyle('KZ');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_KZ_HEAD';

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=46;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=46;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=40;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     {cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);}

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     UndoStack.init;

end;

end.
