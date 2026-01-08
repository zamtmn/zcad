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

unit UGDBOpenArrayOfPV;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzegeometrytypes,uzgldrawcontext,uzedrawingdef,uzeentity,uzecamera,
     gzctnrVectorTypes,sysutils,uzegeometry,
     uzeentsubordinated,uzeentityfactory,//uzctnrvectorpgdbaseobjects,
     uzctnrvectorpbaseentity,uzeEntBase,uzeTypes;
type
{PGDBObjEntityArray=^GDBObjEntityArray;
objvizarray = array[0..0] of PGDBObjEntity;
pobjvizarray = ^objvizarray;
GDBObjEntityArray=array [0..0] of PGDBObjEntity;}

PGDBObjOpenArrayOfPV=^GDBObjOpenArrayOfPV;
GDBObjOpenArrayOfPV= object({TZctnrVectorPGDBaseObjects}TZctnrVectorPGDBaseEntity)
                      procedure DrawWithattrib(var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
                      procedure DrawGeometry(lw:Integer;var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
                      function calcvisible(const frustum:TzeFrustum;const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                      function CalcActualVisible(const Actuality:TVisActuality):Boolean;virtual;
                      function CalcTrueInFrustum(const frustum:TzeFrustum):TInBoundingVolume;virtual;
                      procedure DeSelect(var SelectedObjCount:Integer;ds2s:TDeSelect2Stage);virtual;
                      function CreateObj(t: Byte{;owner:Pointer}):Pointer;virtual;
                      function CreateInitObj(t: Byte;owner:Pointer):PGDBObjSubordinated;virtual;
                      function calcbb:TBoundingBox;
                      function calcvisbb(infrustumactualy:TActuality):TBoundingBox;
                      function getoutbound(var DC:TDrawContext):TBoundingBox;
                      function getonlyoutbound(var DC:TDrawContext):TBoundingBox;
                      function getonlyvisibleoutbound(var DC:TDrawContext):TBoundingBox;
                      procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                      procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
                      procedure FormatAfterEdit(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                      //function InRect:TInRect;virtual;
                      function onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:TzePoint3d):Boolean;virtual;
                      //function FindEntityByVar(objID:Word;vname,vvalue:String):PGDBObjSubordinated;virtual;
                end;

function EqualFuncPGDBaseEntity(const a, b: PGDBObjBaseEntity):Boolean;
implementation
function EqualFuncPGDBaseEntity(const a, b: PGDBObjBaseEntity):Boolean;
begin
  result:=(a=b);
end;
function GDBObjOpenArrayOfPV.onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:TzePoint3d):Boolean;
var pobj:pGDBObjEntity;
    ir:itrec;
    //fr:TInRect;
    //all:boolean;
begin
     result:=false;
     pobj:=beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.onpoint(Objects,point) then
           begin
                result:=true;
                //Objects.Add(@pobj);
           end;

           pobj:=iterate(ir);
     until pobj=nil;

end;


function GDBObjOpenArrayOfPV.calcbb:TBoundingBox;
var pobj:pGDBObjEntity;
    ir:itrec;
begin
  pobj:=beginiterate(ir);
  if pobj=nil then
                  begin
                       result.LBN:=NulVertex;
                       result.RTF:=NulVertex;
                  end
              else
                  begin
                       result:=pobj^.vp.BoundingBox;
                       pobj:=iterate(ir);
                       if pobj<>nil then
                       repeat
                             concatbb(result,pobj^.vp.BoundingBox);
                             pobj:=iterate(ir);
                       until pobj=nil;
                  end;
end;
function GDBObjOpenArrayOfPV.calcvisbb(infrustumactualy:TActuality):TBoundingBox;
var pobj:pGDBObjEntity;
    ir:itrec;
begin
     result.LBN:=NulVertex;
     result.RTF:=NulVertex;

     pobj:=beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.infrustum=infrustumactualy then
           begin
                result:=pobj^.vp.BoundingBox;
                       pobj:=iterate(ir);
                       if pobj<>nil then
                       repeat
                             if pobj^.infrustum=infrustumactualy then
                             begin
                                  concatbb(result,pobj^.vp.BoundingBox);
                             end;
                             pobj:=iterate(ir);
                       until pobj=nil;
           end;
           pobj:=iterate(ir);
     until pobj=nil;
end;

function GDBObjOpenArrayOfPV.getoutbound(var DC:TDrawContext):TBoundingBox;
var pobj:pGDBObjEntity;
    ir:itrec;
begin
  pobj:=beginiterate(ir);
  if pobj=nil then
                  begin
                       result.LBN:=NulVertex;
                       result.RTF:=NulVertex;
                  end
              else
                  begin
                       pobj^.getoutbound(DC);
                       result:=pobj.vp.BoundingBox;
                       pobj^.correctbb(dc);
                       pobj:=iterate(ir);
                       if pobj<>nil then
                       repeat
                             pobj^.getoutbound(dc);
                             concatbb(result,pobj^.vp.BoundingBox);
                             pobj^.correctbb(dc);
                             pobj:=iterate(ir);
                       until pobj=nil;
                  end;
end;
function GDBObjOpenArrayOfPV.getonlyoutbound(var DC:TDrawContext):TBoundingBox;
var pobj:pGDBObjEntity;
    ir:itrec;
begin
  pobj:=beginiterate(ir);
  if pobj=nil then
                  begin
                       result.LBN:=NulVertex;
                       result.RTF:=NulVertex;
                  end
              else
                  begin
                       pobj^.getonlyoutbound(DC);
                       result:=pobj.vp.BoundingBox;
                       //pobj^.correctbb;
                       pobj:=iterate(ir);
                       if pobj<>nil then
                       repeat
                             pobj^.getonlyoutbound(dc);
                             concatbb(result,pobj^.vp.BoundingBox);
                             //pobj^.correctbb;
                             pobj:=iterate(ir);
                       until pobj=nil;
                  end;
end;
function GDBObjOpenArrayOfPV.getonlyvisibleoutbound(var DC:TDrawContext):TBoundingBox;
var pobj:pGDBObjEntity;
    ir:itrec;
    bb:TBoundingBox;
begin
  pobj:=beginiterate(ir);

  result.LBN:=NulVertex;
  result.RTF:=MinusOneVertex;

  if pobj=nil then
                  begin
                       {result.LBN:=NulVertex;
                       result.RTF:=MinusOneVertex;}
                  end
              else
                  begin
                       //pobj^.getonlyoutbound(DC);
                       //result:=pobj.vp.BoundingBox;
                       //pobj^.correctbb;
                       //pobj:=iterate(ir);
                       if pobj<>nil then
                       repeat
                         if (pobj.vp.Layer<>nil)and(pobj.vp.Layer^._on) then begin
                           bb:=pobj^.getonlyvisibleoutbound(dc);
                           if bb.RTF.x>=bb.LBN.x then begin
                             if result.RTF.x>=result.LBN.x then
                               concatbb(result,bb)
                             else
                               result:=bb;
                           end;
                         end;
                           pobj:=iterate(ir);
                       until pobj=nil;
                  end;
end;
function GDBObjOpenArrayOfPV.CreateObj(t: Byte{;owner:Pointer}):Pointer;
var temp: PGDBObjEntity;
begin
  temp := nil;
  if count=max then
                   self.grow;
  if count<max then
  begin
  temp:=AllocEnt(t);
  //temp^.bp.ListPos.Owner:=owner;
  //add(@temp);
  end;
  result := temp;
end;
function GDBObjOpenArrayOfPV.CreateInitObj(t: Byte;owner:Pointer):PGDBObjSubordinated;
var temp: PGDBObjEntity;
begin
  temp := nil;
  //if count<max then
  begin
  temp:=CreateInitObjfree(t,owner);
  temp^.bp.ListPos.Owner:=owner;
  PushBackData(temp);
  end;
  result := temp;
end;
procedure GDBObjOpenArrayOfPV.DeSelect;
var
  p:pGDBObjEntity;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.DeSelect(SelectedObjCount,ds2s);
       p:=iterate(ir);
  until p=nil;
end;
procedure GDBObjOpenArrayOfPV.FormatEntity;
var
  p:pGDBObjEntity;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.FormatEntity(drawing,dc,Stage);
       p:=iterate(ir);
  until p=nil;
end;
procedure GDBObjOpenArrayOfPV.CalcObjMatrix(pdrawing:PTDrawingDef=nil);
var
  p:pGDBObjEntity;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
    repeat
      p^.CalcObjMatrix(pdrawing);
      p:=iterate(ir);
    until p=nil;
end;
procedure GDBObjOpenArrayOfPV.formatafteredit;
var
  p:pGDBObjEntity;
      ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.formatafteredit(drawing,dc);
       p:=iterate(ir);
  until p=nil;
end;
procedure GDBObjOpenArrayOfPV.DrawWithattrib;
var
  p:pGDBObjEntity;
  ir:itrec;
begin
//  if Count>1 then
//                    Count:=Count;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       if p^.infrustum=dc.DrawingContext.VActuality.infrustumactualy then
                           p^.DrawWithAttrib(dc,inFrustumState);
       p:=iterate(ir);
  until p=nil;
end;
procedure GDBObjOpenArrayOfPV.DrawGeometry;
var
  p:pGDBObjEntity;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
    if p^.infrustum=dc.DrawingContext.VActuality.infrustumactualy then
      p^.DrawGeometry(lw,dc,infrustumstate);
    p:=iterate(ir);
  until p=nil;
end;
function GDBObjOpenArrayOfPV.calcvisible;
var
  p:pGDBObjEntity;
  q:Boolean;
      ir:itrec;
begin
  result:=false;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       q:=p^.calcvisible(frustum,Actuality,Counters,ProjectProc,zoom,currentdegradationfactor);
       result:=result or q;
       p:=iterate(ir);
  until p=nil;
end;
function GDBObjOpenArrayOfPV.CalcActualVisible(const Actuality:TVisActuality):Boolean;
var
  p:pGDBObjEntity;
  ir:itrec;
  q:boolean;
begin
  result:=false;
  p:=beginiterate(ir);
  if p<>nil then
    repeat
      q:=p^.CalcActualVisible(Actuality);
      result:=result or q;
      p:=iterate(ir);
    until p=nil;
end;
function GDBObjOpenArrayOfPV.CalcTrueInFrustum;
var
  p:pGDBObjEntity;
  q:TInBoundingVolume;
  ir:itrec;
  emptycount,notappl,objcount:integer;
begin
  emptycount:=0;
  objcount:=0;
  notappl:=0;
  result:={IREmpty}IRNotAplicable;
  q:=IRNotAplicable;
  p:=beginiterate(ir);
  if p<>nil then
  begin
  repeat
        //if p^.Visible=visibleactualy then
    if p^.vp.Layer^._on then
        begin
             inc(objcount);
             q:=p^.CalcTrueInFrustum(frustum);

    if q=IREmpty then
                            begin
                                 inc(emptycount);
                            end;
    if q=IRNotAplicable then
                            begin
                                 inc(notappl);
                            end;
     if q=IRPartially then
                                  begin
                                       result:=IRPartially;
                                       exit;
                                  end;
     if (q=IRFully)and(emptycount>0) then
                                  begin
                                       result:=IRPartially;
                                       exit;
                                  end;
        end;
        p:=iterate(ir);
  until p=nil;
  if objcount=0 then
    exit(IRNotAplicable);
  if (result<>IRNotAplicable) then begin
     if (emptycount=0)and(objcount>0) then
                       result:=IRFully
                     else
                       result:=IREmpty;
  end else if emptycount>0 then begin
    if emptycount+notappl=objcount then
      result:=IREmpty
    else
      result:=IRPartially;
  end else begin
       if notappl=objcount then
         result:=IREmpty
       else
         result:=IRFully;
  end;
  end;
end;
begin
end.
