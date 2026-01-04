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

unit uzcimagesmanager;
{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,SysUtils,
  LResources,LazUTF8,Controls,Graphics,
  gzctnrSTL,uzctnrVectorBytesStream,
  uzbpaths,uzbstrproc,uzcLog;
type
  TImageData=record
    Index:Integer;
    UppercaseName:string;
    Path:string;
  end;
  TImageName2TImageDataMap=GKey2DataMap<String,TImageData(*{$IFNDEF DELPHI},LessString{$ENDIF}*)>;
  TImagesManager=class(TComponent)
    private
      FDefaultImageIndex:integer;
      FIconList: TImageList;
      ImageDataMap:TImageName2TImageDataMap;
      procedure InternalCreate;
      //procedure FoundImage(filename:{AnsiString}String);
    public
      constructor Create;overload;
      constructor Create(TheOwner: TComponent); override;overload;
      destructor destroy; override;
      function loadicon(const f:string):integer;
      procedure ScanDir(const path:string);
      procedure LoadAliasesDir(const path:string);
      function GetImageIndex(const ImageName:string):integer;overload;
      function GetImageIndex(const ImageName:string;DefaultInd:integer):integer;overload;
    published
      property IconList: TImageList read FIconList write FIconList;
      property DefaultImageIndex:integer read FDefaultImageIndex write FDefaultImageIndex;
  end;

var
  ImagesManager:TImagesManager;
implementation
constructor TImagesManager.Create;
begin
  inherited;
  InternalCreate;
end;
constructor TImagesManager.Create(TheOwner: TComponent);
begin
  inherited;
  InternalCreate;
end;
procedure TImagesManager.InternalCreate;
var
   ID:TImageData;
   PNG:TPortableNetworkGraphic;
begin
  FIconList:=TImageList.Create(self);
  FIconList.RegisterResolutions([16,24,32,48,64]);
  ImageDataMap:=TImageName2TImageDataMap.create;

  PNG:=TPortableNetworkGraphic.create;
  PNG.LoadFromLazarusResource('!!!noimage');
  PNG.Transparent:=true;
  defaultimageindex:=iconlist.Add(PNG,nil);
  freeandnil(PNG);
  ID.Index:=defaultimageindex;
  ID.Path:='fromresources';
  ID.UppercaseName:='!!!NOIMAGE';

  ImageDataMap.RegisterKey(ID.UppercaseName,ID);
end;
destructor TImagesManager.destroy;
begin
  FreeAndNil(FIconList);
  FreeAndNil(ImageDataMap);
end;
procedure {TImagesManager.}FoundImage(const filename:String;pdata:pointer);
var
   ID:TImageData;
   PID:TImageName2TImageDataMap.PValue;
   internalname:string;
begin
  id.Index:=-1;
  id.Path:=filename;
  //exit;
  internalname:=uppercase(ChangeFileExt(extractfilename(filename),''));
  if ImagesManager.ImageDataMap.tryGetMutableValue(internalname,PID) then
    begin
      //уже зарегистрирован
    end
  else
    begin
      id.Index:=-1;
      id.Path:=filename;
      id.UppercaseName:=internalname;
      ImagesManager.ImageDataMap.RegisterKey(internalname,id)
    end;
end;
function TImagesManager.GetImageIndex(const ImageName:string):integer;
begin
  result:=GetImageIndex(ImageName,defaultimageindex)
end;
function TImagesManager.GetImageIndex(const ImageName:string;DefaultInd:integer):integer;
var
   PID:TImageName2TImageDataMap.PValue;
   internalname:string;
begin
   internalname:=uppercase(ChangeFileExt(extractfilename(ImageName),''));
   if ImagesManager.ImageDataMap.tryGetMutableValue(internalname,PID) then
     begin
       if PID^.Index<>-1 then
                             exit(PID^.Index);
       PID^.Index:=loadicon(PID^.Path);
       exit(PID^.Index);
     end
   else
     begin
       result:=DefaultInd;
     end;
end;
procedure TImagesManager.LoadAliasesDir(const path:string);
var
  line,sub,internalname:String;
  f:TZctnrVectorBytes;
  PID:TImageName2TImageDataMap.PValue;
  ID:TImageData;
begin
  f.InitFromFile(path);
  while f.notEOF do
    begin
      line:=f.readString;
      if line<>'' then
      if line[1]<>';' then
        begin
          sub:=GetPredStr(line,'=');
          internalname:=uppercase(sub);
          if ImagesManager.ImageDataMap.tryGetMutableValue(internalname,PID) then
            begin
              //уже зарегистрирован
            end
          else
            begin
              id.Index:=GetImageIndex(line);;
              id.Path:=sub;
              id.UppercaseName:=internalname;
              ImagesManager.ImageDataMap.RegisterKey(internalname,id)
            end;
        end;
    end;
  f.done;
end;
procedure TImagesManager.ScanDir(const path:string);
begin
  FromDirIterator(utf8tosys(path),'*.png','',foundimage,{TImagesManager.foundimage}nil);
end;
function TImagesManager.loadicon(const f:string):integer;
var
  PNG:TPortableNetworkGraphic;
begin
  PNG:=TPortableNetworkGraphic.create;
  PNG.LoadFromFile(f);
  PNG.Transparent:=true;
  result:=iconlist.Add(PNG,nil);
  freeandnil(PNG);
end;
initialization
  {$i defaultimages.inc}
  ImagesManager:=TImagesManager.Create;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ImagesManager.Destroy;
end.

