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

unit uzeTypes;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzbtypes,uzegeometrytypes;

type
  TLoadOpt=(TLOLoad,TLOMerge);
  TEntUpgradeInfo=longword;
  PExtensionData=Pointer;

  GDBStrWithPoint=record
    str:TDXFEntsInternalStringType;
    x,y,z,w:double;
  end;
  PGDBStrWithPoint=^GDBStrWithPoint;
  TDWGHandle=QWord;
  TObjID=word;

  TLayerControl=record
    Enabled:boolean;(*'Enabled'*)
    LayerName:ansistring;(*'Layer name'*)
  end;
  PTLayerControl=^TLayerControl;

  TIntegerOverrider=record
    Enable:boolean;(*'Enable'*)
    Value:integer;(*'New value'*)
  end;
  PTIntegerOverrider=^TIntegerOverrider;

  THAlign=(HALeft,HAMidle,HARight);
  PTHAlign=^THAlign;

  TVAlign=(VATop,VAMidle,VABottom);
  PTVAlign=^TVAlign;

  TAlign=(TATop,TABottom,TALeft,TARight);
  PTAlign=^TAlign;

  TAppMode=(TAMAllowDark,TAMForceDark,TAMForceLight);
  PTAppMode=^TAppMode;


  TGDBLineWeight=SmallInt;
  PTGDBLineWeight=^TGDBLineWeight;

  TGDBOSMode=Integer;
  PTGDBOSMode=^TGDBOSMode;

  TGDB3StateBool=(T3SB_Fale(*'False'*),T3SB_True(*'True'*),T3SB_Default(*'Default'*));
  PTGDB3StateBool=^TGDB3StateBool;

  TLLPrimitiveAttrib=Integer;
  PTLLVertexIndex=^TLLVertexIndex;
  TLLVertexIndex=Integer;

  TStringTreeType=String;
  PStringTreeType=^TStringTreeType;

  TENTID=TStringTreeType;
  TEentityRepresentation=TStringTreeType;
  TEentityFunction=TStringTreeType;

implementation

end.
