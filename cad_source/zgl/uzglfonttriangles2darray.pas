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

unit uzglfonttriangles2darray;
{$INCLUDE def.inc}
interface
uses uzglline3darray,gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
geometry;
type
{Export+}
PZGLFontTriangle2DArray=^ZGLFontTriangle2DArray;
ZGLFontTriangle2DArray=packed object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBFontVertex2D*)
                             constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                             constructor initnul;
                       end;
{Export-}
implementation
uses OGLSpecFunc,log;
constructor ZGLFontTriangle2DArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBFontVertex2D));
end;
constructor ZGLFontTriangle2DArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBFontVertex2D);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzgltriangles3darray.initialization');{$ENDIF}
end.

