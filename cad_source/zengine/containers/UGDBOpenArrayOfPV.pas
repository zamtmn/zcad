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

unit UGDBOpenArrayOfPV;
{$INCLUDE def.inc}
interface
uses uzbgeomtypes,uzgldrawcontext,uzedrawingdef,uzeentity,uzecamera,uzbtypesbase,
     gzctnrvectortypes,gzctnrvectorpobjects,sysutils,uzbtypes,uzegeometry,uzbmemman,uzeentsubordinated,uzeentityfactory;
type
{PGDBObjEntityArray=^GDBObjEntityArray;
objvizarray = array[0..0] of PGDBObjEntity;
pobjvizarray = ^objvizarray;
GDBObjEntityArray=array [0..0] of PGDBObjEntity;}
{Export+}
PGDBObjOpenArrayOfPV=^GDBObjOpenArrayOfPV;
{REGISTEROBJECTTYPE GDBObjOpenArrayOfPV}
GDBObjOpenArrayOfPV= object(TZctnrVectorPGDBaseObjects)
                      procedure DrawWithattrib(var DC:TDrawContext);virtual;
                      procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                      procedure DrawOnlyGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                      procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                      function calcvisible(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble):GDBBoolean;virtual;
                      function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;
                      procedure DeSelect(var SelectedObjCount:GDBInteger;ds2s:TDeSelect2Stage);virtual;
                      function CreateObj(t: GDBByte{;owner:GDBPointer}):GDBPointer;virtual;
                      function CreateInitObj(t: GDBByte;owner:GDBPointer):PGDBObjSubordinated;virtual;
                      function calcbb:TBoundingBox;
                      function calcvisbb(infrustumactualy:TActulity):TBoundingBox;
                      function getoutbound(var DC:TDrawContext):TBoundingBox;
                      function getonlyoutbound(var DC:TDrawContext):TBoundingBox;
                      procedure Format;virtual;abstract;
                      procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                      procedure FormatAfterEdit(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                      //function InRect:TInRect;virtual;
                      function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;virtual;
                      //function FindEntityByVar(objID:GDBWord;vname,vvalue:GDBString):PGDBObjSubordinated;virtual;
                end;
{Export-}
function EqualFuncPGDBaseObject(const a, b: PGDBaseObject):Boolean;
implementation
function EqualFuncPGDBaseObject(const a, b: PGDBaseObject):Boolean;
begin
  result:=(a=b);
end;
function GDBObjOpenArrayOfPV.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):GDBBoolean;
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
function GDBObjOpenArrayOfPV.calcvisbb(infrustumactualy:TActulity):TBoundingBox;
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
function GDBObjOpenArrayOfPV.CreateObj(t: GDBByte{;owner:GDBPointer}):GDBPointer;
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
function GDBObjOpenArrayOfPV.CreateInitObj(t: GDBByte;owner:GDBPointer):PGDBObjSubordinated;
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
       p^.FormatEntity(drawing,dc);
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
procedure GDBObjOpenArrayOfPV.renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);
var
  p:pGDBObjEntity;
      ir:itrec;
begin
  if count>500 then
                   count:=count;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
  if ir.itc=12 then
                         count:=count;

  {if p^.GetObjType=0 then
                         p^.vp.ID:=p^.vp.ID;}
       if (p^.infrustum=infrustumactualy)or(p^.Selected) then
                                            begin
                                                 p^.renderfeedback(pcount,camera,ProjectProc,dc);
                                            end;
       p:=iterate(ir);
  until p=nil;
end;
procedure GDBObjOpenArrayOfPV.DrawWithattrib;
var
  p:pGDBObjEntity;
  ir:itrec;
begin
  if Count>1 then
                    Count:=Count;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       if p^.infrustum=dc.DrawingContext.infrustumactualy then
                           p^.DrawWithAttrib(dc);
       p:=iterate(ir);
  until p=nil;
end;
procedure GDBObjOpenArrayOfPV.DrawGeometry;
var
  p:pGDBObjEntity;
      ir:itrec;
begin
  if Count>1 then
                    Count:=Count;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       //if p^.vp.ID<>0 then
                         //p^.vp.ID:=p^.vp.ID;
       if p^.infrustum=dc.DrawingContext.infrustumactualy then
                           p^.DrawGeometry(lw,dc{infrustumactualy,subrender});
       p:=iterate(ir);
  until p=nil;
end;
procedure GDBObjOpenArrayOfPV.DrawOnlyGeometry;
var
  p:pGDBObjEntity;
      ir:itrec;
begin
  if Count>1 then
                    Count:=Count;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       //if p^.vp.ID<>0 then
                         //p^.vp.ID:=p^.vp.ID;
       if p^.infrustum=dc.DrawingContext.infrustumactualy then
                           p^.DrawOnlyGeometry(lw,dc{infrustumactualy,subrender});
       p:=iterate(ir);
  until p=nil;
end;
function GDBObjOpenArrayOfPV.calcvisible;
var
  p:pGDBObjEntity;
  q:GDBBoolean;
      ir:itrec;
begin
  result:=false;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       q:=p^.calcvisible(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
       result:=result or q;
       p:=iterate(ir);
  until p=nil;
end;
function GDBObjOpenArrayOfPV.CalcTrueInFrustum;
var
  p:pGDBObjEntity;
  q:TInBoundingVolume;
  ir:itrec;
  emptycount,objcount:integer;
begin
  emptycount:=0;
  objcount:=0;
  result:=IREmpty;
  p:=beginiterate(ir);
  if p<>nil then
  begin
  repeat
        if p^.Visible=visibleactualy then
        begin
             inc(objcount);
             q:=p^.CalcTrueInFrustum(frustum,visibleactualy);

    if q=IREmpty then
                            begin
                                 inc(emptycount);
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
     if (emptycount=0)and(objcount>0) then
                       result:=IRFully
                     else
                       result:=IREmpty;
  end;
end;
begin
end.
