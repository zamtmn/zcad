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
unit uzccommand_dist;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings,uzcinterface,
  uzcstrconsts,uzegeometrytypes,
  uzccommandsmanager,
  varmandef,uzegeometry;

implementation
var
   c1,c2:integer;
   distlen:Double;
   oldpoint,point:gdbvertex;
function Dist_com_CommandStart(operands:TCommandOperands):TCommandResult;
begin
     c1:=commandmanager.GetValueHeap;
     c2:=-1;
     commandmanager.executecommandsilent('Get3DPoint(Первая точка:)',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
     distlen:=0;
     result:=cmd_ok;
end;
procedure Dist_com_CommandCont;
var
   cs:integer;
   vd:vardesk;
   len:Double;
begin
     cs:=commandmanager.GetValueHeap;
     if cs=c1 then
     begin
          commandmanager.executecommandend;
          exit;
     end;
     vd:=commandmanager.PopValue;
     point:=pgdbvertex(vd.data.Addr.Instance)^;
     //c1:=cs;
     c1:=commandmanager.GetValueHeap;
     if c2<>-1 then
                   begin
                        len:=uzegeometry.Vertexlength(point,oldpoint);
                        distlen:=distlen+len;
                        ZCMsgCallBackInterface.TextMessage(format(rscmSegmentLengthTotalLength,[floattostr(len),floattostr(distlen)]),TMWOHistoryOut)
                   end;
     c2:=cs;
     oldpoint:=point;
     commandmanager.executecommandsilent('Get3DPoint(Следующая точка:)',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandRTEdObjectPlugin(@Dist_com_CommandStart,nil,nil,nil,nil,nil,nil,@Dist_com_CommandCont,'Dist',0,0){.overlay:=true};
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
