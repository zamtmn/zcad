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

unit uzventsuperline;
{$INCLUDE zengineconfig.inc}

interface
uses uzeobjectextender,LCLProc,uzeentityfactory,uzedrawingdef,
     uzestyleslayers,uzeentsubordinated,uzcLog,
     uzeentline,uzeentity,uzctnrVectorBytes,uzbtypes,uzeconsts,
     uzegeometrytypes,uzegeometry,uzeffdxfsupport;
type
{Export+}
{REGISTEROBJECTTYPE GDBObjSuperLine}
PGDBObjSuperLine=^GDBObjSuperLine;
GDBObjSuperLine= object(GDBObjLine)
                  constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p1,p2:TzePoint3d);
                  constructor initnul(owner:PGDBObjGenericWithSubordinated);
                  function GetObjTypeName:String;virtual;
                  class function CreateInstance:PGDBObjLine;static;
                  function GetObjType:TObjID;virtual;
                  function Clone(own:Pointer):PGDBObjEntity;virtual;
                  procedure SaveToDXFObjXData(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext);virtual;
                  class function GetDXFIOFeatures:TDXFEntIODataManager;static;
           end;
{Export-}
function AllocAndInitSuperLine(owner:PGDBObjGenericWithSubordinated):PGDBObjLine;
var
    GDBObjSuperLineDXFFeatures:TDXFEntIODataManager;
implementation
constructor GDBObjSuperLine.init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt;p1,p2:TzePoint3d);
begin
     inherited;
     GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
constructor GDBObjSuperLine.initnul(owner:PGDBObjGenericWithSubordinated);
begin
     inherited;
     GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
procedure GDBObjSuperLine.SaveToDXFObjXData(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext);
begin
     inherited;
     dxfStringout(outStream,1000,'_UPGRADE=10');
end;
class function GDBObjSuperLine.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjSuperLineDXFFeatures;
end;
function GDBObjSuperLine.GetObjTypeName;
begin
     result:=ObjN_GDBObjSuperLine;
end;
function GDBObjSuperLine.GetObjType;
begin
     result:=GDBSuperLineID;
end;
function GDBObjSuperLine.Clone;
var tvo: PGDBObjSuperLine;
begin
  Getmem(Pointer(tvo), sizeof(GDBObjSuperLine));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight, CoordInOCS.lBegin, CoordInOCS.lEnd);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.bp.ListPos.Owner:=own;
  EntExtensions.RunOnCloneProcedures(@self,tvo);
  result := tvo;
end;
function AllocSuperLine:PGDBObjLine;
begin
  Getmem(pointer(result),sizeof(GDBObjSuperLine));
end;
function AllocAndInitSuperLine(owner:PGDBObjGenericWithSubordinated):PGDBObjLine;
begin
  result:=AllocSuperLine;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
procedure SetSuperLineGeomProps(Pline:PGDBObjLine;args:array of const);
var
   counter:integer;
begin
  counter:=low(args);
  Pline.CoordInOCS.lBegin:=CreateVertexFromArray(counter,args);
  Pline.CoordInOCS.lEnd:=CreateVertexFromArray(counter,args);
end;
function AllocAndCreateSuperLine(owner:PGDBObjGenericWithSubordinated;args:array of const):PGDBObjLine;
begin
  result:=AllocAndInitSuperLine(owner);
  //owner^.AddMi(@result);
  SetSuperLineGeomProps(result,args);
end;
class function GDBObjSuperLine.CreateInstance:PGDBObjLine;
begin
  result:=AllocAndInitSuperLine(nil);
end;
function UpgradeLine2SuperLine(ptu:PExtensionData;pent:PGDBObjLine;const drawing:TDrawingDef):PGDBObjSuperLine;
begin
     Getmem(pointer(result),sizeof(GDBObjSuperLine));
     result^.initnul(pent^.bp.ListPos.Owner);
     result^.CoordInOCS:=pent^.CoordInOCS;
     pent.CopyVPto(result^);
end;
initialization
  GDBObjSuperLineDXFFeatures:=TDXFEntIODataManager.Create;
  RegisterEntity(GDBSuperLineID,'SuperLine',@AllocSuperLine,@AllocAndInitSuperLine,@SetSuperLineGeomProps,@AllocAndCreateSuperLine);
  RegisterEntityUpgradeInfo(GDBLineID,UD_LineToSuperLine,@UpgradeLine2SuperLine);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  GDBObjSuperLineDXFFeatures.destroy;
end.
