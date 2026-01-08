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
unit uzbBaseUtils;
{$mode delphi}

interface

uses
  SysUtils;

type
  PTypeOf=Pointer;

function IsObjectIt(APCheckedObject,APCheckedType:PTypeOf):boolean;
function ParentObjectPType(const APType:PTypeOf):PTypeOf;

implementation

type
  TObjectVMTRec=packed record
  type
    vmtRecPtr=^TObjectVMTRec;
    vmtRecPtrPtr=^vmtRecPtr;
  var
    size,negSize:sizeint;
    parent: {$ifdef VER3_0}vmtRecPtr{$else}vmtRecPtrPtr{$endif};
  end;

function IsObjectIt(APCheckedObject,APCheckedType:PTypeOf):boolean;
var
  CurrParent:{$ifdef VER3_0}vmtRec.vmtRecPtr{$else}TObjectVMTRec.vmtRecPtrPtr{$endif};
begin
  if APCheckedObject=APCheckedType then
    exit(True);
  if APCheckedObject=nil then
    exit(False);
  CurrParent:=TObjectVMTRec.vmtRecPtr(APCheckedObject)^.parent;
  if CurrParent=nil then
    exit(False);
  {$ifndef VER3_0}
  if CurrParent^=nil then
    exit(False);
  {$endif}
  Result:=IsObjectIt({$ifdef VER3_0}CurrParent{$else}CurrParent^{$endif},APCheckedType);
end;

function ParentObjectPType(const APType:PTypeOf):PTypeOf;
begin
  if APType=nil then
    exit(nil);
  if TObjectVMTRec.vmtRecPtr(APType)^.parent<>nil then
    Result:=TObjectVMTRec.vmtRecPtr(APType)^.parent{$ifndef VER3_0}^{$endif}
  else
    Result:=nil;
end;

begin
end.
