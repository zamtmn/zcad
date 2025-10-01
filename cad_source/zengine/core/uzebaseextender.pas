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
unit uzeBaseExtender;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
  uses gzctnrSTL;

type
  TBaseExtender=class
    class function getExtenderName:string;virtual;abstract;
    procedure Assign(Source:TBaseExtender);virtual;abstract;
  end;

  TExtender<GPExtendable>=class(TBaseExtender)
    constructor Create(pEntity:GPExtendable);virtual;abstract;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:GPExtendable);virtual;abstract;
    class function CanBeAddedTo(pEntity:GPExtendable):Boolean;virtual;abstract;
  end;


  TMetaExtender=class of TBaseExtender;

  TMetaExtender2Counter=TMyMapCounter<TMetaExtender>;

  TExtensions<GExtender:class;GMetaExtender;GExtendable>=class
  type
    TEntityExtenderVector=TMyVector<GExtender>;
    TEntityExtenderMap=GKey2DataMap<GMetaExtender,SizeUInt>;
  var
    fFreeEntityExtensions:Integer;
    fEntityExtensions:TEntityExtenderVector;
    fEntityExtenderToIndex:TEntityExtenderMap;

    constructor create;
    destructor destroy;override;
    function AddExtension(ExtObj:GExtender):GExtender;
    procedure RemoveExtension(ExtType:GMetaExtender);
    function GetExtension(ExtType:GMetaExtender):GExtender;overload;
    function GetExtension(n:Integer):GExtender;overload;
    function GetExtensionsCount:Integer;
    //function GetExtension<GEntityExtenderType>:GEntityExtenderType;overload;
  end;


implementation

function TExtensions<GExtender,GMetaExtender,GExtendable>.GetExtensionsCount:Integer;
begin
  if Assigned(fEntityExtensions) then
    result:=fEntityExtensions.Size
  else
    result:=0;
end;

function TExtensions<GExtender,GMetaExtender,GExtendable>.GetExtension(n:Integer):GExtender;
begin
  result:=fEntityExtensions[n];
end;

function TExtensions<GExtender,GMetaExtender,GExtendable>.GetExtension(ExtType:GMetaExtender):GExtender;
var
  index:SizeUInt;
begin
     if assigned(fEntityExtensions)then
     begin
     if fEntityExtenderToIndex.MyGetValue(ExtType,index) then
       result:=fEntityExtensions[index]
     else
       result:=nil;
     end
     else
       result:=nil;
end;


constructor TExtensions<GExtender,GMetaExtender,GExtendable>.create;
begin
     fEntityExtensions:=TEntityExtenderVector.Create;
     fEntityExtenderToIndex:=TEntityExtenderMap.Create;
     fFreeEntityExtensions:=0;
end;

destructor TExtensions<GExtender,GMetaExtender,GExtendable>.destroy;
var
  i:integer;
  p:GExtender;
begin
     if fEntityExtensions.Size>0 then
     for i:=0 to fEntityExtensions.Size-1 do
     begin
       p:=fEntityExtensions[i];
       p.Free;
     end;
     fEntityExtensions.Destroy;
     fEntityExtenderToIndex.Destroy;
end;

function TExtensions<GExtender,GMetaExtender,GExtendable>.AddExtension(ExtObj:GExtender):GExtender;
var
  nevindex:SizeUInt;
begin
     if not fEntityExtenderToIndex.MyGetValue(typeof(ExtObj),nevindex) then
     begin
          if fFreeEntityExtensions=0 then begin
            nevindex:=fEntityExtensions.Size;
            fEntityExtensions.PushBack(ExtObj)
          end else begin
            nevindex:=0;
            while nevindex<fEntityExtensions.Size do begin
              if fEntityExtensions.Mutable[nevindex]^=nil then
                Break;
              inc(nevindex);
            end;
            fEntityExtensions.Mutable[nevindex]^:=ExtObj;
            dec(fFreeEntityExtensions);
          end;

          fEntityExtenderToIndex.RegisterKey(typeof(ExtObj),nevindex);
          result:=ExtObj;
     end
     else
        result:=fEntityExtensions[nevindex];
end;

procedure TExtensions<GExtender,GMetaExtender,GExtendable>.RemoveExtension(ExtType:GMetaExtender);
var
  index:SizeUInt;
begin
     if fEntityExtenderToIndex.MyGetValue(ExtType,index) then
     begin
          fEntityExtenderToIndex.Remove(ExtType);
          fEntityExtensions.Mutable[index]^:=nil;
          inc(fFreeEntityExtensions);
     end;
end;



end.

