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
unit uzccommand_dimlinear;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentline,uzeentityfactory,
  uzcutils,uzeentdimrotated,uzgldrawcontext,uzcdrawings,
  uzccominteractivemanipulators,uzcsysvars;

function GetInteractiveLine(prompt1,prompt2:String;out p1,p2:GDBVertex):Boolean;

implementation

function GetInteractiveLine(prompt1,prompt2:String;out p1,p2:GDBVertex):Boolean;
var
    pline:PGDBObjLine;
begin
    result:=false;
    if commandmanager.get3dpoint(prompt1,p1)=GRNormal then
    begin
         pline := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
         pline^.CoordInOCS.lBegin:=p1;
         InteractiveLineEndManipulator(pline,p1,false);
      if commandmanager.Get3DPointInteractive(prompt2,p2,@InteractiveLineEndManipulator,pline)=GRNormal then
      begin
           result:=true;
      end;
    end;
    drawings.GetCurrentDWG^.FreeConstructionObjects;
end;

function DrawRotatedDim_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjRotatedDimension;
    p1,p2,p3,vd,vn:gdbvertex;
    dc:TDrawContext;
begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    if GetInteractiveLine(rscmSpecifyfirstPoint,rscmSpecifySecondPoint,p1,p2) then
    begin
         pd := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBRotatedDimensionID,drawings.GetCurrentROOT));
         pd^.DimData.P13InWCS:=p1;
         pd^.DimData.P14InWCS:=p2;
         InteractiveRDimManipulator(pd,p2,false);
         if commandmanager.Get3DPointInteractive( rscmSpecifyThirdPoint,
                                                  p3,
                                                  @InteractiveRDimManipulator,
                                                  pd)=GRNormal
         then
         begin
              vd:=pd^.vectorD;
              vn:=pd^.vectorN;
              drawings.GetCurrentDWG^.FreeConstructionObjects;
              pd := AllocEnt(GDBRotatedDimensionID);
              pd^.initnul(drawings.GetCurrentROOT);
              zcSetEntPropFromCurrentDrawingProp(pd);

              pd^.PDimStyle:=sysvar.dwg.DWG_CDimStyle^;
              pd^.DimData.P13InWCS:=p1;
              pd^.DimData.P14InWCS:=p2;
              pd^.DimData.P10InWCS:=p3;

              pd^.vectorD:=vd;
              pd^.vectorN:=vn;
              InteractiveRDimManipulator(pd,p3,false);

              pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
              {drawings.}zcAddEntToCurrentDrawingWithUndo(pd);
         end;
    end;
    result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawRotatedDim_com,'DimLinear',  CADWG,0)
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
