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

unit UGDBObjBlockdefArray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
{$PointerMath ON}
interface
uses
  uzgldrawcontext,uzedrawingdef,uzbstrproc,uzeblockdef, gzctnrVectorObjects,
  gzctnrVectorTypes,sysutils,uzbtypes,uzegeometry,uzbLogIntf,Strings,uzeTypes;
type
{Export+}
{REGISTEROBJECTTYPE GDBObjBlockdefArray}
PGDBObjBlockdefArray=^GDBObjBlockdefArray;
PBlockdefArray=^BlockdefArray;
BlockdefArray=packed array [0..0] of GDBObjBlockdef;
GDBObjBlockdefArray= object(GZVectorObjects{-}<GDBObjBlockdef>{//})
                      constructor init(m:Integer);
                      constructor initnul;

                      function getindex(const name:String):Integer;virtual;
                      function getblockdef(const name:String):PGDBObjBlockdef;virtual;
                      //function loadblock(filename,bname:pansichar;pdrawing:Pointer):Integer;virtual;
                      function create(const name:String):PGDBObjBlockdef;virtual;
                      procedure freeelement(PItem:PT);virtual;
                      procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                      procedure Grow(newmax:Integer=0);virtual;
                      procedure IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);virtual;
                    end;
{Export-}
implementation
//uses log;
procedure GDBObjBlockdefArray.IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);
var p:PGDBObjBlockdef;
    ir:itrec;
begin
    inherited;
    p:=beginiterate(ir);
    if p<>nil then
    repeat
         p^.IterateCounter(PCounted,Counter,proc);
    p:=iterate(ir);
    until p=nil;
end;
procedure GDBObjBlockdefArray.Grow;
var
  p:PGDBObjBlockdef;
      ir:itrec;
begin
  inherited;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.correctobjects(nil,0);
       p:=iterate(ir);
  until p=nil;
end;

procedure GDBObjBlockdefArray.freeelement;
begin
  PGDBObjBlockdef(PItem).done;
  //PGDBObjBlockdef(p).ObjArray.FreeAndDone;
end;
constructor GDBObjBlockdefArray.init;
begin
     inherited init(m);
end;
constructor GDBObjBlockdefArray.initnul;
begin
     inherited initnul;
     //size:=sizeof(GDBObjBlockdef);
end;
function GDBObjBlockdefArray.create;
begin
  if parray=nil then createarray;
  if count = max then
                     //exit;
                     grow;
  result := @PGDBObjBlockdef(parray)[count];
  result.init(name);
  inc(count);
end;
function GDBObjBlockdefArray.getindex;
var
   i:Integer;
   name_: String;
begin
  for i:=0 to count-1 do
  begin
    name_:=PGDBObjBlockdef(parray)[i].Name;
    if (Length(name_)=Length(name)) and (StrLIComp(@name_[1], @name[1], Length(name))=0) then
      exit(i);
  end;
  result:=-1;
end;
procedure GDBObjBlockdefArray.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
var
  p:PGDBObjBlockdef;
      ir:itrec;
begin
  //programlog.LogOutStr('GDBObjBlockdefArray.FormatEntity;',lp_IncPos,LM_Debug);
  zDebugLn('{D+}GDBObjBlockdefArray.FormatEntity;');
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       if Tria_Utf8ToAnsi(p^.Name)='*D234' then
                            p^.Name:=p^.Name;
       zTraceLn('{D+}Formatting blockdef name="%s"',[p^.Name]);

       //programlog.LogOutFormatStr('Formatting blockdef name="%s"',[p^.Name],lp_IncPos,LM_Debug);
       p^.FormatEntity(drawing,dc);
       zTraceLn('{D-}end;{Formatting}');

       //programlog.LogOutStr('end;{Formatting}',lp_DecPos,LM_Debug);
       p:=iterate(ir);
  until p=nil;
  zDebugLn('{D-}end;{GDBObjBlockdefArray.FormatEntity;}');
  //programlog.LogOutStr('end;{GDBObjBlockdefArray.FormatEntity;}',lp_DecPos,LM_Debug);
end;
function GDBObjBlockdefArray.getblockdef;
var
  p:PGDBObjBlockdef;
      ir:itrec;
  name_: String;
begin
  result:=nil;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       name_:=p^.Name;
       if (Length(name_)=Length(name)) and (StrLIComp(@name_[1], @name[1], Length(name))=0) then
                                           begin
                                                result := p;
                                                exit;
                                           end;
       p:=iterate(ir);
  until p=nil;
end;
{function GDBObjBlockdefArray.loadblock;
var bc:Integer;
begin
  bc := count;
  inc(count);
  PBlockdefArray(parray)[bc].init(extractfilename(bname));
  addfromdxf(filename,@PBlockdefArray(parray)[bc],tlomerge,PTSimpleDrawing(pdrawing)^);
end;}
begin
end.
