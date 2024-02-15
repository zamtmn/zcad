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
unit uzccommand_NumDevices;
{$INCLUDE zengineconfig.inc}

interface
uses
  gzctnrVectorTypes,
  uzctnrvectorobjid,
  uzctnrVectorDouble,
  uzctnrvectorgdblineweight,
  uzctnrVectorPointers,
  uzcstrconsts,
  uzeenttext,
  uzccommandsabstract,
  
  uzccommandsmanager,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzcutils,
  sysutils,
  uzcinterface,
  uzeconsts,
  uzeentity,
  uzeentmtext,
  uzeentblockinsert,
  uzctnrvectorstrings,
  Varman, varmandef,
  uzcLog,uzctnrvectorgdbpalettecolor,
  uzccomdraw,UGDBSelectedObjArray,uzeentdevice,uzgldrawcontext,
  uzcenitiesvariablesextender,uzbstrproc;
type
  TST=(
          TST_YX(*'Y-X'*),
          TST_XY(*'X-Y'*),
          TST_UNSORTED(*'Unsorted'*)
         );

  PTNumberingParams=^TNumberingParams;
  TNumberingParams=record
                     SortMode:TST;(*'Sorting'*)
                     InverseX:Boolean;(*'Inverse X axis dir'*)
                     InverseY:Boolean;(*'Inverse Y axis dir'*)
                     DeadDand:Double;(*'Deadband'*)
                     StartNumber:Integer;(*'Start'*)
                     Increment:Integer;(*'Increment'*)
                     SaveStart:Boolean;(*'Save start number'*)
                     BaseName:AnsiString;(*'Base name sorting devices'*)
                     NumberVar:AnsiString;(*'Number variable'*)
               end;
  Number_com= object(CommandRTEdObject)
                         procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:PtrInt); virtual;
             end;
var
   NumberCom:Number_com;
   NumberingParams:TNumberingParams;
implementation
procedure Number_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  if drawings.GetCurrentDWG^.SelObjArray.Count>0 then
  begin
       showmenu;
       inherited CommandStart(context,'');
  end
  else
  begin
    ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;
procedure Number_com.ShowMenu;
begin
  commandmanager.DMAddMethod(rscmNumber,'Number selected devices',@run);
  commandmanager.DMShow;
end;
procedure Number_com.Run(pdata:PtrInt);
var
    psd:PSelectedObjDesc;
    ir:itrec;
    mpd:devcoordarray;
    pdev:PGDBObjDevice;
    //key:GDBVertex;
    index:integer;
    pvd:pvardesk;
    dcoord:tdevcoord;
    i,count:integer;
    process:boolean;
    DC:TDrawContext;
    pdevvarext:TVariablesExtender;
begin
     mpd:=devcoordarray.Create;
     psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
     count:=0;
     dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
     if psd<>nil then
     repeat
           if psd^.objaddr^.GetObjType=GDBDeviceID then
           begin
                case NumberingParams.SortMode of
                                                TST_YX,TST_UNSORTED:
                                                       begin
                                                       dcoord.coord:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS;
                                                       if NumberingParams.InverseX then
                                                                                       dcoord.coord.x:=-dcoord.coord.x;
                                                       if NumberingParams.InverseY then
                                                                                       dcoord.coord.y:=-dcoord.coord.y;
                                                       end;
                                                TST_XY:
                                                       begin
                                                            dcoord.coord.x:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.y;
                                                            dcoord.coord.y:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.x;
                                                            dcoord.coord.z:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.z;
                                                            if NumberingParams.InverseX then
                                                                                            dcoord.coord.y:=-dcoord.coord.y;
                                                            if NumberingParams.InverseY then
                                                                                            dcoord.coord.x:=-dcoord.coord.x;
                                                       end;
                                               end;{case}
                dcoord.pdev:=pointer(psd^.objaddr);
                inc(count);
                mpd.PushBack(dcoord);
           end;
     psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
     until psd=nil;
     if count=0 then
                    begin
                         ZCMsgCallBackInterface.TextMessage('In selection not found devices',TMWOHistoryOut);
                         mpd.Destroy;
                         Commandmanager.executecommandend;
                         exit;
                    end;
     index:=NumberingParams.StartNumber;
     if NumberingParams.SortMode<>TST_UNSORTED then begin
       TGDBVertexLess.deadband:=NumberingParams.DeadDand;
       devcoordsort.Sort(mpd,mpd.Size);
     end;
     count:=0;
     for i:=0 to mpd.Size-1 do
       begin
            dcoord:=mpd[i];
            pdev:=dcoord.pdev;
            pointer(pdevvarext):=pdev^.specialize GetExtension<TVariablesExtender>;

            if NumberingParams.BaseName<>'' then
            begin
            //pvd:=PTEntityUnit(pdev^.ou.Instance)^.FindVariable('NMO_BaseName');
            pvd:=pdevvarext.entityunit.FindVariable('NMO_BaseName');
            if pvd<>nil then
            begin
            if uppercase(pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Addr.Instance))=
               uppercase(Tria_AnsiToUtf8(NumberingParams.BaseName)) then
                                                       process:=true
                                                   else
                                                       process:=false;
            end
               else
                   begin
                        process:=true;
                        ZCMsgCallBackInterface.TextMessage('In device not found BaseName variable. Processed',TMWOHistoryOut);
                   end;
            end
               else
                   process:=true;
            if process then
            begin
            //pvd:=PTEntityUnit(pdev^.ou.Instance)^.FindVariable(NumberingParams.NumberVar);
            pvd:=pdevvarext.entityunit.FindVariable(NumberingParams.NumberVar);
            if pvd<>nil then
            begin
                 pvd^.data.PTD^.SetValueFromString(pvd^.data.Addr.Instance,inttostr(index));
                 inc(index,NumberingParams.Increment);
                 inc(count);
                 pdev^.FormatEntity(drawings.GetCurrentDWG^,dc);
            end
               else
               ZCMsgCallBackInterface.TextMessage('In device not found numbering variable',TMWOHistoryOut);
            end
            else
                ZCMsgCallBackInterface.TextMessage('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Addr.Instance)+'" filtred out',TMWOHistoryOut);
       end;
     ZCMsgCallBackInterface.TextMessage(sysutils.format(rscmNEntitiesProcessed,[count]),TMWOHistoryOut);
     if NumberingParams.SaveStart then
                                      NumberingParams.StartNumber:=index;
     mpd.Destroy;
     Commandmanager.executecommandend;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  SysUnit^.RegisterType(TypeInfo(TST));
  SysUnit^.SetTypeDesk(TypeInfo(TST),['Y-X','X-Y','Unsorted']);
  SysUnit^.RegisterType(TypeInfo(TNumberingParams));
  SysUnit^.SetTypeDesk(TypeInfo(TNumberingParams),['Sorting','Inverse X axis dir','Inverse Y axis dir','Deadband','Start',
                                                   'Increment','Save start number','Base name sorting devices','Number variable']);
  SysUnit^.RegisterType(TypeInfo(PTNumberingParams));

  NumberingParams.BaseName:='??';
  NumberingParams.Increment:=1;
  NumberingParams.StartNumber:=1;
  NumberingParams.SaveStart:=false;
  NumberingParams.DeadDand:=10;
  NumberingParams.NumberVar:='NMO_Suffix';
  NumberingParams.InverseX:=false;
  NumberingParams.InverseY:=true;
  NumberingParams.SortMode:=TST_YX;
  NumberCom.init('NumDevices',CADWG,0);
  NumberCom.SetCommandParam(@NumberingParams,'PTNumberingParams');
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
