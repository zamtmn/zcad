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
{$mode delphi}
unit uzccommand_arc;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccominteractivemanipulators,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentarc,uzeentline,uzeentityfactory,
  uzcdrawings,uzgldrawcontext,
  uzcutils;

implementation

function DrawArc_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pa:PGDBObjArc;
    pline:PGDBObjLine;
    pe:T3PointPentity;
    dc:TDrawContext;
begin
    if commandmanager.get3dpoint(rscmSpecifyFirstPoint,pe.p1)=GRNormal then
    begin
         pline := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
         pline^.CoordInOCS.lBegin:=pe.p1;
         InteractiveLineEndManipulator(pline,pe.p1,false);
      if commandmanager.Get3DPointInteractive(rscmSpecifySecondPoint,pe.p2,@InteractiveLineEndManipulator,pline)=GRNormal then
      begin
           drawings.GetCurrentDWG^.FreeConstructionObjects;
           pe.pentity:= Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBArcID,drawings.GetCurrentROOT));
        if commandmanager.Get3DPointInteractive(rscmSpecifyThirdPoint,pe.p3,@InteractiveArcManipulator,@pe)=GRNormal then
          begin
               drawings.GetCurrentDWG^.FreeConstructionObjects;
               pa := AllocEnt(GDBArcID);
               pe.pentity:=pa;
               pa^.initnul;

               InteractiveArcManipulator(@pe,pe.p3,false);
               dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
               pa^.FormatEntity(drawings.GetCurrentDWG^,dc);

               {drawings.}zcAddEntToCurrentDrawingWithUndo(pa);
          end;
      end;
    end;
    result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawArc_com,'Arc',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
