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
unit uzccommand_polyed;
{$INCLUDE zengineconfig.inc}

interface
uses
  gzundoCmdChgMethods,
  gzctnrVectorTypes,uzeentitiesmanager,
  uzcdrawing,
  uzgldrawcontext,
  uzcstrconsts,
  uzccommandsabstract,
  uzccommandsmanager,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzcutils,
  uzglviewareadata,
  uzcinterface,
  uzegeometry,
  uzeconsts,
  uzegeometrytypes,uzeentity,uzeentcircle,uzeentline,
  uzeentpolyline,
  math,
  Varman,
  uzcLog,
  uzccommand_circle2;

type
  TSubPolyEdit=(
    TSPE_Insert(*'Insert vertex'*),
    TSPE_Remove(*'Remove vertex'*),
    TSPE_Scissor(*'Cut into two parts'*)
  );
  TPolyEditMode=(
    TPEM_Nearest(*'Paste in nearest segment'*),
    TPEM_Select(*'Choose a segment'*)
  );
  TPolyEdit=record
    Action:TSubPolyEdit;(*'Action'*)
    Mode:TPolyEditMode;(*'Mode'*)
    vdist:Double;(*hidden_in_objinsp*)
    ldist:Double;(*hidden_in_objinsp*)
    nearestvertex:Integer;(*hidden_in_objinsp*)
    nearestline:Integer;(*hidden_in_objinsp*)
    dir:Integer;(*hidden_in_objinsp*)
    setpoint:Boolean;(*hidden_in_objinsp*)
    vvertex:gdbvertex;(*hidden_in_objinsp*)
    lvertex1:gdbvertex;(*hidden_in_objinsp*)
    lvertex2:gdbvertex;(*hidden_in_objinsp*)
  end;

var
  p3dpl:pgdbobjpolyline;
  PCreatedGDBLine:pgdbobjline;
  pworkvertex:pgdbvertex;
  PEProp:TPolyEdit;

implementation

function _3DPolyEd_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   pobj:pgdbobjentity;
   ir:itrec;
begin
  p3dpl:=nil;
  pc:=nil;
  PCreatedGDBLine:=nil;
  pworkvertex:=nil;
  PEProp.setpoint:=false;
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj^.selected
              and (
                   (pobj^.GetObjType=GDBPolylineID)
                 or(pobj^.GetObjType=GDBCableID)
                   )
              then
                  begin
                       p3dpl:=pointer(pobj);
                       system.Break;
                  end;
          end;
          pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
   until pobj=nil;
   if p3dpl=nil then
                   begin
                        ZCMsgCallBackInterface.TextMessage(rscmPolyNotSel,TMWOHistoryOut);
                        commandmanager.executecommandend;
                   end
               else
                   begin
                        ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('TPolyEdit'),@PEProp,drawings.GetCurrentDWG);
                        drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
                        drawings.GetCurrentDWG^.SelObjArray.Free;
                   end;
  result:=cmd_ok;
end;


function _3DPolyEd_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
    ptv,ptvprev:pgdbvertex;
    ir:itrec;
    v,l:Double;
    domethod,undomethod:tmethod;
    polydata:tpolydata;
    _tv:gdbvertex;
    p3dpl2:pgdbobjpolyline;
    i:integer;
    dc:TDrawContext;
begin
//  if (button and MZW_LBUTTON)<>0 then
//                    button:=button;
  if PEProp.Action=TSPE_Remove then
                                   PEProp.setpoint:=false;

  if (pc<>nil)or(PCreatedGDBLine<>nil) then
                 begin
                      drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
                      pc:=nil;
                      PCreatedGDBLine:=nil;
                 end;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  result:={mclick}0;
  if not PEProp.setpoint then
  begin
  PEProp.nearestvertex:=-1;
  PEProp.dir:=0;
  PEProp.nearestline:=-1;
  PEProp.vdist:=+Infinity;
  PEProp.ldist:=+Infinity;
  ptvprev:=nil;
  ptv:=p3dpl^.vertexarrayinwcs.beginiterate(ir);
  if ptv<>nil then
  repeat
        v:=SqrVertexlength(wc,ptv^);
        if v<PEProp.vdist then
                       begin
                            PEProp.vdist:=v;
                            PEProp.nearestvertex:=ir.itc;
                            PEProp.vvertex:=ptv^;
                       end;
        if ptvprev<>nil then
                            begin
                                 l:=sqr(distance2piece(wc,ptvprev^,ptv^));
                                 if l<PEProp.ldist then
                                                begin
                                                     PEProp.ldist:=l;
                                                     PEProp.nearestline:=ir.itc;
                                                     PEProp.lvertex1:=ptvprev^;
                                                     PEProp.lvertex2:=ptv^;
                                                end;
                            end;
        ptvprev:=ptv;
        ptv:=p3dpl^.vertexarrayinwcs.iterate(ir);
  until ptv=nil;
  end;
  if (PEProp.Action=TSPE_Remove) then
  begin
  if PEProp.nearestvertex>-1 then
                          begin

                          pc := PGDBObjCircle(ENTF_CreateCircle(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                                                drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,lwgdbdefault,ClByLayer,
                                                                PEProp.vvertex,10*drawings.GetCurrentDWG^.pcamera^.prop.zoom));
                          zcSetEntPropFromCurrentDrawingProp(pc);
                          //pc := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
                          //GDBObjSetCircleProp(pc,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^,sysvar.dwg.DWG_CLinew^, PEProp.vvertex,10*drawings.GetCurrentDWG^.pcamera^.prop.zoom);

                          pc^.Formatentity(drawings.GetCurrentDWG^,dc);
                          end;
  end;
  if (PEProp.Action=TSPE_Insert) then
                                     begin
                                          if abs(PEProp.vdist-PEProp.ldist)>sqreps then
                                          begin
                                               PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                                                                              drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                                                                              PEProp.lvertex1,wc));
                                               zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
                                               //PCreatedGDBLine := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                               //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);

                                               PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);

                                               PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                                                                              drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                                                                              PEProp.lvertex2,wc));
                                               zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
                                               //PCreatedGDBLine := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                               //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^,sysvar.dwg.DWG_CLinew^, PEProp.lvertex2, wc);

                                               PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
                                               PEProp.dir:=-1;
                                          end
                                     else
                                         begin
                                              if PEProp.nearestvertex=0 then
                                              begin
                                                   PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                                                                                  drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                                                                                  PEProp.lvertex1,wc));
                                                   zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);

                                                   //PCreatedGDBLine := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                                   //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, PEProp.lvertex1, wc);
                                                   PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
                                                   PEProp.nearestline:=PEProp.nearestvertex;
                                                   PEProp.dir:=-1;
                                              end
                                              else if PEProp.nearestvertex=p3dpl^.vertexarrayinwcs.Count-1 then
                                              begin
                                                   PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                                                                                  drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                                                                                  PEProp.lvertex2,wc));
                                                   zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
                                                   //PCreatedGDBLine := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                                   //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, PEProp.lvertex2, wc);
                                                   PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
                                                   PEProp.nearestline:=PEProp.nearestvertex;
                                                   PEProp.dir:=1;
                                              end

                                         end;
                                     end;
  if (PEProp.Action=TSPE_Scissor) then
  begin
  if PEProp.vdist>PEProp.ldist+bigeps then
                                   begin
                                        _tv:=NearestPointOnSegment(wc,PEProp.lvertex1,PEProp.lvertex2);
                                        pc := PGDBObjCircle(ENTF_CreateCircle(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                                                              drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,lwgdbdefault,ClByLayer,
                                                                              _tv,10*drawings.GetCurrentDWG^.pcamera^.prop.zoom));
                                        zcSetEntPropFromCurrentDrawingProp(pc);
                                        //pc := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
                                        //GDBObjSetCircleProp(pc,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, _tv, 10*drawings.GetCurrentDWG^.pcamera^.prop.zoom);
                                        pc^.Formatentity(drawings.GetCurrentDWG^,dc);

                                        PCreatedGDBLine := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                                                                       drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                                                                       _tv,wc));
                                        zcSetEntPropFromCurrentDrawingProp(PCreatedGDBLine);
                                        //PCreatedGDBLine := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
                                        //GDBObjSetLineProp(PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, _tv, wc);

                                        //PCreatedGDBLine := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateObj(GDBLineID,drawings.GetCurrentROOT));
                                        //GDBObjLineInit(drawings.GetCurrentROOT,PCreatedGDBLine,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^, _tv, wc);
                                        PCreatedGDBLine^.Formatentity(drawings.GetCurrentDWG^,dc);
                                   end
                               else
                               begin
                                   pc := PGDBObjCircle(ENTF_CreateCircle(@drawings.GetCurrentDWG^.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                                       drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,lwgdbdefault,ClByLayer,
                                                       PEProp.vvertex,40*drawings.GetCurrentDWG^.pcamera^.prop.zoom));
                                   zcSetEntPropFromCurrentDrawingProp(pc);
                                   //pc := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBCircleID,drawings.GetCurrentROOT));
                                   //GDBObjSetCircleProp(pc,drawings.GetCurrentDWG^.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^, sysvar.dwg.DWG_CLinew^, PEProp.vvertex, 40*drawings.GetCurrentDWG^.pcamera^.prop.zoom);
                                   pc^.Formatentity(drawings.GetCurrentDWG^,dc);
                               end

  end;
  if (button and MZW_LBUTTON)<>0 then
  begin
       if (PEProp.Action=TSPE_Remove)and(PEProp.nearestvertex<>-1) then
                                        begin
                                             if p3dpl^.vertexarrayinocs.Count>2 then
                                             begin
                                                  polydata.index:=PEProp.nearestvertex;
                                                  if PEProp.nearestvertex=p3dpl^.vertexarrayinocs.GetCount then
                                                                                polydata.index:=polydata.index+1;
                                                  {polydata.nearestvertex:=PEProp.nearestvertex;
                                                  polydata.nearestline:=polydata.nearestvertex;
                                                  polydata.dir:=PEProp.dir;
                                                  polydata.dir:=-1;
                                                  if PEProp.nearestvertex=0 then
                                                                                polydata.dir:=-1;
                                                  if PEProp.nearestvertex=p3dpl^.vertexarrayinocs.GetCount then
                                                                                polydata.dir:=1;}
                                                  polydata.wc:=PEProp.vvertex;
                                                  domethod:=tmethod(@p3dpl^.DeleteVertex);
                                                  {tmethod(domethod).Code:=pointer(p3dpl.DeleteVertex);
                                                  tmethod(domethod).Data:=p3dpl;}
                                                  undomethod:=tmethod(@p3dpl^.InsertVertex);
                                                  {tmethod(undomethod).Code:=pointer(p3dpl.InsertVertex);
                                                  tmethod(undomethod).Data:=p3dpl;}
                                                  with specialize GUCmdChgMethods<TPolyData>.CreateAndPush(polydata,domethod,undomethod,PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,@drawings.AfterAutoProcessGDB) do
                                                  begin
                                                       comit;
                                                  end;




                                                  //p3dpl^.vertexarrayinocs.DeleteElement(PEProp.nearestvertex);
                                                  p3dpl^.YouChanged(drawings.GetCurrentDWG^);
                                                  drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
                                                  //p3dpl^.Format;
                                                  zcRedrawCurrentDrawing;
                                             end
                                             else
                                                 ZCMsgCallBackInterface.TextMessage(rscm2VNotRemove,TMWOHistoryOut);
                                        end;
       if (PEProp.Action=TSPE_Insert)and(PEProp.nearestline<>-1)and(PEProp.dir<>0) then
                                        begin
                                             if (PEProp.setpoint)or(PEProp.Mode=TPEM_Nearest) then
                                                                    begin
                                                                         polydata.{nearestvertex}index:=PEProp.nearestline;
                                                                         if PEProp.dir=1 then
                                                                                      inc(polydata.{nearestvertex}index);
                                                                         //polydata.nearestline:=PEProp.nearestline;
                                                                         //polydata.dir:=PEProp.dir;
                                                                         polydata.wc:=wc;
                                                                         domethod:=tmethod(@p3dpl^.InsertVertex);
                                                                         {tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
                                                                         tmethod(domethod).Data:=p3dpl;}
                                                                         undomethod:=tmethod(@p3dpl^.DeleteVertex);
                                                                         {tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
                                                                         tmethod(undomethod).Data:=p3dpl;}
                                                                         with Specialize GUCmdChgMethods<TPolyData>.CreateAndPush(polydata,domethod,undomethod,PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,@drawings.AfterAutoProcessGDB) do
                                                                         begin
                                                                              comit;
                                                                         end;

                                                                         //p3dpl^.vertexarrayinocs.InsertElement(PEProp.nearestline,PEProp.dir,@wc);
                                                                         p3dpl^.YouChanged(drawings.GetCurrentDWG^);
                                                                         drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^,dc);
                                                                         //p3dpl^.Format;
                                                                         zcRedrawCurrentDrawing;
                                                                         PEProp.setpoint:=false;
                                                                    end
                                                                else
                                                                    begin
                                                                         PEProp.setpoint:=true;
                                                                    end;


                                        end;

       if (PEProp.Action=TSPE_Scissor) then
       begin
       if PEProp.vdist>PEProp.ldist+bigeps then
                                        begin
                                        p3dpl2 := pointer(p3dpl^.Clone(p3dpl^.bp.ListPos.Owner));
                                        drawings.GetCurrentROOT^.AddObjectToObjArray(@p3dpl2);
                                        _tv:=NearestPointOnSegment(wc,PEProp.lvertex1,PEProp.lvertex2);
                                        for i:=0 to p3dpl^.VertexArrayInOCS.count-1 do
                                          begin
                                               if i<PEProp.nearestline then
                                                                             p3dpl2^.VertexArrayInOCS.DeleteElement(0);
                                               if i>PEProp.nearestline-1 then
                                                                             p3dpl^.VertexArrayInOCS.DeleteElement(PEProp.nearestline{+1});

                                          end;
                                        (*if p3dpl2^.VertexArrayInOCS.Count>1 then
                                                                               p3dpl2^.VertexArrayInOCS.InsertElement({0}1,{1,}_tv)
                                                                           else*)
                                                                               p3dpl2^.VertexArrayInOCS.InsertElement(0,{-1,}_tv);
                                        p3dpl^.VertexArrayInOCS.InsertElement(p3dpl^.VertexArrayInOCS.Count,{1,}_tv);
                                        p3dpl2^.Formatentity(drawings.GetCurrentDWG^,dc);
                                        p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
                                        drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl2^);
                                        end
                                    else
                                    begin
                                         if (PEProp.nearestvertex=0)or(PEProp.nearestvertex=p3dpl^.VertexArrayInOCS.Count-1) then
                                         begin
                                              ZCMsgCallBackInterface.TextMessage(rscmNotCutHere,TMWOShowError);
                                              exit;
                                         end;
                                         p3dpl2 := pointer(p3dpl^.Clone(p3dpl^.bp.ListPos.Owner));
                                         drawings.GetCurrentROOT^.AddObjectToObjArray(@p3dpl2);

                                         for i:=0 to p3dpl^.VertexArrayInOCS.count-1 do
                                           begin
                                                if i<PEProp.nearestvertex then
                                                                              p3dpl2^.VertexArrayInOCS.DeleteElement(0);
                                                if i>PEProp.nearestvertex then
                                                                              p3dpl^.VertexArrayInOCS.DeleteElement(PEProp.nearestvertex+1);

                                           end;
                                         p3dpl2^.Formatentity(drawings.GetCurrentDWG^,dc);
                                         p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
                                         drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl2^);
                                    end

       end;
      zcRedrawCurrentDrawing;
      //drawings.GetCurrentDWG^.OGLwindow1.draw;

  end
end;

{function _3DPolyEd_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: Byte;osp:pos_record;mclick:Integer): Integer;
var po:PGDBObjSubordinated;
begin
  exit;
  result:=mclick;
  p3dpl^.vp.Layer :=drawings.LayerTable.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  //p3dpl^.CoordInOCS.lEnd:= wc;
  p3dpl^.Format;
  if button = 1 then
  begin
    p3dpl^.AddVertex(wc);
    p3dpl^.RenderFeedback;
    drawings.GetCurrentDWG^.ConstructObjRoot.Count := 0;
    result:=1;
    redrawoglwnd;
  end;
end;}

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  PEProp.Action:=TSPE_Insert;
  SysUnit^.RegisterType(TypeInfo(TPolyEdit));//регистрируем тип данных в зкадном RTTI
  SysUnit^.SetTypeDesk(TypeInfo(TPolyEdit),['Action','Mode','vdist','ldist','nearestvertex','nearestline','dir','setpoint','vvertex','lvertex1','lvertex2']);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел
  SysUnit^.SetTypeDesk(TypeInfo(TSubPolyEdit),['TSPE_Insert','TSPE_Remove','TSPE_Scissor']);//Даем человечьи имена параметрам
  SysUnit^.SetTypeDesk(TypeInfo(TPolyEditMode),['TPEM_Nearest','TPEM_Select']);//Даем человечьи имена параметрам

  CreateCommandRTEdObjectPlugin(@_3DPolyEd_com_CommandStart,nil,nil,nil,@_3DPolyEd_com_BeforeClick,@_3DPolyEd_com_BeforeClick,nil,nil,'PolyEd',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
