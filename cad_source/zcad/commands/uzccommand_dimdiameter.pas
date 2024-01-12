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
unit uzccommand_dimdiameter;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentcircle,uzeentarc,uzeentityfactory,uzegeometry,
  uzcutils,uzeentdimdiametric,uzgldrawcontext,uzcdrawings,uzcinterface,
  uzccominteractivemanipulators,uzcsysvars,uzccommand_dimlinear;

implementation

function DrawDiametricDim_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjDiametricDimension;
    pcircle:PGDBObjCircle;
    p1,p2,p3:gdbvertex;
    dc:TDrawContext;
  procedure FinalCreateDDim;
  begin
      pd := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBDiametricDimensionID,drawings.GetCurrentROOT));
      pd^.DimData.P10InWCS:=p1;
      pd^.DimData.P15InWCS:=p2;
      InteractiveDDimManipulator(pd,p2,false);
      if commandmanager.Get3DPointInteractive(rscmSpecifyThirdPoint,p3,@InteractiveDDimManipulator,pd)=GRNormal then
      begin
          drawings.GetCurrentDWG^.FreeConstructionObjects;
          pd := AllocEnt(GDBDiametricDimensionID);
          pd^.initnul(drawings.GetCurrentROOT);

          pd^.DimData.P10InWCS:=p1;
          pd^.DimData.P15InWCS:=p2;
          pd^.DimData.P11InOCS:=p3;

          InteractiveDDimManipulator(pd,p3,false);

          pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
          {drawings.}zcAddEntToCurrentDrawingWithUndo(pd);
      end;
  end;

begin
    if operands<>'' then
    begin
    if GetInteractiveLine(rscmSpecifyfirstPoint,rscmSpecifySecondPoint,p1,p2) then
    begin
         FinalCreateDDim;
    end;
    end
    else
    begin
         if commandmanager.GetEntity('Select circle or arc',pcircle) then
         begin
              dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
              case pcircle^.GetObjType of
              GDBCircleID:begin
                              p1:=pcircle^.q1;
                              p2:=pcircle^.q3;
                              FinalCreateDDim;
                          end;
                 GDBArcID:begin
                              p1:=pcircle^.Local.P_insert;
                              p2:=PGDBObjArc(pcircle)^.q1;
                              p3:=VertexSub(p2,p1);
                              p1:=VertexSub(p1,p3);
                              FinalCreateDDim;
                          end;
                     else begin
                              ZCMsgCallBackInterface.TextMessage('Please select Arc or Circle',TMWOShowError);
                          end;
              end;
         end;
    end;
    result:=cmd_ok;
end;



initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DrawDiametricDim_com,'DimDiameter',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
