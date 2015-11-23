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

unit imagesmanager;
{$INCLUDE def.inc}

interface

uses
  paths,Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  {StdCtrls,} Buttons, {ColorBox,}{ ButtonPanel,}{ Spin,} ExtCtrls, {ComCtrls,}{math,}
  gdbase,{zcadstrconsts,}uzcsysvars,uzcsysinfo;
var
  II_Plus,
  II_Minus,
  II_Ok,
  II_LayerOff,
  II_LayerOn,
  II_LayerUnPrint,
  II_LayerPrint,
  II_LayerUnLock,
  II_LayerLock,
  II_LayerFreze,
  II_LayerUnFreze,
  II_Bug,
  II_Dxf,
  II_Purge,
  II_Refresh
  :integer;
  IconList: TImageList;
procedure LoadIcons;
implementation
function loadicon(iconlist: TImageList;f:string):integer;
var
  bmp:TPortableNetworkGraphic;
begin
  bmp:=TPortableNetworkGraphic.create;
  bmp.LoadFromFile(f);
  bmp.Transparent:=true;
  result:=iconlist.Add(bmp,nil);
  freeandnil(bmp);
end;
procedure LoadIcons;
begin
  iconlist:=timagelist.Create(application);

  II_Plus:=loadicon(iconlist, ProgramPath+'images/plus.png');
  II_Minus:=loadicon(iconlist, ProgramPath+'images/minus.png');
  II_Ok:=loadicon(iconlist, ProgramPath+'images/ok.png');
  II_LayerOff:=loadicon(iconlist, ProgramPath+'images/off.png');
  II_LayerOn:=loadicon(iconlist, ProgramPath+'images/on.png');
  II_LayerUnPrint:=loadicon(iconlist, ProgramPath+'images/unprint.png');
  II_LayerPrint:=loadicon(iconlist, ProgramPath+'images/print.png');
  II_LayerUnLock:=loadicon(iconlist, ProgramPath+'images/unlock.png');
  II_LayerLock:=loadicon(iconlist, ProgramPath+'images/lock.png');
  II_LayerFreze:=loadicon(iconlist, ProgramPath+'images/freze.png');
  II_LayerUnFreze:=loadicon(iconlist, ProgramPath+'images/unfreze.png');
  II_Bug:=loadicon(iconlist, ProgramPath+'images/bug.png');
  II_Dxf:=loadicon(iconlist, ProgramPath+'images/dxf.png');
  II_Purge:=loadicon(iconlist, ProgramPath+'images/purge.png');
  II_Refresh:=loadicon(iconlist, ProgramPath+'images/refresh.png');
end;
end.

