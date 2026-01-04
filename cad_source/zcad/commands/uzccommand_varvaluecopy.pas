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
unit uzccommand_VarValueCopy;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  Controls,
  SysUtils,
  uzbpaths,
  uzccmdinfoform,
  uzccommandsabstract,uzccommandsimpl,
  uzctnrVectorBytesStream,
  uzeentity,
  gzctnrVectorTypes,
  uzcenitiesvariablesextender,
  uzcinterface,
  uzcstrconsts,
  uzcdrawings,
  UUnitManager,
  UGDBSelectedObjArray,varmandef,uzeroot,UGDBOpenArrayOfPV,uzgldrawcontext,
  uzelongprocesssupport,
  uzctranslations,uzcuitypes;

implementation

function VarValueCopy_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  pEntity:PGDBObjEntity;
  ir:itrec;
  Count:integer;
  psd:PSelectedObjDesc;
  VarFrom,VarTo:string;
  entVarExt:TVariablesExtender;
  FromPVD,ToPVD:pvardesk;
  ents:GDBObjOpenArrayOfPV;
  DC:TDrawContext;
begin
  if operands='' then begin
    zcUI.TextMessage('Command must have arguments',TMWOHistoryOut);
    exit(cmd_ok);
  end;
  if drawings.GetCurrentDWG.SelObjArray.Count=0 then begin
    zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    exit(cmd_ok);
  end;
  VarTo:=operands;
  GetPartOfPath(VarFrom,VarTo,',');
  if VarFrom='' then begin
    zcUI.TextMessage('VarFrom=""',TMWOHistoryOut);
    exit(cmd_ok);
  end;
  if VarTo='' then begin
    zcUI.TextMessage('VarTo=""',TMWOHistoryOut);
    exit(cmd_ok);
  end;

  ents.init(drawings.GetCurrentDWG.SelObjArray.Count);

  try
    Count:=0;
    psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
    if psd<>nil then
      repeat
        pEntity:=psd^.objaddr;
        if (pEntity^.Selected) then begin
          entVarExt:=pEntity^.GetExtension<TVariablesExtender>;
          if entVarExt<>nil then begin
            FromPVD:=entVarExt.entityunit.FindVariable(VarFrom,True);
            ToPVD:=entVarExt.entityunit.FindVariable(VarTo,True);
            if (FromPVD<>nil)and(ToPVD<>nil) then begin
              ToPVD^.Data.PTD^.SetValueFromString(
                ToPVD^.Data.Addr.Instance,FromPVD^.GetValueAsString);
              ents.PushBackData(pEntity);
              Inc(Count);
            end;
          end;
        end;
        psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
      until psd=nil;
    zcUI.TextMessage(format(rscmNEntitiesProcessed,[Count]),TMWOHistoryOut);
    if Count>0 then begin
      dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
      DoFormat(drawings.GetCurrentROOT^,ents,drawings.GetCurrentROOT.ObjToConnectedArray,
        drawings.GetCurrentDwg^,DC,LPSHEmpty,[]);
    end;
  finally
    Result:=cmd_ok;
    ents.Clear;
    ents.done;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  //VarValueCopy(NMO_BaseName,NMO_Suffix)
  CreateZCADCommand(@VarValueCopy_com,'VarValueCopy',CADWG or CASelEnts,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
