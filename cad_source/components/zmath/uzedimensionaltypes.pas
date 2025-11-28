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

unit uzedimensionaltypes;

interface

uses
  uzegeometrytypes;

type
{EXPORT+}
  TDimUnit=(DUScientific(*'Scientific'*),DUDecimal(*'Decimal'*),
    DUEngineering(*'Engineering'*),DUArchitectural(*'Architectural'*),
    DUFractional(*'Fractional'*),DUSystem(*'System'*));
  TDimDSep=(DDSDot,DDSComma,DDSSpace);
  PTLUnits=^TLUnits;
  TLUnits=(LUScientific(*'Scientific'*),LUDecimal(*'Decimal'*),
    LUEngineering(*'Engineering'*),LUArchitectural(*'Architectural'*),
    LUFractional(*'Fractional'*));
  PTAUnits=^TAUnits;
  TAUnits=(AUDecimalDegrees(*'Decimal degrees'*),
    AUDegreesMinutesSeconds(*'Degrees minutes seconds'*),AUGradians(*'Gradians'*),
    AURadians(*'Radians'*),AUSurveyorsUnits(*'Surveyors units'*));
  PTAngDir=^TAngDir;
  TAngDir=(ADCounterClockwise(*'Counterclockwise'*),ADClockwise(*'Clockwise'*));
  PTUPrec=^TUPrec;
  TUPrec=(UPrec0(*'0'*),UPrec1(*'0.0'*),UPrec2(*'0.00'*),UPrec3(*'0.000'*),
    UPrec4(*'0.0000'*),UPrec5(*'0.00000'*),UPrec6(*'0.000000'*),
    UPrec7(*'0.0000000'*),UPrec8(*'0.00000000'*));
  PTUnitMode=^TUnitMode;
  TUnitMode=(UMWithSpaces(*'With spaces'*),UMWithoutSpaces(*'Without spaces'*));
  {REGISTERRECORDTYPE TzeUnitsFormat}
  TzeUnitsFormat=record
    abase:TZeAngleDeg;
    adir:TAngDir;
    aformat:TAUnits;
    aprec:TUPrec;
    uformat:TLUnits;
    uprec:TUPrec;
    umode:TUnitMode;
    DeciminalSeparator:TDimDSep;
    RemoveTrailingZeros:boolean;
  end;
  {REGISTERRECORDTYPE TInsUnits}
  TInsUnits=(IUUnspecified(*'Unspecified'*),
    IUInches(*'Inches'*),
    IUFeet(*'Feet'*),
    IUMiles(*'Miles'*),
    IUMillimeters(*'Millimeters'*),
    IUCentimeters(*'Centimeters'*),
    IUMeters(*'Meters'*),
    IUKilometers(*'Kilometers'*),
    IUMicroinches(*'Microinches'*),
    IUMils(*'Mils'*),
    IUYards(*'Yards'*),
    IUAngstroms(*'Angstroms'*),
    IUNanometers(*'Nanometers'*),
    IUMicrons(*'Microns'*),
    IUDecimeters(*'Decimeters'*),
    IUDekameters(*'Dekameters'*),
    IUHectometers(*'Hectometers'*),
    IUGigameters(*'Gigameters'*),
    IUAstronomicalUnits(*'Astronomical units'*),
    IULightYears(*'Light years'*),
    IUParsecs(*'Parsecs'*));
  PTInsUnits=^TInsUnits;
{EXPORT-}
implementation

end.
