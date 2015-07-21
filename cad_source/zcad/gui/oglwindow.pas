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

unit oglwindow;
{$INCLUDE def.inc}

interface

uses

   uzglopengldrawer,zcadsysvars,UGDBLayerArray,
  {$IFDEF LCLGTK2}
  //x,xlib,{x11,}{xutil,}
  gtk2,gdk2,{gdk2x,}
  {$ENDIF}
  {$IFNDEF DELPHI}LCLType,InterfaceBase,FileUtil,{$ELSE}windows,{$ENDIF}
  {umytreenode,}menus,Classes,Forms,
  ExtCtrls,Controls,
  gdbasetypes,sysutils,
  {$IFNDEF DELPHI}{GLext,gl,glu,}OpenGLContext,{$ELSE}dglOpenGL,UOpenGLControl,{$ENDIF}
  gdbase,{varmandef,varman,UUnitManager,}
  oglwindowdef,
  sysinfo,
  strproc,glstatemanager,memman,
  log,abstractviewarea;

type
  PTOGLWnd = ^TOGLWnd;


  { TOGLWnd }

  TOGLWnd = class({TPanel}TOpenGLControl)
  private
  public
    OGLContext:TOGLContextDesk;
    wa:TAbstractViewArea;

    destructor Destroy; override;

    {LCL}
    protected
    procedure EraseBackground(DC: HDC);{$IFNDEF DELPHI}override;{$ENDIF}
  end;
const maxgrid=100;
var
  gridarray:array [0..maxgrid,0..maxgrid] of GDBvertex2S;
  //InfoForm:TInfoForm=nil;

//function timeSetEvent(uDelay, uReolution: UINT; lpTimeProc: GDBPointer;dwUser: DWord; fuEvent: UINT): GDBInteger; stdcall; external 'winmm';
//function timeKillEvent(uID: UINT): GDBInteger; stdcall; external 'winmm';

{procedure startup;
procedure finalize;}
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
//function getsortedindex(cl:integer):integer;
implementation
uses geometry,
     shared;
procedure TOGLWnd.EraseBackground(DC: HDC);
begin
     dc:=0;
end;
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
                               result:=correcttogrid(point);
                               {result.x:=round((point.x-SysVar.DWG.DWG_Snap.Base.x)/SysVar.DWG.DWG_Snap.Spacing.x)*SysVar.DWG.DWG_Snap.Spacing.x+SysVar.DWG.DWG_Snap.Spacing.x;
                               result.y:=round((point.y-SysVar.DWG.DWG_Snap.Base.y)/SysVar.DWG.DWG_Snap.Spacing.y)*SysVar.DWG.DWG_Snap.Spacing.y+SysVar.DWG.DWG_Snap.Spacing.y;
                               result.z:=point.z;}
                          end
                      else
                          result:=point;
end;
destructor TOGLWnd.Destroy;
var
   i:integer;
begin
     wa.Drawer.delmyscrbuf;
     if wa.param.pglscreen <> nil then
     GDBFreeMem(wa.param.pglscreen);
     MywglDeleteContext(OGLContext);//wglDeleteContext(hrc);
     wa.PolarAxis.done;
     if wa.param.pglscreen<>nil then
     gdbfreemem(wa.param.pglscreen);
     wa.param.ospoint.arraydispaxis.done;
     wa.param.ospoint.arrayworldaxis.done;
     for i := 0 to {wa.param.ontrackarray.total-1}3 do
                                              begin
                                              wa.param.ontrackarray.otrackarray[i].arrayworldaxis.done;
                                              wa.param.ontrackarray.otrackarray[i].arraydispaxis.done;
                                              end;
     {переделать}//inherited done;
     inherited;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('oglwindow.initialization');{$ENDIF}
end.

