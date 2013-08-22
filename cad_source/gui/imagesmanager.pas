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
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  {StdCtrls,} Buttons, {ColorBox,}{ ButtonPanel,}{ Spin,} ExtCtrls, {ComCtrls,}{math,}
  gdbase,{zcadstrconsts,}zcadsysvars,sysinfo;
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
  II_Dxf
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

  II_Plus:=loadicon(iconlist, sysparam.programpath+'images/plus.png');
  II_Minus:=loadicon(iconlist, sysparam.programpath+'images/minus.png');
  II_Ok:=loadicon(iconlist, sysparam.programpath+'images/ok.png');
  II_LayerOff:=loadicon(iconlist, sysparam.programpath+'images/off.png');
  II_LayerOn:=loadicon(iconlist, sysparam.programpath+'images/on.png');
  II_LayerUnPrint:=loadicon(iconlist, sysparam.programpath+'images/unprint.png');
  II_LayerPrint:=loadicon(iconlist, sysparam.programpath+'images/print.png');
  II_LayerUnLock:=loadicon(iconlist, sysparam.programpath+'images/unlock.png');
  II_LayerLock:=loadicon(iconlist, sysparam.programpath+'images/lock.png');
  II_LayerFreze:=loadicon(iconlist, sysparam.programpath+'images/freze.png');
  II_LayerUnFreze:=loadicon(iconlist, sysparam.programpath+'images/unfreze.png');
  II_Bug:=loadicon(iconlist, sysparam.programpath+'images/bug.png');
  II_Dxf:=loadicon(iconlist, sysparam.programpath+'images/dxf.png');
end;
end.
