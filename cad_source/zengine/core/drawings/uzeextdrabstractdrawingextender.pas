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
unit uzeExtdrAbstractDrawingExtender;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses
  usimplegenerics,uzctnrVectorBytesStream,gzctnrSTL,uzeBaseExtender,uzedrawingabstract;

type
  TAbstractDrawingExtender=class(TExtender<TAbstractDrawing>)
  end;

  TMetaDrawingExtender=class of TAbstractDrawingExtender;

  TDrawingExtensions=class(TExtensions<TAbstractDrawingExtender,TMetaDrawingExtender,TAbstractDrawing>)

    function GetExtension<GEntityExtenderType>:GEntityExtenderType;overload;
  end;
  TEntityExtendersMap=GKey2DataMap<string,TMetaDrawingExtender>;
var
  EntityExtenders:TEntityExtendersMap;
implementation

function TDrawingExtensions.GetExtension<GEntityExtenderType>:GEntityExtenderType;
var
  index:SizeUInt;
begin
     if assigned(fEntityExtensions)then
     begin
     if fEntityExtenderToIndex.MyGetValue(GEntityExtenderType,index) then
       result:=GEntityExtenderType(fEntityExtensions[index])
     else
       result:=nil;
     end
     else
       result:=nil;
end;

initialization
  EntityExtenders:=TEntityExtendersMap.Create;
finalization
  EntityExtenders.Free;
end.

