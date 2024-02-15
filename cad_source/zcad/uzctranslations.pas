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

unit uzcTranslations;
{$INCLUDE zengineconfig.inc}

interface
uses uzbpaths,uzbstrproc,LazUTF8,gettext,translations,
     fileutil,LResources,sysutils,uzbLogTypes,uzcLog,uzbLog,forms,
     Classes, typinfo,uzcsysparams{,uzcLog};

const
  ZCADTranslatedPOFileName='zcad.%s.po';
  ZCADPOFileName='zcad.po';
  ZCADRTTranslatedPOFileName='rtzcad.%s.po';
  ZCADRTPOFileName='rtzcad.po';
  ZCADRTBackupPOFileName='rtzcad.po.backup';
  ZCADPOFileNotFound='Founf command line swith "UpdatePO". File "%s" not found. STOP!';
  identpref='zcadexternal.';

type
  TmyPOFile = class(TPOFile)
      function FindByIdentifier(const Identifier: String):TPOFileItem;
      procedure Add(const Identifier,OriginalValue,TranslatedValue,
                          Comments,Context,Flags,PreviousID: string;
                    SetFuzzy:boolean=false;LineNr:Integer=-1);
      function Translate(const Identifier, OriginalValue: String): String;
      function exportcompileritems(sourcepo:TPOFile):integer;
  end;

  TPoTranslator=class(TAbstractTranslator)
    public
      procedure TranslateStringProperty(Sender:TObject;const Instance: TPersistent;
                                        PropInfo: PPropInfo; var Content:string);override;
    end;

var
  PODirectory:String;
  Lang, FallbackLang:String;
  RunTimePO,CompileTimePO:TmyPOFile;
  actualypo:TmyPOFile;
  _UpdatePO:integer=0;
  _NotEnlishWord:integer=0;
  _DebugWord:integer=0;
  DisableTranslateCount:integer;

function InterfaceTranslate(const Identifier, OriginalValue: String): String;
function IsLatin(const Identifier:string):Boolean;
procedure DisableTranslate;
procedure EnableTranslate;

implementation

var
  TranslateLogModuleId:TModuleDesk;

procedure DisableTranslate;
begin
  inc(DisableTranslateCount);
end;
procedure EnableTranslate;
begin
  dec(DisableTranslateCount);
end;
procedure TPoTranslator.TranslateStringProperty(Sender: TObject;const Instance: TPersistent;
                                                PropInfo: PPropInfo; var Content: string);
var
  s: String;
begin
  if not Assigned(CompileTimePO) then exit;
  if not Assigned(PropInfo) then exit;
{Нужно ли нам это?}
  if Instance is TComponent then
   if csDesigning in (Instance as TComponent).ComponentState then exit;
{:)}
  if (AnsiUpperCase(PropInfo^.PropType^.Name)<>'TTRANSLATESTRING') then exit;
  s:=CompileTimePO.Translate(Content,Content);
  if s<>'' then Content:=s;
end;

function TmyPOFile.FindByIdentifier(const Identifier: String):TPOFileItem;
begin
  result:=FindPoItem(Identifier);
  //uncoment for lazarus < r57491
  //result:=TPOFileItem({FIdentifierToItem}FIdentLowVarToItem.Data[Identifier]);
end;
function TmyPOFile.exportcompileritems(sourcepo:TPOFile):integer;
var
  j:integer;
  ident:string;
  Item,NewItem: TPOFileItem;
begin
  for j:=0 to Fitems.Count-1 do begin
    item:=TPOFileItem(FItems[j]);
    ident:=item.IdentifierLow;
    if (pos('~',ident)<=0)
    and(pos('.',ident)>0) then begin
      NewItem:=nil;
      sourcepo.FillItem(NewItem,ident, item.Original, item.Translation, item.Comments,
                    item.Context, item.Flags,'');
      //uncoment if Lazarus<r57425
      //sourcepo.Add(ident, item.Original, item.Translation, item.Comments,
      //              item.Context, item.Flags,'');
    end;
  end;
  result:=items.Count-sourcepo.items.Count;
end;
function TmyPOFile.Translate(const Identifier, OriginalValue: String): String;
var
  Item: TPOFileItem;
begin
  Item:=FindPoItem(Identifier);
  //uncoment for lazarus < r57491
  //Item:=TPOFileItem({FIdentifierToItem}FIdentLowVarToItem.Data[Identifier]);
  if Item=nil then
    Item:=TPOFileItem(FOriginalToItem.Data[OriginalValue]);
  if Item<>nil then begin
    Result:=Item.Translation;
    if Result='' then Result:=OriginalValue;
  end else
    Result:=OriginalValue;
end;
procedure TmyPOFile.Add(const Identifier, OriginalValue, TranslatedValue,
  Comments, Context, Flags, PreviousID: string; SetFuzzy: boolean = false; LineNr: Integer = -1);
var
  t:boolean;
  NewItem:TPOFileItem;
begin
  t:=self.FAllEntries;
  self.FAllEntries:=true;
  NewItem:=nil;
  FillItem(NewItem,Identifier, OriginalValue, TranslatedValue, Comments,Context, Flags, PreviousID);
  //uncoment if Lazarus<r57425
  //inherited  Add(Identifier, OriginalValue, TranslatedValue, Comments,Context, Flags, PreviousID);
  self.FAllEntries:=t;
end;
procedure internalCreatePO(out CreatedPO:TmyPOFile;UpdatePOMode:Boolean;POFormat,POFileName:string);
var
   AFilename:string;
begin
  CreatedPO:=nil;
  if not UpdatePOMode then begin
    if Lang<>'' then begin
      AFilename:=Format(PODirectory + POFormat,[Lang]);
      if FileExists(AFilename) then
        CreatedPO:=TmyPOFile.Create(AFilename);
    end;
    if (FallbackLang<>'')and(not assigned(CreatedPO)) then begin
      AFilename:=Format(PODirectory + POFormat,[FallbackLang]);
      if FileExists(AFilename) then
        CreatedPO:=TmyPOFile.Create(AFilename);
    end;
    if (not assigned(RunTimePO)) then
      CreatedPO:=TmyPOFile.Create;
  end else begin
    AFilename:=(PODirectory + POFileName);
    if FileExists(AFilename) then begin
      CreatedPO:=TmyPOFile.Create(AFilename,true);
      //actualypo:=TmyPOFile.Create;
    end else begin
      programlog.LogOutFormatStr(ZCADPOFileNotFound,[AFilename],0,LM_Fatal);
      raise Exception.CreateFmt(ZCADPOFileNotFound,[AFilename]);
    end;
  end;
end;

procedure createpo;
begin
  internalCreatePO(RunTimePO,sysparam.saved.updatepo,ZCADRTTranslatedPOFileName,ZCADRTPOFileName);
  internalCreatePO(CompileTimePO,sysparam.saved.updatepo,ZCADTranslatedPOFileName,ZCADPOFileName);
  if sysparam.saved.updatepo then
    actualypo:=TmyPOFile.Create;
end;

function IsLatin(const Identifier:string):Boolean;
begin
  result:=(utf8length(Identifier)=length(Identifier));
end;

function IsNoNeedTranslate(const OriginalValue:string):Boolean;
begin
  result:=(pos('**',OriginalValue)>0)or(pos('??',OriginalValue)>0)or(pos('__',OriginalValue)=1);
end;

procedure NormalizeIdentifier(var Identifier:String);
var
  i:integer;
begin
  for i:=1 to length(Identifier) do
    case Identifier[i] of
      ':':Identifier[i]:='.';
      ' ':Identifier[i]:='_';
    end;
end;

function InterfaceTranslate( const Identifier, OriginalValue: String): String;
const nontranslatedword='InterfaceTranslate: found not translated word: identifier:"%s" originalValue:"%s"';
var
  Item: TPOFileItem;
  FullIdentifier:String;
  LatinIdentifier:boolean;
begin

  {if lowercase(Identifier)='menu~file' then begin
    Item:=nil;
  end;

  if lowercase(OriginalValue)='plan' then begin
    Item:=nil;
  end;}

  if pos(identpref,Identifier)<>1 then
    FullIdentifier:=identpref+Identifier
  else
    FullIdentifier:=Identifier;

  LatinIdentifier:=IsLatin(Identifier);

  if LatinIdentifier then
    NormalizeIdentifier(FullIdentifier);

  if DisableTranslateCount>0 then
    exit(OriginalValue);

  result:=RunTimePO.Translate(Identifier, OriginalValue);
  programlog.LogOutFormatStr('InterfaceTranslate: identifier:"%s" originalValue:"%s" translate to "%s"',[Identifier,OriginalValue,result],LM_Debug,TranslateLogModuleId);

  if sysparam.saved.updatepo then begin
    Item:=RunTimePO.FindPoItem(FullIdentifier);
    if not assigned(item) then begin
      if IsNoNeedTranslate(OriginalValue)then begin
        inc(_DebugWord);
        programlog.LogOutStr(format('InterfaceTranslate: found debug word: identifier:"%s" originalValue:"%s"',[Identifier,OriginalValue]),0,LM_Warning,TranslateLogModuleId);
      end else begin
        if LatinIdentifier and IsLatin(OriginalValue) then begin
          programlog.LogOutStr(format(nontranslatedword,[Identifier,OriginalValue]),0,LM_Warning,TranslateLogModuleId);
          RunTimePO.Add(FullIdentifier,OriginalValue, {TranslatedValue}'', {Comments}'',{Context}'', {Flags}'', {PreviousID}'');
          actualypo.Add(FullIdentifier,OriginalValue, {TranslatedValue}'', {Comments}'',{Context}'', {Flags}'', {PreviousID}'');
          inc(_UpdatePO);
        end else begin
          inc(_NotEnlishWord);
          programlog.LogOutStr(format('InterfaceTranslate: found non ASCII word: identifier:"%s" originalValue:"%s"',[Identifier,OriginalValue]),0,LM_Warning,TranslateLogModuleId);
        end;
      end;
    end else begin
      if item.Original<>OriginalValue then begin
        item.ModifyFlag('fuzzy',true);
        item.Original:=OriginalValue;
      end;
      if actualypo.FindPoItem(item.IdentifierLow)=nil then
        actualypo.Add(item.IdentifierLow,item.Original,item.Translation,item.Comments,item.Context, item.Flags,'');
    end;

  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  TranslateLogModuleId:=programlog.RegisterModule('TRANSLATOR');
  DisableTranslateCount:=0;
  PODirectory := ProgramPath+'languages/';
  GetLanguageIDs(Lang, FallbackLang); // определено в модуле gettext
  if sysparam.saved.LangOverride<>'' then begin
    Lang:=sysparam.saved.LangOverride;
    FallbackLang:='';
  end;
  createpo;
  LRSTranslator:=TPoTranslator.Create;
  if not sysparam.saved.updatepo then begin
    TranslateResourceStrings(PODirectory + ZCADTranslatedPOFileName, Lang, FallbackLang);
    TranslateUnitResourceStrings('anchordockstr', PODirectory + 'anchordockstr.%s.po', Lang, FallbackLang);
    TranslateUnitResourceStrings('lclstrconsts', PODirectory + 'lclstrconsts.%S.po', Lang, FallbackLang);
  end;

finalization
  programlog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  if assigned(actualypo) then
    freeandnil(actualypo);
  if assigned(RunTimePO) then
    freeandnil(RunTimePO);
  if assigned(CompileTimePO) then
    freeandnil(CompileTimePO);
  if assigned(LRSTranslator) then
    freeandnil(LRSTranslator);
end.
