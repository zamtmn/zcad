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
uses sysutils,typinfo;
type
  TPtrOffs=record
             case byte of
               1:(ptr:Pointer);
               2:(offs:PtrUInt);
           end;
{Export+}
  PTArrayIndex=^TArrayIndex;
  TArrayIndex=Integer;
  {REGISTEROBJECTWITHOUTCONSTRUCTORTYPE TZAbsVector}
  TZAbsVector=object
    function GetParray:pointer;virtual;abstract;
    function getPData(index:TArrayIndex):Pointer;virtual;abstract;
    constructor initnul;
  end;
  PZAbsVector=^TZAbsVector;
  {REGISTERRECORDTYPE TInVectorAddr}
  TInVectorAddr=record
                  Instt:{-}TPtrOffs{/Pointer/};
                  DataSegment:PZAbsVector;
                  {-}function GetInstance:Pointer;{/ /}
                  {-}function IsNil:Boolean;{/ /}
                  {-}property Instance:Pointer read GetInstance;{/ /}
                  {-}procedure SetInstance(DS:PZAbsVector;Offs:PtrUInt);overload;{/ /}
                  {-}procedure SetInstance(Ptr:Pointer);overload;{/ /}
                  {-}procedure FreeeInstance;{/ /}
                end;
  {REGISTERRECORDTYPE itrec}
  itrec=record
              itp:{-}PPointer{/Pointer/};
              itc:Integer;
        end;
{Export-}
implementation
constructor TZAbsVector.initnul;
begin
end;

function TInVectorAddr.GetInstance:Pointer;
begin
  if DataSegment=nil then
    result:=Instt.ptr
  else
    result:=DataSegment^.getPData(Instt.offs);
    //result:=Pointer(PtrUInt(DataSegment^.GetParray)+Instt.offs);
end;
function TInVectorAddr.IsNil:Boolean;
begin
  result:=(DataSegment=nil)and(Instt.ptr=nil);
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
