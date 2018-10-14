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

unit uzcsysparams;
{$INCLUDE def.inc}
interface
uses LCLProc,uzclog,uzbpaths,uzbtypesbase,Forms,uzbtypes{$IFNDEF DELPHI},LazUTF8{$ENDIF},sysutils;
{$INCLUDE revision.inc}
type
  TmyFileVersionInfo=packed record
                         major,minor,release,build,revision:GDBInteger;
                         versionstring:GDBstring;
                     end;
  tsysparam=record
                     ScreenX,ScreenY:GDBInteger;
                     DefaultHeight:GDBInteger;
                     Ver:TmyFileVersionInfo;
                     NoSplash,NoLoadLayout,UpdatePO:GDBBoolean;
                     otherinstancerun,UniqueInstance:GDBBoolean;
                     PreloadedFile:GDBString;
              end;
var
  SysParam: tsysparam;

implementation
end.
