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
{$IfDef FPC}
  {$Codepage UTF8}
  {$Mode objfpc}{$H+}
{$ENDIF}
unit uzcCommand_Find;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzeTypes,
  uzegeometry,
  uzeentity,uzeenttext,
  URecordDescriptor,typedescriptors,Varman,gzctnrVectorTypes,
  uzeparserenttypefilter,uzeparserentpropfilter,
  uzelongprocesssupport,uzeparser,uzcoimultiproperties,
  uzcoimultipropertiesutil,varmandef,Masks,uzcregother,
  uzeparsercmdprompt,uzcinterface,uzcdialogsfiles,
  uzcEnitiesVariablesExtender,UGDBOpenArrayOfPV,UGDBSelectedObjArray,
  uzeconsts,uzcstrconsts,LazUTF8,
  uzeExtdrAbstractDrawingExtender,uzedrawingsimple,uzedrawingabstract,uzbPaths,
  gzctnrSTL;

const
  CMDNFind='Find';
  CMDNFindFindParams='FindParams';

type
  TCheckFuncType=(CFCheckEntity,CFCheckText);
  //                  |где ищем                  |что ищем (в двух вариантах utf8 и utf16)      | ответ от сравнения, например предложения
  //                  ˅                          ˅                                              ˅ озамене при проверке орфографии
  TCheckStrU=function(FindIn:UnicodeString;const TextA:Ansistring;const TextU:UnicodeString;var Details:String;const NeedDetails:Boolean):boolean;
  TCheckStrA=function(FindIn:Ansistring;   const TextA:Ansistring;const TextU:UnicodeString;var Details:String;const NeedDetails:Boolean):boolean;
  TCheckEnt =function(PEntity:pGDBObjEntity;                                                var Details:String;const NeedDetails:Boolean):boolean;
  TFindProcData=record
    CheckStrU:TCheckStrU;
    case CheckFuncType:TCheckFuncType of
      CFCheckText:(CheckStrA:TCheckStrA);
      CFCheckEntity:(CheckEnt:TCheckEnt);
  end;

  TFindProcKeyType=string;

procedure RegisterCheckStrProc(AKey:TFindProcKeyType;ACheckStr:TCheckStrA;ACheckUStr:TCheckStrU=nil);
procedure RegisterCheckEntProc(AKey:TFindProcKeyType;ACheckEnt:TCheckEnt);

procedure ShowFindCommandParams;
function Find_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

resourcestring
  RSFCPOptions='Options';
    RSFCPOptionsCaseSensitive='Case sensitive';
    RSFCPOptionsWholeWords='Whole words';
    RSFCPOptionsUseWildcards='Use wildcards';
  RSFCPArea='Area';
    RSFCPAreaInSelection='In selection';
    RSFCPAreaInTextContent='In text content';
    RSFCPAreaInTextTemplate='In text template';
    RSFCPAreaInVariables='In variables';
    RSFCPAreaVariables='Variables';
  RSFCPAction='Action';
    RSFCPActionSelectResult='Select result';

  RSTSelectResultSelect='Create selection';
  RSTSelectResultAddToSelection='Add to selection';
  RSTSelectResultNohhing='Nothing';

const
  WordBreakChars = [#0..#31,'.', ',', ';', ':', '"', '''', '!', '?', '[', ']',
                  '(', ')', '{', '}', '^', '-', '=', '+',  '*', '/', '\', '|',
                  ' '];

type
  TFindProcsRegister=specialize GKey2DataMap<TFindProcKeyType,TFindProcData>;
  //** Тип данных для отображения в инспекторе опций
  TCompareOptions=record
    CaseSensitive:boolean;
    WholeWords:boolean;
    UseWildcards:boolean;
  end;
  TSearhArea=record
    InSelection:boolean;
    InTextContent:boolean;
    InTextTemplate:boolean;
    InVariables:boolean;
    Variables:string;
  end;
  TSelectResult=(SR_Select,SR_AddToSelection,SR_Nohhing);
  TFindAction=record
    SelectResult:TSelectResult;
  end;
  TFindCommandParam=record
    Options:TCompareOptions;
    Area:TSearhArea;
    Action:TFindAction;
  end;

  TFindInDrawingExtender=class(TAbstractDrawingExtender)
    Finded:GDBObjOpenArrayOfPV;
    Current:Integer;
    fd:TFindProcData;
    constructor Create(pEntity:TAbstractDrawing);override;
  end;

var
  FindCommandParam:TFindCommandParam; //**<  Переменная содержащая опции команды
  FindProcsRegister:TFindProcsRegister;

procedure CreateFindProcsRegisterIfNeed;
begin
  if FindProcsRegister=nil then
    FindProcsRegister:=TFindProcsRegister.Create;
end;

procedure RegisterCheckStrProc(AKey:TFindProcKeyType;ACheckStr:TCheckStrA;ACheckUStr:TCheckStrU=nil);
var
  fd:TFindProcData;
begin
  CreateFindProcsRegisterIfNeed;
  fd.CheckStrU:=ACheckUStr;
  fd.CheckFuncType:=CFCheckText;
  fd.CheckStrA:=ACheckStr;
  FindProcsRegister.RegisterKey(AKey,fd);
end;
procedure RegisterCheckEntProc(AKey:TFindProcKeyType;ACheckEnt:TCheckEnt);
var
  fd:TFindProcData;
begin
  CreateFindProcsRegisterIfNeed;
  fd.CheckStrU:=nil;
  fd.CheckFuncType:=CFCheckEntity;
  fd.CheckEnt:=ACheckEnt;
  FindProcsRegister.RegisterKey(AKey,fd);
end;

constructor TFindInDrawingExtender.Create(pEntity:TAbstractDrawing);
begin
  Finded.init(10);
  Current:=-1;
end;

function GetFindCommandParam:PUserTypeDescriptor;
begin
  result:=SysUnit^.TypeName2PTD('TFindCommandParam');
  if result=nil then begin
    result:=SysUnit^.RegisterType(TypeInfo(FindCommandParam));
    SysUnit^.SetTypeDesk(TypeInfo(TSelectResult),[RSTSelectResultSelect,RSTSelectResultAddToSelection,RSTSelectResultNohhing],[FNUser]);
    SysUnit^.SetTypeDesk(TypeInfo(FindCommandParam),[RSFCPOptions,RSFCPArea,RSFCPAction],[FNUser]);
    SysUnit^.SetTypeDesk(TypeInfo(TCompareOptions),[RSFCPOptionsCaseSensitive,RSFCPOptionsWholeWords,RSFCPOptionsUseWildcards],[FNUser]);
    SysUnit^.SetTypeDesk(TypeInfo(TSearhArea),[RSFCPAreaInSelection,RSFCPAreaInTextContent,RSFCPAreaInTextTemplate,RSFCPAreaInVariables,RSFCPAreaVariables],[FNProgram]);
    SysUnit^.SetTypeDesk(TypeInfo(TFindAction),[RSFCPActionSelectResult],[FNProgram]);
  end;
end;

procedure ShowFindCommandParams;
begin
  zcShowCommandParams(GetFindCommandParam,@FindCommandParam);
end;

function FindCommandParam_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  ShowFindCommandParams;
  result:=cmd_ok;
end;

function FCheckStrU(FindIn:UnicodeString;const TextA:Ansistring;const TextU:UnicodeString;var Details:String;const NeedDetails:Boolean):boolean;overload;
var
  i:integer;
begin
  if not FindCommandParam.Options.CaseSensitive then
    FindIn:=UnicodeUpperCase(FindIn);
  if FindCommandParam.Options.UseWildcards then begin
    result:=MatchesMask(AnsiString(FindIn),TextA)
  end else begin
    i:=pos(TextU,FindIn);
    result:=i>0;
    if result and FindCommandParam.Options.WholeWords then begin
      if i>1 then
        result:=(ord(FindIn[i-1])<256)and(FindIn[i-1] in WordBreakChars);
      if result then
        if i+length(TextU)<=length(FindIn) then
          result:=(ord(FindIn[i+length(TextU)])<256)and(FindIn[i+length(TextU)] in WordBreakChars);
    end;
  end;
end;
function FCheckStrA(FindIn:Ansistring;const TextA:Ansistring;const TextU:UnicodeString;var Details:String;const NeedDetails:Boolean):boolean;overload;
var
  i:integer;
begin
  if not FindCommandParam.Options.CaseSensitive then
    FindIn:=UTF8UpperCase(FindIn);
  if FindCommandParam.Options.UseWildcards then begin
    result:=MatchesMask(FindIn,TextA)
  end else begin
    i:=pos(TextA,FindIn);
    result:=i>0;
    if result and FindCommandParam.Options.WholeWords then begin
      if i>1 then
        result:=FindIn[i-1] in WordBreakChars;
      if result then
        if i+length(textA)<=length(FindIn) then
          result:=FindIn[i+length(textA)] in WordBreakChars;
    end;
  end;
end;

function CheckEntity(const pv:pGDBObjEntity;const fd:TFindProcData;const TextA:Ansistring;const TextU:UnicodeString;var details:string;const NeedDetails:Boolean):boolean;
var
  pvt:TObjID;
  pentvarext:TVariablesExtender;
  vars,&var:string;
  v:pvardesk;
begin
  pvt:=pv^.GetObjType;
  result:=False;
  case fd.CheckFuncType of
    CFCheckText:begin
      if (pvt=GDBMTextID)or(pvt=GDBTextID) then begin
        if FindCommandParam.Area.InTextContent then begin
          if fd.CheckStrU<>nil then
            result:=fd.CheckStrU(PGDBObjText(pv)^.Content,TextA,TextU,details,NeedDetails)
          else
            result:=fd.CheckStrA(AnsiString(PGDBObjText(pv)^.Content),TextA,TextU,details,NeedDetails)
        end;
        if not result then
          if FindCommandParam.Area.InTextTemplate then begin
            if fd.CheckStrU<>nil then
              result:=fd.CheckStrU(PGDBObjText(pv)^.Template,TextA,TextU,details,NeedDetails)
            else
              result:=fd.CheckStrA(AnsiString(PGDBObjText(pv)^.Template),TextA,TextU,details,NeedDetails)
          end;
      end;
      if not result then
        if (FindCommandParam.Area.InVariables)and(FindCommandParam.Area.Variables<>'') then begin
          pentvarext:=pv^.specialize GetExtension<TVariablesExtender>;
          if pentvarext<>nil then begin
            vars:=FindCommandParam.Area.Variables;
            repeat
              GetPartOfPath(&var,vars,';');
              v:=pentvarext.entityunit.FindVariable(&var);
              if v<>nil then begin
                &var:=v^.data.PTD^.GetValueAsString(v^.data.Addr.Instance);
                result:=fd.CheckStrA(&var,TextA,TextU,details,NeedDetails);
              end;
            until (vars='')or result;
          end;
        end;
    end;
    CFCheckEntity:
      result:=fd.CheckEnt(pv,details,NeedDetails);
  end;
end;

procedure FindInArray(const fd:TFindProcData;const text:string; constref arr:GDBObjOpenArrayOfPV;var Finded:GDBObjOpenArrayOfPV);
var
  pv:pGDBObjEntity;
  ir:itrec;
  details:string;
begin
  pv:=arr.beginiterate(ir);
  if pv<>nil then
  repeat
    if CheckEntity(pv,fd,AnsiString(text),UnicodeString(text),details,false) then
      Finded.PushBackData(pv);
    pv:=arr.iterate(ir);
  until pv=nil;
end;


procedure FindInSelection(const fd:TFindProcData;const text:string; PSelArr:PGDBSelectedObjArray; var Finded:GDBObjOpenArrayOfPV);
var
  Selection:GDBObjOpenArrayOfPV;
  ir:itrec;
  psd:pselectedobjdesc;
begin
  Selection.init(PSelArr^.Count);
  psd:=PSelArr^.beginiterate(ir);
  if psd<>nil then repeat
    Selection.PushBackData(psd^.objaddr);
    psd:=PSelArr^.iterate(ir);
  until psd=nil;
  FindInArray(fd,text,Selection,Finded);
  Selection.Clear;
  Selection.Done;
end;

function FindFindInDrawingExtender(var dwg:TSimpleDrawing;CreateIfnotFound:boolean=true):TFindInDrawingExtender;
begin
  result:=dwg.DrawingExtensions.specialize GetExtension<TFindInDrawingExtender>;
  if (CreateIfnotFound)and(result=nil) then begin
    result:=TFindInDrawingExtender.Create(dwg);
    dwg.DrawingExtensions.AddExtension(result);
  end;
end;

procedure ShowEntity(fe:TFindInDrawingExtender);
var
  pv:pGDBObjEntity;
  Details:String;
begin
  pv:=pGDBObjEntity(fe.Finded.getData(fe.Current));
  Details:='';
  CheckEntity(pv,fe.fd,'','',Details,true);
  if Details='' then
    zcUI.TextMessage(format(rscmNEntityFrom,[fe.Current+1,fe.Finded.Count]),TMWOHistoryOut)
  else
    zcUI.TextMessage(format(rscmNEntityFromWithDetails,[fe.Current+1,fe.Finded.Count,Details]),TMWOHistoryOut);
  drawings.GetCurrentDWG^.wa.ZoomToVolume(ScaleBB(pv^.vp.BoundingBox,10));
end;

function FindNext_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  fe:TFindInDrawingExtender;
begin
  fe:=FindFindInDrawingExtender(drawings.CurrentDWG^,False);
  if fe<>nil then
    if fe.Finded.Count>0 then begin
      inc(fe.Current);
      if (fe.Current<0)or(fe.Current>=fe.Finded.Count) then
        fe.Current:=0;
      showentity(fe);
    end;
  result:=cmd_ok;
end;

function FindPrev_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  fe:TFindInDrawingExtender;
begin
  fe:=FindFindInDrawingExtender(drawings.CurrentDWG^,False);
  if fe<>nil then
    if fe.Finded.Count>0 then begin
      dec(fe.Current);
      if (fe.Current<0)or(fe.Current>=fe.Finded.Count) then
        fe.Current:=fe.Finded.Count-1;
      showentity(fe);
    end;
  result:=cmd_ok;
end;

function Find_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
const
  DefaultFindProcData:TFindProcData=(
    CheckStrU:@FCheckStrU;
    CheckFuncType:CFCheckText;
    CheckStrA:@FCheckStrA
  );
var
  Finded:GDBObjOpenArrayOfPV;
  PSelArr:PGDBSelectedObjArray;
  ir:itrec;
  pv:pGDBObjEntity;
  text:string;
  fe:TFindInDrawingExtender;
  fd:TFindProcData;
begin
  if operands<>''then begin
    if FindProcsRegister<>nil then begin
      if not FindProcsRegister.TryGetValue(operands,fd) then
        fd:=DefaultFindProcData;
    end else
      fd:=DefaultFindProcData;

    if not FindCommandParam.Options.CaseSensitive then
      text:=UTF8UpperString(operands)
    else
      text:=operands;
    Finded.init(100);
    PSelArr:=@drawings.GetCurrentDWG^.SelObjArray;
    if (FindCommandParam.Area.InSelection)and(PSelArr^.Count>0) then
      FindInSelection(fd,text,PSelArr,Finded)
    else
      FindInArray(fd,text,drawings.GetCurrentDWG^.GetCurrentROOT^.ObjArray,Finded);
    zcUI.TextMessage(format(rscmNEntitiesFounded,[Finded.Count]),TMWOHistoryOut);

    if FindCommandParam.Action.SelectResult<>SR_Nohhing then begin
      if FindCommandParam.Action.SelectResult=SR_Select then begin
        drawings.GetCurrentDWG^.SelObjArray.Free;
        drawings.GetCurrentROOT^.ObjArray.DeSelect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.GetCurrentDWG^.DeSelector);
      end;
      pv:=Finded.beginiterate(ir);
      if pv<>nil then
      repeat
        pv^.select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,@drawings.CurrentDWG^.Selector);
        pv:=Finded.iterate(ir);
      until pv=nil;
    end;

    fe:=FindFindInDrawingExtender(drawings.CurrentDWG^);
    if fe<>nil then begin
      fe.Current:=-1;
      fe.Finded.Clear;
      fe.fd:=fd;
      Finded.copyto(fe.Finded);
      result:=FindNext_com(Context,'');
    end;

    Finded.Clear;
    Finded.Done;
  end else
    zcShowCommandParams(GetFindCommandParam,@FindCommandParam);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  FindCommandParam.Options.CaseSensitive:=False;
  FindCommandParam.Options.WholeWords:=False;
  FindCommandParam.Options.UseWildcards:=False;
  FindCommandParam.Area.InSelection:=True;
  FindCommandParam.Area.InTextContent:=True;
  FindCommandParam.Area.InTextTemplate:=false;
  FindCommandParam.Area.InVariables:=false;
  FindCommandParam.Area.Variables:='NMO_Name';
  FindCommandParam.Action.SelectResult:=SR_Nohhing;

  CreateZCADCommand(@FindCommandParam_com,'FindParams',0,0);
  CreateZCADCommand(@Find_com,CMDNFind,CADWG,0);
  CreateZCADCommand(@FindNext_com,'FindNext',CADWG,0)^.overlay:=true;
  CreateZCADCommand(@FindPrev_com,'FindPrev',CADWG,0)^.overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  FindProcsRegister.Free;
end.
