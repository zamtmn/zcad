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
{$MODE OBJFPC}
unit gdbentityextender;
{$INCLUDE def.inc}

interface
uses memman,uabstractunit,UGDBDrawingdef,gdbasetypes,gdbase,usimplegenerics,gvector,UGDBOpenArrayOfByte;

type
TBaseObjExtender={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)

end;
PTBaseEntityExtender=^TBaseEntityExtender;
TCreateThisExtender=function (pEntity:Pointer; out ObjSize:Integer):PTBaseEntityExtender;

TBaseEntityExtender={$IFNDEF DELPHI}packed{$ENDIF} object(TBaseObjExtender)
                  //class function CreateThisExtender(pEntity:Pointer; out ObjSize:Integer):PTBaseEntityExtender;
                  constructor init(pEntity:Pointer);
                  class procedure onEntityDestruct(pEntity:Pointer);virtual;abstract;
                  procedure onEntityFormat(pEntity:Pointer;const drawing:TDrawingDef);virtual;abstract;
end;
TEntityExtenderVector=specialize TVector<PTBaseEntityExtender>;
TEntityExtensions=class
                       fEntityExtensions:TEntityExtenderVector;

                       constructor create;
                       destructor destroy;override;
                       procedure AddExtension(ExtObj:PTBaseEntityExtender;ObjSize:GDBInteger);
                  end;
implementation
constructor TBaseEntityExtender.init(pEntity:Pointer);
begin
end;
procedure TEntityExtensions.AddExtension(ExtObj:PTBaseEntityExtender;ObjSize:GDBInteger);
begin
     fEntityExtensions.PushBack(ExtObj);
end;
constructor TEntityExtensions.create;
begin
     fEntityExtensions:=TEntityExtenderVector.Create;
end;
destructor TEntityExtensions.destroy;
var
  i:integer;
  p:PTBaseEntityExtender;
begin
     for i:=0 to fEntityExtensions.Size-1 do
     begin
       p:=fEntityExtensions[i];
       p^.Done;
       GDBFreeMem(p);
     end;
     fEntityExtensions.Destroy;
end;
end.

