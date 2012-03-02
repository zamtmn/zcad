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

unit intftranslations;
{$INCLUDE def.inc}

interface
uses strproc,lclproc,gettext,translations,sysinfo,sysutils,fileutil,log,forms,LResources,Classes, typinfo;

type
    TmyPOFile = class(TPOFile)
                     function FindByIdentifier(const Identifier: String):TPOFileItem;
                     procedure SaveToFile(const AFilename: string);
                     procedure Add(const Identifier, OriginalValue, TranslatedValue,
                                   Comments, Context, Flags, PreviousID: string);
                     function Translate(const Identifier, OriginalValue: String): String;
                     function exportcompileritems(sourcepo:TPOFile):integer;
                end;
    TPoTranslator=class(TAbstractTranslator)
    public
     procedure TranslateStringProperty(Sender:TObject;
       const Instance: TPersistent; PropInfo: PPropInfo; var Content:string);override;
    end;

function InterfaceTranslate(const Identifier, OriginalValue: String): String;
var
   PODirectory, Lang, FallbackLang: String;
   po: TmyPOFile;
   actualypo: TmyPOFile;
   _UpdatePO:integer=0;
   _NotEnlishWord:integer=0;
   _DebugWord:integer=0;
const
  identpref='zcadexternal.';
implementation

procedure TPoTranslator.TranslateStringProperty(Sender: TObject;
  const Instance: TPersistent; PropInfo: PPropInfo; var Content: string);
var
  s: String;
begin
  if not Assigned(po) then exit;
  if not Assigned(PropInfo) then exit;
{Нужно ли нам это?}
  if Instance is TComponent then
   if csDesigning in (Instance as TComponent).ComponentState then exit;
{:)}
  if (AnsiUpperCase(PropInfo^.PropType^.Name)<>'TTRANSLATESTRING') then exit;
  s:=po.Translate(Content, Content);
  if s<>'' then Content:=s;
end;

function TmyPOFile.FindByIdentifier(const Identifier: String):TPOFileItem;
begin
     result:=TPOFileItem({FIdentifierToItem}FIdentLowVarToItem.Data[Identifier]);
end;
procedure TmyPOFile.SaveToFile(const AFilename: string);
begin
     inherited//self.f
end;
function TmyPOFile.exportcompileritems(sourcepo:TPOFile):integer;
var
   j:integer;
   ident:string;
   Item: TPOFileItem;
begin
      for j:=0 to Fitems.Count-1 do
           begin
                item:=TPOFileItem(FItems[j]);
                 ident:=item.IdentifierLow;
                 if (pos('~',ident)<=0)
                 and(pos('.',ident)>0) then
                 begin
                      sourcepo.Add(ident, item.Original, item.Translation, item.Comments,
                                    item.Context, item.Flags,'');
                 end;
           end;
      result:=items.Count-sourcepo.items.Count;
end;
function TmyPOFile.Translate(const Identifier, OriginalValue: String): String;
var
  Item: TPOFileItem;
begin
  Item:=TPOFileItem({FIdentifierToItem}FIdentLowVarToItem.Data[Identifier]);
  if Item=nil then
    Item:=TPOFileItem(FOriginalToItem.Data[OriginalValue]);
  if Item<>nil then begin
    Result:=Item.Translation;
    if Result='' then Result:=OriginalValue;
  end else
    Result:=OriginalValue;
end;
procedure TmyPOFile.Add(const Identifier, OriginalValue, TranslatedValue,
  Comments, Context, Flags, PreviousID: string);
var
   t:boolean;
begin
     t:=self.FAllEntries;
     self.FAllEntries:=true;
     inherited;
     self.FAllEntries:=t;
end;

procedure createpo;
var
   AFilename:string;
begin
     if not sysinfo.sysparam.updatepo then
     begin
           if Lang<>'' then
                           begin
                                AFilename:=Format(PODirectory + 'zcad.%s.po',[Lang]);
                                if FileExistsUTF8(AFilename) then
                                                                 begin
                                                                      po:=TmyPOFile.Create(AFilename);
                                                                 end;
                           end;
           if (FallbackLang<>'')and(not assigned(po)) then
                           begin
                                AFilename:=Format(PODirectory + 'zcad.%s.po',[FallbackLang]);
                                if FileExistsUTF8(AFilename) then
                                                                 begin
                                                                      po:=TmyPOFile.Create(AFilename);
                                                                 end;
                           end;
           if (not assigned(po)) then
                                     begin
                                          po:=TmyPOFile.Create;
                                     end;

     end
     else
         begin
              AFilename:=(PODirectory + 'zcad.po');
              if FileExistsUTF8(AFilename) then
                                               begin
                                                    po:=TmyPOFile.Create(AFilename,true);
                                                    actualypo:=TmyPOFile.Create;
                                               end
                                           else
                                               begin
                                                    log.programlog.LogOutStr('Founf command line swith "UpdatePO". File "zcad.po" not found. STOP!',0);
                                                    halt(0);
                                               end;
         end;
end;
function InterfaceTranslate( const Identifier, OriginalValue: String): String;
var
   s:string;
  Item: TPOFileItem;

begin
    if UTF8LowerCase(Identifier)='acn_close~caption' then
                                s:=s;
    log.programlog.LogOutStr(Identifier+' '+OriginalValue,0);
    result:=po.Translate({Identifier}'', OriginalValue);

    if sysinfo.sysparam.updatepo then
     begin
          Item:=TPOFileItem(po.{FIdentifierToItem}FIdentLowVarToItem{FOriginalToItem}.Data[UTF8LowerCase(Identifier)]);
          if not assigned(item) then
          begin
               if (pos('**',OriginalValue)>0)or(pos('??',OriginalValue)>0)then
               begin
                    inc(_DebugWord);
               end
               else
               begin
               if (utf8length(Identifier)=length(Identifier))and
                  (utf8length(OriginalValue)=length(OriginalValue)) then
               begin
                    po.Add(identpref+Identifier,OriginalValue, {TranslatedValue}'', {Comments}'',{Context}'', {Flags}'', {PreviousID}'');
                    actualypo.Add(identpref+Identifier,OriginalValue, {TranslatedValue}'', {Comments}'',{Context}'', {Flags}'', {PreviousID}'');
                    inc(_UpdatePO);
                    //po.SaveToFile(PODirectory + 'zcad.po');
               end
                  else
                      inc(_NotEnlishWord);

               end;
          end
          else
          begin
               if item.Original<>OriginalValue then
                                                   begin
                                                   item.ModifyFlag('fuzzy',true);
                                                   item.Original:=OriginalValue;
                                                   end;
               actualypo.Add(identpref+item.IdentifierLow, item.Original, item.Translation, item.Comments,
                              item.Context, item.Flags,'');
          end;

     end;
end;

procedure initialize;
    begin
      PODirectory := sysinfo.sysparam.programpath+'languades/';
      GetLanguageIDs(Lang, FallbackLang); // определено в модуле gettext
      createpo;
      LRSTranslator:=TPoTranslator.Create;
      if not sysinfo.sysparam.updatepo then
                                       begin
                                           TranslateResourceStrings(po);
                                           TranslateUnitResourceStrings('anchordockstr', PODirectory + 'anchordockstr.%s.po', Lang, FallbackLang);
                                           TranslateUnitResourceStrings('lclstrconsts', PODirectory + 'lclstrconsts.%S.po', Lang, FallbackLang);
                                       end;
    end;

initialization
{$IFDEF DEBUGINITSECTION}log.LogOut('intftranslations.initialization');{$ENDIF}
initialize;
finalization
if assigned(actualypo) then freeandnil(actualypo);
if assigned(po) then freeandnil(po);
if assigned(LRSTranslator) then freeandnil(LRSTranslator);
end.
