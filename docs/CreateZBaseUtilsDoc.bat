md ZBaseUtilsDoc 

pasdoc.exe --graphviz-uses --graphviz-classes --output ZBaseUtilsDoc --auto-abstract --staronly --write-uses-list --source ZBaseUtilsFullList.txt --include ..\cad_source\components\zbaseutils\;..\cad_source\components\zbaseutilsgui\
dottoxml.py ZBaseUtilsDoc\GVClasses.dot ZBaseUtilsFullClasses.graphml
dottoxml.py ZBaseUtilsDoc\GVUses.dot ZBaseUtilsFullUses.graphml

pause