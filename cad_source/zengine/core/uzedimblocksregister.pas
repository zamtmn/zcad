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
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeutils,uzestyleslayers,uzestyleslinetypes,uzeconsts,uzeentitiesmanager,
  UGDBObjBlockdefArray,uzeblockdefsfactory,uzeblockdef,uzedrawingdef,uzcsysvars,
  uzeentgenericsubentry,uzeentity,uzbLogIntf,uzegeometrytypes,uzegeometry,math;

implementation

function CreateClosedFilledBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
begin
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateSolid(result,@result.ObjArray,
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
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
  p1,p2:TzePoint3d;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);

  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  p1:=CreateVertex(-1,-1/6,0);
  p2:=CreateVertex(-1,1/6,0);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  nulvertex,p1);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p1,p2);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p2,nulvertex);
end;
function CreateClosedBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
  p1,p2:TzePoint3d;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  p1:=CreateVertex(-1,-1/6,0);
  p2:=CreateVertex(-1,1/6,0);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  nulvertex,p1);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p1,p2);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p2,nulvertex);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  nulvertex,CreateVertex(-1,0,0));
end;

function CreateDotBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-0.5,0,0),CreateVertex(-1,0,0));
  ENTF_CreateLWPolyLine(result,@result.ObjArray,
                        SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                        [true,
                        -0.25{x},0{y},1{bulge},0.5,0.5,{start/end width}
                         0.25,   0,   1,       0.5,0.5]);
end;

function CreateArchTickBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  c,s:double;
  sine,cosine:double;
begin
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  SinCos(pi/4,sine,cosine);
  c:=0.075*cosine;
  s:=0.075*sine;
  ENTF_CreateSolid(result,@result.ObjArray,
                   dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                   CreateVertex(-0.5-c,-0.5+s,0),
                   CreateVertex( 0.5-c, 0.5+s,0),
                   CreateVertex(-0.5+c,-0.5-s,0),
                   CreateVertex( 0.5+c, 0.5-s,0));
end;
function CreateObliqueBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
begin
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                  CreateVertex(-0.5,-0.5,0),CreateVertex(0.5,0.5,0));
end;
function CreateOpenBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
  p1,p2:TzePoint3d;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  p1:=CreateVertex(-1,-1/6,0);
  p2:=CreateVertex(-1,1/6,0);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  nulvertex,p1);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p2,nulvertex);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  nulvertex,CreateVertex(-1,0,0));
end;

function CreateOriginBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  nulvertex,CreateVertex(-1,0,0));
  ENTF_CreateCircle(result,@result.ObjArray,
                    SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                    nulvertex,0.5);
end;

function CreateOrigin2Block(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-1,0,0),CreateVertex(-0.5,0,0));
  ENTF_CreateCircle(result,@result.ObjArray,
                    SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                    nulvertex,0.5);
  ENTF_CreateCircle(result,@result.ObjArray,
                    SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                    nulvertex,0.25);
end;

function CreateOpen90Block(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  nulvertex,CreateVertex(-1,0,0));
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-0.5,0.5,0),nulvertex);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-0.5,-0.5,0),nulvertex);
end;

function CreateOpen30Block(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  nulvertex,CreateVertex(-1,0,0));
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-1,0.2679,0),nulvertex);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-1,-0.2679,0),nulvertex);
end;

function CreateDotSmallBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
begin
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLWPolyLine(result,@result.ObjArray,
                        dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                        [true,
                        -0.0625{x},0{y},1{bulge},0.5,0.5,{start/end width}
                         0.0625,   0,   1,       0.5,0.5]);
end;


function CreateDotBlankBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-1,0,0),CreateVertex(-0.5,0,0));
  ENTF_CreateCircle(result,@result.ObjArray,
                    SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                    nulvertex,0.5);
end;

function CreateSmallBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
begin
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateCircle(result,@result.ObjArray,
                    dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                    nulvertex,0.25);
end;

function CreateBoxBlankBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
  p1,p2,p3,p4:TzePoint3d;
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
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p1,p2);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p2,p3);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p3,p4);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p4,p1);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-0.5,0,0),CreateVertex(-1,0,0));
end;

function CreateBoxFilledBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateSolid(result,@result.ObjArray,
                   SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                   CreateVertex( 0.5,-0.5,0),
                   CreateVertex(-0.5,-0.5,0),
                   CreateVertex( 0.5, 0.5,0),
                   CreateVertex(-0.5 ,0.5,0));
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  CreateVertex(-0.5,0,0),CreateVertex(-1,0,0));
end;

function CreateDatumBlankBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
  p1,p2,p3:TzePoint3d;
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
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p1,p2);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p2,p3);
  ENTF_CreateLine(result,@result.ObjArray,
                  SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                  p3,p1);
end;

function CreateDatumFilledBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
begin
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateSolid(result,@result.ObjArray,
                   dwg^.GetLayerTable^.GetSystemLayer,dwg^.GetLTypeTable^.GetSystemLT(TLTByBlock),LnWtByBlock,ClByBlock,
                   CreateVertex( 0, 0.5774,0),
                   CreateVertex(-1, 0     ,0),
                   CreateVertex( 0,-0.5774,0));
end;

function CreateIntegralBlock(var dwg:PTDrawingDef;const BlockName,BlockDependsOn,BlockDeffinedIn:String):PGDBObjBlockdef;
var
  BlockDefArray:PGDBObjBlockdefArray;
  layertable:PGDBLayerArray;
  lttable:PGDBLtypeArray;
  SystemLayer:PGDBLayerProp;
  SystemLT:PGDBLtypeProp;
begin
  layertable:=dwg^.GetLayerTable;
  lttable:=dwg^.GetLTypeTable;
  SystemLayer:=layertable^.GetSystemLayer;
  SystemLT:=lttable^.GetSystemLT(TLTByBlock);
  BlockDefArray:=dwg^.GetBlockDefArraySimple;
  result:=BlockDefArray.create(BlockName);
  ENTF_CreateArc(result,@result.ObjArray,
                 SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                 CreateVertex(-0.44424204,0.09442656,0),
                 0.45416667,4.92182849,6.07374580);
  ENTF_CreateArc(result,@result.ObjArray,
                 SystemLayer,SystemLT,LnWtByBlock,ClByBlock,
                 CreateVertex(0.44553400,-0.08824270,0),
                 0.45416667,1.78023584,2.93215314);
end;


initialization
  RegisterBlockDefCreateFunc('_ClosedFilled','','',CreateClosedFilledBlock);
  RegisterBlockDefCreateFunc('_ClosedBlank','','',CreateClosedBlankBlock);
  RegisterBlockDefCreateFunc('_Closed','','',CreateClosedBlock);
  RegisterBlockDefCreateFunc('_Dot','','',CreateDotBlock);
  RegisterBlockDefCreateFunc('_ArchTick','','',CreateArchTickBlock);
  RegisterBlockDefCreateFunc('_Oblique','','',CreateObliqueBlock);
  RegisterBlockDefCreateFunc('_Open','','',CreateOpenBlock);
  RegisterBlockDefCreateFunc('_Origin','','',CreateOriginBlock);
  RegisterBlockDefCreateFunc('_Origin2','','',CreateOrigin2Block);
  RegisterBlockDefCreateFunc('_Open90','','',CreateOpen90Block);
  RegisterBlockDefCreateFunc('_Open30','','',CreateOpen30Block);
  RegisterBlockDefCreateFunc('_DotSmall','','',CreateDotSmallBlock);
  RegisterBlockDefCreateFunc('_DotBlank','','',CreateDotBlankBlock);
  RegisterBlockDefCreateFunc('_Small','','',CreateSmallBlock);
  RegisterBlockDefCreateFunc('_BoxBlank','','',CreateBoxBlankBlock);
  RegisterBlockDefCreateFunc('_BoxFilled','','',CreateBoxFilledBlock);
  RegisterBlockDefCreateFunc('_DatumBlank','','',CreateDatumBlankBlock);
  RegisterBlockDefCreateFunc('_DatumFilled','','',CreateDatumFilledBlock);
  RegisterBlockDefCreateFunc('_Integral','','',CreateIntegralBlock);
finalization
  zDebugLn('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
end.
