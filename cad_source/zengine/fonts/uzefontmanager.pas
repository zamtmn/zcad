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

unit uzefontmanager;
{$INCLUDE zengineconfig.inc}
{$ModeSwitch advancedrecords}
interface
uses
  uzctnrVectorBytes,{$IFNDEF DELPHI}LResources,{$ENDIF}LCLProc,uzbpaths,
  uzelclintfex,uzestrconsts,uzbstrproc,uzefont,
  sysutils,uzbtypes,uzegeometry,gzctnrSTL,
  UGDBNamedObjectsArray,classes,uzefontttfpreloader,uzelongprocesssupport;
type
  TGeneralFontParam=record
    procedure Init;
    constructor Create(dummy:integer);
  end;
  TGeneralFontFileDesc=record
    Name:string;
    FontFile:string;
    Param:TGeneralFontParam;
    procedure Init(AName:string;AFontFile:string;AParam:TGeneralFontParam);
    constructor Create(AName:string;AFontFile:string;AParam:TGeneralFontParam);
  end;
  TFontName2FontFileMap=GKey2DataMap<String,TGeneralFontFileDesc(*{$IFNDEF DELPHI},LessString{$ENDIF}*)>;

  TFontLoadProcedure=function(name:String;var pf:PGDBfont):Boolean;
  TFontLoadProcedureData=record
    FontDesk:String;
    FontLoadProcedure:TFontLoadProcedure;
  end;

  TFontExt2LoadProcMap=GKey2DataMap<String,TFontLoadProcedureData(*{$IFNDEF DELPHI},LessString{$ENDIF}*)>;
{Export+}
  PGDBFontRecord=^GDBFontRecord;
  {REGISTERRECORDTYPE GDBFontRecord}
  GDBFontRecord = record
    Name: String;
    Pfont: Pointer;
  end;
  PGDBFontManager=^GDBFontManager;
  {REGISTEROBJECTTYPE GDBFontManager}
  GDBFontManager=object({GDBOpenArrayOfData}GDBNamedObjectsArray{-}<PGDBfont,GDBfont>{//})(*OpenArrayOfData=GDBfont*)
    FontFiles:{-}TFontName2FontFileMap{/pointer/};
    shxfontfiles:TStringList;
    constructor init(m:Integer);
    destructor done;virtual;
    procedure CreateBaseFont;

    function addFonfByFile(FontPathName:String):PGDBfont;
    function addFont(FontFile,FontFamily:String):PGDBfont;
    procedure EnumerateFontFiles;
    procedure EnumerateTTFFontFile(filename:String;pdata:pointer);
    procedure EnumerateSHXFontFile(filename:String;pdata:pointer);
    //function FindFonf(FontName:String):Pointer;
    {procedure freeelement(p:Pointer);virtual;}
  end;
{Export-}
var
   FontManager:GDBFontManager;
   FontExt2LoadProc:TFontExt2LoadProcMap;
   sysvarPATHFontsPath:String;
   sysvarAlternateFont:String='GEWIND.SHX';
procedure RegisterFontLoadProcedure(const _FontExt,_FontDesk:String;
                                    const _FontLoadProcedure:TFontLoadProcedure);
implementation

procedure TGeneralFontParam.init;
begin
end;

constructor TGeneralFontParam.Create;
begin
end;

procedure TGeneralFontFileDesc.init(AName:string;AFontFile:string;AParam:TGeneralFontParam);
begin
  Name:=AName;
  FontFile:=AFontFile;
  Param:=AParam;
end;

constructor TGeneralFontFileDesc.Create(AName:string;AFontFile:string;AParam:TGeneralFontParam);
begin
  //init(AName,AFontFile,AParam);
  Name:=AName;
  FontFile:=AFontFile;
  Param:=AParam;
end;

procedure RegisterFontLoadProcedure(const _FontExt,_FontDesk:String;
                                    const _FontLoadProcedure:TFontLoadProcedure);
var
   EntInfoData:TFontLoadProcedureData;
begin
     EntInfoData.FontDesk:=_FontDesk;
     EntInfoData.FontLoadProcedure:=_FontLoadProcedure;
     FontExt2LoadProc.RegisterKey(_FontExt,EntInfoData);
end;
procedure GDBFontManager.EnumerateTTFFontFile(filename:String;pdata:pointer);
var
  ttfparams:TTTFFileParams;
  ffg:^TGeneralFontFileDesc;
  //gfd:TGeneralFontFileDesc;
begin
  if AddFontResourceFile(filename)>0 then begin
    ttfparams:=getTTFFileParams(filename);
    if ttfparams.ValidTTFFile then begin
      if not FontFiles.MyGetMutableValue(uppercase(ttfparams.FontFamily),ffg)then
        FontFiles.registerkey(uppercase(ttfparams.FontFamily),TGeneralFontFileDesc.Create(ttfparams.FontFamily,filename,TGeneralFontParam.Create(0)))
      else
        if ((ttfparams.FontSubfamily='')or(LowerCase(ttfparams.FontSubfamily)='regular')) then
          ffg^.FontFile:=filename;
    end;
  end;
end;

procedure GDBFontManager.EnumerateSHXFontFile(filename:String;pdata:pointer);
begin
     shxfontfiles.Add(filename);
end;
destructor GDBFontManager.done;
begin
  inherited;
  if assigned(FontFiles)then
    FontFiles.Destroy;
  if assigned(shxfontfiles)then
    shxfontfiles.Destroy;
end;
procedure GDBFontManager.EnumerateFontFiles;
var
  lpsh:TLPSHandle;
begin
  //FontFiles:=TFontName2FontFileMap.create;
  lpsh:=LPS.StartLongProcess('Enumerate *.ttf fonts',FontFiles);
  FromDirsIterator(sysvarPATHFontsPath,'*.ttf','',nil,EnumerateTTFFontFile);
  LPS.EndLongProcess(lpsh);
  shxfontfiles:=TStringList.create;
  shxfontfiles.Duplicates := dupIgnore;
  lpsh:=LPS.StartLongProcess('Enumerate *.shx fonts',shxfontfiles);
  FromDirsIterator(sysvarPATHFontsPath,'*.shx','',nil,EnumerateSHXFontFile);
  LPS.EndLongProcess(lpsh);
end;
constructor GDBFontManager.init;
begin
  FontFiles:=TFontName2FontFileMap.Create;
  inherited init(m);
end;
procedure GDBFontManager.CreateBaseFont;
{NEEDFIXFORDELPHI}
{$IFNDEF DELPHI}
var
   r: TLResource;
   f:TZctnrVectorBytes;
{$ENDIF}
const
   resname='GEWIND';
   filename='GEWIND.SHX';
begin
  {$IFNDEF DELPHI}
  pbasefont:=addFonfByFile(FindInPaths(sysvarPATHFontsPath,sysvarAlternateFont));
  if pbasefont=nil then
  begin
       DebugLn('{E}'+rsAlternateFontNotFoundIn,[sysvarAlternateFont,sysvarPATHFontsPath]);
       r := LazarusResources.Find(resname);
       if r = nil then
                      DebugLn('{F}'+rsReserveFontNotFound)
                  else
                      begin
                           f.init(length(r.Value));
                           f.AddData(@r.Value[1],length(r.Value));
                           f.SaveToFile(expandpath(TempPath+filename));
                           pbasefont:=addFonfByFile(TempPath+filename);
                           f.done;
                           if pbasefont=nil then
                                                DebugLn('{F}'+rsReserveFontNotLoad)
                      end;
  end;
  addFonfByFile(FindInPaths(sysvarPATHFontsPath,'ltypeshp.shx'));
  {$ENDIF}
end;

function GDBFontManager.addFonfByFile(FontPathName:String):PGDBfont;
var
  p:PGDBfont;
  FontName,FontExt:String;
  FontLoaded:Boolean;
  _key:String;
  data:TFontLoadProcedureData;
      //ir:itrec;
begin
     debugln('{D+}GDBFontManager.addFonf(%s)',[FontPathName]);
     //programlog.LogOutFormatStr('GDBFontManager.addFonf(%s)',[FontPathName],lp_IncPos,LM_Debug);
     result:=nil;
     if FontPathName='' then
                            begin
                              debugln('{D-}Empty fontname');
                              //programlog.logoutstr('Empty fontname',lp_DecPos,LM_Debug);
                              exit;
                            end;
     FontExt:=uppercase(ExtractFileExt(FontPathName));
     FontName:=ExtractFileName(FontPathName);
//          if FontName='_mipgost.shx' then
//                                    fontname:=FontName;
     case AddItem(FontName,pointer(p)) of
             IsFounded:
                       begin
                            debugln('{I}Font "%s" already loaded',[FontPathName]);
                            //programlog.LogOutFormatStr('Font "%s" already loaded',[FontPathName],lp_OldPos,LM_Info);
                       end;
             IsCreated:
                       begin
                            //HistoryOutStr(sysutils.format(rsLoadingFontFile,[FontPathName]));
                            debugln('{IH+}'+rsLoadingFontFile,[FontPathName]);
                            //programlog.LogOutFormatStr('Loading font "%s"',[FontPathName],lp_IncPos,LM_Info);
                            _key:=lowercase(FontExt);
                            if _key<>'' then
                            begin
                            while _key[1]='.' do
                             _key:=copy(_key,2,length(_key)-1);
                            end;
                            FontLoaded:=false;
                            if FontExt2LoadProc.MyGetValue(_key,data) then
                            begin
                                 FontLoaded:=data.FontLoadProcedure(FontPathName,p)
                            end;
                            {if FontExt='.SHX' then
                                                  FontLoaded:=createnewfontfromshx(FontPathName,p)}
                      { else if FontExt='.TTF' then
                                                  FontLoaded:=createnewfontfromttf(FontPathName,p);}
                            if not FontLoaded then
                            begin
                                 debugln('{EH}Font file "%S" unknown format',[FontPathName]);
                                 //programlog.LogOutFormatStr('Font file "%S" unknown format',[FontPathName],lp_OldPos,LM_Error);
                                 //ShowError(sysutils.format('Font file "%S" unknown format',[FontPathName]));
                                 dec(self.Count);
                                 //p^.Name:='ERROR ON LOAD';
                                 p:=nil;
                            end;
                            debugln('{I-}end;{Loading font}');
                            //programlog.LogOutStr('end;{Loading font}',lp_DecPos,LM_Info);
                            //p^.init(FontPathName,Color,LW,oo,ll,pp);
                       end;
             IsError:
                       begin
                            debugln('{I}Font "%s"... something wrong',[FontPathName]);
                            //programlog.LogOutFormatStr('Font "%s"... something wrong',[FontPathName],lp_OldPos,LM_Info);
                       end;
     end;
     result:=p;
     debugln('{D-}end;{GDBFontManager.addFonf}');
     //programlog.logoutstr('end;{GDBFontManager.addFonf}',lp_DecPos,LM_Debug);
end;
function GDBFontManager.addFont(FontFile,FontFamily:String):PGDBfont;
var
  ffd:TGeneralFontFileDesc;
  FF:String;
begin
  FF:=FontFile;
  FontFile:=FindInPaths(sysvarPATHFontsPath,FontFile);
  if FontFile='' then
    FontFile:=FindInPaths(sysvarPATHFontsPath,FF+'.shx');
  if FontFile='' then
    FontFile:=FindInPaths(sysvarPATHFontsPath,FF+'.ttf');
  if FontFile<>'' then
    result:=FontManager.addFonfByFile(FontFile)
  else
    result:=nil;
  if result=nil then
    if (FF<>'')and(FontFiles.MyGetValue(uppercase(FF),ffd)) then
      result:=addFonfByFile(ffd.FontFile);
  if result=nil then
    if (FontFamily<>'')and(FontFiles.MyGetValue(uppercase(FontFamily),ffd)) then
      result:=addFonfByFile(ffd.FontFile);
end;

{function GDBFontManager.FindFonf;
var
  pfr:pGDBFontRecord;
  i:Integer;
begin
  result:=nil;
  if count=0 then exit;
  pfr:=parray;
  for i:=0 to count-1 do
  begin
       if pfr^.Name=fontname then begin
                                       result:=pfr^.Pfont;
                                       exit;
                                  end;
       inc(pfr);
  end;
end;}

{function GDBLayerArray.CalcCopactMemSize2;
var i:Integer;
    tlp:PGDBLayerProp;
begin
     result:=0;
     objcount:=count;
     if count=0 then exit;
     result:=result;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          result:=result+sizeof(Byte)+sizeof(SmallInt)+sizeof(Word)+length(tlp^.name);
          inc(tlp);
     end;
end;
function GDBLayerArray.SaveToCompactMemSize2;
var i:Integer;
    tlp:PGDBLayerProp;
begin
     result:=0;
     if count=0 then exit;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          PByte(pmem)^:=tlp^.color;
          inc(PByte(pmem));
          PGDBSmallint(pmem)^:=tlp^.lineweight;
          inc(PGDBSmallint(pmem));
          PGDBWord(pmem)^:=length(tlp^.name);
          inc(PGDBWord(pmem));
          Move(Pointer(tlp.name)^, pmem^,length(tlp.name));
          inc(PByte(pmem),length(tlp.name));
          inc(tlp);
     end;
end;
function GDBLayerArray.LoadCompactMemSize2;
begin
     {inherited LoadCompactMemSize(pmem);
     Coord:=PGDBLineProp(pmem)^;
     inc(PGDBLineProp(pmem));
     PProjPoint:=nil;
     format;}
//end;
initialization
{NEEDFIXFORDELPHI}
{$IFNDEF DELPHI}
  {$I gewind.lrs}
{$ENDIF}
  FontManager.init(100);
  FontExt2LoadProc:=TFontExt2LoadProcMap.Create;
  sysvarPATHFontsPath:=ExtractFileDir(ParamStr(0));
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  FontManager.Done;
  FontExt2LoadProc.Destroy;
end.
