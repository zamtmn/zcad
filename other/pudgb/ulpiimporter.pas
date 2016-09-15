unit ulpiimporter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Laz2_XMLCfg,LazUTF8,
  uoptions,ufileutils;

procedure LPIImport(var Options:TOptions;const filename:string;const LogWriter:TLogWriter);

implementation

procedure LPIImport(var Options:TOptions;const filename:string;const LogWriter:TLogWriter);
var
 Doc:TXMLConfig;
 j:integer;
 IncludeFiles,OtherUnitFiles,UnitOutputDirectory,MainFilename:string;
 FileVersion:integer;
 basepath:string;
 opt,s,ts:string;
begin
 Doc:=TXMLConfig.Create(filename);
 FileVersion:=Doc.GetValue('CompilerOptions/Version/Value', 0);
 LogWriter('Version='+inttostr(FileVersion));
 IncludeFiles:=Doc.GetValue('CompilerOptions/SearchPaths/IncludeFiles/Value','');
 LogWriter('IncludeFiles='+IncludeFiles);
 OtherUnitFiles:=Doc.GetValue('CompilerOptions/SearchPaths/OtherUnitFiles/Value','');
 LogWriter('OtherUnitFiles='+OtherUnitFiles);
 UnitOutputDirectory:=Doc.GetValue('CompilerOptions/SearchPaths/UnitOutputDirectory/Value','');
 LogWriter('UnitOutputDirectory='+UnitOutputDirectory);
 MainFilename:=Doc.GetValue('ProjectOptions/Units/Unit0/Filename/Value','');
 LogWriter('Unit0='+MainFilename);
 Doc.Free;
 basepath:=ExtractFileDir(filename)+PathDelim;
 if MainFilename<>'' then
 begin
      if not FileExists(MainFilename) then MainFilename:=basepath+MainFilename;
      Options.Paths._File:=MainFilename;
 end;
 if IncludeFiles<>'' then
 begin
      s:=IncludeFiles;
      opt:='-Sc'+' -Fi'+basepath;
      repeat
            GetPartOfPath(ts,s,';');
            if not DirectoryExists(utf8tosys(ts)) then
                                                      ts:=basepath+ts;
            if DirectoryExists(utf8tosys(ts)) then
                                                  opt:=opt+' -Fi'+ts;
      until s='';
     Options.ParserOptions._CompilerOptions:=opt;
 end
 else
  Options.ParserOptions._CompilerOptions:='-Sc'+' -Fi'+basepath;
 if OtherUnitFiles<>'' then
 begin
      s:=OtherUnitFiles;
      opt:=basepath;
      repeat
            GetPartOfPath(ts,s,';');
            if not DirectoryExists(utf8tosys(ts)) then
                                                      ts:=basepath+ts;
            if DirectoryExists(utf8tosys(ts)) then
                                                  opt:=opt+';'+ts
      until s='';
     Options.Paths._Paths:=opt;
 end
 else
  Options.Paths._Paths:=basepath;
end;

end.

