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

unit uzelclintfex;
{$INCLUDE zengineconfig.inc}
interface

uses
 {$IFDEF WINDOWS}windows,{$ENDIF}
 {$IFDEF LCLQT}qt4,qtobjects,{$ENDIF}
 {$IFDEF LCLQT5}qt5,qtobjects,{$ENDIF}
 {$IFNDEF DELPHI}LCLType,LCLIntf,{$ENDIF}
 {$IFDEF DELPHI}windows,types,{$ENDIF}
 uzegeometrytypes;
const
     GM_COMPATIBLE=1;
     GM_ADVANCED=2;
     FR_PRIVATE=$10;//from WinGDI.h//#define FR_PRIVATE     0x10
 {$IFNDEF WINDOWS}type winbool=longint;{$ENDIF}

function AddFontResourceFile(const FontResourceFileName:string):integer;
function SetGraphicsMode_(hdc:HDC; iMode:longint):longint;
function SetWorldTransform_(hdc:HDC; const tm:DMatrix4d):WINBOOL;
function SetTextAlignToBaseLine(hdc:HDC):UINT;
implementation
{$IFDEF WINDOWS}
  function __AddFontResourceEx(_para1:LPCSTR; flags:DWORD; reserved:Pointer) : integer; stdcall; external 'gdi32' name 'AddFontResourceExA';
  //function __SetGraphicsMode(hdc:HDC; iMode:longint):longint; external 'gdi32' name 'SetGraphicsMode';
  //function __SetWorldTransform(_para1:HDC; var _para2:XFORM):WINBOOL; external 'gdi32' name 'SetWorldTransform';
{$ENDIF}
function SetTextAlignToBaseLine(hdc:HDC):UINT;
begin
  {$IFDEF WINDOWS}
    result:=SetTextAlign(hdc,TA_BASELINE{ or TA_LEFT});
  {$ENDIF}
  {$if DEFINED(LCLQt) OR DEFINED(LCLQt5)}
  TQtDeviceContext(hdc).translate(0,-TQtDeviceContext(hdc).Metrics.ascent)
  {$ENDIF}
end;
function AddFontResourceFile(const FontResourceFileName:string):integer;
begin
  {$IFDEF WINDOWS}
    result:=__AddFontResourceEx(@FontResourceFileName[1],FR_PRIVATE,nil);
  {$Else}
    result:=1;
  {$ENDIF}
end;
function SetGraphicsMode_(hdc:HDC; iMode:longint):longint;
begin
  {$IFDEF WINDOWS}
    result:=windows.SetGraphicsMode(hdc,iMode);
  {$Else}
    result:=1;
  {$ENDIF}
end;
function SetWorldTransform_(hdc:HDC; const tm:DMatrix4d):WINBOOL;
{$IFDEF WINDOWS}
  var
    _m:XFORM;
{$ENDIF}
{$if DEFINED(LCLQt) OR DEFINED(LCLQt5)}
  var
  //QtDC: TQtDeviceContext absolute hdc;
  matr:QMatrixH;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  _m.eM11:=tm.mtr.v[0].v[0];
  _m.eM12:=tm.mtr.v[0].v[1];
  _m.eM21:=tm.mtr.v[1].v[0];
  _m.eM22:=tm.mtr.v[1].v[1];
  _m.eDx:=tm.mtr.v[3].v[0];
  _m.eDy:=tm.mtr.v[3].v[1];
  result:=SetWorldTransform(hdc,_m);
  {$ENDIF}
  {$if DEFINED(LCLQt) OR DEFINED(LCLQt5)}
    //QtDC.pa;
    matr:=QMatrix_create(tm.mtr.v[0].v[0],tm.mtr.v[0].v[1],tm.mtr.v[1].v[0],tm.mtr.v[1].v[1],tm.mtr.v[3].v[0],tm.mtr.v[3].v[1]);
    QPainter_setWorldMatrix(TQtDeviceContext(hdc).Widget,matr,false);
    //setWorldTransform
  {$ENDIF}
end;
end.

