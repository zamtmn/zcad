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
{$mode delphi}
unit uzcCommand_ZCTable2CSV;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,Classes,
  LazUTF8,
  uzbEncoding,
  gzctnrVectorTypes,
  uzeTypes,uzeconsts,uzeEntTable,
  uzccommandsabstract,uzccommandsimpl,
  uzcLog,uzcinterface,uzcstrconsts,uzcdialogsfiles;

implementation

procedure WriteBOM(const fcp:TCodePage;const fs:TFileStream);
var
  fileBOM:rawbytestring;
begin
  fileBOM:=getBOM(fcp);
  if fileBOM<>'' then
    fs.Write(fileBOM[1],Length(fileBOM)*SizeOf(fileBOM[1]));
end;

procedure WriteTableToFile(const AFileName:string;constref ATable:GDBObjTable);
var
  ir,irCol:itrec;
  sb:TDXFEntsInternalStringBuilder;
  pstr:PDXFEntsInternalStringType;
  PLine:PDXFEntsInternalVectorStrings;
  fcp:TCodePage;
  fs:TFileStream;
  encoding:TEncoding;
  bytes:TBytes;
begin
  fs:=TFileStream.Create(UTF8ToSys(AFileName),fmCreate or fmOpenWrite);
  sb:=TDXFEntsInternalStringBuilder.Create;
  try
    fcp:=TXTCodePage(TxtFileSaveCodePage);
    encoding:=getEncoding(fcp);
    if IsNeedBOM(fcp) then
      WriteBOM(fcp,fs);
    PLine:=ATable.tbl.beginiterate(ir);
    if PLine<>nil then
      repeat
        sb.Length:=0;
        pstr:=PLine.beginiterate(irCol);
        if pstr<>nil then
          repeat
            if (irCol.itc>0)or(sb.Length>0) then
              sb.Append(';');
            sb.Append(pstr^);
            pstr:=PLine.iterate(irCol);
          until pstr=nil;
        if sb.Length>0 then
          sb.Append(#13#10);
        bytes:=encoding.GetBytes(sb.ToString);
        fs.Write(bytes[0],Length(bytes)*SizeOf(bytes[0]));
        PLine:=ATable.tbl.iterate(ir);
      until PLine=nil;
  finally
    sb.Free;
    fs.Free;
  end;
end;

function ZCTable2CSV_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  FileName:string='';
begin
  if Context.PDWG<>nil then begin
    if (Context.PDWG^.wa.param.seldesc.Selectedobjcount=1)and(Context.PDWG^.wa.param.seldesc.LastSelectedObject<>nil)and
      (PGDBObjTable(Context.PDWG^.wa.param.seldesc.LastSelectedObject)^.GetObjType=GDBTableID) then begin
      if SaveFileDialog(FileName,cCSVExtension,CSVFileFilter,'',rsSaveFile) then
        WriteTableToFile(FileName,PGDBObjTable(Context.PDWG^.wa.param.seldesc.LastSelectedObject)^);
    end else begin
      zcUI.TextMessage(Format(rscmSel_S_BeforeComm,['ZCAD table']),TMWOHistoryOut);;
    end;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@ZCTable2CSV_com,'ZCTable2CSV',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
