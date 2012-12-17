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

unit GDBTable;
{$INCLUDE def.inc}

interface
uses ugdbtrash,ugdbdrawingdef,strproc,UGDBOpenArrayOfByte,UGDBTableStyleArray,GDBLine{,math},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils,UGDBTable,UGDBStringArray,GDBMTEXT{,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,UGDBSelectedObjArray,UGDBVisibleOpenArray,}gdbEntity{,varman,varmandef},
GDBase{,UGDBDescriptor}{,GDBWithLocalCS},gdbobjectsconstdef{,oglwindowdef},geometry,dxflow,memman{,GDBSubordinated,UGDBOpenArrayOfByte};
//jcm(*'TopMiddle'*),
type
{TTableCellJustify=(jcl(*'TopLeft'*),
              jcc(*'TopCenter'*),
              jcr(*'TopRight'*));}

{EXPORT+}
PTGDBTableItemFormat=^TGDBTableItemFormat;
TGDBTableItemFormat=record
                 Width,TextWidth:GDBDouble;
                 CF:TTableCellJustify;
                end;
PGDBObjTable=^GDBObjTable;
GDBObjTable=object(GDBObjComplex)
            PTableStyle:PTGDBTableStyle;
            tbl:GDBTableArray;
            w,h:GDBDouble;
            scale:GDBDouble;
            constructor initnul;
            destructor done;virtual;
            function Clone(own:GDBPointer):PGDBObjEntity;virtual;
            procedure Build(const drawing:TDrawingDef);virtual;
            procedure SaveToDXFFollow(var handle:TDWGHandle;var outhandle:{GDBInteger}GDBOpenArrayOfByte;const drawing:TDrawingDef);virtual;
            procedure ReCalcFromObjMatrix;virtual;
            end;
{EXPORT-}
var
  PTempTableStyle:PTGDBTableStyle;
implementation
uses GDBBlockInsert,log;
procedure GDBObjTable.ReCalcFromObjMatrix;
var
    ox:gdbvertex;
begin
     inherited;
     Local.basis.ox:=PGDBVertex(@objmatrix[0])^;
     Local.basis.oy:=PGDBVertex(@objmatrix[1])^;

     Local.basis.ox:=normalizevertex(Local.basis.ox);
     Local.basis.oy:=normalizevertex(Local.basis.oy);
     Local.basis.oz:=normalizevertex(Local.basis.oz);

     Local.P_insert:=PGDBVertex(@objmatrix[3])^;

     if (abs (Local.basis.oz.x) < 1/64) and (abs (Local.basis.oz.y) < 1/64) then
                                                                    ox:=CrossVertex(YWCS,Local.basis.oz)
                                                                else
                                                                    ox:=CrossVertex(ZWCS,Local.basis.oz);
end;
procedure GDBObjTable.SaveToDXFFollow;
var
  //i:GDBInteger;
  pv,pvc:pgdbobjEntity;
  ir:itrec;
  m4:DMatrix4D;
begin
     //historyoutstr('Table DXFOut self='+inttohex(longword(@self),10)+' owner'+inttohex(bp.owner.gethandle,10));
     inherited;
     m4:={self.ObjMatrix; //}getmatrix^;
     //MatrixInvert(m4);
     pv:=ConstObjArray.beginiterate(ir);
     if pv<>nil then
     repeat
         pvc:=pv^.Clone(@self{.bp.Owner});
         //historyoutstr(pv^.ObjToGDBString('','')+'  cloned obj='+pvc^.ObjToGDBString('',''));
         if pvc^.vp.ID=GDBDeviceID then
            pvc:=pvc;

         pvc^.bp.ListPos.Owner:=@self;
         self.ObjMatrix:=onematrix;
         if pvc^.IsHaveLCS then
                               pvc^.FormatEntity(drawing);
         pvc^.transform(m4);
         pvc^.FormatEntity(drawing);

         if bp.ListPos.Owner<>@GDBTrash then
                                    pvc^.bp.ListPos.Owner:=drawing.GetCurrentRootSimple// gdb.GetCurrentROOT //@GDBTrash;
                                else
                                    pvc^.bp.ListPos.Owner:=@GDBTrash;


         //pvc^.DXFOut(handle, outhandle);

              pvc^.SaveToDXF(handle, outhandle,drawing);
              pvc^.SaveToDXFPostProcess(outhandle);
              pvc^.SaveToDXFFollow(handle, outhandle,drawing);


         pvc^.done;
         GDBFREEMEM(pointer(pvc));
         pv:=ConstObjArray.iterate(ir);
     until pv=nil;
     objmatrix:=m4;
     //historyout('Device DXFOut end');
     //self.CalcObjMatrix;
end;
function GDBObjTable.Clone;
var tvo: PGDBObjTable;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjTable));
  tvo^.initnul;
  tbl.copyto(@tvo^.tbl);

  tvo^.PTableStyle:=PTableStyle;
  tvo^.w:=w;
  tvo^.h:=h;

  tvo^.vp.id := GDBTableID;
  //tvo^.vp.layer :=vp.layer;
  CopyVPto(tvo^);
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
   psa:PGDBGDBStringArray;
   pstr:pGDBsTRiNG;
   //cf:TGDBTableItemFormat;
   pcf:PTGDBTableItemFormat;
   x{,y},xw:gdbdouble;
   xcount,xcurrcount,ycount,ycurrcount,ccount:integer;
begin

ConstObjArray.cleareraseobj;

     psa:=tbl.beginiterate(ir);
     ccount:=0;
     xcount:=0;
     xw:=0;
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
                           pgdbmtext.Template:={Tria_Utf8ToAnsi}(pstr^);
                           pgdbmtext.textprop.size:=PTableStyle^.textheight*scale;
                           pgdbmtext.linespacef:=1;
                           pgdbmtext.linespacef:=PTableStyle^.rowheight/pgdbmtext.textprop.size*3/5;
                           pgdbmtext.width:=pcf^.TextWidth*scale;
                           pgdbmtext.vp.Layer:=vp.Layer;

                           pgdbmtext.Local.P_insert.y:=(-ccount*PTableStyle^.rowheight-PTableStyle^.rowheight/4)*scale;
                           case pcf^.CF of
                                          jcl:begin
                                                   pgdbmtext.textprop.justify:=jstl;
                                                   pgdbmtext.Local.P_insert.x:=(x+scale);
                                              end;
                                          jcc:begin
                                                   pgdbmtext.textprop.justify:=jstm;
                                                   pgdbmtext.Local.P_insert.x:=(x+pcf^.Width/2*scale);
                                              end;
                                          jcr:begin
                                                   pgdbmtext.textprop.justify:=jstr;
                                                   pgdbmtext.Local.P_insert.x:=(x-scale)+pcf^.Width*scale;
                                              end;
                           end;
                           pgdbmtext.FormatEntity(drawing);;
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
           pl^.vp.Layer:=vp.Layer;
           pl^.FormatEntity(drawing);;
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
           pl^.vp.Layer:=vp.Layer;
           pl^.FormatEntity(drawing);


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
     pl^.vp.Layer:=vp.Layer;
     pl^.FormatEntity(drawing);

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
          pgdbins^.vp.Layer:=vp.Layer;
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
   //psa:PGDBGDBStringArray;
   //pstr:pGDBsTRiNG;
   //cf:TGDBTableItemFormat;
   //pcf:PTGDBTableItemFormat;
   //x,y:gdbdouble;
   //xcount,xcurrcount,ycount,ycurrcount,ccount:integer;
begin
     inherited;
     vp.ID:=GDBTableID;

     tbl.init({$IFDEF DEBUGBUILD}'{C6EE9076-623F-4D7A-A355-122C6271B9ED}',{$ENDIF}9,20);
     //ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('Standart');{проверить}
     scale:=1;

     //build();


     //tblformat.init({$IFDEF DEBUGBUILD}'{9616C423-CF78-45A4-9244-62F2821332D2}',{$ENDIF}25,sizeof(TGDBTableItemFormat));

end;
destructor GDBObjTable.done;
begin
     inherited done;
     tbl.freeandsubfree; //TODO:чистить...чистить...
     tbl.done;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBTable.initialization');{$ENDIF}
end.
