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
unit uzeEntTable;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzgldrawcontext,uzeentabstracttext,uzetrash,uzedrawingdef,uzbstrproc,
  uzctnrVectorBytesStream,uzestylestables,uzeentline,uzeentcomplex,SysUtils,
  gzctnrVectorPObjects,uzctnrvectorstrings,uzeentmtext,uzeentity,
  uzeTypes,uzeconsts,uzegeometry,gzctnrVectorTypes,uzegeometrytypes,
  uzeentblockinsert,uzeffdxfsupport,uzeentityfactory,uzeobjectextender,uzsbVarmanDef,
  Varman,uzeentsubordinated;

type

  PTGDBTableItemFormat=^TGDBTableItemFormat;

  TGDBTableItemFormat=record
    Width,TextWidth:double;
    CF:TTableCellJustify;
  end;
  PGDBTableArray=^GDBTableArray;

  GDBTableArray=object(GZVectorPObects<PTZctnrVectorStrings,TZctnrVectorStrings>)
  end;
  PGDBObjTable=^GDBObjTable;

  GDBObjTable=object(GDBObjComplex)
  private
    w,h:double;
  public
    PTableStyle:PTGDBTableStyle;
    tbl:GDBTableArray;
    scale:double;
    constructor initnul;
    destructor done;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function IsStagedFormatEntity:boolean;virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure Build(var drawing:TDrawingDef);virtual;
    procedure BuildGeometry(var drawing:TDrawingDef);virtual;
    procedure DXFOut(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure SaveToDXFFollow(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure AdditionalPostProcess(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext;AData:PtrUInt);
    procedure DXFLoadAddMi(var pobj:PGDBObjSubordinated);virtual;
    function DXFLoadTryMi(ptu:PExtensionData;var pobj:PGDBObjSubordinated):DXFLoadTryMiResult;virtual;
    function DXFDelayedBuildGeometry:boolean;virtual;
    procedure ReCalcFromObjMatrix;virtual;
    function GetObjType:TObjID;virtual;
    procedure SaveToDXFObjXData(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext);virtual;

    class function GetDXFIOFeatures:TDXFEntIODataManager;static;

    property Width:double read w;
    property Height:double read h;
  end;

implementation

type
  TTblIterData=record
    psa:PTZctnrVectorStrings;
    pstr:pString;
    ir1,ir2:itrec;
  end;
  PTTblIterData=^TTblIterData;

var
  GDBObjTableDXFFeatures:TDXFEntIODataManager;

procedure GDBObjTable.ReCalcFromObjMatrix;
begin
  inherited;
  Local.basis.ox:=PzePoint3d(@objmatrix.mtr.v[0])^;
  Local.basis.oy:=PzePoint3d(@objmatrix.mtr.v[1])^;

  Local.basis.ox:=normalizevertex(Local.basis.ox);
  Local.basis.oy:=normalizevertex(Local.basis.oy);
  Local.basis.oz:=normalizevertex(Local.basis.oz);

  Local.P_insert:=PzePoint3d(@objmatrix.mtr.v[3])^;
end;

function GDBObjTable.DXFDelayedBuildGeometry:boolean;
begin
  Result:=true;
end;

procedure GDBObjTable.DXFLoadAddMi(var pobj:PGDBObjSubordinated);
begin
  pobj:=pobj;
  //pobj:=nil;
end;

function GDBObjTable.DXFLoadTryMi(ptu:PExtensionData;var pobj:PGDBObjSubordinated):DXFLoadTryMiResult;
var
  row,col:integer;
  &val:string;
  pvd:pvardesk;
  pvs:PTZctnrVectorStrings;
begin
  Result:=TR_NeedTrash;
  if ptu<>nil then begin
    pvd:=PTUnit(ptu).FindVariable('row');
    if pvd<>nil then
      row:=PInteger(pvd^.data.Addr.Instance)^
    else
      exit;
    pvd:=PTUnit(ptu).FindVariable('col');
    if pvd<>nil then
      col:=PInteger(pvd^.data.Addr.Instance)^
    else
      exit;
    pvd:=PTUnit(ptu).FindVariable('val');
    if pvd<>nil then
      &val:=pvd^.GetValueAsString
    else
      exit;
    if tbl.Count-1<row then begin
      while tbl.Count-1<row do begin
        pvs:=tbl.CreateObject;
        pvs.init(10);
      end;
    end else begin
      pvs:=tbl.getDataMutable(row);
    end;

    while pvs.Count-1<col do
      pvs^.PushBackData('');

    pvs^.getDataMutable(col)^:=val;
  end;

end;


procedure gotoNext(var tbl:GDBTableArray; var irstring:TTblIterData;next,notEmpty:boolean);
begin
  if next then begin
    if irstring.psa<>nil then
      irstring.pstr:=irstring.psa.iterate(irstring.ir2);
    if irstring.pstr=nil then begin
      irstring.psa:=tbl.iterate(irstring.ir1);
      if irstring.psa<>nil then
        irstring.pstr:=irstring.psa.beginiterate(irstring.ir2);
    end;
  end;
  if notEmpty then
    while (not((irstring.pstr<>nil) and (irstring.pstr^<>'')))and(irstring.psa<>nil) do begin
    if irstring.psa<>nil then
      irstring.pstr:=irstring.psa.iterate(irstring.ir2);
    if irstring.pstr=nil then begin
      irstring.psa:=tbl.iterate(irstring.ir1);
      if irstring.psa<>nil then
        irstring.pstr:=irstring.psa.beginiterate(irstring.ir2);
    end;
  end;
end;

procedure GDBObjTable.SaveToDXFFollow;
var
  p:pointer;
  pv,pvc,pvc2:pgdbobjEntity;
  ir:itrec;

  irstring:TTblIterData;

  m4:TzeTypedMatrix4d;
  DC:TDrawContext;
  first:boolean;
  PBlockInsert:pointer;
begin
  inherited;
  first:=true;
  PBlockInsert:=nil;
  m4:=getmatrix^;
  dc:=drawing.CreateDrawingRC;

  irstring.psa:=tbl.beginiterate(irstring.ir1);
  if irstring.psa<>nil then
    irstring.pstr:=irstring.psa.beginiterate(irstring.ir2);
  gotoNext(tbl,irstring,false,true);


  pv:=ConstObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      pvc:=pv^.Clone(@self);
      pvc2:=pv^.Clone(@self);
      pvc^.bp.ListPos.Owner:=@self;
      self.ObjMatrix:=onematrix;
      if pvc^.IsHaveLCS then
        pvc^.FormatEntity(drawing,dc);
      pvc^.transform(m4);
      pvc^.FormatEntity(drawing,dc);

      if bp.ListPos.Owner<>@GDBTrash then
        pvc^.bp.ListPos.Owner:=
          drawing.GetCurrentRootSimple
      else
        pvc^.bp.ListPos.Owner:=@GDBTrash;
      pv.rtsave(pvc2);
      pvc.rtsave(pv);
      p:=pv^.bp.ListPos.Owner;
      if PBlockInsert=nil then
        pv^.bp.ListPos.Owner:=@GDBTrash
      else
        pv^.bp.ListPos.Owner:=@self;

      if first then begin
        first:=false;
        if (self.PTableStyle.HeadBlockName<>'')and(pv^.GetObjType=GDBBlockInsertID) then begin
          pv^.SaveToDXF(outStream,drawing,IODXFContext);
          PBlockInsert:=pv;
          SaveToDXFPostProcess(outStream,IODXFContext);
          pv^.SaveToDXFFollow(outStream,drawing,IODXFContext);
        end;
      end else begin
        pv^.SaveToDXF(outStream,drawing,IODXFContext);
        pv^.SaveToDXFPostProcess(outStream,IODXFContext,AdditionalPostProcess,PtrUInt(@irstring));
        pv^.SaveToDXFFollow(outStream,drawing,IODXFContext);
      end;

      pvc2.rtsave(pv);
      pv^.bp.ListPos.Owner:=p;


      pvc^.done;
      Freemem(pointer(pvc));
      pvc2^.done;
      Freemem(pointer(pvc2));
      pv:=ConstObjArray.iterate(ir);
    until pv=nil;
  objmatrix:=m4;
end;

procedure GDBObjTable.AdditionalPostProcess(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext;AData:PtrUInt);
begin
  AData:=AData;
  if PTTblIterData(AData).pstr<>nil then
    if PTTblIterData(AData).pstr^<>'' then begin
      dxfStringout(outStream,1000,'%999=row|integer|'+IntToStr(PTTblIterData(AData).ir1.itc)+'|');
      dxfStringout(outStream,1000,'%999=col|integer|'+IntToStr(PTTblIterData(AData).ir2.itc)+'|');
      dxfStringout(outStream,1000,'%999=val|string|'+PTTblIterData(AData).pstr^+'|');
    end;
  gotoNext(tbl,PTTblIterData(AData)^,true,true);
end;

procedure GDBObjTable.DXFOut;
begin
     SaveToDXF(outStream,drawing,IODXFContext);
     //SaveToDXFPostProcess(outStream);
     SaveToDXFFollow(outStream,drawing,IODXFContext);
end;


procedure GDBObjTable.SaveToDXFObjXData;
begin
  if PTableStyle<>nil then
    dxfStringout(outStream,1000,'%1=style|String|'+PTableStyle.Name+'|');
  dxfStringout(outStream,1000,'_HANDLE='+inttohex(GetHandle,10));
  dxfStringout(outStream,1000,'_UPGRADE='+inttostr(UD_BlockInsertToTable));
  GetDXFIOFeatures.RunSaveFeatures(outStream,@self,IODXFContext);
  inherited;
end;


function GDBObjTable.Clone;
var
  tvo:PGDBObjTable;
  i:integer;
  pvs:PTZctnrVectorStrings;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjTable));
  tvo^.initnul;
  for i:=0 to tbl.Count-1 do begin
    pvs:=tvo^.tbl.CreateObject;
    pvs^.initnul;
    tbl.getDataMutable(i).copyto(pvs^);
  end;
  tvo^.PTableStyle:=PTableStyle;
  tvo^.w:=w;
  tvo^.h:=h;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local.p_insert:=Local.p_insert;
  tvo^.Local:=Local;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.scale:=scale;
  Result:=tvo;
end;

procedure GDBObjTable.BuildGeometry(var drawing:TDrawingDef);
begin
  Build(drawing);
end;

function GDBObjTable.IsStagedFormatEntity:boolean;
begin
  Result:=True;
end;

procedure GDBObjTable.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if EFCalcEntityCS in stage then begin
    if assigned(EntExtensions) then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
    calcobjmatrix;
    //ConstObjArray.FormatEntity(drawing,dc);
    calcbb(dc);
  end;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin
    self.BuildGeometry(drawing);
      if assigned(EntExtensions) then
        EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;

procedure GDBObjTable.Build;
var
  pl:pgdbobjline;
  pgdbmtext:pgdbobjmtext;
  pgdbins:pgdbobjblockinsert;
  i:integer;
  ir,ic,icf:itrec;
  psa:PTZctnrVectorStrings;
  pstr:pString;
  pcf:PTGDBTableItemFormat;
  x,xw:double;
  xcount,xcurrcount,ycount,ycurrcount,ccount:integer;
  DC:TDrawContext;
begin
  ConstObjArray.Free;
  psa:=tbl.beginiterate(ir);
  ccount:=0;
  xcount:=0;
  xw:=0;
  dc:=drawing.CreateDrawingRC;

  if self.PTableStyle.HeadBlockName<>'' then begin
    drawing.AddBlockFromDBIfNeed(PTableStyle.HeadBlockName);
    pointer(pgdbins):=self.ConstObjArray.CreateInitObj(GDBBlockInsertID,@self);
    pgdbins^.Name:=self.PTableStyle.HeadBlockName;
    pgdbins^.scale.x:=scale;
    pgdbins^.scale.y:=scale;
    pgdbins^.scale.z:=scale;
    CopyVPto(pgdbins^);
    pgdbins^.BuildGeometry(drawing);
  end;

  if psa<>nil then begin
    repeat
      x:=0;
      ycount:=0;
      xcurrcount:=0;
      pcf:=PTableStyle^.tblformat.beginiterate(icf);
      pstr:=psa.beginiterate(ic);
      if pstr<>nil then begin
        repeat
          ycurrcount:=1;
          Inc(xcurrcount);
          if pstr^<>'' then begin
            pointer(pgdbmtext):=
              self.ConstObjArray.CreateInitObj(GDBMtextID,@self);
            pgdbmtext.Template:=UTF8ToString({Tria_AnsiToUtf8}(pstr^));
            pgdbmtext.textprop.size:=PTableStyle^.textheight*scale;
            pgdbmtext.linespacef:=1;
            pgdbmtext.linespacef:=
              PTableStyle^.rowheight/pgdbmtext.textprop.size*3/5;
            pgdbmtext.Width:=pcf^.TextWidth*scale;
            CopyVPto(pgdbmtext^);
            pgdbmtext.TXTStyle:=
              pointer(drawing.GetTextStyleTable^.getDataMutable(0));

            pgdbmtext.Local.P_insert.y:=
              (-ccount*PTableStyle^.rowheight-PTableStyle^.rowheight/4)*scale;
            case pcf^.CF of
              jcl:begin
                pgdbmtext.textprop.justify:=jstl;
                pgdbmtext.Local.P_insert.x:=(x+scale);
              end;
              jcc:begin
                pgdbmtext.textprop.justify:=jstc;
                pgdbmtext.Local.P_insert.x:=
                  (x+pcf^.Width/2*scale);
              end;
              jcr:begin
                pgdbmtext.textprop.justify:=jstr;
                pgdbmtext.Local.P_insert.x:=
                  (x-scale)+pcf^.Width*scale;
              end;
            end;
            pgdbmtext.FormatEntity(drawing,dc);
            ycurrcount:=pgdbmtext^.Text.Count;
          end;
          if ycurrcount>ycount then
            ycount:=ycurrcount;
          x:=x+pcf^.Width*scale;
          pcf:=PTableStyle^.tblformat.iterate(icf);
          if pcf=nil then
            pcf:=PTableStyle^.tblformat.beginiterate(icf);
          pstr:=psa.iterate(ic);
        until pstr=nil;

        if xcurrcount>xcount then
          xcount:=xcurrcount;
        if xw<x then
          xw:=x;

        ccount:=ccount+ycount;
      end;
      psa:=tbl.iterate(ir);
    until psa=nil;
  end;
  for i:=0 to ccount do begin
    pointer(pl):=self.ConstObjArray.CreateInitObj(GDBLineID,@self);
    pl^.CoordInOCS.lBegin.x:=0;
    pl^.CoordInOCS.lBegin.y:=-i*PTableStyle^.rowheight*scale;
    pl^.CoordInOCS.lEnd.x:=xw;
    pl^.CoordInOCS.lEnd.y:=-i*PTableStyle^.rowheight*scale;
    CopyVPto(pl^);
    pl^.FormatEntity(drawing,dc);
  end;
  if xcount<PTableStyle^.tblformat.Count then
    xcount:=PTableStyle^.tblformat.Count;
  x:=0;
  pcf:=PTableStyle^.tblformat.beginiterate(icf);
  if xcount>0 then
    repeat
      pointer(pl):=self.ConstObjArray.CreateInitObj(GDBLineID,@self);
      pl^.CoordInOCS.lBegin.x:=x*scale;
      pl^.CoordInOCS.lBegin.y:=0;
      pl^.CoordInOCS.lEnd.x:=x*scale;
      pl^.CoordInOCS.lEnd.y:=-ccount*PTableStyle^.rowheight*scale;
      CopyVPto(pl^);
      pl^.FormatEntity(drawing,dc);


      x:=x+pcf^.Width;
      pcf:=PTableStyle^.tblformat.iterate(icf);
      if pcf=nil then
        pcf:=PTableStyle^.tblformat.beginiterate(icf);

      Dec(xcount);
    until xcount=0;

  pointer(pl):=self.ConstObjArray.CreateInitObj(GDBLineID,@self);
  pl^.CoordInOCS.lBegin.x:=x*scale;
  pl^.CoordInOCS.lBegin.y:=0;
  pl^.CoordInOCS.lEnd.x:=x*scale;
  pl^.CoordInOCS.lEnd.y:=-ccount*PTableStyle^.rowheight*scale;
  CopyVPto(pl^);
  pl^.FormatEntity(drawing,dc);

  h:=ccount*PTableStyle^.rowheight*scale;
  w:=x*scale;
  inherited BuildGeometry(drawing);
end;

constructor GDBObjTable.initnul;
begin
  inherited;
  tbl.init(20);
  scale:=1;
end;

function GDBObjTable.GetObjType;
begin
  Result:=GDBTableID;
end;

destructor GDBObjTable.done;
begin
  inherited done;
  tbl.done;
end;

class function GDBObjTable.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjTableDXFFeatures;
end;

function UpgradeBlockInsert2Table(ptu:PExtensionData;pent:PGDBObjBlockInsert;const drawing:TDrawingDef):PGDBObjTable;
var
  pvd:pvardesk;
begin

  Getmem(result,sizeof(GDBObjTable));
  result^.initnul;
  pent.CopyVPto(Result^);
  Result^.Local:=pent^.local;
  Result^.P_insert_in_WCS:=pent^.P_insert_in_WCS;

  if pent^.PExtAttrib<>nil then
    Result^.PExtAttrib:=pent^.CopyExtAttrib;

  pvd:=PTUnit(ptu).FindVariable('style');
  if pvd<>nil then begin
    result^.PTableStyle:=drawing.GetTableStyleTable.AddStyle(pvd.GetValueAsString);
    pvd^.GetValueAsString;
  end;

end;


initialization
  RegisterEntity(GDBTableID,'Table',nil,nil);
  RegisterEntityUpgradeInfo(GDBBlockInsertID,UD_BlockInsertToTable,@UpgradeBlockInsert2Table);
  GDBObjTableDXFFeatures:=TDXFEntIODataManager.create;
finalization
  GDBObjTableDXFFeatures.destroy;
end.
