//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("pkGraph.res");
USEPACKAGE("vcl50.bpi");
USEUNIT("..\Graphs\VFState.pas");
USEUNIT("..\Graphs\EulerCyc.pas");
USEUNIT("..\Graphs\ExtGraph.pas");
USEUNIT("..\Graphs\GMLObj.pas");
USEUNIT("..\Graphs\GraphErr.pas");
USEUNIT("..\Graphs\GraphGML.pas");
USEUNIT("..\Graphs\GraphIO.pas");
USEUNIT("..\Graphs\Graphs.pas");
USEUNIT("..\Graphs\GrColor.pas");
USEUNIT("..\Graphs\HamilCyc.pas");
USEUNIT("..\Graphs\Isomorph.pas");
USEUNIT("..\Graphs\MapColor.pas");
USEUNIT("..\Graphs\MinPath.pas");
USEUNIT("..\Graphs\Planar.pas");
USEUNIT("..\Graphs\Postman.pas");
USEUNIT("..\Graphs\RWGML.pas");
USEUNIT("..\Graphs\Steiner.pas");
USEUNIT("..\Graphs\VFGraph.pas");
USEUNIT("..\Graphs\CTrick.pas");
USEPACKAGE("PKVECTOR.bpi");
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
