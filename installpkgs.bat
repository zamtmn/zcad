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
lazbuild --add-package cad_source\components\zcontainers\zcontainers.lpk
lazbuild --add-package cad_source\components\zcontrols\zcontrols.lpk
lazbuild --add-package cad_source\components\zmacros\zmacros.lpk
lazbuild --add-package cad_source\components\zmath\zmath.lpk
lazbuild --add-package cad_source\components\zobjectinspector\zobjectinspector.lpk
lazbuild --add-package cad_source\components\zscriptbase\zscriptbase.lpk
lazbuild --add-package cad_source\components\zscript\zscript.lpk
lazbuild --add-package cad_source\components\ztoolbars\ztoolbars.lpk
lazbuild --add-package cad_source\components\zundostack\zundostack.lpk
