unit uscaner;

{$mode objfpc}{$H+}

interface
uses
  LazUTF8,Classes, SysUtils,
  uoptions,uscanresult,
  PParser, PasTree;

type
    TSimpleEngine = class(TPasTreeContainer)
    public
    function CreateElement(AClass: TPTreeElement; const AName: String;
      AParent: TPasElement; AVisibility: TPasMemberVisibility;
      const ASourceFilename: String; ASourceLinenumber: Integer): TPasElement;
      override;
    function FindElement(const AName: String): TPasElement; override;
    end;
    TPrepareMode = (PMProgram,PMInterface,PMImplementation);

procedure GetDecls(PM:TPrepareMode;Decl:TPasDeclarations;Options:TOptions;ScanResult:TScanResult;UnitIndex:TUnitIndex;const LogWriter:TLogWriter);
procedure ScanModule(mn:String;Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);

implementation

function TSimpleEngine.CreateElement(AClass: TPTreeElement; const AName: String;
  AParent: TPasElement; AVisibility: TPasMemberVisibility;
  const ASourceFilename: String; ASourceLinenumber: Integer): TPasElement;
begin
  Result := AClass.Create(AName, AParent);
  Result.Visibility := AVisibility;
  Result.SourceFilename := ASourceFilename;
  Result.SourceLinenumber := ASourceLinenumber;
end;

function TSimpleEngine.FindElement(const AName: String): TPasElement;
begin
  { dummy implementation, see TFPDocEngine.FindElement for a real example }
  Result := nil;
end;

function GetPartOfPath(out part:String;var path:String;const separator:String):String;
var
   i:Integer;
begin
           i:=pos(separator,path);
           if i<>0 then
                       begin
                            part:=copy(path,1,i-1);
                            path:=copy(path,i+1,length(path)-i);
                       end
                   else
                       begin
                            part:=path;
                            path:='';
                       end;
     result:=part;
end;
function FindInSupportPath(PPaths:String;FileName:String):String;
var
   s,ts:string;
begin
     if FileExists(utf8tosys(FileName)) then
                                 begin
                                      result:=FileName;
                                      exit;
                                 end;
     begin
     s:=PPaths;
     repeat
           GetPartOfPath(ts,s,';');
           ts:=ts+FileName;
           if FileExists(utf8tosys(ts)) then
                                 begin
                                      result:=ts;
                                      exit;
                                 end;
     until s='';
     end;
     result:='';
end;
procedure PrepareModule(M:TPasModule;Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
   UnitIndex:TUnitIndex;
begin
   if ScanResult.TryCreateNewUnitInfo(M.Name,UnitIndex)then
   begin
   if M is TPasProgram then
    begin
     if assigned(LogWriter) then LogWriter('Program '+M.Name+';');
     GetDecls(PMProgram,(M as TPasProgram).ProgramSection as TPasDeclarations,Options,ScanResult,UnitIndex,LogWriter);
     if assigned(M.ImplementationSection) then
       begin
        GetDecls(PMProgram,M.ImplementationSection as TPasDeclarations,Options,ScanResult,UnitIndex,LogWriter);
       end;
    end
   else
    begin
      if assigned(LogWriter) then LogWriter('Unit '+M.Name+';');
      if assigned(LogWriter) then LogWriter('Interface');
      GetDecls(PMInterface,M.InterfaceSection as TPasDeclarations,Options,ScanResult,UnitIndex,LogWriter);
      if assigned(M.ImplementationSection) then
       begin
        if assigned(LogWriter) then LogWriter('Implementation');
        GetDecls(PMImplementation,M.ImplementationSection as TPasDeclarations,Options,ScanResult,UnitIndex,LogWriter);
       end;
    end;
   end;
end;

procedure ScanModule(mn:String;Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
  M:TPasModule;
  E:TPasTreeContainer;
begin
   E := TSimpleEngine.Create;
   if assigned(LogWriter) then LogWriter(format('Process file: "%s"',[mn]));
   try
     M := ParseSource(E,mn+' '+Options._CompilerOptions,Options.TargetOS,Options.TargetCPU,False);
   except
     on excep:EParserError do
       begin
         if assigned(LogWriter) then LogWriter(format('Error! "%s" line:%d column:%d  file:%s',[excep.message,excep.row,excep.column,excep.filename]));
         //raise;
      end;
   end;
    PrepareModule(M,Options,ScanResult,LogWriter);
    if assigned(LogWriter) then LogWriter(format('Done file: "%s"',[mn]));
    E.Free;
    M.Free;
end;
procedure GetDecls(PM:TPrepareMode;Decl:TPasDeclarations;Options:TOptions;ScanResult:TScanResult;UnitIndex:TUnitIndex;const LogWriter:TLogWriter);
 var i,j:integer;
     pe:TPasElement;
     pp:TPasProcedure;
     ps:TPasSection;
     l:TStringList;
     ss,s:string;
     uarr:TUsesArray;
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
       if assigned(LogWriter) then LogWriter('uses');
       ps:=TPasSection(Decl);
       for i:=0 to ps.UsesList.Count-2 do
        begin
        if UpCase(TPasElement(ps.UsesList[i]).Name) = 'SYSTEM' then continue
         else s:=s+(TPasElement(ps.UsesList[i]).Name+',');
        l.Add(TPasElement(ps.UsesList[i]).Name);
        end;
       s:=s+(TPasElement(ps.UsesList[ps.UsesList.Count-1]).Name+';');
       l.Add(TPasElement(ps.UsesList[ps.UsesList.Count-1]).Name);
       if assigned(LogWriter) then LogWriter(s);
      end;
    end;
   for i:=0 to l.Count-1 do
    begin
    s:=l.Strings[i];
    if s='debug' then
                      s:=s;
    if not ScanResult.isUnitInfoPresent(l.Strings[i],j)then
    begin
      s:='/'+l.Strings[i]+'.pas';
      s:=FindInSupportPath(Options._Paths,s);
      if s<>''then
                  begin
                    ScanModule(s,Options,ScanResult,LogWriter);
                    if ScanResult.UnitName2IndexMap.GetValue(l.Strings[i],j) then
                                                                                 uarr.PushBack(j);
                  end;
    end
    else
    begin
       s:='/'+l.Strings[i]+'.pas';
       uarr.PushBack(j);
    end;
    end;
   l.Free;
  end;
end;
end.

