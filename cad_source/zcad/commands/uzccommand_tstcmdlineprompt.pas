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
{$IFDEF FPC}
  {$CODEPAGE UTF8}
  {$MODE DELPHI}
{$ENDIF}
unit uzccommand_tstCmdLinePrompt;
{$INCLUDE zengineconfig.inc}

interface
uses
  CsvDocument,
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,
  URecordDescriptor,typedescriptors,Varman,gzctnrVectorTypes,
  uzeparserenttypefilter,uzeparserentpropfilter,uzeentitiestypefilter,
  uzelongprocesssupport,uzeparser,uzcoimultiproperties,uzedimensionaltypes,
  uzcoimultipropertiesutil,varmandef,uzcvariablesutils,Masks,uzcregother,
  uzeparsercmdprompt,uzcinterface,uzcdialogsfiles;

resourcestring
  RSCLPDataExportWaitFile                ='Configure export ${"&[p]arams",Keys[p],StrId[CLPIdOptions]}, run ${"&[f]ile dialog",Keys[f],StrId[CLPIdFileDialog]} or enter file name (empty for default):';
  RSCLPDataExportOptions                 ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Set ${"&[e]ntities",Keys[o],StrId[CLPIdUser1]}/${"&[p]roperties",Keys[o],StrId[CLPIdUser2]} filter or export ${"&[s]cript",Keys[o],StrId[CLPIdUser3]}';
  RSCLPDataExportEntsFilterCurrentValue  ='Entities filter current value:';
  RSCLPDataExportEntsFilterNewValue      ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new entities filter:';
  RSCLPDataExportPropsFilterCurrentValue ='Properties filter current value:';
  RSCLPDataExportPropsFilterNewValue     ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new properties filter:';
  RSCLPDataExportExportScriptCurrentValue='Properties export script current value:';
  RSCLPDataExportExportScriptNewValue    ='${"&[<]<<",Keys[<],StrId[CLPIdBack]} Enter new export script:';

implementation

var
  clFilePrompt:CMDLinePromptParser.TGeneralParsedText=nil;
  clOptionsPrompt:CMDLinePromptParser.TGeneralParsedText=nil;
  clOptionsPrompt1:CMDLinePromptParser.TGeneralParsedText=nil;
  clOptionsPrompt2:CMDLinePromptParser.TGeneralParsedText=nil;
  clOptionsPrompt3:CMDLinePromptParser.TGeneralParsedText=nil;

function DataExport_com(operands:TCommandOperands):TCommandResult;
type
  TCmdMode=(CMEmpty,CMWaitFile,CMOptions,CMOptions1,CMOptions2,CMOptions3,CMExport);
var

  pv:pGDBObjEntity;
  propdata:TPropFilterData;
  ir:itrec;
  lpsh:TLPSHandle;
  inpt:String;
  gr:TGetResult;
  CmdMode:TCmdMode;
  filename:string;
  procedure SetCmdMode(Mode:TCmdMode);
  begin
    if CmdMode=Mode then
      exit;
    case Mode of
      CMWaitFile:begin
                   if clFilePrompt=nil then
                     clFilePrompt:=CMDLinePromptParser.GetTokens(RSCLPDataExportWaitFile);
                   commandmanager.SetPrompt(clFilePrompt);
                   commandmanager.ChangeInputMode([GPIempty],[]);
                 end;
       CMOptions:begin
                   if clOptionsPrompt=nil then
                     clOptionsPrompt:=CMDLinePromptParser.GetTokens(RSCLPDataExportOptions);
                   commandmanager.SetPrompt(clOptionsPrompt);
                   commandmanager.ChangeInputMode([GPIempty],[]);
                 end;
      CMOptions1:begin
                   ZCMsgCallBackInterface.TextMessage(RSCLPDataExportEntsFilterCurrentValue,TMWOHistoryOut);
                   ZCMsgCallBackInterface.TextMessage(DataExportParam.EntFilter^,TMWOHistoryOut);
                   if clOptionsPrompt1=nil then
                     clOptionsPrompt1:=CMDLinePromptParser.GetTokens(RSCLPDataExportEntsFilterNewValue);
                   commandmanager.SetPrompt(clOptionsPrompt1);
                   commandmanager.ChangeInputMode([GPIempty],[]);
                 end;
      CMOptions2:begin
                   ZCMsgCallBackInterface.TextMessage(RSCLPDataExportPropsFilterCurrentValue,TMWOHistoryOut);
                   ZCMsgCallBackInterface.TextMessage(DataExportParam.PropFilter^,TMWOHistoryOut);
                   if clOptionsPrompt2=nil then
                     clOptionsPrompt2:=CMDLinePromptParser.GetTokens(RSCLPDataExportPropsFilterNewValue);
                   commandmanager.SetPrompt(clOptionsPrompt2);
                   commandmanager.ChangeInputMode([GPIempty],[]);
                 end;
      CMOptions3:begin
                   ZCMsgCallBackInterface.TextMessage(RSCLPDataExportExportScriptCurrentValue,TMWOHistoryOut);
                   ZCMsgCallBackInterface.TextMessage(DataExportParam.Exporter^,TMWOHistoryOut);
                   if clOptionsPrompt3=nil then
                     clOptionsPrompt3:=CMDLinePromptParser.GetTokens(RSCLPDataExportExportScriptNewValue);
                   commandmanager.SetPrompt(clOptionsPrompt3);
                   commandmanager.ChangeInputMode([GPIempty],[]);
                 end;
    end;
    CmdMode:=Mode;
  end;

begin
  zcShowCommandParams(SysUnit^.TypeName2PTD('TDataExportParam'),@DataExportParam);
  CmdMode:=CMEmpty;
  SetCmdMode(CMWaitFile);
  repeat
    gr:=commandmanager.GetInput('',inpt);
       case gr of
             GRId:case commandmanager.GetLastId of
                                      CLPIdOptions:SetCmdMode(CMOptions);
                                         CLPIdBack:if CmdMode=CMOptions then
                                                     SetCmdMode(CMWaitFile)
                                                   else
                                                     SetCmdMode(CMOptions);
                                        CLPIdUser1:SetCmdMode(CMOptions1);
                                        CLPIdUser2:SetCmdMode(CMOptions2);
                                        CLPIdUser3:SetCmdMode(CMOptions3);
                                   CLPIdFileDialog:begin
                                                     filename:='';
                                                     if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Export data...') then begin
                                                       DataExportParam.FileName^:=filename;
                                                       CmdMode:=CMExport;
                                                       system.break;
                                                     end;

                                                   end;
                  end;
         GRNormal:case CmdMode of
                       CMWaitFile:begin
                                    if inpt<>'' then
                                      DataExportParam.FileName^:=inpt;
                                    CmdMode:=CMExport;
                                    system.break;
                                  end;
                       CMOptions1:begin
                                    if inpt<>'' then
                                      DataExportParam.EntFilter^:=inpt;
                                    SetCmdMode(CMOptions);
                                  end;
                       CMOptions2:begin
                                    if inpt<>'' then
                                      DataExportParam.PropFilter^:=inpt;
                                    SetCmdMode(CMOptions);
                                  end;
                       CMOptions3:begin
                                    if inpt<>'' then
                                      DataExportParam.Exporter^:=inpt;
                                    SetCmdMode(CMOptions);
                                  end;
                  end;
       end;
  until gr=GRCancel;

  if CmdMode=CMExport then begin
    EntsTypeFilter:=TEntsTypeFilter.Create;
    pt:=ParserEntityTypeFilter.GetTokens(DataExportParam.EntFilter^);
    pt.Doit(EntsTypeFilter);
    EntsTypeFilter.SetFilter;
    pt.Free;

    pet:=ExporterParser.GetTokens(DataExportParam.Exporter^);

    EntityIncluder:=ParserEntityPropFilter.GetTokens(DataExportParam.PropFilter^);
    lpsh:=LPSHEmpty;

     Data.f:=drawings.GetUnitsFormat;
     propdata.f:=Data.f;
     Data.FDoc:=TCSVDocument.Create;
       if drawings.GetCurrentDWG<>nil then
       begin
         lpsh:=LPS.StartLongProcess('DataExport',@DataExport_com,drawings.GetCurrentROOT^.ObjArray.Count);
         pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
         if pv<>nil then
         repeat
           if EntsTypeFilter.IsEntytyTypeAccepted(pv^.GetObjType) then begin
             if assigned(EntityIncluder) then begin
               propdata.CurrentEntity:=pv;
               propdata.IncludeEntity:=T3SB_Default;
               EntityIncluder.Doit(PropData);
             end else
               propdata.IncludeEntity:=T3SB_True;

             if propdata.IncludeEntity=T3SB_True then begin
               Data.CurrentEntity:=pv;
               if assigned(pet) then
                 pet.Doit(data);
             end;
           end;

           pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
           LPS.ProgressLongProcess(lpsh,ir.itc);
         until pv=nil;
       end;
    if lpsh<>LPSHEmpty then
      LPS.EndLongProcess(lpsh);
    Data.FDoc.Delimiter:=';';
    Data.FDoc.SaveToFile(DataExportParam.FileName^);
    Data.FDoc.Free;
    EntsTypeFilter.Free;
    EntityIncluder.Free;
  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  VU.init('test');
  VU.InterfaceUses.PushBackIfNotPresent(sysunit);

  DataExportParam.EntFilter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_EntFilter','AnsiString').data.Addr.Instance;
  if DataExportParam.EntFilter^='' then
    DataExportParam.EntFilter^:='IncludeEntityName(''Cable'');'#13#10'IncludeEntityName(''Device'')';
  DataExportParam.PropFilter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_PropFilter','AnsiString').data.Addr.Instance;
  //if DataExportParam.PropFilter^='' then
  //  DataExportParam.PropFilter:='';
  DataExportParam.Exporter:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_Exporter','AnsiString').data.Addr.Instance;
  if DataExportParam.Exporter^='' then
    DataExportParam.Exporter^:='DoIf(SameMask(%%(''EntityName''),''Device''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''Position'',@@(''Position'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Device''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''Power'',@@(''Power'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Cable''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''AmountD'',@@(''AmountD'')))'+
                           #10+'DoIf(SameMask(%%(''EntityName''),''Cable''),Export(%%(''EntityName''),''NMO_Name'',@@(''NMO_Name''),''CABLE_Segment'',@@(''CABLE_Segment'')))';
  DataExportParam.FileName:=savedunit.FindOrCreateValue('tmpCmdParamSave_DataExportParam_FileName','AnsiString').data.Addr.Instance;
  if DataExportParam.FileName^='' then
    DataExportParam.FileName^:='d:\test.csv';

  SysUnit^.RegisterType(TypeInfo(TDataExportParam));//регистрируем тип данных в зкадном RTTI
  SysUnit^.SetTypeDesk(TypeInfo(TDataExportParam),['EntFilter','PropFilter','Exporter','FileName'],[FNProgram]);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел

  CreateCommandFastObjectPlugin(@DataExport_com,'DataExport',  CADWG,0);


  ExporterParser:=TExporterParser.create;
  BracketTockenId:=ExporterParser.RegisterToken('(','(',')',nil,ExporterParser,TGONestedBracke or TGOIncludeBrackeOpen or TGOSeparator);
  ExporterParser.RegisterToken('Export',#0,#0,TExport,nil,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('DoIf',#0,#0,TDoIf,ExporterParser,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('SameMask',#0,#0,TSameMask,ExporterParser,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('%%',#0,#0,TGetEntParam,ExporterParser,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('@@',#0,#0,TGetEntVariable,ExporterParser,TGOWholeWordOnly,BracketTockenId);
  ExporterParser.RegisterToken('''','''','''',ExporterParser.TParserTokenizer.TStringProcessor,nil,TGOIncludeBrackeOpen);
  ExporterParser.RegisterToken(',',#0,#0,nil,nil,TGOSeparator);
  ExporterParser.RegisterToken(';',#0,#0,nil,nil,TGOSeparator);
  ExporterParser.RegisterToken('\P',#0,#0,nil,nil,TGOSeparator);
  ExporterParser.RegisterToken(' ',#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ExporterParser.RegisterToken(#10,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);
  ExporterParser.RegisterToken(#13,#0,#0,nil,nil,TGOSeparator or TGOCanBeOmitted);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ExporterParser.Free;
  VU.done;
  if clFilePrompt<>nil then
    clFilePrompt.Free;
  if clOptionsPrompt<>nil then
    clOptionsPrompt.Free;
end.
