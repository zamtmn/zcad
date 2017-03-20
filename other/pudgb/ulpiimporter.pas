unit ulpiimporter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Laz2_XMLCfg,LazUTF8,
  uoptions,ufileutils,LazFileUtils,Laz2_DOM,
  MacroIntf,TransferMacros,MacroDefIntf;//From lazarus ide

type
  TMacroMethods=class
      Options:TOptions;
      UnitOutputDirectory:string;
      packagefiles:TXMLConfig;
      function MacroFuncTargetCPU(const {%H-}Param: string; const Data: PtrInt;
                                    var {%H-}Abort: boolean): string;
      function MacroFuncTargetOS (const {%H-}Param: string; const Data: PtrInt;
                                    var {%H-}Abort: boolean): string;
      function MacroFuncProjOutDir (const {%H-}Param: string; const Data: PtrInt;
                                      var {%H-}Abort: boolean): string;
      function MacroFuncPkgDir (const {%H-}Param: string; const Data: PtrInt;
                                  var {%H-}Abort: boolean): string;
      constructor create;
  end;

procedure LPIImport(var Options:TOptions;const filename:string;const LogWriter:TLogWriter);

implementation
constructor TMacroMethods.create;
var
 LazarusPackageFilesConfig:string;
begin
 inherited;
 {$IFDEF WINDOWS}
 LazarusPackageFilesConfig:=AppendPathDelim(ExtractFilePath(ChompPathDelim(GetAppConfigDirUTF8(False)))+'lazarus')+'packagefiles.xml';
 {$Else}
 LazarusPackageFilesConfig:=ExpandFileNameUTF8('~/.lazarus/packagefiles.xml');
 //SecondaryConfigPath:='/etc/lazarus';
 {$ENDIF}
 packagefiles:=TXMLConfig.Create(LazarusPackageFilesConfig);
end;

function TMacroMethods.MacroFuncTargetCPU(const Param: string;
  const Data: PtrInt; var Abort: boolean): string;
begin
    Result:=Options.ParserOptions.TargetCPU;
end;
function TMacroMethods.MacroFuncTargetOS(const Param: string;
  const Data: PtrInt; var Abort: boolean): string;
begin
    Result:=Options.ParserOptions.TargetOS;
end;
function TMacroMethods.MacroFuncProjOutDir(const Param: string;
  const Data: PtrInt; var Abort: boolean): string;
begin
    Result:=UnitOutputDirectory;
end;
function TMacroMethods.MacroFuncPkgDir(const Param: string;
  const Data: PtrInt; var Abort: boolean): string;
var
 node,subnode,namenode:TDomNode;
 UCParam,deb:string;
begin
    UCParam:=uppercase(param);
    Result:='Something wrong';
    node:=packagefiles.FindNode('UserPkgLinks',false);
    if not assigned(node) then exit;
    deb:=node.NodeValue;
    deb:=node.NodeName;
    deb:=node.TextContent;
    subnode:= node.FirstChild;
    while assigned(subnode)do
    begin
       deb:=subnode.NodeValue;
       deb:=subnode.NodeName;
       deb:=subnode.TextContent;
       namenode:=subnode.FindNode('Name');
       if assigned(namenode) then
       namenode:=namenode.Attributes.GetNamedItem('Value');
       if assigned(namenode) then
       begin
           deb:=namenode.NodeValue;
           deb:=namenode.NodeName;
           deb:=namenode.TextContent;
         if UCParam=uppercase(namenode.NodeValue) then
         begin
           namenode:=subnode.FindNode('Filename');
           if assigned(namenode) then
           namenode:=namenode.Attributes.GetNamedItem('Value');
           if assigned(namenode) then
             result:=ExtractFileDir(namenode.NodeValue);
           break;
         end;
       end;
       subnode:= subnode.NextSibling;
    end;
end;

procedure LPIImport(var Options:TOptions;const filename:string;const LogWriter:TLogWriter);
var
 Doc:TXMLConfig;
 j:integer;
 IncludeFiles,OtherUnitFiles,MainFilename,SwithKey:string;
 FileVersion:integer;
 basepath:string;
 opt,s,ts:string;
 IDEMacros: TIDEMacros;
 tmm:TMacroMethods;
 Swith:string;
begin
 IDEMacros:=TLazIDEMacros.Create;
 GlobalMacroList:=TTransferMacroList.Create;
 tmm:=TMacroMethods.create;
 tmm.Options:=Options;
 GlobalMacroList.Add(TTransferMacro.Create('TargetCPU','',
                     'Target CPU',@tmm.MacroFuncTargetCPU,[]));
 GlobalMacroList.Add(TTransferMacro.Create('TargetOS','',
                     'Target OS',@tmm.MacroFuncTargetOS,[]));
 GlobalMacroList.Add(TTransferMacro.Create('ProjOutDir','',
                     'Project out dir',@tmm.MacroFuncProjOutDir,[]));
 GlobalMacroList.Add(TTransferMacro.Create('PkgDir','',
                     'PkgDir',@tmm.MacroFuncPkgDir,[]));

 Doc:=TXMLConfig.Create(filename);
 FileVersion:=Doc.GetValue('CompilerOptions/Version/Value', 0);
 LogWriter('Version='+inttostr(FileVersion));

 tmm.UnitOutputDirectory:=Doc.GetValue('CompilerOptions/SearchPaths/UnitOutputDirectory/Value','');
 LogWriter('UnitOutputDirectory='+tmm.UnitOutputDirectory);
 if IDEMacros.SubstituteMacros(tmm.UnitOutputDirectory) then
                                                    LogWriter('Resolve to UnitOutputDirectory='+tmm.UnitOutputDirectory);

 IncludeFiles:=Doc.GetValue('CompilerOptions/SearchPaths/IncludeFiles/Value','');
 LogWriter('IncludeFiles='+IncludeFiles);
 if IDEMacros.SubstituteMacros(IncludeFiles) then
                                                 LogWriter('Resolve to IncludeFiles='+IncludeFiles);
 OtherUnitFiles:=Doc.GetValue('CompilerOptions/SearchPaths/OtherUnitFiles/Value','');
 LogWriter('OtherUnitFiles='+OtherUnitFiles);
 if IDEMacros.SubstituteMacros(OtherUnitFiles) then
                                                   LogWriter('Resolve to OtherUnitFiles='+OtherUnitFiles);
 MainFilename:=Doc.GetValue('ProjectOptions/Units/Unit0/Filename/Value','');
 LogWriter('Unit0='+MainFilename);

 Swith:='';
 SwithKey:=Doc.GetValue('CompilerOptions/Parsing/SyntaxOptions/SyntaxMode/Value','');
 Case Uppercase(SwithKey) of
      'DELPHI':Swith:='-Sd'
 end;
 SwithKey:=Doc.GetValue('CompilerOptions/Parsing/SyntaxOptions/SyntaxMode/CPPInline','False');
 Case Uppercase(SwithKey) of
      'TRUE':Swith:=Swith+' -Sc'
 end;
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
      if Swith='' then
                      opt:='-Fi'+basepath
                  else
                      opt:=Swith+' -Fi'+basepath;
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
  Options.ParserOptions._CompilerOptions:=Swith+' -Fi'+basepath;
 if OtherUnitFiles<>'' then
 begin
      s:=OtherUnitFiles;
      opt:=basepath;
      repeat
            GetPartOfPath(ts,s,';');
            if not DirectoryExists(utf8tosys(ts)) then
                                                      ts:=basepath+ts;
            DoDirSeparators(ts);
            if DirectoryExists(utf8tosys(ts)) then
                                                  opt:=opt+';'+ts
      until s='';
     Options.Paths._Paths:=opt;
 end
 else
  Options.Paths._Paths:=basepath;
end;

end.

