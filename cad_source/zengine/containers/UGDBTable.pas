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

unit UGDBTable;
{$INCLUDE def.inc}
interface
uses uzctnrvector,uzctnrvectordata,uzctnrvectorpobjects,uzbtypesbase,uzbtypes,sysutils,uzctnrvectorobjects,
     uzctnrvectorgdbstring;
type
{EXPORT+}
PGDBTableArray=^GDBTableArray;
GDBTableArray={$IFNDEF DELPHI}packed{$ENDIF} object(TZctnrVectorPObects{-}<PGDBGDBStringArray,GDBGDBStringArray>{//})(*OpenArrayOfData=GDBGDBStringArray*)
                    columns,rows:GDBInteger;
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}c,r:GDBInteger);
                    destructor done;virtual;
                    procedure cleareraseobj;virtual;
                    //function copyto(var source:GDBOpenArrayOfData{-}<GDBGDBStringArray>{//}):GDBInteger;virtual;
              end;
{EXPORT-}
implementation
//uses
//    log;
{function GDBTableArray.copyto(source:PGDBOpenArray):GDBInteger; //PGDBOpenArrayOfData
var
  p,np:PGDBGDBStringArray;
  ir:itrec;
begin
  PGDBTableArray(source)^.columns:=columns;
  PGDBTableArray(source)^.rows:=rows;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        pointer(np):=PGDBTableArray(source)^.CreateObject;
        np^.init(p^.Count);
        p^.copyto(np);
        p:=iterate(ir);
  until p=nil;
end;}
procedure GDBTableArray.cleareraseobj;
var
  p:PGDBaseObject;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       PGDBGDBStringArray(p)^.FREEANDdone;
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
destructor GDBTableArray.done;
var p:PGDBGDBStringArray;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        p^.done;
  until p=nil;
  inherited;
end;
constructor GDBTableArray.init;
//var //i,j:gdbinteger;
    //psl:PGDBGDBStringArray;
    //s:gdbstring;
begin
   inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}r{,sizeof(GDBGDBStringArray)});

   {psl:=pointer(CreateObject);
          psl.init(c);
          s:='Пусто';
          psl.add(@s);}

   (*for i := 1 to r do
     begin
          psl:=pointer(CreateObject);
          psl.init(c);
          s:=inttostr(i);
          psl.add(@s);
          //s:='  Манометр электроконтактный показывающий, сигнализи- рующий, верхний предел измерения 10 кгс/см2, радиальный штуцер, исп. 2 разм. конт., вода, класс точности 1.5.'#13#10;
          s:='test';
          psl.add(@s);
          s:='ДМ2010СГ ТУ25-02.180335-84';
          psl.add(@s);
          s:='007';
          psl.add(@s);
          s:='АО "Монотомь" г.Томск';
          psl.add(@s);
          s:='шт.';
          psl.add(@s);
          s:=inttostr(1+random(9));
          psl.add(@s);
          s:=floattostr(((1+random(99))/100));;
          psl.add(@s);
          s:='SP'+inttostr(i);
          psl.add(@s);
     end;*)
end;
begin
end.
