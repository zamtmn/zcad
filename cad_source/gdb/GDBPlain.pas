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

unit GDBPlain;
{$INCLUDE def.inc}

interface
uses
gl,
 {GDBEntity,}GDBWithLocalCS,gdbase,gdbasetypes,varmandef,OGLSpecFunc;
type
{EXPORT+}
GDBObjPlain=object(GDBObjWithLocalCS)
                  Outbound:OutBound4V;

                  procedure DrawGeometry(lw:GDBInteger);virtual;
            end;
{EXPORT-}
implementation
uses
    log;
//uses UGDBDescriptor;
procedure GDBObjPlain.DrawGeometry;
//var
//  i: GDBInteger;
begin
  if (sysvar.DWG.DWG_SystmGeometryDraw^){and(POGLWnd.subrender=0)} then
  begin
       myglbegin(gl_line_loop);
       myglvertex3dv(@outbound[0]);
       myglvertex3dv(@outbound[1]);
       myglvertex3dv(@outbound[2]);
       myglvertex3dv(@outbound[3]);
       myglend;
  end;
  inherited;

end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBPlain.initialization');{$ENDIF}
end.
