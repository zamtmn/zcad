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

  TOSnapModeControl=(On,Off,AsOwner);
  TTextJustify=(jstl(*'TopLeft'*),
                jstc(*'TopCenter'*),
                jstr(*'TopRight'*),
                jsml(*'MiddleLeft'*),
                jsmc(*'MiddleCenter'*), //СерединаЦентр
                jsmr(*'MiddleRight'*),
                jsbl(*'BottomLeft'*),
                jsbc(*'BottomCenter'*),
                jsbr(*'BottomRight'*),
                jsbtl(*'Left'*),
                jsbtc(*'Center'*),
                jsbtr(*'Right'*));

  TZCCodePage=(ZCCPINVALID,ZCCP874,ZCCP932,ZCCP936,ZCCP949,ZCCP950,
    ZCCP1250,ZCCP1251,ZCCP1252,ZCCP1253,ZCCP1254,ZCCP1255,ZCCP1256,
    ZCCP1257,ZCCP1258);
  PTZCCodePage=^TZCCodePage;

  GDBSnap2D=record
    Base:TzePoint2d;(*'Base'*)
    Spacing:TzePoint2d;(*'Spacing'*)
  end;
  PGDBSnap2D=^GDBSnap2D;

  GDBPiece=record
    lbegin:TzePoint3d;
    dir:TzeVector3d;
    lend:TzePoint3d;
  end;

  TImageDegradation=record
    RD_ID_Enabled:PBoolean;(*'Enabled'*)
    RD_ID_CurrentDegradationFactor:PDouble;(*'Current degradation factor'*)(*oi_readonly*)
    RD_ID_MaxDegradationFactor:PDouble;(*'Max degradation factor'*)
    RD_ID_PrefferedRenderTime:PInteger;(*'Prefered rendertime'*)
  end;

  TDCableMountingMethod=string;

implementation

end.
