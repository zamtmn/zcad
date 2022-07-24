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
{MODE OBJFPC}{$H+}
unit uzeobjectextender;
{$INCLUDE zengineconfig.inc}

interface
uses uzeentityextender,uzeentsubordinated,uzedrawingdef,uzbtypes,
     uzctnrVectorBytes,gzctnrSTL,uzeffdxfsupport;

type
TConstructorFeature=procedure(pEntity:Pointer);
TDestructorFeature=procedure(pEntity:Pointer);
TCreateEntFeatureData=record
                constr:TConstructorFeature;
                destr:TDestructorFeature;
              end;
TDXFEntSaveFeature=procedure(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
TDXFEntLoadFeature=function(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:Pointer):boolean of object;
TDXFEntAfterLoadFeature=procedure(pEntity:Pointer);
TDXFEntFormatFeature=procedure (pEntity:Pointer;const drawing:TDrawingDef);
TDXFEntLoadData=record
                DXFEntLoadFeature:TDXFEntLoadFeature;
              end;
TDXFEntSaveData=record
                DXFEntSaveFeature:TDXFEntSaveFeature;
              end;
TDXFEntLoadDataMap=GKey2DataMap<String,TDXFEntLoadData(*{$IFNDEF DELPHI},LessString{$ENDIF}*)>;
TDXFEntSaveDataVector=TmyVector<TDXFEntSaveData>;
TDXFEntFormatProcsVector=TmyVector<TDXFEntFormatFeature>;
TCreateEntFeatureVector=TmyVector<TCreateEntFeatureData>;
TDXFEntAfterLoadFeatureVector=TmyVector<TDXFEntAfterLoadFeature>;
TEntityCreateExtenderVector=TmyVector<TMetaEntityExtender>;
TDXFEntIODataManager=class
                      fDXFEntLoadDataMapByName:TDXFEntLoadDataMap;
                      fDXFEntLoadDataMapByPrefix:TDXFEntLoadDataMap;
                      fDXFEntSaveDataVector:TDXFEntSaveDataVector;
                      fDXFEntFormatprocsVector:TDXFEntFormatprocsVector;
                      fCreateEntFeatureVector:TCreateEntFeatureVector;
                      fDXFEntAfterLoadFeatureVector:TDXFEntAfterLoadFeatureVector;
                      fTEntityExtenderVector:TEntityCreateExtenderVector;
                      procedure RegisterNamedLoadFeature(name:String;PLoadProc:TDXFEntLoadFeature);
                      procedure RegisterAfterLoadFeature(PAfterLoadProc:TDXFEntAfterLoadFeature);
                      procedure RegisterPrefixLoadFeature(prefix:String;PLoadProc:TDXFEntLoadFeature);
                      procedure RegisterSaveFeature(PSaveProc:TDXFEntSaveFeature);
                      procedure RegisterFormatFeature(PFormatProc:TDXFEntFormatFeature);
                      procedure RunSaveFeatures(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
                      procedure RunFormatProcs(const drawing:TDrawingDef;pEntity:Pointer);
                      procedure RunAfterLoadFeature(pEntity:Pointer);
                      function GetLoadFeature(name:String):TDXFEntLoadFeature;

                      procedure RegisterCreateEntFeature(_constr:TConstructorFeature;_destr:TDestructorFeature);
                      procedure RunConstructorFeature(pEntity:Pointer);
                      procedure RunDestructorFeature(pEntity:Pointer);

                      procedure RegisterEntityExtenderObject(ExtenderClass:TMetaEntityExtender);
                      procedure AddExtendersToEntity(pEntity:Pointer);

                      constructor create;
                      destructor destroy;override;
                 end;
implementation
constructor TDXFEntIODataManager.create;
begin
     fDXFEntLoadDataMapByName:=TDXFEntLoadDataMap.Create;
     fDXFEntLoadDataMapByPrefix:=TDXFEntLoadDataMap.Create;
     fDXFEntSaveDataVector:=TDXFEntSaveDataVector.Create;
     fDXFEntFormatprocsVector:=TDXFEntFormatprocsVector.Create;
     fCreateEntFeatureVector:=TCreateEntFeatureVector.Create;
     fDXFEntAfterLoadFeatureVector:=TDXFEntAfterLoadFeatureVector.create;
     fTEntityExtenderVector:=TEntityCreateExtenderVector.Create;
end;
destructor TDXFEntIODataManager.destroy;
begin
     fDXFEntLoadDataMapByName.Destroy;
     fDXFEntLoadDataMapByPrefix.Destroy;
     fDXFEntSaveDataVector.Destroy;
     fDXFEntFormatprocsVector.Destroy;
     fCreateEntFeatureVector.Destroy;
     fDXFEntAfterLoadFeatureVector.Destroy;
     fTEntityExtenderVector.Destroy;
end;
function TDXFEntIODataManager.GetLoadFeature(name:String):TDXFEntLoadFeature;
var
  data:TDXFEntLoadData;
begin
     if fDXFEntLoadDataMapByName.MyGetValue(name,data)then
                                                        begin
                                                        result:=data.DXFEntLoadFeature;
                                                        exit;
                                                        end;
     if length(name)>=1 then
     if fDXFEntLoadDataMapByPrefix.MyGetValue(name[1],data)then
                                                        begin
                                                        result:=data.DXFEntLoadFeature;
                                                        exit;
                                                        end;
     result:=nil;
end;
procedure TDXFEntIODataManager.RegisterNamedLoadFeature(name:String;PLoadProc:TDXFEntLoadFeature);
var
  data:TDXFEntLoadData;
begin
     data.DXFEntLoadFeature:=PLoadProc;
     fDXFEntLoadDataMapByName.RegisterKey(name,data);
end;
procedure TDXFEntIODataManager.RegisterAfterLoadFeature(PAfterLoadProc:TDXFEntAfterLoadFeature);
begin
     fDXFEntAfterLoadFeatureVector.PushBack(PAfterLoadProc);
end;

procedure TDXFEntIODataManager.RegisterPrefixLoadFeature(prefix:String;PLoadProc:TDXFEntLoadFeature);
var
  data:TDXFEntLoadData;
begin
     data.DXFEntLoadFeature:=PLoadProc;
     fDXFEntLoadDataMapByPrefix.RegisterKey(prefix,data);
end;
procedure TDXFEntIODataManager.RegisterSaveFeature(PSaveProc:TDXFEntSaveFeature);
var
  data:TDXFEntSaveData;
begin
     data.DXFEntSaveFeature:=PSaveProc;
     fDXFEntSaveDataVector.PushBack(data);
end;
procedure TDXFEntIODataManager.RegisterFormatFeature(PFormatProc:TDXFEntFormatFeature);
begin
     fDXFEntFormatprocsVector.PushBack(PFormatProc);
end;
procedure TDXFEntIODataManager.RegisterCreateEntFeature(_constr:TConstructorFeature;_destr:TDestructorFeature);
var
  data:TCreateEntFeatureData;
begin
     data.constr:=_constr;
     data.destr:=_destr;
     fCreateEntFeatureVector.PushBack(data);
end;
procedure TDXFEntIODataManager.RunSaveFeatures(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
var
  i:integer;
begin
     for i:=0 to fDXFEntSaveDataVector.Size-1 do
      fDXFEntSaveDataVector[i].DXFEntSaveFeature(outhandle,PEnt,IODXFContext);
end;
procedure TDXFEntIODataManager.RunFormatProcs(const drawing:TDrawingDef;pEntity:Pointer);
var
  i:integer;
begin
     for i:=0 to fDXFEntFormatprocsVector.Size-1 do
      fDXFEntFormatprocsVector[i](pEntity,drawing);
end;
procedure TDXFEntIODataManager.RunConstructorFeature(pEntity:Pointer);
var
  i:integer;
begin
     for i:=0 to fCreateEntFeatureVector.Size-1 do
      fCreateEntFeatureVector[i].constr(pEntity);
end;
procedure TDXFEntIODataManager.RunAfterLoadFeature(pEntity:Pointer);
var
  i:integer;
begin
     for i:=0 to fDXFEntAfterLoadFeatureVector.Size-1 do
      fDXFEntAfterLoadFeatureVector[i](pEntity);
end;
procedure TDXFEntIODataManager.RunDestructorFeature(pEntity:Pointer);
var
  i:integer;
begin
     for i:=0 to fCreateEntFeatureVector.Size-1 do
      fCreateEntFeatureVector[i].destr(pEntity);
end;

procedure TDXFEntIODataManager.RegisterEntityExtenderObject(ExtenderClass:TMetaEntityExtender);
begin
     fTEntityExtenderVector.PushBack(ExtenderClass);
end;
procedure TDXFEntIODataManager.AddExtendersToEntity(pEntity:Pointer);
var
  i:integer;
  extension:TBaseEntityExtender;
begin
     for i:=0 to fTEntityExtenderVector.Size-1 do
     begin
      extension:=fTEntityExtenderVector[i].create(pEntity);
      PGDBObjSubordinated(pEntity)^.AddExtension(extension);
     end;
end;

end.

