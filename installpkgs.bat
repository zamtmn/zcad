@echo off
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\other\AGraphLaz\lazarus\ag_attr.lpk
if %errorlevel% neq 0 (
   Echo Error when running lazbuild. Check lazbuild in %%PATCH%%
   pause
   exit
)
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\other\AGraphLaz\lazarus\ag_graph.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\other\AGraphLaz\lazarus\ag_math.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\other\AGraphLaz\lazarus\ag_vectors.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\other\AGraphLaz\lazarus\ag_vectors.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\other\uniqueinstance\uniqueinstance_package.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\other\laz.virtualtreeview_package\laz.virtualtreeview_package.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zebase\zebase.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zcontainers\zcontainers.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zcontrols\zcontrols.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zmacros\zmacros.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zmath\zmath.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zobjectinspector\zobjectinspector.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zscriptbase\zscriptbase.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zscript\zscript.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\ztoolbars\ztoolbars.lpk
E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg --add-package cad_source\components\zundostack\zundostack.lpk
;E:\lazarus2010\lazbuild --pcp=E:\lazarus2010\laz2010cfg -B -r --build-ide=clean