# ZCAD
[![GitHub Release](https://img.shields.io/github/release/zamtmn/zcad.svg)](https://github.com/zamtmn/zcad/releases)[![Build status](https://ci.appveyor.com/api/projects/status/7bsg5me8q1r5jjt4/branch/master?svg=true)](https://ci.appveyor.com/project/zamtmn/zcad/branch/master)
![screenshot](https://github.com/zamtmn/zcad/raw/master/docs/img/sch.png)
![screenshot](https://github.com/zamtmn/zcad/raw/master/docs/img/ops.png)
![screenshot](https://github.com/zamtmn/zcad/raw/master/docs/img/zcadet_win32.png)
## Overview
ZCAD is simple CAD program, written in Lazarus / FPC.

License: GPL3.0/MPL2.0

Features:
* Fast OpenGL rendering
* Fast GDI rendering
* Crossplatform (Windows x86/x64, Linux x86/x64 - gtk/qt)
* DXF fileformat
* SHX, TTF font support
* true DXF linetypes
* POINT, LINE, CIRCLE, POLYLINE,  LWPOLYLINE, ARC, ELLIPSE, INSERT, TEXT, MTEXT, 3DFACE, SOLID, SPLINE, HATCH entities support
* Polar tracking, Object snap

ToDo:
* ~~Dimensional entities~~ (partially done)
* ~~Line type~~
* More entities
* ~~Separate graphics engine from the CAD implementation~~ (partially done)
* ~~GDI and canvas render backends~~
* DX render backend
* ~~Printing~~

## Build from source
Detailed instructions: [ENG](https://github.com/zamtmn/zcad/blob/master/BUILD_FROM_SOURCES.md "ENG") / [RUS](https://github.com/zamtmn/zcad/blob/master/cad_source/docs/userguide/locale/ru/for_developers/building_from_sources.adoc "RUS")

Requirements:

* **Lazarus RC2.2 (or trunk)**
* **FPC 3.2 (or trunk)**

You can build ZCAD or ZCADELECTROTECH

Build ZCAD:

* `make installpkgstolaz LP=/path/to/your/lazarus PCP=/path/to/your/lazarus/primary/config`
* `make clean`
* `make zcadenv`
* `make zcad LP=/path/to/your/lazarus PCP=/path/to/your/lazarus/primary/config`

Build ZCADELECTROTECH:

* `make installpkgstolaz LP=/path/to/your/lazarus PCP=/path/to/your/lazarus/primary/config`
* `make clean`
* `make zcadelectrotechenv`
* `make zcadelectrotech LP=/path/to/your/lazarus PCP=/path/to/your/lazarus/primary/config`

`make installpkgstolaz` you need to do it only one time, this will install packages from '**cad_sources/components**' and '**cad_sources/other**' to your lazarus and will rebuild it
