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

unit uzeNamedObject;
{$INCLUDE zengineconfig.inc}
interface
uses uzepalette,uzeconsts,usimplegenerics,
     uzedimensionaltypes,sysutils,uzbtypes,uzegeometry,
     gzctnrVectorTypes,uzbstrproc;
type
{EXPORT+}
  PGDBNamedObject=^GDBNamedObject;
  {REGISTEROBJECTTYPE GDBNamedObject}
  GDBNamedObject=object(GDBaseObject)
                       Name:AnsiString;(*saved_to_shd*)(*'Name'*)
                       constructor initnul;
                       constructor init(n:String);
                       destructor Done;virtual;
                       procedure SetName(n:String);
                       function GetName:String;
                       function GetFullName:String;virtual;
                       procedure SetDefaultValues;virtual;
                       procedure IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);virtual;
                 end;
{EXPORT-}
implementation
constructor GDBNamedObject.initnul;
begin
     pointer(name):=nil;
     SetDefaultValues;
end;
constructor GDBNamedObject.Init(n:String);
begin
    initnul;
    SetName(n);
end;
destructor GDBNamedObject.done;
begin
     SetName('');
end;
procedure GDBNamedObject.SetName(n:String);
begin
     name:=n;
end;
function GDBNamedObject.GetName:String;
begin
     result:=name;
end;
function GDBNamedObject.GetFullName:String;
begin
     result:=name;
end;
procedure GDBNamedObject.SetDefaultValues;
begin
end;
procedure GDBNamedObject.IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);
begin
    proc(@self,PCounted,Counter);
end;
begin
end.
