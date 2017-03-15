{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ag_graph;

interface

uses
  CTrick, EulerCyc, ExtGraph, GMLObj, GraphErr, GraphGML, GraphIO, Graphs, 
  GrColor, HamilCyc, Isomorph, MapColor, MinPath, Planar, Postman, RWGML, 
  Steiner, VFGraph, VFState, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('ag_graph', @Register);
end.
