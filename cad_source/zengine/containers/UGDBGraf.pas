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

unit UGDBGraf;
{$INCLUDE zengineconfig.inc}
interface
uses varman,uzedrawingdef,uzsbVarmanDef,UGDBPoint3DArray,gzctnrVector,
     uzegeometrytypes,sysutils,uzegeometry,uzeentity,UGDBOpenArrayOfPV,
     gzctnrVectorTypes,uzcenitiesvariablesextender,uzeentline,math;
type

PTLinkType=^TLinkType;
TLinkType=(LT_Normal,LT_OnlyLink);
pgrafelement=^grafelement;
grafelement= object
                  linkcount:Integer;
                  point:TzePoint3d;
                  link:GDBObjOpenArrayOfPV;
                  workedlink:PGDBObjEntity;
                  connected:Integer;
                  step:Integer;
                  pathlength:Double;

                  constructor initnul;
                  constructor init(const v:TzePoint3d);
                  procedure addline(pv:pgdbobjEntity);
                  function IsConnectedTo(node:pgrafelement):pgdbobjEntity;
            end;
GDBGraf= object(GZVector<grafelement>)
                constructor init(m:Integer);
                function addge(const v:TzePoint3d):pgrafelement;
                procedure clear;virtual;
                function minimalize(var drawing:TDrawingDef):Boolean;
                function divide:Boolean;
                procedure done;virtual;
                procedure freeelement(PItem:PT);virtual;

                procedure BeginFindPath;
                procedure FindPath(point1,point2:TzePoint3d;l1,l2:pgdbobjEntity;var pa:GDBPoint3dArray);
             end;

function getlinktype(pv:PGDBObjEntity):TLinktype;
implementation
procedure GDBGraf.BeginFindPath;
var
  pgfe: pgrafelement;
  ir:itrec;
begin
  pgfe:=beginiterate(ir);
  if pgfe<>nil then
  repeat
        pgfe^.step:=0;
        pgfe^.pathlength:=+infinity;
        pgfe^.workedlink:=nil;

        pgfe:=iterate(ir);
  until pgfe=nil;
end;
function getlinktype(pv:PGDBObjEntity):TLinktype;
var
    pvd:pvardesk;
    pentvarext:TVariablesExtender;
begin
  pentvarext:=pv^.GetExtension<TVariablesExtender>;
  if pentvarext<>nil then
  begin
     pvd:=pentvarext.entityunit.FindVariable('LinkType');
     if pvd=nil then
                    result:=LT_Normal
                else
                    result:=PTLinkType(pvd.data.Addr.Instance)^;
  end
  else
      result:=LT_Normal;
end;
function getlinklength(pv:PGDBObjLine):Double;
var
    pvd:pvardesk;
    pentvarext:TVariablesExtender;
begin
     pentvarext:=pv^.GetExtension<TVariablesExtender>;
     if pentvarext<>nil then
     begin
     pvd:=pentvarext.entityunit.FindVariable('LengthOverrider');
     if pvd=nil then
                    result:=Vertexlength(pv^.CoordInWCS.lbegin,pv^.CoordInWCS.lend)
                else
                    result:=PDouble(pvd.data.Addr.Instance)^;
     end
        else
            result:=Vertexlength(pv^.CoordInWCS.lbegin,pv^.CoordInWCS.lend);
end;
procedure GDBGraf.FindPath;
var
  pgfe,pgfe2,pgfe3: pgrafelement;
  ir,ir2,ir3:itrec;
  step,oldstep:Integer;
  isend:Boolean;
  pl:pgdbobjEntity;
  npath,npathmin,linklength:Double;
  linkline,mainlinkline:pgdbobjEntity;
begin

     BeginFindPath;

  step:=1;
  pgfe:=beginiterate(ir);
  if pgfe<>nil then
  repeat
        if pgfe^.link.IsDataExistWithCompareProc(l1,EqualFuncPGDBaseEntity)<>-1 then
        begin
             pgfe^.step:=step;
             pgfe^.pathlength:=Vertexlength(point1,pgfe^.point);
        end;
        pgfe:=iterate(ir);
  until pgfe=nil;

  repeat
  isend:=true;
  oldstep:=step;
  inc(step);
  pgfe:=beginiterate(ir);
  if pgfe<>nil then
  repeat
        if pgfe^.step=oldstep then
        begin
              pl:=pgfe^.link.beginiterate(ir2);
              if pl<>nil then
              repeat
                    linklength:=getlinklength(pointer(pl));
                    pgfe2:=beginiterate(ir3);
                    if pgfe2<>nil then
                    repeat
                          if (pgfe<>pgfe2)and(pgfe2^.link.IsDataExistWithCompareProc(pl,EqualFuncPGDBaseEntity)<>-1) then
                          begin
                          npath:=pgfe^.pathlength+{Vertexlength(pgfe^.point,pgfe2^.point)}linklength;
                          if {(pgfe2.step=0)or}(pgfe2.pathlength>npath) then
                                              begin
                                                   pgfe2^.step:=step;
                                                   pgfe2^.pathlength:=npath;
                                                   pgfe2^.workedlink:=pl;
                                                   isend:=false;
                                              end;
                          end;
                          pgfe2:=iterate(ir3);
                    until pgfe2=nil;

                    pl:=pgfe^.link.iterate(ir2);
              until pl=nil;
        end;
        pgfe:=iterate(ir);
  until pgfe=nil;
  until isend;

  npathmin:=Infinity;
  pgfe2:=nil;{-----------}
  pgfe:=beginiterate(ir);
  if pgfe<>nil then
  repeat
        if pgfe^.link.IsDataExistWithCompareProc(l2,EqualFuncPGDBaseEntity)<>-1 then
        begin
             npath:=pgfe^.pathlength+Vertexlength(pgfe^.point,point2);
             if npath<=npathmin then
             begin
                  pgfe2:=pgfe;
                  step:=pgfe^.step;
                  npathmin:=npath;
             end;
        end;
        pgfe:=iterate(ir);
  until pgfe=nil;
  if pgfe2<>nil then
  pa.PushBackData(pgfe2.point);
  dec(step);
  pgfe3:=pgfe2;
  while step>0 do
  begin
        //npathmin:=Infinity;
        pgfe:=beginiterate(ir);
        if pgfe<>nil then
        repeat
        if pgfe^.step=step then
        begin
             linkline:=pgfe^.IsConnectedTo(pgfe2);
             if linkline<>nil then
             begin
                  linklength:=getlinklength(pointer(linkline));
             npath:=pgfe^.pathlength+{Vertexlength(pgfe2^.point,pgfe^.point)}linklength;
             if {npathmin>npath}abs(npath-pgfe2^.pathlength)<eps then
             begin
                  //npathmin:=pgfe^.pathlength;
                  pgfe3:=pgfe;
                  mainlinkline:=linkline;
             end;
             end;
        end;
        pgfe:=iterate(ir);
        until pgfe=nil;
        dec(step);
        pgfe2:=pgfe3;
        if getlinktype(mainlinkline)=LT_OnlyLink then
        begin
             pa.PushBackData(InfinityVertex);
        end;
        pa.PushBackData(pgfe2.point);
  end;

  pa.Invert;
end;
function grafelement.IsConnectedTo;
var
  line: pgdbobjEntity;
  ir:itrec;
begin
  line:=link.beginiterate(ir);
  if line<>nil then
  repeat
        if node^.link.IsDataExistWithCompareProc(line,EqualFuncPGDBaseEntity)<>-1 then
                                          begin
                                               result:=line;
                                               exit;
                                          end;
        line:=link.iterate(ir);
  until line=nil;
  result:=nil;
end;
procedure grafelement.addline;
begin
     inc(linkcount);
     link.PushBackData(pv);
end;
constructor grafelement.initnul;
begin
     point:=nulvertex;
     link.init(100);
     linkcount:=0;
     connected:=0;
end;
constructor grafelement.init(const v:TzePoint3d);
begin
     point:=v;
     link.init(100);
     link.CreateArray;
     linkcount:=0;
     connected:=0;
end;
procedure GDBGraf.freeelement;
begin
  pgrafelement(PItem).link.Clear;
  pgrafelement(PItem).link.done;
  //pgrafelement(p).
  //Freemem(PGDBFontRecord(p).Pfont);
end;
constructor GDBGraf.init;
begin
  inherited init(m);
end;
function GDBGraf.minimalize;
var
  i{,j}: Integer;
  tgf: pgrafelement;
  l1,l2:pgdbobjline;
begin
  result:=false;
  if count = 0 then exit;
  for i := 0 to count - 1 do
  begin
       tgf:=pgrafelement(self.getDataMutable(i));
       if tgf^.linkcount=2 then
       begin
              //j:=0;
              //repeat
              l1:=pointer(tgf^.link.getDataMutable({j}0));
              if l1<>nil then
                             l1:=pgdbobjline(ppointer(l1));
              //inc(j);
              //until l1<>nil;
              //repeat
              l2:=pointer(tgf^.link.getDataMutable({j}1));
              if l2<>nil then
                             l2:=pgdbobjline(ppointer(l2));
              //inc(j);
              //until l2<>nil;

              if (l1<>nil)and(l2<>nil) then
              result:=l1^.jointoline(l2,drawing);
              if result then system.break;
       end;
  end;
end;
procedure GDBGraf.done;
begin
     //clear;
     inherited done;
end;
function GDBGraf.divide;
function marknearelement(pgf:pgrafelement):Boolean;
var i,j,k: Integer;
    tgf: pgrafelement;
    l1,l2:pgdbobjline;
    l1addr,l2addr:Pointer;
begin
  result:=false;
  for i := 0 to count - 1 do
  begin
       tgf:=pgrafelement(self.getDataMutable(i));
       if tgf<>pgf then
       begin
            for j:=0 to pgf^.link.Count-1 do
            begin
                 l1addr:=pointer(pgf^.link.getDataMutable(j));
                 l1:=pgdbobjline(l1addr);
                 if l1<>nil then
                 for k:=0 to tgf^.link.Count-1 do
                 begin
                      l2addr:=pointer(tgf^.link.getDataMutable(k));
                      l2:=pgdbobjline(l2addr);
                      if l2<>nil then
                      if l1=l2 then
                      begin
                           inc(pgf^.connected);
                           inc(tgf^.connected);
                           l1addr:=nil;
                           l2addr:=nil;
                           result:=true;
                      end;
                 end;
            end;
       end;
  end;
end;
var
  i{,j}: Integer;
  tgf: pgrafelement;
//  l1,l2:pgdbobjline;
  q:Boolean;
  ir:itrec;
begin
  result:=false;
  if count = 0 then exit;
  tgf:=pgrafelement(self.getDataMutable(0));
  marknearelement(tgf);
  repeat
  q:=false;
  tgf:=beginiterate(ir);
  //for i := 0 to count - 1 do
  if tgf<>nil then
  //begin
  repeat
       //tgf:=pgrafelement(self.getDataMutable(i));
       if (tgf^.connected>0)and(tgf^.connected<tgf^.linkcount) then
       q:=q or marknearelement(tgf);
       tgf:=iterate(ir);
  until tgf=nil;
  //end;
  until not q;
  //q:=false;
  for i := 0 to count - 1 do
  begin
       tgf:=pgrafelement(self.getDataMutable(i));
       if tgf^.connected=0 then
       begin
            result:=true;
            exit;
       end;
  end;
end;
function GDBGraf.addge;
var
  i: Integer;
  tgf: pgrafelement;
begin
  if count = 0 then
  begin
    if parray=nil then
                      createarray;
    pgrafelement(Parray)^.init(v);
    inc(count);
    result:=GetParrayAsPointer;
  end
  else
  begin
    for i := 0 to count - 1 do
    begin
      tgf:=pgrafelement(self.getDataMutable(i));
      if vertexeq(tgf^.point,v) then
        begin
             result:=tgf;
             system.exit;
        end;
    end;
    //if i = count then
    begin
      inc(count);
      tgf:=pgrafelement(self.getDataMutable(count-1));
      tgf^.init(v);
      result:=tgf;

    end;
  end;
end;
procedure GDBGraf.clear;
//var
//  i: Integer;
//  tgf: pgrafelement;
begin
  {if count = 0 then exit;
  begin
    for i := 0 to count - 1 do
    begin
      tgf:=pgrafelement(self.getDataMutable(i));
      tgf^.point:=nulvertex;
      tgf^.link.Count:=0;
      tgf^.linkcount:=0;
      tgf^.connected:=0;
    end;
  end;}
  count:=0;
end;
begin
end.
