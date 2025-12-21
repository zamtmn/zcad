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
unit uzeobjectextender;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses
  uzeExtdrAbstractEntityExtender,uzeentsubordinated,uzedrawingdef,
  uzbtypes,uzeTypes,uzctnrVectorBytes,gzctnrSTL,uzeffdxfsupport;

type
TConstructorFeature=procedure(pEntity:Pointer);
TDestructorFeature=procedure(pEntity:Pointer);
TCreateEntFeatureData=record
                constr:TConstructorFeature;
                destr:TDestructorFeature;
              end;
TDXFEntSaveFeature=procedure(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
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
                      procedure RunSaveFeatures(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
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
procedure TDXFEntIODataManager.RunSaveFeatures(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
var
  i:SizeUInt;
begin
     if fDXFEntSaveDataVector.Size>0 then
       for i:=fDXFEntSaveDataVector.Size-1 downto 0  do
        fDXFEntSaveDataVector[i].DXFEntSaveFeature(outStream,PEnt,IODXFContext);
end;
procedure TDXFEntIODataManager.RunFormatProcs(const drawing:TDrawingDef;pEntity:Pointer);
var
  i:SizeUInt;
begin
     if fDXFEntFormatprocsVector.Size>0 then
       for i:=fDXFEntFormatprocsVector.Size-1 downto 0 do
        fDXFEntFormatprocsVector[i](pEntity,drawing);
end;
procedure TDXFEntIODataManager.RunConstructorFeature(pEntity:Pointer);
var
  i:SizeUInt;
begin
     if fCreateEntFeatureVector.Size>0 then
       for i:=fCreateEntFeatureVector.Size-1 downto 0 do
        fCreateEntFeatureVector[i].constr(pEntity);
end;
procedure TDXFEntIODataManager.RunAfterLoadFeature(pEntity:Pointer);
var
  i:SizeUInt;
begin
     if fDXFEntAfterLoadFeatureVector.Size>0 then
       for i:=fDXFEntAfterLoadFeatureVector.Size-1 downto 0 do
        fDXFEntAfterLoadFeatureVector[i](pEntity);
end;
procedure TDXFEntIODataManager.RunDestructorFeature(pEntity:Pointer);
var
  i:SizeUInt;
begin
     if fCreateEntFeatureVector.Size>0 then
       for i:=fCreateEntFeatureVector.Size-1 downto 0 do
        fCreateEntFeatureVector[i].destr(pEntity);
end;

procedure TDXFEntIODataManager.RegisterEntityExtenderObject(ExtenderClass:TMetaEntityExtender);
begin
     fTEntityExtenderVector.PushBack(ExtenderClass);
end;
procedure TDXFEntIODataManager.AddExtendersToEntity(pEntity:Pointer);
var
  i:SizeUInt;
  extension:TAbstractEntityExtender;
begin
     if fTEntityExtenderVector.Size>0 then
         for i:=fTEntityExtenderVector.Size-1 downto 0 do
         begin
          extension:=fTEntityExtenderVector[i].create(pEntity);
          PGDBObjSubordinated(pEntity)^.AddExtension(extension);
         end;
end;

end.

