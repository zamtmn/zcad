@echo off
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg cad_source\utils\typeexporter.lpi
if %errorlevel% neq 0 (
   Echo Error when running lazbuild. Check lazbuild in %%PATCH%%
   pause
   exit
)
environment\makeenv_zcadelectrotech.bat