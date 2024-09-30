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

unit uzeFontFileFormatTTFBackendFTTest;
{$INCLUDE zengineconfig.inc}
interface
uses
  sysutils,freetypehdyn,
  uzbLogIntf,
  uzeFontFileFormatTTFBackend;
implementation
initialization
 {$IF DEFINED(USEFREETYPETTFIMPLEMENTATION)}
  if not sysvarTTFUseLazFreeTypeImplementation then begin
    try
      try
        InitializeFreetype(FreeTypeDLL)
      except
        on E: Exception do begin
          zDebugLn('{E}Exception in InitializeFreetype(FreeTypeDLL) with msg "%s"',[e.Message]);
         {$IFDEF USELAZFREETYPETTFIMPLEMENTATION}
          zDebugLn('{E}Set sysvarTTFUseLazFreeTypeImplementation to True');
          sysvarTTFUseLazFreeTypeImplementation:=true;
         {$ENDIF}
        end;
      end;
    finally
      ReleaseFreetype;
    end;
  end;
{$ENDIF}
end.
