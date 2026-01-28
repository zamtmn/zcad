var
  sa:TStringArray;
  EntTypeInclude,EntTypeExclude,EntExtdrInclude,EntExtdrExclude:String;
  fltr:ThEntsTypeFilter;
  ents:ThEnts;
  ent,report:PzeEntity;
  vars,reportvars:TVariablesExtender;
  basename:string;
  i:int32;
begin
  report:=ThisReport;
  reportvars:=ThisReportVariableExtdr;

  reportvars.GetVarValue('RPRT_EntTypeInclude',EntTypeInclude);
  reportvars.GetVarValue('RPRT_EntTypeExclude',EntTypeExclude);
  reportvars.GetVarValue('RPRT_EntExtdrInclude',EntExtdrInclude);
  reportvars.GetVarValue('RPRT_EntExtdrExclude',EntExtdrExclude);
  zcUIHistoryOut('EntTypeInclude='+EntTypeInclude);
  zcUIHistoryOut('EntTypeExclude='+EntTypeExclude);
  zcUIHistoryOut('EntExtdrInclude='+EntExtdrInclude);
  zcUIHistoryOut('EntExtdrExclude='+EntExtdrExclude);

  fltr:=ThEntsTypeFilter.create;   
  fltr.AddTypeNames(EntTypeInclude.split(','));
  fltr.SubTypeNames(EntTypeExclude.split(','));
  fltr.AddExtdrNames(EntExtdrInclude.split(','));
  fltr.SubExtdrNames(EntExtdrExclude.split(','));
  
  ents:=ThEnts.create;
  GetEntsFromCurrentRoot(ents,fltr);
  fltr.free;
  for i:=ents.low to ents.high do begin
    ent:=ents.data(i);
    vars:=ent.GetVariableExtdr;
    vars.GetVarValue('NMO_Name',basename);
    zcUIHistoryOut(basename);
  end;
  ents.free;
end.