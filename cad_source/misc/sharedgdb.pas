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

unit sharedgdb;
{$INCLUDE def.inc}
interface
uses OGLSpecFunc,gdbasetypes;
procedure redrawoglwnd; export;
procedure updatevisible; export;
procedure reloadlayer; export;

implementation
uses strproc,umytreenode,FileUtil,{LCLclasses,} LCLtype, LCLproc,forms,GDBBlockDef,
     mainwindow,
     log,UGDBDescriptor,varmandef,sysinfo,cmdline,{strutils,}SysUtils{,zbasicvisible,ZGUIArrays},oglwindow{,ZTabControlsGeneric};

procedure redrawoglwnd; export;
var
   pdwg:PTDrawing;
begin
  isOpenGLError;
  pdwg:=gdb.GetCurrentDWG;
  if pdwg<>nil then
  begin
       gdb.GetCurrentRoot.FormatAfterEdit;
  pdwg.OGLwindow1.param.firstdraw := TRUE;
  pdwg.OGLwindow1.CalcOptimalMatrix;
  pdwg.pcamera^.totalobj:=0;
  pdwg.pcamera^.infrustum:=0;
  gdb.GetCurrentROOT.CalcVisibleByTree(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,gdb.GetCurrentROOT.ObjArray.ObjTree);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  pdwg.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  pdwg.OGLwindow1.calcgrid;
  pdwg.OGLwindow1.draw;
  end;
  //gdb.GetCurrentDWG.OGLwindow1.repaint;
end;
procedure updatevisible; export;
var
   ir:itrec;
   //pcontrol:PZGUIRec;
   poglwnd:toglwnd;
   name:gdbstring;
   //i:TPageNumber;
   i:Integer;
   pdwg:PTDrawing;
begin
   pdwg:=gdb.GetCurrentDWG;
   if assigned(mainformn)then
   begin
   mainformn.UpdateControls;
  if (pdwg<>nil)and(pdwg<>BlockBaseDWG) then
  begin
                                      begin
                                           reloadlayer;
                                           gdb.GetCurrentDWG.OGLwindow1.setvisualprop;
                                           mainformn.Caption:=(('ZCad v'+sysvar.SYS.SYS_Version^+' - ['+gdb.GetCurrentDWG.FileName+']'));
  if assigned(mainwindow.LayerBox) then
  mainwindow.LayerBox.enabled:=true;
  if assigned(mainwindow.LineWBox) then
  mainwindow.LineWBox.enabled:=true;
  for i:=0 to MainFormN.PageControl.PageCount-1 do
    begin
         tobject(poglwnd):=FindControlByType(MainFormN.PageControl.Pages[i]{.PageControl},TOGLwnd);
           if assigned(poglwnd) then
            if poglwnd.PDWG<>nil then
           begin
                name:=extractfilename(PTDrawing(poglwnd.PDWG)^.FileName);
                if @PTDRAWING(poglwnd.PDWG).mainObjRoot=(PTDRAWING(poglwnd.PDWG).pObjRoot) then
                                                                     MainFormN.PageControl.Pages[i].caption:=(name)
                                                                 else
                                                                     MainFormN.PageControl.Pages[i].caption:='BEdit('+name+':'+PGDBObjBlockdef(PTDRAWING(poglwnd.PDWG).pObjRoot).Name+')';
           end;    end;
    { i:=0;
    pcontrol:=MainForm.PageControl.pages.beginiterate(ir);
     if pcontrol<>nil then
     repeat
           if pcontrol^.pobj<>nil then
           begin
           poglwnd:=nil;
           //переделать//poglwnd:=pointer(pzbasic(pcontrol^.pobj)^.FindKidsByType(typeof(TOGLWnd)));
           if poglwnd<>nil then
            if poglwnd^.PDWG<>nil then
           begin
                name:=extractfilename(PTDrawing(poglwnd^.PDWG)^.FileName);
                if @PTDRAWING(poglwnd^.PDWG).mainObjRoot=(PTDRAWING(poglwnd^.PDWG).pObjRoot) then
                                                                     MainForm.PageControl.setpagetext(name,i)
                                                                 else
                                                                     MainForm.PageControl.setpagetext('BEdit('+name+':'+PGDBObjBlockdef(PTDRAWING(poglwnd^.PDWG).pObjRoot).Name+')',i);
           end;
           end;
           inc(i);
           pcontrol:=MainForm.PageControl.pages.iterate(ir);
     until pcontrol=nil;                  }
                                      end;
  end
  else
      begin
           mainformn.Caption:=('ZCad v'+sysvar.SYS.SYS_Version^);
           if assigned(mainwindow.LayerBox)then
           mainwindow.LayerBox.enabled:=false;
           if assigned(mainwindow.LineWBox)then
           mainwindow.LineWBox.enabled:=false;
      end;
  end;
end;
procedure reloadlayer; export;
begin
     exit;
     if assigned(layerbox) then
     mainformN.ReloadLayer(@gdb.GetCurrentDWG.LayerTable);
end;
begin
{$IFDEF DEBUGINITSECTION}log.LogOut('shared.initialization');{$ENDIF}
end.
