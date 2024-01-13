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
{$MODE OBJFPC}{$H+}
unit uzccommand_Mirror;
{$INCLUDE zengineconfig.inc}

interface
uses
  Varman,
  uzcdrawings,
  uzeutils,
  uzglviewareadata,
  uzccommandsabstract,
  uzccommand_copy,
  uzegeometry,
  uzccommandsmanager,
  uzegeometrytypes,uzeentity,uzcLog,
  uzcstrconsts;
type
  TEntityProcess=(TEP_Erase,TEP_leave);
  PTMirrorParam=^TMirrorParam;
  TMirrorParam=record
    SourceEnts:TEntityProcess;
  end;
  mirror_com =  object(copy_com)
    function CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D; virtual;
    function AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
  end;
var
  MirrorParam:TMirrorParam;
  mirror:mirror_com;
implementation

function Mirror_com.CalcTransformMatrix(p1,p2: GDBvertex):DMatrix4D;
var
    dist,p3:gdbvertex;
    d:Double;
    plane:DVector4D;
begin
        dist:=uzegeometry.VertexSub(p2,p1);
        d:=uzegeometry.oneVertexlength(dist);
        p3:=uzegeometry.VertexMulOnSc(ZWCS,d);
        p3:=uzegeometry.VertexAdd(p3,t3dp);

        plane:=PlaneFrom3Pont(p1,p2,p3);
        normalizeplane(plane);
        result:=CreateReflectionMatrix(plane);
end;

function Mirror_com.AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer;
var
    dispmatr:DMatrix4D;
begin

  dispmatr:=CalcTransformMatrix(t3dp,wc);
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=dispmatr;

   if (button and MZW_LBUTTON)<>0 then
   begin
      case MirrorParam.SourceEnts of
                           TEP_Erase:move(dispmatr,self.CommandName);
                           TEP_Leave:copy(dispmatr,self.CommandName);
      end;
      //redrawoglwnd;
      commandmanager.executecommandend;
   end;
   result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  SysUnit^.RegisterType(TypeInfo(TMirrorParam));
  SysUnit^.RegisterType(TypeInfo(PTMirrorParam));
  SysUnit^.SetTypeDesk(TypeInfo(TMirrorParam),[rscmSourceEntities],[FNUser]);
  SysUnit^.SetTypeDesk(TypeInfo(TEntityProcess),[rscmErase,rscmLeave],[FNUser]);

  MirrorParam.SourceEnts:=TEP_Erase;
  mirror.init('Mirror',0,0);
  mirror.SetCommandParam(@MirrorParam,'PTMirrorParam');
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);

end.
