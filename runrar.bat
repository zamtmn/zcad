#!/bin/sh
call deltmp
del c:\cad.rar;c:\cad_source.rar
rar a -r -m5 -x*\.svn\* -ed c:\cad.rar cad
rar a -r -m5 -x*\.svn\* -ed c:\cad_source.rar cad_source
