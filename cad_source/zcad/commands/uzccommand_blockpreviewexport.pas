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
{$MODE OBJFPC}
unit uzccommand_blockpreviewexport;
{$INCLUDE def.inc}

interface
uses
  uzgldrawerabstract,
  uzgldrawercanvas,uzgldrawergdi,uzgldrawergeneral2d,
  uzcoimultiobjects,uzepalette,
  uzgldrawcontext,
  uzeentpoint,uzeentityfactory,
  uzedrawingsimple,uzcsysvars,uzcstrconsts,uzccomdrawdase,
  PrintersDlgs,printers,graphics,uzeentdevice,
  LazUTF8,Clipbrd,LCLType,classes,uzeenttext,
  uzccommandsabstract,uzbstrproc,
  uzbtypesbase,uzccommandsmanager,uzccombase,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzeutils,uzcutils,
  sysutils,
  varmandef,
  uzglviewareadata,
  uzeffdxf,
  uzcinterface,
  uzegeometry,
  uzbmemman,uzbpaths,
  uzbgeomtypes,uzeentity,uzeentcircle,uzeentline,uzeentgenericsubentry,uzeentmtext,
  uzcshared,uzeentblockinsert,uzeentpolyline,uzclog,
  math,zcmultiobjectcreateundocommand,uzcdrawing,
  uzeentsubordinated,uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray
  ,uzelongprocesssupport,LazLogger,uzeiopalette,uzeconsts,uzerasterizer;
implementation
function BlockPreViewExport_com(operands:TCommandOperands):TCommandResult;
//const
  //BlockName='DEVICE_PS_DAT_HAND';
  //sx=64;
var
   cdwg:PTSimpleDrawing;
   pb:PGDBObjBlockInsert;
   tb:PGDBObjSubordinated;
   domethod,undomethod:tmethod;
   DC:TDrawContext;
   BMP:{TBitmap}TPortableNetworkGraphic;
   PrinterDrawer:TZGLGeneral2DDrawer;
   PrintParam:TRasterizeParams;
   BlockName,imgsize:AnsiString;
   sx:integer;
begin //BlockPreViewExport(128|DEVICE_PS_DAT_HAND|*images\palettes)
      //ExecuteFile(*components\blockpreviewexport.cmd)
  GetPartOfPath(imgsize,operands,'|');
  TryStrToInt(imgsize,sx);
  GetPartOfPath(BlockName,operands,'|');
  cdwg:=drawings.GetCurrentDWG;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,BlockName);
  pb := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID));
  pb^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
  pb^.Name:=BlockName;
  zcSetEntPropFromCurrentDrawingProp(pb);
  pb^.Local.p_insert:=NulVertex;
  pb^.scale:=ScaleOne;
  pb^.CalcObjMatrix;
  pb^.setrot(0);
  tb:=pb^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^);
  if tb<>nil then begin
    tb^.bp:=pb^.bp;
    pb^.done;
    gdbfreemem(pointer(pb));
    pb:=pointer(tb);
  end;

  SetObjCreateManipulator(domethod,undomethod);
  with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
  begin
       AddObject(pb);
       comit;
  end;

  //drawings.GetCurrentROOT^.AddObjectToObjArray{ObjArray.add}(addr(pb));
  PGDBObjEntity(pb)^.FromDXFPostProcessAfterAdd;
  pb^.CalcObjMatrix;
  pb^.BuildGeometry(drawings.GetCurrentDWG^);
  pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
  pb^.FormatEntity(drawings.GetCurrentDWG^,dc);
  drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(pb^);
  //pb^.Visible:=0;
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
  pb^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);


  PrintParam.FitToPage:=true;
  PrintParam.Center:=false;
  PrintParam.Scale:=1;
  PrintParam.Palette:=PC_Color;


  BMP:=TPortableNetworkGraphic.Create;
  BMP.SetSize(sx,sx);
  BMP.Canvas.Brush.Color:=graphics.clWhite;
  BMP.Canvas.Brush.Style:=bsSolid;
  BMP.Canvas.FillRect(0,0,sx-1,sx-1);
  PrinterDrawer:=TZGLCanvasDrawer.create;
  rasterize(cdwg,sx,sx,VertexMulOnSc(pb^.vp.BoundingBox.LBN,1.1),VertexMulOnSc(pb^.vp.BoundingBox.RTF,1.1),PrintParam,BMP.Canvas,PrinterDrawer);
  BMP.SaveToFile(ExpandPath(operands)+BlockName+'.png');
  BMP.Free;
  PrinterDrawer.Free;

  zcRedrawCurrentDrawing;

  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

{procedure Print_com.Print(pdata:GDBPlatformint);
 var
  cdwg:PTSimpleDrawing;
  PrinterDrawer:TZGLGeneral2DDrawer;
begin
  cdwg:=drawings.GetCurrentDWG;
  try

    Printer.Title := 'zcadprint';
    Printer.BeginDoc;

    PrinterDrawer:=TZGLCanvasDrawer.create;
    rasterize(cdwg,Printer.PageWidth,Printer.PageHeight,p1,p2,PrintParam,Printer.Canvas,PrinterDrawer);
    PrinterDrawer.Free;

    Printer.EndDoc;

  except
    on E:Exception do
    begin
      Printer.Abort;
      ZCMsgCallBackInterface.TextMessage(e.message,TMWOShowError);
    end;
  end;
  zcRedrawCurrentDrawing;
end;}

procedure startup;
begin
  CreateCommandFastObjectPlugin(@BlockPreViewExport_com,'BlockPreViewExport',0,0);
end;

procedure Finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
