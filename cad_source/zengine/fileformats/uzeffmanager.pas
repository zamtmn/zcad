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
unit uzeffmanager;
{$INCLUDE zengineconfig.inc}
{$Mode Delphi}{$H+}

interface
uses
  uzbnamedhandles,uzbnamedhandleswithdata,uzeTypes,
  uzeentgenericsubentry,uzedrawingsimple,sysutils,gzctnrSTL,uzgldrawcontext,
  uzbLogIntf,uzeLogIntf;

type
  TExt2LoadProcMap<GFileProcessProc>=class
    private
      type
        PTFileFormatData=^TFileFormatData;
        TFileFormatData=record
          FormatExt:String;
          FormatDesk:String;
          FileLoadProcedure:GFileProcessProc;
        end;
        PTFileFormatHandle=^TFileFormatHandle;
        TFileFormatHandle=Integer;
        TFileFormats=GTNamedHandlesWithData<TFileFormatHandle,GTLinearIncHandleManipulator<TFileFormatHandle>,String,GTStringNamesUPPERCASE<String>,TFileFormatData>;
        TFileFormatDataVector=TMyVector<TFileFormatData>;
        TExt2LoadProcMapGen=GKey2DataMap<String,TFileFormatHandle>;
      var
        fDefaultFileExt:String;
        map:TExt2LoadProcMapGen;

    public
      vec:TFileFormats;
      constructor Create;
      destructor Destroy;override;
      procedure RegisterExt(const _Wxt:String; const _FormatDesk:String; _FileLoadProcedure:GFileProcessProc; const DefaultForThisExt:boolean=false);
      function GetLoadProc(const _Wxt:String):GFileProcessProc;
      function GetDefaultFileFormatHandle(const _Wxt:String):TFileFormatHandle;
      function GetCurrentFileFilter:String;
      //function GetDefaultFileFilterIndex:integer;
      property DefaultExt:String read fDefaultFileExt write fDefaultFileExt;
  end;
  TZDrawingContext=record
    PDrawing:PTSimpleDrawing;
    POwner:PGDBObjGenericSubEntry;
    LoadMode:TLoadOpt;
    DC:TDrawContext;
    procedure CreateRec(var ADrawing:TSimpleDrawing;var AOwner:GDBObjGenericSubEntry;ALoadMode:TLoadOpt;constref ADC:TDrawContext);
  end;
  TFileLoadProcedure=procedure(const name: String;var ZCDCtx:TZDrawingContext;const LogProc:TZELogProc=nil);
  TLoadFomats=TExt2LoadProcMap<TFileLoadProcedure>;
var
    Ext2LoadProcMap:TLoadFomats;

implementation

procedure TZDrawingContext.CreateRec(var ADrawing:TSimpleDrawing;var AOwner:GDBObjGenericSubEntry;ALoadMode:TLoadOpt;constref ADC:TDrawContext);
begin
  PDrawing:=@ADrawing;
  POwner:=@AOwner;
  LoadMode:=ALoadMode;
  DC:=ADC;
end;


constructor TExt2LoadProcMap<GFileProcessProc>.Create;
begin
  inherited;
  map:=TExt2LoadProcMapGen.Create;
  vec.Init;
end;

destructor TExt2LoadProcMap<GFileProcessProc>.Destroy;
begin
  inherited;
  map.Free;
  vec.Done;
end;

function TExt2LoadProcMap<GFileProcessProc>.GetLoadProc(const _Wxt:String):GFileProcessProc;
var
  ExtHandle:TFileFormatHandle;
  //_key:String;
begin
  ExtHandle:=GetDefaultFileFormatHandle(_Wxt);
  if ExtHandle>=0 then
    result:=vec.GetPLincedData(ExtHandle)^.FileLoadProcedure
  else
    result:=nil;
end;

function TExt2LoadProcMap<GFileProcessProc>.GetDefaultFileFormatHandle(const _Wxt:String):TFileFormatHandle;
var
  _key:String;
begin
  result:=-1;
  _key:=vec.StandartizeName(_Wxt);
  if _key<>'' then begin
    while _key[1]='.' do
     _key:=copy(_key,2,length(_key)-1);
    map.MyGetValue(_key,result)
  end;
end;

procedure TExt2LoadProcMap<GFileProcessProc>.RegisterExt(const _Wxt:String; const _FormatDesk:String; _FileLoadProcedure:GFileProcessProc; const DefaultForThisExt:boolean=false);
var
  //FileFormatData:TFileFormatData;
  StandartizedName:string;
  ExtHandle:integer;
  PValue:TExt2LoadProcMapGen.PValue;
  PData:PTFileFormatData;
begin
  StandartizedName:=vec.StandartizeName(_Wxt);
  if map.tryGetMutableValue(StandartizedName,PValue) then begin
    ExtHandle:=vec.CreateHandle;
    PData:=vec.GetPLincedData(ExtHandle);
    PData^.FormatDesk:=_FormatDesk;
    PData^.FormatExt:=_Wxt;
    PData^.FileLoadProcedure:=_FileLoadProcedure;
    if DefaultForThisExt then
      PValue^:=ExtHandle;
  end else begin
    ExtHandle:=vec.CreateOrGetHandle(_Wxt);
    PData:=vec.GetPLincedData(ExtHandle);
    PData^.FormatDesk:=_FormatDesk;
    PData^.FormatExt:=_Wxt;
    PData^.FileLoadProcedure:=_FileLoadProcedure;
    map.RegisterKey(StandartizedName,ExtHandle);
  end;
end;

{function TExt2LoadProcMap<GFileProcessProc>.GetDefaultFileFilterIndex:integer;
var
  pair:TExt2LoadProcMapGen.TDictionaryPair;
begin
  result:=1;
  for pair in map do begin
    if fDefaultFileExt=pair.key then
      exit;
    inc(result)
  end;
end;}
function TExt2LoadProcMap<GFileProcessProc>.GetCurrentFileFilter:String;
var
  ffd:TFileFormats.THandleData;
begin
  result:='';
  for ffd in vec.HandleDataVector do
    if result<>'' then
      result:=result+'|'+ffd.d.FormatDesk+'|*.'+ffd.d.FormatExt
    else
      result:=ffd.d.FormatDesk+'|*.'+ffd.d.FormatExt;

  if result<>'' then
    result:=result+'|';
  result:=result+'All files (*.*)|*.*'
end;

initialization
  Ext2LoadProcMap:=TLoadFomats.create;
finalization
  zDebugln('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  Ext2LoadProcMap.Destroy;
end.

