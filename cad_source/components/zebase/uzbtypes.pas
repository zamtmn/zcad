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
  uzbGetterSetter,uzbUsable;

const
  GDBBaseObjectID=30000;
  ObjN_NotRecognized='NotRecognized';

type

  TObjID=word;

  GDBaseObject=object
    function ObjToString(const prefix,sufix:string):string;virtual;
    function GetObjType:TObjID;virtual;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
    function GetObjTypeName:string;virtual;
    function GetObjName:string;virtual;
    constructor initnul;
    destructor Done;virtual;{ abstract;}
  end;
  PGDBaseObject=^GDBaseObject;

  TCalculatedString=record
    value:string;
    format:string;
  end;
  PTCalculatedString=^TCalculatedString;

  TZColor=type Longword;
  PTZColor=^TZColor;

  //TGetterSetterString=GGetterSetter<string>;


  TGetterSetterInteger=GGetterSetter<integer>;
  PTGetterSetterInteger=^TGetterSetterInteger;

  TGetterSetterLongWord=GGetterSetter<LongWord>;
  PTGetterSetterLongWord=^TGetterSetterLongWord;


  TGetterSetterBoolean=GGetterSetter<boolean>;
  PTGetterSetterBoolean=^TGetterSetterBoolean;

  TGetterSetterTZColor=GGetterSetter<TZColor>;
  PTGetterSetterTZColor=^TGetterSetterTZColor;

  TUsableInteger=GUsable<Integer>;
  PTUsableInteger=^TUsableInteger;

  TGetterSetterTUsableInteger=GGetterSetter<TUsableInteger>;
  PTGetterSetterTUsableInteger=^TGetterSetterTUsableInteger;

{EXPORT+}

{EXPORT-}

function IsIt(PType,PChecedType:Pointer):Boolean;
function ParentPType(PType:Pointer):Pointer;

{$IFDEF DELPHI}
function StrToQWord(const sh:string):UInt64;
{$ENDIF}
implementation

function GDBaseObject.GetObjType:Word;
begin
     result:=GDBBaseObjectID;
end;
function GDBaseObject.ObjToString(const prefix,sufix:String):String;
begin
     result:=prefix+GetObjTypeName+sufix;
end;
constructor GDBaseObject.initnul;
begin
end;
destructor GDBaseObject.Done;
begin

end;

{procedure GDBaseObject.format;
begin
end;}
procedure GDBaseObject.FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
begin
     //format;
end;
function GDBaseObject.GetObjTypeName:String;
begin
     //pointer(result):=typeof(testobj);
     result:='GDBaseObject';

end;
function GDBaseObject.GetObjName:String;
begin
     //pointer(result):=typeof(testobj);
     result:=GetObjTypeName;

end;
function IsIt(PType,PChecedType:Pointer):Boolean;
type
  vmtRecPtr=^vmtRec;
  vmtRecPtrPtr=^vmtRecPtr;
  vmtRec=packed record
    size,negSize : sizeint;
    parent: {$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
  end;
var
  CurrParent:{$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
begin

  if PType=PChecedType then
    exit(true);
  if PType=nil then
    exit(false);
  CurrParent:=vmtRecPtr(PType)^.parent;
  if CurrParent=nil then
    exit(false);
  {$ifndef VER3_0}
  if CurrParent^=nil then
    exit(false);
  {$endif}
  result:=IsIt({$ifdef VER3_0}CurrParent{$else}CurrParent^{$endif},PChecedType);
end;
function ParentPType(PType:Pointer):Pointer;
type
  vmtRecPtr=^vmtRec;
  vmtRecPtrPtr=^vmtRecPtr;
  vmtRec=packed record
    size,negSize : sizeint;
    parent: {$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
  end;
begin
  if PType=nil then
    exit(nil);
  if vmtRecPtr(PType)^.parent<>nil then
    result:=vmtRecPtr(PType)^.parent{$ifndef VER3_0}^{$endif}
  else
    result:=nil;
end;

{$IFDEF DELPHI}
function StrToQWord(const sh:string):UInt64;
begin
      result:=strtoint(sh);
end;
{$ENDIF}

end.

