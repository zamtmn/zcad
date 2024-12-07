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

unit uzeEntityStylesRegister;
{$mode objfpc}{$H+}
{$modeswitch TypeHelpers}{$modeswitch advancedrecords}
interface

uses
  sysutils,
  gvector,
  Generics.Collections,Generics.Defaults,
  uzbHandles,uzbNamedHandles,uzbNamedHandlesWithData,{uzbSets,}uzeNamedObject;

type

  TNamedObjectArray=class
  end;

  TNamedObjectClass=class of TNamedObject;
  TNamedObjectArrayClass=class of TNamedObjectArray;

  TStyleDeskHandle=SizeUInt;
  TStyleDeskNameType=TNamedObject;


  TEntityStylesRegister=object
    private
      type
        TStyleDeskData=record
          TNO:TNamedObjectClass;
          TNOA:TNamedObjectArrayClass;
        end;
        TStylesDeskHandles=specialize GTNamedHandlesWithData<TStyleDeskHandle,
                                                             specialize GTLinearIncHandleManipulator<TStyleDeskHandle>,
                                                             TNamedObjectClass,
                                                             specialize GTStringNamesCaseSensetive<TNamedObjectClass>,
                                                             TStyleDeskData>;

      var
        StylesDesks:TStylesDeskHandles;

    public
      constructor Init;
      destructor Done;virtual;

      function RegisterStyle(StyleClass:TNamedObjectClass;StyleArrayClass:TNamedObjectArrayClass):TStyleDeskHandle;
      //function isModuleEnabled(LMDI:TStyleDeskHandle):Boolean;
  end;

implementation

function TEntityStylesRegister.RegisterStyle(StyleClass:TNamedObjectClass;StyleArrayClass:TNamedObjectArrayClass):TStyleDeskHandle;
//var
//  i:integer;
begin
  if not StylesDesks.TryGetHandle(StyleClass,result) then
  begin
    result:=StylesDesks.CreateOrGetHandle(StyleClass);
    with StylesDesks.GetPLincedData(result)^ do begin
      TNO:=StyleClass;
      TNOA:=StyleArrayClass;
    end;
  end;
end;

constructor TEntityStylesRegister.init({TraceModeName:TLogLevelHandleNameType;TraceModeAlias:AnsiChar});
begin
  StylesDesks.init;
end;

destructor TEntityStylesRegister.done;
//var
//  i:integer;
begin
  StylesDesks.Done;
end;

initialization
finalization
end.

