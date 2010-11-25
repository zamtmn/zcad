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
uses UGDBOpenArrayOfByte,UGDBTableStyleArray,GDBLine{,math},gdbasetypes{,GDBGenericSubEntry},GDBComplex,SysInfo,sysutils,UGDBTable,UGDBStringArray,GDBMTEXT{,UGDBOpenArrayOfData},
{UGDBOpenArrayOfPV,UGDBObjBlockdefArray,UGDBSelectedObjArray,UGDBVisibleOpenArray,}gdbEntity{,varman,varmandef},
gl,
GDBase,UGDBDescriptor{,GDBWithLocalCS},gdbobjectsconstdef{,oglwindowdef},geometry,dxflow,memman{,GDBSubordinated,UGDBOpenArrayOfByte};
type
{EXPORT+}
TCellJustify=(jcl(*'ВерхЛево'*),
              jcm(*'ВерхЦентр'*),
              jcr(*'ВерхПраво'*));
PTGDBTableItemFormat=^TGDBTableItemFormat;
TGDBTableItemFormat=record
                 Width,TextWidth:GDBDouble;
                 CF:TCellJustify;
                end;
PGDBObjTable=^GDBObjTable;
GDBObjTable=object(GDBObjComplex)
            PTableStyle:PTGDBTableStyle;
            tbl:GDBTableArray;
            w,h:GDBDouble;
            constructor initnul;
            destructor done;virtual;
            function Clone(own:GDBPointer):PGDBObjEntity;virtual;
            procedure Build;virtual;
            procedure SaveToDXFFollow(var handle:longint;var outhandle:{GDBInteger}GDBOpenArrayOfByte);virtual;
            end;
{EXPORT-}
implementation
uses GDBBlockInsert,log;
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

         pvc^.bp.Owner:=@self;
         pvc^.transform(m4);
         self.ObjMatrix:=onematrix;
         pvc^.Format;

         if bp.Owner<>@GDBTrash then
                                    pvc^.bp.Owner:=gdb.GetCurrentROOT //@GDBTrash;
                                else
                                    pvc^.bp.Owner:=@GDBTrash;


         //pvc^.DXFOut(handle, outhandle);

              pvc^.SaveToDXF(handle, outhandle);
              pvc^.SaveToDXFPostProcess(outhandle);
              pvc^.SaveToDXFFollow(handle, outhandle);


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
  tvo^.vp.layer :=vp.layer;
  tvo^.Local.p_insert := Local.p_insert;
  tvo^.Local := Local;
  tvo^.bp.Owner:=own;
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
                           pgdbmtext.Template:=pstr^;
                           pgdbmtext.textprop.size:=PTableStyle^.textheight;
                           pgdbmtext.linespacef:=1;
                           pgdbmtext.linespacef:=PTableStyle^.rowheight/pgdbmtext.textprop.size*3/5;
                           pgdbmtext.width:=pcf^.TextWidth;

                           pgdbmtext.Local.P_insert.y:=-ccount*PTableStyle^.rowheight-PTableStyle^.rowheight/4;
                           case pcf^.CF of
                                          jcl:begin
                                                   pgdbmtext.textprop.justify:=jstl;
                                                   pgdbmtext.Local.P_insert.x:=x+1;
                                              end;
                                          jcm:begin
                                                   pgdbmtext.textprop.justify:=jstm;
                                                   pgdbmtext.Local.P_insert.x:=x+pcf^.Width/2;
                                              end;
                                          jcr:begin
                                                   pgdbmtext.textprop.justify:=jstr;
                                                   pgdbmtext.Local.P_insert.x:=x+pcf^.Width-1;
                                              end;
                           end;
                           pgdbmtext.Format;
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


                           x:=x+pcf^.Width;
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
           pl^.CoordInOCS.lBegin.y:=-({ccount+}i)*PTableStyle^.rowheight;
           pl^.CoordInOCS.lEnd.x:=xw;
           pl^.CoordInOCS.lEnd.y:=-({ccount+}i)*PTableStyle^.rowheight;
           pl^.Format;
           end;
     if xcount<PTableStyle^.tblformat.Count then
                                   xcount:=PTableStyle^.tblformat.Count;
     x:=0;
     pcf:=PTableStyle^.tblformat.beginiterate(icf);
     if xcount>0 then
     repeat
           pointer(pl):=self.ConstObjArray.CreateInitObj(GDBLineID,@self);
           pl^.CoordInOCS.lBegin.x:=x;
           pl^.CoordInOCS.lBegin.y:=0;
           pl^.CoordInOCS.lEnd.x:=x;
           pl^.CoordInOCS.lEnd.y:=-(ccount)*PTableStyle^.rowheight;
           pl^.Format;


           x:=x+pcf^.Width;
           pcf:=PTableStyle^.tblformat.iterate(icf);
                           if pcf=nil then
                                          pcf:=PTableStyle^.tblformat.beginiterate(icf);

           dec(xcount);
     until xcount=0;

     pointer(pl):=self.ConstObjArray.CreateInitObj(GDBLineID,@self);
     pl^.CoordInOCS.lBegin.x:=x;
     pl^.CoordInOCS.lBegin.y:=0;
     pl^.CoordInOCS.lEnd.x:=x;
     pl^.CoordInOCS.lEnd.y:=-(ccount)*PTableStyle^.rowheight;
     pl^.Format;

     h:=(ccount)*PTableStyle^.rowheight;
     w:=x;
     if self.PTableStyle.HeadBlockName<>'' then
     begin
          GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,PTableStyle.HeadBlockName);
          pointer(pgdbins):=self.ConstObjArray.CreateInitObj(GDBBlockInsertID,@self);
          pgdbins^.name:=self.PTableStyle.HeadBlockName;
          pgdbins^.BuildGeometry;
     end;
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
     ptablestyle:=gdb.GetCurrentDWG.TableStyleTable.getAddres('Standart');
     build;
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
