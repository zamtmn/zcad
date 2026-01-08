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
uses
  sysutils,uzeTypes;
type
  TNamedObject=class
    private
      fName:String;
    public
      constructor Create(const n:String);
      procedure SetDefaultValues;virtual;

      property Name:String read fName write fName;
  end;

  GDBNamedObject=object(GDBaseObject)
                       Name:AnsiString;(*'Name'*)
                       constructor initnul;
                       constructor init(const n:String);
                       destructor Done;virtual;
                       procedure SetName(const n:String);
                       function GetName:String;
                       function GetFullName:String;virtual;
                       procedure SetDefaultValues;virtual;
                       procedure IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);virtual;
                 end;
  PGDBNamedObject=^GDBNamedObject;

implementation
constructor TNamedObject.Create(const n:String);
begin
  Name:=n;
  SetDefaultValues;
end;

procedure TNamedObject.SetDefaultValues;
begin
end;


constructor GDBNamedObject.initnul;
begin
     pointer(name):=nil;
     SetDefaultValues;
end;
constructor GDBNamedObject.Init(const n:String);
begin
    initnul;
    SetName(n);
end;
destructor GDBNamedObject.done;
begin
     SetName('');
end;
procedure GDBNamedObject.SetName(const n:String);
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
