program classic;
{$Mode delphi}{$H+}
uses
  XYZ_CAPI,
  uLNLib;
type
  TYourVector3d=record
    x,y,z:double;
  end;

var
  a,b:TYourVector3d;
begin
  LNLib.LoadLNLib;
  TXYZ(a):=LNLib.xyz_create(2,3,4);
  b:=a;
  writeln(LNLib.xyz_distance(TXYZ(a),TXYZ(b)));
  readln;
end.

