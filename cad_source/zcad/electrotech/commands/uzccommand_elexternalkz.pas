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
unit uzcCommand_ElExternalKZ;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,Math,
  LazUTF8,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzeconsts,
  uzcLog,
  uzCtnrVectorPBaseEntity,UGDBOpenArrayOfPV,UGDBPoint3DArray,
  Varman,
  uzccablemanager,uzcdialogsfiles,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcutils,uzcvariablesutils,
  uzcinterface,
  uzeentity,uzcentcable,uzcentnet,uzeentdevice,uzeentline,uzeblockdef,uzeEntBase,uzeentitiesmanager,
  uzeGeometryTypes,uzeGeometry,
  uzelongprocesssupport,
  uzcEnitiesVariablesExtender,
  uzcbillofmaterial,
  uzcdrawings,uzbPaths,uzcTranslations,UUnitManager,
  CsvDocument;

procedure rootbytrace(firstpoint,lastpoint:TzePoint3d;PTrace:PGDBObjNet;cable:PGDBObjCable;addfirstpoint:boolean);

implementation

procedure AddPolySegmentFromConnIfZnotMatch(const PrevPoint,NextPoint:TzePoint3d;cable:PGDBObjCable);
begin
  if not SameValue(PrevPoint.z,NextPoint.z) then begin
    cable^.AddVertex(TzePoint3d.Make(NextPoint.x,NextPoint.y,PrevPoint.z));
    cable^.AddVertex(NextPoint);
  end else
    cable^.AddVertex(NextPoint);
end;

procedure AddPolySegmentToConnIfZnotMatch(const PrevPoint,NextPoint:TzePoint3d;cable:PGDBObjCable);
begin
  if not SameValue(PrevPoint.z,NextPoint.z) then begin
    cable^.AddVertex(TzePoint3d.Make(PrevPoint.x,PrevPoint.y,NextPoint.z));
    cable^.AddVertex(NextPoint);
  end else
    cable^.AddVertex(NextPoint);
end;

procedure AddPolySegmentIfZnotMatch(const PrevPoint,NextPoint:TzePoint3d;cable:PGDBObjCable);
var
  MidPoint:TzePoint3d;
begin
  if not SameValue(PrevPoint.z,NextPoint.z) then begin
    MidPoint:=PrevPoint.LerpTo(NextPoint,0.5);
    cable^.AddVertex(TzePoint3d.Make(MidPoint.x,MidPoint.y,PrevPoint.z));
    cable^.AddVertex(TzePoint3d.Make(MidPoint.x,MidPoint.y,NextPoint.z));
    cable^.AddVertex(NextPoint);
  end else
    cable^.AddVertex(NextPoint);
end;

procedure rootbytrace(firstpoint,lastpoint:TzePoint3d;PTrace:PGDBObjNet;cable:PGDBObjCable;addfirstpoint:boolean);
var //po:PGDBObjSubordinated;
  //plastw:PzePoint3d;
  tw1,tw2:TzePoint3d;
  l1,l2:pgdbobjline;
  pa:GDBPoint3dArray;
  //prevpoint:TzePoint3d;
  //polydata:tpolydata;
  //domethod,undomethod:tmethod;
begin
  if ptrace<>nil then begin
    pointer(l1):=PTrace.GetNearestLine(firstpoint);
    pointer(l2):=PTrace.GetNearestLine(lastpoint);
    tw1:=NearestPointOnSegment(firstpoint,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
    if l1=l2 then begin
      if addfirstpoint then
        cable^.AddVertex(firstpoint);
      if not tw1.IsEqual(firstpoint,sqreps) then
        AddPolySegmentFromConnIfZnotMatch(firstpoint,tw1,cable);
      tw2:=NearestPointOnSegment(lastpoint,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
      cable^.AddVertex(tw2);
      if not tw2.IsEqual(lastpoint,sqreps) then
        AddPolySegmentToConnIfZnotMatch(tw2,lastpoint,cable);
    end else begin
      tw2:=NearestPointOnSegment(lastpoint,l2.CoordInWCS.lBegin,l2.CoordInWCS.lEnd);
      PTrace.BuildGraf(drawings.GetCurrentDWG^);
      pa.init(100);
      PTrace.graf.FindPath(tw1,tw2,l1,l2,pa);
      if addfirstpoint then
        cable^.AddVertex(firstpoint);
      if not tw1.IsEqual(firstpoint,sqreps) then
        AddPolySegmentFromConnIfZnotMatch(firstpoint,tw1,cable);
      //cable^.AddVertex(tw1);
      pa.copyto(cable.VertexArrayInOCS);
      //firstpoint:=PzePoint3d(cable^.VertexArrayInWCS.getDataMutable(cable^.VertexArrayInWCS.Count-1))^;
      //if not IsPointEqual(tw2,firstpoint) then
      cable^.AddVertex(tw2);
      if not tw2.IsEqual(lastpoint,sqreps) then
        AddPolySegmentToConnIfZnotMatch(tw2,lastpoint,cable);
      //cable^.AddVertex(lastpoint);
      pa.done;
    end;

  end else begin
    if addfirstpoint then
      cable^.AddVertex(firstpoint);
    AddPolySegmentIfZnotMatch(firstpoint,lastpoint,cable);
  end;
end;

function RootByMultiTrace(firstpoint,lastpoint:TzePoint3d;PTrace:PGDBObjNet;cable:PGDBObjCable;addfirstpoint:boolean):TZctnrVectorPGDBaseEntity;
var //po:PGDBObjSubordinated;
  //plastw:PzePoint3d;
  tw1,tw2:TzePoint3d;
  l1,l2:pgdbobjline;
  pa:GDBPoint3dArray;
  pv:PzePoint3d;
  ir:itrec;
  tcable:PGDBObjCable;
  pvd:pvardesk;
  cablecount:integer;
  //polydata:tpolydata;
  //domethod,undomethod:tmethod;
  ptcablevarext,pcablevarext:TVariablesExtender;
begin
  pointer(l1):=PTrace.GetNearestLine(firstpoint);
  pointer(l2):=PTrace.GetNearestLine(lastpoint);
  tw1:=NearestPointOnSegment(firstpoint,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
  Result.init(100);
  if l1=l2 then begin
    if addfirstpoint then
      cable^.AddVertex(firstpoint);
    if not tw1.IsEqual(firstpoint,sqreps) then
      AddPolySegmentFromConnIfZnotMatch(firstpoint,tw1,cable);
    tw2:=NearestPointOnSegment(lastpoint,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
    cable^.AddVertex(tw2);
    if not tw2.IsEqual(lastpoint,sqreps) then
      AddPolySegmentToConnIfZnotMatch(tw2,lastpoint,cable);
  end else begin
    tw2:=NearestPointOnSegment(lastpoint,l2.CoordInWCS.lBegin,l2.CoordInWCS.lEnd);
    PTrace.BuildGraf(drawings.GetCurrentDWG^);
    pa.init(100);
    PTrace.graf.FindPath(tw1,tw2,l1,l2,pa);
    if addfirstpoint then
      cable^.AddVertex(firstpoint);
    if not tw1.IsEqual(firstpoint,sqreps) then
      AddPolySegmentFromConnIfZnotMatch(firstpoint,tw1,cable);

    //pa.copyto(@cable.VertexArrayInOCS);
    tcable:=cable;
    cablecount:=1;
    pv:=pa.beginiterate(ir);
    if pv<>nil then
      repeat
        if pv^.x<>infinity then
          tcable.VertexArrayInOCS.PushBackData(pv^)
        else begin
          tcable:=AllocCable;
          tcable.init(drawings.GetCurrentROOT,nil,0);
          //tcable := Pointer(drawings.GetCurrentROOT.ObjArray.CreateinitObj(GDBCableID,drawings.GetCurrentROOT));
          ptcablevarext:=tcable^.GetExtension<TVariablesExtender>;
          pcablevarext:=cable^.GetExtension<TVariablesExtender>;
          ptcablevarext.entityunit.copyfrom(@pcablevarext.entityunit);
          drawings.standardization(tcable,GDBCableID);
          pvd:=ptcablevarext.entityunit.FindVariable('CABLE_Segment');
          if pvd<>nil then
            PInteger(pvd^.Data.Addr.Instance)^:=PInteger(pvd^.Data.Addr.Instance)^+cablecount;
          Inc(cablecount);
          Result.PushBackData(tcable);
        end;
        pv:=pa.iterate(ir);
      until pv=nil;


    //firstpoint:=PzePoint3d(cable^.VertexArrayInWCS.getDataMutable(cable^.VertexArrayInWCS.Count-1))^;
    //if not IsPointEqual(tw2,firstpoint) then
    tcable^.AddVertex(tw2);
    if not tw2.IsEqual(lastpoint,sqreps) then
      AddPolySegmentToConnIfZnotMatch(tw2,lastpoint,tcable);
    pa.done;
  end;
end;


function findconnector(CurrentObj:PGDBObjDevice):PGDBObjDevice;
var
  CurrentSubObj:PGDBObjDevice;
  {ir_inGDB,ir_inVertexArray,ir_inNodeArray,}ir_inDevice:itrec;
begin
  Result:=nil;
  CurrentSubObj:=CurrentObj^.VarObjArray.beginiterate(ir_inDevice);
  if (CurrentSubObj<>nil) then
    repeat
      if (CurrentSubObj^.GetObjType=GDBDeviceID) then begin
        if CurrentSubObj^.BlockDesc.BType=BT_Connector then begin
          Result:=CurrentSubObj;
          exit;
        end;
      end;
      CurrentSubObj:=CurrentObj^.VarObjArray.iterate(ir_inDevice);
    until CurrentSubObj=nil;
end;

function CreateCable(Name,mater:string):PGDBObjCable;
var
  //vd,pvn,pvn2: pvardesk;
  pvd{,pvd2}:pvardesk;
  pentvarext:TVariablesExtender;
begin
  Result:=AllocCable;
  Result.init(drawings.GetCurrentROOT,nil,0);
  //result := Pointer(drawings.GetCurrentROOT.ObjArray.CreateInitObj(GDBCableID,drawings.GetCurrentROOT));
  pentvarext:=Result^.GetExtension<TVariablesExtender>;
  pentvarext.entityunit.copyfrom(units.findunit(GetSupportPaths,InterfaceTranslate,'cable'));
  pvd:=pentvarext.entityunit.FindVariable('NMO_Suffix');
  pstring(pvd^.Data.Addr.Instance)^:='';
  pvd:=pentvarext.entityunit.FindVariable('NMO_Prefix');
  pstring(pvd^.Data.Addr.Instance)^:='';
  pvd:=pentvarext.entityunit.FindVariable('NMO_BaseName');
  pstring(pvd^.Data.Addr.Instance)^:='';
  pvd:=pentvarext.entityunit.FindVariable('NMO_Template');
  pstring(pvd^.Data.Addr.Instance)^:='';
  pvd:=pentvarext.entityunit.FindVariable('NMO_Name');
  pstring(pvd^.Data.Addr.Instance)^:=Name;
  pvd:=pentvarext.entityunit.FindVariable('DB_link');
  pstring(pvd^.Data.Addr.Instance)^:=mater;

  pvd:=pentvarext.entityunit.FindVariable('CABLE_AutoGen');
  pBoolean(pvd^.Data.Addr.Instance)^:=True;
  zcSetEntPropFromCurrentDrawingProp(Result);
  drawings.standardization(Result,GDBCableID);
end;


function _El_ExternalKZ_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  FDoc:TCSVDocument;
  isload:boolean;
  s:string;
  row,col:integer;
  startdev,enddev,riser,riser2:PGDBObjDevice;
  supernet,net,net2:PGDBObjNet;
  cable:PGDBObjCable;
  pvd,pvd2:pvardesk;
  netarray,riserarray,linesarray:TZctnrVectorPGDBaseEntity;
  processednets:TZctnrVectorPGDBaseEntity;
  segments:TZctnrVectorPGDBaseEntity;

  ir_net,ir_net2,ir_riser,ir_riser2:itrec;
  nline,new_line:pgdbobjline;
  np:TzePoint3d;
  vd,pvn,pvn2:pvardesk;
  supernetsarray:GDBObjOpenArrayOfPV;
  DC:TDrawContext;
  priservarext,priser2varext,psupernetvarext,pnetvarext,plinevarext:TVariablesExtender;
  lph:TLPSHandle;
  entarray:TZctnrVectorPGDBaseEntity;

  procedure GetStartEndPin(startdevname,enddevname:string);
  begin
    startdev:=nil;
    enddev:=nil;

    entarray.Clear;
    drawings.FindMultiEntityByVar(GDBDeviceID,'NMO_Name',startdevname,entarray);
    if entarray.Count>0 then begin
      PGDBObjEntity(startdev):=FindEntityByVarInArray(GDBDeviceID,'ENTID_Representation','GraphSymbol~onPlan',entarray,True);
      if startdev=nil then
        pointer(startdev):=entarray.getData(0);
    end;

    entarray.Clear;
    drawings.FindMultiEntityByVar(GDBDeviceID,'NMO_Name',enddevname,entarray);
    if entarray.Count>0 then begin
      PGDBObjEntity(enddev):=FindEntityByVarInArray(GDBDeviceID,'ENTID_Representation','GraphSymbol~onPlan',entarray,True);
      if enddev=nil then
        pointer(enddev):=entarray.getData(0);
    end;

    if startdev=nil then
      zcUI.TextMessage(format('In row %d startdevice "%s" not found',[row,startdevname]),TMWOHistoryOut)
    else begin
      startdev:=findconnector(startdev);
      if startdev=nil then
        zcUI.TextMessage(format('In row %d startdevice "%s" connector not found',[row,startdevname]),TMWOHistoryOut);
    end;
    if enddev=nil then
      zcUI.TextMessage(format('In row %d enddevice "%s" not found',[row,enddevname]),TMWOHistoryOut)
    else begin
      enddev:=findconnector(enddev);
      if enddev=nil then
        zcUI.TextMessage(format('In row %d enddevice "%s" connector not found',[row,enddevname]),TMWOHistoryOut);

    end;
  end;

  procedure LinkRisersToNets;
  begin
    drawings.FindMultiEntityByVar2(GDBDeviceID,'RiserName',riserarray);
    supernet:=nil;
    net:=netarray.beginiterate(ir_net);
    if (net<>nil) then
      repeat
        net.riserarray.Clear;
        riser:=riserarray.beginiterate(ir_riser);
        if (riser<>nil) then
          repeat
            pointer(nline):=net.GetNearestLine(riser.P_insert_in_WCS);
            np:=NearestPointOnSegment(riser.P_insert_in_WCS,nline.CoordInWCS.lBegin,nline.CoordInWCS.lEnd);
            if np.IsEqual(riser.P_insert_in_WCS,sqreps) then begin
              net.riserarray.PushBackData(riser);
            end;
            riser:=riserarray.iterate(ir_riser);
          until riser=nil;
        net:=netarray.iterate(ir_net);
      until net=nil;
  end;

begin
  linesarray.init(10);
  entarray.init(10);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if length(operands)=0 then begin
    isload:=OpenFileDialog(s,'csv',CSVFileFilter,'','Открыть журнал...');
    if not isload then begin
      Result:=cmd_cancel;
      exit;
    end else begin

    end;

  end else begin
    begin
      s:=FindInPaths(GetSupportPaths,operands);
    end;
  end;
  isload:=FileExists(utf8tosys(s));
  if isload then begin
    processednets.init(100);
    supernetsarray.init(100);
    FDoc:=TCSVDocument.Create;
    FDoc.Delimiter:=';';
    FDoc.LoadFromFile(utf8tosys(s));
    lph:=lps.StartLongProcess('Create cables',nil,FDoc.RowCount);
    netarray.init(100);
    for row:=0 to FDoc.RowCount-1 do begin
      if FDoc.ColCount[row]>4 then begin
        netarray.Clear;
        drawings.FindMultiEntityByVar(GDBNetID,'NMO_Name',FDoc.Cells[3,row],netarray);

        GetStartEndPin(FDoc.Cells[1,row],FDoc.Cells[2,row]);
        if (startdev<>nil)and(enddev<>nil) then
          if netarray.Count=1 then begin
            PGDBObjBaseEntity(net):=netarray.getDataMutable(0);
            if net=nil then
              zcUI.TextMessage(format('In row %d trace "%s" not found',[row,FDoc.Cells[3,row]]),TMWOHistoryOut);
            if (net<>nil) then begin
              if (startdev<>nil)and(enddev<>nil) then begin
                cable:=CreateCable(FDoc.Cells[0,row],FDoc.Cells[4,row]);
                rootbytrace(startdev.P_insert_in_WCS,enddev.P_insert_in_WCS,net,Cable,True);
                zcAddEntToCurrentDrawingWithUndo(Cable);
                Cable^.Formatentity(drawings.GetCurrentDWG^,dc);
              end;

            end;
          end else begin
            if netarray.Count>1 then begin
              supernet:=PGDBObjNet(FindEntityByVar(supernetsarray,GDBNetID,'NMO_Name',FDoc.Cells[3,row]));

              if supernet=nil then begin
                riserarray.init(100);
                drawings.FindMultiEntityByVar2(GDBDeviceID,'RiserName',riserarray);

                LinkRisersToNets;
                processednets.Clear;
                net:=netarray.beginiterate(ir_net);
                if (net<>nil) then
                  repeat
                    pnetvarext:=net^.GetExtension<TVariablesExtender>;
                    net2:=netarray.beginiterate(ir_net2);

                    if (net2<>nil) then
                      repeat
                        if net<>net2 then begin
                          riser:=net.riserarray.beginiterate(ir_riser);
                          if (riser<>nil) then
                            repeat
                              priservarext:=riser^.GetExtension<TVariablesExtender>;
                              riser2:=net2.riserarray.beginiterate(ir_riser2);
                              if (riser2<>nil) then
                                repeat
                                  if not riser2.P_insert_in_WCS.IsEqual(riser.P_insert_in_WCS,bigeps) then begin
                                    priser2varext:=riser2^.GetExtension<TVariablesExtender>;
                                    pvd:=priservarext.entityunit.FindVariable('RiserName');
                                    pvd2:=priser2varext.entityunit.FindVariable('RiserName');
                                    if (pvd<>nil)and(pvd2<>nil) then begin
                                      if pstring(pvd^.Data.Addr.Instance)^=pstring(pvd2^.Data.Addr.Instance)^ then begin
                                        if supernet=nil then begin
                                          Getmem(supernet,sizeof(GDBObjNet));
                                          supernet.initnul(nil);
                                          psupernetvarext:=supernet.GetExtension<TVariablesExtender>;
                                          psupernetvarext.entityunit.copyfrom(@pnetvarext.entityunit);
                                        end;
                                        if not processednets.IsDataExist(net)<>-1 then begin
                                          net.objarray.copyto(supernet.ObjArray);
                                          processednets.PushBackData(net);
                                        end;

                                        if not processednets.IsDataExist(net2)<>-1 then begin
                                          net2.objarray.copyto(supernet.ObjArray);
                                          processednets.PushBackData(net2);
                                        end;

                                        New_line:=
                                          PGDBObjLine(ENTF_CreateLine(drawings.GetCurrentROOT,nil,
                                          drawings.GetCurrentDWG^.GetCurrentLayer,
                                          drawings.GetCurrentDWG^.GetCurrentLType,LnWtByLayer,ClByLayer,
                                          riser.P_insert_in_WCS,riser2.P_insert_in_WCS));
                                        zcSetEntPropFromCurrentDrawingProp(New_line);
                                        plinevarext:=New_line^.GetExtension<TVariablesExtender>;
                                        if plinevarext=nil then
                                          plinevarext:=AddVariablesToEntity(New_line);
                                        plinevarext.entityunit.copyfrom(
                                          units.findunit(GetSupportPaths,InterfaceTranslate,'_riserlink'));
                                        vd:=plinevarext.entityunit.FindVariable('LengthOverrider');

                                        pvn:=FindVariableInEnt(riser,'Elevation');
                                        pvn2:=FindVariableInEnt(riser,'Elevation');
                                        if (pvn<>nil)and(pvn2<>nil)and(vd<>nil) then begin
                                          pDouble(vd^.Data.Addr.Instance)^:=
                                            abs(pDouble(pvn^.Data.Addr.Instance)^-pDouble(pvn2^.Data.Addr.Instance)^);
                                        end;
                                        New_line^.Formatentity(drawings.GetCurrentDWG^,dc);
                                        supernet^.ObjArray.AddPEntity(New_line^);
                                        linesarray.PushBackData(New_line);
                                      end;
                                    end;
                                  end;

                                  riser2:=net2.riserarray.iterate(ir_riser2);
                                until riser2=nil;


                              riser:=net.riserarray.iterate(ir_riser);
                            until riser=nil;

                        end;
                        net2:=netarray.iterate(ir_net2);
                      until net2=nil;

                    net:=netarray.iterate(ir_net);
                  until (net=nil);
                riserarray.Clear;
                riserarray.Done;
                if supernet<>nil then
                  supernetsarray.PushBackData(supernet);
              end;

              if supernet<>nil then begin
                cable:=CreateCable(FDoc.Cells[0,row],FDoc.Cells[4,row]);

                segments:=rootbymultitrace(startdev.P_insert_in_WCS,enddev.P_insert_in_WCS,supernet,Cable,True);
                zcAddEntToCurrentDrawingWithUndo(Cable);
                zcSetEntPropFromCurrentDrawingProp(Cable);
                drawings.standardization(Cable,GDBCableID);
                Cable^.Formatentity(drawings.GetCurrentDWG^,dc);

                cable:=segments.beginiterate(ir_net);
                if (cable<>nil) then
                  repeat
                    zcAddEntToCurrentDrawingWithUndo(Cable);
                    zcSetEntPropFromCurrentDrawingProp(Cable);
                    drawings.standardization(Cable,GDBCableID);
                    Cable^.Formatentity(drawings.GetCurrentDWG^,dc);

                    cable:=segments.iterate(ir_net);
                  until cable=nil;
                segments.Clear;
                segments.done;
              end else
                zcUI.TextMessage(format('In row %d several unlinced traces "%s" found',[row,FDoc.Cells[3,row]]),TMWOHistoryOut);
            end else begin
              if uppercase(FDoc.Cells[3,row])='DIRECTLY' then begin
                cable:=CreateCable(FDoc.Cells[0,row],FDoc.Cells[4,row]);
                rootbytrace(startdev.P_insert_in_WCS,enddev.P_insert_in_WCS,nil,Cable,True);
                zcAddEntToCurrentDrawingWithUndo(Cable);
                Cable^.Formatentity(drawings.GetCurrentDWG^,dc);
              end else
                zcUI.TextMessage(format('In row %d trace "%s" not found in drawing',[row,FDoc.Cells[3,row]]),TMWOHistoryOut);
            end;
          end;

      end else begin
        zcUI.TextMessage(format('In row %d too few parameters',[row]),TMWOHistoryOut);
        for col:=0 to FDoc.ColCount[row] do
          zcUI.TextMessage(FDoc.Cells[col,row],TMWOHistoryOut);
      end;
      lps.ProgressLongProcess(lph,row);
    end;
    netarray.Clear;
    netarray.Done;

    FDoc.Destroy;
    processednets.Clear;
    processednets.Done;

    net:=supernetsarray.beginiterate(ir_net);
    if (net<>nil) then
      repeat
        net.objarray.Clear;
        net.riserarray.Clear;
        net:=supernetsarray.iterate(ir_net);
      until net=nil;
    supernetsarray.done;
    linesarray.done;
    entarray.Clear;
    entarray.done;


    lps.EndLongProcess(lph);
  end else
    zcUI.TextMessage(format('GDBCommandsElectrical.El_ExternalKZ: can''t open file: "%s"("%s")',[s,Operands]),TMWOShowError);
end;


initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@_El_ExternalKZ_com,'El_ExternalKZ',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
