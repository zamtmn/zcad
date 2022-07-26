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

unit uzctypesdecorations;

{$MODE DELPHI}

interface
uses varmandef;
procedure DecorateType(PT:PUserTypeDescriptor;getvalueasstring:TOnGetValueAsString;CreateEditor:TOnCreateEditor;DrawProperty:TOnDrawProperty);
procedure AddEditorToType(PT:PUserTypeDescriptor;CreateEditor:TCreateEditorFunc);
procedure AddFastEditorToType(PT:PUserTypeDescriptor;GetPrefferedFastEditorSize:TGetPrefferedFastEditorSize;
                              DrawFastEditor:TDrawFastEditor;
                              RunFastEditor:TRunFastEditor;
                              _UndoInsideFastEditor:Boolean=false);
implementation
procedure DecorateType(PT:PUserTypeDescriptor;getvalueasstring:TOnGetValueAsString;CreateEditor:TOnCreateEditor;DrawProperty:TOnDrawProperty);
begin
     if PT<>nil then
                    begin
                         PT^.Decorators.OnGetValueAsString:=getvalueasstring;
                         PT^.Decorators.OnCreateEditor:=CreateEditor;
                         PT^.Decorators.OnDrawProperty:=DrawProperty;
                    end;
end;
procedure AddEditorToType(PT:PUserTypeDescriptor;CreateEditor:TCreateEditorFunc);
begin
     if PT<>nil then
                    begin
                         PT^.onCreateEditorFunc:=CreateEditor;
                    end;
end;
procedure AddFastEditorToType(PT:PUserTypeDescriptor;GetPrefferedFastEditorSize:TGetPrefferedFastEditorSize;
                              DrawFastEditor:TDrawFastEditor;
                              RunFastEditor:TRunFastEditor;
                              _UndoInsideFastEditor:Boolean=false);
var
   fsep:TFastEditorProcs;
begin
     if PT<>nil then
                    begin
                         fsep.OnGetPrefferedFastEditorSize:=GetPrefferedFastEditorSize;
                         fsep.OnDrawFastEditor:=DrawFastEditor;
                         fsep.OnRunFastEditor:=RunFastEditor;
                         fsep.UndoInsideFastEditor:=_UndoInsideFastEditor;

                         if PT^.FastEditors=nil then
                                                    PT^.FastEditors:=TFastEditorsVector.Create;
                         PT^.FastEditors.PushBack(fsep);
                         //PT^.FastEditor:=fsep;
                    end;
end;
begin
end.
