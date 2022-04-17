{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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

unit uzefontshx;
{$INCLUDE zengineconfig.inc}
interface
uses uzefontbase,uzctnrVectorBytes,sysutils,
     uzegeometry;
type
{EXPORT+}
PSHXFont=^SHXFont;
{REGISTEROBJECTTYPE SHXFont}
SHXFont= object(BASEFont)
              //compiledsize:Integer;
              h,u:Byte;
              //SHXdata:TZctnrVectorBytes;
              constructor init;
              destructor done;virtual;
        end;
{EXPORT-}
implementation
//uses log;
constructor SHXFont.init;
begin
     inherited;
     u:=1;
     h:=1;
     //SHXdata.init(1024);
end;
destructor SHXFont.done;
begin
     inherited;
     //SHXdata.done;
end;
end.
