{
*****************************************************************************
*                                                                           *
*  This file is part of the fpLNLib                                         *
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

unit uLNLib;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,dynlibs,
  XYZ_CAPI,
  XYZW_CAPI,
  UV_CAPI,
  Matrix4d_CAPI,
  LNEnums_CAPI,
  LNObject_CAPI,
  NurbsCurve_CAPI,
  NurbsSurface_CAPI,
  gLNLib;

type
  LNLib=specialize gLNLibRec<TXYZ,TXYZW,TUV,TMatrix4d>;

implementation

begin
end.
