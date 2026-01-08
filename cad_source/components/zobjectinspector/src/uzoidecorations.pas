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

unit uzOIDecorations;

{$Mode objfpc}{$H+}

interface

uses uzsbVarmanDef;

procedure DecorateType(PT:PUserTypeDescriptor;
  getvalueasstring:TDecoratorGetValueAsString;
  CreateEditor:TDecoratorCreateEditor;DrawProperty:TDecoratorDrawProperty);
procedure AddEditorToType(PT:PUserTypeDescriptor;CreateEditor:TCreateEditorFunc);
procedure AddFastEditorToType(PT:PUserTypeDescriptor;
  GetPrefferedFastEditorSize:TGetPrefferedFastEditorSize;
  DrawFastEditor:TDrawFastEditor;RunFastEditor:TRunFastEditor;
  _UndoInsideFastEditor:boolean=False);

implementation

procedure DecorateType(PT:PUserTypeDescriptor;
  getvalueasstring:TDecoratorGetValueAsString;CreateEditor:TDecoratorCreateEditor;
  DrawProperty:TDecoratorDrawProperty);
begin
  if PT<>nil then begin
    PT^.Decorators.OnGetValueAsString:=getvalueasstring;
    PT^.Decorators.OnCreateEditor:=CreateEditor;
    PT^.Decorators.OnDrawProperty:=DrawProperty;
  end;
end;

procedure AddEditorToType(PT:PUserTypeDescriptor;CreateEditor:TCreateEditorFunc);
begin
  if PT<>nil then begin
    PT^.onCreateEditorFunc:=CreateEditor;
  end;
end;

procedure AddFastEditorToType(PT:PUserTypeDescriptor;
  GetPrefferedFastEditorSize:TGetPrefferedFastEditorSize;
  DrawFastEditor:TDrawFastEditor;
  RunFastEditor:TRunFastEditor;
  _UndoInsideFastEditor:boolean=False);
var
  fsep:TFastEditorProcs;
begin
  if PT<>nil then begin
    fsep.OnGetPrefferedFastEditorSize:=GetPrefferedFastEditorSize;
    fsep.OnDrawFastEditor:=DrawFastEditor;
    fsep.OnRunFastEditor:=RunFastEditor;
    fsep.UndoInsideFastEditor:=_UndoInsideFastEditor;

    if PT^.FastEditors=nil then
      PT^.FastEditors:=
        TFastEditorsVector.Create;
    PT^.FastEditors.PushBack(fsep);
  end;
end;

begin
end.
