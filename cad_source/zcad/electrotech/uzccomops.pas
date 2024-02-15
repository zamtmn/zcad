(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzccomops;
{$INCLUDE zengineconfig.inc}
interface
uses

  uzctranslations,uzeentitiesmanager,uzeentity,uzglviewareaabstract,uzgldrawcontext,
  uzeentabstracttext,uzeenttext,uzctnrvectorstrings,uzeentityfactory,uzcsysvars,uzbstrproc,
  uzcinterface,uzccommandsmanager,
  uzccommandsabstract,uzccommandsimpl,uzbtypes,uzcdrawings,uzeutils,uzcutils,sysutils,
  varmandef,uzctnrVectorBytes,uzegeometry,uzeconsts,
  uzccomdraw,UGDBVisibleOpenArray,uzeentline,uzbpaths,uzeentblockinsert,
  uzegeometrytypes,varman,uzccablemanager,uzeentdevice,uzeentmtext,math,
  uzcenitiesvariablesextender,uzeroot,uzglviewareadata,uzcentcable,UUnitManager,
  gzctnrVectorTypes,uzccomelectrical,URecordDescriptor,TypeDescriptors,uzcLog,
  uzcstrconsts,uzccmdfloatinsert,uzctnrvectorpgdbaseobjects;

type
  TPlaceParam=record
                    PlaceFirst:boolean;
                    PlaceFirstOffset:double;
                    PlaceLast:boolean;
                    PlaceLastOffset:double;
                    OtherStep:double;
  end;
{Export+}
  TInsertType=(
               TIT_Block(*'Block'*),
               TIT_Device(*'Device'*)
              );
  TOPSDatType=(
               TOPSDT_Termo(*'Termo'*),
               TOPSDT_Smoke(*'Smoke'*)
              );
  TOPSMinDatCount=(
                   TOPSMDC_1_4(*'1 in the quarter'*),
                   TOPSMDC_1_2(*'1 in the middle'*),
                   TOPSMDC_2(*'2'*),
                   TOPSMDC_3(*'3'*),
                   TOPSMDC_4(*'4'*)
                  );
  TODPCountType=(
                   TODPCT_by_Count(*'by number'*),
                   TODPCT_by_XY(*'by width/height'*)
                 );
  TPlaceSensorsStrategy=(
                  TPSS_Proportional(*'Proportional'*),
                  TPSS_FixDD(*'Sensor-Sensor distance fix'*),
                  TPSS_FixDW(*'Sensor-Wall distance fix'*),
                  TPSS_ByNum(*'By number'*)
                  );
  TAxisReduceDistanceMode=(TARDM_Nothing(*'Nothing'*),
                           TARDM_LongAxis(*'Long axis'*),
                           TARDM_ShortAxis(*'Short axis'*),
                           TARDM_AllAxis(*'All xxis'*));
  PTOPSPlaceSmokeDetectorOrtoParam=^TOPSPlaceSmokeDetectorOrtoParam;
  {REGISTERRECORDTYPE TOPSPlaceSmokeDetectorOrtoParam}
  TOPSPlaceSmokeDetectorOrtoParam=record
                                        InsertType:TInsertType;(*'Insert'*)
                                        Scale:Double;(*'Plan scale'*)
                                        ScaleBlock:Double;(*'Blocks scale'*)
                                        StartAuto:Boolean;(*'"Start" signal'*)
                                        SensorSensorDistance:TAxisReduceDistanceMode;(*'Sensor-sensor distance reduction'*)
                                        SensorWallDistance:TAxisReduceDistanceMode;(*'Sensor-wall distance reduction'*)
                                        DatType:TOPSDatType;(*'Sensor type'*)
                                        DMC:TOPSMinDatCount;(*'Min. number of sensors'*)
                                        Height:TEnumData;(*'Height of installation'*)
                                        ReductionFactor:Double;(*'Reduction factor'*)
                                        NDD:Double;(*'Sensor-Sensor(standard)'*)
                                        NDW:Double;(*'Sensor-Wall(standard)'*)
                                        PlaceStrategy:TPlaceSensorsStrategy;
                                        FDD:Double;(*'Sensor-Sensor(fact)'*)(*oi_readonly*)
                                        FDW:Double;(*'Sensor-Wall(fact)'*)(*oi_readonly*)
                                        NormalizePoint:Boolean;(*'Normalize to grid (if enabled)'*)

                                        oldth:Integer;(*hidden_in_objinsp*)
                                        oldsh:Integer;(*hidden_in_objinsp*)
                                        olddt:TOPSDatType;(*hidden_in_objinsp*)
                                  end;
  PTOrtoDevPlaceParam=^TOrtoDevPlaceParam;
  {REGISTERRECORDTYPE TOrtoDevPlaceParam}
  TOrtoDevPlaceParam=record
                                        Name:String;(*'Block'*)(*oi_readonly*)
                                        ScaleBlock:Double;(*'Blocks scale'*)
                                        CountType:TODPCountType;(*'Type of placement'*)
                                        Count:Integer;(*'Total number'*)
                                        NX:Integer;(*'Number of length'*)
                                        NY:Integer;(*'Number of width'*)
                                        Angle:Double;(*'Rotation'*)
                                        AutoAngle:Boolean;(*'Auto rotation'*)
                                        NormalizePoint:Boolean;(*'Normalize to grid (if enabled)'*)

                     end;
  {REGISTERRECORDTYPE GDBLineOps}
     GDBLineOps=record
                  lBegin,lEnd:GDBvertex;
              end;
   {REGISTEROBJECTTYPE OPS_SPBuild}
  OPS_SPBuild= object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;
{Export-}
var
   pco,pco2:pCommandRTEdObjectPlugin;
   //pwnd:POGLWndtype;
   t3dp: gdbvertex;
   //pgdbinplugin: PTZCADDrawingsManager;
   //psysvarinplugin: pgdbsysvariable;
   pvarman:pvarmanagerdef;
   pdw,pdd,pdtw,pdtd:PDouble;
   pdt:pinteger;
   sdname:String;

   OPSPlaceSmokeDetectorOrtoParam:TOPSPlaceSmokeDetectorOrtoParam;
   OrtoDevPlaceParam:TOrtoDevPlaceParam;

   OPS_SPBuild_com:OPS_SPBuild;
//procedure Getmem(var p:pointer; const size: LongWord); external 'cad.exe';
//procedure Freemem(var p: pointer); external 'cad.exe';

//procedure HistoryOut(s: pchar); external 'cad.exe';
//function getprogramlog:pointer; external 'cad.exe';
//function getcommandmanager:pointer;external 'cad.exe';
//function getgdb: pointer; external 'cad.exe';
//procedure addblockinsert(pva: PGDBObjEntityOpenArray; point: gdbvertex; scale, angle: gldouble; s: pchar);external 'cad.exe';
//function Vertexmorph(Vector1, Vector2: GDBVertex; a: gldouble): GDBVertex; external 'cad.exe';
//function VertexDmorph(Vector1, Vector2: GDBVertex; a: gldouble): GDBVertex; external 'cad.exe';
//function Vertexlength(Vector1, Vector2: GDBVertex): gldouble; external 'cad.exe';
//function Vertexangle(Vector1, Vector2: GDBVertex): gldouble; external 'cad.exe';
//function Vertexdmorphabs(Vector1, Vector2: GDBVertex; a: gldouble): GDBVertex; external 'cad.exe';
//function Vertexmorphabs(Vector1, Vector2: GDBVertex; a: gldouble): GDBVertex; external 'cad.exe';
//function redrawoglwnd: integer; external 'cad.exe';
//function getpsysvar: pointer; external 'cad.exe';
//function GetPZWinManager:PTZWinManager; external 'cad.exe';
//procedure GDBObjLineInit(own:PGDBObjGenericSubEntry;var pobjline: PGDBObjLine; layerindex, LW: smallint; p1, p2: GDBvertex); external 'cad.exe';

//function GetPVarMan: pointer; external 'cad.exe';


//function CreateCommandRTEdObjectPlugin(ocs,oce,occ:comproc;obc,oac:commousefunc;name:pchar):pCommandRTEdObjectPlugin; external 'cad.exe';
{
//procedure builvldtable(x,y,z:gldouble);

}
{procedure startup;
procedure finalize;}

implementation
function docorrecttogrid(point:GDBVertex;need:Boolean):GDBVertex;
var
   gr:Boolean;
begin
     gr:=false;
     if SysVar.DWG.DWG_SnapGrid<>nil then
     if SysVar.DWG.DWG_SnapGrid^ then
                                     gr:=true;
     if (need and gr) then
                          begin
                               result:=correcttogrid(point,SysVar.DWG.DWG_Snap^);
                               {result.x:=round((point.x-SysVar.DWG.DWG_Snap.Base.x)/SysVar.DWG.DWG_Snap.Spacing.x)*SysVar.DWG.DWG_Snap.Spacing.x+SysVar.DWG.DWG_Snap.Spacing.x;
                               result.y:=round((point.y-SysVar.DWG.DWG_Snap.Base.y)/SysVar.DWG.DWG_Snap.Spacing.y)*SysVar.DWG.DWG_Snap.Spacing.y+SysVar.DWG.DWG_Snap.Spacing.y;
                               result.z:=point.z;}
                          end
                      else
                          result:=point;
end;
function GetPlaceParam(count:integer;length,sd,dd:Double;DMC:TOPSMinDatCount;ps:TPlaceSensorsStrategy):TPlaceParam;
begin
     if count=2 then
     case ps of
 TPSS_FixDD:
            if length<dd then
                             ps:=TPSS_Proportional;
 TPSS_FixDW:
            if length<2*sd then
                             ps:=TPSS_Proportional;
 TPSS_Proportional,TPSS_ByNum:;//заглушка на варнинг
     end;
     case count of
          1:begin
              case dmc of
               TOPSMDC_1_4:result.PlaceFirstOffset:=1/4;
               TOPSMDC_1_2:result.PlaceFirstOffset:=1/2;
               TOPSMDC_2,TOPSMDC_3,TOPSMDC_4:;//заглушка на варнинг
              end;
              result.PlaceFirst:=true;
              result.PlaceLast:=false;
              result.otherstep:=0;
            end;
          else
            begin
              case ps of
    TPSS_Proportional:
                      result.PlaceFirstOffset:=sd/(2*sd+(count-1)*dd);
           TPSS_FixDD:
                      result.PlaceFirstOffset:=(length-((count-1)*dd))/(2*length);
           TPSS_FixDW:
                      result.PlaceFirstOffset:=sd/length;
           TPSS_ByNum:
                      result.PlaceFirstOffset:=1/(count*2);
              end;
              result.PlaceLastOffset:=1-result.PlaceFirstOffset;
              if count>2 then
                             result.otherstep:=(result.PlaceLastOffset-result.PlaceFirstOffset)/(count-1)
                         else
                             result.otherstep:=0;
              result.PlaceFirst:=true;
              result.PlaceLast:=true;
            end;
     end;
end;
procedure place2(pva:PGDBObjEntityOpenArray;basepoint, dir: gdbvertex; count: integer; length,sd,dd: Double; name: pansichar;angle:Double;norm:Boolean;scaleblock:Double;ps:TPlaceSensorsStrategy);
var //line2: GDBLineOps;
    i: integer;
    d: TPlaceParam;
begin
     d:=GetPlaceParam(count,length,sd,dd,OPSPlaceSmokeDetectorOrtoParam.DMC,ps);

     if d.PlaceFirst then
     begin
          old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,pva,
                                     drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                     docorrecttogrid(Vertexdmorph(basepoint, dir, d.PlaceFirstOffset),norm), scaleblock, angle, name)
     end;
     if d.PlaceLast then
     begin
          old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,pva,
                                     drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                     docorrecttogrid(Vertexdmorph(basepoint, dir, d.PlaceLastOffset),norm), scaleblock, angle, name)
     end;
     if count>2 then
     begin
         count := count - 2;
         for i := 1 to count do
         begin
             d.PlaceFirstOffset:=d.PlaceFirstOffset+d.OtherStep;
             old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,pva,
                                        drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                        docorrecttogrid(Vertexdmorph(basepoint, dir, d.PlaceFirstOffset),norm), scaleblock, angle, name)
         end;
     end;
end;
procedure placedatcic(pva:PGDBObjEntityOpenArray;p1, p2: gdbvertex; InitialSD, InitialDD: Double; name: pansichar;norm:Boolean;scaleblock: Double;ps:TPlaceSensorsStrategy);
var dx, dy: Double;
  FirstLine, SecondLine: GDBLineOps;
  FirstCount, SecondCount, i: integer;
  dir: gdbvertex;
  mincount:integer;
  FirstLineLength,SecondLineLength:double;
  d: TPlaceParam;
  LongSD,LongDD: Double;
  ShortSD,ShortDD: Double;
begin
  dx := p2.x - p1.x;
  dy := p2.y - p1.y;
  dx := abs(dx);
  dy := abs(dy);
  FirstLine.lbegin := p1;
  SecondLine.lbegin := p1;
  if dx < dy then
  begin
    FirstLine.lend.x := p2.x;
    FirstLine.lend.y := p1.y;
    FirstLine.lend.z := 0;
    SecondLine.lend.x := p1.x;
    SecondLine.lend.y := p2.y;
    SecondLine.lend.z := 0;
  end
  else
  begin
    FirstLine.lend.x := p1.x;
    FirstLine.lend.y := p2.y;
    FirstLine.lend.z := 0;
    SecondLine.lend.x := p2.x;
    SecondLine.lend.y := p1.y;
    SecondLine.lend.z := 0;
  end;
  dir.x := SecondLine.lend.x - SecondLine.lbegin.x;
  dir.y := SecondLine.lend.y - SecondLine.lbegin.y;
  dir.z := SecondLine.lend.z - SecondLine.lbegin.z;

  LongSD:=InitialSD;
  LongDD:=InitialDD;
  ShortSD:=InitialSD;
  ShortDD:=InitialDD;
  if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
  begin
  case OPSPlaceSmokeDetectorOrtoParam.SensorSensorDistance of
                                            TARDM_LongAxis:LongDD:=LongDD/2;
                                           TARDM_ShortAxis:ShortDD:=ShortDD/2;
                                             TARDM_AllAxis:begin
                                                            LongDD:=LongDD/2;
                                                            ShortDD:=ShortDD/2;
                                                           end;
                                             TARDM_Nothing:;//заглушка на варнинг
  end;
  case OPSPlaceSmokeDetectorOrtoParam.SensorWallDistance of
                                            TARDM_LongAxis:LongSD:=LongSD/2;
                                           TARDM_ShortAxis:ShortSD:=ShortSD/2;
                                             TARDM_AllAxis:begin
                                                            LongSD:=LongSD/2;
                                                            ShortSD:=ShortSD/2;
                                                           end;
                                             TARDM_Nothing:;//заглушка на варнинг
  end;
  end;
  if (Vertexlength(FirstLine.lbegin, FirstLine.lend) - 2 * ShortSD)>0 then FirstCount := round(abs(Vertexlength(FirstLine.lbegin, FirstLine.lend) - 2 * ShortSD) / ShortDD- eps + 1.5)
                                                         else FirstCount := 1;
  if (Vertexlength(SecondLine.lbegin, SecondLine.lend) - 2 * LongSD)>0 then SecondCount := round(abs(Vertexlength(SecondLine.lbegin, SecondLine.lend) - 2 * LongSD) / LongDD-eps + 1.5)
                                                         else SecondCount := 1;
  mincount:=2;
  case OPSPlaceSmokeDetectorOrtoParam.DMC of
                                            TOPSMDC_1_4:mincount:=1;
                                            TOPSMDC_1_2:mincount:=1;
                                            TOPSMDC_2:;//заглушка на варнинг
                                            TOPSMDC_3:mincount:=3;
                                            TOPSMDC_4:mincount:=4;
                                          end;
  if FirstCount <= 0 then FirstCount := 1;
  if SecondCount <= 0 then SecondCount := 1;
  if (FirstCount*SecondCount)<mincount then
                          begin
                             case OPSPlaceSmokeDetectorOrtoParam.DMC of
                               TOPSMDC_2:SecondCount:=2;
                               TOPSMDC_3:SecondCount:=3;
                               TOPSMDC_4:
                                         begin
                                              SecondCount:=2;
                                              FirstCount:=2;
                                         end;
                               TOPSMDC_1_4,TOPSMDC_1_2:;//заглушка на варнинг
                             end;
                         end;
  SecondLineLength:=oneVertexlength(dir);
  FirstLineLength:=Vertexlength(FirstLine.lbegin, FirstLine.lend);

  d:=GetPlaceParam(FirstCount,FirstLineLength,ShortSD,ShortDD,TOPSMDC_1_2,ps);

  if d.PlaceFirst then
  begin
       place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend,d.PlaceFirstOffset), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
  end;
  if d.PlaceLast then
  begin
       place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend,d.PlaceLastOffset), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
  end;
  if FirstCount>2 then
  begin
       FirstCount := FirstCount - 2;
       for i := 1 to FirstCount do
       begin
           d.PlaceFirstOffset:=d.PlaceFirstOffset+d.OtherStep;
           place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend,d.PlaceFirstOffset), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
       end;
  end;

  {case FirstCount of
    1: begin
          place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend, 0.5), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
       end;
    2: begin
        if ((Vertexlength(FirstLine.lbegin, FirstLine.lend) - 2 * LongSD)<LongDD) then
        begin
          place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend, 1 / 4), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
          place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend, 3 / 4), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
        end
        else
          begin
          place2(pva,Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, LongSD), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
          place2(pva,Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, -LongSD), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
        end
       end
  else begin
          place2(pva,Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, LongSD), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
          place2(pva,Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, -LongSD), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
          SecondLine.lbegin := Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, LongSD);
          SecondLine.lend := Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, -LongSD);
          FirstCount:=FirstCount-2;
          for i := 1 to FirstCount do place2(pva,Vertexmorph(SecondLine.lbegin, SecondLine.lend, i / (FirstCount + 1)), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
       end
  end;}
end;
function CommandStart(const Context:TZCADCommandContext;operands:pansichar):Integer;
begin
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_PS_DAT_SMOKE');
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_PS_DAT_TERMO');
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera));
  ZCMsgCallBackInterface.TextMessage(rscmFirstCorner,TMWOHistoryOut);
  zcShowCommandParams(SysUnit.TypeName2PTD('CommandRTEdObject'),pco);
  result:=cmd_ok;
end;
function BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): integer;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
    //if pco^.mouseclic = 1 then
    begin
      ZCMsgCallBackInterface.TextMessage(rscmSecondCorner,TMWOHistoryOut);
      t3dp:=wc;
    end;
end;
function AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer):Integer;
var
pl:pgdbobjline;
//debug:string;
dw,dd:Double;
DC:TDrawContext;
begin


  dw:=OPSPlaceSmokeDetectorOrtoParam.NDW/OPSPlaceSmokeDetectorOrtoParam.Scale;
  dd:=OPSPlaceSmokeDetectorOrtoParam.NDD/OPSPlaceSmokeDetectorOrtoParam.Scale;
  if OPSPlaceSmokeDetectorOrtoParam.ReductionFactor<>0 then
  begin
       dw:=dw*OPSPlaceSmokeDetectorOrtoParam.ReductionFactor;
       dd:=dd*OPSPlaceSmokeDetectorOrtoParam.ReductionFactor;
  end;
  {if drawings.GetCurrentDWG.BlockDefArray.getindex(@sdname[1])<0 then
                                                         begin
                                                              sdname:=sdname;
                                                              //drawings.GetCurrentDWG.BlockDefArray.loadblock(pansichar(sysinfo.sysparam.programpath+'blocks\ops\'+sdname+'.dxf'),@sdname[1],drawings.GetCurrentDWG)
                                                         end;}
  result:=mclick;
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.free;

  pl := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                    drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                    t3dp,wc));
  zcSetEntPropFromCurrentDrawingProp(pl);

  //pl := pointer(drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID{,drawings.GetCurrentROOT}));
  //GDBObjLineInit(drawings.GetCurrentROOT,pl, drawings.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^, t3dp, wc);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  if (button and MZW_LBUTTON)=0 then
  begin
       placedatcic(@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, dw, dd,@sdname[1],OPSPlaceSmokeDetectorOrtoParam.NormalizePoint,OPSPlaceSmokeDetectorOrtoParam.ScaleBlock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
  end
  else
  begin
       result:=-1;
       //pco^.mouseclic:=-1;
       //drawings.GetCurrentDWG.ConstructObjRoot.cleareraseobj;
       placedatcic(@drawings.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, dw, dd,@sdname[1],OPSPlaceSmokeDetectorOrtoParam.NormalizePoint,OPSPlaceSmokeDetectorOrtoParam.ScaleBlock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
       drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.free;

       drawings.GetCurrentROOT.calcbb(dc);
       zcRedrawCurrentDrawing;
       ZCMsgCallBackInterface.TextMessage(rscmFirstCorner,TMWOHistoryOut);
       //commandend;
       //pcommandmanager^.executecommandend;
  end;
//  if button = 1 then
//  begin
//    pgdbinplugin^.ObjArray.add(addr(pc));
//    pgdbinplugin^.ConstructObjRoot.Count := 0;
//    commandend;
//    executecommandend;
//  end;
end;
procedure commformat;
var s:String;
    pcfd:PRecordDescriptor;
    pf:PfieldDescriptor;
begin
  pcfd:=pointer(SysUnit.TypeName2PTD('TOPSPlaceSmokeDetectorOrtoParam'));
  if pcfd<>nil then
  begin
  pf:=pcfd^.FindField('SensorSensorDistance');
  if pf<>nil then
                 begin
                    if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                                                                    pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY)
                                                                else
                                                                    pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;
                 end;
  pf:=pcfd^.FindField('SensorWallDistance');
  if pf<>nil then
                 begin
                    if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                                                                    pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY)
                                                                else
                                                                    pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;
                 end;
  end;
//     sdname:=sdname;
     if OPSPlaceSmokeDetectorOrtoParam.DatType<>OPSPlaceSmokeDetectorOrtoParam.olddt then
     begin
          OPSPlaceSmokeDetectorOrtoParam.olddt:=OPSPlaceSmokeDetectorOrtoParam.DatType;
          OPSPlaceSmokeDetectorOrtoParam.Height.Enums.clear;
          case OPSPlaceSmokeDetectorOrtoParam.DatType of
               TOPSDT_Smoke:begin
                                 s:='До 3,5м';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 s:='Св. 3,5 до 6,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 s:='Св. 6,0 до 10,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 s:='Св. 10,5 до 12,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 s:='Не норм.';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 OPSPlaceSmokeDetectorOrtoParam.oldth:=OPSPlaceSmokeDetectorOrtoParam.Height.Selected;
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Selected:=OPSPlaceSmokeDetectorOrtoParam.oldsh;
                            end;
               TOPSDT_Termo:begin
                                 s:='До 3,5м';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 s:='Св. 3,5 до 6,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 s:='Св. 6,0 до 9,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 s:='Не норм.';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.PushBackData(s);
                                 OPSPlaceSmokeDetectorOrtoParam.oldsh:=OPSPlaceSmokeDetectorOrtoParam.Height.Selected;
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Selected:=OPSPlaceSmokeDetectorOrtoParam.oldth;
                            end;
          end;
     end;
     case OPSPlaceSmokeDetectorOrtoParam.DatType of
          TOPSDT_Smoke:begin
                            case OPSPlaceSmokeDetectorOrtoParam.Height.Selected of
                               0:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=4500;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=9000;
                                 end;
                               1:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=4000;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=8500;
                                 end;
                               2:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=4000;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=8000;
                                 end;
                               3:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=3500;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=7500;
                                 end;
                           end;
                               {if (OPSPlaceSmokeDetectorOrtoParam.Height.Selected<>4)and OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                               begin
                                    OPSPlaceSmokeDetectorOrtoParam.NDW:=OPSPlaceSmokeDetectorOrtoParam.NDW/2;
                                    OPSPlaceSmokeDetectorOrtoParam.NDD:=OPSPlaceSmokeDetectorOrtoParam.NDD/2;
                               end;}
                           sdname:='PS_DAT_SMOKE';
                     end;
          TOPSDT_Termo:begin
               case OPSPlaceSmokeDetectorOrtoParam.Height.Selected of
                               0:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=2500;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=5000;
                                 end;
                               1:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=2000;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=4500;
                                 end;
                               2:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=2000;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=4000;
                                 end;
               end;
                               {if (OPSPlaceSmokeDetectorOrtoParam.Height.Selected<>3)and OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                               begin
                                    OPSPlaceSmokeDetectorOrtoParam.NDW:=OPSPlaceSmokeDetectorOrtoParam.NDW/2;
                                    OPSPlaceSmokeDetectorOrtoParam.NDD:=OPSPlaceSmokeDetectorOrtoParam.NDD/2;
                               end;}
               sdname:='PS_DAT_TERMO';
                            end;
     end;
    if OPSPlaceSmokeDetectorOrtoParam.InsertType=TIT_Device then
                                                                sdname:=DevicePrefix+sdname;
end;
{function OPS_Sensor_Mark_com(Operands:pansichar):Integer;
var i: Integer;
    pcable:pGDBObjCable;
    ir,ir_inNodeArray:itrec;
    pvd:pvardesk;
    currentunit:TUnit;
    ucount:Integer;
    ptn:PTNodeProp;
    p:pointer;
    cman:TCableManager;
begin
  if drawings.GetCurrentDWG.ObjRoot.ObjArray.Count = 0 then exit;
  cman.init;
  cman.build;
  cman.done;

  currentunit.init('calc');
  units.loadunit(expandpath('*rtl\objcalc\opsmarkdef.pas'),(@currentunit));
  pcable:=gdb.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
  if pcable<>nil then
  repeat
        if pcable^.GetObjType=GDBCableID then
        begin
             pvd:=currentunit.FindVariable('CDC_temp');
             PInteger(pvd.Instance)^:=0;
             pvd:=currentunit.FindVariable('CDSC_temp');
             PInteger(pvd.Instance)^:=0;
             p:=@pcable.ou;
             currentunit.InterfaceUses.addnodouble(@p);
             ucount:=currentunit.InterfaceUses.Count;





             ptn:=pcable^.NodePropArray.beginiterate(ir_inNodeArray);
             if ptn<>nil then
                repeat
                    if ptn^.DevLink<>nil then
                    begin
                         p:=@ptn^.DevLink^.bp.Owner.ou;
                         currentunit.InterfaceUses.addnodouble(@p);

                         units.loadunit(expandpath('*rtl\objcalc\opsmark.pas'),(@currentunit));

                         dec(currentunit.InterfaceUses.Count);

                         ptn^.DevLink^.bp.Owner^.Format;
                     end;

                    ptn:=pcable^.NodePropArray.iterate(ir_inNodeArray);
                until ptn=nil;




             currentunit.InterfaceUses.Count:=ucount-1;
        end;
  pcable:=drawings.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
  until pcable=nil;

  currentunit.done;
  redrawoglwnd;
  result:=cmd_ok;
end;}
function OPS_Sensor_Mark_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var //i: Integer;
    pcabledesk:PTCableDesctiptor;
    ir,ir2,ir_inNodeArray:itrec;
    pvd:pvardesk;
    defaultunit:TUnit;
    currentunit:PTUnit;
    UManager:TUnitManager;
    ucount:Integer;
    ptn:PGDBObjDevice;
    p:pointer;
    cman:TCableManager;
    SaveEntUName,SaveCabUName:String;
    cablemetric,devicemetric,numingroupmetric:String;
    ProcessedDevices:TZctnrVectorPGDBaseObjects;
    name:String;
    DC:TDrawContext;
    pcablestartsegmentvarext,pptnownervarext:TVariablesExtender;
const
      DefNumMetric='default_num_in_group';
function GetNumUnit(uname:String):PTUnit;
begin
     //result:=nil;
     result:=UManager.internalfindunit(uname);
     if result=nil then
     begin
          result:=pointer(UManager.CreateObject);
          result.init(uname);
          result.CopyFrom(@defaultunit);
     end;
end;

begin
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if drawings.GetCurrentROOT.ObjArray.Count = 0 then exit;
  ProcessedDevices.init(100);
  cman.init;
  cman.build;
  UManager.init;

  defaultunit.init(DefNumMetric);
  units.loadunit(GetSupportPath,InterfaceTranslate,expandpath('*rtl/objcalc/opsmarkdef.pas'),(@defaultunit));
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
  repeat
        begin
            pcablestartsegmentvarext:=pcabledesk.StartSegment^.GetExtension<TVariablesExtender>;
            //pvd:=PTEntityUnit(pcabledesk.StartSegment.ou.Instance)^.FindVariable('GC_Metric');
            pvd:=pcablestartsegmentvarext.entityunit.FindVariable('GC_Metric');
            if pvd<>nil then
                            begin
                                 cablemetric:=pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance);
                            end
                        else
                            begin
                                 cablemetric:='';
                            end;

             currentunit:=Umanager.beginiterate(ir2);
             if currentunit<>nil then
             repeat
             pvd:=currentunit.FindVariable('CDC_temp');
             PInteger(pvd.data.Addr.Instance)^:=0;
             pvd:=currentunit.FindVariable('CDSC_temp');
             PInteger(pvd.data.Addr.Instance)^:=1;
             currentunit:=Umanager.iterate(ir2);
             until currentunit=nil;
             currentunit:=nil;





             ptn:=pcabledesk^.Devices.beginiterate(ir_inNodeArray);
             if ptn<>nil then
                repeat
                    begin
                        pptnownervarext:=ptn^.bp.ListPos.Owner^.GetExtension<TVariablesExtender>;
                        //pvd:=PTEntityUnit(ptn^.bp.ListPos.Owner.ou.Instance)^.FindVariable('GC_Metric');
                        pvd:=pptnownervarext.entityunit.FindVariable('GC_Metric');
                        if pvd<>nil then
                                        begin
                                             devicemetric:=pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance);
                                        end
                                    else
                                        begin
                                             devicemetric:='';
                                        end;
                        //pvd:=PTEntityUnit(ptn^.bp.ListPos.Owner.ou.Instance)^.FindVariable('GC_InGroup_Metric');
                        pvd:=pptnownervarext.entityunit.FindVariable('GC_InGroup_Metric');
                                        if pvd<>nil then
                                                        begin
                                                             numingroupmetric:=pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance);
                                                             if numingroupmetric='' then
                                                                                        numingroupmetric:=DefNumMetric;

                                                        end
                                                    else
                                                        begin
                                                             numingroupmetric:=DefNumMetric;
                                                        end;
                        if devicemetric=cablemetric then
                        begin
                        if ProcessedDevices.IsDataExist(@ptn^.bp.ListPos.Owner^)=-1 then
                    begin
                         currentunit:=GetNumUnit(numingroupmetric);

                         SaveCabUName:=pcablestartsegmentvarext.entityunit.Name;
                         pcablestartsegmentvarext.entityunit.Name:='Cable';
                         p:=@pcablestartsegmentvarext.entityunit;
                         currentunit.InterfaceUses.PushBackIfNotPresent(p);
                         ucount:=currentunit.InterfaceUses.Count;

                         SaveEntUName:=pptnownervarext.entityunit.Name;
                         pptnownervarext.entityunit.Name:='Entity';
                         p:=@pptnownervarext.entityunit;
                         currentunit.InterfaceUses.PushBackIfNotPresent(p);

                         units.loadunit(GetSupportPath,InterfaceTranslate,expandpath('*rtl/objcalc/opsmark.pas'),(currentunit));

                         ProcessedDevices.PushBackData(ptn^.bp.ListPos.Owner);

                         dec(currentunit.InterfaceUses.Count,2);

                         pptnownervarext.entityunit.Name:=SaveEntUName;
                         pcablestartsegmentvarext.entityunit.Name:=SaveCabUName;

                         PGDBObjLine(ptn^.bp.ListPos.Owner)^.Formatentity(drawings.GetCurrentDWG^,dc);
                    end
                        else
                            begin
                            pvd:=pptnownervarext.entityunit.FindVariable('NMO_Name');
                            if pvd<>nil then
                                        begin
                                             name:='"'+pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance)+'"';
                                        end
                                    else
                                        begin
                                             name:='"без имени"';
                                        end;
                            ZCMsgCallBackInterface.TextMessage(format('Попытка повторной нумерации устройства %s кабелем (сегментом кабеля) %s',[name,'"'+pcabledesk^.Name+'"']),TMWOHistoryOut);
                            end;
                        end;

                    end;
                    //ptn^.bp.ListPos.Owner.ou.Name:=SaveEntUName;
                    ptn:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                until ptn=nil;



             if currentunit<>nil then
             currentunit.InterfaceUses.Count:=ucount-1;
        end;
  pcablestartsegmentvarext.entityunit.Name:=SaveCabUName;
  pcabledesk:=cman.iterate(ir);
  until pcabledesk=nil;

  defaultunit.done;
  UManager.done;
  cman.done;
  ProcessedDevices.Clear;
  ProcessedDevices.Done;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;
procedure InsertDat2(datname,name:String;var currentcoord:GDBVertex; var root:GDBObjRoot);
var
   pv:pGDBObjDevice;
   pt:pGDBObjMText;
   lx,{rx,}uy,dy:Double;
   tv:gdbvertex;
   DC:TDrawContext;
begin
     //name:=uzbstrproc.Tria_Utf8ToAnsi(name);

     drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,datname);
     pointer(pv):=old_ENTF_CreateBlockInsert(drawings.GetCurrentROOT,@{drawings.GetCurrentROOT}root.ObjArray,
                                         drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                         currentcoord, 1, 0,datname);
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     zcSetEntPropFromCurrentDrawingProp(pv);
     pv^.formatentity(drawings.GetCurrentDWG^,dc);
     pv^.getoutbound(dc);

     lx:=pv.P_insert_in_WCS.x-pv.vp.BoundingBox.LBN.x;
     //rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
     dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
     uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;

     pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
     pv^.Formatentity(drawings.GetCurrentDWG^,dc);

     tv:=currentcoord;
     tv.x:=tv.x-lx-1;
     tv.y:=tv.y+(dy+uy)/2;

     if name<>'' then
     begin
     pt:=pointer(AllocEnt(GDBMtextID));
     pt^.init({drawings.GetCurrentROOT}@root,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,UTF8Decode(name),tv,2.5,0,0.65,RightAngle,jsbc,1,1);
     pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
     root.ObjArray.AddPEntity(pt^);
     zcSetEntPropFromCurrentDrawingProp(pt);
     pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
     pt^.Formatentity(drawings.GetCurrentDWG^,dc);
     end;

     currentcoord.y:=currentcoord.y+dy+uy;
end;
function InsertDat(datname,sname,ename:String;datcount:Integer;var currentcoord:GDBVertex; var root:GDBObjRoot):pgdbobjline;
var
//   pv:pGDBObjDevice;
//   lx,rx,uy,dy:Double;
   pl:pgdbobjline;
   oldcoord,oldcoord2:gdbvertex;
   DC:TDrawContext;
begin
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     if datcount=1 then
                    InsertDat2(datname,sname,currentcoord,root)
else if datcount>1 then
                    begin
                         InsertDat2(datname,sname,currentcoord,root);
                         oldcoord:=currentcoord;
                         currentcoord.y:=currentcoord.y+10;
                         oldcoord2:=currentcoord;
                         InsertDat2(datname,ename,currentcoord,root);
                    end;
     if datcount=2 then
                       begin
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,oldcoord2);
                         root.ObjArray.AddPEntity(pl^);
                         zcSetEntPropFromCurrentDrawingProp(pl);
                         pl^.Formatentity(drawings.GetCurrentDWG^,dc);
                       end
else if datcount>2 then
                       begin
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord, Vertexmorphabs2(oldcoord,oldcoord2,2));
                         root.ObjArray.AddPEntity(pl^);
                         zcSetEntPropFromCurrentDrawingProp(pl);
                         pl^.Formatentity(drawings.GetCurrentDWG^,dc);
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,4), Vertexmorphabs2(oldcoord,oldcoord2,6));
                         root.ObjArray.AddPEntity(pl^);
                         zcSetEntPropFromCurrentDrawingProp(pl);
                         pl^.Formatentity(drawings.GetCurrentDWG^,dc);
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,8), oldcoord2);
                         root.ObjArray.AddPEntity(pl^);
                         zcSetEntPropFromCurrentDrawingProp(pl);
                         pl^.Formatentity(drawings.GetCurrentDWG^,dc);
                       end;

     oldcoord:=currentcoord;
     currentcoord.y:=currentcoord.y+10;
     pl:=pointer(AllocEnt(GDBLineID));
     pl^.init({drawings.GetCurrentROOT}@root,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,currentcoord);
     root.ObjArray.AddPEntity(pl^);
     zcSetEntPropFromCurrentDrawingProp(pl);
     pl^.Formatentity(drawings.GetCurrentDWG^,dc);
     result:=pl;
end;
procedure OPS_SPBuild.Command(Operands:TCommandOperands);
//function OPS_SPBuild_com(Operands:pansichar):Integer;
var count: Integer;
    pcabledesk:PTCableDesctiptor;
    PCableSS:PGDBObjCable;
    ir,ir_inNodeArray:itrec;
    pvd:pvardesk;
//    currentunit:TUnit;
//    ucount:Integer;
//    ptn:PGDBObjDevice;
//    p:pointer;
    cman:TCableManager;
    pv:pGDBObjDevice;

    coord,currentcoord:GDBVertex;
//    pbd:PGDBObjBlockdef;
    {pvn,pvm,}pvmc{,pvl}:pvardesk;

    nodeend,nodestart:PGDBObjDevice;
    isfirst:boolean;
    startmat,endmat,startname,endname,prevname:String;

    //cmlx,cmrx,cmuy,cmdy:Double;
    {lx,rx,}uy,dy:Double;
    lsave:{integer}PPointer;
    DC:TDrawContext;
    pCableSSvarext,ppvvarext,pnodeendvarext:TVariablesExtender;
begin
  if drawings.GetCurrentROOT.ObjArray.Count = 0 then exit;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  cman.init;
  cman.build;

         drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  coord:=uzegeometry.NulVertex;
  coord.y:=0;
  coord.x:=0;
  prevname:='';
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
  repeat
        PCableSS:=pcabledesk^.StartSegment;
        pCableSSvarext:=PCableSS^.GetExtension<TVariablesExtender>;
        //pvd:=PTEntityUnit(PCableSS.ou.Instance)^.FindVariable('CABLE_Type');     { TODO : Сделать поиск переменных caseнезависимым }
        pvd:=pCableSSvarext.entityunit.FindVariable('CABLE_Type');

        if pvd<>nil then
        begin
             //if PTCableType(pvd^.Instance)^=TCT_ShleifOPS then
             if (pcabledesk.StartDevice<>nil){and(pcabledesk.EndDevice<>nil)} then
             begin
                  ZCMsgCallBackInterface.TextMessage(pcabledesk.Name,TMWOHistoryOut);
                  //programlog.logoutstr(pcabledesk.Name,0);
                  currentcoord:=coord;
                  PTCableType(pvd^.data.Addr.Instance)^:=TCT_ShleifOPS;
                  lsave:=SysVar.dwg.DWG_CLayer^;
                  SysVar.dwg.DWG_CLayer^:=drawings.GetCurrentDWG.LayerTable.GetSystemLayer;

                  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_CABLE_MARK');
                  pointer(pv):=old_ENTF_CreateBlockInsert(@drawings.GetCurrentDWG.ConstructObjRoot,@{drawings.GetCurrentROOT.ObjArray}drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,
                                                      drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                                      currentcoord, 1, 0,'DEVICE_CABLE_MARK');
                  zcSetEntPropFromCurrentDrawingProp(pv);

                  SysVar.dwg.DWG_CLayer^:=lsave;
                  ppvvarext:=pv^.GetExtension<TVariablesExtender>;
                  //pvmc:=PTEntityUnit(pv^.ou.Instance)^.FindVariable('CableName');
                  pvmc:=ppvvarext.entityunit.FindVariable('CableName');
                  if pvmc<>nil then
                  begin
                      pstring(pvmc^.data.Addr.Instance)^:=pcabledesk.Name;
                  end;
                  Cable2CableMark(pcabledesk,pv);
                  pv^.formatentity(drawings.GetCurrentDWG^,dc);
                  pv^.getoutbound(dc);

                  //lx:=pv.P_insert_in_WCS.x-pv.vp.BoundingBox.LBN.x;
                  //rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
                  dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
                  uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;

                  pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
                  pv^.Formatentity(drawings.GetCurrentDWG^,dc);
                  currentcoord.y:=currentcoord.y+dy+uy;


                  isfirst:=true;
                  {nodeend:=}pcabledesk^.Devices.beginiterate(ir_inNodeArray);
                  nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                  nodestart:=nil;
                  count:=0;
                  if nodeend<>nil then
                  repeat
                        if nodeend^.bp.ListPos.Owner<>pointer(drawings.GetCurrentROOT) then
                                                                          nodeend:=pointer(nodeend^.bp.ListPos.Owner);
                        pnodeendvarext:=nodeend^.GetExtension<TVariablesExtender>;
                        //pvd:=PTEntityUnit(nodeend^.ou.Instance)^.FindVariable('NMO_Name');
                        pvd:=pnodeendvarext.entityunit.FindVariable('NMO_Name');
                        if pvd<>nil then
                        begin
                             //endname:=pstring(pvd^.Instance)^;
                             endname:=pvd^.data.PTD.GetValueAsString(pvd^.data.Addr.Instance);
                        end
                           else endname:='';
                        //pvd:=PTEntityUnit(nodeend^.ou.Instance)^.FindVariable('DB_link');
                        pvd:=pnodeendvarext.entityunit.FindVariable('DB_link');
                        if pvd<>nil then
                        begin
                            //endmat:=pstring(pvd^.Instance)^;
                            endmat:=nodeend^.Name+pvd^.data.PTD.GetValueAsString(pvd^.data.Addr.Instance);
                            if isfirst then
                                           begin
                                                isfirst:=false;
                                                nodestart:=nodeend;
                                                startmat:=endmat;
                                                startname:=endname;
                                           end;
                            if startmat<>endmat then
                            begin
                                 InsertDat(nodestart^.name,startname,prevname,count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot);
                                 count:=0;
                                 nodestart:=nodeend;
                                 startmat:=endmat;
                                 startname:=endname;
                                 //isfirst:=true;
                            end;
                            inc(count);
                        end;
                        prevname:=endname;
                        nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                  until nodeend=nil;
                  if nodestart<>nil then
                                        InsertDat(nodestart^.name,startname,endname,count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot).YouDeleted(drawings.GetCurrentDWG^)
                                    else
                                        InsertDat('_error_here',startname,endname,count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot).YouDeleted(drawings.GetCurrentDWG^);

                  //pvd:=PTEntityUnit(PCableSS.ou.Instance)^.FindVariable('CABLE_WireCount');
                  pvd:=pCableSSvarext.entityunit.FindVariable('CABLE_WireCount');
                  if pvd=nil then
                                 coord.x:=coord.x+12
                             else
                                 begin
                                      if PInteger(pvd^.data.Addr.Instance)^<>0 then
                                                                                  coord.x:=coord.x+6*PInteger(pvd^.data.Addr.Instance)^
                                                                              else
                                                                                  coord.x:=coord.x+12;
                                 end;
             end

        end;


  pcabledesk:=cman.iterate(ir);
  until pcabledesk=nil;

  cman.done;

  zcRedrawCurrentDrawing;
end;
procedure commformat2;
var
   pcfd:PRecordDescriptor;
   pf:PfieldDescriptor;
begin
   pcfd:=pointer(SysUnit.TypeName2PTD('TOrtoDevPlaceParam'));
   if pcfd<>nil then

     case OrtoDevPlaceParam.CountType of
          TODPCT_by_Count:begin
                               pf:=pcfd^.FindField('NX');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;

                               pf:=pcfd^.FindField('NY');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;
                               pf:=pcfd^.FindField('Count');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY);
                          end;
          TODPCT_by_XY:begin
                               pf:=pcfd^.FindField('NX');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY);

                               pf:=pcfd^.FindField('NY');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY);
                               pf:=pcfd^.FindField('Count');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;
                       end;
     end;
end;
function PlCommandStart(const Context:TZCADCommandContext;operands:pansichar):Integer;
var //i: Integer;
    sd:TSelEntsDesk;
begin
  OrtoDevPlaceParam.Name:='';
  sd:=zcGetSelEntsDeskInCurrentRoot;
    if sd.PFirstSelectedEnt<>nil then
    if (sd.PFirstSelectedEnt^.GetObjType=GDBBlockInsertID) then
    begin
         OrtoDevPlaceParam.Name:=PGDBObjBlockInsert(sd.PFirstSelectedEnt)^.name;
    end
else if (sd.PFirstSelectedEnt^.GetObjType=GDBDeviceID) then
    begin
         OrtoDevPlaceParam.Name:=DevicePrefix+PGDBObjBlockInsert(sd.PFirstSelectedEnt)^.name;
    end;

  if (OrtoDevPlaceParam.Name='')or(sd.SelectedEntsCount=0)or(sd.SelectedEntsCount>1) then
                                   begin
                                        ZCMsgCallBackInterface.TextMessage('Должен быть выбран только один блок или устройство!',TMWOHistoryOut);
                                        commandmanager.executecommandend;
                                        exit;
                                   end;

  zcRedrawCurrentDrawing;
  result:=cmd_ok;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera));
  ZCMsgCallBackInterface.TextMessage(rscmFirstCorner,TMWOHistoryOut);
  zcShowCommandParams(SysUnit.TypeName2PTD('CommandRTEdObject'),pco2);
  OPSPlaceSmokeDetectorOrtoParam.DMC:=TOPSMDC_1_2;
end;
function PlBeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): integer;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
    begin
      ZCMsgCallBackInterface.TextMessage('Второй угол',TMWOHistoryOut);
      t3dp:=wc;
    end
end;
procedure placedev(pva:PGDBObjEntityOpenArray;p1, p2: gdbvertex; nmax, nmin: Integer; name: pansichar;a:Double;aa:Boolean;Norm:Boolean);
var dx, dy: Double;
  line1, line2: GDBLineOps;
  l1, l2, i: integer;
  dir: gdbvertex;
//  mincount:integer;
  sd,{dd,}sdd,{ddd,}angle:double;
  linelength:double;
begin
  angle:=a;
  dx := p2.x - p1.x;
  dy := p2.y - p1.y;
  dx := abs(dx);
  dy := abs(dy);
  line1.lbegin := p1;
  line2.lbegin := p1;
  if dx < dy then
  begin
    line1.lend.x := p2.x;
    line1.lend.y := p1.y;
    line1.lend.z := 0;
    line2.lend.x := p1.x;
    line2.lend.y := p2.y;
    line2.lend.z := 0;
    sd:=dy/nmax/2;
    //dd:=dy/nmax;
    sdd:=dx/nmin/2;
    //ddd:=dx/nmin;
  end
  else
  begin
    line1.lend.x := p1.x;
    line1.lend.y := p2.y;
    line1.lend.z := 0;
    line2.lend.x := p2.x;
    line2.lend.y := p1.y;
    line2.lend.z := 0;
    sd:=dx/nmax/2;
    //dd:=dx/nmax;
    sdd:=dy/nmin/2;
    //ddd:=dy/nmin;
    if aa then
              angle:=angle+RightAngle;

  end;
  dir.x := line2.lend.x - line2.lbegin.x;
  dir.y := line2.lend.y - line2.lbegin.y;
  dir.z := line2.lend.z - line2.lbegin.z;

  l1:=nmin;
  l2:=nmax;
  Linelength:=Vertexlength(line1.lbegin, line1.lend);
  case l1 of
    1: begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 0.5), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
       end;
    2: begin
        //if (Vertexlength(line1.lbegin, line1.lend) - 2 * sd)<dd then
        begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 1 / 4), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 3 / 4), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
        end
        {else
        begin
        place2(pva,Vertexmorphabs(line1.lbegin, line1.lend, sd), dir, l2, sd, name);
        place2(pva,Vertexmorphabs(line1.lbegin, line1.lend, -sd), dir, l2, sd, name);
        end}
       end
  else begin
      place2(pva,Vertexmorphabs2(line1.lbegin, line1.lend, sdd{}), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      place2(pva,Vertexmorphabs2(line1.lbegin, line1.lend, -sdd{}), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      line2.lbegin := Vertexmorphabs2(line1.lbegin, line1.lend, sdd);
      line2.lend := Vertexmorphabs2(line1.lbegin, line1.lend, -sdd);
      l1:=l1-2;
      for i := 1 to l1 do place2(pva,Vertexmorph(line2.lbegin, line2.lend, i / (l1 + 1)), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      //for i := 1 to l2 do place3(pva,Vertexmorph(line2.lbegin, line2.lend, i / (l2 )), dir, l1, dd, name);
       end
  end;
end;
function PlAfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): integer;
var
pl:pgdbobjline;
//debug:string;
//dw,dd:Double;
nx,ny:Integer;
//t:Integer;
tt,tx,ty,ttx,tty:Double;
DC:TDrawContext;
begin
  //nx:=OrtoDevPlaceParam.NX;
  //ny:=OrtoDevPlaceParam.NY;
  result:=mclick;
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.free;


  pl := PGDBObjLine(ENTF_CreateLine(@drawings.GetCurrentDWG.ConstructObjRoot,@drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray,
                                    drawings.GetCurrentDWG^.GetCurrentLayer,drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                    t3dp,wc));
  zcSetEntPropFromCurrentDrawingProp(pl);
  //pl := pointer(drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID{,drawings.GetCurrentROOT}));
  //GDBObjLineInit(drawings.GetCurrentROOT,pl, drawings.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^, t3dp, wc);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pl^.FormatEntity(drawings.GetCurrentDWG^,dc);

     case OrtoDevPlaceParam.CountType of
          TODPCT_by_Count:begin
                               if abs(OrtoDevPlaceParam.Count)=1 then
                                          begin
                                               nx:=1;
                                               ny:=1;
                                          end
                          else
                              begin
                                   //t:=round(sqrt(abs(OrtoDevPlaceParam.Count)){+0.5});
                                   //tt:=abs(gdbobjline(pl^).CoordInOCS.lEnd.y-gdbobjline(pl^).CoordInOCS.lBegin.y)+abs(gdbobjline(pl^).CoordInOCS.lEnd.x-gdbobjline(pl^).CoordInOCS.lBegin.x);
                                   ty:=abs(gdbobjline(pl^).CoordInOCS.lEnd.y-gdbobjline(pl^).CoordInOCS.lBegin.y);
                                   tx:=abs(gdbobjline(pl^).CoordInOCS.lEnd.x-gdbobjline(pl^).CoordInOCS.lBegin.x);

                                   tt:=sqrt(tx*ty/OrtoDevPlaceParam.Count);

                                   {if tx>ty then
                                                tx:=1/ty
                                            else
                                                ty:=1/tx;}

                                   //tt:=gdbobjline(pl^).CoordInOCS.lEnd.y-gdbobjline(pl^).CoordInOCS.lBegin.y;

                                  { if abs(tt)>eps then
                                                      tt:=abs((gdbobjline(pl^).CoordInOCS.lEnd.x-gdbobjline(pl^).CoordInOCS.lBegin.x)/tt)
                                                  else
                                                      tt:=1000000000;
                                   if tt>1 then
                                              begin
                                                   //nx:=OrtoDevPlaceParam.count;
                                                   //ny:=1;
                                                   tt:=1/tt;
                                              end;

                                               begin
                                                   nx:=round(t*tx);
                                                   ny:=round(t*ty);
                                               end;}
                                   ttx:=(tx/tt);
                                   tty:=(ty/tt);

                      {             if ttx<0.5 then
                                               begin
                                                    nx:=1;
                                                    ny:=OrtoDevPlaceParam.Count;
                                               end
                              else if tty<0.5 then
                                               begin
                                                    ny:=1;
                                                    nx:=OrtoDevPlaceParam.Count;
                                               end
                              else
                                  begin
                                   nx:=round(tx/tt);
                                   ny:=round(ty/tt);
                                  end;

                                   while nx*ny<OrtoDevPlaceParam.Count do
                                   if tx<ty then
                                                inc(ny)
                                            else
                                                inc(nx)}
                                   if ttx<tty then
                                                  begin
                                                       //tt:=tx;
                                                       //tx:=ty;
                                                       //ty:=tt;

                                                       tt:=ttx;
                                                       //ttx:=tty;
                                                       tty:=tt;

                                                  end;
                                   ny:=round(tty);
                                   if ny=0 then
                                               ny:=1;
                                   if ny>OrtoDevPlaceParam.Count then
                                               ny:=OrtoDevPlaceParam.Count;
                                   nx:=ceil(OrtoDevPlaceParam.Count/ny);
                              end;
                          end;
          TODPCT_by_XY:begin
                            nx:=OrtoDevPlaceParam.NX;
                            ny:=OrtoDevPlaceParam.NY;
                       end;
     end;
  if button=0 then
  begin
       placedev(@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, NX, NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
  end
  else
  begin
       result:=-1;
       pco^.mouseclic:=-1;
       //drawings.GetCurrentDWG.ConstructObjRoot.cleareraseobj;
       placedev(@drawings.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, NX, NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
       drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.free;

       drawings.GetCurrentROOT.calcbb(dc);
       zcRedrawCurrentDrawing;
       ZCMsgCallBackInterface.TextMessage(rscmFirstCorner,TMWOHistoryOut);
       //commandend;
       //pcommandmanager^.executecommandend;
  end;
//  if button = 1 then
//  begin
//    pgdbinplugin^.ObjArray.add(addr(pc));
//    pgdbinplugin^.ConstructObjRoot.Count := 0;
//    commandend;
//    executecommandend;
//  end;
end;
procedure startup;
begin
  OPS_SPBuild_com.init('OPS_SPBuild',0,0);
  //CreateCommandFastObjectPlugin(@OPS_SPBuild_com,'OPS_SPBuild',CADWG,0);

  CreateZCADCommand(@OPS_Sensor_Mark_com,'OPS_Sensor_Mark',CADWG,0);
  pco:=CreateCommandRTEdObjectPlugin(@CommandStart,nil,nil,@commformat,@BeforeClick,@AfterClick,nil,nil,'PlaceSmokeDetectorOrto',0,0);
  pco^.SetCommandParam(@OPSPlaceSmokeDetectorOrtoParam,'PTOPSPlaceSmokeDetectorOrtoParam');
  OPSPlaceSmokeDetectorOrtoParam.InsertType:=TIT_Device;
  OPSPlaceSmokeDetectorOrtoParam.Height.Enums.init(10);
  OPSPlaceSmokeDetectorOrtoParam.DatType:=TOPSDT_Smoke;
  OPSPlaceSmokeDetectorOrtoParam.StartAuto:=false;
  OPSPlaceSmokeDetectorOrtoParam.DMC:=TOPSMDC_2;
  OPSPlaceSmokeDetectorOrtoParam.Scale:=100;
  OPSPlaceSmokeDetectorOrtoParam.ScaleBlock:=1;
  OPSPlaceSmokeDetectorOrtoParam.oldth:=0;
  OPSPlaceSmokeDetectorOrtoParam.oldsh:=0;
  OPSPlaceSmokeDetectorOrtoParam.olddt:=TOPSDT_Termo;
  OPSPlaceSmokeDetectorOrtoParam.NormalizePoint:=True;
  OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy:=TPSS_Proportional;
  OPSPlaceSmokeDetectorOrtoParam.ReductionFactor:=1;
  OPSPlaceSmokeDetectorOrtoParam.SensorSensorDistance:=TARDM_LongAxis;
  OPSPlaceSmokeDetectorOrtoParam.SensorWallDistance:=TARDM_Nothing;
  commformat;

  pco2:=CreateCommandRTEdObjectPlugin(@PlCommandStart,nil,nil,@commformat2,@PlBeforeClick,@PlAfterClick,nil,nil,'OrtoDevPlace',0,0);

  pco2^.SetCommandParam(@OrtoDevPlaceParam,'PTOrtoDevPlaceParam');

  OrtoDevPlaceParam.ScaleBlock:=1;
  OrtoDevPlaceParam.NX:=2;
  OrtoDevPlaceParam.NY:=2;
  OrtoDevPlaceParam.Count:=2;
  OrtoDevPlaceParam.Angle:=0;
  OrtoDevPlaceParam.AutoAngle:=false;
  OrtoDevPlaceParam.NormalizePoint:=true;
  commformat2;
  //format;
end;
procedure finalize;
begin
  OPSPlaceSmokeDetectorOrtoParam.Height.Enums.Done;
  //result := 0;
end;
initialization
  startup;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
end.
