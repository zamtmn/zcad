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
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
unit gzctnrVectorTypes;

interface

uses SysUtils,typinfo;

type
  TPtrOffs=record
    case boolean of
      False:(ptr:Pointer);
      True:(offs:PtrUInt);
  end;
  PTArrayIndex=^TArrayIndex;
  TArrayIndex=integer;

  TZAbsVector=object
    function GetParray:pointer;virtual;abstract;
    function getPData(index:TArrayIndex):Pointer;virtual;abstract;
    constructor initnul;
  end;
  PZAbsVector=^TZAbsVector;

  TInVectorAddr=record
    Instt:TPtrOffs;
    DataSegment:PZAbsVector;
    function GetInstance:Pointer;
    function IsNil:boolean;
    property Instance:Pointer read GetInstance;
    procedure SetInstance(DS:PZAbsVector;Offs:PtrUInt);overload;
    procedure SetInstance(Ptr:Pointer);overload;
    procedure FreeeInstance;
  end;

  itrec=record
    itp:PPointer;
    itc:integer;
  end;

implementation

constructor TZAbsVector.initnul;
begin
end;

function TInVectorAddr.GetInstance:Pointer;
begin
  if DataSegment=nil then
    Result:=Instt.ptr
  else
    Result:=DataSegment^.getPData(Instt.offs);
  //result:=Pointer(PtrUInt(DataSegment^.GetParray)+Instt.offs);
end;

function TInVectorAddr.IsNil:boolean;
begin
  Result:=(DataSegment=nil)and(Instt.ptr=nil);
end;

procedure TInVectorAddr.SetInstance(DS:PZAbsVector;Offs:PtrUInt);
begin
  DataSegment:=DS;
  Instt.offs:=Offs;
end;

procedure TInVectorAddr.SetInstance(Ptr:Pointer);
begin
  DataSegment:=nil;
  Instt.ptr:=Ptr;
end;

procedure TInVectorAddr.FreeeInstance;
begin
  if DataSegment=nil then
    Freemem(Instt.ptr);
end;

begin
end.
