{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzeTriangulator;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzgprimitivescreator,uzgprimitives,uzglvectorobject,uzegluinterface,
  uzegeometrytypes,uzctnrVectorBytesStream,sysutils,uzegeometry,uzbLogIntf,
  gzctnrVectorTypes,uzgloglstatemanager,uzbtypes,uzeTypes,uzeenrepresentation;
type
  TV4P = array [0..3] of Pointer;
  TArray4F = Array [0..3] of {Float}Double;
  TTriangulationMode=(TM_Triangles,TM_TriangleStrip,TM_TriangleFan);
  TTriangulator=class
    type
      TTesselator=TessObj;
      TExtDataType=Pointer;
      TIntDataType=Pointer;
    var
      PZR:PTZEntityRepresentation;
      pcount:integer;
      trmode:TTriangulationMode;
      CurrentLLentity:TArrayIndex;
      triangle:array[0..2] of integer;

    function GetExtDataType:TExtDataType;
    class function GetTriangulatorInstance(EDT:TExtDataType):TTriangulator;
    function NewTesselator:TTesselator;
    procedure DeleteTess(tesselator:TTesselator);
    procedure BeginPolygon(Representation:PTZEntityRepresentation;TS:TTesselator);
    procedure EndPolygon(TS:TTesselator);
    procedure BeginContour(TS:TTesselator);
    procedure EndContour(TS:TTesselator);
    procedure TessVertex(TS:TTesselator; const V:TzePoint3d);

    procedure ErrorCallBack(error: Cardinal);
    procedure BeginCallBack(gmode: Cardinal);
    procedure VertexCallBack(const VertexData: Pointer);
    procedure CombineCallback(const coords:TzePoint3d;const vertex_data:TV4P;const weight:TArray4F;var dataout:Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};

    //constructor create;
    //destructor Destroy;override;
  end;
var
  Triangulator:TTriangulator;
implementation

procedure TessErrorCallBackData(error: Cardinal;Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
  TTriangulator.GetTriangulatorInstance(Data).ErrorCallBack(error);
end;
procedure TessBeginCallBackData(gmode: Cardinal;Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
  TTriangulator.GetTriangulatorInstance(Data).BeginCallBack(gmode);
end;
procedure TessVertexCallBackData(const v: Pdouble;const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
  TTriangulator.GetTriangulatorInstance(Data).VertexCallBack(v);
end;
procedure TessCombineCallbackData(const coords:TzePoint3d;const vertex_data:TV4P;const weight:TArray4F;var dataout:Pointer;const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
  TTriangulator.GetTriangulatorInstance(Data).CombineCallback(coords,vertex_data,weight,dataout);
end;

function TTriangulator.GetExtDataType:TExtDataType;
begin
  result:=Self;
end;

class function TTriangulator.GetTriangulatorInstance(EDT:TExtDataType):TTriangulator;
begin
  result:=EDT;
end;

function TTriangulator.NewTesselator:TTesselator;
begin
  result:=GLUIntrf.NewTess;
  GLUIntrf.TessCallback(result,GLU_TESS_VERTEX_DATA,@TessVertexCallBackData);
  GLUIntrf.TessCallback(result,GLU_TESS_BEGIN_DATA,@TessBeginCallBackData);
  GLUIntrf.TessCallback(result,GLU_TESS_ERROR_DATA,@TessErrorCallBackData);
  GLUIntrf.TessCallback(result,GLU_TESS_COMBINE_DATA,@TessCombineCallbackData);
end;

procedure TTriangulator.DeleteTess(tesselator:TTesselator);
begin
  GLUIntrf.DeleteTess(tesselator);
end;

procedure TTriangulator.BeginPolygon(Representation:PTZEntityRepresentation;TS:TTesselator);
begin
  Self.PZR:=Representation;
  GLUIntrf.TessBeginPolygon(TS,GetExtDataType);
end;
procedure TTriangulator.EndPolygon(TS:TTesselator);
begin
  GLUIntrf.TessEndPolygon(TS);
end;
procedure TTriangulator.BeginContour(TS:TTesselator);
begin
  GLUIntrf.TessBeginContour(TS);
end;
procedure TTriangulator.EndContour(TS:TTesselator);
begin
  GLUIntrf.TessEndContour(TS);
end;
procedure TTriangulator.TessVertex(TS:TTesselator; const V:TzePoint3d);
var
  i:TArrayIndex;
begin
  i:=PZR^.Graphix.GeomData.Vertex3S.AddGDBVertex(V);
  GLUIntrf.TessVertex(TS,@V,i);
end;
procedure TTriangulator.ErrorCallBack(error: Cardinal);
begin
     zDebugln('{F}GLU_TESS_ERROR_DATA!!');
end;
procedure TTriangulator.BeginCallBack(gmode: Cardinal);
begin
     CurrentLLentity:=-1;
//     if gmode=GL_TRIANGLES then
//                               gmode:=gmode;
     pcount:=0;
     case gmode of
     GL_TRIANGLES:
                  begin
                       trmode:=TM_Triangles;
                  end;
  GL_TRIANGLE_FAN:begin
                       trmode:=TM_TriangleFan;
                       CurrentLLentity:=DefaultLLPCreator.CreateLLTriangleFan(PZR^.Graphix.LLprimitives);
                  end;
GL_TRIANGLE_STRIP:begin

                       trmode:=TM_TriangleStrip;
                       CurrentLLentity:=DefaultLLPCreator.CreateLLTriangleStrip(PZR^.Graphix.LLprimitives);
                  end;
     else
         begin
           zDebugLn('{F}Wrong triangulation mode!!');
           raise Exception.Create('Wrong triangulation mode!!');
         end;
     end;
end;
procedure TTriangulator.VertexCallBack(const VertexData: Pointer);
var
   pts:PTLLTriangleStrip;
   index:TLLVertexIndex;
begin
     if pcount<3 then
                         begin
                              if (trmode=TM_TriangleStrip)or(trmode=TM_TriangleFan) then
                                                         begin
                                                              pts:=pointer(PZR^.Graphix.LLprimitives.getDataMutable(CurrentLLentity));
                                                              index:=ptruint(VertexData);
                                                              index:=PZR^.Graphix.GeomData.Indexes.PushBackData(index);
                                                              pts^.AddIndex(index);
                                                              exit;
                                                         end;

                              triangle[pcount]:=ptruint(VertexData);
                              inc(pcount);
                              if pcount=3 then
                                             begin
                                                  DefaultLLPCreator.CreateLLFreeTriangle(PZR^.Graphix.LLprimitives,triangle[0],triangle[1],triangle[2],PZR^.Graphix.GeomData.Indexes);
                                             if trmode=TM_Triangles then
                                                                       pcount:=0;
                                             end;
                         end
                     else
                         begin
                              case trmode of
                       TM_TriangleFan:begin
                                            triangle[1]:=triangle[2];
                                            triangle[2]:=ptruint(VertexData);
                                            DefaultLLPCreator.CreateLLFreeTriangle(PZR^.Graphix.LLprimitives,triangle[0],triangle[1],triangle[2],PZR^.Graphix.GeomData.Indexes);
                                       end;
                     TM_TriangleStrip:begin
                                            triangle[0]:=triangle[1];
                                            triangle[1]:=triangle[2];
                                            triangle[2]:=ptruint(VertexData);
                                            DefaultLLPCreator.CreateLLFreeTriangle(PZR^.Graphix.LLprimitives,triangle[0],triangle[1],triangle[2],PZR^.Graphix.GeomData.Indexes);
                                       end;
                              else begin
                                        triangle[1]:=triangle[1];
                                   end;
                              end;
                         end;
end;
procedure TTriangulator.CombineCallback(const coords:TzePoint3d;const vertex_data:TV4P;const weight:TArray4F;var dataout:Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
  ptruint(dataout):=pzr.Graphix.GeomData.Vertex3S.AddGDBVertex(coords);
  dataout:=dataout;
end;

initialization
  Triangulator:=TTriangulator.Create;
finalization
  Triangulator.Free;
  zDebugLn('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
end.
