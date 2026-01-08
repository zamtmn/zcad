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

unit UGDBSelectedObjArray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  uzegeometrytypes,uzepalette,uzgldrawcontext,uzecamera,uzeentwithmatrix,
  uzeentity,UGDBControlPointArray,gzctnrVector,sysutils,uzegeometry,
  uzglviewareadata,uzeTypes;
type

PSelectedObjDesc=^SelectedObjDesc;
SelectedObjDesc=record
                      objaddr:PGDBObjEntity;
                      pcontrolpoint:PGDBControlPointArray;
                      ptempobj:PGDBObjEntity;
                end;
PGDBSelectedObjArray=^GDBSelectedObjArray;
GDBSelectedObjArray= object(GZVector<selectedobjdesc>)
                          SelectedCount:Integer;

                          function addobject(PEntity:PGDBObjEntity):pselectedobjdesc;virtual;
                          procedure pushobject(PEntity:PGDBObjEntity);
                          procedure free;virtual;
                          procedure remappoints(pcount:TActuality;ScrollMode:Boolean;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                          procedure drawpoint(var DC:TDrawContext;const GripSize:Integer; const SelColor,UnSelColor:TRGB);virtual;
                          procedure drawobject(var DC:TDrawContext);virtual;
                          function getnearesttomouse(mx,my:integer):tcontrolpointdist;virtual;
                          function getonlyoutbound(var DC:TDrawContext):TBoundingBox;
                          procedure selectcurrentcontrolpoint(key:Byte;mx,my,h:integer);virtual;
                          procedure selectcontrolpointinframe(f1,f2: TzePoint2i);virtual;
                          //destructor done;virtual;
                          procedure freeclones;
                          procedure Transform(const dispmatr:TzeTypedMatrix4d);
                          procedure SetRotate(const minusd,plusd,rm:TzeTypedMatrix4d;const x,y,z:TzePoint3d);
                          procedure SetRotateObj(const minusd,plusd,rm:TzeTypedMatrix4d;const x,y,z:TzePoint3d);
                          procedure TransformObj(const dispmatr:TzeTypedMatrix4d);

                          procedure drawobj(var DC:TDrawContext);virtual;
                          procedure freeelement(PItem:PT);virtual;
                          procedure calcvisible(const frustum:TzeFrustum;const Actuality:TVisActuality;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);virtual;
                          //procedure resprojparam(pcount:TActuality;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);
                    end;

implementation
//uses uzedrawingabstract,uzeentgenericsubentry;
{procedure GDBSelectedObjArray.resprojparam;
var tdesc:pselectedobjdesc;
    i:Integer;
begin
  if count<>0 then
  begin
       tdesc:=GetParrayAsPointer;
       for i:=0 to count-1 do
       begin
            tdesc^.objaddr^.Renderfeedback(pcount,camera,ProjectProc,dc);
            inc(tdesc);
       end;
  end;
end;}
procedure GDBSelectedObjArray.freeelement;
begin
  if PSelectedObjDesc(PItem).pcontrolpoint<>nil then
                                                begin
                                                     PSelectedObjDesc(PItem).pcontrolpoint^.Done;
                                                     Freemem(Pointer(PSelectedObjDesc(PItem).pcontrolpoint));
                                                end;
  if PSelectedObjDesc(PItem).ptempobj<>nil then
                                           begin
                                                PSelectedObjDesc(PItem).ptempobj^.done;
                                                Freemem(Pointer(PSelectedObjDesc(PItem).ptempobj));
                                           end;
  //PGDBObjBlockdef(p).Entities.ClearAndDone;
end;
function dummyseldesccompare(const a, b: selectedobjdesc):Boolean;
begin
   if a.objaddr=b.objaddr then
                              result:=true
                          else
                              result:=false;
end;

function GDBSelectedObjArray.addobject;
var dummyseldesc:selectedobjdesc;
    i:Integer;
begin
  dummyseldesc.objaddr:=PEntity;
  dummyseldesc.pcontrolpoint:=nil;
  dummyseldesc.ptempobj:=nil;
  i:=PushBackIfNotPresentWithCompareProc(dummyseldesc,dummyseldesccompare);
  result:=@PArray^[i];
  {i:=IsDataExistWithCompareProc(dummyseldesc,dummyseldesccompare);
  if i<0 then
              begin
                i:=PushBackData(dummyseldesc);
              end;
  result:=@PArray^[i];}
end;
procedure GDBSelectedObjArray.pushobject(PEntity:PGDBObjEntity);
var
  dummyseldesc:selectedobjdesc;
begin
  dummyseldesc.objaddr:=PEntity;
  dummyseldesc.pcontrolpoint:=nil;
  dummyseldesc.ptempobj:=nil;
  PushBackData(dummyseldesc);
end;
procedure GDBSelectedObjArray.free;
var tdesc:pselectedobjdesc;
    i:Integer;
begin
  tdesc:=GetParrayAsPointer;
  if count<>0 then
  begin
       for i:=0 to count-1 do
       begin
            if tdesc^.pcontrolpoint<>nil then
            begin
                tdesc^.pcontrolpoint^.done;
                Freemem(Pointer(tdesc^.pcontrolpoint));
            end;
            if tdesc^.ptempobj<>nil then
            begin
                 tdesc^.ptempobj^.done;
                 Freemem(Pointer(tdesc^.ptempobj));
            end;
            inc(tdesc);
       end;
  end;
  clear;
end;
procedure GDBSelectedObjArray.drawpoint;
var tdesc:pselectedobjdesc;
    i:Integer;
begin
  if count<>0 then
  begin
       tdesc:=GetParrayAsPointer;
       dc.drawer.SetPointSize(GripSize);
       for i:=0 to count-1 do
       begin
            if tdesc^.pcontrolpoint<>nil then
            begin
                 tdesc^.pcontrolpoint^.draw(dc,SelColor,UnSelColor);
            end;
            inc(tdesc);
       end;
       dc.drawer.SetPointSize(1);
  end;
end;
{procedure GDBSelectedObjArray.RenderFeedBack;
var tdesc:pselectedobjdesc;
    i:Integer;
begin
  if count<>0 then
  begin
       tdesc:=GetParrayAsPointer;
       for i:=0 to count-1 do
       begin
            if tdesc^.objaddr<>nil then
            begin
                 tdesc^.objaddr^.RenderFeedbackIFNeed(pcount,camera,ProjectProc,dc);
            end;
            if tdesc^.ptempobj<>nil then
            begin
                 tdesc^.ptempobj^.RenderFeedbackIFNeed(pcount,camera,ProjectProc,dc);
            end;
            inc(tdesc);
       end;
  end;
end;}
procedure GDBSelectedObjArray.drawobject;
var tdesc:pselectedobjdesc;
    i:Integer;
begin
  if count<>0 then
  begin
       tdesc:=GetParrayAsPointer;
       for i:=0 to count-1 do
       begin
            if tdesc^.objaddr<>nil then
            begin
                 tdesc^.objaddr^.DrawWithOutAttrib(dc,TInBoundingVolume.IRPartially); //DrawGeometry(tdesc^.objaddr^.CalculateLineWeight);
            end;
            inc(tdesc);
       end;
  end;
end;
procedure GDBSelectedObjArray.remappoints;
var tdesc:pselectedobjdesc;
    i:Integer;
begin
  if count<>0 then
  begin
       tdesc:=GetParrayAsPointer;
       for i:=0 to count-1 do
       begin
            if tdesc^.pcontrolpoint<>nil then
            begin
                 tdesc^.objaddr^.remapcontrolpoints(tdesc^.pcontrolpoint,pcount,ScrollMode,camera,ProjectProc,dc);
            end;
            inc(tdesc);
       end;
  end;
end;
function GDBSelectedObjArray.getnearesttomouse;
var i: Integer;
//  d: Double;
  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  td.pcontrolpoint := nil;
  td.disttomouse:=9999;
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then tdesc^.pcontrolpoint^.getnearesttomouse(td,mx,my);
      inc(tdesc);
    end;
  end;
  result:=td;
end;

(*procedure processobject(pobj:PGDBObjEntity;minusd,plusd,rm:TzeTypedMatrix4d;x,y,z:TzePoint3d);
var i: Integer;
  m,m2,oplus,ominus:TzeTypedMatrix4d;
  tv,P_insert_in_OCS,P_insert_in_WCS:TzePoint3d;
begin
  pobj^.Transform(minusd);

  //1) Делаем M единичной
  m:=onematrix;
  //2) Сдвигаем в начало координат. Для этого выдираем из матрицы объекта элементы
  //отвечающие за смещение, и строим на них матрицу сдвига в начало координат - minus
  //и вторую, для сдвига обратно - plus.Умножаем М на матрицу сдвига в начало системы
  m:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  P_insert_in_OCS:=PzePoint3d(@m[3])^;
  ominus:=uzegeometry.CreateTranslationMatrix(uzegeometry.MinusVertex(P_insert_in_OCS));
  oplus:=uzegeometry.CreateTranslationMatrix(P_insert_in_OCS);
  m:=uzegeometry.MatrixMultiply(m,ominus);

  //3) Выравниваем оси по глобальной СКО. Берем матрицу из объекта Mobj и удаляем
  //у нее элементы сдвига, потом инвертируем (или транспонируем, для матриц
  //вращения это одно и то же). M = M*Mobj_inv
  m2:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  PzePoint3d(@m2[3])^:=nulvertex;
  matrixinvert(m2);
  m:=uzegeometry.MatrixMultiply(m,m2);

  //4) Выравниваем оси по СКО приемника. Выдираем матрицу из приемника - Mdest,
  //обнуляем ей элементы сдвига и умножаем на M: M = M*Mdest
  m:=uzegeometry.MatrixMultiply(m,rm);

  //5) Двигаем объект обратно. M = M*plus
  m:=uzegeometry.MatrixMultiply(m,oplus);


  //6) Двигаем объект в точку крепежа на приемнике. Составляем матрицу сдвига
  //Мpick на основе вектора Vpick - Vobj (точка крепежа минус положение объекта).
  //M = M*Mpck.
  //7) Двигаем объект с учетом смещения точки крепежа исходного объекта внутри
  //его локальной системы координат. Ну думаю сообразишь.

  pobj^.Transform(m);

  pobj^.Transform(plusd);
  PGDBObjWithMatrix(pobj)^.ReCalcFromObjMatrix;
  PGDBObjWithMatrix(pobj)^.Format;
end;

*)
procedure processobject(pobj:PGDBObjEntity;const minusd,plusd,rm:TzeTypedMatrix4d;const x,y,z:TzePoint3d);
var //i: Integer;
  m{,oplus,ominus}:TzeTypedMatrix4d;
  {tv,}P_insert_in_OCS,P_insert_in_WCS:TzePoint3d;
begin
  pobj^.Transform(minusd);

  m:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  P_insert_in_OCS:=PzePoint3d(@m.mtr.v[3])^;
  PzePoint3d(@m.mtr.v[3])^:=nulvertex;
  matrixinvert(m);
  P_insert_in_WCS:=VectorTransform3D(P_insert_in_OCS,m);
  //m:=onematrix;
  //PzePoint3d(@m.mtr[3])^:=P_insert_in_wCS;
  m:=CreateTranslationMatrix(P_insert_in_wCS);
  PGDBObjWithMatrix(pobj)^.ObjMatrix:=m;
  pobj^.Transform(rm);

  pobj^.Transform(plusd);
  PGDBObjWithMatrix(pobj)^.ReCalcFromObjMatrix;
  //PGDBObjWithMatrix(pobj)^.FormatEntity(gdb.GetCurrentDWG^);
end;

(*procedure processobject(pobj:PGDBObjEntity;minusd,plusd,rm:TzeTypedMatrix4d;x,y,z:TzePoint3d);
var i: Integer;
//  d: Double;
//  td:tcontrolpointdist;
  m,m2,oplus,ominus:TzeTypedMatrix4d;
  tv:TzePoint3d;
  l1,l2:GDBObj2dprop;
{
pobj^.Transform(minusd);
m:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
PzePoint3d(@m[3])^:=nulvertex;
matrixinvert(m);
pobj^.Transform(m);
pobj^.Transform(rm);
pobj^.Transform(plusd);
PGDBObjWithMatrix(pobj)^.ReCalcFromObjMatrix;
PGDBObjWithMatrix(pobj)^.Format;
}
begin
  l1:=PGDBObjWithLocalCS(pobj)^.Local;
  m:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  pobj^.Transform({minusd}onematrix);
  l2:=PGDBObjWithLocalCS(pobj)^.Local;
  //m:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  //PzePoint3d(@m[3])^:=nulvertex;
  //matrixinvert(m);
  //pobj^.Transform(m);
  //pobj^.Transform(rm);
  pobj^.Transform({plusd}onematrix);
  m2:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  l2:=PGDBObjWithLocalCS(pobj)^.Local;
  //PGDBObjWithMatrix(pobj)^.ReCalcFromObjMatrix;
  m:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  PGDBObjWithMatrix(pobj)^.Format;
  m2:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  {pobj^.Transform(minusd);
  m:=PGDBObjWithMatrix(pobj)^.ObjMatrix;
  tv:=vectortransform3d(nulvertex,m);
  oplus:=uzegeometry.CreateTranslationMatrix(tv);
  ominus:=uzegeometry.CreateTranslationMatrix(createvertex(-tv.x,-tv.y,-tv.z));
  PzePoint3d(@m[3])^:=nulvertex;
  matrixinvert(m);
  PGDBObjWithMatrix(pobj)^.ObjMatrix:=onematrix;
  //pobj^.Transform(m);
  pobj^.Transform(oplus);
  pobj^.Transform(rm);
  pobj^.Transform(plusd);
  PGDBObjWithMatrix(pobj)^.ReCalcFromObjMatrix;
  PGDBObjWithMatrix(pobj)^.Format;}
end;
*)
procedure GDBSelectedObjArray.SetRotate(const minusd,plusd,rm:TzeTypedMatrix4d;const x,y,z:TzePoint3d);
var i: Integer;
//  d: Double;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
  //m,oplus:TzeTypedMatrix4d;
  //tv:TzePoint3d;
begin
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then
        if tdesc^.pcontrolpoint^.SelectedCount<>0 then
        begin
             processobject(tdesc^.ptempobj,minusd,plusd,rm,x,y,z);
        end;
      inc(tdesc);
    end;
  end;
  {if save then
              gdb.GetCurrentROOT.FormatAfterEdit;}
end;
procedure GDBSelectedObjArray.SetRotateObj(const minusd,plusd,rm:TzeTypedMatrix4d;const x,y,z:TzePoint3d);
var i: Integer;
//  d: Double;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
  //m,tempm,oplus,ominus:TzeTypedMatrix4d;
  //tv:TzePoint3d;
begin
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then
        //if tdesc^.pcontrolpoint^.SelectedCount<>0 then
        begin
          processobject(tdesc^.objaddr,minusd,plusd,rm,x,y,z);
          {tdesc^.objaddr^.Transform(minusd);
          m:=PGDBObjWithMatrix(tdesc^.objaddr)^.ObjMatrix;
          PzePoint3d(@m[3])^:=nulvertex;
          matrixinvert(m);
          tdesc^.objaddr^.Transform(m);
          tdesc^.objaddr^.Transform(rm);
          tdesc^.objaddr^.Transform(plusd);
          PGDBObjWithMatrix(tdesc^.objaddr)^.ReCalcFromObjMatrix;
          PGDBObjWithMatrix(tdesc^.objaddr)^.Format;}
        end;
      inc(tdesc);
    end;
  end;
  {if save then
              gdb.GetCurrentROOT.FormatAfterEdit;}
end;

procedure GDBSelectedObjArray.Transform(const dispmatr:TzeTypedMatrix4d);
var i: Integer;
//  d: Double;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then
        if tdesc^.pcontrolpoint^.SelectedCount<>0 then
        begin
             tdesc^.ptempobj^.Transform(dispmatr);
             //tdesc^.ptempobj^.Format;

             //tdesc^.objaddr^.Transform{At}(dispmatr);
             //tdesc^.objaddr^.Format;
             //gdb.rtmodify(tdesc^.objaddr,tdesc,dist,wc,save);
        end;
      inc(tdesc);
    end;
  end;
  {if save then
              gdb.GetCurrentROOT.FormatAfterEdit;}
end;
procedure GDBSelectedObjArray.TransformObj(const dispmatr:TzeTypedMatrix4d);
var i: Integer;
  tdesc:pselectedobjdesc;
begin
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then
        //if tdesc^.pcontrolpoint^.SelectedCount<>0 then
        begin
             tdesc^.objaddr^.Transform(dispmatr);
             //tdesc^.objaddr^.Format;

             //tdesc^.objaddr^.Transform{At}(dispmatr);
             //tdesc^.objaddr^.Format;
             //gdb.rtmodify(tdesc^.objaddr,tdesc,dist,wc,save);
        end;
      inc(tdesc);
    end;
  end;
  {if save then
              gdb.GetCurrentROOT.FormatAfterEdit;}
end;
procedure GDBSelectedObjArray.freeclones;
var i: Integer;
//  d: Double;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.ptempobj<>nil then
        begin
          tdesc^.ptempobj^.done;
          Freemem(Pointer(tdesc^.ptempobj));
          tdesc^.ptempobj:=nil;
        end;
      inc(tdesc);
    end;
  end;
end;

procedure GDBSelectedObjArray.calcvisible;
{var
  p:pGDBObjEntity;
  q:Boolean;}
var i: Integer;
//  d: Double;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  {result:=false;
  p:=beginiterate;
  if p<>nil then
  repeat
       q:=p^.calcvisible;
       result:=result or q;
       p:=iterate;
  until p=nil;}
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.ptempobj<>nil then
                                  begin
                                  //tdesc^.ptempobj^.getoutbound;
                                  tdesc^.ptempobj^.calcvisible(frustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor);
                                  end;
      inc(tdesc);
    end;
  end;

end;
function GDBSelectedObjArray.getonlyoutbound(var DC:TDrawContext):TBoundingBox;
var
   i: Integer;
   tdesc:pselectedobjdesc;
begin
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    tdesc^.objaddr^.getonlyoutbound(dc);
    result:=tdesc^.objaddr^.vp.BoundingBox;
    inc(tdesc);
    for i := 1 to count - 1 do
    begin
      if tdesc^.objaddr<>nil then
                                 begin
                                   tdesc^.objaddr^.getonlyoutbound(dc);
                                   concatbb(result,tdesc^.objaddr^.vp.BoundingBox);
                                 end;
      inc(tdesc);
    end;
  end
  else
  begin
       result.LBN:=NulVertex;
       result.RTF:=NulVertex;
  end;

end;
procedure GDBSelectedObjArray.drawobj;
var i: Integer;
//  d: Double;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.ptempobj<>nil then
        tdesc^.ptempobj^.DrawWithAttrib(dc,IRPartially);
      inc(tdesc);
    end;
  end;

end;
procedure GDBSelectedObjArray.selectcontrolpointinframe(f1,f2: TzePoint2i);
var i: Integer;
  tdesc:pselectedobjdesc;
begin
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then
        tdesc^.pcontrolpoint^.selectcontrolpointinframe(f1,f2);
      inc(tdesc);
    end;
  end;

end;
procedure GDBSelectedObjArray.selectcurrentcontrolpoint;
var i: Integer;
//  d: Double;
  //td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  //td.pcontrolpoint := nil;
  //td.disttomouse:=9999;
  SelectedCount:=0;
  if count > 0 then
  begin
    tdesc:=GetParrayAsPointer;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then begin
        tdesc^.pcontrolpoint^.selectcurrentcontrolpoint(key,mx,my,h);
        SelectedCount:=SelectedCount+tdesc^.pcontrolpoint^.SelectedCount;
      end;
      inc(tdesc);
    end;
  end;
end;
{destructor GDBSelectedObjArray.done;
begin
  if pa then

  Freemem(PArray);
end;}
begin
end.
