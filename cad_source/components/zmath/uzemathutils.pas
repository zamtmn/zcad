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

unit uzemathutils;
interface
uses uzedimensionaltypes,math,uzegeometry,uzegeometrytypes,sysutils;
function zeDimensionToString(const value:Double; const f:TzeUnitsFormat):String;overload;
function zeDimensionToUnicodeString(const value:Double; const f:TzeUnitsFormat):UnicodeString;
function zeNonDimensionToString(const value:Double; const f:TzeUnitsFormat):String;
function zeAngleDegToString(const value:Double; const f:TzeUnitsFormat):String;
function zeAngleToString(const value:Double; const f:TzeUnitsFormat):String;
function zeStringToAngle(const value:String; const f:TzeUnitsFormat):Double;
function CreateDefaultUnitsFormat:TzeUnitsFormat;
implementation
const
  FromDegToRad=pi/180;
  FromDegToGrad=200/180;
  FromRadToDegrees=180/pi;
  FromRadToGradians=200/pi;
  Fractions:array [TUPrec] of integer=(1,2,4,8,16,32,64,128,256);
  FromRadTo:array [TAUnits] of double=(FromRadToDegrees,FromRadToDegrees,FromRadToGradians,1,FromRadToDegrees);
  FromDegTo:array [TAUnits] of double=(1,1,FromDegToGrad,FromDegToRad,1);
  FromDimDSepToChar:array [TDimDSep] of char=('.',',',' ');
var
  WorkingFormatSettings:TFormatSettings;
function CreateDefaultUnitsFormat:TzeUnitsFormat;
begin
    result.abase:=0;
    result.adir:=ADCounterClockwise;
    result.aformat:=AUDecimalDegrees;
    result.aprec:=UPrec2;
    result.uformat:=LUDecimal;
    result.uprec:=UPrec2;
    result.umode:=UMWithSpaces;
    result.DeciminalSeparator:=DDSDot;
    result.RemoveTrailingZeros:=false;
end;
function MyFloatToStr0(const value:Double):String;
begin
     result:=FloatToStrF(value,ffFixed,0,0,WorkingFormatSettings);
end;
function MyFloatToStr(const value:Double;Prec:TUPrec;DS:TDimDSep;RTZ:boolean):String;
var
  Q:Integer;
begin
     WorkingFormatSettings.DecimalSeparator:=fromDimDSepToChar[DS];
     {case DS of
          DDSDot:WorkingFormatSettings.DecimalSeparator:='.';
        DDSComma:WorkingFormatSettings.DecimalSeparator:=',';
        DDSSpace:WorkingFormatSettings.DecimalSeparator:=' ';
     end;}
     result:=FloatToStrF(value,ffFixed,0,ord(Prec),WorkingFormatSettings);

     if (Prec<>UPrec0)and RTZ then
       begin
           { Remove trailing zeros }
           Q := Length(result);
           while (Q > 0) and (result[Q] = '0') do
             Dec(Q);
           if result[Q] = ansichar(WorkingFormatSettings.DecimalSeparator) then
             Dec(Q); { Remove trailing decimal point }
           if (Q = 0) or ((Q=1) and (result[1] = '-')) then
             result := '0'
           else
             SetLength(result,Q);
       end;
end;

(*procedure rtz(var _value:String);
var
  Q:Integer;
begin
  { Remove trailing zeros }
  Q := Length(_value);
  while (Q > 0) and (_value[Q] = '0') do
    Dec(Q);
  if _value[Q] = FormatSettings.DecimalSeparator then
    Dec(Q); { Remove trailing decimal point }
  if (Q = 0) or ((Q=1) and (_value[1] = '-')) then
    _value := '0'
  else
    SetLength(_value,Q);
end;*)
function zeNonDimensionToString(const value:Double; const f:TzeUnitsFormat):String;
var
   ff:TzeUnitsFormat;
begin
     if f.uformat=LUDecimal then
                                result:=zeDimensionToString(value,f)
                            else
                                begin
                                     ff:=f;
                                     ff.uformat:=LUDecimal;
                                     result:=zeDimensionToString(value,ff);
                                end;
end;
function zeAngleToString(const value:Double; const f:TzeUnitsFormat):String;
type
    TSUDir=(TSUDirN,TSUDirS);
    TSUSubDir=(TSUDirE,TSUDirW);
var
   ff:TzeUnitsFormat;
   angle,superangle:Double;
   deg,min,sec,sec2:double;
   stemp:integer;
   _min,_sec:integer;
   degs,mins,secs:string;
   subaprec:TUPrec;
   SUDir:TSUDir;
   SUSubDir:TSUSubDir;
function GetAngleDegreesMinutesSeconds:String;
var
   i:integer;
begin
    case f.aprec of
             UPrec0:begin
                         ff.uprec:=UPrec0;
                         result:=zeDimensionToString(angle,ff);
                    end;
      UPrec1,UPrec2:begin
                         deg:=floor(angle);
                         min:=angle-deg;
                         _min:={floor}round(60*min);
                         if _min>59 then
                                        begin
                                             deg:=deg+1;
                                             _min:=0;
                                        end;
                         //str(deg:0:0,degs);
                         degs:=MyFloatToStr0(deg);
                         mins:=inttostr(_min);
                         result:=format('%s%s%s%s',[degs,'d',mins,''''])
                    end;
{UPrec3,UPrec4}else begin
                         deg:=floor(angle);
                         min:=angle-deg;
                         _min:=floor(60*min);
                         sec:=min-_min/60;
                         sec:=sec*3600;
                         if ord(f.aprec)<ord(UPrec5)then
                                                        begin
                                                             _sec:={floor}round({60*60*}sec);
                                                             subaprec:=UPrec0;
                                                        end
                                                    else
                                                        begin
                                                             subaprec:=TUPrec(ord(f.aprec)-ord(UPrec4));
                                                             sec2:=sec;
                                                             stemp:=60;
                                                             for i:=0 to ord(subaprec) do
                                                                begin
                                                                     stemp:=stemp*10;
                                                                     sec2:=sec2*10;
                                                                end;
                                                             _sec:=round(sec2);
                                                        end;
                         if _sec>=stemp then
                                        begin
                                             _min:=_min+1;
                                             _sec:=0;
                                             sec:=0;
                                        end;
                         if _min>59 then
                                        begin
                                             deg:=deg+1;
                                             _min:=0;
                                        end;
                         //str(deg:0:0,degs);
                         degs:=MyFloatToStr0(deg);
                         mins:=inttostr(_min);
                         //str(sec:0:ord(subaprec),secs);
                         secs:=MyFloatToStr(sec,subaprec,f.DeciminalSeparator,f.RemoveTrailingZeros);
                         {if subaprec<>UPrec0 then    //Autocad not remove trailing zeros
                                                 rtz(secs);}
                         //secs:=inttostr(_sec);
                         result:=format('%s%s%s%s%s%s',[degs,'d',mins,'''',secs,'"']);
                    end;
    end;
end;
begin
     if f.adir=ADCounterClockwise then
                                      angle:=value-f.abase*FromDegToRad
                                  else
                                      angle:=-value+f.abase*FromDegToRad;
     if angle<0 then
                    angle:=2*pi+angle;
     if abs(angle-2*pi)<eps then
                                angle:=0;
     angle:=angle*fromradto[f.aformat];
     ff:=f;
     ff.RemoveTrailingZeros:=false;
     ff.uformat:=LUDecimal;
     if (f.aformat=AUDecimalDegrees)then
                                 begin
                                      ff.uprec:=f.aprec;
                                      result:=zeDimensionToString(angle,ff);
                                 end
                            else
                                begin
                                     case f.aformat of
                               AUDegreesMinutesSeconds:
                                                       result:=GetAngleDegreesMinutesSeconds;
                                  AUGradians,AURadians:begin
                                                            ff.uprec:=f.aprec;
                                                            result:=zeDimensionToString(angle,ff);
                                                            if f.aformat=AUGradians then
                                                                                        result:=format('%s%s',[result,'g'])
                                                                                    else
                                                                                        result:=format('%s%s',[result,'r'])
                                                       end;
                                      AUSurveyorsUnits:begin
                                                            //SUDir:TSUDir;
                                                            //SUSubDir:TSUSubDir;
                                                            if abs(angle)<eps then
                                                                                  result:='E'
                                                       else if abs(angle-90)<eps then
                                                                                  result:='N'
                                                       else if abs(angle-180)<eps then
                                                                                  result:='W'
                                                       else if abs(angle-270)<eps then
                                                                                  result:='S'
                                                       else begin
                                                                 superangle:=angle;
                                                                 if superangle<90 then
                                                                                        begin
                                                                                             result:='N%sE';
                                                                                             angle:=abs(90-superangle);
                                                                                        end
                                                            else if superangle<180 then
                                                                                        begin
                                                                                             result:='N%sW';
                                                                                             angle:=abs(superangle-90);
                                                                                        end
                                                            else if superangle<270 then
                                                                                        begin
                                                                                             result:='S%sW';
                                                                                             angle:=abs(270-superangle);
                                                                                        end
                                                            else if superangle<360 then
                                                                                        begin
                                                                                             result:='S%sE';
                                                                                             angle:=abs(superangle-270);
                                                                                        end;
                                                            result:=format(result,[GetAngleDegreesMinutesSeconds])
                                                            end;
                                                       end;
                                end;
                                end;
end;
function zeStringToAngle(const value:String; const f:TzeUnitsFormat):Double;
begin
  result:=degtorad(StrToFloat(value));
end;

function zeAngleDegToString(const value:Double; const f:TzeUnitsFormat):String;
var
   ff:TzeUnitsFormat;
   angle:Double;
begin
  {if f.adir=ADCounterClockwise then
                                   angle:=value
                               else
                                   angle:=-value;}
  if value<0 then
                 angle:=360+value
             else
                 angle:=value;
  if abs(angle-360)<eps then
                             angle:=0;
  angle:=angle*fromdegto[f.aformat];
  ff:=f;
  ff.RemoveTrailingZeros:=false;
  ff.uformat:=LUDecimal;
  ff.uprec:=f.aprec;
  result:=zeDimensionToString(angle,ff);
end;
function zeDimensionToUnicodeString(const value:Double; const f:TzeUnitsFormat):UnicodeString;
begin
  result:=UnicodeString(zeDimensionToString(value,f));
end;

function zeDimensionToString(const value:Double; const f:TzeUnitsFormat):String;
var
   _ft,_dft:double;{1}
   absvalue,_in:double;{12*_ft}
   _fts,_ins,_dfts:String;
   divide:integer;
   simplifieduprec:TUPrec;
begin
  //result:='fuckoff';exit;
  //';;Pattern length %f'#13#10'%s';
  case f.uformat of
     LUScientific:begin
                    result:=FloatToStrF(value,ffexponent,ord(f.uprec)+1,2)
                  end;
        LUDecimal:begin
                       //str(value:0:ord(f.uprec),result);
                       result:=MyFloatToStr(value,f.uprec,f.DeciminalSeparator,f.RemoveTrailingZeros);
                       {if f.uprec<>UPrec0 then
                                              rtz(result);}
                  end;
    LUEngineering:begin
                       absvalue:=abs(value);
                       _in:=floor(absvalue/12);
                       _ft:=absvalue-12*_in;
                       if _in<>0 then
                         begin
                           //str(_in:0:0,_ins);
                           _ins:=MyFloatToStr0(_in);
                           //rtz(_ins);
                         end;
                       //str(_ft:0:ord(f.uprec),_fts);
                       _fts:=MyFloatToStr(_ft,f.uprec,f.DeciminalSeparator,f.RemoveTrailingZeros);
                       {if f.uprec<>UPrec0 then
                                              rtz(_fts);}
                       if _in<>0 then
                                     begin
                                       if f.umode=UMWithSpaces then
                                                                   result:=format('%s''-%s"',[_ins,_fts])
                                                               else
                                                                   result:=format('%s''%s"',[_ins,_fts]);
                                     end
                                 else
                                     result:=format('%s"',[_fts]);
                       if sign(value)=-1 then
                                             result:='-'+result;
                  end;
  LUArchitectural:begin
                       simplifieduprec:=f.uprec;
                       absvalue:=abs(value);
                       _in:=floor(absvalue/12);
                       _ft:=absvalue-12*_in;
                       _dft:=floor(_ft);
                       _ft:=_ft-_dft;
                       divide:=round(_ft*fractions[f.uprec]);
                       if {divide=1}divide=fractions[f.uprec] then
                                     begin
                                          _dft:=_dft+1;
                                          divide:=0;
                                     end;
                       if _in<>0 then
                         begin
                           //str(_in:0:0,_ins);
                           _ins:=MyFloatToStr0(_in);
                           //rtz(_ins);
                         end;
                       if _dft<>0 then
                         begin
                           //str(_dft:0:0,_dfts);
                           _dfts:=MyFloatToStr0(_dft);
                           //rtz(_dfts);
                         end;
                       if divide<>0 then
                         begin
                            while (divide and 1)=0 do
                              begin
                                   divide:=divide shr 1;
                                   simplifieduprec:=pred(simplifieduprec);
                              end;
                           _fts:=inttostr(divide)+'/'+inttostr(fractions[simplifieduprec])+'"';
                         end;
                       if (_in=0)and(_dft=0)and(divide=0) then
                                                   exit('0"')
                  else if (_in<>0)and(_dft=0)and(divide=0)then
                                                   result:=format('%s''',[_ins])
                  else if (_in=0)and(_dft<>0)and(divide=0)then
                                                   result:=format('%s"',[_dfts])
                  else if (_in=0)and(_dft=0)and(divide<>0)then
                                                   result:=_fts
                  else if (_in<>0)and(_dft<>0)and(divide=0)then
                                                               begin
                                                                 if f.umode=UMWithSpaces then
                                                                                             result:=format('%s''-%s"',[_ins,_dfts])
                                                                                         else
                                                                                             result:=format('%s''%s"',[_ins,_dfts]);
                                                               end
                  else if (_in<>0)and(_dft=0)and(divide<>0)then
                                                               begin
                                                                 if f.umode=UMWithSpaces then
                                                                                             result:=format('%s''-0 %s',[_ins,_fts])
                                                                                         else
                                                                                             result:=format('%s''0-%s',[_ins,_fts]);
                                                               end
                  else if (_in=0)and(_dft<>0)and(divide<>0)then
                                                               begin
                                                                 if f.umode=UMWithSpaces then
                                                                                             result:=format('%s %s',[_dfts,_fts])
                                                                                         else
                                                                                             result:=format('%s-%s',[_dfts,_fts]);
                                                               end
                  else if (_in<>0)and(_dft<>0)and(divide<>0)then
                                                            begin
                                                   if f.umode=UMWithSpaces then
                                                                   result:=format('%s''-%s %s',[_ins,_dfts,_fts])
                                                               else
                                                                   result:=format('%s''%s-%s',[_ins,_dfts,_fts]);
                                                            end;
                       if sign(value)=-1 then
                                             result:='-'+result;
                  end;
     LUFractional:begin
                        simplifieduprec:=f.uprec;
                        absvalue:=abs(value);
                        _in:=floor(absvalue);
                        _ft:=absvalue-_in;
                        divide:=round(_ft*fractions[f.uprec]);
                        if {divide=1}divide=fractions[f.uprec] then
                                      begin
                                           _in:=_in+1;
                                           divide:=0;
                                      end;
                        if _in<>0 then
                          begin
                            //str(_in:0:0,_ins);
                            _ins:=MyFloatToStr0(_in);
                            //rtz(_ins);
                          end;
                        if divide<>0 then
                          begin
                             while (divide and 1)=0 do
                               begin
                                    divide:=divide shr 1;
                                    simplifieduprec:=pred(simplifieduprec);
                               end;
                            _fts:=inttostr(divide)+'/'+inttostr(fractions[simplifieduprec])
                          end;
                        if (_in=0)and(divide=0) then
                                                    exit('0')
                   else if (_in<>0)and(divide=0)then
                                                    result:=_ins
                   else if (_in=0)and(divide<>0)then
                                                    result:=_fts
                   else if (_in<>0)and(divide<>0)then
                                                    if f.umode=UMWithSpaces then
                                                                    result:=format('%s %s',[_ins,_fts])
                                                                else
                                                                    result:=format('%s-%s',[_ins,_fts]);
                        if sign(value)=-1 then
                                              result:='-'+result;

                  end;
  end;
end;
initialization
   {$IFDEF DELPHI}WorkingFormatSettings:=FormatSettings;{$ENDIF}
   {$IFNDEF DELPHI}WorkingFormatSettings:=DefaultFormatSettings;{$ENDIF}
end.
