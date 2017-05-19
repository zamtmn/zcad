unit uscaner;

{$mode objfpc}{$H+}

interface
uses
  LazUTF8,Classes, SysUtils,
  uprojectoptions,uscanresult,ufileutils,
  PScanner, PParser, PasTree, Masks;

type
    TSimpleEngine = class(TPasTreeContainer)
    private
    uname:string;
    public
    LogWriter:TLogWriter;

    constructor Create(const Options:TProjectOptions;const _LogWriter:TLogWriter);
    destructor Destroy;override;
    Procedure Log(Sender : TObject; Const Msg : String);

    function CreateElement(AClass: TPTreeElement; const AName: String;
      AParent: TPasElement; AVisibility: TPasMemberVisibility;
      const ASourceFilename: String; ASourceLinenumber: Integer): TPasElement;
      override;
    function FindElement(const AName: String): TPasElement; override;
    end;
    TPrepareMode = (PMProgram,PMInterface,PMImplementation);

procedure GetDecls(PM:TPrepareMode;Decl:TPasDeclarations;Options:TProjectOptions;ScanResult:TScanResult;UnitIndex:TUnitIndex;const LogWriter:TLogWriter);
procedure ScanModule(mn:String;Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
procedure ScanDirectory(mn:String;Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);

implementation

destructor TSimpleEngine.Destroy;
begin
  LogWriter(format('unit(%s).Destroy',[uname]),[]);
  if uname='other/uniqueinstance/uniqueinstancebase.pas'{'zengine\core\uzeentityfactory.pas'}{'zengine\core\objects\uzeentitiestree.pas'} then
    uname:=uname;
  if assigned(FPackage) then
    FPackage.Destroy;
  inherited;
end;

function TSimpleEngine.CreateElement(AClass: TPTreeElement; const AName: String;
  AParent: TPasElement; AVisibility: TPasMemberVisibility;
  const ASourceFilename: String; ASourceLinenumber: Integer): TPasElement;
begin
  Result := AClass.Create(AName, AParent);
  Result.Visibility := AVisibility;
  Result.SourceFilename := ASourceFilename;
  Result.SourceLinenumber := ASourceLinenumber;
end;
constructor TSimpleEngine.Create(const Options:TProjectOptions;const _LogWriter:TLogWriter);
begin
  if Options.Logger.ScanerMessages then
    ScannerLogEvents:=[sleFile,sleLineNumber,sleConditionals,sleDirective];
  if Options.Logger.ParserMessages then
    ParserLogEvents:=[pleInterface,pleImplementation];
  OnLog:=@Log;
  FPackage:=TPasPackage.Create('',nil);
  LogWriter:=_LogWriter;
end;
procedure TSimpleEngine.Log(Sender : TObject; Const Msg : String);
begin
  LogWriter(Msg,[LD_Report]);
end;
function TSimpleEngine.FindElement(const AName: String): TPasElement;
begin
  { dummy implementation, see TFPDocEngine.FindElement for a real example }
  Result := nil;
end;
procedure PrepareModule(var M:TPasModule;var E:TPasTreeContainer;Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
   UnitIndex:TUnitIndex;
   s:string;
begin
   if ScanResult.TryCreateNewUnitInfo(M.Name,UnitIndex)then
   begin
   if M is TPasProgram then
    begin
     ScanResult.UnitInfoArray.Mutable[UnitIndex]^.UnitType:=TUnitType.UTProgram;
     ScanResult.UnitInfoArray.Mutable[UnitIndex]^.UnitPath:=extractfilepath(M.SourceFilename);
     GetDecls(PMProgram,(M as TPasProgram).ProgramSection as TPasDeclarations,Options,ScanResult,UnitIndex,LogWriter);
     if assigned(M.ImplementationSection) then
       begin
        GetDecls(PMProgram,M.ImplementationSection as TPasDeclarations,Options,ScanResult,UnitIndex,LogWriter);
       end;
    end
   else
    begin
      ScanResult.UnitInfoArray.Mutable[UnitIndex]^.UnitType:=TUnitType.UTUnit;
      ScanResult.UnitInfoArray.Mutable[UnitIndex]^.UnitPath:=extractfilepath(M.SourceFilename);
      GetDecls(PMInterface,M.InterfaceSection as TPasDeclarations,Options,ScanResult,UnitIndex,LogWriter);
      if assigned(M.ImplementationSection) then
       begin
        //if assigned(LogWriter) then LogWriter('Implementation');
        GetDecls(PMImplementation,M.ImplementationSection as TPasDeclarations,Options,ScanResult,UnitIndex,LogWriter);
       end;
    end;
   ScanResult.UnitInfoArray.Mutable[UnitIndex]^.PasModule:=M;
   ScanResult.UnitInfoArray.Mutable[UnitIndex]^.PasTreeContainer:=E;
   M:=nil;
   E:=nil;
   end;
   s:=ScanResult.UnitInfoArray.Mutable[UnitIndex]^.UnitPath;
end;
function MemoryUsed: Cardinal;
 begin
   Result := GetFPCHeapStatus.CurrHeapUsed;
end;
procedure ScanModule(mn:String;Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
  M:TPasModule;
  E:TSimpleEngine;
  myTime:TDateTime;
  memused:Cardinal;
begin
   E := TSimpleEngine.Create(Options,LogWriter);
   E.uname:=mn;
   //if assigned(LogWriter) then LogWriter(format('Process file: "%s"',[mn]));
   try
     if Options.Logger.Timer then
      begin
       myTime:=now;
       memused:=MemoryUsed;
      end;
     if E.uname='/media/zamtmn/apps/zcad/other/pudgb//uchecker.pas' then
       E.uname:=E.uname;
     M := ParseSource(E,mn+' '+Options.ParserOptions._CompilerOptions,Options.ParserOptions.TargetOS,Options.ParserOptions.TargetCPU,[poSkipDefaultDefs]);
     if Options.Logger.Timer then
      begin
       LogWriter(format('Parse "%s" %fsec, %db',[mn,(now-myTime)*10e4,(MemoryUsed-memused)]),[LD_Report]);
      end;
     if E.uname='zengine\geomlib\uzgeomproxy.pas' then
       E.uname:=E.uname;
     if E.uname='zengine\core\uzeentityfactory.pas' then
       E.uname:=E.uname;
     E.LogWriter:=LogWriter;
     PrepareModule(M,TPasTreeContainer(E),Options,ScanResult,LogWriter);
     if assigned(M) then M.Release;
     if assigned(E) then E.Free;
   except
     on excep:EParserError do
       begin
         if assigned(LogWriter) then LogWriter(format('Parser error: "%s" line:%d column:%d  file:%s',[excep.message,excep.row,excep.column,excep.filename]),[LD_Report]);
         //raise;
       end;
     on excep:Exception do
       begin
         if assigned(LogWriter) then LogWriter(format('Exception: "%s" in file "%s"',[excep.message,mn]),[LD_Report]);
         //raise;
       end;
     else
      begin
        if assigned(LogWriter) then LogWriter(format('Error in file "%s"',[mn]),[LD_Report]);
      end;
   end;
    //if assigned(LogWriter) then LogWriter(format('Done file: "%s"',[mn]));
end;
procedure ScanDirectory(mn:String;Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
  path,mask,s:string;
  i:integer;
  sr: TSearchRec;
begin
   path:=ExtractFileDir(mn)+PathDelim;
   i:=length(path)+1;
   while (i<=(length(mn)))and((mn[i] in AllowDirectorySeparators))do
    inc(i);
   mask:=copy(mn,i,length(mn)-i+1);
   if mask='' then
                  mask:='*.pas;*.pp';

   if FindFirst(path + '*', faDirectory, sr) = 0 then
   begin
     repeat
       if (sr.Name <> '.') and (sr.Name <> '..') then
       begin
         if DirectoryExists(path + sr.Name) then
                                                ScanDirectory(path+sr.Name+PathDelim+mask,Options,ScanResult,LogWriter)
         else
         begin
           //s:=lowercase(sr.Name);
           if MatchesMaskList(sr.Name,mask) then
           begin
             if not ScanResult.isUnitInfoPresent(ExtractFileName(sr.Name),i) then
             ScanModule(path+PathDelim+sr.Name,Options,ScanResult,LogWriter);
           end;
         end;
       end;
     until FindNext(sr) <> 0;
     FindClose(sr);
   end;

end;
procedure GetDecls(PM:TPrepareMode;Decl:TPasDeclarations;Options:TProjectOptions;ScanResult:TScanResult;UnitIndex:TUnitIndex;const LogWriter:TLogWriter);
 var i,j:integer;
     pe:TPasElement;
     pp:TPasProcedure;
     ps:TPasSection;
     l:TStringList;
     ss,s:string;
     uarr:TUsesArray;
     t:boolean;
begin
 if assigned(Decl)then
  begin
   case pm of
     PMProgram:uarr:=ScanResult.UnitInfoArray[UnitIndex].InterfaceUses;
     PMInterface:uarr:=ScanResult.UnitInfoArray[UnitIndex].InterfaceUses;
     PMImplementation:uarr:=ScanResult.UnitInfoArray[UnitIndex].ImplementationUses;
   end;
   l:=TStringList.Create;
   pe:=TPasElement(Decl);
   if pe is TPasSection then
    begin
     ps:=TPasSection(pe);
     if ps.UsesList.Count >0 then
      begin
       //if assigned(LogWriter) then LogWriter('uses');
       ps:=TPasSection(Decl);
       for i:=0 to ps.UsesList.Count-2 do
        begin
        if UpCase(TPasElement(ps.UsesList[i]).Name) = 'SYSTEM' then continue
         else s:=s+(TPasElement(ps.UsesList[i]).Name+',');
        l.Add(TPasElement(ps.UsesList[i]).Name);
        end;
       s:=s+(TPasElement(ps.UsesList[ps.UsesList.Count-1]).Name+';');
       l.Add(TPasElement(ps.UsesList[ps.UsesList.Count-1]).Name);
       //if assigned(LogWriter) then LogWriter(s);
      end;
    end;
   for i:=0 to l.Count-1 do
    begin
    s:=l.Strings[i];
    if lowercase(s)='ucodeparser' then
                      s:=s;
    if not ScanResult.isUnitInfoPresent(l.Strings[i],j)then
    begin
      //s:='/'+l.Strings[i]+'.pas';
      s:=FindInSupportPath(Options.Paths._Paths,PathDelim+l.Strings[i]+'.pas');
      if s=''then
        s:=FindInSupportPath(Options.Paths._Paths,PathDelim+l.Strings[i]+'.pp');
      if s=''then
        s:=FindInSupportPath(Options.Paths._Paths,PathDelim+l.Strings[i]+'.PP');
      if s=''then
        s:=FindInSupportPath(Options.Paths._Paths,PathDelim+lowercase(l.Strings[i])+'.pas');
      if s=''then
        s:=FindInSupportPath(Options.Paths._Paths,PathDelim+lowercase(l.Strings[i])+'.pp');
      if s<>''then
                  begin
                    ScanModule(s,Options,ScanResult,LogWriter);
                    if ScanResult.UnitName2IndexMap.GetValue(lowercase(l.Strings[i]),j) then
                    begin
                      //ScanResult.UnitInfoArray.Mutable[j]^.UnitPath:='s';
                      uarr.PushBack(j);
                    end;
                  end
              else
                  begin
                       if Options.Logger.Notfounded then
                         if assigned(LogWriter) then LogWriter(format('Unit not found: "%s"',[l.Strings[i]]),[LD_Report]);
                       ScanResult.TryCreateNewUnitInfo(l.Strings[i],j);
                       ScanResult.UnitInfoArray.Mutable[j]^.UnitPath:='';
                       uarr.PushBack(j);
                  end;
    end
    else
    begin
       s:=l.Strings[i];
       if lowercase(s)='fpdpansi' then
                      s:=s;
       uarr.PushBack(j);
    end;
    end;
   l.Free;
  end;
end;
end.

