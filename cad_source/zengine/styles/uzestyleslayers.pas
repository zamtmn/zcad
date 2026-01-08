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

unit uzestyleslayers;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  sysutils,uzbtypes,uzeTypes,uzegeometry,
  uzeconsts,UGDBNamedObjectsArray,uzbstrproc,uzeNamedObject,
  uzeEntityStylesRegister;
type

  PGDBLayerPropObjInsp=Pointer;
  PPGDBLayerPropObjInsp=^PGDBLayerPropObjInsp;

  GDBLayerProp=object(GDBNamedObject)
    color:byte;(*'Color'*)
    lineweight:smallint;(*'Line weight'*)
    LT:Pointer;(*'Line type'*)
    _on:boolean;(*'On'*)
    _lock:boolean;(*'Lock'*)
    _print:boolean;(*'Print'*)
    desk:ansistring;(*'Description'*)
    constructor InitWithParam(const N:string;C:integer;
      LW:integer;oo,ll,pp:boolean;const d:string);
    function GetFullName:string;virtual;
    procedure SetValueFromDxf(group:integer;const Value:string);virtual;
    procedure SetDefaultValues;virtual;
    destructor done;virtual;
  end;
  PGDBLayerProp=^GDBLayerProp;

{EXPORT+}
{EXPORT-}

PGDBLayerPropArray=^GDBLayerPropArray;
GDBLayerPropArray=packed array [0..0] of PGDBLayerProp;
  PGDBLayerArray=^GDBLayerArray;
  GDBLayerArray= object(GDBNamedObjectsArray{-}<PGDBLayerProp,GDBLayerProp>{//})
    private
      fActlState:TActuality;
    public
      constructor init(m:Integer;psyslt:Pointer);
      constructor initnul;

      function addlayer(const name:String;color:Integer;lw:Integer;oo,ll,pp:Boolean;const d:String;lm:TLoadOpt):PGDBLayerProp;virtual;
      function GetSystemLayer:PGDBLayerProp;
      function createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
      function createlayerifneedbyname(const lname:String;_source:PGDBLayerProp):PGDBLayerProp;
      procedure NewState;
      {-}property ActlState:TActuality read fActlState;{//}
  end;
{EXPORT-}

TLayerProp=class(TNamedObject)
end;
function GetLTName(LT:PGDBLayerProp):String;
var
   DefaultErrorLayer:GDBLayerProp;
   LayerHandle:TStyleDeskHandle;
implementation
procedure GDBLayerArray.NewState;
begin
  fActlState:=zeHandles.CreateHandle;
end;

function GetLTName(LT:PGDBLayerProp):String;
begin
     if assigned(LT) then
                         result:=LT^.Name
                     else
                         result:='Continuous';
end;

function  GDBLayerArray.createlayerifneedbyname(const lname:String;_source:PGDBLayerProp):PGDBLayerProp;
begin
           result:=getAddres(lname);
           if result=nil then
           begin
                if _source<>nil then
                result:=addlayer(_source.Name,
                                        _source.color,
                                        _source.lineweight,
                                        _source._on,
                                        _source._lock,
                                        _source._print,
                                        _source.desk,
                                        TLOMerge);
           end;
end;
function  GDBLayerArray.createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
begin
           result:=createlayerifneedbyname(_source.Name,_source);
           {result:=getAddres(_source.Name);
           if result=nil then
           begin
                if _source<>nil then
                result:=addlayer(_source.Name,
                                        _source.color,
                                        _source.lineweight,
                                        _source._on,
                                        _source._lock,
                                        _source._print,
                                        _source.desk,
                                        TLOMerge);
           end;}
end;
constructor GDBLayerArray.init;
begin
  inherited init(m);
  addlayer(LNSysLayerName,CGDBWhile,lwgdbdefault,true,false,true,'',TLOLoad).LT:=psyslt;
  addlayer(LNMetricLayerName,CGDBWhile,lwgdbdefault,false,false,false,'',TLOLoad).LT:=psyslt;
  NewState;
end;
constructor GDBLayerArray.initnul;
begin
  inherited initnul;
  NewState;
end;
destructor GDBLayerProp.done;
begin
     inherited;
     self.desk:='';
end;

procedure GDBLayerProp.SetDefaultValues;
begin
     color:=7;
     lineweight:=-1;
     LT:=nil;
     _on:=true;
     _lock:=false;
     if uppercase(name)=LNSysDefpoints then
                                           _print:=false
                                       else
                                           _print:=true;
     desk:='';
end;
procedure GDBLayerProp.SetValueFromDxf(group:Integer;const value:String);
var
   _color:integer;
begin
  case group of
          62:
            begin
              _color:=strtoint(value);
              color:=abs(_color);
              if _color<0 then begin
                                    self._on:=false;
                               end;
            end;
          370:
            begin
              self.lineweight:=strtoint(value);
            end;
          70:
            begin
                 if (strtoint(value)and 4)<>0 then
                                                   begin
                                                        self._lock:=true;
                                                   end;
             end;
          290:
            begin
                 if (strtoint(value))=0 then
                                              begin
                                                   self._print:=false;
                                              end;
             end;
        end;
end;

constructor GDBLayerProp.InitWithParam(const N:String; C: Integer; LW: Integer;oo,ll,pp:Boolean;const d:String);
begin
    initnul;
    LT:=nil;
    SetName(n);
    color := c;
    lineweight := lw;
    _on:=oo;
    _lock:=ll;
    _print:=pp;
    desk:=d;
end;
function GDBLayerProp.GetFullName;
begin
  result:=getname;
end;
function GDBLayerArray.GetSystemLayer;
begin
     result:=getAddres(LNSysLayerName);
end;
function GDBLayerArray.addlayer;
var
  p:PGDBLayerProp;
      //ir:itrec;
begin
     case AddItem(name,pointer(p)) of
             IsFounded:
                       begin
                            if lm=TLOLoad then
                            begin
                                 p^.color:=color;
                                 p^.lineweight:=lw;
                                 p^._on:=oo;
                                 p^._lock:=ll;
                                 p^._print:=pp;
                                 p^.desk:=d;
                            end;
                       end;
             IsCreated:
                       begin
                            if uppercase(name)=LNSysDefpoints then
                                                               p^.initwithparam(Name,Color,LW,oo,ll,false,d)
                            else
                            p^.initwithparam(Name,Color,LW,oo,ll,pp,d);
                       end;
             IsError:
                       begin
                       end;
     end;
     result:=p;
end;
begin
  DefaultErrorLayer.Initwithparam('DefaultErrorLayer',200,0,true,false,true,'');
  //LayerHandle:=RegisterStyle(TLayerPropClass,TLayersClasss);
end.
