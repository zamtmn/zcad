{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
{$MODE OBJFPC}{$H+}
unit uzccommand_blockpreviewexport;
{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  LCLType,LCLIntf,uzcLog,Graphics,

  uzgldrawercanvas,uzerasterizer,uzglviewareageneral,
  uzgldrawcontext,
  uzedrawingsimple,uzcdrawings,
  uzcsysvars,
  uzccommandsabstract,
  uzccommandsimpl,
  uzbtypes,
  uzeutils,uzcutils,
  uzcinterface,
  uzegeometrytypes,uzegeometry,
  uzbpaths,
  uzeentdevice,uzeentblockinsert,uzeblockdef,uzeentsubordinated,
  //uzestyleslayers,
  uzeconsts;
function BlockPreViewExport_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
implementation
function BlockPreViewExport_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
const
  scl=3;
var
   cdwg:PTSimpleDrawing;
   pb:PGDBObjBlockInsert;
   tb:PGDBObjSubordinated;
   DC:TDrawContext;
   BMP:TBitmap;
   PNG:TPortableNetworkGraphic;
   PrinterDrawer:TZGLCanvasDrawer;
   PrintParam:TRasterizeParams;
   BlockName,imgsize:AnsiString;
   sx,bmpw:integer;
   tv:GDBvertex;
   SAVEsysvarDISPLWDisplayScale,
   SAVEsysvarDISPmaxLWDisplayScale:integer;
   SAVELWDisplay:boolean;
   //plp:PGDBLayerProp;
   bb{,bb2}:TBoundingBox;
begin
  //пример вызова(РазмерИзображекния|ИмяБлока|Путь)
  //BlockPreViewExport(128|DEVICE_PS_DAT_HAND|*images\palettes)
  //ExecuteFile(*components\blockpreviewexport.cmd)


  GetPartOfPath(imgsize,operands,'|');
  if not TryStrToInt(imgsize,sx) then
    sx:=24;
  bmpw:=scl*sx;
  GetPartOfPath(BlockName,operands,'|');
  cdwg:=drawings.GetCurrentDWG;
  if cdwg<>nil then begin
    SAVEsysvarDISPLWDisplayScale:=sysvarDISPLWDisplayScale;
    SAVEsysvarDISPmaxLWDisplayScale:=sysvarDISPmaxLWDisplayScale;
    SAVELWDisplay:=cdwg^.LWDisplay;
    sysvarDISPmaxLWDisplayScale:=10*scl;
    sysvarDISPLWDisplayScale:=10*scl;
    {plp:=cdwg^.LayerTable.getAddres('SYS_PIN');
    if plp<>nil then
      plp^._on:=false;
    plp:=cdwg^.LayerTable.getAddres('EL_DEVICE_NAME');
    if plp<>nil then
      plp^._on:=false;}
    cdwg^.LWDisplay:=true;
    dc:=cdwg^.CreateDrawingRC;
    drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,BlockName);
    pb := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBBlockInsertID));
    pb^.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
    pb^.Name:=BlockName;
    zcSetEntPropFromCurrentDrawingProp(pb);
    pb^.Local.p_insert:=NulVertex;
    pb^.scale:=ScaleOne;
    pb^.CalcObjMatrix;
    pb^.setrot(0);
    tb:=pb^.FromDXFPostProcessBeforeAdd(nil,cdwg^);
    if tb<>nil then begin
      tb^.bp:=pb^.bp;
      pb^.done;
      Freemem(pointer(pb));
      pb:=pointer(tb);
    end;

    cdwg^.GetCurrentROOT^.GoodAddObjectToObjArray(pb);

    pb^.FromDXFPostProcessAfterAdd;
    pb^.CalcObjMatrix;
    pb^.BuildGeometry(cdwg^);
    pb^.BuildVarGeometry(cdwg^);
    pb^.FormatEntity(cdwg^,dc);
    drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(pb^);
    cdwg^.ConstructObjRoot.ObjArray.Count := 0;
    pb^.RenderFeedback(cdwg^.pcamera^.POSCOUNT,cdwg^.pcamera^,@cdwg^.myGluProject2,dc);


    PrintParam.FitToPage:=true;
    PrintParam.Center:=false;
    PrintParam.Scale:=1;
    PrintParam.Palette:=PC_Color;


    PNG:=TPortableNetworkGraphic.Create;
    PNG.SetSize(sx,sx);
    PNG.Canvas.Brush.Color:=clWindow;
    PNG.Canvas.Brush.Style:=bsSolid;
    PNG.Canvas.FillRect(0,0,sx,sx);

    BMP:=TBitmap.Create;
    BMP.SetSize(bmpw,bmpw);
    BMP.Canvas.Brush.Color:=clWindow;
    BMP.Canvas.Brush.Style:=bsSolid;
    BMP.Canvas.FillRect(0,0,bmpw,bmpw);

    PrinterDrawer:=TZGLCanvasDrawer.create;
    try
      //bb:=pb^.vp.BoundingBox;
      bb:=pb^.getonlyvisibleoutbound(dc);
      {bb:=pb^.ConstObjArray.getonlyvisibleoutbound(dc);
      if IsIt(typeof(pb^),typeof(GDBObjDevice)) then begin
        bb2:=PGDBObjDevice(pb)^.VarObjArray.getonlyvisibleoutbound(dc);
        if bb2.RTF.x>=bb2.LBN.x then
          ConcatBB(bb,bb2);
      end;}
      tv:=VertexSub(bb.RTF,bb.LBN);
      tv:=VertexMulOnSc(tv,0.15);
      rasterize(cdwg,bmpw,bmpw,VertexSub(bb.LBN,tv),VertexAdd(bb.RTF,tv),PrintParam,bmp.Canvas,PrinterDrawer);

      //PNG.Canvas.StretchDraw(Rect(0,0,bmpw,bmpw),bmp);

      SetStretchBltMode(PNG.Canvas.Handle, HALFTONE);
      StretchBlt(PNG.Canvas.Handle, 0, 0, PNG.Width, PNG.Height,
                 bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, SRCCOPY);

      cdwg^.GetCurrentROOT^.GoodRemoveMiFromArray(pb,cdwg^);
      ForceDirectories(ExtractFileDir(ExpandPath(operands)));
      PNG.SaveToFile(ExpandPath(operands));

    finally
      sysvarDISPLWDisplayScale:=SAVEsysvarDISPLWDisplayScale;
      sysvarDISPmaxLWDisplayScale:=SAVEsysvarDISPmaxLWDisplayScale;
      cdwg^.LWDisplay:=SAVELWDisplay;
      PNG.Free;
      BMP.Free;
      PrinterDrawer.Free;
      zcRedrawCurrentDrawing;
      result:=cmd_ok;
    end;
  end else begin
    ZCMsgCallBackInterface.TextMessage('No current drawing???',TMWOSilentShowError);
    result:=cmd_error;
  end;
end;
initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@BlockPreViewExport_com,'BlockPreViewExport',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
