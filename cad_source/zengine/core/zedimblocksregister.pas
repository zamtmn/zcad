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

unit zedimblocksregister;
{$INCLUDE def.inc}


interface
uses uzestyleslayers,uzestyleslinetypes,gdbobjectsconstdef,zeentitiesmanager,
     UGDBObjBlockdefArray,zeblockdefsfactory,uzeblockdef,uzedrawingdef,
     memman,uzcsysvars,GDBase,GDBasetypes,uzeentgenericsubentry,uzeentity;
implementation
uses
    uzcutils;
function CreateClosedFilledBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:GDBString):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
begin
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateSolid(result,@result.ObjArray,[-1,-1/6,0,-1,1/6,0,0,0,0]);

   if pentity<>nil then
   begin
     layertable:=dwg^.GetLayerTable;
     lttable:=dwg^.GetLTypeTable;
     GDBObjSetEntityProp(pentity,layertable^.GetSystemLayer,lttable^.GetSystemLT(TLTByLayer),ClByLayer,LnWtByLayer);
   end;
end;
initialization
  RegisterBlockDefCreateFunc('_ClosedFilled','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_ClosedBlank','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Closed','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Dot','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_ArchTick','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Oblique','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Open','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Origin','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Origin2','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Open90','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Open30','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_DotSmall','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_DotBlank','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Small','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_BoxBlank','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_BoxFilled','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_DatumBlank','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_DatumFilled','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_Integral','','',CreateClosedFilledBlock);
finalization
end.
