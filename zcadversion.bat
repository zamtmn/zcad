@echo off
git describe --tags > cad_source/zcadversion.inc
set /p ZCADVERSION= < cad_source/zcadversion.inc
echo '%ZCADVERSION%' > cad_source/zcadversion.inc