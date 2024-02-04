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
uses uzgldrawcontext,uzeentabstracttext,uzetrash,uzedrawingdef,uzbstrproc,uzctnrVectorBytes,
     uzestylestables,uzeentline,uzeentcomplex,sysutils,gzctnrVectorPObjects,
     uzctnrvectorstrings,uzeentmtext,uzeentity,uzbtypes,uzeconsts,uzegeometry,
     gzctnrVectorTypes,uzegeometrytypes,uzeentblockinsert,uzeffdxfsupport;
//jcm(*'TopMiddle'*),
type
{TTableCellJustify=(jcl(*'TopLeft'*),
              jcc(*'TopCenter'*),
              jcr(*'TopRight'*));}

{EXPORT+}
PTGDBTableItemFormat=^TGDBTableItemFormat;
{REGISTERRECORDTYPE TGDBTableItemFormat}
TGDBTableItemFormat=record
                 Width,TextWidth:Double;
                 CF:TTableCellJustify;
                end;
PGDBTableArray=^GDBTableArray;
{REGISTEROBJECTTYPE GDBTableArray}
GDBTableArray= object(GZVectorPObects{-}<PTZctnrVectorStrings,TZctnrVectorStrings>{//})(*OpenArrayOfData=TZctnrVectorStrings*)
              end;
PGDBObjTable=^GDBObjTable;
{REGISTEROBJECTTYPE GDBObjTable}
GDBObjTable= object(GDBObjComplex)
            PTableStyle:PTGDBTableStyle;
            tbl:GDBTableArray;
            w,h:Double;
            scale:Double;
            constructor initnul;
            destructor done;virtual;
            function Clone(own:Pointer):PGDBObjEntity;virtual;
            procedure Build(var drawing:TDrawingDef);virtual;
            procedure SaveToDXFFollow(var outhandle:{Integer}TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
            procedure ReCalcFromObjMatrix;virtual;
            function GetObjType:TObjID;virtual;
            end;
{EXPORT-}
implementation
procedure GDBObjTable.ReCalcFromObjMatrix;
//var
    //ox:gdbvertex;
begin
     inherited;
     Local.basis.ox:=PGDBVertex(@objmatrix[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix[1])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     Local.P_insert:=PGDBVertex(@objmatrix[3])^;

     {if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    ox:=CrossVertex(ZWCS,Local.basis.oz);}
end;
procedure GDBObjTable.SaveToDXFFollow;
var
  //i:Integer;
  p:pointer;
  pv,pvc,pvc2:pgdbobjEntity;
  ir:itrec;
  m4:DMatrix4D;
  DC:TDrawContext;
begin
     //historyoutstr('Table DXFOut self='+inttohex(LongWord(@self),10)+' owner'+inttohex(bp.owner.gethandle,10));
     inherited;
     m4:={self.ObjMatrix; //}getmatrix^;
     //MatrixInvert(m4);
     dc:=drawing.CreateDrawingRC;
     pv:=ConstObjArray.beginiterate(ir);
     if pv<>nil then
     repeat
         pvc:=pv^.Clone(@self{.bp.Owner});
         pvc2:=pv^.Clone(@self{.bp.Owner});
         //historyoutstr(pv^.ObjToString('','')+'  cloned obj='+pvc^.ObjToString('',''));
//         if pvc^.GetObjType=GDBDeviceID then
//            pvc:=pvc;

         pvc^.bp.ListPos.Owner:=@self;
         self.ObjMatrix:=onematrix;
         if pvc^.IsHaveLCS then
                               pvc^.FormatEntity(drawing,dc);
         pvc^.transform(m4);
         pvc^.FormatEntity(drawing,dc);

         if bp.ListPos.Owner<>@GDBTrash then
                                    pvc^.bp.ListPos.Owner:=drawing.GetCurrentRootSimple// gdb.GetCurrentROOT //@GDBTrash;
                                else
                                    pvc^.bp.ListPos.Owner:=@GDBTrash;


         //pvc^.DXFOut(handle, outhandle);
              pv.rtsave(pvc2);
              pvc.rtsave(pv);
              p:=pv^.bp.ListPos.Owner;
              pv^.bp.ListPos.Owner:=@GDBTrash;
              //pvc^.SaveToDXF(outhandle,drawing,IODXFContext);
              //pvc^.SaveToDXFPostProcess(outhandle,IODXFContext);
              //pvc^.SaveToDXFFollow(outhandle,drawing,IODXFContext);
              pv^.SaveToDXF(outhandle,drawing,IODXFContext);
              pv^.SaveToDXFPostProcess(outhandle,IODXFContext);
              pv^.SaveToDXFFollow(outhandle,drawing,IODXFContext);
              pvc2.rtsave(pv);
              pv^.bp.ListPos.Owner:=p;


         pvc^.done;
         Freemem(pointer(pvc));
         pvc2^.done;
         Freemem(pointer(pvc2));
         pv:=ConstObjArray.iterate(ir);
     until pv=nil;
     objmatrix:=m4;
     //historyout('Device DXFOut end');
     //self.CalcObjMatrix;
end;
function GDBObjTable.Clone;
var tvo: PGDBObjTable;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjTable));
  tvo^.initnul;
  //tbl.copyto(@tvo^.tbl);

  tvo^.PTableStyle:=PTableStyle;
  tvo^.w:=w;
  tvo^.h:=h;

  //tvo^.vp.id := GDBTableID;
  //tvo^.vp.layer :=vp.layer;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.bp.ListPos.Owner:=own;
  tvo^.scale:=scale;
  result := tvo;
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
   //cf:TGDBTableItemFormat;
   pcf:PTGDBTableItemFormat;
   x{,y},xw:Double;
   xcount,xcurrcount,ycount,ycurrcount,ccount:integer;
   DC:TDrawContext;
begin

ConstObjArray.free;

     psa:=tbl.beginiterate(ir);
     ccount:=0;
     xcount:=0;
     xw:=0;
     dc:=drawing.CreateDrawingRC;
     if psa<>nil then
     begin
          repeat
                x:=0;
                ycount:=0;
                //ycurrcount:=0;
                xcurrcount:=0;
                pcf:=PTableStyle^.tblformat.beginiterate(icf);
                pstr:=psa.beginiterate(ic);
                if pstr<>nil then
                begin
                     repeat
                           ycurrcount:=1;
                           inc(xcurrcount);
                           if pstr^<>'' then
                           begin
                           pointer(pgdbmtext):=self.ConstObjArray.CreateInitObj(GDBMtextID,@self);
                           pgdbmtext.Template:=UTF8ToString(Tria_AnsiToUtf8(pstr^));
                           pgdbmtext.textprop.size:=PTableStyle^.textheight*scale;
                           pgdbmtext.linespacef:=1;
                           pgdbmtext.linespacef:=PTableStyle^.rowheight/pgdbmtext.textprop.size*3/5;
                           pgdbmtext.width:=pcf^.TextWidth*scale;
                           //pgdbmtext.vp.Layer:=vp.Layer;
                           CopyVPto(pgdbmtext^);
                           pgdbmtext.TXTStyleIndex:=pointer(drawing.GetTextStyleTable^.getDataMutable(0));

                           pgdbmtext.Local.P_insert.y:=(-ccount*PTableStyle^.rowheight-PTableStyle^.rowheight/4)*scale;
                           case pcf^.CF of
                                          jcl:begin
                                                   pgdbmtext.textprop.justify:=jstl;
                                                   pgdbmtext.Local.P_insert.x:=(x+scale);
                                              end;
                                          jcc:begin
                                                   pgdbmtext.textprop.justify:=jstc;
                                                   pgdbmtext.Local.P_insert.x:=(x+pcf^.Width/2*scale);
                                              end;
                                          jcr:begin
                                                   pgdbmtext.textprop.justify:=jstr;
                                                   pgdbmtext.Local.P_insert.x:=(x-scale)+pcf^.Width*scale;
                                              end;
                           end;
                           pgdbmtext.FormatEntity(drawing,dc);
                           ycurrcount:=pgdbmtext^.text.Count;
                           end;
                           if ycurrcount>ycount then
                                                    ycount:=ycurrcount;

                                                      {pointer(pl):=self.ConstObjArray.CreateInitObj(GDBLineID,@self);
                           pl^.CoordInOCS.lBegin.x:=x;
                           pl^.CoordInOCS.lBegin.y:=-ccount*rowheight;
                           pl^.CoordInOCS.lEnd.x:=x;
                           pl^.CoordInOCS.lEnd.y:=-(ccount+ycount)*rowheight;
                           pl^.Format;}


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
     for i := 0 to {ycount -1}ccount do
           begin
           pointer(pl):=self.ConstObjArray.CreateInitObj(GDBLineID,@self);
           pl^.CoordInOCS.lBegin.x:=0;
           pl^.CoordInOCS.lBegin.y:=-({ccount+}i)*PTableStyle^.rowheight*scale;
           pl^.CoordInOCS.lEnd.x:=xw{*scale};
           pl^.CoordInOCS.lEnd.y:=-({ccount+}i)*PTableStyle^.rowheight*scale;
           //pl^.vp.Layer:=vp.Layer;
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
           pl^.CoordInOCS.lEnd.y:=-(ccount)*PTableStyle^.rowheight*scale;
           //pl^.vp.Layer:=vp.Layer;
           CopyVPto(pl^);
           pl^.FormatEntity(drawing,dc);


           x:=x+pcf^.Width;
           pcf:=PTableStyle^.tblformat.iterate(icf);
                           if pcf=nil then
                                          pcf:=PTableStyle^.tblformat.beginiterate(icf);

           dec(xcount);
     until xcount=0;

     pointer(pl):=self.ConstObjArray.CreateInitObj(GDBLineID,@self);
     pl^.CoordInOCS.lBegin.x:=x*scale;
     pl^.CoordInOCS.lBegin.y:=0;
     pl^.CoordInOCS.lEnd.x:=x*scale;
     pl^.CoordInOCS.lEnd.y:=-(ccount)*PTableStyle^.rowheight*scale;
     //pl^.vp.Layer:=vp.Layer;
     CopyVPto(pl^);
     pl^.FormatEntity(drawing,dc);

     h:=(ccount)*PTableStyle^.rowheight*scale;
     w:=x*scale;
     if self.PTableStyle.HeadBlockName<>'' then
     begin
          //GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG@drawing,PTableStyle.HeadBlockName);
          drawing.AddBlockFromDBIfNeed(PTableStyle.HeadBlockName);
          pointer(pgdbins):=self.ConstObjArray.CreateInitObj(GDBBlockInsertID,@self);
          pgdbins^.name:=self.PTableStyle.HeadBlockName;
          pgdbins^.scale.x:=scale;
          pgdbins^.scale.y:=scale;
          pgdbins^.scale.z:=scale;
          //pgdbins^.vp.Layer:=vp.Layer;
          CopyVPto(pgdbins^);
          pgdbins^.BuildGeometry(drawing);
     end;
     BuildGeometry(drawing);
end;
constructor GDBObjTable.initnul;
//var
   //pl:pgdbobjline;
   //pgdbmtext:pgdbobjmtext;
   //i:integer;
   //ir,ic,icf:itrec;
   //psa:PTZctnrVectorStrings;
   //pstr:pString;
   //cf:TGDBTableItemFormat;
   //pcf:PTGDBTableItemFormat;
   //x,y:Double;
   //xcount,xcurrcount,ycount,ycurrcount,ccount:integer;
begin
     inherited;
     //vp.ID:=GDBTableID;

     tbl.init(20);
     //ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('Standart');{проверить}
     scale:=1;

     //build();


     //tblformat.init(25,sizeof(TGDBTableItemFormat));

end;
function GDBObjTable.GetObjType;
begin
     result:=GDBTableID;
end;
destructor GDBObjTable.done;
begin
     inherited done;
     {generics containers}//tbl.freeandsubfree; //TODO:чистить...чистить...
     tbl.done;
end;
begin
end.
