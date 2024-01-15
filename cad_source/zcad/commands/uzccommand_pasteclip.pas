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
{$MODE OBJFPC}{$H+}
unit uzccommand_PasteClip;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzcdrawings,
  uzccommandsabstract,uzccommandsimpl,
  uzccommand_copy,
  uzccommandsmanager,
  uzeentity,uzcLog,
  uzcstrconsts,uzeconsts,
  uzcinterface,
  uzccommand_copyclip,
  uzccmdfloatinsert,
  Clipbrd,
  LCLType,
  Classes,
  uzeffmanager,
  LazUTF8,
  SysUtils,
  uzbtypes,
  uzeffdxf;

type
  PasteClip_com =  object(FloatInsert_com)
    procedure Command(Operands:TCommandOperands); virtual;
  end;

var
  PasteClip:PasteClip_com;

implementation

procedure pasteclip_com.Command(Operands:TCommandOperands);
var
  zcformat:TClipboardFormat;
  tmpStr:AnsiString;
  tmpStream:TMemoryStream;
  tmpSize:LongInt;
  zdctx:TZDrawingContext;
begin
  zcformat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
  if clipboard.HasFormat(zcformat) then begin
    tmpStr:='';
    tmpStream:=TMemoryStream.create;
    try
      clipboard.GetFormat(zcformat,tmpStream);
      tmpSize:=tmpStream.Seek(0,soFromEnd);
      setlength(tmpStr,tmpSize);
      tmpStream.Seek(0,soFromBeginning);
      tmpStream.ReadBuffer(tmpStr[1],tmpSize);
    finally
      tmpStream.free;
    end;
    if fileexists(utf8tosys(tmpStr)) then begin
      zdctx.CreateRec(drawings.GetCurrentDWG^,drawings.GetCurrentDWG^.ConstructObjRoot,TLOMerge,drawings.GetCurrentDWG^.CreateDrawingRC);
      addfromdxf(tmpStr,zdctx);
    end;
    drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
    ZCMsgCallBackInterface.TextMessage(rscmNewBasePoint,TMWOHistoryOut);
  end else
    ZCMsgCallBackInterface.TextMessage(rsClipboardIsEmpty,TMWOHistoryOut);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  PasteClip.init('PasteClip',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
