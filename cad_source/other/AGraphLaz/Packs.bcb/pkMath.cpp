//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("pkMath.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("..\Math\SVD.pas");
USEUNIT("..\Math\Geom_2d.pas");
USEUNIT("..\Math\Geom_3d.pas");
USEUNIT("..\Math\Grevil.pas");
USEUNIT("..\Math\MathErr.pas");
USEUNIT("..\Math\Optimize.pas");
USEUNIT("..\Math\SLS_Iter.pas");
USEUNIT("..\Math\Gauss.pas");
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
