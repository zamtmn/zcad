function rndValue(AMax,AOffs:double):double;
begin
  result:=AMax*random+AOffs;
end;

procedure DoRandomLinesTest(ALinesCount:int32;AMax,AOffs:double);
var
  i:int32;
  p1,p2:TzePoint3d;
  s:string;
begin
  randomize;
  p1.z:=0;
  p2.z:=0;
  for i:=1 to ALinesCount do begin
    if (i and 1) then
      //вариант1
      zeEntLine(rndValue(AMax,AOffs),rndValue(AMax,AOffs),0,rndValue(AMax,AOffs),rndValue(AMax,AOffs),0)
    else begin
      //вариант2
      p1.x:=rndValue(AMax,AOffs);
      p1.y:=rndValue(AMax,AOffs);
      p2.x:=rndValue(AMax,AOffs);
      p2.y:=rndValue(AMax,AOffs);
      zeEntLine(p1,p2);
    end;
  end;
end;

var
  fltr:ThEntsTypeFilter;
  ents:ThEnts;
  ent:PzeEntity;
  vars:TVariablesExtender;
  basename:string;
  i:int32;
begin
  fltr:=ThEntsTypeFilter.create;   
  fltr.AddTypeNames(['Device']);
  //fltr.AddTypeNameMask('*');
  ents:=ThEnts.create;
  GetEntsFromCurrentRoot(ents,fltr);
  fltr.free;
  for i:=ents.low to ents.high do begin
    ent:=ents.data(i);
    vars:=ent.GetVariableExtdr;
    vars.GetVarValue('NMO_Name',basename);
  end;
  ents.free;
  //zeDecEbableRedrawCounter;
  //DoRandomLinesTest(1000,10,0);
end.