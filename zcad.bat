@echo off
lazbuild cad_source\utils\typeexporter.lpi
if %errorlevel% neq 0 (
   Echo Error when running lazbuild. Check lazbuild in %%PATCH%%
   pause
   exit
)
environment\makeenv_zcad.bat