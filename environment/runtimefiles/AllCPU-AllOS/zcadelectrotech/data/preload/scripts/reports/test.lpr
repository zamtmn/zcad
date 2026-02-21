var
  EntSourceIncludingVolumeFunction:String;
  EntTypeInclude,EntTypeExclude,EntExtdrInclude,EntExtdrExclude:String;
  CombineVariables:String;
  fltr:ThEntsTypeFilter;
  ents:ThEnts;
  ent,report:PzeEntity;
  vars,mainvars,reportvars:TVariablesExtender;
  cc:ThCombineCounter;
  i,j:int32;
  pvd_DB_link,pvd_NMO_Name:pvardesk;
  names,DB_link,NMO_Name:string;

  CounterResults:TCounterResults;
  dic:ThDictionary;

  table:PzeEntity;
begin
  report:=ThisReport;
  reportvars:=ThisReportVariableExtdr;

  reportvars.GetVarValue('RPRTSRC_EntSourceIncludingVolumeFunction',EntSourceIncludingVolumeFunction);
  reportvars.GetVarValue('RPRTFLTR_EntTypeInclude',EntTypeInclude);
  reportvars.GetVarValue('RPRTFLTR_EntTypeExclude',EntTypeExclude);
  reportvars.GetVarValue('RPRTFLTR_EntExtdrInclude',EntExtdrInclude);
  reportvars.GetVarValue('RPRTFLTR_EntExtdrExclude',EntExtdrExclude);
  reportvars.GetVarValue('RPRTBUILD_CombineVariables',CombineVariables);

  zcUIHistoryOut('EntSourceIncludingVolumeFunction='+EntSourceIncludingVolumeFunction);
  zcUIHistoryOut('EntTypeInclude='+EntTypeInclude);
  zcUIHistoryOut('EntTypeExclude='+EntTypeExclude);
  zcUIHistoryOut('EntExtdrInclude='+EntExtdrInclude);
  zcUIHistoryOut('EntExtdrExclude='+EntExtdrExclude);
  zcUIHistoryOut('CombineVariables='+CombineVariables);

  fltr:=ThEntsTypeFilter.create;   
  fltr.AddTypeNames(EntTypeInclude.split(','));
  fltr.SubTypeNames(EntTypeExclude.split(','));
  fltr.AddExtdrNames(EntExtdrInclude.split(','));
  fltr.SubExtdrNames(EntExtdrExclude.split(','));
  
  ents:=ThEnts.create;
  if EntSourceIncludingVolumeFunction='' then
    GetEntsFromCurrentRoot(ents,fltr)
  else
    GetEntsFromConnectedIncludingVolume(ents,fltr,report,'ENTID_Function',EntSourceIncludingVolumeFunction);
  fltr.free;
  //zcUIHistoryOut('ents.low='+ToString(ents.low));
  //zcUIHistoryOut('ents.high='+ToString(ents.high));

  cc:=ThCombineCounter.create;
  cc.SetCombineVarNames(CombineVariables.split(','));
  dic:=ThDictionary.create;
  for i:=ents.low to ents.high do begin
    ent:=ents.data(i);
    vars:=ent.GetVariableExtdr;
    {if vars.GetVarValue('NMO_Name',NMO_Name) in GVRFounded then
      zcUIHistoryOut(NMO_Name)
    else
      zcUIMessageBox('NMO_Name not found');}
    pvd_DB_link:=vars.GetVarDesk('DB_link',true);
    if pvd_DB_link<>nil then begin
      DB_link:=pvd_DB_link.GetValueAsString;

      pvd_NMO_Name:=vars.GetVarDesk('NMO_Name');

      cc.CombineAndCount(ent,vars,pvd_NMO_Name,DB_link);
      dic.add(vars);
    end else begin
      mainvars:=vars.GetMainFunction;
      if not dic.contains(mainvars) then begin
        pvd_DB_link:=mainvars.GetVarDesk('DB_link',true);
        if pvd_DB_link<>nil then begin
          DB_link:=pvd_DB_link.GetValueAsString;
          pvd_NMO_Name:=mainvars.GetVarDesk('NMO_Name');
          cc.CombineAndCount(ent,vars,pvd_NMO_Name,DB_link);
          dic.add(vars);
        end;
      end;
    end;
  end;
  dic.free;
  cc.SaveTo(CounterResults);
  table:=zeEntTable(zeDwgGetTableStyle('PE'));
  for i:=0 to length(CounterResults)-1 do begin
    //_ArraySort(CounterResults[i].names);
    if length(CounterResults[i].names)>0 then begin
    names:=CounterResults[i].names[0];
      for j:=1 to length(CounterResults[i].names)-1 do
        names:=names+', '+CounterResults[i].names[j];
    end else
      names:='';
    zeEntTableAddRow(table,[names,CounterResults[i].Key,ToString(CounterResults[i].Value),''],false);
    //zcUIHistoryOut(names+'  '+CounterResults[i].Key+'  '+ToString(CounterResults[i].Value));
  end;
  //zeEntLine(0,0,0,100,100,0);
  zeEntTableAddRow(table,[''],true);
  ents.free;
  cc.free;
end.
