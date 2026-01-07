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
unit uzbtypes;
{$Mode delphi}
{$ModeSwitch ADVANCEDRECORDS}
{$ModeSwitch typehelpers}

interface

uses
  SysUtils,
  uzbGetterSetter,uzbUsable,Graphics;

const
  GDBBaseObjectID=30000;

type

  TObjID=word;

  GDBaseObject=object
    function ObjToString(const prefix,sufix:string):string;virtual;
    function GetObjType:TObjID;virtual;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
    function GetObjTypeName:string;virtual;
    function GetObjName:string;virtual;
    constructor initnul;
    destructor Done;virtual;
  end;
  PGDBaseObject=^GDBaseObject;

  TUsableInteger=GUsable<integer>;
  PTUsableInteger=^TUsableInteger;

implementation

function GDBaseObject.GetObjType:word;
begin
  Result:=GDBBaseObjectID;
end;

function GDBaseObject.ObjToString(const prefix,sufix:string):string;
begin
  Result:=prefix+GetObjTypeName+sufix;
end;

constructor GDBaseObject.initnul;
begin
end;

destructor GDBaseObject.Done;
begin

end;

procedure GDBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
begin
  //format;
end;

function GDBaseObject.GetObjTypeName:string;
begin
  //pointer(result):=typeof(testobj);
  Result:='GDBaseObject';
end;

function GDBaseObject.GetObjName:string;
begin
  //pointer(result):=typeof(testobj);
  Result:=GetObjTypeName;

end;

end.
