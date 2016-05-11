//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("pkAttr.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("..\Attrs\AttrType.pas");
USEUNIT("..\Attrs\AttrMap.pas");
USEUNIT("..\Attrs\AttrSet.pas");
USEUNIT("..\Attrs\AttrErr.pas");
USEPACKAGE("PKVECTORS.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
	return 1;
}
//---------------------------------------------------------------------------
