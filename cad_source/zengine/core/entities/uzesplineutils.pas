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

unit uzeSplineUtils;
{$INCLUDE zengineconfig.inc}

interface
uses LCLProc,uzegluinterface,uzeentityfactory,uzgldrawcontext,uzgloglstatemanager,gzctnrVector,
     UGDBPoint3DArray,uzedrawingdef,uzecamera,UGDBVectorSnapArray,
     uzestyleslayers,uzeentsubordinated,uzeentcurve,
     uzeentity,uzctnrVectorBytes,uzbtypes,uzeconsts,uzglviewareadata,
     gzctnrVectorTypes,uzegeometrytypes,uzegeometry,uzeffdxfsupport,sysutils,
     uzMVReader,uzCtnrVectorpBaseEntity;
type
  TKnotsVector=object(GZVector<Single>)
  end;
  TCPVector=object(GZVector<GDBvertex4S>)
  end;
implementation
end.
