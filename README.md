# ZCAD
## Overview
ZCAD is simple CAD program, written in Lazarus / FPC.

License: mLGPLv2

Features:
* Fast OpenGL rendering
* Fast GDI rendering
* Crossplatform (Windows x86/x64, Linux x86/x64 - gtk/qt)
* DXF fileformat
* SHX, TTF font support
* true DXF linetypes
* POINT, LINE, CIRCLE, POLYLINE,  LWPOLYLINE, ARC, ELLIPSE, INSERT, TEXT, MTEXT, 3DFACE, SOLID, SPLINE entities support
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
Requirements:

* **trunk Lazarus**
* **FPC 3.0.4 (or trunk)**

Build ZCAD:

* install zcad packages from 'cad_sources/components' to lazarus
* install third party packages from 'cad_sources/other' to lazarus
* check whether the PATCH variable includes patch to lazbuild binary
* if need set PATCH variable: `$ export PATH="$PATH:/your/patch/to/lazarus/"`
* run 'zcad.sh' (or zcadelectrotech.sh) file
* open zcad.lpi in lazarus and compile
