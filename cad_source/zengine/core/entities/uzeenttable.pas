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
unit uzeenttable;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzgldrawcontext,uzeentabstracttext,uzetrash,uzedrawingdef,uzbstrproc,
  uzctnrVectorBytesStream,uzestylestables,uzeentline,uzeentcomplex,SysUtils,
  gzctnrVectorPObjects,uzctnrvectorstrings,uzeentmtext,uzeentity,
  uzeTypes,uzeconsts,uzegeometry,gzctnrVectorTypes,uzegeometrytypes,
  uzeentblockinsert,uzeffdxfsupport;

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
    PTableStyle:PTGDBTableStyle;
    tbl:GDBTableArray;
    w,h:double;
    scale:double;
    constructor initnul;
    destructor done;virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure Build(var drawing:TDrawingDef);virtual;
    procedure SaveToDXFFollow(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure ReCalcFromObjMatrix;virtual;
    function GetObjType:TObjID;virtual;
  end;

implementation

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

procedure GDBObjTable.SaveToDXFFollow;
var
  p:pointer;
  pv,pvc,pvc2:pgdbobjEntity;
  ir:itrec;
  m4:TzeTypedMatrix4d;
  DC:TDrawContext;
begin
  inherited;
  m4:=getmatrix^;
  dc:=drawing.CreateDrawingRC;
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
      pv^.bp.ListPos.Owner:=@GDBTrash;
      pv^.SaveToDXF(outStream,drawing,IODXFContext);
      pv^.SaveToDXFPostProcess(outStream,IODXFContext);
      pv^.SaveToDXFFollow(outStream,drawing,IODXFContext);
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

function GDBObjTable.Clone;
var
  tvo:PGDBObjTable;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjTable));
  tvo^.initnul;
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
  BuildGeometry(drawing);
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

begin
end.
