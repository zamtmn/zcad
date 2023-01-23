md ZUndoStackDoc
pasdoc.exe --graphviz-uses --graphviz-classes --output ZUndoStackDoc --auto-abstract --staronly --write-uses-list --source ZUndoStackFullList.txt --include ..\cad_source\components\zundostack\
dottoxml.py ZUndoStackDoc\GVClasses.dot ZUndoStackFullClasses.graphml
dottoxml.py ZUndoStackDoc\GVUses.dot ZUndoStackFullUses.graphml

pause