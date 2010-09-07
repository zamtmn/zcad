del /S /F /Q *.~*;*.dcu;*.identcache;*.local;*.or;*.s;*.o;*.ppu;*.bak;*.tgs;*.tgw;*.a;*.prjconfig;*.txaPackage;*.txvpck
del /S /F /Q cad\*.ppu;cad\*.o;cad\*.or;cad\*.a;cad\*.res;
del /S /F /Q cad_source\dcu\*.res;cad_source\dcu\*.compiled;
del /S /F /Q cad\log\*.log;
del /S /F /Q cad\log\*.loghard;
del /S /F /Q cad\autosave\*.dxf;
del /S /F /Q cad\autosave\*.dbpas;
del /S /F /Q cad\autosave\*.pas;
rd cad_source\__history
rd /S /Q cad_source\dcu\*.sl
rd cad_source\backup
rd cad_source\electroteh\backup\
rd cad_source\devicebase\backup
rd cad_source\utils\backup
rd cad\rtl\backup
rd cad_source\LCLmod\__history
rd cad_source\LCLmod\backup
rd cad_source\gui\backup
rd cad_source\u\backup
rd cad_source\commands\backup
rd cad_source\languade\backup
rd cad_source\zwin\backup
rd cad_source\GDB\backup
rd cad_source\languade\__history
rd cad_source\commands\__history
rd cad_source\gdb\__history
rd cad_source\gui\__history
rd cad_source\iolow\__history
rd cad_source\OpenGL\__history
rd cad_source\plugins\__history
rd cad_source\u\__history
rd cad_source\utils\__history
rd cad_source\zwin\__history
rd cad_source\DeviceBase\__history
rd cad_source\Utils\__history;Utils\ModelSupport
rd cad_source\ModelSupport
rd cad_source\ModelSupport_cad
rd cad_source\ModelSupport_zcad
