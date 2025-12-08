unit LNLib;

{$mode ObjFPC}{$H+}

interface

uses
  gLNLib,
  XYZW_CAPI,
  Matrix4d_CAPI,
  UV_CAPI;

type

  TYourVector3d=record
    x,y,z:double;
  end;

  TLNLib=specialize gLNLibRec<TYourVector3d,TXYZW,TUV,TMatrix4d>;

implementation

end.
