call s3p
call deltmp
del c:\cad.7z;c:\cad_source.7z
7z a c:\cad.7z cad\ -ms=off  -xr!*.svn
7z a c:\cad_source.7z cad_source\ -ms=off -xr!*.svn
