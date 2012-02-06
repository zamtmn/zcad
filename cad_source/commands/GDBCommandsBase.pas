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

unit GDBCommandsBase;
{$INCLUDE def.inc}

interface
uses
 UGDBStringArray,ucxmenumgr,intftranslations,layerwnd,strutils,strproc,umytreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,{ SysUtils,} FileUtil,{ LResources,} Forms, {stdctrls,} Controls, {Graphics, Dialogs,}ComCtrls,Clipbrd,lclintf,
  plugins,OGLSpecFunc,
  sysinfo,
  //commandline,
  commandlinedef,
  commanddefinternal,
  gdbase,
  UGDBDescriptor,
  sysutils,
  varmandef,
  oglwindowdef,
  //OGLtypes,
  UGDBOpenArrayOfByte,
  iodxf,iodwg,
  //optionswnd,
  objinsp,
  //cmdline,
  //UGDBVisibleOpenArray,
  gdbobjectsconstdef,
  GDBEntity,
 shared,
 sharedgdb,UGDBEntTree,
  {zmenus,}projecttreewnd,gdbasetypes,{optionswnd,}AboutWnd,HelpWnd,memman,WindowsSpecific,{txteditwnd,}
 {messages,}UUnitManager,{zguisct,}log,Varman,UGDBNumerator,cmdline,
 AnchorDocking,dialogs,XMLPropStorage,xmlconf,
   uPSCompiler,
  uPSRuntime,
  uPSC_std,
  uPSC_controls,
  uPSC_stdctrls,
  uPSC_forms,
  uPSR_std,
  uPSR_controls,
  uPSR_stdctrls,
  uPSR_forms;
type
{Export+}
  TMSType=(
           TMST_All(*'Всех примитивов'*),
           TMST_Devices(*'Устройств'*),
           TMST_Cables(*'Кабелей'*)
          );
  TMSEditor=object(GDBaseObject)
                SelCount:GDBInteger;(*'Выбрано объектов'*)(*oi_readonly*)
                EntType:TMSType;(*'Показать переменные'*)
                OU:TObjectUnit;(*'Переменные'*)
                procedure FormatAfterFielfmod(PField,PTypeDescriptor:GDBPointer);virtual;
                procedure CreateUnit;virtual;
                function GetObjType:GDBWord;virtual;
                constructor init;
                destructor done;virtual;
            end;
TOSModeEditor=object(GDBaseObject)
              osm:TOSMode;(*'Привязка'*)
              trace:TTraceMode;(*'Трассировка'*)
              procedure Format;virtual;
              procedure GetState;
             end;

{Export-}



   {procedure startup;
   procedure finalize;}
   var selframecommand:PCommandObjectDef;
       ms2objinsp:PCommandObjectDef;
       deselall,selall:pCommandFastObjectPlugin;

       MSEditor:TMSEditor;

       OSModeEditor:TOSModeEditor;

       InfoFormVar:TInfoForm=nil;

       MSelectCXMenu:TmyPopupMenu=nil;

   function SaveAs_com(Operands:pansichar):GDBInteger;
   procedure CopyToClipboard;
   function quit_com(Operands:pansichar):GDBInteger;
   function Regen_com(Operands:pansichar):GDBInteger;
resourcestring
     s_unknownFileExt='Unknown file format "%s". Saving failed.';
const
     ZCAD_DXF_CLIPBOARD_NAME='DXF2000@ZCADv0.9';
//var DWGPageCxMenu:pzpopupmenu;
implementation
uses commandline,GDBPolyLine,UGDBPolyLine2DArray,GDBLWPolyLine,mainwindow,UGDBSelectedObjArray,{ZBasicVisible,}oglwindow,geometry;
var
   CopyClipFile:GDBString;
procedure  TOSModeEditor.Format;
var
   i,c:integer;
   v:gdbvertex;

begin
    SysVar.dwg.DWG_OSMode^:=0;
    if osm.kosm_inspoint then inc(SysVar.dwg.DWG_OSMode^,osm_inspoint);
    if osm.kosm_endpoint then inc(SysVar.dwg.DWG_OSMode^,osm_endpoint);
    if osm.kosm_midpoint then inc(SysVar.dwg.DWG_OSMode^,osm_midpoint);
    if osm.kosm_3 then inc(SysVar.dwg.DWG_OSMode^,osm_3);
    if osm.kosm_4 then inc(SysVar.dwg.DWG_OSMode^,osm_4);
    if osm.kosm_center then inc(SysVar.dwg.DWG_OSMode^,osm_center);
    if osm.kosm_quadrant then inc(SysVar.dwg.DWG_OSMode^,osm_quadrant);
    if osm.kosm_point then inc(SysVar.dwg.DWG_OSMode^,osm_point);
    if osm.kosm_intersection then inc(SysVar.dwg.DWG_OSMode^,osm_intersection);
    if osm.kosm_perpendicular then inc(SysVar.dwg.DWG_OSMode^,osm_perpendicular);
    if osm.kosm_tangent then inc(SysVar.dwg.DWG_OSMode^,osm_tangent);
    if osm.kosm_nearest then inc(SysVar.dwg.DWG_OSMode^,osm_nearest);
    if osm.kosm_apparentintersection then inc(SysVar.dwg.DWG_OSMode^,osm_apparentintersection);
    if osm.kosm_paralel then inc(SysVar.dwg.DWG_OSMode^,osm_paralel);

    case self.trace.Angle of
         TTA90:c:=2;
         TTA45:c:=4;
         TTA30:c:=6;
    end;

  gdb.GetCurrentDWG.oglwindow1.PolarAxis.clear;
  for i := 0 to c - 1 do
  begin
    v.x:=cos(pi * i / c);
    v.y:=sin(pi * i / c);
    v.z:=0;
    gdb.GetCurrentDWG.oglwindow1.PolarAxis.add(@v);
  end;
  if self.trace.ZAxis then
  begin
    v.x:=0;
    v.y:=0;
    v.z:=1;
    gdb.GetCurrentDWG.oglwindow1.PolarAxis.add(@v);
  end;
end;
procedure TOSModeEditor.GetState;
begin
    if (SysVar.dwg.DWG_OSMode^ and osm_inspoint)=0 then
                                                       osm.kosm_inspoint:=false
                                                   else
                                                       osm.kosm_inspoint:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_endpoint)=0 then
                                                       osm.kosm_endpoint:=false
                                                   else
                                                       osm.kosm_endpoint:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_midpoint)=0 then
                                                       osm.kosm_midpoint:=false
                                                   else
                                                       osm.kosm_midpoint:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_3)=0 then
                                                       osm.kosm_3:=false
                                                   else
                                                       osm.kosm_3:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_4)=0 then
                                                       osm.kosm_4:=false
                                                   else
                                                       osm.kosm_4:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_center)=0 then
                                                       osm.kosm_center:=false
                                                   else
                                                       osm.kosm_center:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_quadrant)=0 then
                                                       osm.kosm_quadrant:=false
                                                   else
                                                       osm.kosm_quadrant:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_point)=0 then
                                                       osm.kosm_point:=false
                                                   else
                                                       osm.kosm_point:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_intersection)=0 then
                                                       osm.kosm_intersection:=false
                                                   else
                                                       osm.kosm_intersection:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_perpendicular)=0 then
                                                       osm.kosm_perpendicular:=false
                                                   else
                                                       osm.kosm_perpendicular:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_tangent)=0 then
                                                       osm.kosm_tangent:=false
                                                   else
                                                       osm.kosm_tangent:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_nearest)=0 then
                                                       osm.kosm_nearest:=false
                                                   else
                                                       osm.kosm_nearest:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_apparentintersection)=0 then
                                                       osm.kosm_apparentintersection:=false
                                                   else
                                                       osm.kosm_apparentintersection:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_paralel)=0 then
                                                       osm.kosm_paralel:=false
                                                   else
                                                       osm.kosm_paralel:=true;

end;
constructor  TMSEditor.init;
begin
     ou.init('multiselunit');
end;
destructor  TMSEditor.done;
begin
     ou.done;
end;
procedure  TMSEditor.FormatAfterFielfmod;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    //pu:pointer;
    pvd,pvdmy:pvardesk;
    //vd:vardesk;
    ir,ir2:itrec;
    //etype:integer;
begin
      pvd:=ou.InterfaceVariables.vardescarray.beginiterate(ir2);
      if pvd<>nil then
      repeat
            if pvd^.data.Instance=PFIELD then
            begin
                 pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
                 if pv<>nil then
                 repeat
                   if pv^.Selected then
                   if (pv^.GetObjType=GetObjType)or(GetObjType=0) then
                   begin
                        pvdmy:=pv^.ou.InterfaceVariables.findvardesc(pvd^.name);
                        if pvdmy<>nil then
                          if pvd^.data.PTD=pvdmy^.data.PTD then
                          begin
                               pvdmy.data.PTD.CopyInstanceTo(pvd.data.Instance,pvdmy.data.Instance);

                               pv^.Format;
                          end;

                   end;
                   pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
                 until pv=nil;


            end;
            //pvdmy:=ou.InterfaceVariables.findvardesc(pvd^.name);
            pvd:=ou.InterfaceVariables.vardescarray.iterate(ir2)
      until pvd=nil;
     createunit;
     GDBobjinsp.rebuild;
     //GDBobjinsp.setptr(SysUnit.TypeName2PTD('TMSEditor'),@MSEditor);
end;
function TMSEditor.GetObjType:GDBWord;
begin
     case EntType of
                    TMST_All:result:=0;
                    TMST_Devices:result:=GDBDeviceID;
                    TMST_Cables:result:=GDBCableID;
     end;
end;
procedure  TMSEditor.createunit;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    psd:PSelectedObjDesc;
    pu:pointer;
    pvd,pvdmy:pvardesk;
    vd:vardesk;
    ir,ir2:itrec;
    //etype:integer;
begin
     self.SelCount:=0;
     ou.free;
     //etype:=GetObjType;
     psd:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
     //pv:=gdb.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
     if psd<>nil then
     repeat
       pv:=psd^.objaddr;
       if pv<>nil then

       if pv^.Selected then
       begin
       inc(self.SelCount);
       if (pv^.GetObjType=GetObjType)or(GetObjType=0) then
       begin
            pu:=pv^.ou.InterfaceUses.beginiterate(ir2);
            if pu<>nil then
            repeat
                  ou.InterfaceUses.addnodouble(@pu);
                  pu:=pv^.ou.InterfaceUses.iterate(ir2)
            until pu=nil;
            pvd:=pv^.ou.InterfaceVariables.vardescarray.beginiterate(ir2);
            if pvd<>nil then
            repeat
                  pvdmy:=ou.InterfaceVariables.findvardesc(pvd^.name);
                  if pvdmy=nil then
                                   begin
                                        //if (pvd^.data.PTD^.GetTypeAttributes and TA_COMPOUND)=0 then
                                        begin
                                        vd:=pvd^;
                                        //vd.attrib:=vda_different;
                                        vd.data.Instance:=nil;
                                        ou.InterfaceVariables.createvariable(pvd^.name,vd);
                                        pvd^.data.PTD.CopyInstanceTo(pvd.data.Instance,vd.data.Instance);
                                        end
                                        {   else
                                        begin

                                        end;}
                                   end
                               else
                                   begin
                                        if pvd^.data.PTD.GetValueAsString(pvd^.data.Instance)<>pvdmy^.data.PTD.GetValueAsString(pvdmy^.data.Instance) then
                                           pvdmy.attrib:=vda_different;
                                   end;

                  pvd:=pv^.ou.InterfaceVariables.vardescarray.iterate(ir2)
            until pvd=nil;
       end;
       end;
     //pv:=gdb.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
     psd:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
     until psd=nil;
end;
function MultiSelect2ObjIbsp_com(Operands:pansichar):GDBInteger;
{$IFDEF TOTALYLOG}
var
   membuf:GDBOpenArrayOfByte;
{$ENDIF}
begin
     MSEditor.CreateUnit;
     if MSEditor.SelCount>0 then
                                begin
                                 {$IFDEF TOTALYLOG}
                                 membuf.init({$IFDEF DEBUGBUILD}'{6F6386AC-95B5-4B6D-AEC3-7EE5DD53F8A3}',{$ENDIF}10000);
                                 MSEditor.OU.SaveToMem(membuf);
                                 membuf.SaveToFile('*log\lms.pas');
                                 {$ENDIF}
                                 SetGDBObjInsp(SysUnit.TypeName2PTD('TMSEditor'),@MSEditor);
                                end
                            else
                                commandmanager.executecommandend;
end;
function GetOnMouseObjWAddr(var ContextMenu:TmyPopupMenu):GDBInteger;
var
  pp:PGDBObjEntity;
  ir:itrec;
  inr:TINRect;
  line:GDBString;
  pvd:pvardesk;
begin
     result:=0;
     pp:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir);
     if pp<>nil then
                    begin
                         repeat
                         pvd:=pp.ou.FindVariable('NMO_Name');
                         if pvd<>nil then
                                         begin
                                         if Result=20 then
                                         begin
                                              //result:=result+#13#10+'...';
                                              exit;
                                         end;
                                         line:=pp^.GetObjName+' Layer='+pp^.vp.Layer.GetFullName;
                                         line:=line+' Name='+pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                                         ContextMenu.Items.Add(TmyMenuItem.create(ContextMenu,line,'SelectObjectByAddres('+inttostr(GDBPlatformint(pp))+')'));
                                         //if result='' then
                                         //                 result:=line
                                         //             else
                                         //                 result:=result+#13#10+line;
                                         inc(Result);
                                         end;
                               pp:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir);
                         until pp=nil;
                    end;
end;
function SelectOnMouseObjects_com(Operands:pansichar):GDBInteger;
begin
     cxmenumgr.closecurrentmenu;
     MSelectCXMenu:=TmyPopupMenu.create(nil);
     if GetOnMouseObjWAddr(MSelectCXMenu)=0 then
                                                         FreeAndNil(MSelectCXMenu)
                                                     else
                                                         cxmenumgr.PopUpMenu(MSelectCXMenu);
end;
function SelectObjectByAddres_com(Operands:pansichar):GDBInteger;
var
   pp:PGDBObjEntity;
   code:integer;
begin
     val(Operands,GDBPlatformint(pp),code);
     if (code=0)and(assigned(pp))then
                                     begin
                                     pp^.select;
                                     gdb.CurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject:=pp;
                                     end;
     updatevisible;
     gdb.CurrentDWG.OGLwindow1.SetObjInsp;
     //SetObjInsp;
     //commandmanager.executecommandsilent('MultiSelect2ObjIbsp');
end;

function SetObjInsp_com(Operands:pansichar):GDBInteger;
var
   obj:gdbstring;
   objt:PUserTypeDescriptor;
  pp:PGDBObjEntity;
  ir:itrec;
begin
     if Operands='VARS' then
                            begin
                                 SetGDBObjInsp(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar);
                            end
else if Operands='CAMERA' then
                            begin
                                 SetGDBObjInsp(SysUnit.TypeName2PTD('GDBObjCamera'),gdb.GetCurrentDWG.pcamera);
                            end
else if Operands='CURRENT' then
                            begin

                                 if (GDB.GetCurrentDWG.GetLastSelected <> nil)
                                 then
                                     begin
                                          obj:=pGDBObjEntity(GDB.GetCurrentDWG.GetLastSelected)^.GetObjTypeName;
                                          objt:=SysUnit.TypeName2PTD(obj);
                                          SetGDBObjInsp(objt,GDB.GetCurrentDWG.GetLastSelected);
                                     end
                                 else
                                     begin
                                          ShowError('ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try find selected in DRAWING...');
                                          pp:=gdb.GetCurrentROOT.objarray.beginiterate(ir);
                                          if pp<>nil then
                                         begin
                                              repeat
                                              if pp^.Selected then
                                                              begin
                                                                   obj:=pp^.GetObjTypeName;
                                                                   objt:=SysUnit.TypeName2PTD(obj);
                                                                   SetGDBObjInsp(objt,pp);
                                                                   exit;
                                                              end;
                                              pp:=gdb.GetCurrentROOT.objarray.iterate(ir);
                                              until pp=nil;
                                         end;
                                     end;
                                 SysVar.DWG.DWG_SelectedObjToInsp^:=false;
                            end
else if Operands='OGLWND_DEBUG' then
                            begin
                                 SetGDBObjInsp(SysUnit.TypeName2PTD('OGLWndtype'),@gdb.GetCurrentDWG.OGLwindow1.param);
                            end
else if Operands='GDBDescriptor' then
                            begin
                                 SetGDBObjInsp(SysUnit.TypeName2PTD('GDBDescriptor'),@gdb);
                            end
else if Operands='RELE_DEBUG' then
                            begin
                                 SetGDBObjInsp(dbunit.TypeName2PTD('vardesk'),dbunit.FindVariable('SEVCABLEkvvg'));
                            end
else if Operands='LAYERS' then
                            begin
                                 SetGDBObjInsp(dbunit.TypeName2PTD('GDBLayerArray'),@gdb.GetCurrentDWG.LayerTable);
                            end
else if Operands='TSTYLES' then
                            begin
                                 SetGDBObjInsp(dbunit.TypeName2PTD('GDBTextStyleArray'),@gdb.GetCurrentDWG.TextStyleTable);
                            end
else if Operands='FONTS' then
                            begin
                                 SetGDBObjInsp(dbunit.TypeName2PTD('GDBFontManager'),@FontManager);
                            end
else if Operands='OSMODE' then
                            begin
                                 OSModeEditor.GetState;
                                 SetGDBObjInsp(dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor);
                            end
else if Operands='NUMERATORS' then
                            begin
                                 SetGDBObjInsp(SysUnit.TypeName2PTD('GDBNumerator'),@gdb.GetCurrentDWG.Numerator);
                            end
else if Operands='TABLESTYLES' then
                            begin
                                 SetGDBObjInsp(SysUnit.TypeName2PTD('GDBTableStyleArray'),@gdb.GetCurrentDWG.TableStyleTable);
                            end
                            ;
     GDBobjinsp.SetCurrentObjDefault;
end;
function CloseDWG_com(Operands:pansichar):GDBInteger;
var
   poglwnd:toglwnd;
   CurrentDWG:PTDrawing;
begin
  application.ProcessMessages;
  CurrentDWG:=gdb.GetCurrentDWG;
  if CurrentDWG<>nil then
  begin
       if CurrentDWG.Changed then
                                 begin
                                      if MainFormN.MessageBox('Чертеж имеет изменения. Закрыть?','Внимание!',MB_YESNO)<>IDYES then exit;
                                 end;
       poglwnd:=CurrentDWG.OGLwindow1;
       //mainform.PageControl.delpage(mainform.PageControl.onmouse);
       gdb.eraseobj(CurrentDWG);
       gdb.pack;
       poglwnd.PDWG:=nil;
       gdb.CurrentDWG:=nil;

       poglwnd.free;

       mainformn.PageControl.ActivePage.Free;
       tobject(poglwnd):=mainformn.PageControl.ActivePage;

       if poglwnd<>nil then
       begin
            tobject(poglwnd):=FindControlByType(poglwnd,TOGLWnd);
            //pointer(poglwnd):=poglwnd^.FindKidsByType(typeof(TOGLWnd));
            gdb.CurrentDWG:=poglwnd.PDWG;
            poglwnd.GDBActivate;
       end;
       shared.SBTextOut('Закрыто');
       GDBobjinsp.ReturnToDefault;
       sharedgdb.updatevisible;
  end;
end;

function CloseDWGOnMouse_com(Operands:pansichar):GDBInteger;
var
   poglwnd:Ptoglwnd;
begin
     {переделать
     poglwnd:=pointer(mainform.PageControl.getpagewindow(mainform.PageControl.onmouse)^.FindKidsByType(typeof(TOGLWnd)));
     if poglwnd<>nil then
     begin
          mainform.PageControl.delpage(mainform.PageControl.onmouse);
          gdb.eraseobj(poglwnd^.PDWG);
          gdb.pack;
          poglwnd^.PDWG:=nil;

          pointer(poglwnd):=mainform.PageControl.GetCurSel;
          if poglwnd<>nil then
          begin
               pointer(poglwnd):=poglwnd^.FindKidsByType(typeof(TOGLWnd));

               gdb.CurrentDWG:=poglwnd^.PDWG;
          end;

          shared.updatevisible;
     end;}
end;
function Load_Merge(Operands:pansichar;LoadMode:TLoadOpt):GDBInteger;
var
   s: GDBString;
   fileext:GDBString;
   isload:boolean;
   mem:GDBOpenArrayOfByte;
   pu:ptunit;
begin
     if gdb.currentdwg<>BlockBaseDWG then
     if gdb.GetCurrentROOT.ObjArray.Count>0 then
                                                     begin
                                                          if MainFormN.messagebox('Чертеж уже содержит данные. Осуществить подгрузку?','QLOAD',MB_YESNO)=IDNO then
                                                          exit;
                                                     end;
     s:=operands;
     isload:=FileExists(utf8tosys(s));
     if isload then
     begin
          fileext:=uppercase(ExtractFileEXT(s));
          if fileext='.ZCP' then LoadZCP(s, @GDB)
     else if fileext='.DXF' then
                                begin
                                     //if operands<>'QS' then
                                     //                      gdb.GetCurrentDWG.FileName:=s;
                                     if gdb.currentdwg<>BlockBaseDWG then
                                                                       begin
                                                                       isOpenGLError;
                                                                       end;
                                     addfromdxf(s,@gdb.GetCurrentDWG^.pObjRoot^,loadmode);
                                     if gdb.currentdwg<>BlockBaseDWG then
                                                                       begin
                                                                       isOpenGLError;
                                                                       end;
                                     if FileExists(utf8tosys(s+'.dbpas')) then
                                     begin
                                           pu:=gdb.GetCurrentDWG.DWGUnits.findunit('drawingdevicebase');
                                           mem.InitFromFile(s+'.dbpas');
                                           pu^.free;
                                           units.parseunit(mem,PTSimpleUnit(pu));
                                           mem.done;
                                     end;
                                end
          else if fileext='.DWG' then
                                     begin
                                          addfromdwg(s,@gdb.GetCurrentDWG^.pObjRoot^,loadmode);
                                          if FileExists(utf8tosys(s+'.dbpas')) then
                                          begin
                                                pu:=gdb.GetCurrentDWG.DWGUnits.findunit('drawingdevicebase');
                                                mem.InitFromFile(s+'.dbpas');
                                                pu^.free;
                                                units.parseunit(mem,PTSimpleUnit(pu));
                                                mem.done;
                                          end;
                                     end;

     if gdb.currentdwg<>BlockBaseDWG then
                                         ReloadLayer;
     gdb.GetCurrentROOT.calcbb;
     //gdb.GetCurrentDWG.ObjRoot.format;//FormatAfterEdit;
     //gdb.GetCurrentROOT.sddf
     //gdb.GetCurrentROOT.format;
     gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot.ObjArray,gdb.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,0,nil,TND_Root)^;
     gdb.GetCurrentROOT.format;
     updatevisible;
     if gdb.currentdwg<>BlockBaseDWG then
                                         begin
                                         gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot.ObjArray,gdb.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,0,nil,TND_Root)^;
                                         isOpenGLError;
                                         redrawoglwnd;
                                         end;
     result:=cmd_ok;

     end
        else
        shared.ShowError('GDBCommandsBase.MERGE: Не могу открыть файл: '+s);
end;

function NextDrawint_com(Operands:pansichar):GDBInteger;
var
   i:integer;
begin
     if assigned(MainFormN.PageControl)then
     if MainFormN.PageControl.PageCount>1 then
     begin
          i:=MainFormN.PageControl.ActivePageIndex+1;
          if i=MainFormN.PageControl.PageCount
                                              then
                                                  i:=0;
             MainFormN.PageControl.ActivePageIndex:=i;
     end;
end;
function PrevDrawint_com(Operands:pansichar):GDBInteger;
var
   i:integer;
begin
     if assigned(MainFormN.PageControl)then
     if MainFormN.PageControl.PageCount>1 then
     begin
          i:=MainFormN.PageControl.ActivePageIndex-1;
          if i<0
                                            then
                                                  i:=MainFormN.PageControl.PageCount-1;
             MainFormN.PageControl.ActivePageIndex:=i;
     end;
end;

function Merge_com(Operands:pansichar):GDBInteger;
var
   s: GDBString;
   fileext:GDBString;
   isload:boolean;
   mem:GDBOpenArrayOfByte;
   pu:ptunit;
begin
     result:=Load_merge(operands,TLOMerge);
end;
function newdwg_com(Operands:pansichar):GDBInteger;
var
   ptd:PTDrawing;
   //tf:PZbasic;
   myts:TTabSheet;
   oglwnd:TOGLWND;
   tn:GDBString;
begin
     ptd:=gdb.CreateDWG;

     gdb.AddRef(ptd^);

     gdb.SetCurrentDWG(ptd);

     if length(operands)=0 then
                               operands:=@UnnamedWindowTitle[1];

     {tf:=mainform.PageControl.addpage(Operands);
     mainform.PageControl.selpage(mainform.PageControl.lastcreated);
     mainform.PageControl.CxMenu:=DWGPageCxMenu;}

     myts:=nil;

     if not assigned(MainFormN.PageControl)then
     begin
          DockMaster.ShowControl('PageControl',true);
          //DockMaster.ShowControl('PageControl',true);
     end;


     myts:=TTabSheet.create(MainFormN.PageControl);
     myts.Caption:=(Operands);
     //mainformn.DisableAutoSizing;
     myts.Parent:=MainFormN.PageControl;
     //mainformn.EnableAutoSizing;

     //tf.align:=al_client;

     oglwnd:=TOGLWnd.Create(myts);

     oglwnd.AuxBuffers:=4;
     oglwnd.StencilBits:=8;
     oglwnd.ColorBits:=24;
     oglwnd.DepthBits:=24;



     //--------------------------------------------------------------oglwnd.BevelOuter:=bvnone;

     gdb.GetCurrentDWG.OGLwindow1:=oglwnd;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.PDWG:=ptd;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.align:=alClient;
          //gdb.GetCurrentDWG.OGLwindow1.align:=al_client;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.Parent:=myts;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.init;{переделать из инита нужно убрать обнуление pdwg}
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.PDWG:=ptd;
     programlog.logoutstr('oglwnd.PDWG:=ptd;',0);
     oglwnd._onresize(nil);
     oglwnd.GDBActivate;
     programlog.logoutstr('oglwnd._onresize(nil);',0);
     oglwnd.MakeCurrent(false);
     programlog.logoutstr('oglwnd.MakeCurrent(false);',0);
     isOpenGLError;
     programlog.logoutstr('isOpenGLError;',0);
     //oglwnd.DoubleBuffered:=false;
     oglwnd.show;
     programlog.logoutstr('oglwnd.show;',0);
     isOpenGLError;
     programlog.logoutstr('isOpenGLError;',0);
     //oglwnd.Repaint;
     //gdb.GetCurrentDWG.OGLwindow1.initxywh('oglwnd',tf,200,72,768,596,false);

     //tf.size;

     //gdb.GetCurrentDWG.OGLwindow1.Show;

     //GDBGetMem({$IFDEF DEBUGBUILD}'{E197C531-C543-4FAF-AF4A-37B8F278E8A2}',{$ENDIF}GDBPointer(gdb.GetCurrentDWG),sizeof(UGDBDescriptor.TDrawing));
     //gdb.GetCurrentDWG^.init(@gdb.ProjectUnits);
     //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_nok.dxf',@gdb.GetCurrentDWG.ObjRoot);

     MainFormN.PageControl.ActivePage:=myts;
     programlog.logoutstr('MainFormN.PageControl.ActivePage:=myts;',0);
     sharedgdb.updatevisible;
     programlog.logoutstr('sharedgdb.updatevisible;',0);
     operands:=operands;
     programlog.logoutstr('operands:=operands;???????????????',0);
     if not fileexists(operands) then
     begin
     tn:=expandpath(sysvar.PATH.Template_Path^)+sysvar.PATH.Template_File^;
     if fileExists(utf8tosys(tn)) then
                           merge_com(@tn[1])
                       else
                           shared.ShowError('Не найден файл шаблона "'+tn+'"');
     end;
     //redrawoglwnd;
     result:=cmd_ok;
     programlog.logoutstr('result:=cmd_ok;',0);
     application.ProcessMessages;
     programlog.logoutstr(' application.ProcessMessages;',0);
     oglwnd._onresize(nil);
     programlog.logoutstr('oglwnd._onresize(nil);',0);
end;
function DeSelectAll_com(Operands:pansichar):GDBInteger;
begin
     //redrawoglwnd;
     updatevisible;
     result:=cmd_ok;
end;

function SelectAll_com(Operands:pansichar):GDBInteger;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if gdb.GetCurrentROOT.ObjArray.Count = 0 then exit;
  GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount:=0;

  count:=0;

  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    inc(count);
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;


  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
        if count>10000 then
                           pv^.SelectQuik//:=true
                       else
                           pv^.select;

  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;

  //redrawoglwnd;
  updatevisible;
  result:=cmd_ok;
end;
function Load_com(Operands:pansichar):GDBInteger;
var
   s: GDBString;
   //fileext:GDBString;
   isload:boolean;
   //mem:GDBOpenArrayOfByte;
   //pu:ptunit;
begin
     if length(operands)=0 then
                        begin
                             mainformn.ShowAllCursors;
                             isload:=OpenFileDialog(s,'dxf',ProjectFileFilter,'','Открыть проект...');
                             mainformn.RestoreCursors;
                             //s:=utf8tosys(s);
                             if not isload then
                                               begin
                                                    result:=cmd_cancel;
                                                    exit;
                                               end
                                           else
                                               begin

                                               end;    

                        end
                    else
                    begin
                         if operands='QS' then
                                              s:=ExpandPath(sysvar.SAVE.SAVE_Auto_FileName^)
                                          else
                                              begin
                                              s:=ExpandPath(operands);
                                              s:=FindInSupportPath(operands);
                                              end;
                    end;
     isload:=FileExists(utf8tosys(s));
     if isload then
     begin
          newdwg_com(@s[1]);
          //if operands<>'QS' then
                                gdb.GetCurrentDWG.FileName:=s;
          programlog.logoutstr('gdb.GetCurrentDWG.FileName:=s;',0);
          load_merge(@s[1],tloload);
          programlog.logoutstr('load_merge(@s[1],tloload);',0);
          MainFormN.processfilehistory(s);
     end
               else
        shared.ShowError('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
end;
function MergeBlocks_com(Operands:pansichar):GDBInteger;
var
   pdwg:PTDrawing;
   s:gdbstring;
begin
     pdwg:=GDB.CurrentDWG;
     GDB.CurrentDWG:=BlockBaseDWG;

     if length(operands)>0 then
     s:=FindInSupportPath(operands);
     result:=Merge_com(@s[1]);

     GDB.CurrentDWG:=pdwg;
end;

procedure SaveDXFDPAS(s:gdbstring);
var
   mem:GDBOpenArrayOfByte;
   pu:ptunit;
   filepath,filename{,fileext}:GDBString;
begin
     savedxf2000(s, GDB.GetCurrentDWG);

     pu:=gdb.GetCurrentDWG.DWGUnits.findunit('drawingdevicebase');
     mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
     pu^.SavePasToMem(mem);
     filepath:=ExtractFilePath(s);
     filename:=ExtractFileName(s);
     mem.SaveToFile(s+'.dbpas');
     mem.done;
     MainFormN.processfilehistory(s);
end;
function QSave_com(Operands:pansichar):GDBInteger;
var s,s1:GDBString;
begin
     if gdb.GetCurrentROOT.ObjArray.Count<1 then
                                                     begin
                                                          if MainFormN.messagebox('Сохраняемый файл пуст. Уверенны?','QSAVE',MB_YESNO)=IDNO then
                                                          exit;
                                                     end;
     if operands='QS' then
                          begin
                               s1:=ExpandPath(sysvar.SAVE.SAVE_Auto_FileName^);
                               s:='Autosave... '''+s1+'''';
                               historyout(pansichar(s));
                          end
                      else
                          begin
                               if gdb.GetCurrentDWG.FileName=UnnamedWindowTitle then
                                                                      begin
                                                                           //commandmanager.executecommandend;
                                                                           SaveAs_com('');
                                                                           exit;
                                                                      end;
                               s1:=gdb.GetCurrentDWG.FileName;
                          end;
     SaveDXFDPAS(s1);
     //savedxf2000(s1, @GDB);
     SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
     result:=cmd_ok;
end;
function SaveAs_com(Operands:pansichar):GDBInteger;
var //pd:^TSaveDialog;
   //sfn: TopenFILENAME;
//   cf: pansichar;
   s: GDBString;
//   errcode: DWord;
   {filepath,filename,}fileext:GDBString;
//    fileext:GDBString;
//   mem:GDBOpenArrayOfByte;
//   ev:TEditWnd;
//   a:integer;
//   pobj:PGDBObjEntity;
//   op:gdbstring;
//   pu:ptunit;

begin
     mainformn.ShowAllCursors;
     if SaveFileDialog(s,'dxf',ProjectFileFilter,'','Сохранить проект...') then
     begin
          fileext:=uppercase(ExtractFileEXT(s));
          if fileext='.ZCP' then
                                saveZCP(s, @GDB)
     else if fileext='.DXF' then
                                begin
                                     SaveDXFDPAS(s);
                                     gdb.GetCurrentDWG.FileName:=s;
                                     updatevisible;
                                    (* savedxf2000(s, @GDB);
                                     pu:=gdb.GetCurrentDWG.DWGUnits.findunit('drawingdevicebase');
                                     mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
                                     pu^.SavePasToMem(mem);
                                     filepath:=ExtractFilePath(s);
                                     filename:=ExtractFileName(s);
                                     mem.SaveToFile(s+'.dbpas');
                                     mem.done; *)
                                end
     else begin
          shared.ShowError(Format(s_unknownFileExt, [fileext]));
          end;
     end;
     result:=cmd_ok;
     mainformn.RestoreCursors;
end;
function Cam_reset_com(Operands:pansichar):GDBInteger;
begin
  gdb.GetCurrentDWG.UndoStack.PushStartMarker('Камера в начало');
  with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
  begin
  gdb.GetCurrentDWG.pcamera^.prop.point.x := 0;
  gdb.GetCurrentDWG.pcamera^.prop.point.y := 0;
  gdb.GetCurrentDWG.pcamera^.prop.point.z := 50;
  gdb.GetCurrentDWG.pcamera^.prop.look.x := 0;
  gdb.GetCurrentDWG.pcamera^.prop.look.y := 0;
  gdb.GetCurrentDWG.pcamera^.prop.look.z := -1;
  gdb.GetCurrentDWG.pcamera^.prop.ydir.x := 0;
  gdb.GetCurrentDWG.pcamera^.prop.ydir.y := 1;
  gdb.GetCurrentDWG.pcamera^.prop.ydir.z := 0;
  gdb.GetCurrentDWG.pcamera^.prop.xdir.x := -1;
  gdb.GetCurrentDWG.pcamera^.prop.xdir.y := 0;
  gdb.GetCurrentDWG.pcamera^.prop.xdir.z := 0;
  gdb.GetCurrentDWG.pcamera^.anglx := -pi;
  gdb.GetCurrentDWG.pcamera^.angly := -pi / 2;
  gdb.GetCurrentDWG.pcamera^.zmin := 1;
  gdb.GetCurrentDWG.pcamera^.zmax := 100000;
  gdb.GetCurrentDWG.pcamera^.fovy := 35;
  gdb.GetCurrentDWG.pcamera^.prop.zoom := 0.1;
  ComitFromObj;
  end;
  gdb.GetCurrentDWG.UndoStack.PushEndMarker;
  redrawoglwnd;
  result:=cmd_ok;
end;
function Undo_com(Operands:pansichar):GDBInteger;
var
   prevundo:integer;
   overlay:GDBBoolean;
begin
  gdb.GetCurrentROOT.ObjArray.DeSelect;
  if commandmanager.CommandsStack.Count>0 then
                                              begin
                                                   prevundo:=pCommandRTEdObject(ppointer(commandmanager.CommandsStack.getelement(commandmanager.CommandsStack.Count-1))^)^.UndoTop;
                                                   overlay:=true;
                                              end
                                          else
                                              begin
                                                   prevundo:=0;
                                                   overlay:=false;
                                              end;
  gdb.GetCurrentDWG.UndoStack.undo(prevundo,overlay);
  redrawoglwnd;
  result:=cmd_ok;
end;
function Redo_com(Operands:pansichar):GDBInteger;
begin
  gdb.GetCurrentROOT.ObjArray.DeSelect;
  gdb.GetCurrentDWG.UndoStack.redo;
  redrawoglwnd;
  result:=cmd_ok;
end;

function ChangeProjType_com(Operands:pansichar):GDBInteger;
var
   ta:TmyAction;
begin
     ta:=tmyaction(MainFormN.StandartActions.ActionByName('ACN_PERSPECTIVE'));
  if GDB.GetCurrentDWG.OGLwindow1.param.projtype = projparalel then
  begin
    GDB.GetCurrentDWG.OGLwindow1.param.projtype := projperspective;
    if ta<>nil then
                   ta.Checked:=true;

  end
  else
    if GDB.GetCurrentDWG.OGLwindow1.param.projtype = projPerspective then
    begin
    GDB.GetCurrentDWG.OGLwindow1.param.projtype := projparalel;
      if ta<>nil then
                     ta.Checked:=false;
    end;
  redrawoglwnd;
  result:=cmd_ok;
end;
procedure FrameEdit_com_CommandStart(Operands:pansichar);
begin
  //inherited CommandStart;
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPointWOOP) or (MMoveCamera) or (MRotateCamera));
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := true;
  historyout('Первая точка:');
end;
procedure FrameEdit_com_Command_End;
begin
  //ugdbdescriptor.poglwnd^.md.mode := (MGet3DPointWOOP) or (MMoveCamera) or (MRotateCamera);
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := false;
end;

function FrameEdit_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
begin
  result:=0;
  if (button and MZW_LBUTTON)<>0 then
  begin
    historyout('Вторая точка:');
    GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1 := mc;
    GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2 := mc;
    GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame13d := wc;
    GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame23d := wc;
  end
end;
function FrameEdit_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var //i: GDBInteger;
  ti: GDBInteger;
  x,y,w,h:gdbdouble;
  pv:PGDBObjEntity;
  ir:itrec;
  r:TInRect;
begin
  result:=mclick;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2 := mc;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame23d := wc;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
      GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := false;

      //mclick:=-1;
      if GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x > GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x then
      begin
        ti := GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x;
        GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x := GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x;
        GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x := ti;
        GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameInverse:=true;
      end
         else GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameInverse:=false;
      if GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y < GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y then
      begin
        ti := GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y;
        GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y := GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y;
        GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y := ti;
      end;
      GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y := GDB.GetCurrentDWG.OGLwindow1.param.height - GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y;
      GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y := GDB.GetCurrentDWG.OGLwindow1.param.height - GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y;
      //ugdbdescriptor.poglwnd^.seldesc.Selectedobjcount:=0;

      x:=(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x+GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x)/2;
      y:=(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y+GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y)/2;
      w:=GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x-GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x;
      h:=GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y-GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y;

      if (w=0) or (h=0)  then
                             begin
                                  commandmanager.executecommandend;
                                  exit;
                             end;

      GDB.GetCurrentDWG.OGLwindow1.param.seldesc.BigMouseFrustum:=CalcDisplaySubFrustum(x,y,w,h,gdb.getcurrentdwg.pcamera.modelMatrix,gdb.getcurrentdwg.pcamera.projMatrix);

      pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pv<>nil then
      repeat
            if pv^.Visible=gdb.GetCurrentDWG.pcamera.VISCOUNT then
            if pv^.infrustum=gdb.GetCurrentDWG.pcamera.POSCOUNT then
            begin
                 r:=pv^.CalcTrueInFrustum(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.BigMouseFrustum,gdb.GetCurrentDWG.pcamera.VISCOUNT);

                 if GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameInverse
                    then
                        begin
                             if r<>IREmpty then
                                               begin
                                               pv^.RenderFeedbackIFNeed;
                                               if (button and MZW_SHIFT)=0 then
                                                                               pv^.select
                                                                           else
                                                                               pv^.deselect;
                                               GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject:=pv;
                                               end;
                        end
                    else
                        begin
                             if r=IRFully then
                                              begin
                                               pv^.RenderFeedbackIFNeed;
                                               if (button and MZW_SHIFT)=0 then
                                                                               pv^.select
                                                                           else
                                                                               pv^.deselect;
                                               GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject:=pv;
                                              end;
                        end
            end;

            pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
      until pv=nil;

      {if gdb.GetCurrentDWG.ObjRoot.ObjArray.count = 0 then exit;
      ti:=0;
      for i := 0 to gdb.GetCurrentDWG.ObjRoot.ObjArray.count - 1 do
      begin
        if PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i]<>nil then
        begin
        if PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].visible then
        begin
          PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].feedbackinrect;
        end;
        if PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i].selected then
                                                                                       begin
                                                                                            inc(ti);
                                                                                            ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject:=PGDBObjEntityArray(gdb.GetCurrentDWG.ObjRoot.ObjArray.parray)^[i];
                                                                                       end;
        end;
        ugdbdescriptor.poglwnd^.seldesc.Selectedobjcount:=ti;
      end;}
      commandmanager.executecommandend;
      //OGLwindow1.SetObjInsp;
      //redrawoglwnd;
      updatevisible;
    end;
  end
  else
  begin
    //if mouseclic = 1 then
    begin
      GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2 := mc;
      if GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x > GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x then
      begin
        GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameInverse:=true;
      end
        else GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameInverse:=false;
    end
  end;
end;

function SelObjChangeLayerToCurrent_com:GDBInteger;
var pv:pGDBObjEntity;
    psv:PSelectedObjDesc;
    ir:itrec;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0) then exit;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.vp.Layer:=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
                             pv^.Format;
                        end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  psv:=gdb.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psv<>nil then
  begin
       repeat
             if psv.objaddr^.Selected then
                                          begin
                                               psv.objaddr^.vp.Layer:=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
                                               psv.objaddr^.Format;
                                          end;
       psv:=gdb.GetCurrentDWG.SelObjArray.iterate(ir);
       until psv=nil;
  end;
  redrawoglwnd;
  result:=cmd_ok;
end;
function SelObjChangeLWToCurrent_com:GDBInteger;
var pv:pGDBObjEntity;
    ir:itrec;
begin
  if (gdb.GetCurrentROOT.ObjArray.count = 0)or(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount=0) then exit;
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then pv^.vp.LineWeight:=sysvar.dwg.DWG_CLinew^ ;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
  redrawoglwnd;
  result:=cmd_ok;
end;
function Options_com(Operands:pansichar):GDBInteger;
begin
  SetGDBObjInsp(SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar);
  historyout('Все настройки доступны в инспекторе объектов');
  //Optionswindow.Show;
  result:=cmd_ok;
end;
function About_com(Operands:pansichar):GDBInteger;
begin
  if not assigned(Aboutwindow) then
                                  Aboutwindow:=TAboutWnd.mycreate(Application,@Aboutwindow);
  MainFormN.DOShowModal(Aboutwindow);
end;
function Help_com(Operands:pansichar):GDBInteger;
begin
  if not assigned(Helpwindow) then
                                  Helpwindow:=THelpWnd.mycreate(Application,@Helpwindow);
  MainFormN.DOShowModal(Helpwindow);
end;
function ProjectTree_com(Operands:pansichar):GDBInteger;
begin
  if not assigned(ProjectTreeWindow) then
                                  ProjectTreeWindow:=TProjectTreeWnd.mycreate(Application,@ProjectTreeWindow);
  ProjectTreeWindow.Show;
end;

function SaveOptions_com(Operands:pansichar):GDBInteger;
var
   mem:GDBOpenArrayOfByte;
//   ev:TEditWnd;
//   a:integer;
//   pobj:PGDBObjEntity;
//   op:gdbstring;
begin
           mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
           SysVarUnit^.SavePasToMem(mem);
           mem.SaveToFile(sysparam.programpath+'rtl/sysvar.pas');
           mem.done;
end;
procedure createInfoFormVar;
begin
  if not assigned(InfoFormVar) then
  begin
  InfoFormVar:=TInfoForm.create(application.MainForm);
  InfoFormVar.DialogPanel.HelpButton.Hide;
  InfoFormVar.DialogPanel.CancelButton.Hide;
  InfoFormVar.caption:=('ОСТОРОЖНО! Проверки синтаксиса пока нет. При нажатии "ОК" объект обновится. При ошибке - ВЫЛЕТ!');
  end;
end;

function ObjVarMan_com(Operands:pansichar):GDBInteger;
var
   mem:GDBOpenArrayOfByte;
   pobj:PGDBObjEntity;
   op:gdbstring;
   size,modalresult:integer;
   us:unicodestring;
   u8s:UTF8String;
   astring:ansistring;
begin
     pobj:=nil;
     if GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount=1 then
                                                pobj:=PGDBObjEntity(GDB.GetCurrentDWG.GetLastSelected)
else if length(Operands)>3 then
                               begin
                                    if pos('BD:',operands)=1 then
                                                                 begin
                                                                      op:=copy(operands,4,length(operands)-3);
                                                                      pobj:=gdb.GetCurrentDWG.BlockDefArray.getblockdef(op)
                                                                 end;
                               end;
  if pobj<>nil
  then
      begin
           mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
           pobj^.OU.SaveToMem(mem);
           mem.SaveToFile(sysparam.programpath+'autosave\lastvariableset.pas');

           setlength(astring,mem.Count);
           StrLCopy(@astring[1],mem.PArray,mem.Count);
           u8s:=(astring);

           createInfoFormVar;

           InfoFormVar.memo.text:=u8s;
           modalresult:=MainFormN.DOShowModal(InfoFormVar);
           if modalresult=MrOk then
                               begin
                                     u8s:=InfoFormVar.memo.text;
                                     astring:={utf8tosys}(u8s);
                                     mem.Clear;
                                     mem.AddData(@astring[1],length(astring));

                                     pobj^.OU.free;
                                     units.parseunit(mem,PTSimpleUnit(@pobj^.OU));
                                     GDBobjinsp.rebuild;
                               end;


           //InfoFormVar.Free;
           mem.done;
      end
  else
      historyout('Выбери или укажи в параметрах объект!');
end;
function MultiObjVarMan_com(Operands:pansichar):GDBInteger;
var
   mem:GDBOpenArrayOfByte;
   pobj:PGDBObjEntity;
   op:gdbstring;
   size,modalresult:integer;
   us:unicodestring;
   u8s:UTF8String;
   astring:ansistring;
   counter:integer;
   ir:itrec;
begin
      begin
           mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);

           createInfoFormVar;
           counter:=0;

           InfoFormVar.memo.text:='';
           modalresult:=MainFormN.DOShowModal(InfoFormVar);
           if modalresult=MrOk then
                               begin
                                     u8s:=InfoFormVar.memo.text;
                                     astring:={utf8tosys}(u8s);
                                     mem.Clear;
                                     mem.AddData(@astring[1],length(astring));

                                     pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
                                     if pobj<>nil then
                                     repeat
                                           if pobj^.Selected then
                                           begin
                                                pobj^.OU.free;
                                                units.parseunit(mem,PTSimpleUnit(@pobj^.OU));
                                                mem.Seek(0);
                                                inc(counter);
                                           end;
                                           pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
                                     until pobj=nil;
                                     if GDBobjinsp.pcurrobj=@MSEditor then  MSEditor.CreateUnit;
                                     GDBobjinsp.rebuild;
                               end;


           //InfoFormVar.Free;
           mem.done;
           historyoutstr('Обработано '+inttostr(counter)+' примитивов');
      end
end;

function Regen_com(Operands:pansichar):GDBInteger;
var //i: GDBInteger;
    pv:pGDBObjEntity;
        ir:itrec;
begin
  MainFormN.StartLongProcess(gdb.GetCurrentROOT.ObjArray.count);
  pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    pv^.Format;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  MainFormN.ProcessLongProcess(ir.itc);
  until pv=nil;
  gdb.GetCurrentROOT.getoutbound;
  MainFormN.EndLongProcess;

  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount:=0;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  {objinsp.GDBobjinsp.}ReturnToDefault;
  clearcp;
  //redrawoglwnd;
  result:=cmd_ok;
end;
procedure CopyToClipboard;
var res:longbool;
    uFormat:longword;

//    lpszFormatName:string[200];
//    hData:THANDLE;
    pbuf:pchar;
    hgBuffer:HGLOBAL;

    s,suni:ansistring;
    I:gdbinteger;
      //tv,pobj: pGDBObjEntity;
      //ir:itrec;

    zcformat:TClipboardFormat;

    memsubstr:TMemoryStream;
begin
     if fileexists(utf8tosys(CopyClipFile)) then
                                    SysUtils.deletefile(CopyClipFile);
     s:=sysparam.temppath+'Z$C'+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)
                              +inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)
                              +'.dxf';
     CopyClipFile:=s;
     savedxf2000(s, {GDB.GetCurrentDWG}ClipboardDWG);
     setlength(suni,length(s)*2+2);
     fillchar(suni[1],length(suni),0);
     s:=s+#0;
     for I := 1 to length(s) do
                               suni[i*2-1]:=s[i];
{    res:=OpenClipboard(mainformn.handle);
    if res then
    begin
         EmptyClipboard();

         uFormat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
         hgBuffer:= GlobalAlloc(GMEM_DDESHARE, length(s));//выделим память
         pbuf:=GlobalLock(hgBuffer);
         //запишем данные в память
         Move(s[1],pbuf^,length(s));
         GlobalUnlock(hgBuffer);
         SetClipboardData(uformat, hgBuffer); //помещаем данные в буфер обмена

         uFormat:=RegisterClipboardFormat('AutoCAD.r16');
         hgBuffer:= GlobalAlloc(GMEM_DDESHARE, length(s));
         pbuf:=GlobalLock(hgBuffer);
         Move(s[1],pbuf^,length(s));
         GlobalUnlock(hgBuffer);
         SetClipboardData(uformat, hgBuffer);

         uFormat:=RegisterClipboardFormat('AutoCAD.r18');
         hgBuffer:= GlobalAlloc(GMEM_DDESHARE, length(suni));
         pbuf:=GlobalLock(hgBuffer);
         Move(suni[1],pbuf^,length(suni));
         GlobalUnlock(hgBuffer);
         SetClipboardData(uformat, hgBuffer);


         CloseClipboard;
    end;
}
    //memsubstr:=TMemoryStream.create;
    //memsubstr.WriteAnsiString(s);
    //memsubstr.Write(s[1],length(s));

    Clipboard.Open;
    Clipboard.Clear;
    zcformat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
    clipboard.AddFormat(zcformat,s[1],length(s));

    zcformat:=RegisterClipboardFormat('AutoCAD.r16');
    clipboard.AddFormat(zcformat,s[1],length(s));

    zcformat:=RegisterClipboardFormat('AutoCAD.r18');
    clipboard.AddFormat(zcformat,suni[1],length(suni));
    Clipboard.Close;

    //memsubstr.free;
end;
function CopyClip_com(Operands:pansichar):GDBInteger;
var //res:longbool;
    //uFormat:longword;

//    lpszFormatName:string[200];
//    hData:THANDLE;
    //pbuf:pchar;
    //hgBuffer:HGLOBAL;

//    s,suni:gdbstring;
//    I:gdbinteger;
      {tv,}pobj: pGDBObjEntity;
      ir:itrec;
begin
   ClipboardDWG.pObjRoot.ObjArray.cleareraseobj;
   pobj:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj.selected then
              begin
                gdb.CopyEnt(gdb.GetCurrentDWG,ClipboardDWG,pobj).Format;
              end;
          end;
          pobj:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
   until pobj=nil;




   copytoclipboard;

    result:=cmd_ok;
end;
function DebClip_com(Operands:pansichar):GDBInteger;
{type
    twordarray=array [1..100] of word;}
var
    //res:longbool;
    //uFormat:longword;

    //lpszFormatName:string[200];
    //hData:THANDLE;
    pbuf:pansichar;
    PWA:Pwordarray;

    s,suni:gdbstring;
    I,memsize:gdbinteger;

       //mem:GDBOpenArrayOfByte;
   //ev:TEditWnd;
   a,modalresult:integer;
   cf:TClipboardFormat;
   ts:string;

   memsubstr:TMemoryStream;
   InfoForm:TInfoForm;
begin
     InfoForm:=TInfoForm.create(application.MainForm);
     InfoForm.DialogPanel.HelpButton.Hide;
     InfoForm.DialogPanel.CancelButton.Hide;
     InfoForm.DialogPanel.CloseButton.Hide;
     InfoForm.caption:=('а в клипбоарде валяется...');

     memsubstr:=TMemoryStream.Create;
     ts:=Clipboard.AsText;
     i:=Clipboard.FormatCount;
     for i:=0 to Clipboard.FormatCount-1 do
     begin
          cf:=Clipboard.Formats[i];
          ts:=ClipboardFormatToMimeType(cf);
          if ts='' then
                       ts:=inttostr(cf);
          InfoForm.Memo.lines.Add(ts);

          Clipboard.GetFormat(cf,memsubstr);

          //memsize:=memsubstr.GetSize;
          memsize:=memsubstr.Seek(0,soFromEnd);
          pbuf:=memsubstr.Memory;

          InfoForm.Memo.lines.Add('  ANSI: '+pbuf);

          //InfoForm.Memo.Lines.LoadFromStream();


          memsubstr.Clear;
     end;
     memsubstr.Free;

     modalresult:=MainFormN.DOShowModal(InfoForm);
     InfoForm.Free;

     result:=cmd_ok;
end;
function MemSummary_com(Operands:pansichar):GDBInteger;
var
    memcount:GDBNumerator;
    pmemcounter:PGDBNumItem;
    ir:itrec;
    s:gdbstring;
    I:gdbinteger;

    //mem:GDBOpenArrayOfByte;
    //ev:TEditWnd;

    memsubstr:TMemoryStream;
    InfoForm:TInfoForm;
begin

     InfoForm:=TInfoForm.create(application.MainForm);
     InfoForm.DialogPanel.HelpButton.Hide;
     InfoForm.DialogPanel.CancelButton.Hide;
     InfoForm.DialogPanel.CloseButton.Hide;
     InfoForm.caption:=('Память мы расходуем...');

     memsubstr:=TMemoryStream.Create;
     memcount.init(100);
     for i := 0 to memdesktotal do
     begin
          if not(memdeskarr[i].free) then
          begin
               pmemcounter:=memcount.addnumerator(memdeskarr[i].getmemguid);
               inc(pmemcounter^.Nymber,memdeskarr[i].size);
           end;
     end;
     memcount.sort;

     pmemcounter:=memcount.beginiterate(ir);
     if pmemcounter<>nil then
     repeat

           s:=pmemcounter^.Name+' '+inttostr(pmemcounter^.Nymber);
           InfoForm.Memo.lines.Add(s);
           pmemcounter:=memcount.iterate(ir);
     until pmemcounter=nil;


     MainFormN.DOShowModal(InfoForm);
     InfoForm.Free;
     memcount.FreeAndDone;
    result:=cmd_ok;
end;
procedure PrintTreeNode(pnode:PTEntTreeNode;var depth:integer);
var
   s:gdbstring;
begin
     s:='';
     if pnode^.nul.Count<>0 then
     begin
          s:='В ноде примитивов: '+inttostr(pnode^.nul.Count);
     end;
     s:=s+'(далее в +): '+inttostr(pnode.pluscount);
     s:=s+' (далее в -): '+inttostr(pnode.minuscount);

     shared.HistoryOutStr(dupestring('  ',pnode.nodedepth)+s);

     if pnode.nodedepth>depth then
                                  depth:=pnode.nodedepth;

     if assigned(pnode.pplusnode) then
                       PrintTreeNode(pnode.pplusnode,depth);
     if assigned(pnode.pminusnode) then
                       PrintTreeNode(pnode.pminusnode,depth);
end;

function RebuildTree_com:GDBInteger;
var //i: GDBInteger;
    pv:pGDBObjEntity;
    ir:itrec;
    depth:integer;
begin
  MainFormN.StartLongProcess(gdb.GetCurrentROOT.ObjArray.count);
  gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree:=createtree(gdb.GetCurrentDWG^.pObjRoot.ObjArray,gdb.GetCurrentDWG^.pObjRoot.vp.BoundingBox,@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,0,nil,TND_Root)^;
  MainFormN.EndLongProcess;

  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount:=0;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.OnMouseObject:=nil;
  GDB.GetCurrentDWG.OGLwindow1.param.seldesc.LastSelectedObject:=nil;
  {objinsp.GDBobjinsp.}ReturnToDefault;
  clearcp;
  redrawoglwnd;
  depth:=0;
  PrintTreeNode(@gdb.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree,depth);
  shared.HistoryOutStr('Всего примитивов: '+inttostr(GDB.GetCurrentROOT.ObjArray.count));
  shared.HistoryOutStr('Глубина дерева  : '+inttostr(depth));

  result:=cmd_ok;
end;
procedure polytest_com_CommandStart(Operands:pansichar);
begin
  if GDB.GetCurrentDWG.GetLastSelected<>nil then
  if GDB.GetCurrentDWG.GetLastSelected.vp.ID=GDBlwPolylineID then
  begin
  GDB.GetCurrentDWG.OGLwindow1.SetMouseMode((MGet3DPointWOOP) or (MMoveCamera) or (MRotateCamera) or (MGet3DPoint));
  //GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := true;
  historyout('тыкаем и проверяем внутри\снаружи 2D полилинии:');
  exit;
  end;
  //else
  begin
       historyout('перед запуском нужно выбрать 2D полилинию');
       commandmanager.executecommandend;
  end;
end;
function polytest_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
//var tb:PGDBObjSubordinated;
begin
  result:=mclick+1;
  if (button and MZW_LBUTTON)<>0 then
  begin
       if pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).isPointInside(wc) then
       historyout('Внутри!')
       else
       historyout('Снаружи!')
  end;
end;
function isrect(const p1,p2,p3,p4:GDBVertex2D):boolean;
var
   p:gdbdouble;
begin
     p:=SqrVertexlength(p1,p3)-sqrVertexlength(p2,p4);
     p:=SqrVertexlength(p1,p2)-sqrVertexlength(p3,p4);
     if (abs(SqrVertexlength(p1,p3)-sqrVertexlength(p2,p4))<sqreps)and(abs(SqrVertexlength(p1,p2)-sqrVertexlength(p3,p4))<sqreps)
     then
         result:=true
     else
         result:=false;
end;
function IsSubContur(const pva:GDBPolyline2DArray;const p1,p2,p3,p4:integer):boolean;
var
   c,i:integer;
begin
     result:=false;
     for i:=0 to pva.count-1 do
     begin
          if (i<>p1)and
             (i<>p2)and
             (i<>p3)and
             (i<>p4)
                       then
                       begin
                            c:=0;
                            if _intercept2d(PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(p2))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p2))^,PGDBVertex2D(pva.getelement(p3))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p3))^,PGDBVertex2D(pva.getelement(p4))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p4))^,PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if ((c mod 2)=1) then
                                                 exit;
                       end;
     end;
     result:=true;
end;
function IsSubContur2(const pva:GDBPolyline2DArray;const p1,p2,p3:integer;const p:GDBVertex2D):boolean;
var
   c,i:integer;
begin
     result:=false;
     for i:=0 to pva.count-1 do
     begin
          if (i<>p1)and
             (i<>p2)and
             (i<>p3)
                       then
                       begin
                            c:=0;
                            if _intercept2d(PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(p2))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p2))^,PGDBVertex2D(pva.getelement(p3))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(PGDBVertex2D(pva.getelement(p3))^,p,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if _intercept2d(p,PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(i))^, 1, 0)
                            then
                                inc(c);
                            if ((c mod 2)=1) then
                                                 exit;
                       end;
     end;
     result:=true;
end;
procedure nextP(var p,c:integer);
begin
     inc(p);
     if p=c then
                        p:=0;
end;
function CutRect4(var pva,pvr:GDBPolyline2DArray):boolean;
var
   p1,p2,p3,p4,i:integer;
begin
     result:=false;
     p1:=0;p2:=1;p3:=2;p4:=3;
     for i:=1 to pva.count do
     begin
          if isrect(PGDBVertex2D(pva.getelement(p1))^,
                    PGDBVertex2D(pva.getelement(p2))^,
                    PGDBVertex2D(pva.getelement(p3))^,
                    PGDBVertex2D(pva.getelement(p4))^)then
          if pva.ispointinside(Vertexmorph(PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(p3))^,0.5))then
          if IsSubContur(pva,p1,p2,p3,p4)then
              begin
                   pvr.add(pva.getelement(p1));
                   pvr.add(pva.getelement(p2));
                   pvr.add(pva.getelement(p3));
                   pvr.add(pva.getelement(p4));

                   pva.deleteelement(p3);
                   pva.deleteelement(p2);
                   pva.optimize;

                   result:=true;
                   exit;
              end;
          nextP(p1,pva.count);nextP(p2,pva.count);nextP(p3,pva.count);nextP(p4,pva.count);
     end;
end;
function CutRect3(var pva,pvr:GDBPolyline2DArray):boolean;
var
   p1,p2,p3,p4,i:integer;
   p:GDBVertex2d;
begin
     result:=false;
     p1:=0;p2:=1;p3:=2;p4:=3;
     for i:=1 to pva.count do
     begin
          p.x:=PGDBVertex2D(pva.getelement(p1))^.x+(PGDBVertex2D(pva.getelement(p3))^.x-PGDBVertex2D(pva.getelement(p2))^.x);
          p.y:=PGDBVertex2D(pva.getelement(p1))^.y+(PGDBVertex2D(pva.getelement(p3))^.y-PGDBVertex2D(pva.getelement(p2))^.y);
          if distance2piece_2dmy(p,PGDBVertex2D(pva.getelement(p3))^,PGDBVertex2D(pva.getelement(p4))^)<eps then
          if pva.ispointinside(Vertexmorph(PGDBVertex2D(pva.getelement(p1))^,PGDBVertex2D(pva.getelement(p3))^,0.5))then
          if IsSubContur2(pva,p1,p2,p3,p)then
              begin
                   pvr.add(pva.getelement(p1));
                   pvr.add(pva.getelement(p2));
                   pvr.add(pva.getelement(p3));
                   pvr.add(@p);

                   PGDBVertex2D(pva.getelement(p3))^.x:=p.x;
                   PGDBVertex2D(pva.getelement(p3))^.y:=p.y;
                   pva.deleteelement(p2);
                   pva.optimize;

                   result:=true;
                   exit;
              end;
          nextP(p1,pva.count);nextP(p2,pva.count);nextP(p3,pva.count);nextP(p4,pva.count);
     end;
end;

procedure polydiv(var pva,pvr:GDBPolyline2DArray;m:DMatrix4D);
var
   nstep,i:integer;
   p3dpl:PGDBObjPolyline;
   wc:gdbvertex;
begin
     nstep:=0;
     repeat
           case nstep of
                       0:begin
                              if CutRect4(pva,pvr) then
                                                       nstep:=-1;

                         end;
                       1:begin
                              if CutRect3(pva,pvr) then
                                                       nstep:=-1;
                         end;
                       2:begin

                              if CutRect3(pva,pvr) then
                                                       nstep:=-1;
                         end
           end;
           inc(nstep)
     until nstep=3;
     nstep:=nstep;
     i:=0;
     p3dpl := GDBPointer(gdb.GetCurrentROOT.ObjArray.CreateInitObj(GDBPolylineID,gdb.GetCurrentROOT));
     p3dpl.Closed:=true;
     p3dpl^.vp.Layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
     p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;

     while i<pvr.Count do
     begin
          wc.x:=PGDBVertex2D(pvr.getelement(i))^.x;
          wc.y:=PGDBVertex2D(pvr.getelement(i))^.y;
          wc.z:=0;
          wc:=geometry.VectorTransform3D(wc,m);
          p3dpl^.AddVertex(wc);

          if ((i+1) mod 4)=0 then
          begin
               p3dpl^.Format;
               p3dpl^.RenderFeedback;
               gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
               if i<>pvr.Count-1 then
               p3dpl := GDBPointer(gdb.GetCurrentROOT.ObjArray.CreateInitObj(GDBPolylineID,gdb.GetCurrentROOT));
               p3dpl.Closed:=true;
          end;
          inc(i);
     end;

     p3dpl^.Format;
     p3dpl^.RenderFeedback;
     gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(p3dpl);
     //redrawoglwnd;
end;

procedure polydiv_com(Operands:pansichar);
var pva,pvr:GDBPolyline2DArray;
begin
  if GDB.GetCurrentDWG.GetLastSelected<>nil then
  if GDB.GetCurrentDWG.GetLastSelected.vp.ID=GDBlwPolylineID then
  begin
       pva.init({$IFDEF DEBUGBUILD}'{9372BADE-74EE-4101-8FA4-FC696054CD4F}',{$ENDIF}pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.count,true);
       pvr.init({$IFDEF DEBUGBUILD}'{9372BADE-74EE-4101-8FA4-FC696054CD4F}',{$ENDIF}pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.count,true);

       pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).Vertex2D_in_OCS_Array.copyto(@pva);

       polydiv(pva,pvr,pgdbobjlwpolyline(GDB.GetCurrentDWG.GetLastSelected).GetMatrix^);

       pva.done;
       pvr.done;
       exit;
  end;
  //else
  begin
       historyout('перед запуском нужно выбрать 2D полилинию');
       commandmanager.executecommandend;
  end;
end;

function layer_cmd:GDBInteger;
begin
  LayerWindow:=TLayerWindow.Create(nil);
  SetHeightControl(LayerWindow,22);
  MainFormN.DOShowModal(LayerWindow);
  Freeandnil(LayerWindow);
  result:=cmd_ok;
end;

procedure finalize;
begin
     //Optionswindow.done;
     //Aboutwindow.{done}free;
     //Helpwindow.{done}free;
     MSEditor.done;

     //DWGPageCxMenu^.done;
     //gdbfreemem(pointer(DWGPageCxMenu));
end;
procedure SaveLayoutToFile(Filename: string);
var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:=Filename;
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      DockMaster.SaveLayoutToConfig(Config);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;
function SaveLayout_com:GDBInteger;
var
  XMLConfig: TXMLConfigStorage;
  filename:string;
begin
  try
    // create a new xml config file
    filename:=utf8tosys(sysparam.programpath+'components/defaultlayout.xml');
    SaveLayoutToFile(filename);
    exit;
    XMLConfig:=TXMLConfigStorage.Create(filename,false);
    try
      // save the current layout of all forms
      DockMaster.SaveLayoutToConfig(XMLConfig);
      XMLConfig.WriteToDisk;
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      MessageDlg('Error',
        'Error saving layout to file '+Filename+':'#13+E.Message,mtError,
        [mbCancel],0);
    end;
  end;
  result:=cmd_ok;
end;
function SnapProp_com(Operands:pansichar):GDBInteger;
begin
      StoreAndSetGDBObjInsp(dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor);
      result:=cmd_ok;
end;
function Show_com(Operands:pansichar):GDBInteger;
var
   obj:gdbstring;
   objt:PUserTypeDescriptor;
begin
  DockMaster.ShowControl(Operands,true);
{     if Operands='ObjInsp' then
                            begin
                                 DockMaster.ShowControl('ObjectInspector',true);
                            end
else if Operands='CommandLine' then
                            begin
                                 DockMaster.ShowControl('CommandLine',true);
                            end
else if Operands='PageControl' then
                            begin
                                 DockMaster.ShowControl('PageControl',true);
                            end
else if Operands='ToolBarR' then
                            begin
                                 DockMaster.ShowControl('ToolBarR',true);
                            end;}
end;
function UpdatePO_com(Operands:pansichar):GDBInteger;
var
   cleaned:integer;
   s:string;
begin
     if sysinfo.sysparam.updatepo then
     begin
          begin
               cleaned:=po.exportcompileritems(actualypo);
               s:='Cleaned items: '+inttostr(cleaned)
           +#13#10'Added items: '+inttostr(_UpdatePO)
           +#13#10'File zcad.po must be rewriten. Confirm?';
               if MainFormN.messagebox(@s[1],'UpdatePO',MB_YESNO)=IDNO then
                                                                         exit;
               po.SaveToFile(PODirectory + 'zcad.po.backup');
               actualypo.SaveToFile(PODirectory + 'zcad.po');
               sysinfo.sysparam.updatepo:=false
          end;
     end
        else showerror('Command line swith "UpdatePO" must be set. (or not the first time running this command)');
end;
function quit_com(Operands:pansichar):GDBInteger;
begin
     //Application.QueueAsyncCall(MainFormN.asynccloseapp, 0);
     CloseApp;
end;
function tw_com(Operands:pansichar):GDBInteger;
begin
     //Application.QueueAsyncCall(MainFormN.asynccloseapp, 0);
  if CWMemo.IsVisible then
                                 CWindow.Hide
                             else
                                 CWindow.Show;

end;
function CommandList_com(Operands:pansichar):GDBInteger;
var
   p:PCommandObjectDef;
   ps:pgdbstring;
   ir:itrec;
   clist:GDBGDBStringArray;
begin
   clist.init(200);
   p:=commandmanager.beginiterate(ir);
   if p<>nil then
   repeat
         //shared.HistoryOutStr(p^.CommandName);
         clist.add(@p^.CommandName);
         p:=commandmanager.iterate(ir);
   until p=nil;
   clist.sort;
   shared.HistoryOutStr(clist.GetTextWithEOL);
   clist.done;
   result:=cmd_ok;
end;
function StoreFrustum_com(Operands:pansichar):GDBInteger;
var
   p:PCommandObjectDef;
   ps:pgdbstring;
   ir:itrec;
   clist:GDBGDBStringArray;
begin
   gdb.GetCurrentDWG.OGLwindow1.param.debugfrustum:=gdb.GetCurrentDWG.pcamera.frustum;
   gdb.GetCurrentDWG.OGLwindow1.param.ShowDebugFrustum:=true;
end;
function ScriptOnUses(Sender: TPSPascalCompiler; const Name: string): Boolean;
{ the OnUses callback function is called for each "uses" in the script.
  It's always called with the parameter 'SYSTEM' at the top of the script.
  For example: uses ii1, ii2;
  This will call this function 3 times. First with 'SYSTEM' then 'II1' and then 'II2'.
}
begin
  if Name = 'SYSTEM' then
  begin
    SIRegister_Std(Sender);
    { This will register the declarations of these classes:
      TObject, TPersisent. This can be found
      in the uPSC_std.pas unit. }
    SIRegister_Controls(Sender);
    { This will register the declarations of these classes:
      TControl, TWinControl, TFont, TStrings, TStringList, TGraphicControl. This can be found
      in the uPSC_controls.pas unit. }

    SIRegister_Forms(Sender);
    { This will register: TScrollingWinControl, TCustomForm, TForm and TApplication. uPSC_forms.pas unit. }

    SIRegister_stdctrls(Sender);
     { This will register: TButtonContol, TButton, TCustomCheckbox, TCheckBox, TCustomEdit, TEdit, TCustomMemo, TMemo,
      TCustomLabel and TLabel. Can be found in the uPSC_stdctrls.pas unit. }

    AddImportedClassVariable(Sender, 'Application', 'TApplication');
    // Registers the application variable to the script engine.
    sender.AddDelphiFunction('procedure test;');
    Result := True;
  end else
    Result := False;
end;

procedure test;
var
  Script:GDBString;
begin
                   Script:='GDBString;';
                   shared.ShowError(Script);
end;
function TestScript_com(Operands:pansichar):GDBInteger;
var
  Compiler: TPSPascalCompiler;
  { TPSPascalCompiler is the compiler part of the scriptengine. This will
    translate a Pascal script into a compiled form the executer understands. }
  Exec: TPSExec;
   { TPSExec is the executer part of the scriptengine. It uses the output of
    the compiler to run a script. }
  {$IFDEF UNICODE}Data: AnsiString;{$ELSE}Data: string;{$ENDIF}
  Script,Messages:GDBString;
  i:integer;
  CI: TPSRuntimeClassImporter;
begin
(*
var f: TForm; i: Longint; begin f := TForm.CreateNew(f{, 0}); f.Show; while f.Visible do Application.ProcessMessages; F.free;  end.
*)
     Script:='type tt=record a:Longint; end; var b:tt; f: TForm; i: Longint; begin b.a:=1; test; f := TForm.CreateNew(f{, 0}); f.Show; while f.Visible do Application.ProcessMessages; F.free;  end.';
     Compiler := TPSPascalCompiler.Create; // create an instance of the compiler.
     Compiler.OnUses := ScriptOnUses; // assign the OnUses event.
     if not Compiler.Compile(Script) then  // Compile the Pascal script into bytecode.
     begin
       //Compiler.
       for i := 0 to Compiler.MsgCount -1 do
         Messages := Messages +
                     Compiler.Msg[i].MessageToString +
                     #13#10;
       shared.ShowError(Messages);
       Compiler.Free;
        // You could raise an exception here.
       Exit;
     end;

     Compiler.GetOutput(Data); // Save the output of the compiler in the string Data.
     Compiler.Free; // After compiling the script, there is no need for the compiler anymore.

     CI := TPSRuntimeClassImporter.Create;
     { Create an instance of the runtime class importer.}

     RIRegister_Std(CI);  // uPSR_std.pas unit.
     RIRegister_Controls(CI); // uPSR_controls.pas unti.
     RIRegister_stdctrls(CI);  // uPSR_stdctrls.pas unit.
     RIRegister_Forms(CI);  // uPSR_forms.pas unit.

     Exec := TPSExec.Create;  // Create an instance of the executer.
     RegisterClassLibraryRuntime(Exec, CI);
     Exec.RegisterDelphiFunction(@test, 'test', cdRegister);
     //----Exec.RegisterDelphiFunction(@MyOwnFunction, 'MYOWNFUNCTION', cdRegister);
     { This will register the function to the executer. The first parameter is a
       pointer to the function. The second parameter is the name of the function (in uppercase).
   	And the last parameter is the calling convention (usually Register). }

     if not  Exec.LoadData(Data) then // Load the data from the Data string.
     begin
         Exec.LastEx;

       { For some reason the script could not be loaded. This is usually the case when a
         library that has been used at compile time isn't registered at runtime. }
       Exec.Free;
        // You could raise an exception here.
       Exit;
     end;

     Exec.RunScript; // Run the script.
     Exec.Free; // Free the executer.
end;
procedure startup;
//var
   //pmenuitem:pzmenuitem;
begin
  Randomize;
  MSEditor.init;
  CopyClipFile:='Empty';
  CreateCommandFastObjectPlugin(@SetObjInsp_com,'SetObjInsp',CADWG,0);
  CreateCommandFastObjectPlugin(@CommandList_com,'CommandList',0,0);
  ms2objinsp:=CreateCommandFastObjectPlugin(@MultiSelect2ObjIbsp_com,'MultiSelect2ObjIbsp',CADWG,0);
  ms2objinsp.CEndActionAttr:=0;
  CreateCommandFastObjectPlugin(@SelectOnMouseObjects_com,'SelectOnMouseObjects',CADWG,0);
  CreateCommandFastObjectPlugin(@SelectObjectByAddres_com,'SelectObjectByAddres',CADWG,0);
  CreateCommandFastObjectPlugin(@quit_com,'Quit',0,0);
  CreateCommandFastObjectPlugin(@newdwg_com,'NewDWG',0,0);
  CreateCommandFastObjectPlugin(@NextDrawint_com,'NextDrawing',0,0);
  CreateCommandFastObjectPlugin(@PrevDrawint_com,'PrevDrawing',0,0);
  CreateCommandFastObjectPlugin(@CloseDWGOnMouse_com,'CloseDWGOnMouse',CADWG,0);
  CreateCommandFastObjectPlugin(@CloseDWG_com,'CloseDWG',CADWG,0);
  selall:=CreateCommandFastObjectPlugin(@SelectAll_com,'SelectAll',CADWG,0);
  selall^.overlay:=true;
  selall.CEndActionAttr:=0;
  deselall:=CreateCommandFastObjectPlugin(@DeSelectAll_com,'DeSelectAll',CADWG,0);
  deselall.CEndActionAttr:=CEDeSelect;
  deselall^.overlay:=true;
  //deselall.CEndActionAttr:=0;
  CreateCommandFastObjectPlugin(@QSave_com,'QSave',CADWG,0);
  CreateCommandFastObjectPlugin(@Merge_com,'Merge',CADWG,0);
  CreateCommandFastObjectPlugin(@Load_com,'Load',0,0);
  CreateCommandFastObjectPlugin(@MergeBlocks_com,'MergeBlocks',0,0);
  CreateCommandFastObjectPlugin(@SaveAs_com,'SaveAs',CADWG,0);
  CreateCommandFastObjectPlugin(@Cam_reset_com,'Cam_Reset',CADWG,0);
  CreateCommandFastObjectPlugin(@Options_com,'Options',0,0);
  CreateCommandFastObjectPlugin(@About_com,'About',0,0);
  CreateCommandFastObjectPlugin(@Help_com,'Help',0,0);
  CreateCommandFastObjectPlugin(@ProjectTree_com,'ProjectTree',CADWG,0);
  CreateCommandFastObjectPlugin(@ObjVarMan_com,'ObjVarMan',CADWG,0);
  CreateCommandFastObjectPlugin(@MultiObjVarMan_com,'MultiObjVarMan',CADWG,0);
  CreateCommandFastObjectPlugin(@SaveOptions_com,'SaveOptions',0,0);
  CreateCommandFastObjectPlugin(@Regen_com,'Regen',CADWG,0);
  CreateCommandFastObjectPlugin(@Copyclip_com,'CopyClip',CADWG,0);
  //CreateCommandFastObjectPlugin(@Pasteclip_com,'PasteClip');
  CreateCommandFastObjectPlugin(@DebClip_com,'DebClip',0,0);
  CreateCommandFastObjectPlugin(@ChangeProjType_com,'ChangeProjType',CADWG,0);
  CreateCommandFastObjectPlugin(@SelObjChangeLayerToCurrent_com,'SelObjChangeLayerToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@SelObjChangeLWToCurrent_com,'SelObjChangeLWToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@MemSummary_com,'MeMSummary',0,0);
  selframecommand:=CreateCommandRTEdObjectPlugin(@FrameEdit_com_CommandStart,@FrameEdit_com_Command_End,nil,nil,@FrameEdit_com_BeforeClick,@FrameEdit_com_AfterClick,nil,nil,'SelectFrame',0,0);
  selframecommand^.overlay:=true;
  selframecommand.CEndActionAttr:=0;
  CreateCommandFastObjectPlugin(@RebuildTree_com,'RebuildTree',CADWG,0);
  CreateCommandFastObjectPlugin(@layer_cmd,'Layer',CADWG,0);
  CreateCommandFastObjectPlugin(@undo_com,'Undo',CADWG,0).overlay:=true;
  CreateCommandFastObjectPlugin(@redo_com,'Redo',CADWG,0).overlay:=true;

  CreateCommandRTEdObjectPlugin(@polytest_com_CommandStart,nil,nil,nil,@polytest_com_BeforeClick,@polytest_com_BeforeClick,nil,nil,'PolyTest',0,0);
  CreateCommandFastObjectPlugin(@SelObjChangeLWToCurrent_com,'SelObjChangeLWToCurrent',CADWG,0);
  CreateCommandFastObjectPlugin(@PolyDiv_com,'PolyDiv',CADWG,0).CEndActionAttr:=CEDeSelect;
  CreateCommandFastObjectPlugin(@SaveLayout_com,'SaveLayout',0,0);
  CreateCommandFastObjectPlugin(@Show_com,'Show',0,0);

  CreateCommandFastObjectPlugin(@UpdatePO_com,'UpdatePO',0,0);

  CreateCommandFastObjectPlugin(@LoadLayout_com,'LoadLayout',0,0);
  CreateCommandFastObjectPlugin(@SnapProp_com,'SnapProperties',CADWG,0).overlay:=true;

  CreateCommandFastObjectPlugin(@TW_com,'TextWindow',0,0).overlay:=true;

  CreateCommandFastObjectPlugin(@StoreFrustum_com,'StoreFrustum',CADWG,0).overlay:=true;
  CreateCommandFastObjectPlugin(@TestScript_com,'TestScript',0,0).overlay:=true;



  //Optionswindow.initxywh('',@mainformn,500,300,400,100,false);
  //Aboutwindow:=TAboutWnd.create(Application);{.initxywh('',@mainform,500,200,200,180,false);}
  //Application.CreateForm(TAboutWnd,Aboutwindow);
  Aboutwindow:=nil;
  Helpwindow:=nil;//THelpWnd.create(Application);{Helpwindow.initxywh('',@mainform,500,290,400,150,false);}
  //Aboutwindow.show;
  //Helpwindow.show;
  //Application.mainform:=

(*  GDBGetMem({$IFDEF DEBUGBUILD}'{7A89C3DC-00FB-49E9-B938-030C79A09A37}',{$ENDIF}GDBPointer(DWGPageCxMenu),sizeof(zpopupmenu));
  DWGPageCxMenu.init('DWGPageMenu');
  GDBGetMem({$IFDEF DEBUGBUILD}'{19CBFAC7-4671-4F40-A34F-3F69CE37DA65}',{$ENDIF}GDBPointer(pmenuitem),sizeof(zmenuitem));
  pmenuitem.init('Создать вкладку');
  pmenuitem.command:='newdwg';
  pmenuitem.addto(DWGPageCxMenu);
  GDBGetMem({$IFDEF DEBUGBUILD}'{19CBFAC7-4671-4F40-A34F-3F69CE37DA65}',{$ENDIF}GDBPointer(pmenuitem),sizeof(zmenuitem));
  pmenuitem.init('Закрыть вкладку');
  pmenuitem.command:='closedwgonmouse';
  pmenuitem.addto(DWGPageCxMenu);
  *)
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('GDBCommandsBase.initialization');{$ENDIF}
  OSModeEditor.initnul;
  OSModeEditor.trace.ZAxis:=false;
  OSModeEditor.trace.Angle:=TTA45;
  startup;
finalization
  finalize;
end.
