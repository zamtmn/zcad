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

{$Include zengineconfig.inc}

interface

uses
  SysUtils,freetypehdyn,
  uzbLogIntf,
  uzeFontFileFormatTTFBackend;

implementation

initialization
 {$IfDef USEFREETYPETTFIMPLEMENTATION}
  //если LazFreeType не включен по умолчанию
  if not sysvarTTFUseLazFreeTypeImplementation then begin
    try
      try
        //пытаемся занрузить FreeType
        InitializeFreetype(FreeTypeDLL);
      except
        on E: Exception do begin
         {$IfDef USELAZFREETYPETTFIMPLEMENTATION}
          //если LazFreeType доступен
          //тихо ругаемся в лог, включаем LazFreeType
          zDebugLn('{EH}Exception in InitializeFreetype(FreeTypeDLL) with msg "%s", Set sysvarTTFUseLazFreeTypeImplementation to True',[e.Message]);
          sysvarTTFUseLazFreeTypeImplementation:=True;
         {$Else}
          //если LazFreeType не доступен
          //громко ругаемся в лог и окно, работаем дальше, но с TTF работать будет нечем
          zDebugLn('{EM}Exception in InitializeFreetype(FreeTypeDLL) with msg "%s", TTF fonts won''t work',[e.Message]);
         {$EndIf}
        end;
      end;
    finally
      ReleaseFreetype;
    end;
  end;
 {$EndIf}
end.
