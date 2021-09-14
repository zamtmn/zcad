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
{$mode delphi}
unit uzccommand_dimradius;

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzeconsts,uzcstrconsts,
  uzbgeomtypes,
  uzccommandsmanager,
  uzeentcircle,uzeentarc,uzeentityfactory,uzegeometry,
  uzcutils,uzeentdimradial,uzgldrawcontext,uzcdrawings,uzcinterface,
  uzccominteractivemanipulators,uzcsysvars,uzccommand_dimlinear;

implementation

function DrawRadialDim_com(operands:TCommandOperands):TCommandResult;
var
    pd:PGDBObjRadialDimension;
    pcircle:PGDBObjCircle;
    p1,p2,p3:gdbvertex;
    dc:TDrawContext;
  procedure FinalCreateRDim;
  begin
         pd := Pointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBRadialDimensionID,drawings.GetCurrentROOT));
         pd^.DimData.P10InWCS:=p1;
         pd^.DimData.P15InWCS:=p2;
         InteractiveDDimManipulator(pd,p2,false);
    if commandmanager.Get3DPointInteractive(rscmSpecifyThirdPoint,p3,@InteractiveDDimManipulator,pd)=GRNormal then
    begin
         drawings.GetCurrentDWG^.FreeConstructionObjects;
         pd := AllocEnt(GDBRadialDimensionID);
         pd^.initnul(drawings.GetCurrentROOT);

         pd^.DimData.P10InWCS:=p1;
         pd^.DimData.P15InWCS:=p2;
         pd^.DimData.P11InOCS:=p3;

         InteractiveDDimManipulator(pd,p3,false);
         dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

         pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
         {drawings.}zcAddEntToCurrentDrawingWithUndo(pd);
    end;
  end;

begin
    if operands<>'' then
    begin
    if GetInteractiveLine(rscmSpecifyfirstPoint,rscmSpecifySecondPoint,p1,p2) then
    begin
         FinalCreateRDim;
    end;
    end
    else
    begin
         if commandmanager.GetEntity('Select circle or arc',pcircle) then
         begin
              case pcircle^.GetObjType of
              GDBCircleID:begin
                              p1:=pcircle^.Local.P_insert;
                              p2:=pcircle^.q1;
                              FinalCreateRDim;
                          end;
                 GDBArcID:begin
                              p1:=pcircle^.Local.P_insert;
                              p2:=PGDBObjArc(pcircle)^.q1;
                              FinalCreateRDim;
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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@DrawRadialDim_com,'DimRadius',  CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
