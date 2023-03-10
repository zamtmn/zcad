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

unit uzedimblocksregister;
{$INCLUDE zengineconfig.inc}


interface
uses uzeutils,uzestyleslayers,uzestyleslinetypes,uzeconsts,uzeentitiesmanager,
     UGDBObjBlockdefArray,uzeblockdefsfactory,uzeblockdef,uzedrawingdef,
     uzcsysvars,uzeentgenericsubentry,uzeentity,LazLogger,uzegeometrytypes,uzegeometry;
implementation
function CreateClosedFilledBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   pentity:PGDBObjEntity;
begin
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateSolid(result,@result.ObjArray,
                             dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                             CreateVertex(-1,-1/6,0),
                             CreateVertex(-1, 1/6,0),
                             CreateVertex( 0,   0,0));
end;
function CreateClosedBlankBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
   p1,p2:GDBvertex;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);

   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   p1:=CreateVertex(-1,-1/6,0);
   p2:=CreateVertex(-1,1/6,0);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            nulvertex,p1);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p1,p2);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p2,nulvertex);
end;
function CreateClosedBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
   p1,p2:GDBvertex;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   p1:=CreateVertex(-1,-1/6,0);
   p2:=CreateVertex(-1,1/6,0);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            nulvertex,p1);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p1,p2);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p2,nulvertex);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            nulvertex,CreateVertex(-1,0,0));
end;
function CreateArchTickBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   pentity:PGDBObjEntity;
   c,s:double;
begin
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   c:=0.075*cos(pi/4);
   s:=0.075*sin(pi/4);
   pentity:=ENTF_CreateSolid(result,@result.ObjArray,
                             dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                             CreateVertex(-0.5-c,-0.5+s,0),
                             CreateVertex( 0.5-c, 0.5+s,0),
                             CreateVertex(-0.5+c,-0.5-s,0),
                             CreateVertex( 0.5+c, 0.5-s,0));
end;
function CreateObliqueBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   pentity:PGDBObjEntity;
begin
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  pentity:=ENTF_CreateLine(result,@result.ObjArray,
                           dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                           CreateVertex(-0.5,-0.5,0),CreateVertex(0.5,0.5,0));
end;
function CreateOpenBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
   p1,p2:GDBvertex;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   p1:=CreateVertex(-1,-1/6,0);
   p2:=CreateVertex(-1,1/6,0);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            nulvertex,p1);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p2,nulvertex);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            nulvertex,CreateVertex(-1,0,0));
end;

function CreateOriginBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            nulvertex,CreateVertex(-1,0,0));
   pentity:=ENTF_CreateCircle(result,@result.ObjArray,
                              SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                              nulvertex,0.5);
end;

function CreateOrigin2Block(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            CreateVertex(-1,0,0),CreateVertex(-0.5,0,0));
   pentity:=ENTF_CreateCircle(result,@result.ObjArray,
                              SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                              nulvertex,0.5);
   pentity:=ENTF_CreateCircle(result,@result.ObjArray,
                              SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                              nulvertex,0.25);
end;

function CreateOpen90Block(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            nulvertex,CreateVertex(-1,0,0));
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            CreateVertex(-0.5,0.5,0),nulvertex);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            CreateVertex(-0.5,-0.5,0),nulvertex);

end;

function CreateOpen30Block(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            nulvertex,CreateVertex(-1,0,0));
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            CreateVertex(-1,0.2679,0),nulvertex);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            CreateVertex(-1,-0.2679,0),nulvertex);

end;

function CreateDotBlankBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            CreateVertex(-1,0,0),CreateVertex(-0.5,0,0));
   pentity:=ENTF_CreateCircle(result,@result.ObjArray,
                              SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                              nulvertex,0.5);
end;

function CreateSmallBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   pentity:PGDBObjEntity;
begin
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateCircle(result,@result.ObjArray,
                              dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                              nulvertex,0.25);
end;

function CreateBoxBlankBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
   p1,p2,p3,p4:GDBvertex;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   p1:=CreateVertex(-0.5,0.5,0);
   p2:=CreateVertex(0.5,0.5,0);
   p3:=CreateVertex(0.5,-0.5,0);
   p4:=CreateVertex(-0.5,-0.5,0);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p1,p2);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p2,p3);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p3,p4);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p4,p1);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            CreateVertex(-0.5,0,0),CreateVertex(-1,0,0));
end;

function CreateBoxFilledBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateSolid(result,@result.ObjArray,
                             SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                             CreateVertex( 0.5,-0.5,0),
                             CreateVertex(-0.5,-0.5,0),
                             CreateVertex( 0.5, 0.5,0),
                             CreateVertex(-0.5 ,0.5,0));
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            CreateVertex(-0.5,0,0),CreateVertex(-1,0,0));
end;

function CreateDatumBlankBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   layertable:PGDBLayerArray;
   lttable:PGDBLtypeArray;
   pentity:PGDBObjEntity;
   SystemLayer:PGDBLayerProp;
   SystemLT:PGDBLtypeProp;
   p1,p2,p3:GDBvertex;
begin
   layertable:=dwg^.GetLayerTable;
   lttable:=dwg^.GetLTypeTable;
   SystemLayer:=layertable^.GetSystemLayer;
   SystemLT:=lttable^.GetSystemLT(TLTByBlock);
   p1:=CreateVertex( 0, 0.5774,0);
   p2:=CreateVertex(-1, 0     ,0);
   p3:=CreateVertex( 0,-0.5774,0);
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p1,p2);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p2,p3);
   pentity:=ENTF_CreateLine(result,@result.ObjArray,
                            SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                            p3,p1);
end;

function CreateDatumFilledBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
   BlockDefArray:PGDBObjBlockdefArray;
   pentity:PGDBObjEntity;
begin
   BlockDefArray:=dwg^.GetBlockDefArraySimple;
   result:=BlockDefArray.create(BlockName);
   pentity:=ENTF_CreateSolid(result,@result.ObjArray,
                             dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                             CreateVertex( 0, 0.5774,0),
                             CreateVertex(-1, 0     ,0),
                             CreateVertex( 0,-0.5774,0));
end;


initialization
  RegisterBlockDefCreateFunc('_ClosedFilled','','',CreateClosedFilledBlock);//implemented
  RegisterBlockDefCreateFunc('_ClosedBlank','','',CreateClosedBlankBlock);//implemented
  RegisterBlockDefCreateFunc('_Closed','','',CreateClosedBlock);//implemented
  //RegisterBlockDefCreateFunc('_Dot','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_ArchTick','','',CreateArchTickBlock);//implemented
  RegisterBlockDefCreateFunc('_Oblique','','',CreateObliqueBlock);//implemented
  RegisterBlockDefCreateFunc('_Open','','',CreateOpenBlock);//implemented
  RegisterBlockDefCreateFunc('_Origin','','',CreateOriginBlock);//implemented
  RegisterBlockDefCreateFunc('_Origin2','','',CreateOrigin2Block);//implemented
  RegisterBlockDefCreateFunc('_Open90','','',CreateOpen90Block);//implemented
  RegisterBlockDefCreateFunc('_Open30','','',CreateOpen30Block);//implemented
  //RegisterBlockDefCreateFunc('_DotSmall','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_DotBlank','','',CreateDotBlankBlock);//implemented
  RegisterBlockDefCreateFunc('_Small','','',CreateSmallBlock);//implemented
  RegisterBlockDefCreateFunc('_BoxBlank','','',CreateBoxBlankBlock);//implemented
  RegisterBlockDefCreateFunc('_BoxFilled','','',CreateBoxFilledBlock);//implemented
  RegisterBlockDefCreateFunc('_DatumBlank','','',CreateDatumBlankBlock);//implemented
  RegisterBlockDefCreateFunc('_DatumFilled','','',CreateDatumFilledBlock);//implemented
  //RegisterBlockDefCreateFunc('_Integral','','',CreateClosedFilledBlock);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
