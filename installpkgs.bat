@echo off

set PathToLazBuild=%~1
echo PathToLazBuild=%PathToLazBuild%
if "%PathToLazBuild%" equ "" (
     Echo Please specify path to lazbuild at first param
     Echo Example:
     Echo   installpkgs c:\path\to\lazarus c:\patch\to\lazconfig
     pause
     exit
)
set PathToLazConfig=%~2
echo PathToLazConfig=%PathToLazConfig%
if "%PathToLazConfig%" equ "" (
     Echo Please specify path to lazconfig at second param
     Echo Example:
     Echo   installpkgs c:\path\to\lazarus c:\patch\to\lazconfig
     pause
     exit
)
if "%PathToLazConfig%" neq "" (
  set LazConfigOpt="--pcp=%PathToLazConfig%"
)
echo LazConfigOpt=%LazConfigOpt%
if "%PathToLazBuild%" neq "" if "%PathToLazConfig%" neq "" (
  %PathToLazBuild%lazbuild %LazConfigOpt% cad_source\utils\typeexporter.lpi
  if %errorlevel% neq 0 (
     Echo Error when running lazbuild. Check params
     Echo Example:
     Echo   installpkgs c:\path\to\lazarus c:\patch\to\lazconfig
     pause
     exit
  )
)


%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\other\AGraphLaz\lazarus\ag_attr.lpk
if %errorlevel% neq 0 (
   Echo Error when running lazbuild. Check lazbuild in %%PATCH%%
   pause
   exit
)
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\other\AGraphLaz\lazarus\ag_graph.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\other\AGraphLaz\lazarus\ag_math.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\other\AGraphLaz\lazarus\ag_vectors.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\other\AGraphLaz\lazarus\ag_vectors.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\other\uniqueinstance\uniqueinstance_package.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\other\laz.virtualtreeview_package\laz.virtualtreeview_package.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zebase\zebase.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zcontainers\zcontainers.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zcontrols\zcontrols.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zmacros\zmacros.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zmath\zmath.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zobjectinspector\zobjectinspector.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zscriptbase\zscriptbase.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zscript\zscript.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\ztoolbars\ztoolbars.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% --add-package cad_source\components\zundostack\zundostack.lpk
%PathToLazBuild%lazbuild %LazConfigOpt% -B -r --build-ide=