@echo off
set PathToLazBuild=%~1
echo PathToLazBuild=%PathToLazBuild%
if "%PathToLazBuild%" equ "" (
     Echo Please specify path to lazbuild at first param
     Echo Example:
     Echo   zcadelectrotech c:\path\to\lazarus c:\patch\to\lazconfig
     pause
     exit
)
set PathToLazConfig=%~2
echo PathToLazConfig=%PathToLazConfig%
if "%PathToLazConfig%" equ "" (
     Echo Please specify path to lazconfig at second param
     Echo Example:
     Echo   zcadelectrotech c:\path\to\lazarus c:\patch\to\lazconfig
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
     Echo   zcadelectrotech c:\path\to\lazarus c:\patch\to\lazconfig
     pause
     exit
  )
)
environment\makeenv_zcadelectrotech.bat