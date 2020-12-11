@echo off
lazbuild --add-package cad_source\other\AGraphLaz\lazarus\ag_attr.lpk
if %errorlevel% neq 0 (
   Echo Error when running lazbuild. Check lazbuild in %%PATCH%%
   pause
   exit
)
lazbuild --add-package cad_source\other\AGraphLaz\lazarus\ag_graph.lpk
lazbuild --add-package cad_source\other\AGraphLaz\lazarus\ag_math.lpk
lazbuild --add-package cad_source\other\AGraphLaz\lazarus\ag_vectors.lpk
lazbuild --add-package cad_source\other\AGraphLaz\lazarus\ag_vectors.lpk
lazbuild --add-package cad_source\components\zebase\zebase.lpk
 
