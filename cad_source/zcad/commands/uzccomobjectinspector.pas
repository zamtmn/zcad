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
{/$mode objfpc}

{**Модуль реализации чертежных команд (линия, круг, размеры и т.д.)}
unit uzccomobjectinspector;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }
  
{$INCLUDE zengineconfig.inc}

interface
uses

  { uses units, the list will vary depending on the required entities
    and actions }
  { подключеные модули, список будет меняться в зависимости от требуемых
    примитивов и действий с ними }

  sysutils,

  URecordDescriptor,TypeDescriptors,

  Forms,
  uzegeometrytypes,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,

  uzcentcable,
  uzeentdevice,

  uzegeometry,

  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
   //base types
                      //описания базовых типов
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  uzcdrawing,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  gzundoCmdChgData,

  uzcstrconsts,       //resouce strings

  uzclog;                //log system
                      //<**система логирования

implementation

function GetPoint_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   p:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   cmd:TGDBVertexChangeCommand;
begin
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint(rscmSpecifyPoint,p)=GRNormal then
    begin
         cmd:=TGDBVertexChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,pgdbvertex(ppointer(vdpvertex.data.Addr.Instance)^)^,ppointer(vdpobj.data.Addr.Instance)^,drawings.AfterEnt);
         pgdbvertex(ppointer(vdpvertex.data.Addr.Instance)^)^:=p;
         //cmd.PEntity:=ppointer(vdpobj.data.Addr.Instance)^;
         cmd.ComitFromObj;
    end;
    result:=cmd_ok;
end;
function GetVertexX_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   p:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   cmd:TDoubleChangeCommand;
begin
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint(rscmSpecifyX,p)=GRNormal then
    begin
         cmd:=TDoubleChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBXCoordinate(ppointer(vdpvertex.data.Addr.Instance)^)^,ppointer(vdpobj.data.Addr.Instance)^,drawings.AfterEnt);
         pDouble(ppointer(vdpvertex.data.Addr.Instance)^)^:=p.x;
         //cmd.PEntity:=ppointer(vdpobj.data.Addr.Instance)^;
         cmd.ComitFromObj;
    end;
    result:=cmd_ok;
end;
function GetVertexY_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   p:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   cmd:TDoubleChangeCommand;
begin
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint(rscmSpecifyY,p)=GRNormal then
    begin
         cmd:=TDoubleChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBYCoordinate(ppointer(vdpvertex.data.Addr.Instance)^)^,ppointer(vdpobj.data.Addr.Instance)^,drawings.AfterEnt);
         pDouble(ppointer(vdpvertex.data.Addr.Instance)^)^:=p.y;
         //cmd.PEntity:=ppointer(vdpobj.data.Addr.Instance)^;
         cmd.ComitFromObj;
    end;
    result:=cmd_ok;
end;
function GetVertexZ_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   p:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   cmd:TDoubleChangeCommand;
begin
    vdpobj:=commandmanager.PopValue;
    vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint(rscmSpecifyZ,p)=GRNormal then
    begin
         cmd:=TDoubleChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PGDBZCoordinate(ppointer(vdpvertex.data.Addr.Instance)^)^,ppointer(vdpobj.data.Addr.Instance)^,drawings.AfterEnt);
         pDouble(ppointer(vdpvertex.data.Addr.Instance)^)^:=p.z;
         //cmd.PEntity:=ppointer(vdpobj.data.Addr.Instance)^;
         cmd.ComitFromObj;
    end;
    result:=cmd_ok;
end;
function GetLength_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   p1,p2:GDBVertex;
   vdpobj,vdpvertex:vardesk;
   cmd:TDoubleChangeCommand;
begin
  vdpobj:=commandmanager.PopValue;
  vdpvertex:=commandmanager.PopValue;
    if commandmanager.get3dpoint(rscmSpecifyFirstPoint,p1)=GRNormal then
    begin
      if commandmanager.get3dpoint(rscmSpecifySecondPoint,p2)=GRNormal then
      begin
        cmd:=TDoubleChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,pDouble(ppointer(vdpvertex.data.Addr.Instance)^)^,ppointer(vdpobj.data.Addr.Instance)^,drawings.AfterEnt);
        pgdblength(ppointer(vdpvertex.data.Addr.Instance)^)^:=uzegeometry.Vertexlength(p1,p2);
        //cmd.PEntity:=ppointer(vdpobj.data.Addr.Instance)^;
        cmd.ComitFromObj;
      end;
    end;
    result:=cmd_ok;
end;

initialization
  CreateZCADCommand(@GetPoint_com,   'GetPoint',   CADWG,0);
  CreateZCADCommand(@GetVertexX_com, 'GetVertexX', CADWG,0);
  CreateZCADCommand(@GetVertexY_com, 'GetVertexY', CADWG,0);
  CreateZCADCommand(@GetVertexZ_com, 'GetVertexZ', CADWG,0);
  CreateZCADCommand(@GetLength_com,  'GetLength',  CADWG,0);
end.
