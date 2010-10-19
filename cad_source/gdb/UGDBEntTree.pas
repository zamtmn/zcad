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

unit UGDBEntTree;
{$INCLUDE def.inc}
interface
uses
    math,gl,geometry,UGDBVisibleOpenArray,GDBEntity,gdbase,gdbasetypes,log,memman,OGLSpecFunc;
type
{EXPORT+}
         TNodeDir=(TND_Plus,TND_Minus,TND_Root);
         PTEntTreeNode=^TEntTreeNode;
         TEntTreeNode=object(GDBaseObject)
                            nodedepth:integer;
                            pluscount,minuscount:integer;
                            point:GDBVertex;
                            plane:DVector4D;
                            BoundingBox:GDBBoundingBbox;
                            nul:GDBObjEntityOpenArray;
                            pplusnode,pminusnode:PTEntTreeNode;

                            NodeDir:TNodeDir;
                            Root:PTEntTreeNode;

                            //selected:boolean;
                            infrustum:TActulity;
                            nuldrawpos,minusdrawpos,plusdrawpos:TActulity;
                            constructor initnul;
                            destructor done;
                            procedure draw;
                            procedure drawonlyself;
                            procedure ClearSub;
                            procedure updateenttreeadress;
                            procedure addtonul(p:PGDBObjEntity);
                      end;
         TTestTreeNode=Object
                             plane:DVector4D;
                             nul,plus,minus:GDBObjEntityOpenArray;
                             constructor initnul;
                             destructor done;
                       end;
         TTestTreeArray=array [0..2] of TTestTreeNode;
{EXPORT-}
const
  _InNodeCount=500;
  _NodeDepth=15;
function createtree(entitys:GDBObjEntityOpenArray;AABB:GDBBoundingBbox;PRootNode:PTEntTreeNode;nodedepth:GDBInteger;_root:PTEntTreeNode;dir:TNodeDir):PTEntTreeNode;
implementation
procedure TEntTreeNode.drawonlyself;
begin
     DrawAABB(BoundingBox);
end;

procedure TEntTreeNode.draw;
begin
     if assigned(pplusnode) then
                       pplusnode^.draw;
     if assigned(pminusnode) then
                       pminusnode^.draw;

     {if selected then glColor3ub(255, 0, 0)
                 else glColor3ub(100, 100, 100);}

     {myglbegin(GL_lines);
     myglVertex3d(vertexadd(point,createvertex(-1000/nodedepth,0,0)));
     myglVertex3d(vertexadd(point,createvertex(1000/nodedepth,0,0)));
     myglVertex3d(vertexadd(point,createvertex(0,-1000/nodedepth,0)));
     myglVertex3d(vertexadd(point,createvertex(0,1000/nodedepth,0)));
     myglVertex3d(vertexadd(point,createvertex(0,0,-1000/nodedepth)));
     myglVertex3d(vertexadd(point,createvertex(0,0,1000/nodedepth)));
     myglend;}
     {if selected then }drawonlyself;
end;

constructor TEntTreeNode.initnul;
begin
     nul.init(1000);
end;
procedure TEntTreeNode.ClearSub;
begin
     nul.Clear;
     if assigned(pplusnode) then
                                begin
                                     pplusnode^.done;
                                     gdbfreemem(pplusnode);
                                end;
     if assigned(pminusnode) then
                                begin
                                     pminusnode^.done;
                                     gdbfreemem(pminusnode);
                                end;
end;
procedure TEntTreeNode.addtonul(p:PGDBObjEntity);
begin
     p^.bp.TreePos.Owner:=@self;
     p^.bp.TreePos.SelfIndex:=nul.add(@p);
end;

procedure TEntTreeNode.updateenttreeadress;
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=nul.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.bp.TreePos.Owner:=@self;
           pobj^.bp.TreePos.SelfIndex:=ir.itc;

           pobj:=nul.iterate(ir);
     until pobj=nil;
end;
destructor TEntTreeNode.done;
begin
     ClearSub;
     nul.done;
end;
constructor TTestTreeNode.initnul;
begin
     nul.init(1000);
     plus.init(1000);
     minus.init(1000);
end;
destructor TTestTreeNode.done;
begin

end;

function createtree(entitys:GDBObjEntityOpenArray;AABB:GDBBoundingBbox;PRootNode:PTEntTreeNode;nodedepth:GDBInteger;_root:PTEntTreeNode;dir:TNodeDir):PTEntTreeNode;
var pobj:PGDBObjEntity;
    ir:itrec;
    midlepoint:gdbvertex;
    d1,d2,d:gdbdouble;
    entcount,dentcount,i,imin:integer;
    ta:TTestTreeArray;
    plusaabb,minusaabb:GDBBoundingBbox;
    tv:gdbvertex;
begin
     inc(nodedepth);
     if PRootNode<>nil then
                           begin
                           result:=PRootNode;
                           PRootNode^.ClearSub;
                           end
                       else
                           GDBGetMem({$IFDEF DEBUGBUILD}'{A1E9743F-63CF-4C8F-8C40-57CCDC24F8CF}',{$ENDIF}pointer(result),sizeof(TEntTreeNode));
     result.BoundingBox:=aabb;
     result.pluscount:=0;
     result.minuscount:=0;
     result.Root:=_root;
     result.NodeDir:=dir;
     if (entitys.Count<=_InNodeCount)or(nodedepth>_NodeDepth) then
                                                begin
                                                     //result.selected:=false;
                                                     {if entitys.beginiterate(ir)<>nil then
                                                                       if PGDBObjEntity(entitys.beginiterate(ir))^.Selected then
                                                                           result.selected:=true;}

                                                     result.plane:=geometry.NulVector4D;
                                                     result.pminusnode:=nil;
                                                     result.pplusnode:=nil;
                                                     if prootnode<>nil then
                                                                           begin
                                                                                //nul.init({$IFDEF DEBUGBUILD}'{A1E9743F-63CF-4C8F-8C40-57CCDC24F8CF}',{$ENDIF}entitys.Count);
                                                                                entitys.copytowithoutcorrect(@result.nul);
                                                                           end
                                                                       else
                                                                           begin
                                                                                result.nul:=entitys;
                                                                                //entitys.FreeAndDone;
                                                                           end;
                                                     result.updateenttreeadress;
                                                     exit;
                                                end;
     midlepoint:=nulvertex;
     entcount:=0;
     pobj:=entitys.beginiterate(ir);
     if pobj<>nil then
     repeat
           midlepoint:=vertexadd(midlepoint,VertexMulOnSc(vertexadd(pobj^.vp.BoundingBox.RTF,pobj^.vp.BoundingBox.LBN),1/2));
           //if abs(midlepoint.x)>100000000 then
           //                              pobj^.Format;
           inc(entcount);

           pobj:=entitys.iterate(ir);
     until pobj=nil;

     if entcount<>0 then
                        midlepoint:=geometry.VertexMulOnSc(midlepoint,1/entcount);

     d:=sqrt(sqr(midlepoint.x) + sqr(midlepoint.y) + sqr(midlepoint.z));
     ta[0].initnul;
     ta[0].plane:=geometry.PlaneFrom3Pont(midlepoint,
                                          vertexadd(midlepoint,VertexMulOnSc(x_Y_zVertex,d)),
                                          vertexadd(midlepoint,VertexMulOnSc(xy_Z_Vertex,d))
                                          );
     ta[1].initnul;
     ta[1].plane:=geometry.PlaneFrom3Pont(midlepoint,
                                          vertexadd(midlepoint,VertexMulOnSc(_X_yzVertex,d)),
                                          vertexadd(midlepoint,VertexMulOnSc(xy_Z_Vertex,d))
                                          );
     ta[2].initnul;
     ta[2].plane:=geometry.PlaneFrom3Pont(midlepoint,
                                          vertexadd(midlepoint,VertexMulOnSc(_X_yzVertex,d)),
                                          vertexadd(midlepoint,VertexMulOnSc(x_Y_ZVertex,d))
                                          );
     for i:=0 to 2 do
     begin
     pobj:=entitys.beginiterate(ir);
     if pobj<>nil then
     repeat
           d1:=ta[i].plane[0] * pobj^.vp.BoundingBox.RTF.x + ta[i].plane[1] * pobj^.vp.BoundingBox.RTF.y + ta[i].plane[2] * pobj^.vp.BoundingBox.RTF.z + ta[i].plane[3];
           d2:=ta[i].plane[0] * pobj^.vp.BoundingBox.LBN.x + ta[i].plane[1] * pobj^.vp.BoundingBox.LBN.y + ta[i].plane[2] * pobj^.vp.BoundingBox.LBN.z + ta[i].plane[3];
           if abs(d1)<eps then
                              d1:=0;
           if abs(d2)<eps then
                              d2:=0;
           d:=d1*d2;

           if d=0 then
                      begin
                           if (d1=0)and(d2=0) then
                                                  //ta[i].nul.AddRef(pobj^)
                                                  ta[i].nul.addwithoutcorrect(@pobj)
                      else if (d1>0)or(d2>0)  then
                                                  ta[i].plus.addwithoutcorrect(@pobj)
                                              else
                                                  ta[i].minus.addwithoutcorrect(@pobj);
                      end
      else if d<0 then
                      ta[i].nul.addwithoutcorrect(@pobj)
      else if (d1>0)or(d2>0)  then
                                  ta[i].plus.addwithoutcorrect(@pobj)
                              else
                                  ta[i].minus.addwithoutcorrect(@pobj);
           pobj:=entitys.iterate(ir);
     until pobj=nil;
     end;
     entcount:=ta[0].nul.Count;
     dentcount:=abs(ta[0].plus.Count-ta[0].minus.Count);
     imin:=-1;
     for i:=1 to 2 do
     begin
          if ta[i].nul.Count<entcount then
                                          begin
                                               entcount:=ta[i].nul.Count;
                                               dentcount:=abs(ta[i].plus.Count-ta[i].minus.Count);
                                               imin:=i;
                                          end
     else if ta[i].nul.Count=entcount then
                                       begin
                                            if abs(ta[i].plus.Count-ta[i].minus.Count)<dentcount then
                                            begin
                                                 entcount:=ta[i].nul.Count;
                                                 dentcount:=abs(ta[i].plus.Count-ta[i].minus.Count);
                                                 imin:=i;
                                            end;
                                       end;
     end;

     if imin=-1 then
     begin

     tv:=vertexsub(aabb.RTF,aabb.LBN);
     if (tv.x>=tv.y)and(tv.x>=tv.z) then
                                        imin:=0
else if (tv.y>=tv.x)and(tv.y>=tv.z) then
                                        imin:=1
else if (tv.z>=tv.x)and(tv.z>=tv.y) then
                                        imin:=2;
     end;



     plusaabb:=aabb;
     minusaabb:=aabb;

     case imin of
                 0:
                   begin
                        minusaabb.RTF.x:=midlepoint.x;
                        plusaabb.LBN.x:=midlepoint.x;
                   end;
                 1:
                   begin
                        minusaabb.LBN.y:=midlepoint.y;
                        plusaabb.RTF.y:=midlepoint.y;
                   end;
                 2:
                   begin
                        minusaabb.RTF.z:=midlepoint.z;
                        plusaabb.LBN.z:=midlepoint.z;
                   end;
     end;

     result.plane:=ta[imin].plane;
     result.point:=midlepoint;
     result.nul:=ta[imin].nul;
     result^.updateenttreeadress;
     result.nodedepth:=nodedepth;
     result.pminusnode:=createtree(ta[imin].minus,minusaabb,nil,nodedepth,result,TND_Minus);
     result.pplusnode:=createtree(ta[imin].plus,plusaabb,nil,nodedepth,result,TND_Plus);
     result.pluscount:=ta[imin].plus.Count;
     result.minuscount:=ta[imin].minus.Count;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBEntTre.initialization');{$ENDIF}
end.
