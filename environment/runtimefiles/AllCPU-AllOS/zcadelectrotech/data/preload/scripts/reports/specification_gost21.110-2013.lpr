const
  cMissedGroup=' __cMissedGroup';
  cSectionNodeName='Section';
  cItemsNodeName='Items';

type
  TCounterResultsArray=array of TCounterResults;

  TPartDesc=record
    PartName:string;
    Counter:int32;
  end;
  TPartDescs=record
    stack:array of TPartDesc;
  end;

function TPartDesc.Create(APartName:string;ACounter:int32):TPartDesc;static;
begin
  result.PartName:=APartName;
  result.Counter:=ACounter;
end;

function TPartDescs.Create:TPartDescs;static;
begin
  setlength(result.stack,0);
end;

procedure TPartDescs.Push(APart:TPartDesc);
begin
  setlength(stack,length(stack)+1);
  stack[length(stack)-1]:=APart;
end;

function TPartDescs.Pop:TPartDesc;
begin
  result:=stack[length(stack)-1];
  setlength(stack,length(stack)-1);
end;

function GetGroup(AVars:TVariablesExtender;AGroupVariable:string):string;
var
  pvd_GroupVariable:pvardesk;
begin
  pvd_GroupVariable:=AVars.GetVarDesk(AGroupVariable);
  if pvd_GroupVariable<>nil then
    result:=pvd_GroupVariable.GetValueAsString
  else
    result:=cMissedGroup;
  if result='' then
    result:=cMissedGroup;
end;

function ProcessItems(const AGroups:array of string;ATable:PzeEntity;CounterResults:TCounterResultsArray;AMask:String;var part:TPartDesc;APartCounterPrefix:string):string;
var
  i,j,k:int32;
  names:string;
  GroupIsPlaced:boolean;
begin
  for k:=low(CounterResults) to high(CounterResults) do begin
    GroupIsPlaced:=false;
    for i:=0 to length(CounterResults[k])-1 do
      if not CounterResults[k][i].Processed then
        if MatchesMask(CounterResults[k][i].Group,AMask) then begin
          //_ArraySort(CounterResults[k][i].names);
          if length(CounterResults[k][i].names)>0 then begin
          names:=CounterResults[k][i].names[0];
            for j:=1 to length(CounterResults[k][i].names)-1 do
              names:=names+', '+CounterResults[k][i].names[j];
          end else
            names:='';
          if not GroupIsPlaced then
            zeEntTableAddRow(ATable,['',AGroups[k]],false);
          GroupIsPlaced:=true;
          CounterResults[k][i].Processed:=true;
          inc(part.Counter);
          zeEntTableAddRow(ATable,[APartCounterPrefix+tostring(part.Counter),CounterResults[k][i].NameFull,
            CounterResults[k][i].NameShort+' '+CounterResults[k][i].Standard,CounterResults[k][i].OKP,
            CounterResults[k][i].Manufacturer,CounterResults[k][i].EdIzm,ToString(CounterResults[k][i].Value),
            '',names],false);
          //zcUIHistoryOut(names+'  '+CounterResults[i].Key+'  '+ToString(CounterResults[i].Value));
        end;
  end;
end;

function _ProcessNode(const AGroups:array of string;AXMLNode:PDOMNode;ATable:PzeEntity;CounterResults:TCounterResultsArray;var parts:TPartDescs;APartCounterPrefix:string):string;
var
  NodeCaption,NodeName,NodeMask:string;
  part:TPartDesc;
begin
  if AXMLNode<>nil then begin
  repeat
    NodeName:=AXMLNode.NodeName;
    NodeCaption:=AXMLNode.AttrValue('Caption','Отсутствует');
    part:=TPartDesc.create(NodeCaption,0);
    //zeEntTableAddRow(ATable,['',NodeCaption],false);

    if NodeName=cSectionNodeName then begin
      parts.push(part);
      _ProcessNode(AGroups,AXMLNode.FirstChild,ATable,CounterResults,parts,APartCounterPrefix+'.'+tostring(part.Counter));
      part:=parts.pop;
    end else if NodeName=cItemsNodeName then begin
      NodeMask:=AXMLNode.AttrValue('Mask','');
      if NodeMask<>'' then
        ProcessItems(AGroups,ATable,CounterResults,NodeMask,part,APartCounterPrefix);
    end;

    AXMLNode:=AXMLNode.NextSibling;
    until AXMLNode=nil;
  end;
end;

function ProcessNode(const AGroups:array of string;AXMLNode:PDOMNode;ATable:PzeEntity;CounterResults:TCounterResultsArray):string;
var
  parts:TPartDescs;
begin
  parts:=TPartDescs.Create;
  _ProcessNode(AGroups,AXMLNode,ATable,CounterResults,parts,'num');
end;

var
  EntSourceIncludingVolumeFunction:String;
  EntTypeInclude,EntTypeExclude,EntExtdrInclude,EntExtdrExclude:String;
  CombineVariables,GroupVariable,GroupVariableValues:String;
  fltr:ThEntsTypeFilter;
  ents:ThEnts;
  ent,report:PzeEntity;
  vars,mainvars,reportvars:TVariablesExtender;

  ccs:array of ThCombineCounter;
  i,j,k,groupindex:int32;
  pvd_GroupVariable,pvd_DB_link,pvd_NMO_Name:pvardesk;
  names,DB_link,NMO_Name:string;

  CounterResults:TCounterResultsArray;
  dic:ThDictionary;
  groupdic:ThStringDictionary;
  groups,SplitedCombineVariables:array of string;

  SpecXMLTemplateFile:string;
  XMLTemplate:ThXMLDocument;
  XMLNode:PDOMNode;

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
  reportvars.GetVarValue('RPRTBUILD_CombineVariables',CombineVariables);
  reportvars.GetVarValue('RPRTBUILD_GroupVariable',GroupVariable);
  reportvars.GetVarValue('SpecXMLTemplateFile',SpecXMLTemplateFile,'specification.xml');
  SpecXMLTemplateFile:=FindFileInSupportPaths(SpecXMLTemplateFile);

  zcUIHistoryOut('EntSourceIncludingVolumeFunction='+EntSourceIncludingVolumeFunction);
  zcUIHistoryOut('EntTypeInclude='+EntTypeInclude);
  zcUIHistoryOut('EntTypeExclude='+EntTypeExclude);
  zcUIHistoryOut('EntExtdrInclude='+EntExtdrInclude);
  zcUIHistoryOut('EntExtdrExclude='+EntExtdrExclude);
  zcUIHistoryOut('CombineVariables='+CombineVariables);
  zcUIHistoryOut('GroupVariable='+GroupVariable);
  zcUIHistoryOut('SpecXMLTemplateFile='+SpecXMLTemplateFile);

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

  if GroupVariable<>'' then begin
    groupdic:=ThStringDictionary.create;
    for i:=ents.low to ents.high do begin
      ent:=ents.data(i);
      vars:=ent.GetVariableExtdr;
      groupdic.add(GetGroup(vars,GroupVariable));
    end;
    groups:=groupdic.KeysToArray;
    groupdic.free;
    _ArraySort(groups);
  end else
    groups:=[cMissedGroup];

  if length(groups)>0 then begin
    GroupVariableValues:=groups[0];
    for i:=groups.low+1 to groups.high do
      GroupVariableValues:=GroupVariableValues+', '+groups[i];
    zcUIHistoryOut('GroupVariable values='+GroupVariableValues);
  end else
    zcUIHistoryOut('Error: GroupVariable not found in entities!');

  setlength(ccs,length(groups));
  SplitedCombineVariables:=CombineVariables.split(',');
  for i:=ccs.low to ccs.high do begin
    ccs[i]:=ThCombineCounter.create;
    ccs[i].SetCombineVarNames(SplitedCombineVariables);
  end;
  dic:=ThDictionary.create;

  for i:=ents.low to ents.high do begin
    ent:=ents.data(i);
    vars:=ent.GetVariableExtdr;

    groupindex:=_ArrayIndexOf(GetGroup(vars,GroupVariable),groups);

    pvd_DB_link:=vars.GetVarDesk('DB_link',true);
    if pvd_DB_link<>nil then begin
      DB_link:=pvd_DB_link.GetValueAsString;

      pvd_NMO_Name:=vars.GetVarDesk('NMO_Name');

      ccs[groupindex].CombineAndCount(ent,vars,pvd_NMO_Name,DB_link);
      dic.add(vars);
    end else begin
      mainvars:=vars.GetMainFunction;
      if not dic.contains(mainvars) then begin
        pvd_DB_link:=mainvars.GetVarDesk('DB_link',true);
        if pvd_DB_link<>nil then begin
          DB_link:=pvd_DB_link.GetValueAsString;
          pvd_NMO_Name:=mainvars.GetVarDesk('NMO_Name');
          ccs[groupindex].CombineAndCount(ent,vars,pvd_NMO_Name,DB_link);
          dic.add(vars);
        end;
      end;
    end;
  end;
  dic.free;

  setlength(CounterResults,length(ccs));
  for i:=low(ccs) to high(ccs) do
    ccs[i].SaveTo(CounterResults[i]);

  XMLTemplate:=ThXMLDocument.CreateFromFile(SpecXMLTemplateFile);
  table:=zeEntTable(zeDwgGetTableStyle('Spec'));
  XMLNode:=XMLTemplate.FindNode('Specification');
  if XMLNode<>nil then
    ProcessNode(groups,XMLNode.FirstChild,table,CounterResults);

  zeEntTableAddRow(table,[''],true);

  XMLTemplate.free;
  ents.free;
  for i:=low(ccs) to high(ccs) do
    ccs[i].free;
end.
