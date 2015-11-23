(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit GDBCommandsOPS;
{$INCLUDE def.inc}
interface
uses

  intftranslations,zeentitiesmanager,GDBEntity,uzglabstractviewarea,gdbdrawcontext,GDBAbstractText,GDBText,UGDBStringArray,zeentityfactory,uzcsysvars,strproc,gdbasetypes,commandline,uzclog,UGDBOpenArrayOfPObjects,
  plugins,
  commandlinedef,
  commanddefinternal,
  gdbase,
  UGDBDescriptor,
  GDBManager,
  sysutils,
  varmandef,
  //oglwindowdef,
  //OGLtypes,
  UGDBOpenArrayOfByte,
  iodxf,
  //optionswnd,
  //objinsp,
  zcadinterface,
  geometry,
  memman,
  gdbobjectsconstdef,
  GDBCommandsDraw,
  UGDBVisibleOpenArray,{gdbEntity,}{GDBCircle,}GDBLine,{GDBGenericSubEntry,}
  paths,uzcshared,{GDBSubordinated,}GDBBlockInsert,{ZWinMan,}{sysinfo,}varman,uzccablemanager,GDBDevice,GDBMText,math;

type
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
                   TOPSMDC_1(*'1 in the quarter'*),
                   TOPSMDC_1_2(*'1 in the middle'*),
                   TOPSMDC_2(*'2'*),
                   TOPSMDC_3(*'3'*),
                   TOPSMDC_4(*'4'*)
                  );
  TODPCountType=(
                   TODPCT_by_Count(*'by number'*),
                   TODPCT_by_XY(*'by width/height'*)
                 );
  PTOPSPlaceSmokeDetectorOrtoParam=^TOPSPlaceSmokeDetectorOrtoParam;
  TOPSPlaceSmokeDetectorOrtoParam=packed record
                                        InsertType:TInsertType;(*'Insert'*)
                                        Scale:GDBDouble;(*'Plan scale'*)
                                        ScaleBlock:GDBDouble;(*'Blocks scale'*)
                                        StartAuto:GDBBoolean;(*'"Start" signal'*)
                                        DatType:TOPSDatType;(*'Sensor type'*)
                                        DMC:TOPSMinDatCount;(*'Min. number of sensors'*)
                                        Height:TEnumData;(*'Height of installation'*)
                                        NDD:GDBDouble;(*'Sensor-Sensor(standard)'*)
                                        NDW:GDBDouble;(*'Sensor-Wall(standard)'*)
                                        FDD:GDBDouble;(*'Sensor-Sensor(fact)'*)(*oi_readonly*)
                                        FDW:GDBDouble;(*'Sensor-Wall(fact)'*)(*oi_readonly*)
                                        NormalizePoint:GDBBoolean;(*'Normalize to grid (if enabled)'*)

                                        oldth:GDBInteger;(*hidden_in_objinsp*)
                                        oldsh:GDBInteger;(*hidden_in_objinsp*)
                                        olddt:TOPSDatType;(*hidden_in_objinsp*)
                                  end;
  PTOrtoDevPlaceParam=^TOrtoDevPlaceParam;
  TOrtoDevPlaceParam=packed record
                                        Name:GDBString;(*'Block'*)(*oi_readonly*)
                                        ScaleBlock:GDBDouble;(*'Blocks scale'*)
                                        CountType:TODPCountType;(*'Type of placement'*)
                                        Count:GDBInteger;(*'Total number'*)
                                        NX:GDBInteger;(*'Number of length'*)
                                        NY:GDBInteger;(*'Number of width'*)
                                        Angle:GDBDouble;(*'Rotation'*)
                                        AutoAngle:GDBBoolean;(*'Auto rotation'*)
                                        NormalizePoint:GDBBoolean;(*'Normalize to grid (if enabled)'*)

                     end;
     GDBLine=packed record
                  lBegin,lEnd:GDBvertex;
              end;
  OPS_SPBuild={$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;
  end;

{Export-}
const //plugname: pchar = 'OPS_Plugin';
      command1: pansichar = 'PlaceSmokeDetectorOrto';  //920661-487808
      //eps=10E-5;
      //Dat_Smoke_Name='PS_DAT_SMOKE';
      //Dat_Termo_Name='PS_DAT_TERMO';
      //smoke_wal='ops_det_smoke_wal';
      //smoke_smoke='ops_det_smoke_det';
      //termo_wal='ops_det_termo_wal';
      //termo_termo='ops_det_termo_det';
var
   pco,pco2:pCommandRTEdObjectPlugin;
   //pwnd:POGLWndtype;
   t3dp: gdbvertex;
   //pgdbinplugin: PGDBDescriptor;
   //psysvarinplugin: pgdbsysvariable;
   pluginspath:string;
   pvarman:pvarmanagerdef;
   pdw,pdd,pdtw,pdtd:PGDBDouble;
   pdt:pinteger;
   sdname:GDBstring;

   OPSPlaceSmokeDetectorOrtoParam:TOPSPlaceSmokeDetectorOrtoParam;
   OrtoDevPlaceParam:TOrtoDevPlaceParam;

   OPS_SPBuild_com:OPS_SPBuild;

//procedure GDBGetMem({$IFDEF DEBUGBUILD}ErrGuid:pchar;{$ENDIF}var p:pointer; const size: longword); external 'cad.exe';
//procedure GDBFreeMem(var p: pointer); external 'cad.exe';

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

//function getoglwndparam: pointer; external 'cad.exe';
//function GetPVarMan: pointer; external 'cad.exe';


//function CreateCommandRTEdObjectPlugin(ocs,oce,occ:comproc;obc,oac:commousefunc;name:pchar):pCommandRTEdObjectPlugin; external 'cad.exe';
{
//procedure builvldtable(x,y,z:gldouble);

}
{procedure startup;
procedure finalize;}

implementation
uses enitiesextendervariables,GDBRoot,oglwindowdef, gdbcable,UUnitManager,GDBCommandsElectrical,{UGDBObjBlockdefArray,}URecordDescriptor,TypeDescriptors;
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
var
   gr:GDBBoolean;
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
procedure place2(pva:PGDBObjEntityOpenArray;basepoint, dir: gdbvertex; count: integer; sd: GDBDouble; name: pansichar;angle:GDBDouble;norm:GDBBoolean;scaleblock:GDBDouble);
var line2: gdbline;
  i: integer;
begin
  case count of
    1:
       begin
            case OPSPlaceSmokeDetectorOrtoParam.DMC of
                                            TOPSMDC_1:old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                                                                             gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                                                             docorrecttogrid(Vertexdmorph(basepoint, dir, 1 / 4),norm), scaleblock, angle, name);
                                            TOPSMDC_1_2:old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                                                                               gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                                                               docorrecttogrid(Vertexdmorph(basepoint, dir, 1 / 2),norm), scaleblock, angle, name);
            end;
       end;
    2: begin
        old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                               gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                               docorrecttogrid(Vertexdmorph(basepoint, dir, 1 / 4),norm), scaleblock, angle, name);
        old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                               gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                               docorrecttogrid(Vertexdmorph(basepoint, dir, 3 / 4),norm), scaleblock, angle, name);
      end;
    3: begin
        old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                               gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                               docorrecttogrid(Vertexdmorph(basepoint, dir, 1 / 6),norm), scaleblock, angle, name);
        old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                               gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                               docorrecttogrid(Vertexdmorph(basepoint, dir, 3 / 6),norm), scaleblock, angle, name);
        old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                               gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                               docorrecttogrid(Vertexdmorph(basepoint, dir, 5 / 6),norm), scaleblock, angle, name);
      end
  else begin
      old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                             gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                             docorrecttogrid(VertexDmorphabs(basepoint, dir, sd),norm), scaleblock, angle, name);
      old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                             gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                             docorrecttogrid(VertexDmorphabs(basepoint, dir, -sd),norm), scaleblock, angle, name);
      line2.lbegin := VertexDmorphabs(basepoint, dir, sd);
      line2.lend := VertexDmorphabs(basepoint, dir, -sd);
      count := count - 2;
      for i := 1 to count do old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                                                    gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                                    docorrecttogrid(Vertexmorph(line2.lbegin, line2.lend, i / (count + 1)),norm), scaleblock, angle, name);
    end
  end;
end;
{procedure place3(pva:PGDBObjEntityOpenArray;basepoint, dir: gdbvertex; count: integer; dd: gldouble; name: pchar);
var line2: gdbline;
  i: integer;
begin
      line2.lbegin := VertexDmorph(basepoint, dir, 0);
      line2.lend := VertexDmorph(basepoint, dir, 1);
      for i := 1 to count do addblockinsert(pva, Vertexmorph(line2.lbegin, line2.lend, i / (count + 1)), 1, 0, name);
end;}
procedure placedatcic(pva:PGDBObjEntityOpenArray;p1, p2: gdbvertex; sd, dd: GDBDouble; name: pansichar;norm:GDBBoolean;scaleblock: GDBDouble);
var dx, dy: GDBDouble;
  line1, line2: gdbline;
  l1, l2, i: integer;
  dir: gdbvertex;
  mincount:integer;
begin
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
  end
  else
  begin
    line1.lend.x := p1.x;
    line1.lend.y := p2.y;
    line1.lend.z := 0;
    line2.lend.x := p2.x;
    line2.lend.y := p1.y;
    line2.lend.z := 0;
  end;
  dir.x := line2.lend.x - line2.lbegin.x;
  dir.y := line2.lend.y - line2.lbegin.y;
  dir.z := line2.lend.z - line2.lbegin.z;
  if (Vertexlength(line1.lbegin, line1.lend) - 2 * sd)>0 then l1 := round(abs(Vertexlength(line1.lbegin, line1.lend) - 2 * sd) / dd- eps + 1.5)
                                                         else l1 := 1;
  if (Vertexlength(line2.lbegin, line2.lend) - 2 * sd)>0 then l2 := round(abs(Vertexlength(line2.lbegin, line2.lend) - 2 * sd) / dd-eps + 1.5)
                                                         else l2 := 1;

  //l2 := round(abs(Vertexlength(line2.lbegin, line2.lend) - 2 * sd) / dd + 1.5);
  mincount:=2;
  case OPSPlaceSmokeDetectorOrtoParam.DMC of
                                            TOPSMDC_1:mincount:=1;
                                            TOPSMDC_1_2:mincount:=1;
                                            TOPSMDC_3:mincount:=3;
                                            TOPSMDC_4:mincount:=4;
                                          end;
  if l1 <= 0 then l1 := 1;
  if l2 <= 0 then l2 := 1;
  //if (l1 = 1) and (l2 = 1) then l2 := 2;
  //if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
     if (l1*l2)<mincount then
                             begin
                                  //l2:=3;
                                          case OPSPlaceSmokeDetectorOrtoParam.DMC of
                                            TOPSMDC_2:l2:=2;
                                            TOPSMDC_3:l2:=3;
                                            TOPSMDC_4:
                                                      begin
                                                           l2:=2;
                                                           l1:=2;
                                                      end;
                                          end;
                             end;

  case l1 of
    1: begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 0.5), dir, l2, sd, name,0,norm,scaleblock);
       end;
    2: begin
        if (Vertexlength(line1.lbegin, line1.lend) - 2 * sd)<dd then
        begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 1 / 4), dir, l2, sd, name,0,norm,scaleblock);
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 3 / 4), dir, l2, sd, name,0,norm,scaleblock);
        end
        else
        begin
        place2(pva,Vertexmorphabs(line1.lbegin, line1.lend, sd), dir, l2, sd, name,0,norm,scaleblock);
        place2(pva,Vertexmorphabs(line1.lbegin, line1.lend, -sd), dir, l2, sd, name,0,norm,scaleblock);
        end
       end{;
    3: begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 1 / 6), dir, l2, sd, name);
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 3 / 6), dir, l2, sd, name);
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 5 / 6), dir, l2, sd, name);
      end}
  else begin
      place2(pva,Vertexmorphabs2(line1.lbegin, line1.lend, sd), dir, l2, sd, name,0,norm,scaleblock);
      place2(pva,Vertexmorphabs2(line1.lbegin, line1.lend, -sd), dir, l2, sd, name,0,norm,scaleblock);
      line2.lbegin := Vertexmorphabs2(line1.lbegin, line1.lend, sd);
      line2.lend := Vertexmorphabs2(line1.lbegin, line1.lend, -sd);
      l1:=l1-2;
      for i := 1 to l1 do place2(pva,Vertexmorph(line2.lbegin, line2.lend, i / (l1 + 1)), dir, l2, sd, name,0,norm,scaleblock);
      //for i := 1 to l2 do place3(pva,Vertexmorph(line2.lbegin, line2.lend, i / (l2 )), dir, l1, dd, name);
       end
  end;
end;
function CommandStart(operands:pansichar):GDBInteger;
begin
  GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_PS_DAT_SMOKE');
  GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_PS_DAT_TERMO');
  GDB.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera));
  historyout('Первый угол:');
  If assigned(SetGDBObjInspProc)then
  SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('CommandRTEdObject'),pco,gdb.GetCurrentDWG);
  result:=cmd_ok;
end;
function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): integer;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
    //if pco^.mouseclic = 1 then
    begin
      historyout('Второй угол');
      t3dp:=wc;
    end;
end;
function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger):GDBInteger;
var
pl:pgdbobjline;
//debug:string;
dw,dd:gdbdouble;
DC:TDrawContext;
begin


  dw:=OPSPlaceSmokeDetectorOrtoParam.NDW/OPSPlaceSmokeDetectorOrtoParam.Scale;
  dd:=OPSPlaceSmokeDetectorOrtoParam.NDD/OPSPlaceSmokeDetectorOrtoParam.Scale;
  {if gdb.GetCurrentDWG.BlockDefArray.getindex(@sdname[1])<0 then
                                                         begin
                                                              sdname:=sdname;
                                                              //gdb.GetCurrentDWG.BlockDefArray.loadblock(pansichar(sysinfo.sysparam.programpath+'blocks\ops\'+sdname+'.dxf'),@sdname[1],gdb.GetCurrentDWG)
                                                         end;}
  result:=mclick;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;

  pl := PGDBObjLine(ENTF_CreateLine(@gdb.GetCurrentDWG.ConstructObjRoot,@gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray,[t3dp.x,t3dp.y,t3dp.z,wc.x,wc.y,wc.z]));
  GDBObjSetEntityProp(pl,gdb.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^,sysvar.dwg.DWG_CLinew^);

  //pl := pointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID{,gdb.GetCurrentROOT}));
  //GDBObjLineInit(gdb.GetCurrentROOT,pl, gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^, t3dp, wc);
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pl^.Formatentity(gdb.GetCurrentDWG^,dc);
  if (button and MZW_LBUTTON)=0 then
  begin
       placedatcic(@gdb.GetCurrentDWG.ConstructObjRoot.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, dw, dd,@sdname[1],OPSPlaceSmokeDetectorOrtoParam.NormalizePoint,OPSPlaceSmokeDetectorOrtoParam.ScaleBlock);
  end
  else
  begin
       result:=-1;
       //pco^.mouseclic:=-1;
       //gdb.GetCurrentDWG.ConstructObjRoot.cleareraseobj;
       placedatcic(@gdb.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, dw, dd,@sdname[1],OPSPlaceSmokeDetectorOrtoParam.NormalizePoint,OPSPlaceSmokeDetectorOrtoParam.ScaleBlock);
       gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;

       gdb.GetCurrentROOT.calcbb(dc);
       if assigned(redrawoglwndproc) then redrawoglwndproc;
       historyout('Первый угол:');
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
var s:GDBString;
begin
     sdname:=sdname;
     if OPSPlaceSmokeDetectorOrtoParam.DatType<>OPSPlaceSmokeDetectorOrtoParam.olddt then
     begin
          OPSPlaceSmokeDetectorOrtoParam.olddt:=OPSPlaceSmokeDetectorOrtoParam.DatType;
          OPSPlaceSmokeDetectorOrtoParam.Height.Enums.clear;
          case OPSPlaceSmokeDetectorOrtoParam.DatType of
               TOPSDT_Smoke:begin
                                 s:='До 3,5м';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 3,5 до 6,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 6,0 до 10,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 10,5 до 12,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Не норм.';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 OPSPlaceSmokeDetectorOrtoParam.oldth:=OPSPlaceSmokeDetectorOrtoParam.Height.Selected;
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Selected:=OPSPlaceSmokeDetectorOrtoParam.oldsh;
                            end;
               TOPSDT_Termo:begin
                                 s:='До 3,5м';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 3,5 до 6,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 6,0 до 9,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Не норм.';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
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
                               if (OPSPlaceSmokeDetectorOrtoParam.Height.Selected<>4)and OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                               begin
                                    OPSPlaceSmokeDetectorOrtoParam.NDW:=OPSPlaceSmokeDetectorOrtoParam.NDW/2;
                                    OPSPlaceSmokeDetectorOrtoParam.NDD:=OPSPlaceSmokeDetectorOrtoParam.NDD/2;
                               end;
                           //sdname:={'PS_DAT_SMOKE'}'SS_BIAS';
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
                               if (OPSPlaceSmokeDetectorOrtoParam.Height.Selected<>3)and OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                               begin
                                    OPSPlaceSmokeDetectorOrtoParam.NDW:=OPSPlaceSmokeDetectorOrtoParam.NDW/2;
                                    OPSPlaceSmokeDetectorOrtoParam.NDD:=OPSPlaceSmokeDetectorOrtoParam.NDD/2;
                               end;
               sdname:='PS_DAT_TERMO';
                            end;
     end;
    if OPSPlaceSmokeDetectorOrtoParam.InsertType=TIT_Device then
                                                                sdname:=DevicePrefix+sdname;
end;
{function OPS_Sensor_Mark_com(Operands:pansichar):GDBInteger;
var i: GDBInteger;
    pcable:pGDBObjCable;
    ir,ir_inNodeArray:itrec;
    pvd:pvardesk;
    currentunit:TUnit;
    ucount:gdbinteger;
    ptn:PTNodeProp;
    p:pointer;
    cman:TCableManager;
begin
  if gdb.GetCurrentDWG.ObjRoot.ObjArray.Count = 0 then exit;
  cman.init;
  cman.build;
  cman.done;

  currentunit.init('calc');
  units.loadunit(expandpath('*rtl\objcalc\opsmarkdef.pas'),(@currentunit));
  pcable:=gdb.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
  if pcable<>nil then
  repeat
        if pcable^.vp.ID=GDBCableID then
        begin
             pvd:=currentunit.FindVariable('CDC_temp');
             pgdbinteger(pvd.data.Instance)^:=0;
             pvd:=currentunit.FindVariable('CDSC_temp');
             pgdbinteger(pvd.data.Instance)^:=0;
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
  pcable:=gdb.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
  until pcable=nil;

  currentunit.done;
  redrawoglwnd;
  result:=cmd_ok;
end;}
function OPS_Sensor_Mark_com(operands:TCommandOperands):TCommandResult;
var //i: GDBInteger;
    pcabledesk:PTCableDesctiptor;
    ir,ir2,ir_inNodeArray:itrec;
    pvd:pvardesk;
    defaultunit:TUnit;
    currentunit:PTUnit;
    UManager:TUnitManager;
    ucount:gdbinteger;
    ptn:PGDBObjDevice;
    p:pointer;
    cman:TCableManager;
    SaveEntUName,SaveCabUName:gdbstring;
    cablemetric,devicemetric,numingroupmetric:GDBString;
    ProcessedDevices:GDBOpenArrayOfPObjects;
    name:gdbstring;
    DC:TDrawContext;
    pcablestartsegmentvarext,pptnownervarext:PTVariablesExtender;
const
      DefNumMetric='default_num_in_group';
function GetNumUnit(uname:gdbstring):PTUnit;
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
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  if gdb.GetCurrentROOT.ObjArray.Count = 0 then exit;
  ProcessedDevices.init({$IFDEF DEBUGBUILD}'{518968B6-90DE-4895-A27C-B28234A6DC17}',{$ENDIF}100);
  cman.init;
  cman.build;
  UManager.init;

  defaultunit.init(DefNumMetric);
  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/objcalc/opsmarkdef.pas'),(@defaultunit));
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
  repeat
        begin
            pcablestartsegmentvarext:=pcabledesk.StartSegment^.GetExtension(typeof(TVariablesExtender));
            //pvd:=PTObjectUnit(pcabledesk.StartSegment.ou.Instance)^.FindVariable('GC_Metric');
            pvd:=pcablestartsegmentvarext^.entityunit.FindVariable('GC_Metric');
            if pvd<>nil then
                            begin
                                 cablemetric:=pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                            end
                        else
                            begin
                                 cablemetric:='';
                            end;

             currentunit:=Umanager.beginiterate(ir2);
             if currentunit<>nil then
             repeat
             pvd:=currentunit.FindVariable('CDC_temp');
             pgdbinteger(pvd.data.Instance)^:=0;
             pvd:=currentunit.FindVariable('CDSC_temp');
             pgdbinteger(pvd.data.Instance)^:=1;
             currentunit:=Umanager.iterate(ir2);
             until currentunit=nil;
             currentunit:=nil;





             ptn:=pcabledesk^.Devices.beginiterate(ir_inNodeArray);
             if ptn<>nil then
                repeat
                    begin
                        pptnownervarext:=ptn^.bp.ListPos.Owner^.GetExtension(typeof(TVariablesExtender));
                        //pvd:=PTObjectUnit(ptn^.bp.ListPos.Owner.ou.Instance)^.FindVariable('GC_Metric');
                        pvd:=pptnownervarext^.entityunit.FindVariable('GC_Metric');
                        if pvd<>nil then
                                        begin
                                             devicemetric:=pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                                        end
                                    else
                                        begin
                                             devicemetric:='';
                                        end;
                        //pvd:=PTObjectUnit(ptn^.bp.ListPos.Owner.ou.Instance)^.FindVariable('GC_InGroup_Metric');
                        pvd:=pptnownervarext^.entityunit.FindVariable('GC_InGroup_Metric');
                                        if pvd<>nil then
                                                        begin
                                                             numingroupmetric:=pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                                                             if numingroupmetric='' then
                                                                                        numingroupmetric:=DefNumMetric;

                                                        end
                                                    else
                                                        begin
                                                             numingroupmetric:=DefNumMetric;
                                                        end;
                        if devicemetric=cablemetric then
                        begin
                        if ProcessedDevices.IsObjExist(@ptn^.bp.ListPos.Owner^)=false then
                    begin
                         currentunit:=GetNumUnit(numingroupmetric);

                         SaveCabUName:=pcablestartsegmentvarext^.entityunit.Name;
                         pcablestartsegmentvarext^.entityunit.Name:='Cable';
                         p:=@pcablestartsegmentvarext^.entityunit;
                         currentunit.InterfaceUses.addnodouble(@p);
                         ucount:=currentunit.InterfaceUses.Count;

                         SaveEntUName:=pptnownervarext^.entityunit.Name;
                         pptnownervarext^.entityunit.Name:='Entity';
                         p:=@pptnownervarext^.entityunit;
                         currentunit.InterfaceUses.addnodouble(@p);

                         units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/objcalc/opsmark.pas'),(currentunit));

                         ProcessedDevices.Add(@ptn^.bp.ListPos.Owner);

                         dec(currentunit.InterfaceUses.Count,2);

                         pptnownervarext^.entityunit.Name:=SaveEntUName;
                         pcablestartsegmentvarext^.entityunit.Name:=SaveCabUName;

                         PGDBObjLine(ptn^.bp.ListPos.Owner)^.Formatentity(gdb.GetCurrentDWG^,dc);
                    end
                        else
                            begin
                            pvd:=pptnownervarext^.entityunit.FindVariable('NMO_Name');
                            if pvd<>nil then
                                        begin
                                             name:='"'+pvd.data.PTD.GetValueAsString(pvd.data.Instance)+'"';
                                        end
                                    else
                                        begin
                                             name:='"без имени"';
                                        end;
                            uzcshared.HistoryOutstr(format('Попытка повторной нумерации устройства %s кабелем (сегментом кабеля) %s',[name,'"'+pcabledesk^.Name+'"']));
                            end;
                        end;

                    end;
                    //ptn^.bp.ListPos.Owner.ou.Name:=SaveEntUName;
                    ptn:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                until ptn=nil;



             if currentunit<>nil then
             currentunit.InterfaceUses.Count:=ucount-1;
        end;
  pcablestartsegmentvarext^.entityunit.Name:=SaveCabUName;
  pcabledesk:=cman.iterate(ir);
  until pcabledesk=nil;

  defaultunit.done;
  UManager.done;
  cman.done;
  ProcessedDevices.ClearAndDone;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
procedure InsertDat2(datname,name:GDBString;var currentcoord:GDBVertex; var root:GDBObjRoot);
var
   pv:pGDBObjDevice;
   pt:pGDBObjMText;
   lx,{rx,}uy,dy:GDBDouble;
   tv:gdbvertex;
   DC:TDrawContext;
begin
          name:=strproc.Tria_Utf8ToAnsi(name);

     gdb.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,datname);
     pointer(pv):=old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,@{gdb.GetCurrentROOT}root.ObjArray,
                                         gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                         currentcoord, 1, 0,@datname[1]);
     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
     pv^.formatentity(gdb.GetCurrentDWG^,dc);
     pv^.getoutbound(dc);

     lx:=pv.P_insert_in_WCS.x-pv.vp.BoundingBox.LBN.x;
     //rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
     dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
     uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;

     pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
     pv^.Formatentity(gdb.GetCurrentDWG^,dc);

     tv:=currentcoord;
     tv.x:=tv.x-lx-1;
     tv.y:=tv.y+(dy+uy)/2;

     if name<>'' then
     begin
     pt:=pointer(AllocEnt(GDBMtextID));
     pt^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.LayerTable.getAddres('TEXT'),sysvar.dwg.DWG_CLinew^,name,tv,2.5,0,0.65,RightAngle,jsbc,1,1);
     pt^.TXTStyleIndex:=gdb.GetCurrentDWG.GetTextStyleTable^.getelement(0);
     {gdb.GetCurrentROOT}root.ObjArray.add(@pt);
     pt^.Formatentity(gdb.GetCurrentDWG^,dc);
     end;

     currentcoord.y:=currentcoord.y+dy+uy;
end;
function InsertDat(datname,sname,ename:GDBString;datcount:GDBInteger;var currentcoord:GDBVertex; var root:GDBObjRoot):pgdbobjline;
var
//   pv:pGDBObjDevice;
//   lx,rx,uy,dy:GDBDouble;
   pl:pgdbobjline;
   oldcoord,oldcoord2:gdbvertex;
   DC:TDrawContext;
begin
     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
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
                         pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,oldcoord2);
                         {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
                         pl^.Formatentity(gdb.GetCurrentDWG^,dc);
                       end
else if datcount>2 then
                       begin
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord, Vertexmorphabs2(oldcoord,oldcoord2,2));
                         {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
                         pl^.Formatentity(gdb.GetCurrentDWG^,dc);
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,4), Vertexmorphabs2(oldcoord,oldcoord2,6));
                         {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
                         pl^.Formatentity(gdb.GetCurrentDWG^,dc);
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,8), oldcoord2);
                         {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
                         pl^.Formatentity(gdb.GetCurrentDWG^,dc);
                       end;

     oldcoord:=currentcoord;
     currentcoord.y:=currentcoord.y+10;
     pl:=pointer(AllocEnt(GDBLineID));
     pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,currentcoord);
     {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
     pl^.Formatentity(gdb.GetCurrentDWG^,dc);
     result:=pl;
end;
procedure OPS_SPBuild.Command(Operands:pansichar);
//function OPS_SPBuild_com(Operands:pansichar):GDBInteger;
var count: GDBInteger;
    pcabledesk:PTCableDesctiptor;
    PCableSS:PGDBObjCable;
    ir,ir_inNodeArray:itrec;
    pvd:pvardesk;
//    currentunit:TUnit;
//    ucount:gdbinteger;
//    ptn:PGDBObjDevice;
//    p:pointer;
    cman:TCableManager;
    pv:pGDBObjDevice;

    coord,currentcoord:GDBVertex;
//    pbd:PGDBObjBlockdef;
    {pvn,pvm,}pvmc{,pvl}:pvardesk;

    nodeend,nodestart:PGDBObjDevice;
    isfirst:boolean;
    startmat,endmat,startname,endname,prevname:gdbstring;

    //cmlx,cmrx,cmuy,cmdy:gdbdouble;
    {lx,rx,}uy,dy:gdbdouble;
    lsave:{integer}PGDBPointer;
    DC:TDrawContext;
    pCableSSvarext,ppvvarext,pnodeendvarext:PTVariablesExtender;
begin
  if gdb.GetCurrentROOT.ObjArray.Count = 0 then exit;
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  cman.init;
  cman.build;

         GDB.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  coord:=geometry.NulVertex;
  coord.y:=0;
  coord.x:=0;
  prevname:='';
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
  repeat
        PCableSS:=pcabledesk^.StartSegment;
        pCableSSvarext:=PCableSS^.GetExtension(typeof(TVariablesExtender));
        //pvd:=PTObjectUnit(PCableSS.ou.Instance)^.FindVariable('CABLE_Type');     { TODO : Сделать поиск переменных caseнезависимым }
        pvd:=pCableSSvarext^.entityunit.FindVariable('CABLE_Type');

        if pvd<>nil then
        begin
             //if PTCableType(pvd^.data.Instance)^=TCT_ShleifOPS then
             if (pcabledesk.StartDevice<>nil){and(pcabledesk.EndDevice<>nil)} then
             begin
                  uzcshared.HistoryOutStr(pcabledesk.Name);
                  //programlog.logoutstr(pcabledesk.Name,0);
                  currentcoord:=coord;
                  PTCableType(pvd^.data.Instance)^:=TCT_ShleifOPS;
                  lsave:=SysVar.dwg.DWG_CLayer^;
                  SysVar.dwg.DWG_CLayer^:=gdb.GetCurrentDWG.LayerTable.GetSystemLayer;

                  gdb.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_CABLE_MARK');
                  pointer(pv):=old_ENTF_CreateBlockInsert(@GDB.GetCurrentDWG.ConstructObjRoot,@{gdb.GetCurrentROOT.ObjArray}GDB.GetCurrentDWG.ConstructObjRoot.ObjArray,
                                                      gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                                      currentcoord, 1, 0,'DEVICE_CABLE_MARK');

                  SysVar.dwg.DWG_CLayer^:=lsave;
                  ppvvarext:=pv^.GetExtension(typeof(TVariablesExtender));
                  //pvmc:=PTObjectUnit(pv^.ou.Instance)^.FindVariable('CableName');
                  pvmc:=ppvvarext^.entityunit.FindVariable('CableName');
                  if pvmc<>nil then
                  begin
                      pstring(pvmc^.data.Instance)^:=pcabledesk.Name;
                  end;
                  Cable2CableMark(pcabledesk,pv);
                  pv^.formatentity(gdb.GetCurrentDWG^,dc);
                  pv^.getoutbound(dc);

                  //lx:=pv.P_insert_in_WCS.x-pv.vp.BoundingBox.LBN.x;
                  //rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
                  dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
                  uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;

                  pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
                  pv^.Formatentity(gdb.GetCurrentDWG^,dc);
                  currentcoord.y:=currentcoord.y+dy+uy;


                  isfirst:=true;
                  {nodeend:=}pcabledesk^.Devices.beginiterate(ir_inNodeArray);
                  nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                  nodestart:=nil;
                  count:=0;
                  if nodeend<>nil then
                  repeat
                        if nodeend^.bp.ListPos.Owner<>pointer(gdb.GetCurrentROOT) then
                                                                          nodeend:=pointer(nodeend^.bp.ListPos.Owner);
                        pnodeendvarext:=nodeend^.GetExtension(typeof(TVariablesExtender));
                        //pvd:=PTObjectUnit(nodeend^.ou.Instance)^.FindVariable('NMO_Name');
                        pvd:=pnodeendvarext^.entityunit.FindVariable('NMO_Name');
                        if pvd<>nil then
                        begin
                             //endname:=pstring(pvd^.data.Instance)^;
                             endname:=pvd^.data.PTD.GetValueAsString(pvd^.data.Instance);
                        end
                           else endname:='';
                        //pvd:=PTObjectUnit(nodeend^.ou.Instance)^.FindVariable('DB_link');
                        pvd:=pnodeendvarext^.entityunit.FindVariable('DB_link');
                        if pvd<>nil then
                        begin
                            //endmat:=pstring(pvd^.data.Instance)^;
                            endmat:=pvd^.data.PTD.GetValueAsString(pvd^.data.Instance);
                            if isfirst then
                                           begin
                                                isfirst:=false;
                                                nodestart:=nodeend;
                                                startmat:=endmat;
                                                startname:=endname;
                                           end;
                            if startmat<>endmat then
                            begin
                                 InsertDat(nodestart^.name,startname,prevname,count,currentcoord,GDB.GetCurrentDWG.ConstructObjRoot);
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
                                        InsertDat(nodestart^.name,startname,endname,count,currentcoord,GDB.GetCurrentDWG.ConstructObjRoot).YouDeleted(gdb.GetCurrentDWG^)
                                    else
                                        InsertDat('_error_here',startname,endname,count,currentcoord,GDB.GetCurrentDWG.ConstructObjRoot).YouDeleted(gdb.GetCurrentDWG^);

                  //pvd:=PTObjectUnit(PCableSS.ou.Instance)^.FindVariable('CABLE_WireCount');
                  pvd:=pCableSSvarext^.entityunit.FindVariable('CABLE_WireCount');
                  if pvd=nil then
                                 coord.x:=coord.x+12
                             else
                                 begin
                                      if pgdbinteger(pvd^.data.Instance)^<>0 then
                                                                                  coord.x:=coord.x+6*pgdbinteger(pvd^.data.Instance)^
                                                                              else
                                                                                  coord.x:=coord.x+12;
                                 end;
             end

        end;


  pcabledesk:=cman.iterate(ir);
  until pcabledesk=nil;

  cman.done;

  if assigned(redrawoglwndproc) then redrawoglwndproc;
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
function PlCommandStart(operands:pansichar):GDBInteger;
var //i: GDBInteger;
    sd:TSelObjDesk;
begin
  OrtoDevPlaceParam.Name:='';
  sd:=GetSelOjbj;
    if sd.PFirstObj<>nil then
    if (sd.PFirstObj^.vp.ID=GDBBlockInsertID) then
    begin
         OrtoDevPlaceParam.Name:=PGDBObjBlockInsert(sd.PFirstObj)^.name;
    end
else if (sd.PFirstObj^.vp.ID=GDBDeviceID) then
    begin
         OrtoDevPlaceParam.Name:=DevicePrefix+PGDBObjBlockInsert(sd.PFirstObj)^.name;
    end;

  if (OrtoDevPlaceParam.Name='')or(sd.Count=0)or(sd.Count>1) then
                                   begin
                                        historyout('Должен быть выбран только один блок или устройство!');
                                        commandmanager.executecommandend;
                                        exit;
                                   end;

  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
  GDB.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera));
  historyout('Первый угол:');
  If assigned(SetGDBObjInspProc)then
  SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('CommandRTEdObject'),pco2,gdb.GetCurrentDWG);
  OPSPlaceSmokeDetectorOrtoParam.DMC:=TOPSMDC_1_2;
end;
function PlBeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): integer;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
    begin
      historyout('Второй угол');
      t3dp:=wc;
    end
end;
procedure placedev(pva:PGDBObjEntityOpenArray;p1, p2: gdbvertex; nmax, nmin: GDBInteger; name: pansichar;a:gdbdouble;aa:gdbboolean;Norm:GDBBoolean);
var dx, dy: GDBDouble;
  line1, line2: gdbline;
  l1, l2, i: integer;
  dir: gdbvertex;
//  mincount:integer;
  sd,{dd,}sdd,{ddd,}angle:double;
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
  case l1 of
    1: begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 0.5), dir, l2, sd, name,angle,norm,OrtoDevPlaceParam.ScaleBlock);
       end;
    2: begin
        //if (Vertexlength(line1.lbegin, line1.lend) - 2 * sd)<dd then
        begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 1 / 4), dir, l2, sd, name,angle,norm,OrtoDevPlaceParam.ScaleBlock);
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 3 / 4), dir, l2, sd, name,angle,norm,OrtoDevPlaceParam.ScaleBlock);
        end
        {else
        begin
        place2(pva,Vertexmorphabs(line1.lbegin, line1.lend, sd), dir, l2, sd, name);
        place2(pva,Vertexmorphabs(line1.lbegin, line1.lend, -sd), dir, l2, sd, name);
        end}
       end
  else begin
      place2(pva,Vertexmorphabs2(line1.lbegin, line1.lend, sdd{}), dir, l2, sd, name,angle,norm,OrtoDevPlaceParam.ScaleBlock);
      place2(pva,Vertexmorphabs2(line1.lbegin, line1.lend, -sdd{}), dir, l2, sd, name,angle,norm,OrtoDevPlaceParam.ScaleBlock);
      line2.lbegin := Vertexmorphabs2(line1.lbegin, line1.lend, sdd);
      line2.lend := Vertexmorphabs2(line1.lbegin, line1.lend, -sdd);
      l1:=l1-2;
      for i := 1 to l1 do place2(pva,Vertexmorph(line2.lbegin, line2.lend, i / (l1 + 1)), dir, l2, sd, name,angle,norm,OrtoDevPlaceParam.ScaleBlock);
      //for i := 1 to l2 do place3(pva,Vertexmorph(line2.lbegin, line2.lend, i / (l2 )), dir, l1, dd, name);
       end
  end;
end;
function PlAfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): integer;
var
pl:pgdbobjline;
//debug:string;
//dw,dd:gdbdouble;
nx,ny:GDBInteger;
//t:GDBInteger;
tt,tx,ty,ttx,tty:gdbdouble;
DC:TDrawContext;
begin
  //nx:=OrtoDevPlaceParam.NX;
  //ny:=OrtoDevPlaceParam.NY;
  result:=mclick;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;


  pl := PGDBObjLine(ENTF_CreateLine(@gdb.GetCurrentDWG.ConstructObjRoot,@gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray,[t3dp.x,t3dp.y,t3dp.z,wc.x,wc.y,wc.z]));
  GDBObjSetEntityProp(pl,gdb.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^,sysvar.dwg.DWG_CLinew^);
  //pl := pointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID{,gdb.GetCurrentROOT}));
  //GDBObjLineInit(gdb.GetCurrentROOT,pl, gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^, t3dp, wc);
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pl^.FormatEntity(gdb.GetCurrentDWG^,dc);

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
       placedev(@gdb.GetCurrentDWG.ConstructObjRoot.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, NX, NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
  end
  else
  begin
       result:=-1;
       pco^.mouseclic:=-1;
       //gdb.GetCurrentDWG.ConstructObjRoot.cleareraseobj;
       placedev(@gdb.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, NX, NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
       gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;

       gdb.GetCurrentROOT.calcbb(dc);
       if assigned(redrawoglwndproc) then redrawoglwndproc;
       historyout('Первый угол:');
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

  CreateCommandFastObjectPlugin(@OPS_Sensor_Mark_com,'OPS_Sensor_Mark',CADWG,0);
  pco:=CreateCommandRTEdObjectPlugin(@CommandStart,nil,nil,@commformat,@BeforeClick,@AfterClick,nil,nil,command1,0,0);
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
  OPSPlaceSmokeDetectorOrtoParam.Height.Enums.FreeAndDone;
  //result := 0;
end;
initialization
  startup;
finalization
  finalize;
end.
