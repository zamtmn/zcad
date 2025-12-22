program ganerictypes;
{$Mode delphi}{$H+}
uses
  SysUtils,
  LNLib;

var
  a,b:TYourVector3d;
begin
  TLNLib.LoadLNLib;
  a:=TLNLib.xyz_create(2,3,4);
  b:=a;
  writeln(TLNLib.xyz_distance(a,b));
  readln;
end.
