#!/bin/sh
call deltmp.bat
deltmp.bat
rm cad.7z cad_source.7z
7z a cad.7z cad/ -ms=off  -xr!*.svn
7z a cad_source.7z cad_source/ -ms=off -xr!*.svn
