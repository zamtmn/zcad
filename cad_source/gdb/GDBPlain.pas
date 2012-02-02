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
 {GDBEntity,}GDBWithLocalCS,gdbase,gdbasetypes,varmandef,OGLSpecFunc{,GDBEntity};
type
{EXPORT+}
GDBObjPlain=object(GDBObjWithLocalCS)
                  Outbound:OutBound4V;

                  procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
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
       oglsm.myglbegin(gl_line_loop);
       oglsm.myglvertex3dv(@outbound[0]);
       oglsm.myglvertex3dv(@outbound[1]);
       oglsm.myglvertex3dv(@outbound[2]);
       oglsm.myglvertex3dv(@outbound[3]);
       oglsm.myglend;
  end;
  inherited;

end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBPlain.initialization');{$ENDIF}
end.
