{*************************************************************************** }
{  gfdwg - free implementation of the DWG file format based on LibreDWG      }
{                                                                            }
{        Copyright (C) 2022 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{  You should have received a copy of the GNU General Public License         }
{  along with this program.  If not, see <http://www.gnu.org/licenses/>.     }
{*************************************************************************** }

unit dwg;
interface
//uses
//  ctypes;

{
  Automatically converted by H2Pas 1.0.0 from dwg.h
  The following command line parameters were used:
    dwg.h
    -D
    -p
    -o
    dwg.pp
}

    Type
    P_dwg_3DSOLID_material  = ^_dwg_3DSOLID_material;
    P_dwg_3DSOLID_silhouette  = ^_dwg_3DSOLID_silhouette;
    P_dwg_3DSOLID_wire  = ^_dwg_3DSOLID_wire;
    P_dwg_abstractentity_UNDERLAY  = ^_dwg_abstractentity_UNDERLAY;
    P_dwg_abstractobject_ASSOCARRAYPARAMETERS  = ^_dwg_abstractobject_ASSOCARRAYPARAMETERS;
    P_dwg_abstractobject_UNDERLAYDEFINITION  = ^_dwg_abstractobject_UNDERLAYDEFINITION;
    P_dwg_AcDs  = ^_dwg_AcDs;
    P_dwg_AcDs_Data  = ^_dwg_AcDs_Data;
    P_dwg_AcDs_Data_Record  = ^_dwg_AcDs_Data_Record;
    P_dwg_AcDs_Data_RecordHdr  = ^_dwg_AcDs_Data_RecordHdr;
    P_dwg_AcDs_DataBlob  = ^_dwg_AcDs_DataBlob;
    P_dwg_AcDs_DataBlob01  = ^_dwg_AcDs_DataBlob01;
    P_dwg_AcDs_DataBlobRef  = ^_dwg_AcDs_DataBlobRef;
    P_dwg_AcDs_DataBlobRef_Page  = ^_dwg_AcDs_DataBlobRef_Page;
    P_dwg_AcDs_DataIndex  = ^_dwg_AcDs_DataIndex;
    P_dwg_AcDs_DataIndex_Entry  = ^_dwg_AcDs_DataIndex_Entry;
    P_dwg_AcDs_Schema  = ^_dwg_AcDs_Schema;
    P_dwg_AcDs_Schema_Prop  = ^_dwg_AcDs_Schema_Prop;
    P_dwg_AcDs_SchemaData  = ^_dwg_AcDs_SchemaData;
    P_dwg_AcDs_SchemaData_UProp  = ^_dwg_AcDs_SchemaData_UProp;
    P_dwg_AcDs_SchemaIndex  = ^_dwg_AcDs_SchemaIndex;
    P_dwg_AcDs_SchemaIndex_Prop  = ^_dwg_AcDs_SchemaIndex_Prop;
    P_dwg_AcDs_Search  = ^_dwg_AcDs_Search;
    P_dwg_AcDs_Search_Data  = ^_dwg_AcDs_Search_Data;
    P_dwg_AcDs_Search_IdIdx  = ^_dwg_AcDs_Search_IdIdx;
    P_dwg_AcDs_Search_IdIdxs  = ^_dwg_AcDs_Search_IdIdxs;
    P_dwg_AcDs_Segment  = ^_dwg_AcDs_Segment;
    P_dwg_AcDs_SegmentIndex  = ^_dwg_AcDs_SegmentIndex;
    P_dwg_ACSH_HistoryNode  = ^_dwg_ACSH_HistoryNode;
    P_dwg_ACSH_SubentColor  = ^_dwg_ACSH_SubentColor;
    P_dwg_ACSH_SubentMaterial  = ^_dwg_ACSH_SubentMaterial;
    P_dwg_ACTIONBODY  = ^_dwg_ACTIONBODY;
    P_dwg_appinfo  = ^_dwg_appinfo;
    P_dwg_appinfohistory  = ^_dwg_appinfohistory;
    P_dwg_ARRAYITEMLOCATOR  = ^_dwg_ARRAYITEMLOCATOR;
    P_dwg_ASSOCACTION_Deps  = ^_dwg_ASSOCACTION_Deps;
    P_dwg_ASSOCACTIONBODY_action  = ^_dwg_ASSOCACTIONBODY_action;
    P_dwg_ASSOCARRAYITEM  = ^_dwg_ASSOCARRAYITEM;
    P_dwg_ASSOCPARAMBASEDACTIONBODY  = ^_dwg_ASSOCPARAMBASEDACTIONBODY;
    P_dwg_ASSOCSURFACEACTIONBODY  = ^_dwg_ASSOCSURFACEACTIONBODY;
    P_dwg_auxheader  = ^_dwg_auxheader;
    P_dwg_binary_chunk  = ^_dwg_binary_chunk;
    P_dwg_bitcode_2bd  = ^_dwg_bitcode_2bd;
    P_dwg_bitcode_2rd  = ^_dwg_bitcode_2rd;
    P_dwg_bitcode_3bd  = ^_dwg_bitcode_3bd;
    P_dwg_bitcode_3rd  = ^_dwg_bitcode_3rd;
    P_dwg_BLOCKACTION_connectionpts  = ^_dwg_BLOCKACTION_connectionpts;
    P_dwg_BLOCKLOOKUPACTION_lut  = ^_dwg_BLOCKLOOKUPACTION_lut;
    P_dwg_BLOCKPARAMETER_connection  = ^_dwg_BLOCKPARAMETER_connection;
    P_dwg_BLOCKPARAMETER_PropInfo  = ^_dwg_BLOCKPARAMETER_PropInfo;
    P_dwg_BLOCKPARAMVALUESET  = ^_dwg_BLOCKPARAMVALUESET;
    P_dwg_BLOCKVISIBILITYPARAMETER_state  = ^_dwg_BLOCKVISIBILITYPARAMETER_state;
    P_dwg_CellContentGeometry  = ^_dwg_CellContentGeometry;
    P_dwg_CellStyle  = ^_dwg_CellStyle;
    P_dwg_chain  = ^_dwg_chain;
    P_dwg_class  = ^_dwg_class;
    P_dwg_color  = ^_dwg_color;
    P_dwg_ColorRamp  = ^_dwg_ColorRamp;
    P_dwg_COMPOUNDOBJECTID  = ^_dwg_COMPOUNDOBJECTID;
    P_dwg_CONSTRAINTGROUPNODE  = ^_dwg_CONSTRAINTGROUPNODE;
    P_dwg_ContentFormat  = ^_dwg_ContentFormat;
    P_dwg_CONTEXTDATA_dict  = ^_dwg_CONTEXTDATA_dict;
    P_dwg_CONTEXTDATA_submgr  = ^_dwg_CONTEXTDATA_submgr;
    P_dwg_DATALINK_customdata  = ^_dwg_DATALINK_customdata;
    P_dwg_DATATABLE_column  = ^_dwg_DATATABLE_column;
    P_dwg_DATATABLE_row  = ^_dwg_DATATABLE_row;
    P_dwg_DIMASSOC_Ref  = ^_dwg_DIMASSOC_Ref;
    P_dwg_DIMENSION_common  = ^_dwg_DIMENSION_common;
    P_dwg_entity_3DFACE  = ^_dwg_entity_3DFACE;
    P_dwg_entity_3DLINE  = ^_dwg_entity_3DLINE;
    P_dwg_entity_3DSOLID  = ^_dwg_entity_3DSOLID;
    P_dwg_entity_ALIGNMENTPARAMETERENTITY  = ^_dwg_entity_ALIGNMENTPARAMETERENTITY;
    P_dwg_entity_ARC  = ^_dwg_entity_ARC;
    P_dwg_entity_ARC_DIMENSION  = ^_dwg_entity_ARC_DIMENSION;
    P_dwg_entity_ARCALIGNEDTEXT  = ^_dwg_entity_ARCALIGNEDTEXT;
    P_dwg_entity_ATTDEF  = ^_dwg_entity_ATTDEF;
    P_dwg_entity_ATTRIB  = ^_dwg_entity_ATTRIB;
    P_dwg_entity_BASEPOINTPARAMETERENTITY  = ^_dwg_entity_BASEPOINTPARAMETERENTITY;
    P_dwg_entity_BLOCK  = ^_dwg_entity_BLOCK;
    P_dwg_entity_CAMERA  = ^_dwg_entity_CAMERA;
    P_dwg_entity_CIRCLE  = ^_dwg_entity_CIRCLE;
    P_dwg_entity_DIMENSION_ALIGNED  = ^_dwg_entity_DIMENSION_ALIGNED;
    P_dwg_entity_DIMENSION_ANG2LN  = ^_dwg_entity_DIMENSION_ANG2LN;
    P_dwg_entity_DIMENSION_ANG3PT  = ^_dwg_entity_DIMENSION_ANG3PT;
    P_dwg_entity_DIMENSION_DIAMETER  = ^_dwg_entity_DIMENSION_DIAMETER;
    P_dwg_entity_DIMENSION_LINEAR  = ^_dwg_entity_DIMENSION_LINEAR;
    P_dwg_entity_DIMENSION_ORDINATE  = ^_dwg_entity_DIMENSION_ORDINATE;
    P_dwg_entity_DIMENSION_RADIUS  = ^_dwg_entity_DIMENSION_RADIUS;
    P_dwg_entity_eed  = ^_dwg_entity_eed;
    P_dwg_entity_eed_data  = ^_dwg_entity_eed_data;
    P_dwg_entity_ELLIPSE  = ^_dwg_entity_ELLIPSE;
    P_dwg_entity_ENDBLK  = ^_dwg_entity_ENDBLK;
    P_dwg_entity_ENDREP  = ^_dwg_entity_ENDREP;
    P_dwg_entity_EXTRUDEDSURFACE  = ^_dwg_entity_EXTRUDEDSURFACE;
    P_dwg_entity_FLIPGRIPENTITY  = ^_dwg_entity_FLIPGRIPENTITY;
    P_dwg_entity_FLIPPARAMETERENTITY  = ^_dwg_entity_FLIPPARAMETERENTITY;
    P_dwg_entity_GEOPOSITIONMARKER  = ^_dwg_entity_GEOPOSITIONMARKER;
    P_dwg_entity_HATCH  = ^_dwg_entity_HATCH;
    P_dwg_entity_HELIX  = ^_dwg_entity_HELIX;
    P_dwg_entity_IMAGE  = ^_dwg_entity_IMAGE;
    P_dwg_entity_INSERT  = ^_dwg_entity_INSERT;
    P_dwg_entity_LARGE_RADIAL_DIMENSION  = ^_dwg_entity_LARGE_RADIAL_DIMENSION;
    P_dwg_entity_LEADER  = ^_dwg_entity_LEADER;
    P_dwg_entity_LIGHT  = ^_dwg_entity_LIGHT;
    P_dwg_entity_LINE  = ^_dwg_entity_LINE;
    P_dwg_entity_LINEARGRIPENTITY  = ^_dwg_entity_LINEARGRIPENTITY;
    P_dwg_entity_LINEARPARAMETERENTITY  = ^_dwg_entity_LINEARPARAMETERENTITY;
    P_dwg_entity_LOAD  = ^_dwg_entity_LOAD;
    P_dwg_entity_LOFTEDSURFACE  = ^_dwg_entity_LOFTEDSURFACE;
    P_dwg_entity_LWPOLYLINE  = ^_dwg_entity_LWPOLYLINE;
    P_dwg_entity_MESH  = ^_dwg_entity_MESH;
    P_dwg_entity_MINSERT  = ^_dwg_entity_MINSERT;
    P_dwg_entity_MLINE  = ^_dwg_entity_MLINE;
    P_dwg_entity_MPOLYGON  = ^_dwg_entity_MPOLYGON;
    P_dwg_entity_MTEXT  = ^_dwg_entity_MTEXT;
    P_dwg_entity_MULTILEADER  = ^_dwg_entity_MULTILEADER;
    P_dwg_entity_NAVISWORKSMODEL  = ^_dwg_entity_NAVISWORKSMODEL;
    P_dwg_entity_NURBSURFACE  = ^_dwg_entity_NURBSURFACE;
    P_dwg_entity_OLE2FRAME  = ^_dwg_entity_OLE2FRAME;
    P_dwg_entity_OLEFRAME  = ^_dwg_entity_OLEFRAME;
    P_dwg_entity_PLANESURFACE  = ^_dwg_entity_PLANESURFACE;
    P_dwg_entity_POINT  = ^_dwg_entity_POINT;
    P_dwg_entity_POINTCLOUD  = ^_dwg_entity_POINTCLOUD;
    P_dwg_entity_POINTCLOUDEX  = ^_dwg_entity_POINTCLOUDEX;
    P_dwg_entity_POINTPARAMETERENTITY  = ^_dwg_entity_POINTPARAMETERENTITY;
    P_dwg_entity_POLARGRIPENTITY  = ^_dwg_entity_POLARGRIPENTITY;
    P_dwg_entity_POLYLINE_2D  = ^_dwg_entity_POLYLINE_2D;
    P_dwg_entity_POLYLINE_3D  = ^_dwg_entity_POLYLINE_3D;
    P_dwg_entity_POLYLINE_MESH  = ^_dwg_entity_POLYLINE_MESH;
    P_dwg_entity_POLYLINE_PFACE  = ^_dwg_entity_POLYLINE_PFACE;
    P_dwg_entity_PROXY_ENTITY  = ^_dwg_entity_PROXY_ENTITY;
    P_dwg_entity_RAY  = ^_dwg_entity_RAY;
    P_dwg_entity_REPEAT  = ^_dwg_entity_REPEAT;
    P_dwg_entity_REVOLVEDSURFACE  = ^_dwg_entity_REVOLVEDSURFACE;
    P_dwg_entity_ROTATIONGRIPENTITY  = ^_dwg_entity_ROTATIONGRIPENTITY;
    P_dwg_entity_ROTATIONPARAMETERENTITY  = ^_dwg_entity_ROTATIONPARAMETERENTITY;
    P_dwg_entity_RTEXT  = ^_dwg_entity_RTEXT;
    P_dwg_entity_SECTIONOBJECT  = ^_dwg_entity_SECTIONOBJECT;
    P_dwg_entity_SEQEND  = ^_dwg_entity_SEQEND;
    P_dwg_entity_SHAPE  = ^_dwg_entity_SHAPE;
    P_dwg_entity_SOLID  = ^_dwg_entity_SOLID;
    P_dwg_entity_SPLINE  = ^_dwg_entity_SPLINE;
    P_dwg_entity_SWEPTSURFACE  = ^_dwg_entity_SWEPTSURFACE;
    P_dwg_entity_TABLE  = ^_dwg_entity_TABLE;
    P_dwg_entity_TEXT  = ^_dwg_entity_TEXT;
    P_dwg_entity_TOLERANCE  = ^_dwg_entity_TOLERANCE;
    P_dwg_entity_TRACE  = ^_dwg_entity_TRACE;
    P_dwg_entity_UNKNOWN_ENT  = ^_dwg_entity_UNKNOWN_ENT;
    P_dwg_entity_VERTEX_2D  = ^_dwg_entity_VERTEX_2D;
    P_dwg_entity_VERTEX_3D  = ^_dwg_entity_VERTEX_3D;
    P_dwg_entity_VERTEX_PFACE_FACE  = ^_dwg_entity_VERTEX_PFACE_FACE;
    P_dwg_entity_VIEWPORT  = ^_dwg_entity_VIEWPORT;
    P_dwg_entity_VISIBILITYGRIPENTITY  = ^_dwg_entity_VISIBILITYGRIPENTITY;
    P_dwg_entity_VISIBILITYPARAMETERENTITY  = ^_dwg_entity_VISIBILITYPARAMETERENTITY;
    P_dwg_entity_WIPEOUT  = ^_dwg_entity_WIPEOUT;
    P_dwg_entity_XYGRIPENTITY  = ^_dwg_entity_XYGRIPENTITY;
    P_dwg_entity_XYPARAMETERENTITY  = ^_dwg_entity_XYPARAMETERENTITY;
    P_dwg_EVAL_Edge  = ^_dwg_EVAL_Edge;
    P_dwg_EVAL_Node  = ^_dwg_EVAL_Node;
    P_dwg_EvalExpr  = ^_dwg_EvalExpr;
    P_dwg_EvalVariant  = ^_dwg_EvalVariant;
    P_dwg_FIELD_ChildValue  = ^_dwg_FIELD_ChildValue;
    P_dwg_filedeplist  = ^_dwg_filedeplist;
    P_dwg_FileDepList_Files  = ^_dwg_FileDepList_Files;
    P_dwg_FormattedTableData  = ^_dwg_FormattedTableData;
    P_dwg_FormattedTableMerged  = ^_dwg_FormattedTableMerged;
    P_dwg_GEODATA_meshface  = ^_dwg_GEODATA_meshface;
    P_dwg_GEODATA_meshpt  = ^_dwg_GEODATA_meshpt;
    P_dwg_GridFormat  = ^_dwg_GridFormat;
    P_dwg_handle  = ^_dwg_handle;
    P_dwg_HATCH_Color  = ^_dwg_HATCH_Color;
    P_dwg_HATCH_ControlPoint  = ^_dwg_HATCH_ControlPoint;
    P_dwg_HATCH_DefLine  = ^_dwg_HATCH_DefLine;
    P_dwg_HATCH_Path  = ^_dwg_HATCH_Path;
    P_dwg_HATCH_PathSeg  = ^_dwg_HATCH_PathSeg;
    P_dwg_HATCH_PolylinePath  = ^_dwg_HATCH_PolylinePath;
    P_dwg_header  = ^_dwg_header;
    P_dwg_header_variables  = ^_dwg_header_variables;
    P_dwg_LAYER_entry  = ^_dwg_LAYER_entry;
    P_dwg_LEADER_ArrowHead  = ^_dwg_LEADER_ArrowHead;
    P_dwg_LEADER_BlockLabel  = ^_dwg_LEADER_BlockLabel;
    P_dwg_LEADER_Break  = ^_dwg_LEADER_Break;
    P_dwg_LEADER_Line  = ^_dwg_LEADER_Line;
    P_dwg_LEADER_Node  = ^_dwg_LEADER_Node;
    P_dwg_LIGHTLIST_light  = ^_dwg_LIGHTLIST_light;
    P_dwg_LinkedData  = ^_dwg_LinkedData;
    P_dwg_LinkedTableData  = ^_dwg_LinkedTableData;
    P_dwg_LTYPE_dash  = ^_dwg_LTYPE_dash;
    P_dwg_LWPOLYLINE_width  = ^_dwg_LWPOLYLINE_width;
    P_dwg_MATERIAL_color  = ^_dwg_MATERIAL_color;
    P_dwg_MATERIAL_gentexture  = ^_dwg_MATERIAL_gentexture;
    P_dwg_MATERIAL_mapper  = ^_dwg_MATERIAL_mapper;
    P_dwg_MESH_edge  = ^_dwg_MESH_edge;
    P_dwg_MLEADER_AnnotContext  = ^_dwg_MLEADER_AnnotContext;
    P_dwg_MLEADER_Content  = ^_dwg_MLEADER_Content;
    P_dwg_MLEADER_Content_Block  = ^_dwg_MLEADER_Content_Block;
    P_dwg_MLEADER_Content_MText  = ^_dwg_MLEADER_Content_MText;
    P_dwg_MLINE_line  = ^_dwg_MLINE_line;
    P_dwg_MLINE_vertex  = ^_dwg_MLINE_vertex;
    P_dwg_MLINESTYLE_line  = ^_dwg_MLINESTYLE_line;
    P_dwg_object  = ^_dwg_object;
    P_dwg_object_ACMECOMMANDHISTORY  = ^_dwg_object_ACMECOMMANDHISTORY;
    P_dwg_object_ACMESCOPE  = ^_dwg_object_ACMESCOPE;
    P_dwg_object_ACMESTATEMGR  = ^_dwg_object_ACMESTATEMGR;
    P_dwg_object_ACSH_BOOLEAN_CLASS  = ^_dwg_object_ACSH_BOOLEAN_CLASS;
    P_dwg_object_ACSH_BOX_CLASS  = ^_dwg_object_ACSH_BOX_CLASS;
    P_dwg_object_ACSH_BREP_CLASS  = ^_dwg_object_ACSH_BREP_CLASS;
    P_dwg_object_ACSH_CHAMFER_CLASS  = ^_dwg_object_ACSH_CHAMFER_CLASS;
    P_dwg_object_ACSH_CONE_CLASS  = ^_dwg_object_ACSH_CONE_CLASS;
    P_dwg_object_ACSH_CYLINDER_CLASS  = ^_dwg_object_ACSH_CYLINDER_CLASS;
    P_dwg_object_ACSH_EXTRUSION_CLASS  = ^_dwg_object_ACSH_EXTRUSION_CLASS;
    P_dwg_object_ACSH_FILLET_CLASS  = ^_dwg_object_ACSH_FILLET_CLASS;
    P_dwg_object_ACSH_HISTORY_CLASS  = ^_dwg_object_ACSH_HISTORY_CLASS;
    P_dwg_object_ACSH_LOFT_CLASS  = ^_dwg_object_ACSH_LOFT_CLASS;
    P_dwg_object_ACSH_PYRAMID_CLASS  = ^_dwg_object_ACSH_PYRAMID_CLASS;
    P_dwg_object_ACSH_REVOLVE_CLASS  = ^_dwg_object_ACSH_REVOLVE_CLASS;
    P_dwg_object_ACSH_SPHERE_CLASS  = ^_dwg_object_ACSH_SPHERE_CLASS;
    P_dwg_object_ACSH_SWEEP_CLASS  = ^_dwg_object_ACSH_SWEEP_CLASS;
    P_dwg_object_ACSH_TORUS_CLASS  = ^_dwg_object_ACSH_TORUS_CLASS;
    P_dwg_object_ACSH_WEDGE_CLASS  = ^_dwg_object_ACSH_WEDGE_CLASS;
    P_dwg_object_ALDIMOBJECTCONTEXTDATA  = ^_dwg_object_ALDIMOBJECTCONTEXTDATA;
    P_dwg_object_ANGDIMOBJECTCONTEXTDATA  = ^_dwg_object_ANGDIMOBJECTCONTEXTDATA;
    P_dwg_object_ANNOTSCALEOBJECTCONTEXTDATA  = ^_dwg_object_ANNOTSCALEOBJECTCONTEXTDATA;
    P_dwg_object_APPID  = ^_dwg_object_APPID;
    P_dwg_object_APPID_CONTROL  = ^_dwg_object_APPID_CONTROL;
    P_dwg_object_ASSOC2DCONSTRAINTGROUP  = ^_dwg_object_ASSOC2DCONSTRAINTGROUP;
    P_dwg_object_ASSOC3POINTANGULARDIMACTIONBODY  = ^_dwg_object_ASSOC3POINTANGULARDIMACTIONBODY;
    P_dwg_object_ASSOCACTION  = ^_dwg_object_ASSOCACTION;
    P_dwg_object_ASSOCACTIONPARAM  = ^_dwg_object_ASSOCACTIONPARAM;
    P_dwg_object_ASSOCALIGNEDDIMACTIONBODY  = ^_dwg_object_ASSOCALIGNEDDIMACTIONBODY;
    P_dwg_object_ASSOCARRAYACTIONBODY  = ^_dwg_object_ASSOCARRAYACTIONBODY;
    P_dwg_object_ASSOCARRAYMODIFYACTIONBODY  = ^_dwg_object_ASSOCARRAYMODIFYACTIONBODY;
    P_dwg_object_ASSOCASMBODYACTIONPARAM  = ^_dwg_object_ASSOCASMBODYACTIONPARAM;
    P_dwg_object_ASSOCBLENDSURFACEACTIONBODY  = ^_dwg_object_ASSOCBLENDSURFACEACTIONBODY;
    P_dwg_object_ASSOCCOMPOUNDACTIONPARAM  = ^_dwg_object_ASSOCCOMPOUNDACTIONPARAM;
    P_dwg_object_ASSOCDEPENDENCY  = ^_dwg_object_ASSOCDEPENDENCY;
    P_dwg_object_ASSOCDIMDEPENDENCYBODY  = ^_dwg_object_ASSOCDIMDEPENDENCYBODY;
    P_dwg_object_ASSOCEDGEACTIONPARAM  = ^_dwg_object_ASSOCEDGEACTIONPARAM;
    P_dwg_object_ASSOCEDGECHAMFERACTIONBODY  = ^_dwg_object_ASSOCEDGECHAMFERACTIONBODY;
    P_dwg_object_ASSOCEDGEFILLETACTIONBODY  = ^_dwg_object_ASSOCEDGEFILLETACTIONBODY;
    P_dwg_object_ASSOCEXTENDSURFACEACTIONBODY  = ^_dwg_object_ASSOCEXTENDSURFACEACTIONBODY;
    P_dwg_object_ASSOCEXTRUDEDSURFACEACTIONBODY  = ^_dwg_object_ASSOCEXTRUDEDSURFACEACTIONBODY;
    P_dwg_object_ASSOCFACEACTIONPARAM  = ^_dwg_object_ASSOCFACEACTIONPARAM;
    P_dwg_object_ASSOCFILLETSURFACEACTIONBODY  = ^_dwg_object_ASSOCFILLETSURFACEACTIONBODY;
    P_dwg_object_ASSOCGEOMDEPENDENCY  = ^_dwg_object_ASSOCGEOMDEPENDENCY;
    P_dwg_object_ASSOCLOFTEDSURFACEACTIONBODY  = ^_dwg_object_ASSOCLOFTEDSURFACEACTIONBODY;
    P_dwg_object_ASSOCMLEADERACTIONBODY  = ^_dwg_object_ASSOCMLEADERACTIONBODY;
    P_dwg_object_ASSOCNETWORK  = ^_dwg_object_ASSOCNETWORK;
    P_dwg_object_ASSOCNETWORKSURFACEACTIONBODY  = ^_dwg_object_ASSOCNETWORKSURFACEACTIONBODY;
    P_dwg_object_ASSOCOBJECTACTIONPARAM  = ^_dwg_object_ASSOCOBJECTACTIONPARAM;
    P_dwg_object_ASSOCOFFSETSURFACEACTIONBODY  = ^_dwg_object_ASSOCOFFSETSURFACEACTIONBODY;
    P_dwg_object_ASSOCORDINATEDIMACTIONBODY  = ^_dwg_object_ASSOCORDINATEDIMACTIONBODY;
    P_dwg_object_ASSOCOSNAPPOINTREFACTIONPARAM  = ^_dwg_object_ASSOCOSNAPPOINTREFACTIONPARAM;
    P_dwg_object_ASSOCPATCHSURFACEACTIONBODY  = ^_dwg_object_ASSOCPATCHSURFACEACTIONBODY;
    P_dwg_object_ASSOCPATHACTIONPARAM  = ^_dwg_object_ASSOCPATHACTIONPARAM;
    P_dwg_object_ASSOCPERSSUBENTMANAGER  = ^_dwg_object_ASSOCPERSSUBENTMANAGER;
    P_dwg_object_ASSOCPLANESURFACEACTIONBODY  = ^_dwg_object_ASSOCPLANESURFACEACTIONBODY;
    P_dwg_object_ASSOCPOINTREFACTIONPARAM  = ^_dwg_object_ASSOCPOINTREFACTIONPARAM;
    P_dwg_object_ASSOCRESTOREENTITYSTATEACTIONBODY  = ^_dwg_object_ASSOCRESTOREENTITYSTATEACTIONBODY;
    P_dwg_object_ASSOCREVOLVEDSURFACEACTIONBODY  = ^_dwg_object_ASSOCREVOLVEDSURFACEACTIONBODY;
    P_dwg_object_ASSOCROTATEDDIMACTIONBODY  = ^_dwg_object_ASSOCROTATEDDIMACTIONBODY;
    P_dwg_object_ASSOCSWEPTSURFACEACTIONBODY  = ^_dwg_object_ASSOCSWEPTSURFACEACTIONBODY;
    P_dwg_object_ASSOCTRIMSURFACEACTIONBODY  = ^_dwg_object_ASSOCTRIMSURFACEACTIONBODY;
    P_dwg_object_ASSOCVALUEDEPENDENCY  = ^_dwg_object_ASSOCVALUEDEPENDENCY;
    P_dwg_object_ASSOCVARIABLE  = ^_dwg_object_ASSOCVARIABLE;
    P_dwg_object_ASSOCVERTEXACTIONPARAM  = ^_dwg_object_ASSOCVERTEXACTIONPARAM;
    P_dwg_object_BLKREFOBJECTCONTEXTDATA  = ^_dwg_object_BLKREFOBJECTCONTEXTDATA;
    P_dwg_object_BLOCK_CONTROL  = ^_dwg_object_BLOCK_CONTROL;
    P_dwg_object_BLOCK_HEADER  = ^_dwg_object_BLOCK_HEADER;
    P_dwg_object_BLOCKALIGNEDCONSTRAINTPARAMETER  = ^_dwg_object_BLOCKALIGNEDCONSTRAINTPARAMETER;
    P_dwg_object_BLOCKALIGNMENTGRIP  = ^_dwg_object_BLOCKALIGNMENTGRIP;
    P_dwg_object_BLOCKALIGNMENTPARAMETER  = ^_dwg_object_BLOCKALIGNMENTPARAMETER;
    P_dwg_object_BLOCKANGULARCONSTRAINTPARAMETER  = ^_dwg_object_BLOCKANGULARCONSTRAINTPARAMETER;
    P_dwg_object_BLOCKARRAYACTION  = ^_dwg_object_BLOCKARRAYACTION;
    P_dwg_object_BLOCKBASEPOINTPARAMETER  = ^_dwg_object_BLOCKBASEPOINTPARAMETER;
    P_dwg_object_BLOCKDIAMETRICCONSTRAINTPARAMETER  = ^_dwg_object_BLOCKDIAMETRICCONSTRAINTPARAMETER;
    P_dwg_object_BLOCKFLIPACTION  = ^_dwg_object_BLOCKFLIPACTION;
    P_dwg_object_BLOCKFLIPGRIP  = ^_dwg_object_BLOCKFLIPGRIP;
    P_dwg_object_BLOCKFLIPPARAMETER  = ^_dwg_object_BLOCKFLIPPARAMETER;
    P_dwg_object_BLOCKGRIPLOCATIONCOMPONENT  = ^_dwg_object_BLOCKGRIPLOCATIONCOMPONENT;
    P_dwg_object_BLOCKHORIZONTALCONSTRAINTPARAMETER  = ^_dwg_object_BLOCKHORIZONTALCONSTRAINTPARAMETER;
    P_dwg_object_BLOCKLINEARCONSTRAINTPARAMETER  = ^_dwg_object_BLOCKLINEARCONSTRAINTPARAMETER;
    P_dwg_object_BLOCKLINEARGRIP  = ^_dwg_object_BLOCKLINEARGRIP;
    P_dwg_object_BLOCKLINEARPARAMETER  = ^_dwg_object_BLOCKLINEARPARAMETER;
    P_dwg_object_BLOCKLOOKUPACTION  = ^_dwg_object_BLOCKLOOKUPACTION;
    P_dwg_object_BLOCKLOOKUPGRIP  = ^_dwg_object_BLOCKLOOKUPGRIP;
    P_dwg_object_BLOCKLOOKUPPARAMETER  = ^_dwg_object_BLOCKLOOKUPPARAMETER;
    P_dwg_object_BLOCKMOVEACTION  = ^_dwg_object_BLOCKMOVEACTION;
    P_dwg_object_BLOCKPARAMDEPENDENCYBODY  = ^_dwg_object_BLOCKPARAMDEPENDENCYBODY;
    P_dwg_object_BLOCKPOINTPARAMETER  = ^_dwg_object_BLOCKPOINTPARAMETER;
    P_dwg_object_BLOCKPOLARGRIP  = ^_dwg_object_BLOCKPOLARGRIP;
    P_dwg_object_BLOCKPOLARPARAMETER  = ^_dwg_object_BLOCKPOLARPARAMETER;
    P_dwg_object_BLOCKPOLARSTRETCHACTION  = ^_dwg_object_BLOCKPOLARSTRETCHACTION;
    P_dwg_object_BLOCKPROPERTIESTABLE  = ^_dwg_object_BLOCKPROPERTIESTABLE;
    P_dwg_object_BLOCKPROPERTIESTABLEGRIP  = ^_dwg_object_BLOCKPROPERTIESTABLEGRIP;
    P_dwg_object_BLOCKRADIALCONSTRAINTPARAMETER  = ^_dwg_object_BLOCKRADIALCONSTRAINTPARAMETER;
    P_dwg_object_BLOCKREPRESENTATION  = ^_dwg_object_BLOCKREPRESENTATION;
    P_dwg_object_BLOCKROTATEACTION  = ^_dwg_object_BLOCKROTATEACTION;
    P_dwg_object_BLOCKROTATIONGRIP  = ^_dwg_object_BLOCKROTATIONGRIP;
    P_dwg_object_BLOCKROTATIONPARAMETER  = ^_dwg_object_BLOCKROTATIONPARAMETER;
    P_dwg_object_BLOCKSCALEACTION  = ^_dwg_object_BLOCKSCALEACTION;
    P_dwg_object_BLOCKSTRETCHACTION  = ^_dwg_object_BLOCKSTRETCHACTION;
    P_dwg_object_BLOCKUSERPARAMETER  = ^_dwg_object_BLOCKUSERPARAMETER;
    P_dwg_object_BLOCKVERTICALCONSTRAINTPARAMETER  = ^_dwg_object_BLOCKVERTICALCONSTRAINTPARAMETER;
    P_dwg_object_BLOCKVISIBILITYGRIP  = ^_dwg_object_BLOCKVISIBILITYGRIP;
    P_dwg_object_BLOCKVISIBILITYPARAMETER  = ^_dwg_object_BLOCKVISIBILITYPARAMETER;
    P_dwg_object_BLOCKXYGRIP  = ^_dwg_object_BLOCKXYGRIP;
    P_dwg_object_BLOCKXYPARAMETER  = ^_dwg_object_BLOCKXYPARAMETER;
    P_dwg_object_BREAKDATA  = ^_dwg_object_BREAKDATA;
    P_dwg_object_BREAKPOINTREF  = ^_dwg_object_BREAKPOINTREF;
    P_dwg_object_CELLSTYLEMAP  = ^_dwg_object_CELLSTYLEMAP;
    P_dwg_object_CONTEXTDATAMANAGER  = ^_dwg_object_CONTEXTDATAMANAGER;
    P_dwg_object_CSACDOCUMENTOPTIONS  = ^_dwg_object_CSACDOCUMENTOPTIONS;
    P_dwg_object_CURVEPATH  = ^_dwg_object_CURVEPATH;
    P_dwg_object_DATALINK  = ^_dwg_object_DATALINK;
    P_dwg_object_DATATABLE  = ^_dwg_object_DATATABLE;
    P_dwg_object_DBCOLOR  = ^_dwg_object_DBCOLOR;
    P_dwg_object_DETAILVIEWSTYLE  = ^_dwg_object_DETAILVIEWSTYLE;
    P_dwg_object_DICTIONARY  = ^_dwg_object_DICTIONARY;
    P_dwg_object_DICTIONARYVAR  = ^_dwg_object_DICTIONARYVAR;
    P_dwg_object_DICTIONARYWDFLT  = ^_dwg_object_DICTIONARYWDFLT;
    P_dwg_object_DIMASSOC  = ^_dwg_object_DIMASSOC;
    P_dwg_object_DIMSTYLE  = ^_dwg_object_DIMSTYLE;
    P_dwg_object_DIMSTYLE_CONTROL  = ^_dwg_object_DIMSTYLE_CONTROL;
    P_dwg_object_DMDIMOBJECTCONTEXTDATA  = ^_dwg_object_DMDIMOBJECTCONTEXTDATA;
    P_dwg_object_DUMMY  = ^_dwg_object_DUMMY;
    P_dwg_object_DYNAMICBLOCKPROXYNODE  = ^_dwg_object_DYNAMICBLOCKPROXYNODE;
    P_dwg_object_DYNAMICBLOCKPURGEPREVENTER  = ^_dwg_object_DYNAMICBLOCKPURGEPREVENTER;
    P_dwg_object_entity  = ^_dwg_object_entity;
    P_dwg_object_EVALUATION_GRAPH  = ^_dwg_object_EVALUATION_GRAPH;
    P_dwg_object_FCFOBJECTCONTEXTDATA  = ^_dwg_object_FCFOBJECTCONTEXTDATA;
    P_dwg_object_FIELD  = ^_dwg_object_FIELD;
    P_dwg_object_FIELDLIST  = ^_dwg_object_FIELDLIST;
    P_dwg_object_GEODATA  = ^_dwg_object_GEODATA;
    P_dwg_object_GEOMAPIMAGE  = ^_dwg_object_GEOMAPIMAGE;
    P_dwg_object_GRADIENT_BACKGROUND  = ^_dwg_object_GRADIENT_BACKGROUND;
    P_dwg_object_GROUND_PLANE_BACKGROUND  = ^_dwg_object_GROUND_PLANE_BACKGROUND;
    P_dwg_object_GROUP  = ^_dwg_object_GROUP;
    P_dwg_object_IBL_BACKGROUND  = ^_dwg_object_IBL_BACKGROUND;
    P_dwg_object_IDBUFFER  = ^_dwg_object_IDBUFFER;
    P_dwg_object_IMAGE_BACKGROUND  = ^_dwg_object_IMAGE_BACKGROUND;
    P_dwg_object_IMAGEDEF  = ^_dwg_object_IMAGEDEF;
    P_dwg_object_IMAGEDEF_REACTOR  = ^_dwg_object_IMAGEDEF_REACTOR;
    P_dwg_object_INDEX  = ^_dwg_object_INDEX;
    P_dwg_object_LAYER  = ^_dwg_object_LAYER;
    P_dwg_object_LAYER_CONTROL  = ^_dwg_object_LAYER_CONTROL;
    P_dwg_object_LAYER_INDEX  = ^_dwg_object_LAYER_INDEX;
    P_dwg_object_LAYERFILTER  = ^_dwg_object_LAYERFILTER;
    P_dwg_object_LAYOUT  = ^_dwg_object_LAYOUT;
    P_dwg_object_LAYOUTPRINTCONFIG  = ^_dwg_object_LAYOUTPRINTCONFIG;
    P_dwg_object_LEADEROBJECTCONTEXTDATA  = ^_dwg_object_LEADEROBJECTCONTEXTDATA;
    P_dwg_object_LIGHTLIST  = ^_dwg_object_LIGHTLIST;
    P_dwg_object_LONG_TRANSACTION  = ^_dwg_object_LONG_TRANSACTION;
    P_dwg_object_LTYPE  = ^_dwg_object_LTYPE;
    P_dwg_object_LTYPE_CONTROL  = ^_dwg_object_LTYPE_CONTROL;
    P_dwg_object_MATERIAL  = ^_dwg_object_MATERIAL;
    P_dwg_object_MENTALRAYRENDERSETTINGS  = ^_dwg_object_MENTALRAYRENDERSETTINGS;
    P_dwg_object_MLEADEROBJECTCONTEXTDATA  = ^_dwg_object_MLEADEROBJECTCONTEXTDATA;
    P_dwg_object_MLEADERSTYLE  = ^_dwg_object_MLEADERSTYLE;
    P_dwg_object_MLINESTYLE  = ^_dwg_object_MLINESTYLE;
    P_dwg_object_MOTIONPATH  = ^_dwg_object_MOTIONPATH;
    P_dwg_object_MTEXTATTRIBUTEOBJECTCONTEXTDATA  = ^_dwg_object_MTEXTATTRIBUTEOBJECTCONTEXTDATA;
    P_dwg_object_MTEXTOBJECTCONTEXTDATA  = ^_dwg_object_MTEXTOBJECTCONTEXTDATA;
    P_dwg_object_NAVISWORKSMODELDEF  = ^_dwg_object_NAVISWORKSMODELDEF;
    P_dwg_object_object  = ^_dwg_object_object;
    P_dwg_object_OBJECT_PTR  = ^_dwg_object_OBJECT_PTR;
    P_dwg_object_ORDDIMOBJECTCONTEXTDATA  = ^_dwg_object_ORDDIMOBJECTCONTEXTDATA;
    P_dwg_object_PARTIAL_VIEWING_INDEX  = ^_dwg_object_PARTIAL_VIEWING_INDEX;
    P_dwg_object_PERSUBENTMGR  = ^_dwg_object_PERSUBENTMGR;
    P_dwg_object_PLACEHOLDER  = ^_dwg_object_PLACEHOLDER;
    P_dwg_object_PLOTSETTINGS  = ^_dwg_object_PLOTSETTINGS;
    P_dwg_object_POINTCLOUDCOLORMAP  = ^_dwg_object_POINTCLOUDCOLORMAP;
    P_dwg_object_POINTCLOUDDEF  = ^_dwg_object_POINTCLOUDDEF;
    P_dwg_object_POINTCLOUDDEF_REACTOR  = ^_dwg_object_POINTCLOUDDEF_REACTOR;
    P_dwg_object_POINTCLOUDDEF_REACTOR_EX  = ^_dwg_object_POINTCLOUDDEF_REACTOR_EX;
    P_dwg_object_POINTCLOUDDEFEX  = ^_dwg_object_POINTCLOUDDEFEX;
    P_dwg_object_POINTPATH  = ^_dwg_object_POINTPATH;
    P_dwg_object_PROXY_OBJECT  = ^_dwg_object_PROXY_OBJECT;
    P_dwg_object_RADIMLGOBJECTCONTEXTDATA  = ^_dwg_object_RADIMLGOBJECTCONTEXTDATA;
    P_dwg_object_RADIMOBJECTCONTEXTDATA  = ^_dwg_object_RADIMOBJECTCONTEXTDATA;
    P_dwg_object_RAPIDRTRENDERSETTINGS  = ^_dwg_object_RAPIDRTRENDERSETTINGS;
    P_dwg_object_RASTERVARIABLES  = ^_dwg_object_RASTERVARIABLES;
    P_dwg_object_ref  = ^_dwg_object_ref;
    P_dwg_object_RENDERENTRY  = ^_dwg_object_RENDERENTRY;
    P_dwg_object_RENDERENVIRONMENT  = ^_dwg_object_RENDERENVIRONMENT;
    P_dwg_object_RENDERGLOBAL  = ^_dwg_object_RENDERGLOBAL;
    P_dwg_object_RENDERSETTINGS  = ^_dwg_object_RENDERSETTINGS;
    P_dwg_object_SCALE  = ^_dwg_object_SCALE;
    P_dwg_object_SECTION_MANAGER  = ^_dwg_object_SECTION_MANAGER;
    P_dwg_object_SECTION_SETTINGS  = ^_dwg_object_SECTION_SETTINGS;
    P_dwg_object_SECTIONVIEWSTYLE  = ^_dwg_object_SECTIONVIEWSTYLE;
    P_dwg_object_SKYLIGHT_BACKGROUND  = ^_dwg_object_SKYLIGHT_BACKGROUND;
    P_dwg_object_SOLID_BACKGROUND  = ^_dwg_object_SOLID_BACKGROUND;
    P_dwg_object_SORTENTSTABLE  = ^_dwg_object_SORTENTSTABLE;
    P_dwg_object_SPATIAL_FILTER  = ^_dwg_object_SPATIAL_FILTER;
    P_dwg_object_SPATIAL_INDEX  = ^_dwg_object_SPATIAL_INDEX;
    P_dwg_object_STYLE  = ^_dwg_object_STYLE;
    P_dwg_object_STYLE_CONTROL  = ^_dwg_object_STYLE_CONTROL;
    P_dwg_object_SUN  = ^_dwg_object_SUN;
    P_dwg_object_SUNSTUDY  = ^_dwg_object_SUNSTUDY;
    P_dwg_object_TABLECONTENT  = ^_dwg_object_TABLECONTENT;
    P_dwg_object_TABLEGEOMETRY  = ^_dwg_object_TABLEGEOMETRY;
    P_dwg_object_TABLESTYLE  = ^_dwg_object_TABLESTYLE;
    P_dwg_object_TEXTOBJECTCONTEXTDATA  = ^_dwg_object_TEXTOBJECTCONTEXTDATA;
    P_dwg_object_TVDEVICEPROPERTIES  = ^_dwg_object_TVDEVICEPROPERTIES;
    P_dwg_object_UCS  = ^_dwg_object_UCS;
    P_dwg_object_UCS_CONTROL  = ^_dwg_object_UCS_CONTROL;
    P_dwg_object_UNKNOWN_OBJ  = ^_dwg_object_UNKNOWN_OBJ;
    P_dwg_object_VBA_PROJECT  = ^_dwg_object_VBA_PROJECT;
    P_dwg_object_VIEW  = ^_dwg_object_VIEW;
    P_dwg_object_VIEW_CONTROL  = ^_dwg_object_VIEW_CONTROL;
    P_dwg_object_VISUALSTYLE  = ^_dwg_object_VISUALSTYLE;
    P_dwg_object_VPORT  = ^_dwg_object_VPORT;
    P_dwg_object_VPORT_CONTROL  = ^_dwg_object_VPORT_CONTROL;
    P_dwg_object_VX_CONTROL  = ^_dwg_object_VX_CONTROL;
    P_dwg_object_VX_TABLE_RECORD  = ^_dwg_object_VX_TABLE_RECORD;
    P_dwg_object_WIPEOUTVARIABLES  = ^_dwg_object_WIPEOUTVARIABLES;
    P_dwg_object_XRECORD  = ^_dwg_object_XRECORD;
    P_dwg_objfreespace  = ^_dwg_objfreespace;
    P_dwg_OCD_Dimension  = ^_dwg_OCD_Dimension;
    P_dwg_PARTIAL_VIEWING_INDEX_Entry  = ^_dwg_PARTIAL_VIEWING_INDEX_Entry;
    P_dwg_POINTCLOUD_Clippings  = ^_dwg_POINTCLOUD_Clippings;
    P_dwg_POINTCLOUD_IntensityStyle  = ^_dwg_POINTCLOUD_IntensityStyle;
    P_dwg_POINTCLOUDCOLORMAP_Ramp  = ^_dwg_POINTCLOUDCOLORMAP_Ramp;
    P_dwg_POINTCLOUDEX_Croppings  = ^_dwg_POINTCLOUDEX_Croppings;
    P_dwg_PROXY_LWPOLYLINE  = ^_dwg_PROXY_LWPOLYLINE;
    P_dwg_R2004_Header  = ^_dwg_R2004_Header;
    P_dwg_resbuf  = ^_dwg_resbuf;
    P_dwg_revhistory  = ^_dwg_revhistory;
    P_dwg_second_header  = ^_dwg_second_header;
    P_dwg_section  = ^_dwg_section;
    P_dwg_SECTION_geometrysettings  = ^_dwg_SECTION_geometrysettings;
    P_dwg_SECTION_typesettings  = ^_dwg_SECTION_typesettings;
    P_dwg_security  = ^_dwg_security;
    P_dwg_SPLINE_control_point  = ^_dwg_SPLINE_control_point;
    P_dwg_struct  = ^_dwg_struct;
    P_dwg_summaryinfo  = ^_dwg_summaryinfo;
    P_dwg_SummaryInfo_Property  = ^_dwg_SummaryInfo_Property;
    P_dwg_SUNSTUDY_Dates  = ^_dwg_SUNSTUDY_Dates;
    P_dwg_TABLE_AttrDef  = ^_dwg_TABLE_AttrDef;
    P_dwg_TABLE_BreakHeight  = ^_dwg_TABLE_BreakHeight;
    P_dwg_TABLE_BreakRow  = ^_dwg_TABLE_BreakRow;
    P_dwg_TABLE_Cell  = ^_dwg_TABLE_Cell;
    P_dwg_TABLE_CustomDataItem  = ^_dwg_TABLE_CustomDataItem;
    P_dwg_TABLE_value  = ^_dwg_TABLE_value;
    P_dwg_TableCell  = ^_dwg_TableCell;
    P_dwg_TableCellContent  = ^_dwg_TableCellContent;
    P_dwg_TableCellContent_Attr  = ^_dwg_TableCellContent_Attr;
    P_dwg_TableDataColumn  = ^_dwg_TableDataColumn;
    P_dwg_TABLEGEOMETRY_Cell  = ^_dwg_TABLEGEOMETRY_Cell;
    P_dwg_TableRow  = ^_dwg_TableRow;
    P_dwg_TABLESTYLE_border  = ^_dwg_TABLESTYLE_border;
    P_dwg_TABLESTYLE_CellStyle  = ^_dwg_TABLESTYLE_CellStyle;
    P_dwg_TABLESTYLE_rowstyles  = ^_dwg_TABLESTYLE_rowstyles;
    P_dwg_template  = ^_dwg_template;
    P_dwg_time_bll  = ^_dwg_time_bll;
    P_dwg_UCS_orthopts  = ^_dwg_UCS_orthopts;
    P_dwg_VALUEPARAM  = ^_dwg_VALUEPARAM;
    P_dwg_VALUEPARAM_vars  = ^_dwg_VALUEPARAM_vars;
    P_dwg_vbaproject  = ^_dwg_vbaproject;
    //P_inthash  = ^_inthash;
    PBITCODE_2BD  = ^BITCODE_2BD;
    PBITCODE_2BD_1  = ^BITCODE_2BD_1;
    PBITCODE_2DPOINT  = ^BITCODE_2DPOINT;
    PBITCODE_2RD  = ^BITCODE_2RD;
    PBITCODE_3B  = ^BITCODE_3B;
    PBITCODE_3BD  = ^BITCODE_3BD;
    PBITCODE_3BD_1  = ^BITCODE_3BD_1;
    PBITCODE_3DPOINT  = ^BITCODE_3DPOINT;
    PBITCODE_3RD  = ^BITCODE_3RD;
    PBITCODE_4BITS  = ^BITCODE_4BITS;
    PBITCODE_B  = ^BITCODE_B;
    PBITCODE_BB  = ^BITCODE_BB;
    PBITCODE_BD  = ^BITCODE_BD;
    PBITCODE_BE  = ^BITCODE_BE;
    PBITCODE_BL  = ^BITCODE_BL;
    PBITCODE_BLd  = ^BITCODE_BLd;
    PBITCODE_BLL  = ^BITCODE_BLL;
    PBITCODE_BLx  = ^BITCODE_BLx;
    PBITCODE_BS  = ^BITCODE_BS;
    PBITCODE_BSd  = ^BITCODE_BSd;
    PBITCODE_BSx  = ^BITCODE_BSx;
    PBITCODE_BT  = ^BITCODE_BT;
    PBITCODE_CMC  = ^BITCODE_CMC;
    PBITCODE_CMTC  = ^BITCODE_CMTC;
    PBITCODE_D2T  = ^BITCODE_D2T;
    PBITCODE_DD  = ^BITCODE_DD;
    PBITCODE_ENC  = ^BITCODE_ENC;
    PBITCODE_H  = ^BITCODE_H;
    PBITCODE_MC  = ^BITCODE_MC;
    PBITCODE_MS  = ^BITCODE_MS;
    PBITCODE_RC  = ^BITCODE_RC;
    PBITCODE_RCd  = ^BITCODE_RCd;
    PBITCODE_RCu  = ^BITCODE_RCu;
    PBITCODE_RCx  = ^BITCODE_RCx;
    PBITCODE_RD  = ^BITCODE_RD;
    PBITCODE_RL  = ^BITCODE_RL;
    PBITCODE_RLd  = ^BITCODE_RLd;
    PBITCODE_RLL  = ^BITCODE_RLL;
    PBITCODE_RLLd  = ^BITCODE_RLLd;
    PBITCODE_RLx  = ^BITCODE_RLx;
    PBITCODE_RS  = ^BITCODE_RS;
    PBITCODE_RSd  = ^BITCODE_RSd;
    PBITCODE_RSx  = ^BITCODE_RSx;
    PBITCODE_TF  = ^BITCODE_TF;
    PBITCODE_TIMEBLL  = ^BITCODE_TIMEBLL;
    PBITCODE_TIMERLL  = ^BITCODE_TIMERLL;
    PBITCODE_TU  = ^BITCODE_TU;
    PBITCODE_TV  = ^BITCODE_TV;
    PBITCODE_UMC  = ^BITCODE_UMC;
    Pchar  = ^char;
    PDwg_3DSOLID_material  = ^Dwg_3DSOLID_material;
    PDwg_3DSOLID_silhouette  = ^Dwg_3DSOLID_silhouette;
    PDwg_3DSOLID_wire  = ^Dwg_3DSOLID_wire;
    PDwg_AcDs  = ^Dwg_AcDs;
    PDwg_AcDs_Data  = ^Dwg_AcDs_Data;
    PDwg_AcDs_Data_Record  = ^Dwg_AcDs_Data_Record;
    PDwg_AcDs_Data_RecordHdr  = ^Dwg_AcDs_Data_RecordHdr;
    PDwg_AcDs_DataBlob  = ^Dwg_AcDs_DataBlob;
    PDwg_AcDs_DataBlob01  = ^Dwg_AcDs_DataBlob01;
    PDwg_AcDs_DataBlobRef  = ^Dwg_AcDs_DataBlobRef;
    PDwg_AcDs_DataBlobRef_Page  = ^Dwg_AcDs_DataBlobRef_Page;
    PDwg_AcDs_DataIndex  = ^Dwg_AcDs_DataIndex;
    PDwg_AcDs_DataIndex_Entry  = ^Dwg_AcDs_DataIndex_Entry;
    PDwg_AcDs_Schema  = ^Dwg_AcDs_Schema;
    PDwg_AcDs_Schema_Prop  = ^Dwg_AcDs_Schema_Prop;
    PDwg_AcDs_SchemaData  = ^Dwg_AcDs_SchemaData;
    PDwg_AcDs_SchemaData_UProp  = ^Dwg_AcDs_SchemaData_UProp;
    PDwg_AcDs_SchemaIndex  = ^Dwg_AcDs_SchemaIndex;
    PDwg_AcDs_SchemaIndex_Prop  = ^Dwg_AcDs_SchemaIndex_Prop;
    PDwg_AcDs_Search  = ^Dwg_AcDs_Search;
    PDwg_AcDs_Search_Data  = ^Dwg_AcDs_Search_Data;
    PDwg_AcDs_Search_IdIdx  = ^Dwg_AcDs_Search_IdIdx;
    PDwg_AcDs_Search_IdIdxs  = ^Dwg_AcDs_Search_IdIdxs;
    PDwg_AcDs_Segment  = ^Dwg_AcDs_Segment;
    PDwg_AcDs_SegmentIndex  = ^Dwg_AcDs_SegmentIndex;
    PDwg_ACSH_HistoryNode  = ^Dwg_ACSH_HistoryNode;
    PDwg_ACSH_SubentColor  = ^Dwg_ACSH_SubentColor;
    PDwg_ACSH_SubentMaterial  = ^Dwg_ACSH_SubentMaterial;
    PDwg_ACTIONBODY  = ^Dwg_ACTIONBODY;
    PDwg_AppInfo  = ^Dwg_AppInfo;
    PDwg_AppInfoHistory  = ^Dwg_AppInfoHistory;
    PDwg_ARRAYITEMLOCATOR  = ^Dwg_ARRAYITEMLOCATOR;
    PDwg_ASSOCACTION_Deps  = ^Dwg_ASSOCACTION_Deps;
    PDwg_ASSOCACTIONBODY_action  = ^Dwg_ASSOCACTIONBODY_action;
    PDwg_ASSOCARRAYITEM  = ^Dwg_ASSOCARRAYITEM;
    PDwg_ASSOCPARAMBASEDACTIONBODY  = ^Dwg_ASSOCPARAMBASEDACTIONBODY;
    PDwg_ASSOCSURFACEACTIONBODY  = ^Dwg_ASSOCSURFACEACTIONBODY;
    PDwg_AuxHeader  = ^Dwg_AuxHeader;
    PDwg_Bitcode_2BD  = ^Dwg_Bitcode_2BD;
    PDwg_Bitcode_2RD  = ^Dwg_Bitcode_2RD;
    PDwg_Bitcode_3BD  = ^Dwg_Bitcode_3BD;
    PDwg_Bitcode_3RD  = ^Dwg_Bitcode_3RD;
    PDwg_Bitcode_TimeBLL  = ^Dwg_Bitcode_TimeBLL;
    PDwg_BLOCKACTION_connectionpts  = ^Dwg_BLOCKACTION_connectionpts;
    PDwg_BLOCKLOOKUPACTION_lut  = ^Dwg_BLOCKLOOKUPACTION_lut;
    PDwg_BLOCKPARAMETER_connection  = ^Dwg_BLOCKPARAMETER_connection;
    PDwg_BLOCKPARAMETER_PropInfo  = ^Dwg_BLOCKPARAMETER_PropInfo;
    PDwg_BLOCKPARAMVALUESET  = ^Dwg_BLOCKPARAMVALUESET;
    PDwg_BLOCKVISIBILITYPARAMETER_state  = ^Dwg_BLOCKVISIBILITYPARAMETER_state;
    PDwg_CellContentGeometry  = ^Dwg_CellContentGeometry;
    PDwg_CellStyle  = ^Dwg_CellStyle;
    PDwg_Chain  = ^Dwg_Chain;
    PDwg_Class  = ^Dwg_Class;
    PDWG_CLASS_STABILITY  = ^DWG_CLASS_STABILITY;
    PDwg_Color  = ^Dwg_Color;
    PDwg_ColorRamp  = ^Dwg_ColorRamp;
    PDwg_COMPOUNDOBJECTID  = ^Dwg_COMPOUNDOBJECTID;
    PDwg_CONSTRAINTGROUPNODE  = ^Dwg_CONSTRAINTGROUPNODE;
    PDwg_ContentFormat  = ^Dwg_ContentFormat;
    PDwg_CONTEXTDATA_dict  = ^Dwg_CONTEXTDATA_dict;
    PDwg_CONTEXTDATA_submgr  = ^Dwg_CONTEXTDATA_submgr;
    PDwg_Data  = ^Dwg_Data;
    PDwg_DATALINK_customdata  = ^Dwg_DATALINK_customdata;
    PDwg_DATATABLE_column  = ^Dwg_DATATABLE_column;
    PDwg_DATATABLE_row  = ^Dwg_DATATABLE_row;
    PDwg_DIMASSOC_Ref  = ^Dwg_DIMASSOC_Ref;
    PDwg_DIMENSION_common  = ^Dwg_DIMENSION_common;
    PDwg_Eed  = ^Dwg_Eed;
    PDwg_Eed_Data  = ^Dwg_Eed_Data;
    PDwg_Entity__3DFACE  = ^Dwg_Entity__3DFACE;
    PDwg_Entity__3DLINE  = ^Dwg_Entity__3DLINE;
    PDwg_Entity__3DSOLID  = ^Dwg_Entity__3DSOLID;
    PDwg_Entity_ALIGNMENTPARAMETERENTITY  = ^Dwg_Entity_ALIGNMENTPARAMETERENTITY;
    PDwg_Entity_ARC  = ^Dwg_Entity_ARC;
    PDwg_Entity_ARC_DIMENSION  = ^Dwg_Entity_ARC_DIMENSION;
    PDwg_Entity_ARCALIGNEDTEXT  = ^Dwg_Entity_ARCALIGNEDTEXT;
    PDwg_Entity_ATTDEF  = ^Dwg_Entity_ATTDEF;
    PDwg_Entity_ATTRIB  = ^Dwg_Entity_ATTRIB;
    PDwg_Entity_BASEPOINTPARAMETERENTITY  = ^Dwg_Entity_BASEPOINTPARAMETERENTITY;
    PDwg_Entity_BLOCK  = ^Dwg_Entity_BLOCK;
    PDwg_Entity_BODY  = ^Dwg_Entity_BODY;
    PDwg_Entity_CAMERA  = ^Dwg_Entity_CAMERA;
    PDwg_Entity_CIRCLE  = ^Dwg_Entity_CIRCLE;
    PDwg_Entity_DGNUNDERLAY  = ^Dwg_Entity_DGNUNDERLAY;
    PDwg_Entity_DIMENSION_ALIGNED  = ^Dwg_Entity_DIMENSION_ALIGNED;
    PDwg_Entity_DIMENSION_ANG2LN  = ^Dwg_Entity_DIMENSION_ANG2LN;
    PDwg_Entity_DIMENSION_ANG3PT  = ^Dwg_Entity_DIMENSION_ANG3PT;
    PDwg_Entity_DIMENSION_DIAMETER  = ^Dwg_Entity_DIMENSION_DIAMETER;
    PDwg_Entity_DIMENSION_LINEAR  = ^Dwg_Entity_DIMENSION_LINEAR;
    PDwg_Entity_DIMENSION_ORDINATE  = ^Dwg_Entity_DIMENSION_ORDINATE;
    PDwg_Entity_DIMENSION_RADIUS  = ^Dwg_Entity_DIMENSION_RADIUS;
    PDwg_Entity_DWFUNDERLAY  = ^Dwg_Entity_DWFUNDERLAY;
    PDwg_Entity_ELLIPSE  = ^Dwg_Entity_ELLIPSE;
    PDwg_Entity_ENDBLK  = ^Dwg_Entity_ENDBLK;
    PDwg_Entity_ENDREP  = ^Dwg_Entity_ENDREP;
    PDwg_Entity_EXTRUDEDSURFACE  = ^Dwg_Entity_EXTRUDEDSURFACE;
    PDwg_Entity_FLIPGRIPENTITY  = ^Dwg_Entity_FLIPGRIPENTITY;
    PDwg_Entity_FLIPPARAMETERENTITY  = ^Dwg_Entity_FLIPPARAMETERENTITY;
    PDwg_Entity_GEOPOSITIONMARKER  = ^Dwg_Entity_GEOPOSITIONMARKER;
    PDwg_Entity_HATCH  = ^Dwg_Entity_HATCH;
    PDwg_Entity_HELIX  = ^Dwg_Entity_HELIX;
    PDwg_Entity_IMAGE  = ^Dwg_Entity_IMAGE;
    PDwg_Entity_INSERT  = ^Dwg_Entity_INSERT;
    PDwg_Entity_LARGE_RADIAL_DIMENSION  = ^Dwg_Entity_LARGE_RADIAL_DIMENSION;
    PDwg_Entity_LEADER  = ^Dwg_Entity_LEADER;
    PDwg_Entity_LIGHT  = ^Dwg_Entity_LIGHT;
    PDwg_Entity_LINE  = ^Dwg_Entity_LINE;
    PDwg_Entity_LINEARGRIPENTITY  = ^Dwg_Entity_LINEARGRIPENTITY;
    PDwg_Entity_LINEARPARAMETERENTITY  = ^Dwg_Entity_LINEARPARAMETERENTITY;
    PDwg_Entity_LOAD  = ^Dwg_Entity_LOAD;
    PDwg_Entity_LOFTEDSURFACE  = ^Dwg_Entity_LOFTEDSURFACE;
    PDwg_Entity_LWPOLYLINE  = ^Dwg_Entity_LWPOLYLINE;
    PDwg_Entity_MESH  = ^Dwg_Entity_MESH;
    PDwg_Entity_MINSERT  = ^Dwg_Entity_MINSERT;
    PDwg_Entity_MLINE  = ^Dwg_Entity_MLINE;
    PDwg_Entity_MPOLYGON  = ^Dwg_Entity_MPOLYGON;
    PDwg_Entity_MTEXT  = ^Dwg_Entity_MTEXT;
    PDwg_Entity_MULTILEADER  = ^Dwg_Entity_MULTILEADER;
    PDwg_Entity_NAVISWORKSMODEL  = ^Dwg_Entity_NAVISWORKSMODEL;
    PDwg_Entity_NURBSURFACE  = ^Dwg_Entity_NURBSURFACE;
    PDwg_Entity_OLE2FRAME  = ^Dwg_Entity_OLE2FRAME;
    PDwg_Entity_OLEFRAME  = ^Dwg_Entity_OLEFRAME;
    PDwg_Entity_PDFUNDERLAY  = ^Dwg_Entity_PDFUNDERLAY;
    PDwg_Entity_PLANESURFACE  = ^Dwg_Entity_PLANESURFACE;
    PDwg_Entity_POINT  = ^Dwg_Entity_POINT;
    PDwg_Entity_POINTCLOUD  = ^Dwg_Entity_POINTCLOUD;
    PDwg_Entity_POINTCLOUDEX  = ^Dwg_Entity_POINTCLOUDEX;
    PDwg_Entity_POINTPARAMETERENTITY  = ^Dwg_Entity_POINTPARAMETERENTITY;
    PDwg_Entity_POLARGRIPENTITY  = ^Dwg_Entity_POLARGRIPENTITY;
    PDwg_Entity_POLYLINE_2D  = ^Dwg_Entity_POLYLINE_2D;
    PDwg_Entity_POLYLINE_3D  = ^Dwg_Entity_POLYLINE_3D;
    PDwg_Entity_POLYLINE_MESH  = ^Dwg_Entity_POLYLINE_MESH;
    PDwg_Entity_POLYLINE_PFACE  = ^Dwg_Entity_POLYLINE_PFACE;
    PDwg_Entity_PROXY_ENTITY  = ^Dwg_Entity_PROXY_ENTITY;
    PDwg_Entity_RAY  = ^Dwg_Entity_RAY;
    PDwg_Entity_REGION  = ^Dwg_Entity_REGION;
    PDwg_Entity_REPEAT  = ^Dwg_Entity_REPEAT;
    PDwg_Entity_REVOLVEDSURFACE  = ^Dwg_Entity_REVOLVEDSURFACE;
    PDwg_Entity_ROTATIONGRIPENTITY  = ^Dwg_Entity_ROTATIONGRIPENTITY;
    PDwg_Entity_ROTATIONPARAMETERENTITY  = ^Dwg_Entity_ROTATIONPARAMETERENTITY;
    PDwg_Entity_RTEXT  = ^Dwg_Entity_RTEXT;
    PDwg_Entity_SECTIONOBJECT  = ^Dwg_Entity_SECTIONOBJECT;
    PDwg_Entity_SEQEND  = ^Dwg_Entity_SEQEND;
    PDwg_Entity_SHAPE  = ^Dwg_Entity_SHAPE;
    PDwg_Entity_SOLID  = ^Dwg_Entity_SOLID;
    PDwg_Entity_SPLINE  = ^Dwg_Entity_SPLINE;
    PDwg_Entity_SWEPTSURFACE  = ^Dwg_Entity_SWEPTSURFACE;
    PDwg_Entity_TABLE  = ^Dwg_Entity_TABLE;
    PDwg_Entity_TEXT  = ^Dwg_Entity_TEXT;
    PDwg_Entity_TOLERANCE  = ^Dwg_Entity_TOLERANCE;
    PDwg_Entity_TRACE  = ^Dwg_Entity_TRACE;
    PDwg_Entity_UNDERLAY  = ^Dwg_Entity_UNDERLAY;
    PDwg_Entity_UNKNOWN_ENT  = ^Dwg_Entity_UNKNOWN_ENT;
    PDwg_Entity_UNUSED  = ^Dwg_Entity_UNUSED;
    PDwg_Entity_VERTEX_2D  = ^Dwg_Entity_VERTEX_2D;
    PDwg_Entity_VERTEX_3D  = ^Dwg_Entity_VERTEX_3D;
    PDwg_Entity_VERTEX_MESH  = ^Dwg_Entity_VERTEX_MESH;
    PDwg_Entity_VERTEX_PFACE  = ^Dwg_Entity_VERTEX_PFACE;
    PDwg_Entity_VERTEX_PFACE_FACE  = ^Dwg_Entity_VERTEX_PFACE_FACE;
    PDwg_Entity_VIEWPORT  = ^Dwg_Entity_VIEWPORT;
    PDwg_Entity_VISIBILITYGRIPENTITY  = ^Dwg_Entity_VISIBILITYGRIPENTITY;
    PDwg_Entity_VISIBILITYPARAMETERENTITY  = ^Dwg_Entity_VISIBILITYPARAMETERENTITY;
    PDwg_Entity_WIPEOUT  = ^Dwg_Entity_WIPEOUT;
    PDwg_Entity_XLINE  = ^Dwg_Entity_XLINE;
    PDwg_Entity_XYGRIPENTITY  = ^Dwg_Entity_XYGRIPENTITY;
    PDwg_Entity_XYPARAMETERENTITY  = ^Dwg_Entity_XYPARAMETERENTITY;
    PDWG_ERROR  = ^DWG_ERROR;
    PDwg_EVAL_Edge  = ^Dwg_EVAL_Edge;
    PDwg_EVAL_Node  = ^Dwg_EVAL_Node;
    PDwg_EvalExpr  = ^Dwg_EvalExpr;
    PDwg_EvalVariant  = ^Dwg_EvalVariant;
    PDwg_FIELD_ChildValue  = ^Dwg_FIELD_ChildValue;
    PDwg_FileDepList  = ^Dwg_FileDepList;
    PDwg_FileDepList_Files  = ^Dwg_FileDepList_Files;
    PDwg_FormattedTableData  = ^Dwg_FormattedTableData;
    PDwg_FormattedTableMerged  = ^Dwg_FormattedTableMerged;
    PDwg_GEODATA_meshface  = ^Dwg_GEODATA_meshface;
    PDwg_GEODATA_meshpt  = ^Dwg_GEODATA_meshpt;
    PDwg_GridFormat  = ^Dwg_GridFormat;
    PDwg_Handle  = ^Dwg_Handle;
    PDwg_HATCH_Color  = ^Dwg_HATCH_Color;
    PDwg_HATCH_ControlPoint  = ^Dwg_HATCH_ControlPoint;
    PDwg_HATCH_DefLine  = ^Dwg_HATCH_DefLine;
    PDwg_HATCH_Path  = ^Dwg_HATCH_Path;
    PDwg_HATCH_PathSeg  = ^Dwg_HATCH_PathSeg;
    PDwg_HATCH_PolylinePath  = ^Dwg_HATCH_PolylinePath;
    PDWG_HDL_CODE  = ^DWG_HDL_CODE;
    PDwg_Header  = ^Dwg_Header;
    PDwg_Header_Variables  = ^Dwg_Header_Variables;
    PDwg_LAYER_entry  = ^Dwg_LAYER_entry;
    PDwg_LEADER_ArrowHead  = ^Dwg_LEADER_ArrowHead;
    PDwg_LEADER_BlockLabel  = ^Dwg_LEADER_BlockLabel;
    PDwg_LEADER_Break  = ^Dwg_LEADER_Break;
    PDwg_LEADER_Line  = ^Dwg_LEADER_Line;
    PDwg_LEADER_Node  = ^Dwg_LEADER_Node;
    PDwg_LIGHTLIST_light  = ^Dwg_LIGHTLIST_light;
    PDwg_LinkedData  = ^Dwg_LinkedData;
    PDwg_LinkedTableData  = ^Dwg_LinkedTableData;
    PDwg_LTYPE_dash  = ^Dwg_LTYPE_dash;
    PDwg_LWPOLYLINE_width  = ^Dwg_LWPOLYLINE_width;
    PDwg_MATERIAL_color  = ^Dwg_MATERIAL_color;
    PDwg_MATERIAL_gentexture  = ^Dwg_MATERIAL_gentexture;
    PDwg_MATERIAL_mapper  = ^Dwg_MATERIAL_mapper;
    PDwg_MESH_edge  = ^Dwg_MESH_edge;
    PDwg_MLEADER_AnnotContext  = ^Dwg_MLEADER_AnnotContext;
    PDwg_MLEADER_Content  = ^Dwg_MLEADER_Content;
    PDwg_MLEADER_Content_Block  = ^Dwg_MLEADER_Content_Block;
    PDwg_MLEADER_Content_MText  = ^Dwg_MLEADER_Content_MText;
    PDwg_MLINE_line  = ^Dwg_MLINE_line;
    PDwg_MLINE_vertex  = ^Dwg_MLINE_vertex;
    PDwg_MLINESTYLE_line  = ^Dwg_MLINESTYLE_line;
    PDwg_Object  = ^Dwg_Object;
    PDwg_Object_ACMECOMMANDHISTORY  = ^Dwg_Object_ACMECOMMANDHISTORY;
    PDwg_Object_ACMESCOPE  = ^Dwg_Object_ACMESCOPE;
    PDwg_Object_ACMESTATEMGR  = ^Dwg_Object_ACMESTATEMGR;
    PDwg_Object_ACSH_BOOLEAN_CLASS  = ^Dwg_Object_ACSH_BOOLEAN_CLASS;
    PDwg_Object_ACSH_BOX_CLASS  = ^Dwg_Object_ACSH_BOX_CLASS;
    PDwg_Object_ACSH_BREP_CLASS  = ^Dwg_Object_ACSH_BREP_CLASS;
    PDwg_Object_ACSH_CHAMFER_CLASS  = ^Dwg_Object_ACSH_CHAMFER_CLASS;
    PDwg_Object_ACSH_CONE_CLASS  = ^Dwg_Object_ACSH_CONE_CLASS;
    PDwg_Object_ACSH_CYLINDER_CLASS  = ^Dwg_Object_ACSH_CYLINDER_CLASS;
    PDwg_Object_ACSH_EXTRUSION_CLASS  = ^Dwg_Object_ACSH_EXTRUSION_CLASS;
    PDwg_Object_ACSH_FILLET_CLASS  = ^Dwg_Object_ACSH_FILLET_CLASS;
    PDwg_Object_ACSH_HISTORY_CLASS  = ^Dwg_Object_ACSH_HISTORY_CLASS;
    PDwg_Object_ACSH_LOFT_CLASS  = ^Dwg_Object_ACSH_LOFT_CLASS;
    PDwg_Object_ACSH_PYRAMID_CLASS  = ^Dwg_Object_ACSH_PYRAMID_CLASS;
    PDwg_Object_ACSH_REVOLVE_CLASS  = ^Dwg_Object_ACSH_REVOLVE_CLASS;
    PDwg_Object_ACSH_SPHERE_CLASS  = ^Dwg_Object_ACSH_SPHERE_CLASS;
    PDwg_Object_ACSH_SWEEP_CLASS  = ^Dwg_Object_ACSH_SWEEP_CLASS;
    PDwg_Object_ACSH_TORUS_CLASS  = ^Dwg_Object_ACSH_TORUS_CLASS;
    PDwg_Object_ACSH_WEDGE_CLASS  = ^Dwg_Object_ACSH_WEDGE_CLASS;
    PDwg_Object_ALDIMOBJECTCONTEXTDATA  = ^Dwg_Object_ALDIMOBJECTCONTEXTDATA;
    PDwg_Object_ANGDIMOBJECTCONTEXTDATA  = ^Dwg_Object_ANGDIMOBJECTCONTEXTDATA;
    PDwg_Object_ANNOTSCALEOBJECTCONTEXTDATA  = ^Dwg_Object_ANNOTSCALEOBJECTCONTEXTDATA;
    PDwg_Object_APPID  = ^Dwg_Object_APPID;
    PDwg_Object_APPID_CONTROL  = ^Dwg_Object_APPID_CONTROL;
    PDwg_Object_ASSOC2DCONSTRAINTGROUP  = ^Dwg_Object_ASSOC2DCONSTRAINTGROUP;
    PDwg_Object_ASSOC3POINTANGULARDIMACTIONBODY  = ^Dwg_Object_ASSOC3POINTANGULARDIMACTIONBODY;
    PDwg_Object_ASSOCACTION  = ^Dwg_Object_ASSOCACTION;
    PDwg_Object_ASSOCACTIONPARAM  = ^Dwg_Object_ASSOCACTIONPARAM;
    PDwg_Object_ASSOCALIGNEDDIMACTIONBODY  = ^Dwg_Object_ASSOCALIGNEDDIMACTIONBODY;
    PDwg_Object_ASSOCARRAYACTIONBODY  = ^Dwg_Object_ASSOCARRAYACTIONBODY;
    PDwg_Object_ASSOCARRAYMODIFYACTIONBODY  = ^Dwg_Object_ASSOCARRAYMODIFYACTIONBODY;
    PDwg_Object_ASSOCARRAYMODIFYPARAMETERS  = ^Dwg_Object_ASSOCARRAYMODIFYPARAMETERS;
    PDwg_Object_ASSOCARRAYPARAMETERS  = ^Dwg_Object_ASSOCARRAYPARAMETERS;
    PDwg_Object_ASSOCARRAYPATHPARAMETERS  = ^Dwg_Object_ASSOCARRAYPATHPARAMETERS;
    PDwg_Object_ASSOCARRAYPOLARPARAMETERS  = ^Dwg_Object_ASSOCARRAYPOLARPARAMETERS;
    PDwg_Object_ASSOCARRAYRECTANGULARPARAMETERS  = ^Dwg_Object_ASSOCARRAYRECTANGULARPARAMETERS;
    PDwg_Object_ASSOCASMBODYACTIONPARAM  = ^Dwg_Object_ASSOCASMBODYACTIONPARAM;
    PDwg_Object_ASSOCBLENDSURFACEACTIONBODY  = ^Dwg_Object_ASSOCBLENDSURFACEACTIONBODY;
    PDwg_Object_ASSOCCOMPOUNDACTIONPARAM  = ^Dwg_Object_ASSOCCOMPOUNDACTIONPARAM;
    PDwg_Object_ASSOCDEPENDENCY  = ^Dwg_Object_ASSOCDEPENDENCY;
    PDwg_Object_ASSOCDIMDEPENDENCYBODY  = ^Dwg_Object_ASSOCDIMDEPENDENCYBODY;
    PDwg_Object_ASSOCEDGEACTIONPARAM  = ^Dwg_Object_ASSOCEDGEACTIONPARAM;
    PDwg_Object_ASSOCEDGECHAMFERACTIONBODY  = ^Dwg_Object_ASSOCEDGECHAMFERACTIONBODY;
    PDwg_Object_ASSOCEDGEFILLETACTIONBODY  = ^Dwg_Object_ASSOCEDGEFILLETACTIONBODY;
    PDwg_Object_ASSOCEXTENDSURFACEACTIONBODY  = ^Dwg_Object_ASSOCEXTENDSURFACEACTIONBODY;
    PDwg_Object_ASSOCEXTRUDEDSURFACEACTIONBODY  = ^Dwg_Object_ASSOCEXTRUDEDSURFACEACTIONBODY;
    PDwg_Object_ASSOCFACEACTIONPARAM  = ^Dwg_Object_ASSOCFACEACTIONPARAM;
    PDwg_Object_ASSOCFILLETSURFACEACTIONBODY  = ^Dwg_Object_ASSOCFILLETSURFACEACTIONBODY;
    PDwg_Object_ASSOCGEOMDEPENDENCY  = ^Dwg_Object_ASSOCGEOMDEPENDENCY;
    PDwg_Object_ASSOCLOFTEDSURFACEACTIONBODY  = ^Dwg_Object_ASSOCLOFTEDSURFACEACTIONBODY;
    PDwg_Object_ASSOCMLEADERACTIONBODY  = ^Dwg_Object_ASSOCMLEADERACTIONBODY;
    PDwg_Object_ASSOCNETWORK  = ^Dwg_Object_ASSOCNETWORK;
    PDwg_Object_ASSOCNETWORKSURFACEACTIONBODY  = ^Dwg_Object_ASSOCNETWORKSURFACEACTIONBODY;
    PDwg_Object_ASSOCOBJECTACTIONPARAM  = ^Dwg_Object_ASSOCOBJECTACTIONPARAM;
    PDwg_Object_ASSOCOFFSETSURFACEACTIONBODY  = ^Dwg_Object_ASSOCOFFSETSURFACEACTIONBODY;
    PDwg_Object_ASSOCORDINATEDIMACTIONBODY  = ^Dwg_Object_ASSOCORDINATEDIMACTIONBODY;
    PDwg_Object_ASSOCOSNAPPOINTREFACTIONPARAM  = ^Dwg_Object_ASSOCOSNAPPOINTREFACTIONPARAM;
    PDwg_Object_ASSOCPATCHSURFACEACTIONBODY  = ^Dwg_Object_ASSOCPATCHSURFACEACTIONBODY;
    PDwg_Object_ASSOCPATHACTIONPARAM  = ^Dwg_Object_ASSOCPATHACTIONPARAM;
    PDwg_Object_ASSOCPERSSUBENTMANAGER  = ^Dwg_Object_ASSOCPERSSUBENTMANAGER;
    PDwg_Object_ASSOCPLANESURFACEACTIONBODY  = ^Dwg_Object_ASSOCPLANESURFACEACTIONBODY;
    PDwg_Object_ASSOCPOINTREFACTIONPARAM  = ^Dwg_Object_ASSOCPOINTREFACTIONPARAM;
    PDwg_Object_ASSOCRESTOREENTITYSTATEACTIONBODY  = ^Dwg_Object_ASSOCRESTOREENTITYSTATEACTIONBODY;
    PDwg_Object_ASSOCREVOLVEDSURFACEACTIONBODY  = ^Dwg_Object_ASSOCREVOLVEDSURFACEACTIONBODY;
    PDwg_Object_ASSOCROTATEDDIMACTIONBODY  = ^Dwg_Object_ASSOCROTATEDDIMACTIONBODY;
    PDwg_Object_ASSOCSWEPTSURFACEACTIONBODY  = ^Dwg_Object_ASSOCSWEPTSURFACEACTIONBODY;
    PDwg_Object_ASSOCTRIMSURFACEACTIONBODY  = ^Dwg_Object_ASSOCTRIMSURFACEACTIONBODY;
    PDwg_Object_ASSOCVALUEDEPENDENCY  = ^Dwg_Object_ASSOCVALUEDEPENDENCY;
    PDwg_Object_ASSOCVARIABLE  = ^Dwg_Object_ASSOCVARIABLE;
    PDwg_Object_ASSOCVERTEXACTIONPARAM  = ^Dwg_Object_ASSOCVERTEXACTIONPARAM;
    PDwg_Object_BLKREFOBJECTCONTEXTDATA  = ^Dwg_Object_BLKREFOBJECTCONTEXTDATA;
    PDwg_Object_BLOCK_CONTROL  = ^Dwg_Object_BLOCK_CONTROL;
    PDwg_Object_BLOCK_HEADER  = ^Dwg_Object_BLOCK_HEADER;
    PDwg_Object_BLOCKALIGNEDCONSTRAINTPARAMETER  = ^Dwg_Object_BLOCKALIGNEDCONSTRAINTPARAMETER;
    PDwg_Object_BLOCKALIGNMENTGRIP  = ^Dwg_Object_BLOCKALIGNMENTGRIP;
    PDwg_Object_BLOCKALIGNMENTPARAMETER  = ^Dwg_Object_BLOCKALIGNMENTPARAMETER;
    PDwg_Object_BLOCKANGULARCONSTRAINTPARAMETER  = ^Dwg_Object_BLOCKANGULARCONSTRAINTPARAMETER;
    PDwg_Object_BLOCKARRAYACTION  = ^Dwg_Object_BLOCKARRAYACTION;
    PDwg_Object_BLOCKBASEPOINTPARAMETER  = ^Dwg_Object_BLOCKBASEPOINTPARAMETER;
    PDwg_Object_BLOCKDIAMETRICCONSTRAINTPARAMETER  = ^Dwg_Object_BLOCKDIAMETRICCONSTRAINTPARAMETER;
    PDwg_Object_BLOCKFLIPACTION  = ^Dwg_Object_BLOCKFLIPACTION;
    PDwg_Object_BLOCKFLIPGRIP  = ^Dwg_Object_BLOCKFLIPGRIP;
    PDwg_Object_BLOCKFLIPPARAMETER  = ^Dwg_Object_BLOCKFLIPPARAMETER;
    PDwg_Object_BLOCKGRIPLOCATIONCOMPONENT  = ^Dwg_Object_BLOCKGRIPLOCATIONCOMPONENT;
    PDwg_Object_BLOCKHORIZONTALCONSTRAINTPARAMETER  = ^Dwg_Object_BLOCKHORIZONTALCONSTRAINTPARAMETER;
    PDwg_Object_BLOCKLINEARCONSTRAINTPARAMETER  = ^Dwg_Object_BLOCKLINEARCONSTRAINTPARAMETER;
    PDwg_Object_BLOCKLINEARGRIP  = ^Dwg_Object_BLOCKLINEARGRIP;
    PDwg_Object_BLOCKLINEARPARAMETER  = ^Dwg_Object_BLOCKLINEARPARAMETER;
    PDwg_Object_BLOCKLOOKUPACTION  = ^Dwg_Object_BLOCKLOOKUPACTION;
    PDwg_Object_BLOCKLOOKUPGRIP  = ^Dwg_Object_BLOCKLOOKUPGRIP;
    PDwg_Object_BLOCKLOOKUPPARAMETER  = ^Dwg_Object_BLOCKLOOKUPPARAMETER;
    PDwg_Object_BLOCKMOVEACTION  = ^Dwg_Object_BLOCKMOVEACTION;
    PDwg_Object_BLOCKPARAMDEPENDENCYBODY  = ^Dwg_Object_BLOCKPARAMDEPENDENCYBODY;
    PDwg_Object_BLOCKPOINTPARAMETER  = ^Dwg_Object_BLOCKPOINTPARAMETER;
    PDwg_Object_BLOCKPOLARGRIP  = ^Dwg_Object_BLOCKPOLARGRIP;
    PDwg_Object_BLOCKPOLARPARAMETER  = ^Dwg_Object_BLOCKPOLARPARAMETER;
    PDwg_Object_BLOCKPOLARSTRETCHACTION  = ^Dwg_Object_BLOCKPOLARSTRETCHACTION;
    PDwg_Object_BLOCKPROPERTIESTABLE  = ^Dwg_Object_BLOCKPROPERTIESTABLE;
    PDwg_Object_BLOCKPROPERTIESTABLEGRIP  = ^Dwg_Object_BLOCKPROPERTIESTABLEGRIP;
    PDwg_Object_BLOCKRADIALCONSTRAINTPARAMETER  = ^Dwg_Object_BLOCKRADIALCONSTRAINTPARAMETER;
    PDwg_Object_BLOCKREPRESENTATION  = ^Dwg_Object_BLOCKREPRESENTATION;
    PDwg_Object_BLOCKROTATEACTION  = ^Dwg_Object_BLOCKROTATEACTION;
    PDwg_Object_BLOCKROTATIONGRIP  = ^Dwg_Object_BLOCKROTATIONGRIP;
    PDwg_Object_BLOCKROTATIONPARAMETER  = ^Dwg_Object_BLOCKROTATIONPARAMETER;
    PDwg_Object_BLOCKSCALEACTION  = ^Dwg_Object_BLOCKSCALEACTION;
    PDwg_Object_BLOCKSTRETCHACTION  = ^Dwg_Object_BLOCKSTRETCHACTION;
    PDwg_Object_BLOCKUSERPARAMETER  = ^Dwg_Object_BLOCKUSERPARAMETER;
    PDwg_Object_BLOCKVERTICALCONSTRAINTPARAMETER  = ^Dwg_Object_BLOCKVERTICALCONSTRAINTPARAMETER;
    PDwg_Object_BLOCKVISIBILITYGRIP  = ^Dwg_Object_BLOCKVISIBILITYGRIP;
    PDwg_Object_BLOCKVISIBILITYPARAMETER  = ^Dwg_Object_BLOCKVISIBILITYPARAMETER;
    PDwg_Object_BLOCKXYGRIP  = ^Dwg_Object_BLOCKXYGRIP;
    PDwg_Object_BLOCKXYPARAMETER  = ^Dwg_Object_BLOCKXYPARAMETER;
    PDwg_Object_BREAKDATA  = ^Dwg_Object_BREAKDATA;
    PDwg_Object_BREAKPOINTREF  = ^Dwg_Object_BREAKPOINTREF;
    PDwg_Object_CELLSTYLEMAP  = ^Dwg_Object_CELLSTYLEMAP;
    PDwg_Object_CONTEXTDATAMANAGER  = ^Dwg_Object_CONTEXTDATAMANAGER;
    PDwg_Object_CSACDOCUMENTOPTIONS  = ^Dwg_Object_CSACDOCUMENTOPTIONS;
    PDwg_Object_CURVEPATH  = ^Dwg_Object_CURVEPATH;
    PDwg_Object_DATALINK  = ^Dwg_Object_DATALINK;
    PDwg_Object_DATATABLE  = ^Dwg_Object_DATATABLE;
    PDwg_Object_DBCOLOR  = ^Dwg_Object_DBCOLOR;
    PDwg_Object_DETAILVIEWSTYLE  = ^Dwg_Object_DETAILVIEWSTYLE;
    PDwg_Object_DGNDEFINITION  = ^Dwg_Object_DGNDEFINITION;
    PDwg_Object_DICTIONARY  = ^Dwg_Object_DICTIONARY;
    PDwg_Object_DICTIONARYVAR  = ^Dwg_Object_DICTIONARYVAR;
    PDwg_Object_DICTIONARYWDFLT  = ^Dwg_Object_DICTIONARYWDFLT;
    PDwg_Object_DIMASSOC  = ^Dwg_Object_DIMASSOC;
    PDwg_Object_DIMSTYLE  = ^Dwg_Object_DIMSTYLE;
    PDwg_Object_DIMSTYLE_CONTROL  = ^Dwg_Object_DIMSTYLE_CONTROL;
    PDwg_Object_DMDIMOBJECTCONTEXTDATA  = ^Dwg_Object_DMDIMOBJECTCONTEXTDATA;
    PDwg_Object_DUMMY  = ^Dwg_Object_DUMMY;
    PDwg_Object_DWFDEFINITION  = ^Dwg_Object_DWFDEFINITION;
    PDwg_Object_DYNAMICBLOCKPROXYNODE  = ^Dwg_Object_DYNAMICBLOCKPROXYNODE;
    PDwg_Object_DYNAMICBLOCKPURGEPREVENTER  = ^Dwg_Object_DYNAMICBLOCKPURGEPREVENTER;
    PDwg_Object_Entity  = ^Dwg_Object_Entity;
    PDwg_Object_EVALUATION_GRAPH  = ^Dwg_Object_EVALUATION_GRAPH;
    PDwg_Object_FCFOBJECTCONTEXTDATA  = ^Dwg_Object_FCFOBJECTCONTEXTDATA;
    PDwg_Object_FIELD  = ^Dwg_Object_FIELD;
    PDwg_Object_FIELDLIST  = ^Dwg_Object_FIELDLIST;
    PDwg_Object_GEODATA  = ^Dwg_Object_GEODATA;
    PDwg_Object_GEOMAPIMAGE  = ^Dwg_Object_GEOMAPIMAGE;
    PDwg_Object_GRADIENT_BACKGROUND  = ^Dwg_Object_GRADIENT_BACKGROUND;
    PDwg_Object_GROUND_PLANE_BACKGROUND  = ^Dwg_Object_GROUND_PLANE_BACKGROUND;
    PDwg_Object_GROUP  = ^Dwg_Object_GROUP;
    PDwg_Object_IBL_BACKGROUND  = ^Dwg_Object_IBL_BACKGROUND;
    PDwg_Object_IDBUFFER  = ^Dwg_Object_IDBUFFER;
    PDwg_Object_IMAGE_BACKGROUND  = ^Dwg_Object_IMAGE_BACKGROUND;
    PDwg_Object_IMAGEDEF  = ^Dwg_Object_IMAGEDEF;
    PDwg_Object_IMAGEDEF_REACTOR  = ^Dwg_Object_IMAGEDEF_REACTOR;
    PDwg_Object_INDEX  = ^Dwg_Object_INDEX;
    PDwg_Object_LAYER  = ^Dwg_Object_LAYER;
    PDwg_Object_LAYER_CONTROL  = ^Dwg_Object_LAYER_CONTROL;
    PDwg_Object_LAYER_INDEX  = ^Dwg_Object_LAYER_INDEX;
    PDwg_Object_LAYERFILTER  = ^Dwg_Object_LAYERFILTER;
    PDwg_Object_LAYOUT  = ^Dwg_Object_LAYOUT;
    PDwg_Object_LAYOUTPRINTCONFIG  = ^Dwg_Object_LAYOUTPRINTCONFIG;
    PDwg_Object_LEADEROBJECTCONTEXTDATA  = ^Dwg_Object_LEADEROBJECTCONTEXTDATA;
    PDwg_Object_LIGHTLIST  = ^Dwg_Object_LIGHTLIST;
    PDwg_Object_LONG_TRANSACTION  = ^Dwg_Object_LONG_TRANSACTION;
    PDwg_Object_LTYPE  = ^Dwg_Object_LTYPE;
    PDwg_Object_LTYPE_CONTROL  = ^Dwg_Object_LTYPE_CONTROL;
    PDwg_Object_MATERIAL  = ^Dwg_Object_MATERIAL;
    PDwg_Object_MENTALRAYRENDERSETTINGS  = ^Dwg_Object_MENTALRAYRENDERSETTINGS;
    PDwg_Object_MLEADEROBJECTCONTEXTDATA  = ^Dwg_Object_MLEADEROBJECTCONTEXTDATA;
    PDwg_Object_MLEADERSTYLE  = ^Dwg_Object_MLEADERSTYLE;
    PDwg_Object_MLINESTYLE  = ^Dwg_Object_MLINESTYLE;
    PDwg_Object_MOTIONPATH  = ^Dwg_Object_MOTIONPATH;
    PDwg_Object_MTEXTATTRIBUTEOBJECTCONTEXTDATA  = ^Dwg_Object_MTEXTATTRIBUTEOBJECTCONTEXTDATA;
    PDwg_Object_MTEXTOBJECTCONTEXTDATA  = ^Dwg_Object_MTEXTOBJECTCONTEXTDATA;
    PDwg_Object_NAVISWORKSMODELDEF  = ^Dwg_Object_NAVISWORKSMODELDEF;
    PDwg_Object_Object  = ^Dwg_Object_Object;
    PDwg_Object_OBJECT_PTR  = ^Dwg_Object_OBJECT_PTR;
    PDwg_Object_ORDDIMOBJECTCONTEXTDATA  = ^Dwg_Object_ORDDIMOBJECTCONTEXTDATA;
    PDwg_Object_PARTIAL_VIEWING_INDEX  = ^Dwg_Object_PARTIAL_VIEWING_INDEX;
    PDwg_Object_PDFDEFINITION  = ^Dwg_Object_PDFDEFINITION;
    PDwg_Object_PERSUBENTMGR  = ^Dwg_Object_PERSUBENTMGR;
    PDwg_Object_PLACEHOLDER  = ^Dwg_Object_PLACEHOLDER;
    PDwg_Object_PLOTSETTINGS  = ^Dwg_Object_PLOTSETTINGS;
    PDwg_Object_POINTCLOUDCOLORMAP  = ^Dwg_Object_POINTCLOUDCOLORMAP;
    PDwg_Object_POINTCLOUDDEF  = ^Dwg_Object_POINTCLOUDDEF;
    PDwg_Object_POINTCLOUDDEF_REACTOR  = ^Dwg_Object_POINTCLOUDDEF_REACTOR;
    PDwg_Object_POINTCLOUDDEF_REACTOR_EX  = ^Dwg_Object_POINTCLOUDDEF_REACTOR_EX;
    PDwg_Object_POINTCLOUDDEFEX  = ^Dwg_Object_POINTCLOUDDEFEX;
    PDwg_Object_POINTPATH  = ^Dwg_Object_POINTPATH;
    PDwg_Object_PROXY_OBJECT  = ^Dwg_Object_PROXY_OBJECT;
    PDwg_Object_RADIMLGOBJECTCONTEXTDATA  = ^Dwg_Object_RADIMLGOBJECTCONTEXTDATA;
    PDwg_Object_RADIMOBJECTCONTEXTDATA  = ^Dwg_Object_RADIMOBJECTCONTEXTDATA;
    PDwg_Object_RAPIDRTRENDERSETTINGS  = ^Dwg_Object_RAPIDRTRENDERSETTINGS;
    PDwg_Object_RASTERVARIABLES  = ^Dwg_Object_RASTERVARIABLES;
    PDwg_Object_Ref  = ^Dwg_Object_Ref;
    PDwg_Object_RENDERENTRY  = ^Dwg_Object_RENDERENTRY;
    PDwg_Object_RENDERENVIRONMENT  = ^Dwg_Object_RENDERENVIRONMENT;
    PDwg_Object_RENDERGLOBAL  = ^Dwg_Object_RENDERGLOBAL;
    PDwg_Object_RENDERSETTINGS  = ^Dwg_Object_RENDERSETTINGS;
    PDwg_Object_SCALE  = ^Dwg_Object_SCALE;
    PDwg_Object_SECTION_MANAGER  = ^Dwg_Object_SECTION_MANAGER;
    PDwg_Object_SECTION_SETTINGS  = ^Dwg_Object_SECTION_SETTINGS;
    PDwg_Object_SECTIONVIEWSTYLE  = ^Dwg_Object_SECTIONVIEWSTYLE;
    PDwg_Object_SKYLIGHT_BACKGROUND  = ^Dwg_Object_SKYLIGHT_BACKGROUND;
    PDwg_Object_SOLID_BACKGROUND  = ^Dwg_Object_SOLID_BACKGROUND;
    PDwg_Object_SORTENTSTABLE  = ^Dwg_Object_SORTENTSTABLE;
    PDwg_Object_SPATIAL_FILTER  = ^Dwg_Object_SPATIAL_FILTER;
    PDwg_Object_SPATIAL_INDEX  = ^Dwg_Object_SPATIAL_INDEX;
    PDwg_Object_STYLE  = ^Dwg_Object_STYLE;
    PDwg_Object_STYLE_CONTROL  = ^Dwg_Object_STYLE_CONTROL;
    PDwg_Object_SUN  = ^Dwg_Object_SUN;
    PDwg_Object_SUNSTUDY  = ^Dwg_Object_SUNSTUDY;
    PDWG_OBJECT_SUPERTYPE  = ^DWG_OBJECT_SUPERTYPE;
    PDwg_Object_TABLECONTENT  = ^Dwg_Object_TABLECONTENT;
    PDwg_Object_TABLEGEOMETRY  = ^Dwg_Object_TABLEGEOMETRY;
    PDwg_Object_TABLESTYLE  = ^Dwg_Object_TABLESTYLE;
    PDwg_Object_TEXTOBJECTCONTEXTDATA  = ^Dwg_Object_TEXTOBJECTCONTEXTDATA;
    PDwg_Object_TVDEVICEPROPERTIES  = ^Dwg_Object_TVDEVICEPROPERTIES;
    PDWG_OBJECT_TYPE  = ^DWG_OBJECT_TYPE;
    PDWG_OBJECT_TYPE_R11  = ^DWG_OBJECT_TYPE_R11;
    PDwg_Object_UCS  = ^Dwg_Object_UCS;
    PDwg_Object_UCS_CONTROL  = ^Dwg_Object_UCS_CONTROL;
    PDwg_Object_UNDERLAYDEFINITION  = ^Dwg_Object_UNDERLAYDEFINITION;
    PDwg_Object_UNKNOWN_OBJ  = ^Dwg_Object_UNKNOWN_OBJ;
    PDwg_Object_VBA_PROJECT  = ^Dwg_Object_VBA_PROJECT;
    PDwg_Object_VIEW  = ^Dwg_Object_VIEW;
    PDwg_Object_VIEW_CONTROL  = ^Dwg_Object_VIEW_CONTROL;
    PDwg_Object_VISUALSTYLE  = ^Dwg_Object_VISUALSTYLE;
    PDwg_Object_VPORT  = ^Dwg_Object_VPORT;
    PDwg_Object_VPORT_CONTROL  = ^Dwg_Object_VPORT_CONTROL;
    PDwg_Object_VX_CONTROL  = ^Dwg_Object_VX_CONTROL;
    PDwg_Object_VX_TABLE_RECORD  = ^Dwg_Object_VX_TABLE_RECORD;
    PDwg_Object_WIPEOUTVARIABLES  = ^Dwg_Object_WIPEOUTVARIABLES;
    PDwg_Object_XRECORD  = ^Dwg_Object_XRECORD;
    PDwg_ObjFreeSpace  = ^Dwg_ObjFreeSpace;
    PDwg_OCD_Dimension  = ^Dwg_OCD_Dimension;
    PDwg_PARTIAL_VIEWING_INDEX_Entry  = ^Dwg_PARTIAL_VIEWING_INDEX_Entry;
    PDwg_POINTCLOUD_Clippings  = ^Dwg_POINTCLOUD_Clippings;
    PDwg_POINTCLOUD_IntensityStyle  = ^Dwg_POINTCLOUD_IntensityStyle;
    PDwg_POINTCLOUDCOLORMAP_Ramp  = ^Dwg_POINTCLOUDCOLORMAP_Ramp;
    PDwg_POINTCLOUDEX_Croppings  = ^Dwg_POINTCLOUDEX_Croppings;
    PDwg_PROXY_LWPOLYLINE  = ^Dwg_PROXY_LWPOLYLINE;
    PDwg_R2004_Header  = ^Dwg_R2004_Header;
    PDwg_Resbuf  = ^Dwg_Resbuf;
    PDwg_Resbuf_Value_Type  = ^Dwg_Resbuf_Value_Type;
    PDwg_RevHistory  = ^Dwg_RevHistory;
    PDwg_RGB_Palette  = ^Dwg_RGB_Palette;
    PDwg_Second_Header  = ^Dwg_Second_Header;
    PDwg_Section  = ^Dwg_Section;
    PDwg_SECTION_geometrysettings  = ^Dwg_SECTION_geometrysettings;
    PDwg_Section_Info  = ^Dwg_Section_Info;
    PDwg_Section_InfoHdr  = ^Dwg_Section_InfoHdr;
    PDWG_SECTION_TYPE  = ^DWG_SECTION_TYPE;
    PDWG_SECTION_TYPE_R11  = ^DWG_SECTION_TYPE_R11;
    PDWG_SECTION_TYPE_R13  = ^DWG_SECTION_TYPE_R13;
    PDwg_SECTION_typesettings  = ^Dwg_SECTION_typesettings;
    PDwg_Security  = ^Dwg_Security;
    PDwg_SPLINE_control_point  = ^Dwg_SPLINE_control_point;
    PDwg_SummaryInfo  = ^Dwg_SummaryInfo;
    PDwg_SummaryInfo_Property  = ^Dwg_SummaryInfo_Property;
    PDwg_SUNSTUDY_Dates  = ^Dwg_SUNSTUDY_Dates;
    PDwg_TABLE_AttrDef  = ^Dwg_TABLE_AttrDef;
    PDwg_TABLE_BreakHeight  = ^Dwg_TABLE_BreakHeight;
    PDwg_TABLE_BreakRow  = ^Dwg_TABLE_BreakRow;
    PDwg_TABLE_Cell  = ^Dwg_TABLE_Cell;
    PDwg_TABLE_CustomDataItem  = ^Dwg_TABLE_CustomDataItem;
    PDwg_TABLE_value  = ^Dwg_TABLE_value;
    PDwg_TableCell  = ^Dwg_TableCell;
    PDwg_TableCellContent  = ^Dwg_TableCellContent;
    PDwg_TableCellContent_Attr  = ^Dwg_TableCellContent_Attr;
    PDwg_TableDataColumn  = ^Dwg_TableDataColumn;
    PDwg_TABLEGEOMETRY_Cell  = ^Dwg_TABLEGEOMETRY_Cell;
    PDwg_TableRow  = ^Dwg_TableRow;
    PDwg_TABLESTYLE_border  = ^Dwg_TABLESTYLE_border;
    PDwg_TABLESTYLE_CellStyle  = ^Dwg_TABLESTYLE_CellStyle;
    PDwg_TABLESTYLE_rowstyles  = ^Dwg_TABLESTYLE_rowstyles;
    PDwg_Template  = ^Dwg_Template;
    PDwg_UCS_orthopts  = ^Dwg_UCS_orthopts;
    PDwg_VALUEPARAM  = ^Dwg_VALUEPARAM;
    PDwg_VALUEPARAM_vars  = ^Dwg_VALUEPARAM_vars;
    PDwg_VBAProject  = ^Dwg_VBAProject;
    PDWG_VERSION_TYPE  = ^DWG_VERSION_TYPE;
    Pdwg_versions  = ^dwg_versions;
    Pdwg_wchar_t  = ^dwg_wchar_t;
    PRESBUF_VALUE_TYPE  = ^RESBUF_VALUE_TYPE;
    Prgbpalette  = ^rgbpalette;
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


(* error 
extern "C" {
in declaration at line 16 *)

      BITCODE_RC = byte;

      //PBITCODE_RCd = ^BITCODE_RCd;
      BITCODE_RCd = char;

      //PBITCODE_RCu = ^BITCODE_RCu;
      BITCODE_RCu = byte;

      //PBITCODE_RCx = ^BITCODE_RCx;
      BITCODE_RCx = byte;

      //PBITCODE_B = ^BITCODE_B;
      BITCODE_B = byte;

      //PBITCODE_BB = ^BITCODE_BB;
      BITCODE_BB = byte;

      //PBITCODE_3B = ^BITCODE_3B;
      BITCODE_3B = byte;

      //PBITCODE_BS = ^BITCODE_BS;
      BITCODE_BS = uint16;

      //PBITCODE_BSd = ^BITCODE_BSd;
      BITCODE_BSd = int16;

      //PBITCODE_BSx = ^BITCODE_BSx;
      BITCODE_BSx = uint16;

      //PBITCODE_RS = ^BITCODE_RS;
      BITCODE_RS = uint16;

      //PBITCODE_RSd = ^BITCODE_RSd;
      BITCODE_RSd = int16;

      //PBITCODE_RSx = ^BITCODE_RSx;
      BITCODE_RSx = uint16;

      //PBITCODE_BL = ^BITCODE_BL;
      BITCODE_BL = uint32;

      //PBITCODE_BLx = ^BITCODE_BLx;
      BITCODE_BLx = uint32;

      //PBITCODE_BLd = ^BITCODE_BLd;
      BITCODE_BLd = int32;

      //PBITCODE_RL = ^BITCODE_RL;
      BITCODE_RL = uint32;

      //PBITCODE_RLx = ^BITCODE_RLx;
      BITCODE_RLx = uint32;

      //PBITCODE_RLd = ^BITCODE_RLd;
      BITCODE_RLd = int32;

      //PBITCODE_MC = ^BITCODE_MC;
      BITCODE_MC = int32;

      //PBITCODE_UMC = ^BITCODE_UMC;
      BITCODE_UMC = uint64;

      //PBITCODE_RLLd = ^BITCODE_RLLd;
      BITCODE_RLLd = int64;

      //PBITCODE_MS = ^BITCODE_MS;
      BITCODE_MS = BITCODE_BL;

      //PBITCODE_RD = ^BITCODE_RD;
      BITCODE_RD = double;

      //PBITCODE_RLL = ^BITCODE_RLL;
      BITCODE_RLL = uint64;

      //PBITCODE_BLL = ^BITCODE_BLL;
      BITCODE_BLL = uint64;

      //Pdwg_wchar_t = ^dwg_wchar_t;
      dwg_wchar_t = BITCODE_RS;

      //PBITCODE_TF = ^BITCODE_TF;
      BITCODE_TF = Pbyte;

      //PBITCODE_TV = ^BITCODE_TV;
      BITCODE_TV = Pchar;
      BITCODE_T = BITCODE_TV;

      //PBITCODE_BT = ^BITCODE_BT;
      BITCODE_BT = double;

      //PBITCODE_DD = ^BITCODE_DD;
      BITCODE_DD = double;

      //PBITCODE_BD = ^BITCODE_BD;
      BITCODE_BD = double;

      //PBITCODE_4BITS = ^BITCODE_4BITS;
      BITCODE_4BITS = BITCODE_RC;

      //PBITCODE_D2T = ^BITCODE_D2T;
      BITCODE_D2T = BITCODE_TV;

      //PBITCODE_TU = ^BITCODE_TU;
      BITCODE_TU = PBITCODE_RS;

      //P_dwg_time_bll = ^_dwg_time_bll;
      _dwg_time_bll = record
          days : BITCODE_BL;
          ms : BITCODE_BL;
          value : BITCODE_BD;
        end;
      Dwg_Bitcode_TimeBLL = _dwg_time_bll;
      //PDwg_Bitcode_TimeBLL = ^Dwg_Bitcode_TimeBLL;

      //P_dwg_bitcode_2rd = ^_dwg_bitcode_2rd;
      _dwg_bitcode_2rd = record
          x : BITCODE_RD;
          y : BITCODE_RD;
        end;
      Dwg_Bitcode_2RD = _dwg_bitcode_2rd;
      //PDwg_Bitcode_2RD = ^Dwg_Bitcode_2RD;

      //P_dwg_bitcode_2bd = ^_dwg_bitcode_2bd;
      _dwg_bitcode_2bd = record
          x : BITCODE_BD;
          y : BITCODE_BD;
        end;
      Dwg_Bitcode_2BD = _dwg_bitcode_2bd;
      //PDwg_Bitcode_2BD = ^Dwg_Bitcode_2BD;

      //P_dwg_bitcode_3rd = ^_dwg_bitcode_3rd;
      _dwg_bitcode_3rd = record
          x : BITCODE_RD;
          y : BITCODE_RD;
          z : BITCODE_RD;
        end;
      Dwg_Bitcode_3RD = _dwg_bitcode_3rd;
      //PDwg_Bitcode_3RD = ^Dwg_Bitcode_3RD;

      //P_dwg_bitcode_3bd = ^_dwg_bitcode_3bd;
      _dwg_bitcode_3bd = record
          x : BITCODE_BD;
          y : BITCODE_BD;
          z : BITCODE_BD;
        end;
      Dwg_Bitcode_3BD = _dwg_bitcode_3bd;
      //PDwg_Bitcode_3BD = ^Dwg_Bitcode_3BD;

      //PBITCODE_TIMEBLL = ^BITCODE_TIMEBLL;
      BITCODE_TIMEBLL = Dwg_Bitcode_TimeBLL;

      //PBITCODE_TIMERLL = ^BITCODE_TIMERLL;
      BITCODE_TIMERLL = Dwg_Bitcode_TimeBLL;

      //PBITCODE_2RD = ^BITCODE_2RD;
      BITCODE_2RD = Dwg_Bitcode_2RD;

      //PBITCODE_2BD = ^BITCODE_2BD;
      BITCODE_2BD = Dwg_Bitcode_2BD;

      //PBITCODE_2DPOINT = ^BITCODE_2DPOINT;
      BITCODE_2DPOINT = Dwg_Bitcode_2BD;

      //PBITCODE_2BD_1 = ^BITCODE_2BD_1;
      BITCODE_2BD_1 = Dwg_Bitcode_2BD;

      //PBITCODE_3RD = ^BITCODE_3RD;
      BITCODE_3RD = Dwg_Bitcode_3RD;

      //PBITCODE_3BD = ^BITCODE_3BD;
      BITCODE_3BD = Dwg_Bitcode_3BD;

      //PBITCODE_3DPOINT = ^BITCODE_3DPOINT;
      BITCODE_3DPOINT = Dwg_Bitcode_3BD;

      //PBITCODE_3BD_1 = ^BITCODE_3BD_1;
      BITCODE_3BD_1 = Dwg_Bitcode_3BD;

      //PBITCODE_BE = ^BITCODE_BE;
      BITCODE_BE = Dwg_Bitcode_3BD;

      //PDWG_VERSION_TYPE = ^DWG_VERSION_TYPE;
      DWG_VERSION_TYPE = (R_INVALID,R_1_1,R_1_2,R_1_3,R_1_4,R_2_0b,
        R_2_0,R_2_10,R_2_21,R_2_22,R_2_4,R_2_5,
        R_2_6,R_9,R_9c1,R_10,R_11b1,R_11b2,R_11,
        R_12,R_13b1,R_13b2,R_13,R_13c3,R_14,
        R_2000b,R_2000,R_2000i,R_2002,R_2004a,
        R_2004b,R_2004c,R_2004,R_2005,R_2006,R_2007b,
        R_2007,R_2008,R_2009,R_2010b,R_2010,R_2011,
        R_2012,R_2013b,R_2013,R_2014,R_2015,R_2016,
        R_2017,R_2018b,R_2018,R_2019,R_2020,R_2021,
        R_2022,R_AFTER);
(* Const before type ignored *)
(* Const before declarator ignored *)
(* Const before type ignored *)
(* Const before declarator ignored *)
(* Const before type ignored *)
(* Const before declarator ignored *)

      //Pdwg_versions = ^dwg_versions;
      dwg_versions = record
          r : Dwg_Version_Type;
          _type : Pchar;
          hdr : Pchar;
          desc : Pchar;
          dwg_version : uint8;
        end;

      //PDWG_CLASS_STABILITY = ^DWG_CLASS_STABILITY;
      DWG_CLASS_STABILITY = (DWG_CLASS_STABLE,DWG_CLASS_UNSTABLE,
        DWG_CLASS_DEBUGGING,DWG_CLASS_UNHANDLED
        );

      //PDWG_OBJECT_SUPERTYPE = ^DWG_OBJECT_SUPERTYPE;
      DWG_OBJECT_SUPERTYPE = (DWG_SUPERTYPE_ENTITY,DWG_SUPERTYPE_OBJECT
        );
	  
      //PDWG_OBJECT_TYPE = ^DWG_OBJECT_TYPE;
      DWG_OBJECT_TYPE = (DWG_TYPE_UNUSED = $00,DWG_TYPE_TEXT = $01,
        DWG_TYPE_ATTRIB = $02,DWG_TYPE_ATTDEF = $03,
        DWG_TYPE_BLOCK = $04,DWG_TYPE_ENDBLK = $05,
        DWG_TYPE_SEQEND = $06,DWG_TYPE_INSERT = $07,
        DWG_TYPE_MINSERT = $08,DWG_TYPE_VERTEX_2D = $0a,
        DWG_TYPE_VERTEX_3D = $0b,DWG_TYPE_VERTEX_MESH = $0c,
        DWG_TYPE_VERTEX_PFACE = $0d,DWG_TYPE_VERTEX_PFACE_FACE = $0e,
        DWG_TYPE_POLYLINE_2D = $0f,DWG_TYPE_POLYLINE_3D = $10,
        DWG_TYPE_ARC = $11,DWG_TYPE_CIRCLE = $12,
        DWG_TYPE_LINE = $13,DWG_TYPE_DIMENSION_ORDINATE = $14,
        DWG_TYPE_DIMENSION_LINEAR = $15,DWG_TYPE_DIMENSION_ALIGNED = $16,
        DWG_TYPE_DIMENSION_ANG3PT = $17,DWG_TYPE_DIMENSION_ANG2LN = $18,
        DWG_TYPE_DIMENSION_RADIUS = $19,DWG_TYPE_DIMENSION_DIAMETER = $1A,
        DWG_TYPE_POINT = $1b,DWG_TYPE__3DFACE = $1c,
        DWG_TYPE_POLYLINE_PFACE = $1d,DWG_TYPE_POLYLINE_MESH = $1e,
        DWG_TYPE_SOLID = $1f,DWG_TYPE_TRACE = $20,
        DWG_TYPE_SHAPE = $21,DWG_TYPE_VIEWPORT = $22,
        DWG_TYPE_ELLIPSE = $23,DWG_TYPE_SPLINE = $24,
        DWG_TYPE_REGION = $25,DWG_TYPE__3DSOLID = $26,
        DWG_TYPE_BODY = $27,DWG_TYPE_RAY = $28,
        DWG_TYPE_XLINE = $29,DWG_TYPE_DICTIONARY = $2a,
        DWG_TYPE_OLEFRAME = $2b,DWG_TYPE_MTEXT = $2c,
        DWG_TYPE_LEADER = $2d,DWG_TYPE_TOLERANCE = $2e,
        DWG_TYPE_MLINE = $2f,DWG_TYPE_BLOCK_CONTROL = $30,
        DWG_TYPE_BLOCK_HEADER = $31,DWG_TYPE_LAYER_CONTROL = $32,
        DWG_TYPE_LAYER = $33,DWG_TYPE_STYLE_CONTROL = $34,
        DWG_TYPE_STYLE = $35,DWG_TYPE_LTYPE_CONTROL = $38,
        DWG_TYPE_LTYPE = $39,DWG_TYPE_VIEW_CONTROL = $3c,
        DWG_TYPE_VIEW = $3d,DWG_TYPE_UCS_CONTROL = $3e,
        DWG_TYPE_UCS = $3f,DWG_TYPE_VPORT_CONTROL = $40,
        DWG_TYPE_VPORT = $41,DWG_TYPE_APPID_CONTROL = $42,
        DWG_TYPE_APPID = $43,DWG_TYPE_DIMSTYLE_CONTROL = $44,
        DWG_TYPE_DIMSTYLE = $45,DWG_TYPE_VX_CONTROL = $46,
        DWG_TYPE_VX_TABLE_RECORD = $47,DWG_TYPE_GROUP = $48,
        DWG_TYPE_MLINESTYLE = $49,DWG_TYPE_OLE2FRAME = $4a,
        DWG_TYPE_DUMMY = $4b,DWG_TYPE_LONG_TRANSACTION = $4c,
        DWG_TYPE_LWPOLYLINE = $4d,DWG_TYPE_HATCH = $4e,
        DWG_TYPE_XRECORD = $4f,DWG_TYPE_PLACEHOLDER = $50,
        DWG_TYPE_VBA_PROJECT = $51,DWG_TYPE_LAYOUT = $52,
        DWG_TYPE_PROXY_ENTITY = $1f2,DWG_TYPE_PROXY_OBJECT = $1f3,
        DWG_TYPE_ACDSRECORD = 500,DWG_TYPE_ACDSSCHEMA,
        DWG_TYPE_ACMECOMMANDHISTORY,DWG_TYPE_ACMESCOPE,
        DWG_TYPE_ACMESTATEMGR,DWG_TYPE_ACSH_BOOLEAN_CLASS,
        DWG_TYPE_ACSH_BOX_CLASS,DWG_TYPE_ACSH_BREP_CLASS,
        DWG_TYPE_ACSH_CHAMFER_CLASS,DWG_TYPE_ACSH_CONE_CLASS,
        DWG_TYPE_ACSH_CYLINDER_CLASS,DWG_TYPE_ACSH_EXTRUSION_CLASS,
        DWG_TYPE_ACSH_FILLET_CLASS,DWG_TYPE_ACSH_HISTORY_CLASS,
        DWG_TYPE_ACSH_LOFT_CLASS,DWG_TYPE_ACSH_PYRAMID_CLASS,
        DWG_TYPE_ACSH_REVOLVE_CLASS,DWG_TYPE_ACSH_SPHERE_CLASS,
        DWG_TYPE_ACSH_SWEEP_CLASS,DWG_TYPE_ACSH_TORUS_CLASS,
        DWG_TYPE_ACSH_WEDGE_CLASS,DWG_TYPE_ALDIMOBJECTCONTEXTDATA,
        DWG_TYPE_ALIGNMENTPARAMETERENTITY,
        DWG_TYPE_ANGDIMOBJECTCONTEXTDATA,DWG_TYPE_ANNOTSCALEOBJECTCONTEXTDATA,
        DWG_TYPE_ARCALIGNEDTEXT,DWG_TYPE_ARC_DIMENSION,
        DWG_TYPE_ASSOC2DCONSTRAINTGROUP,DWG_TYPE_ASSOC3POINTANGULARDIMACTIONBODY,
        DWG_TYPE_ASSOCACTION,DWG_TYPE_ASSOCACTIONPARAM,
        DWG_TYPE_ASSOCALIGNEDDIMACTIONBODY,
        DWG_TYPE_ASSOCARRAYACTIONBODY,DWG_TYPE_ASSOCARRAYMODIFYACTIONBODY,
        DWG_TYPE_ASSOCARRAYMODIFYPARAMETERS,
        DWG_TYPE_ASSOCARRAYPATHPARAMETERS,
        DWG_TYPE_ASSOCARRAYPOLARPARAMETERS,
        DWG_TYPE_ASSOCARRAYRECTANGULARPARAMETERS,
        DWG_TYPE_ASSOCASMBODYACTIONPARAM,DWG_TYPE_ASSOCBLENDSURFACEACTIONBODY,
        DWG_TYPE_ASSOCCOMPOUNDACTIONPARAM,
        DWG_TYPE_ASSOCDEPENDENCY,DWG_TYPE_ASSOCDIMDEPENDENCYBODY,
        DWG_TYPE_ASSOCEDGEACTIONPARAM,DWG_TYPE_ASSOCEDGECHAMFERACTIONBODY,
        DWG_TYPE_ASSOCEDGEFILLETACTIONBODY,
        DWG_TYPE_ASSOCEXTENDSURFACEACTIONBODY,
        DWG_TYPE_ASSOCEXTRUDEDSURFACEACTIONBODY,
        DWG_TYPE_ASSOCFACEACTIONPARAM,DWG_TYPE_ASSOCFILLETSURFACEACTIONBODY,
        DWG_TYPE_ASSOCGEOMDEPENDENCY,DWG_TYPE_ASSOCLOFTEDSURFACEACTIONBODY,
        DWG_TYPE_ASSOCMLEADERACTIONBODY,DWG_TYPE_ASSOCNETWORK,
        DWG_TYPE_ASSOCNETWORKSURFACEACTIONBODY,
        DWG_TYPE_ASSOCOBJECTACTIONPARAM,DWG_TYPE_ASSOCOFFSETSURFACEACTIONBODY,
        DWG_TYPE_ASSOCORDINATEDIMACTIONBODY,
        DWG_TYPE_ASSOCOSNAPPOINTREFACTIONPARAM,
        DWG_TYPE_ASSOCPATCHSURFACEACTIONBODY,
        DWG_TYPE_ASSOCPATHACTIONPARAM,DWG_TYPE_ASSOCPERSSUBENTMANAGER,
        DWG_TYPE_ASSOCPLANESURFACEACTIONBODY,
        DWG_TYPE_ASSOCPOINTREFACTIONPARAM,
        DWG_TYPE_ASSOCRESTOREENTITYSTATEACTIONBODY,
        DWG_TYPE_ASSOCREVOLVEDSURFACEACTIONBODY,
        DWG_TYPE_ASSOCROTATEDDIMACTIONBODY,
        DWG_TYPE_ASSOCSWEPTSURFACEACTIONBODY,
        DWG_TYPE_ASSOCTRIMSURFACEACTIONBODY,
        DWG_TYPE_ASSOCVALUEDEPENDENCY,DWG_TYPE_ASSOCVARIABLE,
        DWG_TYPE_ASSOCVERTEXACTIONPARAM,DWG_TYPE_BASEPOINTPARAMETERENTITY,
        DWG_TYPE_BLKREFOBJECTCONTEXTDATA,DWG_TYPE_BLOCKALIGNEDCONSTRAINTPARAMETER,
        DWG_TYPE_BLOCKALIGNMENTGRIP,DWG_TYPE_BLOCKALIGNMENTPARAMETER,
        DWG_TYPE_BLOCKANGULARCONSTRAINTPARAMETER,
        DWG_TYPE_BLOCKARRAYACTION,DWG_TYPE_BLOCKBASEPOINTPARAMETER,
        DWG_TYPE_BLOCKDIAMETRICCONSTRAINTPARAMETER,
        DWG_TYPE_BLOCKFLIPACTION,DWG_TYPE_BLOCKFLIPGRIP,
        DWG_TYPE_BLOCKFLIPPARAMETER,DWG_TYPE_BLOCKGRIPLOCATIONCOMPONENT,
        DWG_TYPE_BLOCKHORIZONTALCONSTRAINTPARAMETER,
        DWG_TYPE_BLOCKLINEARCONSTRAINTPARAMETER,
        DWG_TYPE_BLOCKLINEARGRIP,DWG_TYPE_BLOCKLINEARPARAMETER,
        DWG_TYPE_BLOCKLOOKUPACTION,DWG_TYPE_BLOCKLOOKUPGRIP,
        DWG_TYPE_BLOCKLOOKUPPARAMETER,DWG_TYPE_BLOCKMOVEACTION,
        DWG_TYPE_BLOCKPARAMDEPENDENCYBODY,
        DWG_TYPE_BLOCKPOINTPARAMETER,DWG_TYPE_BLOCKPOLARGRIP,
        DWG_TYPE_BLOCKPOLARPARAMETER,DWG_TYPE_BLOCKPOLARSTRETCHACTION,
        DWG_TYPE_BLOCKPROPERTIESTABLE,DWG_TYPE_BLOCKPROPERTIESTABLEGRIP,
        DWG_TYPE_BLOCKRADIALCONSTRAINTPARAMETER,
        DWG_TYPE_BLOCKREPRESENTATION,DWG_TYPE_BLOCKROTATEACTION,
        DWG_TYPE_BLOCKROTATIONGRIP,DWG_TYPE_BLOCKROTATIONPARAMETER,
        DWG_TYPE_BLOCKSCALEACTION,DWG_TYPE_BLOCKSTRETCHACTION,
        DWG_TYPE_BLOCKUSERPARAMETER,DWG_TYPE_BLOCKVERTICALCONSTRAINTPARAMETER,
        DWG_TYPE_BLOCKVISIBILITYGRIP,DWG_TYPE_BLOCKVISIBILITYPARAMETER,
        DWG_TYPE_BLOCKXYGRIP,DWG_TYPE_BLOCKXYPARAMETER,
        DWG_TYPE_CAMERA,DWG_TYPE_CELLSTYLEMAP,
        DWG_TYPE_CONTEXTDATAMANAGER,DWG_TYPE_CSACDOCUMENTOPTIONS,
        DWG_TYPE_CURVEPATH,DWG_TYPE_DATALINK,
        DWG_TYPE_DATATABLE,DWG_TYPE_DBCOLOR,
        DWG_TYPE_DETAILVIEWSTYLE,DWG_TYPE_DGNDEFINITION,
        DWG_TYPE_DGNUNDERLAY,DWG_TYPE_DICTIONARYVAR,
        DWG_TYPE_DICTIONARYWDFLT,DWG_TYPE_DIMASSOC,
        DWG_TYPE_DMDIMOBJECTCONTEXTDATA,DWG_TYPE_DWFDEFINITION,
        DWG_TYPE_DWFUNDERLAY,DWG_TYPE_DYNAMICBLOCKPROXYNODE,
        DWG_TYPE_DYNAMICBLOCKPURGEPREVENTER,
        DWG_TYPE_EVALUATION_GRAPH,DWG_TYPE_EXTRUDEDSURFACE,
        DWG_TYPE_FCFOBJECTCONTEXTDATA,DWG_TYPE_FIELD,
        DWG_TYPE_FIELDLIST,DWG_TYPE_FLIPPARAMETERENTITY,
        DWG_TYPE_GEODATA,DWG_TYPE_GEOMAPIMAGE,
        DWG_TYPE_GEOPOSITIONMARKER,DWG_TYPE_GRADIENT_BACKGROUND,
        DWG_TYPE_GROUND_PLANE_BACKGROUND,DWG_TYPE_HELIX,
        DWG_TYPE_IBL_BACKGROUND,DWG_TYPE_IDBUFFER,
        DWG_TYPE_IMAGE,DWG_TYPE_IMAGEDEF,DWG_TYPE_IMAGEDEF_REACTOR,
        DWG_TYPE_IMAGE_BACKGROUND,DWG_TYPE_INDEX,
        DWG_TYPE_LARGE_RADIAL_DIMENSION,DWG_TYPE_LAYERFILTER,
        DWG_TYPE_LAYER_INDEX,DWG_TYPE_LAYOUTPRINTCONFIG,
        DWG_TYPE_LEADEROBJECTCONTEXTDATA,DWG_TYPE_LIGHT,
        DWG_TYPE_LIGHTLIST,DWG_TYPE_LINEARPARAMETERENTITY,
        DWG_TYPE_LOFTEDSURFACE,DWG_TYPE_MATERIAL,
        DWG_TYPE_MENTALRAYRENDERSETTINGS,DWG_TYPE_MESH,
        DWG_TYPE_MLEADEROBJECTCONTEXTDATA,
        DWG_TYPE_MLEADERSTYLE,DWG_TYPE_MOTIONPATH,
        DWG_TYPE_MPOLYGON,DWG_TYPE_MTEXTATTRIBUTEOBJECTCONTEXTDATA,
        DWG_TYPE_MTEXTOBJECTCONTEXTDATA,DWG_TYPE_MULTILEADER,
        DWG_TYPE_NAVISWORKSMODEL,DWG_TYPE_NAVISWORKSMODELDEF,
        DWG_TYPE_NPOCOLLECTION,DWG_TYPE_NURBSURFACE,
        DWG_TYPE_OBJECT_PTR,DWG_TYPE_ORDDIMOBJECTCONTEXTDATA,
        DWG_TYPE_PARTIAL_VIEWING_INDEX,DWG_TYPE_PDFDEFINITION,
        DWG_TYPE_PDFUNDERLAY,DWG_TYPE_PERSUBENTMGR,
        DWG_TYPE_PLANESURFACE,DWG_TYPE_PLOTSETTINGS,
        DWG_TYPE_POINTCLOUD,DWG_TYPE_POINTCLOUDCOLORMAP,
        DWG_TYPE_POINTCLOUDDEF,DWG_TYPE_POINTCLOUDDEFEX,
        DWG_TYPE_POINTCLOUDDEF_REACTOR,DWG_TYPE_POINTCLOUDDEF_REACTOR_EX,
        DWG_TYPE_POINTCLOUDEX,DWG_TYPE_POINTPARAMETERENTITY,
        DWG_TYPE_POINTPATH,DWG_TYPE_POLARGRIPENTITY,
        DWG_TYPE_RADIMLGOBJECTCONTEXTDATA,
        DWG_TYPE_RADIMOBJECTCONTEXTDATA,DWG_TYPE_RAPIDRTRENDERSETTINGS,
        DWG_TYPE_RASTERVARIABLES,DWG_TYPE_RENDERENTRY,
        DWG_TYPE_RENDERENVIRONMENT,DWG_TYPE_RENDERGLOBAL,
        DWG_TYPE_RENDERSETTINGS,DWG_TYPE_REVOLVEDSURFACE,
        DWG_TYPE_ROTATIONPARAMETERENTITY,DWG_TYPE_RTEXT,
        DWG_TYPE_SCALE,DWG_TYPE_SECTIONOBJECT,
        DWG_TYPE_SECTIONVIEWSTYLE,DWG_TYPE_SECTION_MANAGER,
        DWG_TYPE_SECTION_SETTINGS,DWG_TYPE_SKYLIGHT_BACKGROUND,
        DWG_TYPE_SOLID_BACKGROUND,DWG_TYPE_SORTENTSTABLE,
        DWG_TYPE_SPATIAL_FILTER,DWG_TYPE_SPATIAL_INDEX,
        DWG_TYPE_SUN,DWG_TYPE_SUNSTUDY,DWG_TYPE_SWEPTSURFACE,
        DWG_TYPE_TABLE,DWG_TYPE_TABLECONTENT,
        DWG_TYPE_TABLEGEOMETRY,DWG_TYPE_TABLESTYLE,
        DWG_TYPE_TEXTOBJECTCONTEXTDATA,DWG_TYPE_TVDEVICEPROPERTIES,
        DWG_TYPE_VISIBILITYGRIPENTITY,DWG_TYPE_VISIBILITYPARAMETERENTITY,
        DWG_TYPE_VISUALSTYLE,DWG_TYPE_WIPEOUT,
        DWG_TYPE_WIPEOUTVARIABLES,DWG_TYPE_XREFPANELOBJECT,
        DWG_TYPE_XYPARAMETERENTITY,DWG_TYPE_BREAKDATA,
        DWG_TYPE_BREAKPOINTREF,DWG_TYPE_FLIPGRIPENTITY,
        DWG_TYPE_LINEARGRIPENTITY,DWG_TYPE_ROTATIONGRIPENTITY,
        DWG_TYPE_XYGRIPENTITY,DWG_TYPE__3DLINE,
        DWG_TYPE_REPEAT,DWG_TYPE_ENDREP,DWG_TYPE_LOAD,
        DWG_TYPE_FREED = $fffd,DWG_TYPE_UNKNOWN_ENT = $fffe,
        DWG_TYPE_UNKNOWN_OBJ = $ffff);

      //PDWG_OBJECT_TYPE_R11 = ^DWG_OBJECT_TYPE_R11;
      DWG_OBJECT_TYPE_R11 = (DWG_TYPE_UNUSED_R11 = 0,DWG_TYPE_LINE_R11 = 1,
        DWG_TYPE_POINT_R11 = 2,DWG_TYPE_CIRCLE_R11 = 3,
        DWG_TYPE_SHAPE_R11 = 4,DWG_TYPE_REPEAT_R11 = 5,
        DWG_TYPE_ENDREP_R11 = 6,DWG_TYPE_TEXT_R11 = 7,
        DWG_TYPE_ARC_R11 = 8,DWG_TYPE_TRACE_R11 = 9,
        DWG_TYPE_LOAD_R11 = 10,DWG_TYPE_SOLID_R11 = 11,
        DWG_TYPE_BLOCK_R11 = 12,DWG_TYPE_ENDBLK_R11 = 13,
        DWG_TYPE_INSERT_R11 = 14,DWG_TYPE_ATTDEF_R11 = 15,
        DWG_TYPE_ATTRIB_R11 = 16,DWG_TYPE_SEQEND_R11 = 17,
        DWG_TYPE_PLINE_R11 = 18,DWG_TYPE_POLYLINE_R11 = 19,
        DWG_TYPE_VERTEX_R11 = 20,DWG_TYPE_3DLINE_R11 = 21,
        DWG_TYPE_3DFACE_R11 = 22,DWG_TYPE_DIMENSION_R11 = 23,
        DWG_TYPE_VIEWPORT_R11 = 24,DWG_TYPE_UNKNOWN_R11 = 25
        );

      //PDWG_ERROR = ^DWG_ERROR;
      DWG_ERROR = (DWG_NOERR = 0,DWG_ERR_WRONGCRC = 1,
        DWG_ERR_NOTYETSUPPORTED = 1 shl 1,DWG_ERR_UNHANDLEDCLASS = 1 shl 2,
        DWG_ERR_INVALIDTYPE = 1 shl 3,DWG_ERR_INVALIDHANDLE = 1 shl 4,
        DWG_ERR_INVALIDEED = 1 shl 5,DWG_ERR_VALUEOUTOFBOUNDS = 1 shl 6,
        DWG_ERR_CLASSESNOTFOUND = 1 shl 7,DWG_ERR_SECTIONNOTFOUND = 1 shl 8,
        DWG_ERR_PAGENOTFOUND = 1 shl 9,DWG_ERR_INTERNALERROR = 1 shl 10,
        DWG_ERR_INVALIDDWG = 1 shl 11,DWG_ERR_IOERROR = 1 shl 12,
        DWG_ERR_OUTOFMEM = 1 shl 13);

      //P_dwg_handle = ^_dwg_handle;
      _dwg_handle = record
          code : BITCODE_RC;
          size : BITCODE_RC;
          value : dword;
          is_global : BITCODE_B;
        end;
      Dwg_Handle = _dwg_handle;
      //PDwg_Handle = ^Dwg_Handle;

      //P_dwg_object_ref = ^_dwg_object_ref;
      _dwg_object_ref = record
          obj : P_dwg_object;
          handleref : Dwg_Handle;
          absolute_ref : dword;
          r11_idx : BITCODE_RS;
        end;
      Dwg_Object_Ref = _dwg_object_ref;
      //PDwg_Object_Ref = ^Dwg_Object_Ref;

      //PBITCODE_H = ^BITCODE_H;
      BITCODE_H = PDwg_Object_Ref;

      //PDWG_HDL_CODE = ^DWG_HDL_CODE;
      DWG_HDL_CODE = (DWG_HDL_OWNER = 0,DWG_HDL_SOFTOWN = 2,
        DWG_HDL_HARDOWN = 3,DWG_HDL_SOFTPTR = 4,
        DWG_HDL_HARDPTR = 5);

      //P_dwg_color = ^_dwg_color;
      _dwg_color = record
          index : BITCODE_BSd;
          flag : BITCODE_BS;
          raw : BITCODE_BS;
          rgb : BITCODE_BL;
          method : dword;
          name : BITCODE_TV;
          book_name : BITCODE_TV;
          handle : BITCODE_H;
          alpha_type : BITCODE_BB;
          alpha : BITCODE_RC;
        end;
      Dwg_Color = _dwg_color;
      //PDwg_Color = ^Dwg_Color;

      //PBITCODE_CMC = ^BITCODE_CMC;
      BITCODE_CMC = Dwg_Color;

      //PBITCODE_CMTC = ^BITCODE_CMTC;
      BITCODE_CMTC = Dwg_Color;

      //PBITCODE_ENC = ^BITCODE_ENC;
      BITCODE_ENC = Dwg_Color;
(* error 
__attribute__((visibility("default"))) const char* dwg_color_method_name (unsigned method);
 in declarator_list *)
      //P_dwg_binary_chunk = ^_dwg_binary_chunk;
      _dwg_binary_chunk = record
          size : word;
          flag0 : word;
          u : record
              case longint of
                0 : ( data : Pchar );
                1 : ( wdata : Pdwg_wchar_t );
              end;
        end;


      //P_dwg_resbuf = ^_dwg_resbuf;
      _dwg_resbuf = record
          _type : smallint;
          value : record
              case longint of
                0 : ( pt : array[0..2] of double );
                1 : ( i8 : char );
                2 : ( i16 : smallint );
                3 : ( i32 : longint );
                4 : ( i64 : BITCODE_BLL );
                5 : ( dbl : double );
                6 : ( hdl : array[0..7] of byte );
                7 : ( h : Dwg_Handle );
                8 : ( str : _dwg_binary_chunk );
              end;
          nextrb : P_dwg_resbuf;
        end;
      Dwg_Resbuf = _dwg_resbuf;
      //PDwg_Resbuf = ^Dwg_Resbuf;

      //P_dwg_header_variables = ^_dwg_header_variables;
      _dwg_header_variables = record
          size : BITCODE_RL;
          bitsize_hi : BITCODE_RL;
          bitsize : BITCODE_RL;
          ACADMAINTVER : BITCODE_RC;
          REQUIREDVERSIONS : BITCODE_BLL;
          DWGCODEPAGE : BITCODE_TV;
          unknown_0 : BITCODE_BD;
          unknown_1 : BITCODE_BD;
          unknown_2 : BITCODE_BD;
          unknown_3 : BITCODE_BD;
          unknown_text1 : BITCODE_TV;
          unknown_text2 : BITCODE_TV;
          unknown_text3 : BITCODE_TV;
          unknown_text4 : BITCODE_TV;
          unknown_8 : BITCODE_BL;
          unknown_9 : BITCODE_BL;
          unknown_10 : BITCODE_BS;
          unknown_18 : BITCODE_BS;
          VX_TABLE_RECORD : BITCODE_H;
          DIMASO : BITCODE_B;
          DIMSHO : BITCODE_B;
          DIMSAV : BITCODE_B;
          PLINEGEN : BITCODE_B;
          ORTHOMODE : BITCODE_B;
          REGENMODE : BITCODE_B;
          FILLMODE : BITCODE_B;
          QTEXTMODE : BITCODE_B;
          PSLTSCALE : BITCODE_B;
          LIMCHECK : BITCODE_B;
          BLIPMODE : BITCODE_B;
          unknown_11 : BITCODE_B;
          USRTIMER : BITCODE_B;
          FASTZOOM : BITCODE_B;
          FLATLAND : BITCODE_B;
          VIEWMODE : BITCODE_B;
          SKPOLY : BITCODE_B;
          ANGDIR : BITCODE_B;
          SPLFRAME : BITCODE_B;
          ATTREQ : BITCODE_B;
          ATTDIA : BITCODE_B;
          MIRRTEXT : BITCODE_B;
          WORLDVIEW : BITCODE_B;
          WIREFRAME : BITCODE_B;
          TILEMODE : BITCODE_B;
          PLIMCHECK : BITCODE_B;
          VISRETAIN : BITCODE_B;
          DELOBJ : BITCODE_B;
          DISPSILH : BITCODE_B;
          PELLIPSE : BITCODE_B;
          SAVEIMAGES : BITCODE_BS;
          PROXYGRAPHICS : BITCODE_BS;
          MEASUREMENT : BITCODE_BS;
          DRAGMODE : BITCODE_BS;
          TREEDEPTH : BITCODE_BS;
          LUNITS : BITCODE_BS;
          LUPREC : BITCODE_BS;
          AUNITS : BITCODE_BS;
          AUPREC : BITCODE_BS;
          ATTMODE : BITCODE_BS;
          COORDS : BITCODE_BS;
          PDMODE : BITCODE_BS;
          PICKSTYLE : BITCODE_BS;
          OSMODE : BITCODE_BL;
          unknown_12 : BITCODE_BL;
          unknown_13 : BITCODE_BL;
          unknown_14 : BITCODE_BL;
          USERI1 : BITCODE_BS;
          USERI2 : BITCODE_BS;
          USERI3 : BITCODE_BS;
          USERI4 : BITCODE_BS;
          USERI5 : BITCODE_BS;
          SPLINESEGS : BITCODE_BS;
          SURFU : BITCODE_BS;
          SURFV : BITCODE_BS;
          SURFTYPE : BITCODE_BS;
          SURFTAB1 : BITCODE_BS;
          SURFTAB2 : BITCODE_BS;
          SPLINETYPE : BITCODE_BS;
          SHADEDGE : BITCODE_BS;
          SHADEDIF : BITCODE_BS;
          UNITMODE : BITCODE_BS;
          MAXACTVP : BITCODE_BS;
          ISOLINES : BITCODE_BS;
          CMLJUST : BITCODE_BS;
          TEXTQLTY : BITCODE_BS;
          unknown_14b : BITCODE_BL;
          LTSCALE : BITCODE_BD;
          TEXTSIZE : BITCODE_BD;
          TRACEWID : BITCODE_BD;
          SKETCHINC : BITCODE_BD;
          FILLETRAD : BITCODE_BD;
          THICKNESS : BITCODE_BD;
          ANGBASE : BITCODE_BD;
          PDSIZE : BITCODE_BD;
          PLINEWID : BITCODE_BD;
          USERR1 : BITCODE_BD;
          USERR2 : BITCODE_BD;
          USERR3 : BITCODE_BD;
          USERR4 : BITCODE_BD;
          USERR5 : BITCODE_BD;
          CHAMFERA : BITCODE_BD;
          CHAMFERB : BITCODE_BD;
          CHAMFERC : BITCODE_BD;
          CHAMFERD : BITCODE_BD;
          FACETRES : BITCODE_BD;
          CMLSCALE : BITCODE_BD;
          CELTSCALE : BITCODE_BD;
          VIEWTWIST : BITCODE_BD;
          MENU : BITCODE_TV;
          TDCREATE : BITCODE_TIMEBLL;
          TDUPDATE : BITCODE_TIMEBLL;
          TDUCREATE : BITCODE_TIMEBLL;
          TDUUPDATE : BITCODE_TIMEBLL;
          unknown_15 : BITCODE_BL;
          unknown_16 : BITCODE_BL;
          unknown_17 : BITCODE_BL;
          TDINDWG : BITCODE_TIMEBLL;
          TDUSRTIMER : BITCODE_TIMEBLL;
          CECOLOR : BITCODE_CMC;
          HANDLING : BITCODE_BS;
          HANDSEED : BITCODE_H;
          unknown_5 : BITCODE_RS;
          unknown_6 : BITCODE_RS;
          unknown_7 : BITCODE_RD;
          CLAYER : BITCODE_H;
          TEXTSTYLE : BITCODE_H;
          CELTYPE : BITCODE_H;
          CMATERIAL : BITCODE_H;
          DIMSTYLE : BITCODE_H;
          CMLSTYLE : BITCODE_H;
          PSVPSCALE : BITCODE_BD;
          PINSBASE : BITCODE_3BD;
          PEXTMIN : BITCODE_3BD;
          PEXTMAX : BITCODE_3BD;
          PLIMMIN : BITCODE_2DPOINT;
          PLIMMAX : BITCODE_2DPOINT;
          PELEVATION : BITCODE_BD;
          PUCSORG : BITCODE_3BD;
          PUCSXDIR : BITCODE_3BD;
          PUCSYDIR : BITCODE_3BD;
          PUCSNAME : BITCODE_H;
          PUCSBASE : BITCODE_H;
          PUCSORTHOREF : BITCODE_H;
          PUCSORTHOVIEW : BITCODE_BS;
          PUCSORGTOP : BITCODE_3BD;
          PUCSORGBOTTOM : BITCODE_3BD;
          PUCSORGLEFT : BITCODE_3BD;
          PUCSORGRIGHT : BITCODE_3BD;
          PUCSORGFRONT : BITCODE_3BD;
          PUCSORGBACK : BITCODE_3BD;
          INSBASE : BITCODE_3BD;
          EXTMIN : BITCODE_3BD;
          EXTMAX : BITCODE_3BD;
          VIEWDIR : BITCODE_3BD;
          TARGET : BITCODE_3BD;
          LIMMIN : BITCODE_2DPOINT;
          LIMMAX : BITCODE_2DPOINT;
          VIEWCTR : BITCODE_3RD;
          ELEVATION : BITCODE_BD;
          VIEWSIZE : BITCODE_RD;
          SNAPMODE : BITCODE_RS;
          SNAPUNIT : BITCODE_2RD;
          SNAPBASE : BITCODE_2RD;
          SNAPANG : BITCODE_RD;
          SNAPSTYLE : BITCODE_RS;
          SNAPISOPAIR : BITCODE_RS;
          GRIDMODE : BITCODE_RS;
          GRIDUNIT : BITCODE_2RD;
          AXISMODE : BITCODE_BS;
          AXISUNIT : BITCODE_2RD;
          UCSORG : BITCODE_3BD;
          UCSXDIR : BITCODE_3BD;
          UCSYDIR : BITCODE_3BD;
          UCSNAME : BITCODE_H;
          UCSBASE : BITCODE_H;
          UCSORTHOVIEW : BITCODE_BS;
          UCSORTHOREF : BITCODE_H;
          UCSORGTOP : BITCODE_3BD;
          UCSORGBOTTOM : BITCODE_3BD;
          UCSORGLEFT : BITCODE_3BD;
          UCSORGRIGHT : BITCODE_3BD;
          UCSORGFRONT : BITCODE_3BD;
          UCSORGBACK : BITCODE_3BD;
          DIMPOST : BITCODE_TV;
          DIMAPOST : BITCODE_TV;
          DIMTOL : BITCODE_B;
          DIMLIM : BITCODE_B;
          DIMTIH : BITCODE_B;
          DIMTOH : BITCODE_B;
          DIMSE1 : BITCODE_B;
          DIMSE2 : BITCODE_B;
          DIMALT : BITCODE_B;
          DIMTOFL : BITCODE_B;
          DIMSAH : BITCODE_B;
          DIMTIX : BITCODE_B;
          DIMSOXD : BITCODE_B;
          DIMALTD : BITCODE_BS;
          DIMZIN : BITCODE_BS;
          DIMSD1 : BITCODE_B;
          DIMSD2 : BITCODE_B;
          DIMTOLJ : BITCODE_BS;
          DIMJUST : BITCODE_BS;
          DIMFIT : BITCODE_BS;
          DIMUPT : BITCODE_B;
          DIMTZIN : BITCODE_BS;
          DIMMALTZ : BITCODE_BS;
          DIMMALTTZ : BITCODE_BS;
          DIMTAD : BITCODE_BS;
          DIMUNIT : BITCODE_BS;
          DIMAUNIT : BITCODE_BS;
          DIMDEC : BITCODE_BS;
          DIMTDEC : BITCODE_BS;
          DIMALTU : BITCODE_BS;
          DIMALTTD : BITCODE_BS;
          DIMTXSTY : BITCODE_H;
          DIMSCALE : BITCODE_BD;
          DIMASZ : BITCODE_BD;
          DIMEXO : BITCODE_BD;
          DIMDLI : BITCODE_BD;
          DIMEXE : BITCODE_BD;
          DIMRND : BITCODE_BD;
          DIMDLE : BITCODE_BD;
          DIMTP : BITCODE_BD;
          DIMTM : BITCODE_BD;
          DIMFXL : BITCODE_BD;
          DIMJOGANG : BITCODE_BD;
          DIMTFILL : BITCODE_BS;
          DIMTFILLCLR : BITCODE_CMC;
          DIMAZIN : BITCODE_BS;
          DIMARCSYM : BITCODE_BS;
          DIMTXT : BITCODE_BD;
          DIMCEN : BITCODE_BD;
          DIMTSZ : BITCODE_BD;
          DIMALTF : BITCODE_BD;
          DIMLFAC : BITCODE_BD;
          DIMTVP : BITCODE_BD;
          DIMTFAC : BITCODE_BD;
          DIMGAP : BITCODE_BD;
          DIMPOST_T : BITCODE_TV;
          DIMAPOST_T : BITCODE_TV;
          DIMBLK_T : BITCODE_TV;
          DIMBLK1_T : BITCODE_TV;
          DIMBLK2_T : BITCODE_TV;
          unknown_string : BITCODE_TV;
          DIMALTRND : BITCODE_BD;
          DIMCLRD_C : BITCODE_RS;
          DIMCLRE_C : BITCODE_RS;
          DIMCLRT_C : BITCODE_RS;
          DIMCLRD : BITCODE_CMC;
          DIMCLRE : BITCODE_CMC;
          DIMCLRT : BITCODE_CMC;
          DIMADEC : BITCODE_BS;
          DIMFRAC : BITCODE_BS;
          DIMLUNIT : BITCODE_BS;
          DIMDSEP : BITCODE_BS;
          DIMTMOVE : BITCODE_BS;
          DIMALTZ : BITCODE_BS;
          DIMALTTZ : BITCODE_BS;
          DIMATFIT : BITCODE_BS;
          DIMFXLON : BITCODE_B;
          DIMTXTDIRECTION : BITCODE_B;
          DIMALTMZF : BITCODE_BD;
          DIMALTMZS : BITCODE_TV;
          DIMMZF : BITCODE_BD;
          DIMMZS : BITCODE_TV;
          DIMLDRBLK : BITCODE_H;
          DIMBLK : BITCODE_H;
          DIMBLK1 : BITCODE_H;
          DIMBLK2 : BITCODE_H;
          DIMLTYPE : BITCODE_H;
          DIMLTEX1 : BITCODE_H;
          DIMLTEX2 : BITCODE_H;
          DIMLWD : BITCODE_BSd;
          DIMLWE : BITCODE_BSd;
          BLOCK_CONTROL_OBJECT : BITCODE_H;
          LAYER_CONTROL_OBJECT : BITCODE_H;
          STYLE_CONTROL_OBJECT : BITCODE_H;
          LTYPE_CONTROL_OBJECT : BITCODE_H;
          VIEW_CONTROL_OBJECT : BITCODE_H;
          UCS_CONTROL_OBJECT : BITCODE_H;
          VPORT_CONTROL_OBJECT : BITCODE_H;
          APPID_CONTROL_OBJECT : BITCODE_H;
          DIMSTYLE_CONTROL_OBJECT : BITCODE_H;
          VX_CONTROL_OBJECT : BITCODE_H;
          DICTIONARY_ACAD_GROUP : BITCODE_H;
          DICTIONARY_ACAD_MLINESTYLE : BITCODE_H;
          DICTIONARY_NAMED_OBJECT : BITCODE_H;
          TSTACKALIGN : BITCODE_BS;
          TSTACKSIZE : BITCODE_BS;
          HYPERLINKBASE : BITCODE_TV;
          STYLESHEET : BITCODE_TV;
          DICTIONARY_LAYOUT : BITCODE_H;
          DICTIONARY_PLOTSETTINGS : BITCODE_H;
          DICTIONARY_PLOTSTYLENAME : BITCODE_H;
          DICTIONARY_MATERIAL : BITCODE_H;
          DICTIONARY_COLOR : BITCODE_H;
          DICTIONARY_VISUALSTYLE : BITCODE_H;
          DICTIONARY_LIGHTLIST : BITCODE_H;
          unknown_20 : BITCODE_H;
          FLAGS : BITCODE_BL;
          CELWEIGHT : BITCODE_BSd;
          ENDCAPS : BITCODE_B;
          JOINSTYLE : BITCODE_B;
          LWDISPLAY : BITCODE_B;
          XEDIT : BITCODE_B;
          EXTNAMES : BITCODE_B;
          PSTYLEMODE : BITCODE_B;
          OLESTARTUP : BITCODE_B;
          INSUNITS : BITCODE_BS;
          CEPSNTYPE : BITCODE_BS;
          CPSNID : BITCODE_H;
          FINGERPRINTGUID : BITCODE_TV;
          VERSIONGUID : BITCODE_TV;
          SORTENTS : BITCODE_RC;
          INDEXCTL : BITCODE_RC;
          HIDETEXT : BITCODE_RC;
          XCLIPFRAME : BITCODE_RC;
          DIMASSOC : BITCODE_RC;
          HALOGAP : BITCODE_RC;
          OBSCOLOR : BITCODE_BS;
          INTERSECTIONCOLOR : BITCODE_BS;
          OBSLTYPE : BITCODE_RC;
          INTERSECTIONDISPLAY : BITCODE_RC;
          PROJECTNAME : BITCODE_TV;
          BLOCK_RECORD_PSPACE : BITCODE_H;
          BLOCK_RECORD_MSPACE : BITCODE_H;
          LTYPE_BYLAYER : BITCODE_H;
          LTYPE_BYBLOCK : BITCODE_H;
          LTYPE_CONTINUOUS : BITCODE_H;
          CAMERADISPLAY : BITCODE_B;
          unknown_21 : BITCODE_BL;
          unknown_22 : BITCODE_BL;
          unknown_23 : BITCODE_BD;
          STEPSPERSEC : BITCODE_BD;
          STEPSIZE : BITCODE_BD;
          _3DDWFPREC : BITCODE_BD;
          LENSLENGTH : BITCODE_BD;
          CAMERAHEIGHT : BITCODE_BD;
          SOLIDHIST : BITCODE_RC;
          SHOWHIST : BITCODE_RC;
          PSOLWIDTH : BITCODE_BD;
          PSOLHEIGHT : BITCODE_BD;
          LOFTANG1 : BITCODE_BD;
          LOFTANG2 : BITCODE_BD;
          LOFTMAG1 : BITCODE_BD;
          LOFTMAG2 : BITCODE_BD;
          LOFTPARAM : BITCODE_BS;
          LOFTNORMALS : BITCODE_RC;
          LATITUDE : BITCODE_BD;
          LONGITUDE : BITCODE_BD;
          NORTHDIRECTION : BITCODE_BD;
          TIMEZONE : BITCODE_BL;
          LIGHTGLYPHDISPLAY : BITCODE_RC;
          TILEMODELIGHTSYNCH : BITCODE_RC;
          DWFFRAME : BITCODE_RC;
          DGNFRAME : BITCODE_RC;
          REALWORLDSCALE : BITCODE_B;
          INTERFERECOLOR : BITCODE_CMC;
          INTERFEREOBJVS : BITCODE_H;
          INTERFEREVPVS : BITCODE_H;
          DRAGVS : BITCODE_H;
          CSHADOW : BITCODE_RC;
          SHADOWPLANELOCATION : BITCODE_BD;
          unknown_54 : BITCODE_BS;
          unknown_55 : BITCODE_BS;
          unknown_56 : BITCODE_BS;
          unknown_57 : BITCODE_BS;
          dwg_size : BITCODE_RL;
          numentities : BITCODE_RS;
          circle_zoom_percent : BITCODE_RS;
          unknown_58 : BITCODE_RC;
          unknown_59 : BITCODE_RC;
          unknown_60 : BITCODE_RC;
          FRONTZ : BITCODE_BD;
          BACKZ : BITCODE_BD;
          UCSICON : BITCODE_RC;
          oldCECOLOR_hi : BITCODE_RL;
          oldCECOLOR_lo : BITCODE_RL;
          layer_colors : array[0..127] of BITCODE_RS;
          unknown_51e : BITCODE_RS;
          unknown_520 : BITCODE_RS;
          unknown_unit1 : BITCODE_TV;
          unknown_unit2 : BITCODE_TV;
          unknown_unit3 : BITCODE_TV;
          unknown_unit4 : BITCODE_TV;
        end;
      Dwg_Header_Variables = _dwg_header_variables;
      //PDwg_Header_Variables = ^Dwg_Header_Variables;

      //PDwg_Entity_UNUSED = ^Dwg_Entity_UNUSED;
      Dwg_Entity_UNUSED = longint;

      //P_dwg_entity_TEXT = ^_dwg_entity_TEXT;
      _dwg_entity_TEXT = record
          parent : P_dwg_object_entity;
          dataflags : BITCODE_RC;
          elevation : BITCODE_RD;
          ins_pt : BITCODE_2DPOINT;
          alignment_pt : BITCODE_2DPOINT;
          extrusion : BITCODE_BE;
          thickness : BITCODE_RD;
          oblique_angle : BITCODE_RD;
          rotation : BITCODE_RD;
          height : BITCODE_RD;
          width_factor : BITCODE_RD;
          text_value : BITCODE_TV;
          generation : BITCODE_BS;
          horiz_alignment : BITCODE_BS;
          vert_alignment : BITCODE_BS;
          style : BITCODE_H;
        end;
      Dwg_Entity_TEXT = _dwg_entity_TEXT;
      //PDwg_Entity_TEXT = ^Dwg_Entity_TEXT;

      //P_dwg_entity_ATTRIB = ^_dwg_entity_ATTRIB;
      _dwg_entity_ATTRIB = record
          parent : P_dwg_object_entity;
          elevation : BITCODE_BD;
          ins_pt : BITCODE_2DPOINT;
          alignment_pt : BITCODE_2DPOINT;
          extrusion : BITCODE_BE;
          thickness : BITCODE_RD;
          oblique_angle : BITCODE_RD;
          rotation : BITCODE_RD;
          height : BITCODE_RD;
          width_factor : BITCODE_RD;
          text_value : BITCODE_TV;
          generation : BITCODE_BS;
          horiz_alignment : BITCODE_BS;
          vert_alignment : BITCODE_BS;
          dataflags : BITCODE_RC;
          class_version : BITCODE_RC;
          _type : BITCODE_RC;
          tag : BITCODE_TV;
          field_length : BITCODE_BS;
          flags : BITCODE_RC;
          lock_position_flag : BITCODE_B;
          style : BITCODE_H;
          mtext_handles : BITCODE_H;
          annotative_data_size : BITCODE_BS;
          annotative_data_bytes : BITCODE_RC;
          annotative_app : BITCODE_H;
          annotative_short : BITCODE_BS;
        end;
      Dwg_Entity_ATTRIB = _dwg_entity_ATTRIB;
      //PDwg_Entity_ATTRIB = ^Dwg_Entity_ATTRIB;

      //P_dwg_entity_ATTDEF = ^_dwg_entity_ATTDEF;
      _dwg_entity_ATTDEF = record
          parent : P_dwg_object_entity;
          elevation : BITCODE_BD;
          ins_pt : BITCODE_2DPOINT;
          alignment_pt : BITCODE_2DPOINT;
          extrusion : BITCODE_BE;
          thickness : BITCODE_RD;
          oblique_angle : BITCODE_RD;
          rotation : BITCODE_RD;
          height : BITCODE_RD;
          width_factor : BITCODE_RD;
          default_value : BITCODE_TV;
          generation : BITCODE_BS;
          horiz_alignment : BITCODE_BS;
          vert_alignment : BITCODE_BS;
          dataflags : BITCODE_RC;
          class_version : BITCODE_RC;
          _type : BITCODE_RC;
          tag : BITCODE_TV;
          field_length : BITCODE_BS;
          flags : BITCODE_RC;
          lock_position_flag : BITCODE_B;
          style : BITCODE_H;
          mtext_handles : BITCODE_H;
          annotative_data_size : BITCODE_BS;
          annotative_data_bytes : BITCODE_RC;
          annotative_app : BITCODE_H;
          annotative_short : BITCODE_BS;
          attdef_class_version : BITCODE_RC;
          prompt : BITCODE_TV;
        end;
      Dwg_Entity_ATTDEF = _dwg_entity_ATTDEF;
      //PDwg_Entity_ATTDEF = ^Dwg_Entity_ATTDEF;

      //P_dwg_entity_BLOCK = ^_dwg_entity_BLOCK;
      _dwg_entity_BLOCK = record
          parent : P_dwg_object_entity;
          name : BITCODE_TV;
          xref_pname : BITCODE_TV;
          base_pt : BITCODE_2RD;
        end;
      Dwg_Entity_BLOCK = _dwg_entity_BLOCK;
      //PDwg_Entity_BLOCK = ^Dwg_Entity_BLOCK;

      //P_dwg_entity_ENDBLK = ^_dwg_entity_ENDBLK;
      _dwg_entity_ENDBLK = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_ENDBLK = _dwg_entity_ENDBLK;
      //PDwg_Entity_ENDBLK = ^Dwg_Entity_ENDBLK;

      //P_dwg_entity_SEQEND = ^_dwg_entity_SEQEND;
      _dwg_entity_SEQEND = record
          parent : P_dwg_object_entity;
          unknown_r11 : BITCODE_RL;
        end;
      Dwg_Entity_SEQEND = _dwg_entity_SEQEND;
      //PDwg_Entity_SEQEND = ^Dwg_Entity_SEQEND;

      //P_dwg_entity_INSERT = ^_dwg_entity_INSERT;
      _dwg_entity_INSERT = record
          parent : P_dwg_object_entity;
          ins_pt : BITCODE_3DPOINT;
          scale_flag : BITCODE_BB;
          scale : BITCODE_3DPOINT;
          rotation : BITCODE_BD;
          extrusion : BITCODE_BE;
          has_attribs : BITCODE_B;
          num_owned : BITCODE_BL;
          block_header : BITCODE_H;
          first_attrib : BITCODE_H;
          last_attrib : BITCODE_H;
          attribs : PBITCODE_H;
          seqend : BITCODE_H;
          num_cols : BITCODE_RS;
          num_rows : BITCODE_RS;
          col_spacing : BITCODE_RD;
          row_spacing : BITCODE_RD;
          block_name : BITCODE_TV;
        end;
      Dwg_Entity_INSERT = _dwg_entity_INSERT;
      //PDwg_Entity_INSERT = ^Dwg_Entity_INSERT;

      //P_dwg_entity_MINSERT = ^_dwg_entity_MINSERT;
      _dwg_entity_MINSERT = record
          parent : P_dwg_object_entity;
          ins_pt : BITCODE_3DPOINT;
          scale_flag : BITCODE_BB;
          scale : BITCODE_3DPOINT;
          rotation : BITCODE_BD;
          extrusion : BITCODE_BE;
          has_attribs : BITCODE_B;
          num_owned : BITCODE_BL;
          num_cols : BITCODE_BS;
          num_rows : BITCODE_BS;
          col_spacing : BITCODE_BD;
          row_spacing : BITCODE_BD;
          block_header : BITCODE_H;
          first_attrib : BITCODE_H;
          last_attrib : BITCODE_H;
          attribs : PBITCODE_H;
          seqend : BITCODE_H;
        end;
      Dwg_Entity_MINSERT = _dwg_entity_MINSERT;
      //PDwg_Entity_MINSERT = ^Dwg_Entity_MINSERT;

      //P_dwg_entity_VERTEX_2D = ^_dwg_entity_VERTEX_2D;
      _dwg_entity_VERTEX_2D = record
          parent : P_dwg_object_entity;
          flag : BITCODE_RC;
          point : BITCODE_3BD;
          start_width : BITCODE_BD;
          end_width : BITCODE_BD;
          id : BITCODE_BL;
          bulge : BITCODE_BD;
          tangent_dir : BITCODE_BD;
        end;
      Dwg_Entity_VERTEX_2D = _dwg_entity_VERTEX_2D;
      //PDwg_Entity_VERTEX_2D = ^Dwg_Entity_VERTEX_2D;

      //P_dwg_entity_VERTEX_3D = ^_dwg_entity_VERTEX_3D;
      _dwg_entity_VERTEX_3D = record
          parent : P_dwg_object_entity;
          flag : BITCODE_RC;
          point : BITCODE_3BD;
        end;
      Dwg_Entity_VERTEX_3D = _dwg_entity_VERTEX_3D;
      //PDwg_Entity_VERTEX_3D = ^Dwg_Entity_VERTEX_3D;

      //PDwg_Entity_VERTEX_MESH = ^Dwg_Entity_VERTEX_MESH;
      Dwg_Entity_VERTEX_MESH = Dwg_Entity_VERTEX_3D;

      //PDwg_Entity_VERTEX_PFACE = ^Dwg_Entity_VERTEX_PFACE;
      Dwg_Entity_VERTEX_PFACE = Dwg_Entity_VERTEX_3D;

      //P_dwg_entity_VERTEX_PFACE_FACE = ^_dwg_entity_VERTEX_PFACE_FACE;
      _dwg_entity_VERTEX_PFACE_FACE = record
          parent : P_dwg_object_entity;
          flag : BITCODE_RC;
          vertind : array[0..3] of BITCODE_BS;
        end;
      Dwg_Entity_VERTEX_PFACE_FACE = _dwg_entity_VERTEX_PFACE_FACE;
      //PDwg_Entity_VERTEX_PFACE_FACE = ^Dwg_Entity_VERTEX_PFACE_FACE;

      //P_dwg_entity_POLYLINE_2D = ^_dwg_entity_POLYLINE_2D;
      _dwg_entity_POLYLINE_2D = record
          parent : P_dwg_object_entity;
          has_vertex : BITCODE_B;
          num_owned : BITCODE_BL;
          first_vertex : BITCODE_H;
          last_vertex : BITCODE_H;
          vertex : PBITCODE_H;
          seqend : BITCODE_H;
          flag : BITCODE_BS;
          curve_type : BITCODE_BS;
          start_width : BITCODE_BD;
          end_width : BITCODE_BD;
          thickness : BITCODE_BT;
          elevation : BITCODE_BD;
          extrusion : BITCODE_BE;
        end;
      Dwg_Entity_POLYLINE_2D = _dwg_entity_POLYLINE_2D;
      //PDwg_Entity_POLYLINE_2D = ^Dwg_Entity_POLYLINE_2D;

      //P_dwg_entity_POLYLINE_3D = ^_dwg_entity_POLYLINE_3D;
      _dwg_entity_POLYLINE_3D = record
          parent : P_dwg_object_entity;
          has_vertex : BITCODE_B;
          num_owned : BITCODE_BL;
          first_vertex : BITCODE_H;
          last_vertex : BITCODE_H;
          vertex : PBITCODE_H;
          seqend : BITCODE_H;
          curve_type : BITCODE_RC;
          flag : BITCODE_RC;
        end;
      Dwg_Entity_POLYLINE_3D = _dwg_entity_POLYLINE_3D;
      //PDwg_Entity_POLYLINE_3D = ^Dwg_Entity_POLYLINE_3D;

      //P_dwg_entity_ARC = ^_dwg_entity_ARC;
      _dwg_entity_ARC = record
          parent : P_dwg_object_entity;
          center : BITCODE_3BD;
          radius : BITCODE_BD;
          thickness : BITCODE_BT;
          extrusion : BITCODE_BE;
          start_angle : BITCODE_BD;
          end_angle : BITCODE_BD;
        end;
      Dwg_Entity_ARC = _dwg_entity_ARC;
      //PDwg_Entity_ARC = ^Dwg_Entity_ARC;

      //P_dwg_entity_CIRCLE = ^_dwg_entity_CIRCLE;
      _dwg_entity_CIRCLE = record
          parent : P_dwg_object_entity;
          center : BITCODE_3BD;
          radius : BITCODE_BD;
          thickness : BITCODE_BT;
          extrusion : BITCODE_BE;
        end;
      Dwg_Entity_CIRCLE = _dwg_entity_CIRCLE;
      //PDwg_Entity_CIRCLE = ^Dwg_Entity_CIRCLE;

      //P_dwg_entity_LINE = ^_dwg_entity_LINE;
      _dwg_entity_LINE = record
          parent : P_dwg_object_entity;
          z_is_zero : BITCODE_RC;
          start : BITCODE_3BD;
          &end : BITCODE_3BD;
          thickness : BITCODE_BT;
          extrusion : BITCODE_BE;
          unknown_r11 : BITCODE_2RD;
        end;
      Dwg_Entity_LINE = _dwg_entity_LINE;
      //PDwg_Entity_LINE = ^Dwg_Entity_LINE;

      //P_dwg_DIMENSION_common = ^_dwg_DIMENSION_common;
      _dwg_DIMENSION_common = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
        end;
      Dwg_DIMENSION_common = _dwg_DIMENSION_common;
      //PDwg_DIMENSION_common = ^Dwg_DIMENSION_common;

      //P_dwg_entity_DIMENSION_ORDINATE = ^_dwg_entity_DIMENSION_ORDINATE;
      _dwg_entity_DIMENSION_ORDINATE = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          feature_location_pt : BITCODE_3BD;
          leader_endpt : BITCODE_3BD;
          flag2 : BITCODE_RC;
        end;
      Dwg_Entity_DIMENSION_ORDINATE = _dwg_entity_DIMENSION_ORDINATE;
      //PDwg_Entity_DIMENSION_ORDINATE = ^Dwg_Entity_DIMENSION_ORDINATE;

      //P_dwg_entity_DIMENSION_LINEAR = ^_dwg_entity_DIMENSION_LINEAR;
      _dwg_entity_DIMENSION_LINEAR = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          xline1_pt : BITCODE_3BD;
          xline2_pt : BITCODE_3BD;
          oblique_angle : BITCODE_BD;
          dim_rotation : BITCODE_BD;
        end;
      Dwg_Entity_DIMENSION_LINEAR = _dwg_entity_DIMENSION_LINEAR;
      //PDwg_Entity_DIMENSION_LINEAR = ^Dwg_Entity_DIMENSION_LINEAR;

      //P_dwg_entity_DIMENSION_ALIGNED = ^_dwg_entity_DIMENSION_ALIGNED;
      _dwg_entity_DIMENSION_ALIGNED = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          xline1_pt : BITCODE_3BD;
          xline2_pt : BITCODE_3BD;
          oblique_angle : BITCODE_BD;
        end;
      Dwg_Entity_DIMENSION_ALIGNED = _dwg_entity_DIMENSION_ALIGNED;
      //PDwg_Entity_DIMENSION_ALIGNED = ^Dwg_Entity_DIMENSION_ALIGNED;

      //P_dwg_entity_DIMENSION_ANG3PT = ^_dwg_entity_DIMENSION_ANG3PT;
      _dwg_entity_DIMENSION_ANG3PT = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          xline1_pt : BITCODE_3BD;
          xline2_pt : BITCODE_3BD;
          center_pt : BITCODE_3BD;
        end;
      Dwg_Entity_DIMENSION_ANG3PT = _dwg_entity_DIMENSION_ANG3PT;
      //PDwg_Entity_DIMENSION_ANG3PT = ^Dwg_Entity_DIMENSION_ANG3PT;

      //P_dwg_entity_DIMENSION_ANG2LN = ^_dwg_entity_DIMENSION_ANG2LN;
      _dwg_entity_DIMENSION_ANG2LN = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          xline1start_pt : BITCODE_3BD;
          xline1end_pt : BITCODE_3BD;
          xline2start_pt : BITCODE_3BD;
          xline2end_pt : BITCODE_3BD;
        end;
      Dwg_Entity_DIMENSION_ANG2LN = _dwg_entity_DIMENSION_ANG2LN;
      //PDwg_Entity_DIMENSION_ANG2LN = ^Dwg_Entity_DIMENSION_ANG2LN;

      //P_dwg_entity_DIMENSION_RADIUS = ^_dwg_entity_DIMENSION_RADIUS;
      _dwg_entity_DIMENSION_RADIUS = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          first_arc_pt : BITCODE_3BD;
          leader_len : BITCODE_BD;
        end;
      Dwg_Entity_DIMENSION_RADIUS = _dwg_entity_DIMENSION_RADIUS;
      //PDwg_Entity_DIMENSION_RADIUS = ^Dwg_Entity_DIMENSION_RADIUS;

      //P_dwg_entity_DIMENSION_DIAMETER = ^_dwg_entity_DIMENSION_DIAMETER;
      _dwg_entity_DIMENSION_DIAMETER = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          first_arc_pt : BITCODE_3BD;
          leader_len : BITCODE_BD;
        end;
      Dwg_Entity_DIMENSION_DIAMETER = _dwg_entity_DIMENSION_DIAMETER;
      //PDwg_Entity_DIMENSION_DIAMETER = ^Dwg_Entity_DIMENSION_DIAMETER;

      //P_dwg_entity_ARC_DIMENSION = ^_dwg_entity_ARC_DIMENSION;
      _dwg_entity_ARC_DIMENSION = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          xline1_pt : BITCODE_3BD;
          xline2_pt : BITCODE_3BD;
          center_pt : BITCODE_3BD;
          is_partial : BITCODE_B;
          arc_start_param : BITCODE_BD;
          arc_end_param : BITCODE_BD;
          has_leader : BITCODE_B;
          leader1_pt : BITCODE_3BD;
          leader2_pt : BITCODE_3BD;
        end;
      Dwg_Entity_ARC_DIMENSION = _dwg_entity_ARC_DIMENSION;
      //PDwg_Entity_ARC_DIMENSION = ^Dwg_Entity_ARC_DIMENSION;

      //P_dwg_entity_LARGE_RADIAL_DIMENSION = ^_dwg_entity_LARGE_RADIAL_DIMENSION;
      _dwg_entity_LARGE_RADIAL_DIMENSION = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_RC;
          extrusion : BITCODE_BE;
          def_pt : BITCODE_3BD;
          text_midpt : BITCODE_2RD;
          elevation : BITCODE_BD;
          flag : BITCODE_RC;
          flag1 : BITCODE_RC;
          user_text : BITCODE_TV;
          text_rotation : BITCODE_BD;
          horiz_dir : BITCODE_BD;
          ins_scale : BITCODE_3BD;
          ins_rotation : BITCODE_BD;
          attachment : BITCODE_BS;
          lspace_style : BITCODE_BS;
          lspace_factor : BITCODE_BD;
          act_measurement : BITCODE_BD;
          unknown : BITCODE_B;
          flip_arrow1 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          clone_ins_pt : BITCODE_2RD;
          dimstyle : BITCODE_H;
          block : BITCODE_H;
          first_arc_pt : BITCODE_3BD;
          leader_len : BITCODE_BD;
          ovr_center : BITCODE_3BD;
          jog_point : BITCODE_3BD;
        end;
      Dwg_Entity_LARGE_RADIAL_DIMENSION = _dwg_entity_LARGE_RADIAL_DIMENSION;
      //PDwg_Entity_LARGE_RADIAL_DIMENSION = ^Dwg_Entity_LARGE_RADIAL_DIMENSION;

      //P_dwg_entity_POINT = ^_dwg_entity_POINT;
      _dwg_entity_POINT = record
          parent : P_dwg_object_entity;
          x : BITCODE_BD;
          y : BITCODE_BD;
          z : BITCODE_BD;
          thickness : BITCODE_BT;
          extrusion : BITCODE_BE;
          x_ang : BITCODE_BD;
        end;
      Dwg_Entity_POINT = _dwg_entity_POINT;
      //PDwg_Entity_POINT = ^Dwg_Entity_POINT;

      //P_dwg_entity_3DFACE = ^_dwg_entity_3DFACE;
      _dwg_entity_3DFACE = record
          parent : P_dwg_object_entity;
          has_no_flags : BITCODE_B;
          z_is_zero : BITCODE_B;
          corner1 : BITCODE_3BD;
          corner2 : BITCODE_3BD;
          corner3 : BITCODE_3BD;
          corner4 : BITCODE_3BD;
          invis_flags : BITCODE_BS;
        end;
      Dwg_Entity__3DFACE = _dwg_entity_3DFACE;
      //PDwg_Entity__3DFACE = ^Dwg_Entity__3DFACE;

      //P_dwg_entity_POLYLINE_PFACE = ^_dwg_entity_POLYLINE_PFACE;
      _dwg_entity_POLYLINE_PFACE = record
          parent : P_dwg_object_entity;
          has_vertex : BITCODE_B;
          num_owned : BITCODE_BL;
          first_vertex : BITCODE_H;
          last_vertex : BITCODE_H;
          vertex : PBITCODE_H;
          seqend : BITCODE_H;
          numverts : BITCODE_BS;
          numfaces : BITCODE_BS;
        end;
      Dwg_Entity_POLYLINE_PFACE = _dwg_entity_POLYLINE_PFACE;
      //PDwg_Entity_POLYLINE_PFACE = ^Dwg_Entity_POLYLINE_PFACE;

      //P_dwg_entity_POLYLINE_MESH = ^_dwg_entity_POLYLINE_MESH;
      _dwg_entity_POLYLINE_MESH = record
          parent : P_dwg_object_entity;
          has_vertex : BITCODE_B;
          num_owned : BITCODE_BL;
          first_vertex : BITCODE_H;
          last_vertex : BITCODE_H;
          vertex : PBITCODE_H;
          seqend : BITCODE_H;
          flag : BITCODE_BS;
          curve_type : BITCODE_BS;
          num_m_verts : BITCODE_BS;
          num_n_verts : BITCODE_BS;
          m_density : BITCODE_BS;
          n_density : BITCODE_BS;
        end;
      Dwg_Entity_POLYLINE_MESH = _dwg_entity_POLYLINE_MESH;
      //PDwg_Entity_POLYLINE_MESH = ^Dwg_Entity_POLYLINE_MESH;

      //P_dwg_entity_SOLID = ^_dwg_entity_SOLID;
      _dwg_entity_SOLID = record
          parent : P_dwg_object_entity;
          thickness : BITCODE_BT;
          elevation : BITCODE_BD;
          corner1 : BITCODE_2RD;
          corner2 : BITCODE_2RD;
          corner3 : BITCODE_2RD;
          corner4 : BITCODE_2RD;
          extrusion : BITCODE_BE;
        end;
      Dwg_Entity_SOLID = _dwg_entity_SOLID;
      //PDwg_Entity_SOLID = ^Dwg_Entity_SOLID;

      //P_dwg_entity_TRACE = ^_dwg_entity_TRACE;
      _dwg_entity_TRACE = record
          parent : P_dwg_object_entity;
          thickness : BITCODE_BT;
          elevation : BITCODE_BD;
          corner1 : BITCODE_2RD;
          corner2 : BITCODE_2RD;
          corner3 : BITCODE_2RD;
          corner4 : BITCODE_2RD;
          extrusion : BITCODE_BE;
        end;
      Dwg_Entity_TRACE = _dwg_entity_TRACE;
      //PDwg_Entity_TRACE = ^Dwg_Entity_TRACE;

      //P_dwg_entity_SHAPE = ^_dwg_entity_SHAPE;
      _dwg_entity_SHAPE = record
          parent : P_dwg_object_entity;
          ins_pt : BITCODE_3BD;
          scale : BITCODE_BD;
          rotation : BITCODE_BD;
          width_factor : BITCODE_BD;
          oblique_angle : BITCODE_BD;
          thickness : BITCODE_BD;
          style_id : BITCODE_BS;
          extrusion : BITCODE_BE;
          style : BITCODE_H;
        end;
      Dwg_Entity_SHAPE = _dwg_entity_SHAPE;
      //PDwg_Entity_SHAPE = ^Dwg_Entity_SHAPE;

      //P_dwg_entity_VIEWPORT = ^_dwg_entity_VIEWPORT;
      _dwg_entity_VIEWPORT = record
          parent : P_dwg_object_entity;
          center : BITCODE_3BD;
          width : BITCODE_BD;
          height : BITCODE_BD;
          on_off : BITCODE_RS;
          id : BITCODE_RS;
          view_target : BITCODE_3BD;
          VIEWDIR : BITCODE_3BD;
          twist_angle : BITCODE_BD;
          VIEWSIZE : BITCODE_BD;
          lens_length : BITCODE_BD;
          front_clip_z : BITCODE_BD;
          back_clip_z : BITCODE_BD;
          SNAPANG : BITCODE_BD;
          VIEWCTR : BITCODE_2RD;
          SNAPBASE : BITCODE_2RD;
          SNAPUNIT : BITCODE_2RD;
          GRIDUNIT : BITCODE_2RD;
          circle_zoom : BITCODE_BS;
          grid_major : BITCODE_BS;
          num_frozen_layers : BITCODE_BL;
          status_flag : BITCODE_BL;
          style_sheet : BITCODE_TV;
          render_mode : BITCODE_RC;
          ucs_at_origin : BITCODE_B;
          UCSVP : BITCODE_B;
          ucsorg : BITCODE_3BD;
          ucsxdir : BITCODE_3BD;
          ucsydir : BITCODE_3BD;
          ucs_elevation : BITCODE_BD;
          UCSORTHOVIEW : BITCODE_BS;
          shadeplot_mode : BITCODE_BS;
          use_default_lights : BITCODE_B;
          default_lighting_type : BITCODE_RC;
          brightness : BITCODE_BD;
          contrast : BITCODE_BD;
          ambient_color : BITCODE_CMC;
          vport_entity_header : BITCODE_H;
          frozen_layers : PBITCODE_H;
          clip_boundary : BITCODE_H;
          named_ucs : BITCODE_H;
          base_ucs : BITCODE_H;
          background : BITCODE_H;
          visualstyle : BITCODE_H;
          shadeplot : BITCODE_H;
          sun : BITCODE_H;
        end;
      Dwg_Entity_VIEWPORT = _dwg_entity_VIEWPORT;
      //PDwg_Entity_VIEWPORT = ^Dwg_Entity_VIEWPORT;

      //P_dwg_entity_ELLIPSE = ^_dwg_entity_ELLIPSE;
      _dwg_entity_ELLIPSE = record
          parent : P_dwg_object_entity;
          center : BITCODE_3BD;
          sm_axis : BITCODE_3BD;
          extrusion : BITCODE_BE;
          axis_ratio : BITCODE_BD;
          start_angle : BITCODE_BD;
          end_angle : BITCODE_BD;
        end;
      Dwg_Entity_ELLIPSE = _dwg_entity_ELLIPSE;
      //PDwg_Entity_ELLIPSE = ^Dwg_Entity_ELLIPSE;

      //P_dwg_SPLINE_control_point = ^_dwg_SPLINE_control_point;
      _dwg_SPLINE_control_point = record
          parent : P_dwg_entity_SPLINE;
          x : double;
          y : double;
          z : double;
          w : double;
        end;
      Dwg_SPLINE_control_point = _dwg_SPLINE_control_point;
      //PDwg_SPLINE_control_point = ^Dwg_SPLINE_control_point;

      //P_dwg_entity_SPLINE = ^_dwg_entity_SPLINE;
      _dwg_entity_SPLINE = record
          parent : P_dwg_object_entity;
          flag : BITCODE_RS;
          scenario : BITCODE_BS;
          degree : BITCODE_BS;
          splineflags1 : BITCODE_BL;
          knotparam : BITCODE_BL;
          fit_tol : BITCODE_BD;
          beg_tan_vec : BITCODE_3BD;
          end_tan_vec : BITCODE_3BD;
          closed_b : BITCODE_B;
          periodic : BITCODE_B;
          rational : BITCODE_B;
          weighted : BITCODE_B;
          knot_tol : BITCODE_BD;
          ctrl_tol : BITCODE_BD;
          num_fit_pts : BITCODE_BS;
          fit_pts : PBITCODE_3DPOINT;
          num_knots : BITCODE_BL;
          knots : PBITCODE_BD;
          num_ctrl_pts : BITCODE_BL;
          ctrl_pts : PDwg_SPLINE_control_point;
        end;
      Dwg_Entity_SPLINE = _dwg_entity_SPLINE;
      //PDwg_Entity_SPLINE = ^Dwg_Entity_SPLINE;

      //P_dwg_3DSOLID_wire = ^_dwg_3DSOLID_wire;
      _dwg_3DSOLID_wire = record
          parent : P_dwg_entity_3DSOLID;
          _type : BITCODE_RC;
          selection_marker : BITCODE_BLd;
          color : BITCODE_BL;
          acis_index : BITCODE_BLd;
          num_points : BITCODE_BL;
          points : PBITCODE_3BD;
          transform_present : BITCODE_B;
          axis_x : BITCODE_3BD;
          axis_y : BITCODE_3BD;
          axis_z : BITCODE_3BD;
          translation : BITCODE_3BD;
          scale : BITCODE_3BD;
          has_rotation : BITCODE_B;
          has_reflection : BITCODE_B;
          has_shear : BITCODE_B;
        end;
      Dwg_3DSOLID_wire = _dwg_3DSOLID_wire;
      //PDwg_3DSOLID_wire = ^Dwg_3DSOLID_wire;

      //P_dwg_3DSOLID_silhouette = ^_dwg_3DSOLID_silhouette;
      _dwg_3DSOLID_silhouette = record
          parent : P_dwg_entity_3DSOLID;
          vp_id : BITCODE_BL;
          vp_target : BITCODE_3BD;
          vp_dir_from_target : BITCODE_3BD;
          vp_up_dir : BITCODE_3BD;
          vp_perspective : BITCODE_B;
          has_wires : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
        end;
      Dwg_3DSOLID_silhouette = _dwg_3DSOLID_silhouette;
      //PDwg_3DSOLID_silhouette = ^Dwg_3DSOLID_silhouette;

      //P_dwg_3DSOLID_material = ^_dwg_3DSOLID_material;
      _dwg_3DSOLID_material = record
          parent : P_dwg_entity_3DSOLID;
          array_index : BITCODE_BL;
          mat_absref : BITCODE_BL;
          material_handle : BITCODE_H;
        end;
      Dwg_3DSOLID_material = _dwg_3DSOLID_material;
      //PDwg_3DSOLID_material = ^Dwg_3DSOLID_material;

      //P_dwg_entity_3DSOLID = ^_dwg_entity_3DSOLID;
      _dwg_entity_3DSOLID = record
          parent : P_dwg_object_entity;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
        end;
      Dwg_Entity__3DSOLID = _dwg_entity_3DSOLID;
      //PDwg_Entity__3DSOLID = ^Dwg_Entity__3DSOLID;

      //PDwg_Entity_REGION = ^Dwg_Entity_REGION;
      Dwg_Entity_REGION = Dwg_Entity__3DSOLID;

      //PDwg_Entity_BODY = ^Dwg_Entity_BODY;
      Dwg_Entity_BODY = Dwg_Entity__3DSOLID;

      //P_dwg_entity_RAY = ^_dwg_entity_RAY;
      _dwg_entity_RAY = record
          parent : P_dwg_object_entity;
          point : BITCODE_3BD;
          vector : BITCODE_3BD;
        end;
      Dwg_Entity_RAY = _dwg_entity_RAY;
      //PDwg_Entity_RAY = ^Dwg_Entity_RAY;

      //PDwg_Entity_XLINE = ^Dwg_Entity_XLINE;
      Dwg_Entity_XLINE = Dwg_Entity_RAY;

      //P_dwg_object_DICTIONARY = ^_dwg_object_DICTIONARY;
      _dwg_object_DICTIONARY = record
          parent : P_dwg_object_object;
          numitems : BITCODE_BL;
          is_hardowner : BITCODE_RC;
          cloning : BITCODE_BS;
          texts : PBITCODE_TV;
          itemhandles : PBITCODE_H;
          cloning_r14 : BITCODE_RC;
        end;
      Dwg_Object_DICTIONARY = _dwg_object_DICTIONARY;
      //PDwg_Object_DICTIONARY = ^Dwg_Object_DICTIONARY;

      //P_dwg_object_DICTIONARYWDFLT = ^_dwg_object_DICTIONARYWDFLT;
      _dwg_object_DICTIONARYWDFLT = record
          parent : P_dwg_object_object;
          numitems : BITCODE_BL;
          is_hardowner : BITCODE_RC;
          cloning : BITCODE_BS;
          texts : PBITCODE_TV;
          itemhandles : PBITCODE_H;
          cloning_r14 : BITCODE_RL;
          defaultid : BITCODE_H;
        end;
      Dwg_Object_DICTIONARYWDFLT = _dwg_object_DICTIONARYWDFLT;
      //PDwg_Object_DICTIONARYWDFLT = ^Dwg_Object_DICTIONARYWDFLT;

      //P_dwg_entity_OLEFRAME = ^_dwg_entity_OLEFRAME;
      _dwg_entity_OLEFRAME = record
          parent : P_dwg_object_entity;
          flag : BITCODE_BS;
          mode : BITCODE_BS;
          data_size : BITCODE_BL;
          data : BITCODE_TF;
        end;
      Dwg_Entity_OLEFRAME = _dwg_entity_OLEFRAME;
      //PDwg_Entity_OLEFRAME = ^Dwg_Entity_OLEFRAME;

      //P_dwg_entity_MTEXT = ^_dwg_entity_MTEXT;
      _dwg_entity_MTEXT = record
          parent : P_dwg_object_entity;
          ins_pt : BITCODE_3BD;
          extrusion : BITCODE_BE;
          x_axis_dir : BITCODE_3BD;
          rect_height : BITCODE_BD;
          rect_width : BITCODE_BD;
          text_height : BITCODE_BD;
          attachment : BITCODE_BS;
          flow_dir : BITCODE_BS;
          extents_width : BITCODE_BD;
          extents_height : BITCODE_BD;
          text : BITCODE_TV;
          style : BITCODE_H;
          linespace_style : BITCODE_BS;
          linespace_factor : BITCODE_BD;
          unknown_b0 : BITCODE_B;
          bg_fill_flag : BITCODE_BL;
          bg_fill_scale : BITCODE_BL;
          bg_fill_color : BITCODE_CMC;
          bg_fill_trans : BITCODE_BL;
          is_not_annotative : BITCODE_B;
          class_version : BITCODE_BS;
          default_flag : BITCODE_B;
          appid : BITCODE_H;
          ignore_attachment : BITCODE_BL;
          column_type : BITCODE_BS;
          numfragments : BITCODE_BL;
          column_width : BITCODE_BD;
          gutter : BITCODE_BD;
          auto_height : BITCODE_B;
          flow_reversed : BITCODE_B;
          num_column_heights : BITCODE_BL;
          column_heights : PBITCODE_BD;
        end;
      Dwg_Entity_MTEXT = _dwg_entity_MTEXT;
      //PDwg_Entity_MTEXT = ^Dwg_Entity_MTEXT;

      //P_dwg_entity_LEADER = ^_dwg_entity_LEADER;
      _dwg_entity_LEADER = record
          parent : P_dwg_object_entity;
          unknown_bit_1 : BITCODE_B;
          path_type : BITCODE_BS;
          annot_type : BITCODE_BS;
          num_points : BITCODE_BL;
          points : PBITCODE_3DPOINT;
          origin : BITCODE_3DPOINT;
          extrusion : BITCODE_BE;
          x_direction : BITCODE_3DPOINT;
          inspt_offset : BITCODE_3DPOINT;
          endptproj : BITCODE_3DPOINT;
          dimgap : BITCODE_BD;
          box_height : BITCODE_BD;
          box_width : BITCODE_BD;
          hookline_dir : BITCODE_B;
          arrowhead_on : BITCODE_B;
          arrowhead_type : BITCODE_BS;
          dimasz : BITCODE_BD;
          unknown_bit_2 : BITCODE_B;
          unknown_bit_3 : BITCODE_B;
          unknown_short_1 : BITCODE_BS;
          byblock_color : BITCODE_BS;
          hookline_on : BITCODE_B;
          unknown_bit_5 : BITCODE_B;
          associated_annotation : BITCODE_H;
          dimstyle : BITCODE_H;
        end;
      Dwg_Entity_LEADER = _dwg_entity_LEADER;
      //PDwg_Entity_LEADER = ^Dwg_Entity_LEADER;

      //P_dwg_entity_TOLERANCE = ^_dwg_entity_TOLERANCE;
      _dwg_entity_TOLERANCE = record
          parent : P_dwg_object_entity;
          unknown_short : BITCODE_BS;
          height : BITCODE_BD;
          dimgap : BITCODE_BD;
          ins_pt : BITCODE_3BD;
          x_direction : BITCODE_3BD;
          extrusion : BITCODE_BE;
          text_value : BITCODE_TV;
          dimstyle : BITCODE_H;
        end;
      Dwg_Entity_TOLERANCE = _dwg_entity_TOLERANCE;
      //PDwg_Entity_TOLERANCE = ^Dwg_Entity_TOLERANCE;

      //P_dwg_MLINE_line = ^_dwg_MLINE_line;
      _dwg_MLINE_line = record
          parent : P_dwg_MLINE_vertex;
          num_segparms : BITCODE_BS;
          segparms : PBITCODE_BD;
          num_areafillparms : BITCODE_BS;
          areafillparms : PBITCODE_BD;
        end;
      Dwg_MLINE_line = _dwg_MLINE_line;
      //PDwg_MLINE_line = ^Dwg_MLINE_line;

      //P_dwg_MLINE_vertex = ^_dwg_MLINE_vertex;
      _dwg_MLINE_vertex = record
          parent : P_dwg_entity_MLINE;
          vertex : BITCODE_3BD;
          vertex_direction : BITCODE_3BD;
          miter_direction : BITCODE_3BD;
          num_lines : BITCODE_RC;
          lines : PDwg_MLINE_line;
        end;
      Dwg_MLINE_vertex = _dwg_MLINE_vertex;
      //PDwg_MLINE_vertex = ^Dwg_MLINE_vertex;

      //P_dwg_entity_MLINE = ^_dwg_entity_MLINE;
      _dwg_entity_MLINE = record
          parent : P_dwg_object_entity;
          scale : BITCODE_BD;
          justification : BITCODE_RC;
          base_point : BITCODE_3BD;
          extrusion : BITCODE_BE;
          flags : BITCODE_BS;
          num_lines : BITCODE_RC;
          num_verts : BITCODE_BS;
          verts : PDwg_MLINE_vertex;
          mlinestyle : BITCODE_H;
        end;
      Dwg_Entity_MLINE = _dwg_entity_MLINE;
      //PDwg_Entity_MLINE = ^Dwg_Entity_MLINE;

      //P_dwg_object_BLOCK_CONTROL = ^_dwg_object_BLOCK_CONTROL;
      _dwg_object_BLOCK_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
          model_space : BITCODE_H;
          paper_space : BITCODE_H;
        end;
      Dwg_Object_BLOCK_CONTROL = _dwg_object_BLOCK_CONTROL;
      //PDwg_Object_BLOCK_CONTROL = ^Dwg_Object_BLOCK_CONTROL;

      //P_dwg_object_BLOCK_HEADER = ^_dwg_object_BLOCK_HEADER;
      _dwg_object_BLOCK_HEADER = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          __iterator : BITCODE_BL;
          flag2 : BITCODE_RC;
          anonymous : BITCODE_B;
          hasattrs : BITCODE_B;
          blkisxref : BITCODE_B;
          xrefoverlaid : BITCODE_B;
          loaded_bit : BITCODE_B;
          num_owned : BITCODE_BL;
          base_pt : BITCODE_3DPOINT;
          xref_pname : BITCODE_TV;
          num_inserts : BITCODE_RL;
          description : BITCODE_TV;
          preview_size : BITCODE_BL;
          preview : BITCODE_TF;
          insert_units : BITCODE_BS;
          explodable : BITCODE_B;
          block_scaling : BITCODE_RC;
          block_entity : BITCODE_H;
          first_entity : BITCODE_H;
          last_entity : BITCODE_H;
          entities : PBITCODE_H;
          endblk_entity : BITCODE_H;
          inserts : PBITCODE_H;
          layout : BITCODE_H;
          unknown_r11 : BITCODE_RS;
          unknown1_r11 : BITCODE_RS;
        end;
      Dwg_Object_BLOCK_HEADER = _dwg_object_BLOCK_HEADER;
      //PDwg_Object_BLOCK_HEADER = ^Dwg_Object_BLOCK_HEADER;

      //P_dwg_object_LAYER_CONTROL = ^_dwg_object_LAYER_CONTROL;
      _dwg_object_LAYER_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
        end;
      Dwg_Object_LAYER_CONTROL = _dwg_object_LAYER_CONTROL;
      //PDwg_Object_LAYER_CONTROL = ^Dwg_Object_LAYER_CONTROL;

      //P_dwg_object_LAYER = ^_dwg_object_LAYER;
      _dwg_object_LAYER = record
          parent : P_dwg_object_object;
          flag : BITCODE_BS;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          frozen : BITCODE_B;
          on : BITCODE_B;
          frozen_in_new : BITCODE_B;
          locked : BITCODE_B;
          plotflag : BITCODE_B;
          linewt : BITCODE_RC;
          color : BITCODE_CMC;
          plotstyle : BITCODE_H;
          material : BITCODE_H;
          ltype : BITCODE_H;
          visualstyle : BITCODE_H;
          unknown_r2 : BITCODE_RC;
        end;
      Dwg_Object_LAYER = _dwg_object_LAYER;
      //PDwg_Object_LAYER = ^Dwg_Object_LAYER;

      //P_dwg_object_STYLE_CONTROL = ^_dwg_object_STYLE_CONTROL;
      _dwg_object_STYLE_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
        end;
      Dwg_Object_STYLE_CONTROL = _dwg_object_STYLE_CONTROL;
      //PDwg_Object_STYLE_CONTROL = ^Dwg_Object_STYLE_CONTROL;

      //P_dwg_object_STYLE = ^_dwg_object_STYLE;
      _dwg_object_STYLE = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          is_shape : BITCODE_B;
          is_vertical : BITCODE_B;
          text_size : BITCODE_BD;
          width_factor : BITCODE_BD;
          oblique_angle : BITCODE_BD;
          generation : BITCODE_RC;
          last_height : BITCODE_BD;
          font_file : BITCODE_TV;
          bigfont_file : BITCODE_TV;
          unknown : BITCODE_RS;
        end;
      Dwg_Object_STYLE = _dwg_object_STYLE;
      //PDwg_Object_STYLE = ^Dwg_Object_STYLE;

      //P_dwg_object_LTYPE_CONTROL = ^_dwg_object_LTYPE_CONTROL;
      _dwg_object_LTYPE_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
          bylayer : BITCODE_H;
          byblock : BITCODE_H;
        end;
      Dwg_Object_LTYPE_CONTROL = _dwg_object_LTYPE_CONTROL;
      //PDwg_Object_LTYPE_CONTROL = ^Dwg_Object_LTYPE_CONTROL;

      //P_dwg_LTYPE_dash = ^_dwg_LTYPE_dash;
      _dwg_LTYPE_dash = record
          parent : P_dwg_object_LTYPE;
          length : BITCODE_BD;
          complex_shapecode : BITCODE_BS;
          style : BITCODE_H;
          x_offset : BITCODE_RD;
          y_offset : BITCODE_RD;
          scale : BITCODE_BD;
          rotation : BITCODE_BD;
          shape_flag : BITCODE_BS;
          text : BITCODE_TV;
        end;
      Dwg_LTYPE_dash = _dwg_LTYPE_dash;
      //PDwg_LTYPE_dash = ^Dwg_LTYPE_dash;

      //P_dwg_object_LTYPE = ^_dwg_object_LTYPE;
      _dwg_object_LTYPE = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          description : BITCODE_TV;
          pattern_len : BITCODE_BD;
          alignment : BITCODE_RC;
          num_dashes : BITCODE_RC;
          dashes : PDwg_LTYPE_dash;
          dashes_r11 : array[0..11] of BITCODE_RD;
          has_strings_area : BITCODE_B;
          strings_area : BITCODE_TF;
          unknown_r11 : BITCODE_RC;
        end;
      Dwg_Object_LTYPE = _dwg_object_LTYPE;
      //PDwg_Object_LTYPE = ^Dwg_Object_LTYPE;

      //P_dwg_object_VIEW_CONTROL = ^_dwg_object_VIEW_CONTROL;
      _dwg_object_VIEW_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
        end;
      Dwg_Object_VIEW_CONTROL = _dwg_object_VIEW_CONTROL;
      //PDwg_Object_VIEW_CONTROL = ^Dwg_Object_VIEW_CONTROL;

      //P_dwg_object_VIEW = ^_dwg_object_VIEW;
      _dwg_object_VIEW = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          VIEWSIZE : BITCODE_BD;
          view_width : BITCODE_BD;
          aspect_ratio : BITCODE_BD;
          VIEWCTR : BITCODE_2RD;
          view_target : BITCODE_3BD;
          VIEWDIR : BITCODE_3BD;
          twist_angle : BITCODE_BD;
          lens_length : BITCODE_BD;
          front_clip_z : BITCODE_BD;
          back_clip_z : BITCODE_BD;
          VIEWMODE : BITCODE_4BITS;
          render_mode : BITCODE_RC;
          use_default_lights : BITCODE_B;
          default_lightning_type : BITCODE_RC;
          brightness : BITCODE_BD;
          contrast : BITCODE_BD;
          ambient_color : BITCODE_CMC;
          is_pspace : BITCODE_B;
          associated_ucs : BITCODE_B;
          ucsorg : BITCODE_3BD;
          ucsxdir : BITCODE_3BD;
          ucsydir : BITCODE_3BD;
          ucs_elevation : BITCODE_BD;
          UCSORTHOVIEW : BITCODE_BS;
          is_camera_plottable : BITCODE_B;
          background : BITCODE_H;
          visualstyle : BITCODE_H;
          sun : BITCODE_H;
          base_ucs : BITCODE_H;
          named_ucs : BITCODE_H;
          livesection : BITCODE_H;
          flag_3d : BITCODE_RS;
          unknown_r2 : BITCODE_RC;
        end;
      Dwg_Object_VIEW = _dwg_object_VIEW;
      //PDwg_Object_VIEW = ^Dwg_Object_VIEW;

      //P_dwg_object_UCS_CONTROL = ^_dwg_object_UCS_CONTROL;
      _dwg_object_UCS_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
        end;
      Dwg_Object_UCS_CONTROL = _dwg_object_UCS_CONTROL;
      //PDwg_Object_UCS_CONTROL = ^Dwg_Object_UCS_CONTROL;

      //P_dwg_UCS_orthopts = ^_dwg_UCS_orthopts;
      _dwg_UCS_orthopts = record
          parent : P_dwg_object_UCS;
          _type : BITCODE_BS;
          pt : BITCODE_3BD;
        end;
      Dwg_UCS_orthopts = _dwg_UCS_orthopts;
      //PDwg_UCS_orthopts = ^Dwg_UCS_orthopts;

      //P_dwg_object_UCS = ^_dwg_object_UCS;
      _dwg_object_UCS = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          ucsorg : BITCODE_3BD;
          ucsxdir : BITCODE_3BD;
          ucsydir : BITCODE_3BD;
          ucs_elevation : BITCODE_BD;
          UCSORTHOVIEW : BITCODE_BS;
          base_ucs : BITCODE_H;
          named_ucs : BITCODE_H;
          num_orthopts : BITCODE_BS;
          orthopts : PDwg_UCS_orthopts;
        end;
      Dwg_Object_UCS = _dwg_object_UCS;
      //PDwg_Object_UCS = ^Dwg_Object_UCS;

      //P_dwg_object_VPORT_CONTROL = ^_dwg_object_VPORT_CONTROL;
      _dwg_object_VPORT_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
        end;
      Dwg_Object_VPORT_CONTROL = _dwg_object_VPORT_CONTROL;
      //PDwg_Object_VPORT_CONTROL = ^Dwg_Object_VPORT_CONTROL;

      //P_dwg_object_VPORT = ^_dwg_object_VPORT;
      _dwg_object_VPORT = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          VIEWSIZE : BITCODE_BD;
          view_width : BITCODE_BD;
          aspect_ratio : BITCODE_BD;
          VIEWCTR : BITCODE_2RD;
          view_target : BITCODE_3BD;
          VIEWDIR : BITCODE_3BD;
          view_twist : BITCODE_BD;
          lens_length : BITCODE_BD;
          front_clip_z : BITCODE_BD;
          back_clip_z : BITCODE_BD;
          VIEWMODE : BITCODE_4BITS;
          render_mode : BITCODE_RC;
          use_default_lights : BITCODE_B;
          default_lightning_type : BITCODE_RC;
          brightness : BITCODE_BD;
          contrast : BITCODE_BD;
          ambient_color : BITCODE_CMC;
          lower_left : BITCODE_2RD;
          upper_right : BITCODE_2RD;
          UCSFOLLOW : BITCODE_B;
          circle_zoom : BITCODE_BS;
          FASTZOOM : BITCODE_B;
          UCSICON : BITCODE_RC;
          GRIDMODE : BITCODE_B;
          GRIDUNIT : BITCODE_2RD;
          SNAPMODE : BITCODE_B;
          SNAPSTYLE : BITCODE_B;
          SNAPISOPAIR : BITCODE_BS;
          SNAPANG : BITCODE_BD;
          SNAPBASE : BITCODE_2RD;
          SNAPUNIT : BITCODE_2RD;
          ucs_at_origin : BITCODE_B;
          UCSVP : BITCODE_B;
          ucsorg : BITCODE_3BD;
          ucsxdir : BITCODE_3BD;
          ucsydir : BITCODE_3BD;
          ucs_elevation : BITCODE_BD;
          UCSORTHOVIEW : BITCODE_BS;
          grid_flags : BITCODE_BS;
          grid_major : BITCODE_BS;
          background : BITCODE_H;
          visualstyle : BITCODE_H;
          sun : BITCODE_H;
          named_ucs : BITCODE_H;
          base_ucs : BITCODE_H;
        end;
      Dwg_Object_VPORT = _dwg_object_VPORT;
      //PDwg_Object_VPORT = ^Dwg_Object_VPORT;

      //P_dwg_object_APPID_CONTROL = ^_dwg_object_APPID_CONTROL;
      _dwg_object_APPID_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
        end;
      Dwg_Object_APPID_CONTROL = _dwg_object_APPID_CONTROL;
      //PDwg_Object_APPID_CONTROL = ^Dwg_Object_APPID_CONTROL;

      //P_dwg_object_APPID = ^_dwg_object_APPID;
      _dwg_object_APPID = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          unknown : BITCODE_RC;
        end;
      Dwg_Object_APPID = _dwg_object_APPID;
      //PDwg_Object_APPID = ^Dwg_Object_APPID;

      //P_dwg_object_DIMSTYLE_CONTROL = ^_dwg_object_DIMSTYLE_CONTROL;
      _dwg_object_DIMSTYLE_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
          num_morehandles : BITCODE_RC;
          morehandles : PBITCODE_H;
        end;
      Dwg_Object_DIMSTYLE_CONTROL = _dwg_object_DIMSTYLE_CONTROL;
      //PDwg_Object_DIMSTYLE_CONTROL = ^Dwg_Object_DIMSTYLE_CONTROL;

      //P_dwg_object_DIMSTYLE = ^_dwg_object_DIMSTYLE;
      _dwg_object_DIMSTYLE = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          DIMTOL : BITCODE_B;
          DIMLIM : BITCODE_B;
          DIMTIH : BITCODE_B;
          DIMTOH : BITCODE_B;
          DIMSE1 : BITCODE_B;
          DIMSE2 : BITCODE_B;
          DIMALT : BITCODE_B;
          DIMTOFL : BITCODE_B;
          DIMSAH : BITCODE_B;
          DIMTIX : BITCODE_B;
          DIMSOXD : BITCODE_B;
          DIMALTD : BITCODE_BS;
          DIMZIN : BITCODE_BS;
          DIMSD1 : BITCODE_B;
          DIMSD2 : BITCODE_B;
          DIMTOLJ : BITCODE_BS;
          DIMJUST : BITCODE_BS;
          DIMFIT : BITCODE_BS;
          DIMUPT : BITCODE_B;
          DIMTZIN : BITCODE_BS;
          DIMMALTZ : BITCODE_BS;
          DIMMALTTZ : BITCODE_BS;
          DIMTAD : BITCODE_BS;
          DIMUNIT : BITCODE_BS;
          DIMAUNIT : BITCODE_BS;
          DIMDEC : BITCODE_BS;
          DIMTDEC : BITCODE_BS;
          DIMALTU : BITCODE_BS;
          DIMALTTD : BITCODE_BS;
          DIMSCALE : BITCODE_BD;
          DIMASZ : BITCODE_BD;
          DIMEXO : BITCODE_BD;
          DIMDLI : BITCODE_BD;
          DIMEXE : BITCODE_BD;
          DIMRND : BITCODE_BD;
          DIMDLE : BITCODE_BD;
          DIMTP : BITCODE_BD;
          DIMTM : BITCODE_BD;
          DIMFXL : BITCODE_BD;
          DIMJOGANG : BITCODE_BD;
          DIMTFILL : BITCODE_BS;
          DIMTFILLCLR : BITCODE_CMC;
          DIMAZIN : BITCODE_BS;
          DIMARCSYM : BITCODE_BS;
          DIMTXT : BITCODE_BD;
          DIMCEN : BITCODE_BD;
          DIMTSZ : BITCODE_BD;
          DIMALTF : BITCODE_BD;
          DIMLFAC : BITCODE_BD;
          DIMTVP : BITCODE_BD;
          DIMTFAC : BITCODE_BD;
          DIMGAP : BITCODE_BD;
          DIMPOST : BITCODE_TV;
          DIMAPOST : BITCODE_TV;
          DIMBLK_T : BITCODE_TV;
          DIMBLK1_T : BITCODE_TV;
          DIMBLK2_T : BITCODE_TV;
          DIMALTRND : BITCODE_BD;
          DIMCLRD_N : BITCODE_RS;
          DIMCLRE_N : BITCODE_RS;
          DIMCLRT_N : BITCODE_RS;
          DIMCLRD : BITCODE_CMC;
          DIMCLRE : BITCODE_CMC;
          DIMCLRT : BITCODE_CMC;
          DIMADEC : BITCODE_BS;
          DIMFRAC : BITCODE_BS;
          DIMLUNIT : BITCODE_BS;
          DIMDSEP : BITCODE_BS;
          DIMTMOVE : BITCODE_BS;
          DIMALTZ : BITCODE_BS;
          DIMALTTZ : BITCODE_BS;
          DIMATFIT : BITCODE_BS;
          DIMFXLON : BITCODE_B;
          DIMTXTDIRECTION : BITCODE_B;
          DIMALTMZF : BITCODE_BD;
          DIMALTMZS : BITCODE_TV;
          DIMMZF : BITCODE_BD;
          DIMMZS : BITCODE_TV;
          DIMLWD : BITCODE_BSd;
          DIMLWE : BITCODE_BSd;
          flag0 : BITCODE_B;
          DIMTXSTY : BITCODE_H;
          DIMLDRBLK : BITCODE_H;
          DIMBLK : BITCODE_H;
          DIMBLK1 : BITCODE_H;
          DIMBLK2 : BITCODE_H;
          DIMLTYPE : BITCODE_H;
          DIMLTEX1 : BITCODE_H;
          DIMLTEX2 : BITCODE_H;
        end;
      Dwg_Object_DIMSTYLE = _dwg_object_DIMSTYLE;
      //PDwg_Object_DIMSTYLE = ^Dwg_Object_DIMSTYLE;

      //P_dwg_object_VX_CONTROL = ^_dwg_object_VX_CONTROL;
      _dwg_object_VX_CONTROL = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BS;
          entries : PBITCODE_H;
        end;
      Dwg_Object_VX_CONTROL = _dwg_object_VX_CONTROL;
      //PDwg_Object_VX_CONTROL = ^Dwg_Object_VX_CONTROL;

      //P_dwg_object_VX_TABLE_RECORD = ^_dwg_object_VX_TABLE_RECORD;
      _dwg_object_VX_TABLE_RECORD = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          name : BITCODE_TV;
          used : BITCODE_RSd;
          is_xref_ref : BITCODE_B;
          is_xref_resolved : BITCODE_BS;
          is_xref_dep : BITCODE_B;
          xref : BITCODE_H;
          is_on : BITCODE_B;
          viewport : BITCODE_H;
          prev_entry : BITCODE_H;
        end;
      Dwg_Object_VX_TABLE_RECORD = _dwg_object_VX_TABLE_RECORD;
      //PDwg_Object_VX_TABLE_RECORD = ^Dwg_Object_VX_TABLE_RECORD;

      //P_dwg_object_GROUP = ^_dwg_object_GROUP;
      _dwg_object_GROUP = record
          parent : P_dwg_object_object;
          name : BITCODE_TV;
          unnamed : BITCODE_BS;
          selectable : BITCODE_BS;
          num_groups : BITCODE_BL;
          groups : PBITCODE_H;
        end;
      Dwg_Object_GROUP = _dwg_object_GROUP;
      //PDwg_Object_GROUP = ^Dwg_Object_GROUP;

      //P_dwg_MLINESTYLE_line = ^_dwg_MLINESTYLE_line;
      _dwg_MLINESTYLE_line = record
          parent : P_dwg_object_MLINESTYLE;
          offset : BITCODE_BD;
          color : BITCODE_CMC;
          lt_index : BITCODE_BSd;
          lt_ltype : BITCODE_H;
        end;
      Dwg_MLINESTYLE_line = _dwg_MLINESTYLE_line;
      //PDwg_MLINESTYLE_line = ^Dwg_MLINESTYLE_line;

      //P_dwg_object_MLINESTYLE = ^_dwg_object_MLINESTYLE;
      _dwg_object_MLINESTYLE = record
          parent : P_dwg_object_object;
          name : BITCODE_TV;
          description : BITCODE_TV;
          flag : BITCODE_BS;
          fill_color : BITCODE_CMC;
          start_angle : BITCODE_BD;
          end_angle : BITCODE_BD;
          num_lines : BITCODE_RC;
          lines : PDwg_MLINESTYLE_line;
        end;
      Dwg_Object_MLINESTYLE = _dwg_object_MLINESTYLE;
      //PDwg_Object_MLINESTYLE = ^Dwg_Object_MLINESTYLE;

      //P_dwg_entity_OLE2FRAME = ^_dwg_entity_OLE2FRAME;
      _dwg_entity_OLE2FRAME = record
          parent : P_dwg_object_entity;
          _type : BITCODE_BS;
          mode : BITCODE_BS;
          lock_aspect : BITCODE_RC;
          data_size : BITCODE_BL;
          data : BITCODE_TF;
          oleversion : BITCODE_BS;
          oleclient : BITCODE_TF;
          pt1 : BITCODE_3BD;
          pt2 : BITCODE_3BD;
        end;
      Dwg_Entity_OLE2FRAME = _dwg_entity_OLE2FRAME;
      //PDwg_Entity_OLE2FRAME = ^Dwg_Entity_OLE2FRAME;

      //P_dwg_object_DUMMY = ^_dwg_object_DUMMY;
      _dwg_object_DUMMY = record
          parent : P_dwg_object_object;
        end;
      Dwg_Object_DUMMY = _dwg_object_DUMMY;
      //PDwg_Object_DUMMY = ^Dwg_Object_DUMMY;

      //P_dwg_object_LONG_TRANSACTION = ^_dwg_object_LONG_TRANSACTION;
      _dwg_object_LONG_TRANSACTION = record
          parent : P_dwg_object_object;
        end;
      Dwg_Object_LONG_TRANSACTION = _dwg_object_LONG_TRANSACTION;
      //PDwg_Object_LONG_TRANSACTION = ^Dwg_Object_LONG_TRANSACTION;

      //P_dwg_LWPOLYLINE_width = ^_dwg_LWPOLYLINE_width;
      _dwg_LWPOLYLINE_width = record
          start : BITCODE_BD;
          &end : BITCODE_BD;
        end;
      Dwg_LWPOLYLINE_width = _dwg_LWPOLYLINE_width;
      //PDwg_LWPOLYLINE_width = ^Dwg_LWPOLYLINE_width;

      //P_dwg_PROXY_LWPOLYLINE = ^_dwg_PROXY_LWPOLYLINE;
      _dwg_PROXY_LWPOLYLINE = record
          parent : P_dwg_entity_PROXY_ENTITY;
          size : BITCODE_RL;
          flags : BITCODE_BS;
          const_width : BITCODE_BD;
          elevation : BITCODE_BD;
          thickness : BITCODE_BD;
          extrusion : BITCODE_BE;
          num_points : BITCODE_BL;
          points : PBITCODE_2RD;
          num_bulges : BITCODE_BL;
          bulges : PBITCODE_BD;
          num_widths : BITCODE_BL;
          widths : PDwg_LWPOLYLINE_width;
          unknown_1 : BITCODE_RC;
          unknown_2 : BITCODE_RC;
          unknown_3 : BITCODE_RC;
        end;
      Dwg_PROXY_LWPOLYLINE = _dwg_PROXY_LWPOLYLINE;
      //PDwg_PROXY_LWPOLYLINE = ^Dwg_PROXY_LWPOLYLINE;

      //P_dwg_entity_PROXY_ENTITY = ^_dwg_entity_PROXY_ENTITY;
      _dwg_entity_PROXY_ENTITY = record
          parent : P_dwg_object_entity;
          class_id : BITCODE_BL;
          version : BITCODE_BL;
          maint_version : BITCODE_BL;
          from_dxf : BITCODE_B;
          data_numbits : BITCODE_BL;
          data_size : BITCODE_BL;
          data : PBITCODE_RC;
          num_objids : BITCODE_BL;
          objids : PBITCODE_H;
        end;
      Dwg_Entity_PROXY_ENTITY = _dwg_entity_PROXY_ENTITY;
      //PDwg_Entity_PROXY_ENTITY = ^Dwg_Entity_PROXY_ENTITY;

      //P_dwg_object_PROXY_OBJECT = ^_dwg_object_PROXY_OBJECT;
      _dwg_object_PROXY_OBJECT = record
          parent : P_dwg_object_object;
          class_id : BITCODE_BL;
          version : BITCODE_BL;
          maint_version : BITCODE_BL;
          from_dxf : BITCODE_B;
          data_numbits : BITCODE_BL;
          data_size : BITCODE_BL;
          data : PBITCODE_RC;
          num_objids : BITCODE_BL;
          objids : PBITCODE_H;
        end;
      Dwg_Object_PROXY_OBJECT = _dwg_object_PROXY_OBJECT;
      //PDwg_Object_PROXY_OBJECT = ^Dwg_Object_PROXY_OBJECT;

      //P_dwg_HATCH_Color = ^_dwg_HATCH_Color;
      _dwg_HATCH_Color = record
          parent : P_dwg_entity_HATCH;
          shift_value : BITCODE_BD;
          color : BITCODE_CMC;
        end;
      Dwg_HATCH_Color = _dwg_HATCH_Color;
      //PDwg_HATCH_Color = ^Dwg_HATCH_Color;

      //P_dwg_HATCH_ControlPoint = ^_dwg_HATCH_ControlPoint;
      _dwg_HATCH_ControlPoint = record
          parent : P_dwg_HATCH_PathSeg;
          point : BITCODE_2RD;
          weight : BITCODE_BD;
        end;
      Dwg_HATCH_ControlPoint = _dwg_HATCH_ControlPoint;
      //PDwg_HATCH_ControlPoint = ^Dwg_HATCH_ControlPoint;

      //P_dwg_HATCH_PathSeg = ^_dwg_HATCH_PathSeg;
      _dwg_HATCH_PathSeg = record
          parent : P_dwg_HATCH_Path;
          curve_type : BITCODE_RC;
          first_endpoint : BITCODE_2RD;
          second_endpoint : BITCODE_2RD;
          center : BITCODE_2RD;
          radius : BITCODE_BD;
          start_angle : BITCODE_BD;
          end_angle : BITCODE_BD;
          is_ccw : BITCODE_B;
          endpoint : BITCODE_2RD;
          minor_major_ratio : BITCODE_BD;
          degree : BITCODE_BL;
          is_rational : BITCODE_B;
          is_periodic : BITCODE_B;
          num_knots : BITCODE_BL;
          num_control_points : BITCODE_BL;
          knots : PBITCODE_BD;
          control_points : PDwg_HATCH_ControlPoint;
          num_fitpts : BITCODE_BL;
          fitpts : PBITCODE_2RD;
          start_tangent : BITCODE_2RD;
          end_tangent : BITCODE_2RD;
        end;
      Dwg_HATCH_PathSeg = _dwg_HATCH_PathSeg;
      //PDwg_HATCH_PathSeg = ^Dwg_HATCH_PathSeg;

      //P_dwg_HATCH_PolylinePath = ^_dwg_HATCH_PolylinePath;
      _dwg_HATCH_PolylinePath = record
          parent : P_dwg_HATCH_Path;
          point : BITCODE_2RD;
          bulge : BITCODE_BD;
        end;
      Dwg_HATCH_PolylinePath = _dwg_HATCH_PolylinePath;
      //PDwg_HATCH_PolylinePath = ^Dwg_HATCH_PolylinePath;

      //P_dwg_HATCH_Path = ^_dwg_HATCH_Path;
      _dwg_HATCH_Path = record
          parent : P_dwg_entity_HATCH;
          flag : BITCODE_BL;
          num_segs_or_paths : BITCODE_BL;
          segs : PDwg_HATCH_PathSeg;
          bulges_present : BITCODE_B;
          closed : BITCODE_B;
          polyline_paths : PDwg_HATCH_PolylinePath;
          num_boundary_handles : BITCODE_BL;
          boundary_handles : PBITCODE_H;
        end;
      Dwg_HATCH_Path = _dwg_HATCH_Path;
      //PDwg_HATCH_Path = ^Dwg_HATCH_Path;

      //P_dwg_HATCH_DefLine = ^_dwg_HATCH_DefLine;
      _dwg_HATCH_DefLine = record
          parent : P_dwg_entity_HATCH;
          angle : BITCODE_BD;
          pt0 : BITCODE_2BD;
          offset : BITCODE_2BD;
          num_dashes : BITCODE_BS;
          dashes : PBITCODE_BD;
        end;
      Dwg_HATCH_DefLine = _dwg_HATCH_DefLine;
      //PDwg_HATCH_DefLine = ^Dwg_HATCH_DefLine;

      //P_dwg_entity_HATCH = ^_dwg_entity_HATCH;
      _dwg_entity_HATCH = record
          parent : P_dwg_object_entity;
          is_gradient_fill : BITCODE_BL;
          reserved : BITCODE_BL;
          gradient_angle : BITCODE_BD;
          gradient_shift : BITCODE_BD;
          single_color_gradient : BITCODE_BL;
          gradient_tint : BITCODE_BD;
          num_colors : BITCODE_BL;
          colors : PDwg_HATCH_Color;
          gradient_name : BITCODE_TV;
          elevation : BITCODE_BD;
          extrusion : BITCODE_BE;
          name : BITCODE_TV;
          is_solid_fill : BITCODE_B;
          is_associative : BITCODE_B;
          num_paths : BITCODE_BL;
          paths : PDwg_HATCH_Path;
          style : BITCODE_BS;
          pattern_type : BITCODE_BS;
          angle : BITCODE_BD;
          scale_spacing : BITCODE_BD;
          double_flag : BITCODE_B;
          num_deflines : BITCODE_BS;
          deflines : PDwg_HATCH_DefLine;
          has_derived : BITCODE_B;
          pixel_size : BITCODE_BD;
          num_seeds : BITCODE_BL;
          seeds : PBITCODE_2RD;
        end;
      Dwg_Entity_HATCH = _dwg_entity_HATCH;
      //PDwg_Entity_HATCH = ^Dwg_Entity_HATCH;

      //P_dwg_entity_MPOLYGON = ^_dwg_entity_MPOLYGON;
      _dwg_entity_MPOLYGON = record
          parent : P_dwg_object_entity;
          is_gradient_fill : BITCODE_BL;
          reserved : BITCODE_BL;
          gradient_angle : BITCODE_BD;
          gradient_shift : BITCODE_BD;
          single_color_gradient : BITCODE_BL;
          gradient_tint : BITCODE_BD;
          num_colors : BITCODE_BL;
          colors : PDwg_HATCH_Color;
          gradient_name : BITCODE_TV;
          elevation : BITCODE_BD;
          extrusion : BITCODE_BE;
          name : BITCODE_TV;
          is_solid_fill : BITCODE_B;
          is_associative : BITCODE_B;
          num_paths : BITCODE_BL;
          paths : PDwg_HATCH_Path;
          style : BITCODE_BS;
          pattern_type : BITCODE_BS;
          angle : BITCODE_BD;
          scale_spacing : BITCODE_BD;
          double_flag : BITCODE_B;
          num_deflines : BITCODE_BS;
          deflines : PDwg_HATCH_DefLine;
          color : BITCODE_CMC;
          x_dir : BITCODE_2RD;
          num_boundary_handles : BITCODE_BL;
        end;
      Dwg_Entity_MPOLYGON = _dwg_entity_MPOLYGON;
      //PDwg_Entity_MPOLYGON = ^Dwg_Entity_MPOLYGON;

      //P_dwg_object_XRECORD = ^_dwg_object_XRECORD;
      _dwg_object_XRECORD = record
          parent : P_dwg_object_object;
          cloning : BITCODE_BS;
          xdata_size : BITCODE_BL;
          num_xdata : BITCODE_BL;
          xdata : PDwg_Resbuf;
          num_objid_handles : BITCODE_BL;
          objid_handles : PBITCODE_H;
        end;
      Dwg_Object_XRECORD = _dwg_object_XRECORD;
      //PDwg_Object_XRECORD = ^Dwg_Object_XRECORD;

      //P_dwg_object_PLACEHOLDER = ^_dwg_object_PLACEHOLDER;
      _dwg_object_PLACEHOLDER = record
          parent : P_dwg_object_object;
        end;
      Dwg_Object_PLACEHOLDER = _dwg_object_PLACEHOLDER;
      //PDwg_Object_PLACEHOLDER = ^Dwg_Object_PLACEHOLDER;

      //P_dwg_LEADER_Break = ^_dwg_LEADER_Break;
      _dwg_LEADER_Break = record
          parent : P_dwg_LEADER_Line;
          start : BITCODE_3BD;
          &end : BITCODE_3BD;
        end;
      Dwg_LEADER_Break = _dwg_LEADER_Break;
      //PDwg_LEADER_Break = ^Dwg_LEADER_Break;

      //P_dwg_LEADER_Line = ^_dwg_LEADER_Line;
      _dwg_LEADER_Line = record
          parent : P_dwg_LEADER_Node;
          num_points : BITCODE_BL;
          points : PBITCODE_3DPOINT;
          num_breaks : BITCODE_BL;
          breaks : PDwg_LEADER_Break;
          line_index : BITCODE_BL;
          _type : BITCODE_BS;
          color : BITCODE_CMC;
          ltype : BITCODE_H;
          linewt : BITCODE_BLd;
          arrow_size : BITCODE_BD;
          arrow_handle : BITCODE_H;
          flags : BITCODE_BL;
        end;
      Dwg_LEADER_Line = _dwg_LEADER_Line;
      //PDwg_LEADER_Line = ^Dwg_LEADER_Line;

      //P_dwg_LEADER_ArrowHead = ^_dwg_LEADER_ArrowHead;
      _dwg_LEADER_ArrowHead = record
          parent : P_dwg_entity_MULTILEADER;
          is_default : BITCODE_B;
          arrowhead : BITCODE_H;
        end;
      Dwg_LEADER_ArrowHead = _dwg_LEADER_ArrowHead;
      //PDwg_LEADER_ArrowHead = ^Dwg_LEADER_ArrowHead;

      //P_dwg_LEADER_BlockLabel = ^_dwg_LEADER_BlockLabel;
      _dwg_LEADER_BlockLabel = record
          parent : P_dwg_entity_MULTILEADER;
          attdef : BITCODE_H;
          label_text : BITCODE_TV;
          ui_index : BITCODE_BS;
          width : BITCODE_BD;
        end;
      Dwg_LEADER_BlockLabel = _dwg_LEADER_BlockLabel;
      //PDwg_LEADER_BlockLabel = ^Dwg_LEADER_BlockLabel;

      //P_dwg_LEADER_Node = ^_dwg_LEADER_Node;
      _dwg_LEADER_Node = record
          parent : P_dwg_entity_MULTILEADER;
          has_lastleaderlinepoint : BITCODE_B;
          has_dogleg : BITCODE_B;
          lastleaderlinepoint : BITCODE_3BD;
          dogleg_vector : BITCODE_3BD;
          branch_index : BITCODE_BL;
          dogleg_length : BITCODE_BD;
          num_lines : BITCODE_BL;
          lines : PDwg_LEADER_Line;
          num_breaks : BITCODE_BL;
          breaks : PDwg_LEADER_Break;
          attach_dir : BITCODE_BS;
        end;
      Dwg_LEADER_Node = _dwg_LEADER_Node;
      //PDwg_LEADER_Node = ^Dwg_LEADER_Node;

      //P_dwg_MLEADER_Content_MText = ^_dwg_MLEADER_Content_MText;
      _dwg_MLEADER_Content_MText = record
          _type : BITCODE_RC;
          normal : BITCODE_3BD;
          location : BITCODE_3BD;
          rotation : BITCODE_BD;
          style : BITCODE_H;
          direction : BITCODE_3BD;
          color : BITCODE_CMC;
          width : BITCODE_BD;
          height : BITCODE_BD;
          line_spacing_factor : BITCODE_BD;
          default_text : BITCODE_TV;
          line_spacing_style : BITCODE_BS;
          alignment : BITCODE_BS;
          flow : BITCODE_BS;
          bg_color : BITCODE_CMC;
          bg_scale : BITCODE_BD;
          bg_transparency : BITCODE_BL;
          is_bg_fill : BITCODE_B;
          is_bg_mask_fill : BITCODE_B;
          col_type : BITCODE_BS;
          is_height_auto : BITCODE_B;
          col_width : BITCODE_BD;
          col_gutter : BITCODE_BD;
          is_col_flow_reversed : BITCODE_B;
          num_col_sizes : BITCODE_BL;
          col_sizes : PBITCODE_BD;
          word_break : BITCODE_B;
          unknown : BITCODE_B;
        end;
      Dwg_MLEADER_Content_MText = _dwg_MLEADER_Content_MText;
      //PDwg_MLEADER_Content_MText = ^Dwg_MLEADER_Content_MText;

      //P_dwg_MLEADER_Content_Block = ^_dwg_MLEADER_Content_Block;
      _dwg_MLEADER_Content_Block = record
          _type : BITCODE_RC;
          normal : BITCODE_3BD;
          location : BITCODE_3BD;
          rotation : BITCODE_BD;
          block_table : BITCODE_H;
          scale : BITCODE_3BD;
          color : BITCODE_CMC;
          transform : PBITCODE_BD;
        end;
      Dwg_MLEADER_Content_Block = _dwg_MLEADER_Content_Block;
      //PDwg_MLEADER_Content_Block = ^Dwg_MLEADER_Content_Block;

      //P_dwg_MLEADER_Content = ^_dwg_MLEADER_Content;
      _dwg_MLEADER_Content = record
          case longint of
            0 : ( txt : Dwg_MLEADER_Content_MText );
            1 : ( blk : Dwg_MLEADER_Content_Block );
          end;
      Dwg_MLEADER_Content = _dwg_MLEADER_Content;
      //PDwg_MLEADER_Content = ^Dwg_MLEADER_Content;

      //P_dwg_MLEADER_AnnotContext = ^_dwg_MLEADER_AnnotContext;
      _dwg_MLEADER_AnnotContext = record
          num_leaders : BITCODE_BL;
          leaders : PDwg_LEADER_Node;
          attach_dir : BITCODE_BS;
          scale_factor : BITCODE_BD;
          content_base : BITCODE_3BD;
          text_height : BITCODE_BD;
          arrow_size : BITCODE_BD;
          landing_gap : BITCODE_BD;
          text_left : BITCODE_BS;
          text_right : BITCODE_BS;
          text_angletype : BITCODE_BS;
          text_alignment : BITCODE_BS;
          has_content_txt : BITCODE_B;
          has_content_blk : BITCODE_B;
          content : Dwg_MLEADER_Content;
          base : BITCODE_3BD;
          base_dir : BITCODE_3BD;
          base_vert : BITCODE_3BD;
          is_normal_reversed : BITCODE_B;
          text_top : BITCODE_BS;
          text_bottom : BITCODE_BS;
        end;
      Dwg_MLEADER_AnnotContext = _dwg_MLEADER_AnnotContext;
      //PDwg_MLEADER_AnnotContext = ^Dwg_MLEADER_AnnotContext;

      //P_dwg_entity_MULTILEADER = ^_dwg_entity_MULTILEADER;
      _dwg_entity_MULTILEADER = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_BS;
          ctx : Dwg_MLEADER_AnnotContext;
          mleaderstyle : BITCODE_H;
          flags : BITCODE_BL;
          _type : BITCODE_BS;
          color : BITCODE_CMC;
          ltype : BITCODE_H;
          linewt : BITCODE_BLd;
          has_landing : BITCODE_B;
          has_dogleg : BITCODE_B;
          landing_dist : BITCODE_BD;
          arrow_handle : BITCODE_H;
          arrow_size : BITCODE_BD;
          style_content : BITCODE_BS;
          text_style : BITCODE_H;
          text_left : BITCODE_BS;
          text_right : BITCODE_BS;
          text_angletype : BITCODE_BS;
          text_alignment : BITCODE_BS;
          text_color : BITCODE_CMC;
          has_text_frame : BITCODE_B;
          block_style : BITCODE_H;
          block_color : BITCODE_CMC;
          block_scale : BITCODE_3BD;
          block_rotation : BITCODE_BD;
          style_attachment : BITCODE_BS;
          is_annotative : BITCODE_B;
          num_arrowheads : BITCODE_BL;
          arrowheads : PDwg_LEADER_ArrowHead;
          num_blocklabels : BITCODE_BL;
          blocklabels : PDwg_LEADER_BlockLabel;
          is_neg_textdir : BITCODE_B;
          ipe_alignment : BITCODE_BS;
          justification : BITCODE_BS;
          scale_factor : BITCODE_BD;
          attach_dir : BITCODE_BS;
          attach_top : BITCODE_BS;
          attach_bottom : BITCODE_BS;
          is_text_extended : BITCODE_B;
        end;
      Dwg_Entity_MULTILEADER = _dwg_entity_MULTILEADER;
      //PDwg_Entity_MULTILEADER = ^Dwg_Entity_MULTILEADER;

      //P_dwg_object_MLEADERSTYLE = ^_dwg_object_MLEADERSTYLE;
      _dwg_object_MLEADERSTYLE = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          content_type : BITCODE_BS;
          mleader_order : BITCODE_BS;
          leader_order : BITCODE_BS;
          max_points : BITCODE_BL;
          first_seg_angle : BITCODE_BD;
          second_seg_angle : BITCODE_BD;
          _type : BITCODE_BS;
          line_color : BITCODE_CMC;
          line_type : BITCODE_H;
          linewt : BITCODE_BLd;
          has_landing : BITCODE_B;
          has_dogleg : BITCODE_B;
          landing_gap : BITCODE_BD;
          landing_dist : BITCODE_BD;
          description : BITCODE_TV;
          arrow_head : BITCODE_H;
          arrow_head_size : BITCODE_BD;
          text_default : BITCODE_TV;
          text_style : BITCODE_H;
          attach_left : BITCODE_BS;
          attach_right : BITCODE_BS;
          text_angle_type : BITCODE_BS;
          text_align_type : BITCODE_BS;
          text_color : BITCODE_CMC;
          text_height : BITCODE_BD;
          has_text_frame : BITCODE_B;
          text_always_left : BITCODE_B;
          align_space : BITCODE_BD;
          block : BITCODE_H;
          block_color : BITCODE_CMC;
          block_scale : BITCODE_3BD;
          use_block_scale : BITCODE_B;
          block_rotation : BITCODE_BD;
          use_block_rotation : BITCODE_B;
          block_connection : BITCODE_BS;
          scale : BITCODE_BD;
          is_changed : BITCODE_B;
          is_annotative : BITCODE_B;
          break_size : BITCODE_BD;
          attach_dir : BITCODE_BS;
          attach_top : BITCODE_BS;
          attach_bottom : BITCODE_BS;
          text_extended : BITCODE_B;
        end;
      Dwg_Object_MLEADERSTYLE = _dwg_object_MLEADERSTYLE;
      //PDwg_Object_MLEADERSTYLE = ^Dwg_Object_MLEADERSTYLE;

      //P_dwg_object_VBA_PROJECT = ^_dwg_object_VBA_PROJECT;
      _dwg_object_VBA_PROJECT = record
          parent : P_dwg_object_object;
          data_size : BITCODE_BL;
          data : BITCODE_TF;
        end;
      Dwg_Object_VBA_PROJECT = _dwg_object_VBA_PROJECT;
      //PDwg_Object_VBA_PROJECT = ^Dwg_Object_VBA_PROJECT;

      //P_dwg_object_PLOTSETTINGS = ^_dwg_object_PLOTSETTINGS;
      _dwg_object_PLOTSETTINGS = record
          parent : P_dwg_object_object;
          printer_cfg_file : BITCODE_TV;
          paper_size : BITCODE_TV;
          canonical_media_name : BITCODE_TV;
          plot_flags : BITCODE_BS;
          plotview : BITCODE_H;
          plotview_name : BITCODE_TV;
          left_margin : BITCODE_BD;
          bottom_margin : BITCODE_BD;
          right_margin : BITCODE_BD;
          top_margin : BITCODE_BD;
          paper_width : BITCODE_BD;
          paper_height : BITCODE_BD;
          plot_origin : BITCODE_2BD_1;
          plot_window_ll : BITCODE_2BD_1;
          plot_window_ur : BITCODE_2BD_1;
          plot_paper_unit : BITCODE_BS;
          plot_rotation_mode : BITCODE_BS;
          plot_type : BITCODE_BS;
          paper_units : BITCODE_BD;
          drawing_units : BITCODE_BD;
          stylesheet : BITCODE_TV;
          std_scale_type : BITCODE_BS;
          std_scale_factor : BITCODE_BD;
          paper_image_origin : BITCODE_2BD_1;
          shadeplot_type : BITCODE_BS;
          shadeplot_reslevel : BITCODE_BS;
          shadeplot_customdpi : BITCODE_BS;
          shadeplot : BITCODE_H;
        end;
      Dwg_Object_PLOTSETTINGS = _dwg_object_PLOTSETTINGS;
      //PDwg_Object_PLOTSETTINGS = ^Dwg_Object_PLOTSETTINGS;

      //P_dwg_object_LAYOUT = ^_dwg_object_LAYOUT;
      _dwg_object_LAYOUT = record
          parent : P_dwg_object_object;
          plotsettings : Dwg_Object_PLOTSETTINGS;
          layout_name : BITCODE_TV;
          tab_order : BITCODE_BS;
          layout_flags : BITCODE_BS;
          INSBASE : BITCODE_3DPOINT;
          LIMMIN : BITCODE_2DPOINT;
          LIMMAX : BITCODE_2DPOINT;
          UCSORG : BITCODE_3DPOINT;
          UCSXDIR : BITCODE_3DPOINT;
          UCSYDIR : BITCODE_3DPOINT;
          ucs_elevation : BITCODE_BD;
          UCSORTHOVIEW : BITCODE_BS;
          EXTMIN : BITCODE_3DPOINT;
          EXTMAX : BITCODE_3DPOINT;
          block_header : BITCODE_H;
          active_viewport : BITCODE_H;
          base_ucs : BITCODE_H;
          named_ucs : BITCODE_H;
          num_viewports : BITCODE_BL;
          viewports : PBITCODE_H;
        end;
      Dwg_Object_LAYOUT = _dwg_object_LAYOUT;
      //PDwg_Object_LAYOUT = ^Dwg_Object_LAYOUT;

      //P_dwg_object_DICTIONARYVAR = ^_dwg_object_DICTIONARYVAR;
      _dwg_object_DICTIONARYVAR = record
          parent : P_dwg_object_object;
          schema : BITCODE_RC;
          strvalue : BITCODE_TV;
        end;
      Dwg_Object_DICTIONARYVAR = _dwg_object_DICTIONARYVAR;
      //PDwg_Object_DICTIONARYVAR = ^Dwg_Object_DICTIONARYVAR;

      //P_dwg_TABLE_value = ^_dwg_TABLE_value;
      _dwg_TABLE_value = record
          flags : BITCODE_BL;
          format_flags : BITCODE_BL;
          data_type : BITCODE_BL;
          data_size : BITCODE_BL;
          data_long : BITCODE_BL;
          data_double : BITCODE_BD;
          data_string : BITCODE_TV;
          data_date : BITCODE_TF;
          data_point : BITCODE_2RD;
          data_3dpoint : BITCODE_3RD;
          data_handle : BITCODE_H;
          unit_type : BITCODE_BL;
          format_string : BITCODE_TV;
          value_string : BITCODE_TV;
        end;
      Dwg_TABLE_value = _dwg_TABLE_value;
      //PDwg_TABLE_value = ^Dwg_TABLE_value;

      //P_dwg_TABLE_CustomDataItem = ^_dwg_TABLE_CustomDataItem;
      _dwg_TABLE_CustomDataItem = record
          name : BITCODE_TV;
          value : Dwg_TABLE_value;
          cell_parent : P_dwg_TableCell;
          row_parent : P_dwg_TableRow;
        end;
      Dwg_TABLE_CustomDataItem = _dwg_TABLE_CustomDataItem;
      //PDwg_TABLE_CustomDataItem = ^Dwg_TABLE_CustomDataItem;

      //P_dwg_TABLE_AttrDef = ^_dwg_TABLE_AttrDef;
      _dwg_TABLE_AttrDef = record
          parent : P_dwg_TABLE_Cell;
          attdef : BITCODE_H;
          index : BITCODE_BS;
          text : BITCODE_TV;
        end;
      Dwg_TABLE_AttrDef = _dwg_TABLE_AttrDef;
      //PDwg_TABLE_AttrDef = ^Dwg_TABLE_AttrDef;

      //P_dwg_TABLE_Cell = ^_dwg_TABLE_Cell;
      _dwg_TABLE_Cell = record
          parent : P_dwg_entity_TABLE;
          _type : BITCODE_BS;
          flags : BITCODE_RC;
          is_merged_value : BITCODE_B;
          is_autofit_flag : BITCODE_B;
          merged_width_flag : BITCODE_BL;
          merged_height_flag : BITCODE_BL;
          rotation : BITCODE_BD;
          text_value : BITCODE_TV;
          text_style : BITCODE_H;
          block_handle : BITCODE_H;
          block_scale : BITCODE_BD;
          additional_data_flag : BITCODE_B;
          cell_flag_override : BITCODE_BL;
          virtual_edge_flag : BITCODE_RC;
          cell_alignment : BITCODE_RS;
          bg_fill_none : BITCODE_B;
          bg_color : BITCODE_CMC;
          content_color : BITCODE_CMC;
          text_height : BITCODE_BD;
          top_grid_color : BITCODE_CMC;
          top_grid_linewt : BITCODE_BS;
          top_visibility : BITCODE_BS;
          right_grid_color : BITCODE_CMC;
          right_grid_linewt : BITCODE_BS;
          right_visibility : BITCODE_BS;
          bottom_grid_color : BITCODE_CMC;
          bottom_grid_linewt : BITCODE_BS;
          bottom_visibility : BITCODE_BS;
          left_grid_color : BITCODE_CMC;
          left_grid_linewt : BITCODE_BS;
          left_visibility : BITCODE_BS;
          unknown : BITCODE_BL;
          value : Dwg_TABLE_value;
          num_attr_defs : BITCODE_BL;
          attr_defs : PDwg_TABLE_AttrDef;
        end;
      Dwg_TABLE_Cell = _dwg_TABLE_Cell;
      //PDwg_TABLE_Cell = ^Dwg_TABLE_Cell;

      //P_dwg_TABLE_BreakHeight = ^_dwg_TABLE_BreakHeight;
      _dwg_TABLE_BreakHeight = record
          parent : P_dwg_entity_TABLE;
          position : BITCODE_3BD;
          height : BITCODE_BD;
          flag : BITCODE_BL;
        end;
      Dwg_TABLE_BreakHeight = _dwg_TABLE_BreakHeight;
      //PDwg_TABLE_BreakHeight = ^Dwg_TABLE_BreakHeight;

      //P_dwg_TABLE_BreakRow = ^_dwg_TABLE_BreakRow;
      _dwg_TABLE_BreakRow = record
          parent : P_dwg_entity_TABLE;
          position : BITCODE_3BD;
          start : BITCODE_BL;
          &end : BITCODE_BL;
        end;
      Dwg_TABLE_BreakRow = _dwg_TABLE_BreakRow;
      //PDwg_TABLE_BreakRow = ^Dwg_TABLE_BreakRow;

      //P_dwg_LinkedData = ^_dwg_LinkedData;
      _dwg_LinkedData = record
          name : BITCODE_TV;
          description : BITCODE_TV;
        end;
      Dwg_LinkedData = _dwg_LinkedData;
      //PDwg_LinkedData = ^Dwg_LinkedData;

      //P_dwg_TableCellContent_Attr = ^_dwg_TableCellContent_Attr;
      _dwg_TableCellContent_Attr = record
          parent : P_dwg_TableCellContent;
          attdef : BITCODE_H;
          value : BITCODE_TV;
          index : BITCODE_BL;
        end;
      Dwg_TableCellContent_Attr = _dwg_TableCellContent_Attr;
      //PDwg_TableCellContent_Attr = ^Dwg_TableCellContent_Attr;

      //P_dwg_ContentFormat = ^_dwg_ContentFormat;
      _dwg_ContentFormat = record
          property_override_flags : BITCODE_BL;
          property_flags : BITCODE_BL;
          value_data_type : BITCODE_BL;
          value_unit_type : BITCODE_BL;
          value_format_string : BITCODE_TV;
          rotation : BITCODE_BD;
          block_scale : BITCODE_BD;
          cell_alignment : BITCODE_BL;
          content_color : BITCODE_CMC;
          text_style : BITCODE_H;
          text_height : BITCODE_BD;
        end;
      Dwg_ContentFormat = _dwg_ContentFormat;
      //PDwg_ContentFormat = ^Dwg_ContentFormat;

      //P_dwg_TableCellContent = ^_dwg_TableCellContent;
      _dwg_TableCellContent = record
          parent : P_dwg_TableCell;
          _type : BITCODE_BL;
          value : Dwg_TABLE_value;
          handle : BITCODE_H;
          num_attrs : BITCODE_BL;
          attrs : PDwg_TableCellContent_Attr;
          has_content_format_overrides : BITCODE_BS;
          content_format : Dwg_ContentFormat;
        end;
      Dwg_TableCellContent = _dwg_TableCellContent;
      //PDwg_TableCellContent = ^Dwg_TableCellContent;

      //P_dwg_CellContentGeometry = ^_dwg_CellContentGeometry;
      _dwg_CellContentGeometry = record
          dist_top_left : BITCODE_3BD;
          dist_center : BITCODE_3BD;
          content_width : BITCODE_BD;
          content_height : BITCODE_BD;
          width : BITCODE_BD;
          height : BITCODE_BD;
          unknown : BITCODE_BL;
          cell_parent : P_dwg_TableCell;
          geom_parent : P_dwg_TABLEGEOMETRY_Cell;
        end;
      Dwg_CellContentGeometry = _dwg_CellContentGeometry;
      //PDwg_CellContentGeometry = ^Dwg_CellContentGeometry;

      //P_dwg_TableCell = ^_dwg_TableCell;
      _dwg_TableCell = record
          flag : BITCODE_BL;
          tooltip : BITCODE_TV;
          customdata : BITCODE_BL;
          num_customdata_items : BITCODE_BL;
          customdata_items : PDwg_TABLE_CustomDataItem;
          has_linked_data : BITCODE_BL;
          data_link : BITCODE_H;
          num_rows : BITCODE_BL;
          num_cols : BITCODE_BL;
          unknown : BITCODE_BL;
          num_cell_contents : BITCODE_BL;
          cell_contents : PDwg_TableCellContent;
          style_id : BITCODE_BL;
          has_geom_data : BITCODE_BL;
          geom_data_flag : BITCODE_BL;
          width_w_gap : BITCODE_BD;
          height_w_gap : BITCODE_BD;
          tablegeometry : BITCODE_H;
          num_geometry : BITCODE_BL;
          geometry : PDwg_CellContentGeometry;
          style_parent : P_dwg_CellStyle;
          row_parent : P_dwg_TableRow;
        end;
      Dwg_TableCell = _dwg_TableCell;
      //PDwg_TableCell = ^Dwg_TableCell;

      //P_dwg_GridFormat = ^_dwg_GridFormat;
      _dwg_GridFormat = record
          parent : P_dwg_CellStyle;
          index_mask : BITCODE_BL;
          border_overrides : BITCODE_BL;
          border_type : BITCODE_BL;
          color : BITCODE_CMC;
          linewt : BITCODE_BLd;
          ltype : BITCODE_H;
          visible : BITCODE_B;
          double_line_spacing : BITCODE_BD;
        end;
      Dwg_GridFormat = _dwg_GridFormat;
      //PDwg_GridFormat = ^Dwg_GridFormat;

      //P_dwg_CellStyle = ^_dwg_CellStyle;
      _dwg_CellStyle = record
          _type : BITCODE_BL;
          data_flags : BITCODE_BS;
          property_override_flags : BITCODE_BL;
          merge_flags : BITCODE_BL;
          bg_color : BITCODE_CMC;
          content_layout : BITCODE_BL;
          content_format : Dwg_ContentFormat;
          margin_override_flags : BITCODE_BS;
          vert_margin : BITCODE_BD;
          horiz_margin : BITCODE_BD;
          bottom_margin : BITCODE_BD;
          right_margin : BITCODE_BD;
          margin_horiz_spacing : BITCODE_BD;
          margin_vert_spacing : BITCODE_BD;
          num_borders : BITCODE_BL;
          borders : PDwg_GridFormat;
          tablerow_parent : P_dwg_TableRow;
          tabledatacolumn_parent : P_dwg_TableDataColumn;
        end;
      Dwg_CellStyle = _dwg_CellStyle;
      //PDwg_CellStyle = ^Dwg_CellStyle;

      //P_dwg_TableRow = ^_dwg_TableRow;
      _dwg_TableRow = record
          parent : P_dwg_LinkedTableData;
          num_cells : BITCODE_BL;
          cells : PDwg_TableCell;
          custom_data : BITCODE_BL;
          num_customdata_items : BITCODE_BL;
          customdata_items : PDwg_TABLE_CustomDataItem;
          cellstyle : Dwg_CellStyle;
          style_id : BITCODE_BL;
          height : BITCODE_BL;
        end;
      Dwg_TableRow = _dwg_TableRow;
      //PDwg_TableRow = ^Dwg_TableRow;

      //P_dwg_TableDataColumn = ^_dwg_TableDataColumn;
      _dwg_TableDataColumn = record
          parent : P_dwg_LinkedTableData;
          name : BITCODE_TV;
          custom_data : BITCODE_BL;
          cellstyle : Dwg_CellStyle;
          cellstyle_id : BITCODE_BL;
          width : BITCODE_BL;
        end;
      Dwg_TableDataColumn = _dwg_TableDataColumn;
      //PDwg_TableDataColumn = ^Dwg_TableDataColumn;

      //P_dwg_LinkedTableData = ^_dwg_LinkedTableData;
      _dwg_LinkedTableData = record
          num_cols : BITCODE_BL;
          cols : PDwg_TableDataColumn;
          num_rows : BITCODE_BL;
          rows : PDwg_TableRow;
          num_field_refs : BITCODE_BL;
          field_refs : PBITCODE_H;
        end;
      Dwg_LinkedTableData = _dwg_LinkedTableData;
      //PDwg_LinkedTableData = ^Dwg_LinkedTableData;

      //P_dwg_FormattedTableMerged = ^_dwg_FormattedTableMerged;
      _dwg_FormattedTableMerged = record
          parent : P_dwg_FormattedTableData;
          top_row : BITCODE_BL;
          left_col : BITCODE_BL;
          bottom_row : BITCODE_BL;
          right_col : BITCODE_BL;
        end;
      Dwg_FormattedTableMerged = _dwg_FormattedTableMerged;
      //PDwg_FormattedTableMerged = ^Dwg_FormattedTableMerged;

      //P_dwg_FormattedTableData = ^_dwg_FormattedTableData;
      _dwg_FormattedTableData = record
          parent : P_dwg_object_TABLECONTENT;
          cellstyle : Dwg_CellStyle;
          num_merged_cells : BITCODE_BL;
          merged_cells : PDwg_FormattedTableMerged;
        end;
      Dwg_FormattedTableData = _dwg_FormattedTableData;
      //PDwg_FormattedTableData = ^Dwg_FormattedTableData;

      //P_dwg_object_TABLECONTENT = ^_dwg_object_TABLECONTENT;
      _dwg_object_TABLECONTENT = record
          parent : P_dwg_object_object;
          ldata : Dwg_LinkedData;
          tdata : Dwg_LinkedTableData;
          fdata : Dwg_FormattedTableData;
          tablestyle : BITCODE_H;
        end;
      Dwg_Object_TABLECONTENT = _dwg_object_TABLECONTENT;
      //PDwg_Object_TABLECONTENT = ^Dwg_Object_TABLECONTENT;

      //P_dwg_entity_TABLE = ^_dwg_entity_TABLE;
      _dwg_entity_TABLE = record
          parent : P_dwg_object_entity;
          ldata : Dwg_LinkedData;
          tdata : Dwg_LinkedTableData;
          fdata : Dwg_FormattedTableData;
          tablestyle : BITCODE_H;
          unknown_rc : BITCODE_RC;
          unknown_h : BITCODE_H;
          unknown_bl : BITCODE_BL;
          unknown_b : BITCODE_B;
          unknown_bl1 : BITCODE_BL;
          ins_pt : BITCODE_3BD;
          scale : BITCODE_3BD;
          scale_flag : BITCODE_BB;
          rotation : BITCODE_BD;
          extrusion : BITCODE_BE;
          has_attribs : BITCODE_B;
          num_owned : BITCODE_BL;
          flag_for_table_value : BITCODE_BS;
          horiz_direction : BITCODE_3BD;
          num_cols : BITCODE_BL;
          num_rows : BITCODE_BL;
          num_cells : dword;
          col_widths : PBITCODE_BD;
          row_heights : PBITCODE_BD;
          cells : PDwg_TABLE_Cell;
          has_table_overrides : BITCODE_B;
          table_flag_override : BITCODE_BL;
          title_suppressed : BITCODE_B;
          header_suppressed : BITCODE_B;
          flow_direction : BITCODE_BS;
          horiz_cell_margin : BITCODE_BD;
          vert_cell_margin : BITCODE_BD;
          title_row_color : BITCODE_CMC;
          header_row_color : BITCODE_CMC;
          data_row_color : BITCODE_CMC;
          title_row_fill_none : BITCODE_B;
          header_row_fill_none : BITCODE_B;
          data_row_fill_none : BITCODE_B;
          title_row_fill_color : BITCODE_CMC;
          header_row_fill_color : BITCODE_CMC;
          data_row_fill_color : BITCODE_CMC;
          title_row_alignment : BITCODE_BS;
          header_row_alignment : BITCODE_BS;
          data_row_alignment : BITCODE_BS;
          title_text_style : BITCODE_H;
          header_text_style : BITCODE_H;
          data_text_style : BITCODE_H;
          title_row_height : BITCODE_BD;
          header_row_height : BITCODE_BD;
          data_row_height : BITCODE_BD;
          has_border_color_overrides : BITCODE_B;
          border_color_overrides_flag : BITCODE_BL;
          title_horiz_top_color : BITCODE_CMC;
          title_horiz_ins_color : BITCODE_CMC;
          title_horiz_bottom_color : BITCODE_CMC;
          title_vert_left_color : BITCODE_CMC;
          title_vert_ins_color : BITCODE_CMC;
          title_vert_right_color : BITCODE_CMC;
          header_horiz_top_color : BITCODE_CMC;
          header_horiz_ins_color : BITCODE_CMC;
          header_horiz_bottom_color : BITCODE_CMC;
          header_vert_left_color : BITCODE_CMC;
          header_vert_ins_color : BITCODE_CMC;
          header_vert_right_color : BITCODE_CMC;
          data_horiz_top_color : BITCODE_CMC;
          data_horiz_ins_color : BITCODE_CMC;
          data_horiz_bottom_color : BITCODE_CMC;
          data_vert_left_color : BITCODE_CMC;
          data_vert_ins_color : BITCODE_CMC;
          data_vert_right_color : BITCODE_CMC;
          has_border_lineweight_overrides : BITCODE_B;
          border_lineweight_overrides_flag : BITCODE_BL;
          title_horiz_top_linewt : BITCODE_BS;
          title_horiz_ins_linewt : BITCODE_BS;
          title_horiz_bottom_linewt : BITCODE_BS;
          title_vert_left_linewt : BITCODE_BS;
          title_vert_ins_linewt : BITCODE_BS;
          title_vert_right_linewt : BITCODE_BS;
          header_horiz_top_linewt : BITCODE_BS;
          header_horiz_ins_linewt : BITCODE_BS;
          header_horiz_bottom_linewt : BITCODE_BS;
          header_vert_left_linewt : BITCODE_BS;
          header_vert_ins_linewt : BITCODE_BS;
          header_vert_right_linewt : BITCODE_BS;
          data_horiz_top_linewt : BITCODE_BS;
          data_horiz_ins_linewt : BITCODE_BS;
          data_horiz_bottom_linewt : BITCODE_BS;
          data_vert_left_linewt : BITCODE_BS;
          data_vert_ins_linewt : BITCODE_BS;
          data_vert_right_linewt : BITCODE_BS;
          has_border_visibility_overrides : BITCODE_B;
          border_visibility_overrides_flag : BITCODE_BL;
          title_horiz_top_visibility : BITCODE_BS;
          title_horiz_ins_visibility : BITCODE_BS;
          title_horiz_bottom_visibility : BITCODE_BS;
          title_vert_left_visibility : BITCODE_BS;
          title_vert_ins_visibility : BITCODE_BS;
          title_vert_right_visibility : BITCODE_BS;
          header_horiz_top_visibility : BITCODE_BS;
          header_horiz_ins_visibility : BITCODE_BS;
          header_horiz_bottom_visibility : BITCODE_BS;
          header_vert_left_visibility : BITCODE_BS;
          header_vert_ins_visibility : BITCODE_BS;
          header_vert_right_visibility : BITCODE_BS;
          data_horiz_top_visibility : BITCODE_BS;
          data_horiz_ins_visibility : BITCODE_BS;
          data_horiz_bottom_visibility : BITCODE_BS;
          data_vert_left_visibility : BITCODE_BS;
          data_vert_ins_visibility : BITCODE_BS;
          data_vert_right_visibility : BITCODE_BS;
          block_header : BITCODE_H;
          first_attrib : BITCODE_H;
          last_attrib : BITCODE_H;
          attribs : PBITCODE_H;
          seqend : BITCODE_H;
          title_row_style_override : BITCODE_H;
          header_row_style_override : BITCODE_H;
          data_row_style_override : BITCODE_H;
          unknown_bs : BITCODE_BS;
          hor_dir : BITCODE_3BD;
          has_break_data : BITCODE_BL;
          break_flag : BITCODE_BL;
          break_flow_direction : BITCODE_BL;
          break_spacing : BITCODE_BD;
          break_unknown1 : BITCODE_BL;
          break_unknown2 : BITCODE_BL;
          num_break_heights : BITCODE_BL;
          break_heights : PDwg_TABLE_BreakHeight;
          num_break_rows : BITCODE_BL;
          break_rows : PDwg_TABLE_BreakRow;
        end;
      Dwg_Entity_TABLE = _dwg_entity_TABLE;
      //PDwg_Entity_TABLE = ^Dwg_Entity_TABLE;

      //P_dwg_TABLESTYLE_CellStyle = ^_dwg_TABLESTYLE_CellStyle;
      _dwg_TABLESTYLE_CellStyle = record
          parent : P_dwg_object_TABLESTYLE;
          id : BITCODE_BL;
          _type : BITCODE_BL;
          name : BITCODE_TV;
          cellstyle : _dwg_CellStyle;
        end;
      Dwg_TABLESTYLE_CellStyle = _dwg_TABLESTYLE_CellStyle;
      //PDwg_TABLESTYLE_CellStyle = ^Dwg_TABLESTYLE_CellStyle;

      //P_dwg_TABLESTYLE_border = ^_dwg_TABLESTYLE_border;
      _dwg_TABLESTYLE_border = record
          linewt : BITCODE_BSd;
          visible : BITCODE_B;
          color : BITCODE_CMC;
        end;
      Dwg_TABLESTYLE_border = _dwg_TABLESTYLE_border;
      //PDwg_TABLESTYLE_border = ^Dwg_TABLESTYLE_border;

      //P_dwg_TABLESTYLE_rowstyles = ^_dwg_TABLESTYLE_rowstyles;
      _dwg_TABLESTYLE_rowstyles = record
          parent : P_dwg_object_TABLESTYLE;
          text_style : BITCODE_H;
          text_height : BITCODE_BD;
          text_alignment : BITCODE_BS;
          text_color : BITCODE_CMC;
          fill_color : BITCODE_CMC;
          has_bgcolor : BITCODE_B;
          num_borders : BITCODE_BL;
          borders : PDwg_TABLESTYLE_border;
          data_type : BITCODE_BL;
          unit_type : BITCODE_BL;
          format_string : BITCODE_TU;
        end;
      Dwg_TABLESTYLE_rowstyles = _dwg_TABLESTYLE_rowstyles;
      //PDwg_TABLESTYLE_rowstyles = ^Dwg_TABLESTYLE_rowstyles;

      //P_dwg_object_TABLESTYLE = ^_dwg_object_TABLESTYLE;
      _dwg_object_TABLESTYLE = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          name : BITCODE_TV;
          flags : BITCODE_BS;
          flow_direction : BITCODE_BS;
          horiz_cell_margin : BITCODE_BD;
          vert_cell_margin : BITCODE_BD;
          is_title_suppressed : BITCODE_B;
          is_header_suppressed : BITCODE_B;
          unknown_rc : BITCODE_RC;
          unknown_bl1 : BITCODE_BL;
          unknown_bl2 : BITCODE_BL;
          cellstyle : BITCODE_H;
          sty : Dwg_TABLESTYLE_CellStyle;
          numoverrides : BITCODE_BL;
          unknown_bl3 : BITCODE_BL;
          ovr : Dwg_TABLESTYLE_CellStyle;
          num_rowstyles : BITCODE_BL;
          rowstyles : PDwg_TABLESTYLE_rowstyles;
        end;
      Dwg_Object_TABLESTYLE = _dwg_object_TABLESTYLE;
      //PDwg_Object_TABLESTYLE = ^Dwg_Object_TABLESTYLE;

      //P_dwg_object_CELLSTYLEMAP = ^_dwg_object_CELLSTYLEMAP;
      _dwg_object_CELLSTYLEMAP = record
          parent : P_dwg_object_object;
          num_cells : BITCODE_BL;
          cells : PDwg_TABLESTYLE_CellStyle;
        end;
      Dwg_Object_CELLSTYLEMAP = _dwg_object_CELLSTYLEMAP;
      //PDwg_Object_CELLSTYLEMAP = ^Dwg_Object_CELLSTYLEMAP;

      //P_dwg_TABLEGEOMETRY_Cell = ^_dwg_TABLEGEOMETRY_Cell;
      _dwg_TABLEGEOMETRY_Cell = record
          parent : P_dwg_object_TABLEGEOMETRY;
          geom_data_flag : BITCODE_BL;
          width_w_gap : BITCODE_BD;
          height_w_gap : BITCODE_BD;
          tablegeometry : BITCODE_H;
          num_geometry : BITCODE_BL;
          geometry : PDwg_CellContentGeometry;
        end;
      Dwg_TABLEGEOMETRY_Cell = _dwg_TABLEGEOMETRY_Cell;
      //PDwg_TABLEGEOMETRY_Cell = ^Dwg_TABLEGEOMETRY_Cell;

      //P_dwg_object_TABLEGEOMETRY = ^_dwg_object_TABLEGEOMETRY;
      _dwg_object_TABLEGEOMETRY = record
          parent : P_dwg_object_object;
          numrows : BITCODE_BL;
          numcols : BITCODE_BL;
          num_cells : BITCODE_BL;
          cells : PDwg_TABLEGEOMETRY_Cell;
        end;
      Dwg_Object_TABLEGEOMETRY = _dwg_object_TABLEGEOMETRY;
      //PDwg_Object_TABLEGEOMETRY = ^Dwg_Object_TABLEGEOMETRY;

      //P_dwg_abstractobject_UNDERLAYDEFINITION = ^_dwg_abstractobject_UNDERLAYDEFINITION;
      _dwg_abstractobject_UNDERLAYDEFINITION = record
          parent : P_dwg_object_object;
          filename : BITCODE_TV;
          name : BITCODE_TV;
        end;
      Dwg_Object_UNDERLAYDEFINITION = _dwg_abstractobject_UNDERLAYDEFINITION;
      //PDwg_Object_UNDERLAYDEFINITION = ^Dwg_Object_UNDERLAYDEFINITION;
      Dwg_Object_PDFDEFINITION = _dwg_abstractobject_UNDERLAYDEFINITION;
      Dwg_Object_DGNDEFINITION = _dwg_abstractobject_UNDERLAYDEFINITION;
      Dwg_Object_DWFDEFINITION = _dwg_abstractobject_UNDERLAYDEFINITION;

      //P_dwg_abstractentity_UNDERLAY = ^_dwg_abstractentity_UNDERLAY;
      _dwg_abstractentity_UNDERLAY = record
          parent : P_dwg_object_entity;
          extrusion : BITCODE_BE;
          ins_pt : BITCODE_3BD;
          scale : BITCODE_3BD;
          angle : BITCODE_BD;
          flag : BITCODE_RC;
          contrast : BITCODE_RC;
          fade : BITCODE_RC;
          num_clip_verts : BITCODE_BL;
          clip_verts : PBITCODE_2RD;
          num_clip_inverts : BITCODE_BS;
          clip_inverts : PBITCODE_2RD;
          definition_id : BITCODE_H;
        end;
      Dwg_Entity_UNDERLAY = _dwg_abstractentity_UNDERLAY;
      //PDwg_Entity_UNDERLAY = ^Dwg_Entity_UNDERLAY;
      Dwg_Entity_PDFUNDERLAY = _dwg_abstractentity_UNDERLAY;
      Dwg_Entity_DGNUNDERLAY = _dwg_abstractentity_UNDERLAY;
      Dwg_Entity_DWFUNDERLAY = _dwg_abstractentity_UNDERLAY;

      //P_dwg_object_DBCOLOR = ^_dwg_object_DBCOLOR;
      _dwg_object_DBCOLOR = record
          parent : P_dwg_object_object;
          color : BITCODE_CMC;
        end;
      Dwg_Object_DBCOLOR = _dwg_object_DBCOLOR;
      //PDwg_Object_DBCOLOR = ^Dwg_Object_DBCOLOR;

      //P_dwg_FIELD_ChildValue = ^_dwg_FIELD_ChildValue;
      _dwg_FIELD_ChildValue = record
          parent : P_dwg_object_FIELD;
          key : BITCODE_TV;
          value : Dwg_TABLE_value;
        end;
      Dwg_FIELD_ChildValue = _dwg_FIELD_ChildValue;
      //PDwg_FIELD_ChildValue = ^Dwg_FIELD_ChildValue;

      //P_dwg_object_FIELD = ^_dwg_object_FIELD;
      _dwg_object_FIELD = record
          parent : P_dwg_object_object;
          id : BITCODE_TV;
          code : BITCODE_TV;
          num_childs : BITCODE_BL;
          childs : PBITCODE_H;
          num_objects : BITCODE_BL;
          objects : PBITCODE_H;
          format : BITCODE_TV;
          evaluation_option : BITCODE_BL;
          filing_option : BITCODE_BL;
          field_state : BITCODE_BL;
          evaluation_status : BITCODE_BL;
          evaluation_error_code : BITCODE_BL;
          evaluation_error_msg : BITCODE_TV;
          value : Dwg_TABLE_value;
          value_string : BITCODE_TV;
          value_string_length : BITCODE_BL;
          num_childval : BITCODE_BL;
          childval : PDwg_FIELD_ChildValue;
        end;
      Dwg_Object_FIELD = _dwg_object_FIELD;
      //PDwg_Object_FIELD = ^Dwg_Object_FIELD;

      //P_dwg_object_FIELDLIST = ^_dwg_object_FIELDLIST;
      _dwg_object_FIELDLIST = record
          parent : P_dwg_object_object;
          num_fields : BITCODE_BL;
          unknown : BITCODE_B;
          fields : PBITCODE_H;
        end;
      Dwg_Object_FIELDLIST = _dwg_object_FIELDLIST;
      //PDwg_Object_FIELDLIST = ^Dwg_Object_FIELDLIST;

      //P_dwg_GEODATA_meshpt = ^_dwg_GEODATA_meshpt;
      _dwg_GEODATA_meshpt = record
          source_pt : BITCODE_2RD;
          dest_pt : BITCODE_2RD;
        end;
      Dwg_GEODATA_meshpt = _dwg_GEODATA_meshpt;
      //PDwg_GEODATA_meshpt = ^Dwg_GEODATA_meshpt;

      //P_dwg_GEODATA_meshface = ^_dwg_GEODATA_meshface;
      _dwg_GEODATA_meshface = record
          face1 : BITCODE_BL;
          face2 : BITCODE_BL;
          face3 : BITCODE_BL;
        end;
      Dwg_GEODATA_meshface = _dwg_GEODATA_meshface;
      //PDwg_GEODATA_meshface = ^Dwg_GEODATA_meshface;

      //P_dwg_object_GEODATA = ^_dwg_object_GEODATA;
      _dwg_object_GEODATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          host_block : BITCODE_H;
          coord_type : BITCODE_BS;
          design_pt : BITCODE_3BD;
          ref_pt : BITCODE_3BD;
          obs_pt : BITCODE_3BD;
          scale_vec : BITCODE_3BD;
          unit_scale_horiz : BITCODE_BD;
          units_value_horiz : BITCODE_BL;
          unit_scale_vert : BITCODE_BD;
          units_value_vert : BITCODE_BL;
          up_dir : BITCODE_3BD;
          north_dir : BITCODE_3BD;
          scale_est : BITCODE_BL;
          user_scale_factor : BITCODE_BD;
          do_sea_level_corr : BITCODE_B;
          sea_level_elev : BITCODE_BD;
          coord_proj_radius : BITCODE_BD;
          coord_system_def : BITCODE_TV;
          geo_rss_tag : BITCODE_TV;
          coord_system_datum : BITCODE_TV;
          coord_system_wkt : BITCODE_TV;
          observation_from_tag : BITCODE_TV;
          observation_to_tag : BITCODE_TV;
          observation_coverage_tag : BITCODE_TV;
          num_geomesh_pts : BITCODE_BL;
          geomesh_pts : PDwg_GEODATA_meshpt;
          num_geomesh_faces : BITCODE_BL;
          geomesh_faces : PDwg_GEODATA_meshface;
          has_civil_data : BITCODE_B;
          obsolete_false : BITCODE_B;
          ref_pt2d : BITCODE_2RD;
          zero1 : BITCODE_3BD;
          zero2 : BITCODE_3BD;
          unknown1 : BITCODE_BL;
          unknown2 : BITCODE_BL;
          unknown_b : BITCODE_B;
          north_dir_angle_deg : BITCODE_BD;
          north_dir_angle_rad : BITCODE_BD;
        end;
      Dwg_Object_GEODATA = _dwg_object_GEODATA;
      //PDwg_Object_GEODATA = ^Dwg_Object_GEODATA;

      //P_dwg_object_IDBUFFER = ^_dwg_object_IDBUFFER;
      _dwg_object_IDBUFFER = record
          parent : P_dwg_object_object;
          unknown : BITCODE_RC;
          num_obj_ids : BITCODE_BL;
          obj_ids : PBITCODE_H;
        end;
      Dwg_Object_IDBUFFER = _dwg_object_IDBUFFER;
      //PDwg_Object_IDBUFFER = ^Dwg_Object_IDBUFFER;

      //P_dwg_entity_IMAGE = ^_dwg_entity_IMAGE;
      _dwg_entity_IMAGE = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_BL;
          pt0 : BITCODE_3BD;
          uvec : BITCODE_3BD;
          vvec : BITCODE_3BD;
          size : BITCODE_2RD;
          display_props : BITCODE_BS;
          clipping : BITCODE_B;
          brightness : BITCODE_RC;
          contrast : BITCODE_RC;
          fade : BITCODE_RC;
          clip_mode : BITCODE_B;
          clip_boundary_type : BITCODE_BS;
          num_clip_verts : BITCODE_BL;
          clip_verts : PBITCODE_2RD;
          imagedef : BITCODE_H;
          imagedefreactor : BITCODE_H;
        end;
      Dwg_Entity_IMAGE = _dwg_entity_IMAGE;
      //PDwg_Entity_IMAGE = ^Dwg_Entity_IMAGE;

      //P_dwg_object_IMAGEDEF = ^_dwg_object_IMAGEDEF;
      _dwg_object_IMAGEDEF = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          image_size : BITCODE_2RD;
          file_path : BITCODE_TV;
          is_loaded : BITCODE_B;
          resunits : BITCODE_RC;
          pixel_size : BITCODE_2RD;
        end;
      Dwg_Object_IMAGEDEF = _dwg_object_IMAGEDEF;
      //PDwg_Object_IMAGEDEF = ^Dwg_Object_IMAGEDEF;

      //P_dwg_object_IMAGEDEF_REACTOR = ^_dwg_object_IMAGEDEF_REACTOR;
      _dwg_object_IMAGEDEF_REACTOR = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_IMAGEDEF_REACTOR = _dwg_object_IMAGEDEF_REACTOR;
      //PDwg_Object_IMAGEDEF_REACTOR = ^Dwg_Object_IMAGEDEF_REACTOR;

      //P_dwg_object_INDEX = ^_dwg_object_INDEX;
      _dwg_object_INDEX = record
          parent : P_dwg_object_object;
          last_updated : BITCODE_TIMEBLL;
        end;
      Dwg_Object_INDEX = _dwg_object_INDEX;
      //PDwg_Object_INDEX = ^Dwg_Object_INDEX;

      //P_dwg_LAYER_entry = ^_dwg_LAYER_entry;
      _dwg_LAYER_entry = record
          parent : P_dwg_object_LAYER_INDEX;
          numlayers : BITCODE_BL;
          name : BITCODE_TV;
          handle : BITCODE_H;
        end;
      Dwg_LAYER_entry = _dwg_LAYER_entry;
      //PDwg_LAYER_entry = ^Dwg_LAYER_entry;

      //P_dwg_object_LAYER_INDEX = ^_dwg_object_LAYER_INDEX;
      _dwg_object_LAYER_INDEX = record
          parent : P_dwg_object_object;
          last_updated : BITCODE_TIMEBLL;
          num_entries : BITCODE_BL;
          entries : PDwg_LAYER_entry;
        end;
      Dwg_Object_LAYER_INDEX = _dwg_object_LAYER_INDEX;
      //PDwg_Object_LAYER_INDEX = ^Dwg_Object_LAYER_INDEX;

      //P_dwg_entity_LWPOLYLINE = ^_dwg_entity_LWPOLYLINE;
      _dwg_entity_LWPOLYLINE = record
          parent : P_dwg_object_entity;
          flag : BITCODE_BS;
          const_width : BITCODE_BD;
          elevation : BITCODE_BD;
          thickness : BITCODE_BD;
          extrusion : BITCODE_BE;
          num_points : BITCODE_BL;
          points : PBITCODE_2RD;
          num_bulges : BITCODE_BL;
          bulges : PBITCODE_BD;
          num_vertexids : BITCODE_BL;
          vertexids : PBITCODE_BL;
          num_widths : BITCODE_BL;
          widths : PDwg_LWPOLYLINE_width;
        end;
      Dwg_Entity_LWPOLYLINE = _dwg_entity_LWPOLYLINE;
      //PDwg_Entity_LWPOLYLINE = ^Dwg_Entity_LWPOLYLINE;

      //P_dwg_object_RASTERVARIABLES = ^_dwg_object_RASTERVARIABLES;
      _dwg_object_RASTERVARIABLES = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          image_frame : BITCODE_BS;
          image_quality : BITCODE_BS;
          units : BITCODE_BS;
        end;
      Dwg_Object_RASTERVARIABLES = _dwg_object_RASTERVARIABLES;
      //PDwg_Object_RASTERVARIABLES = ^Dwg_Object_RASTERVARIABLES;

      //P_dwg_object_SCALE = ^_dwg_object_SCALE;
      _dwg_object_SCALE = record
          parent : P_dwg_object_object;
          flag : BITCODE_BS;
          name : BITCODE_TV;
          paper_units : BITCODE_BD;
          drawing_units : BITCODE_BD;
          is_unit_scale : BITCODE_B;
        end;
      Dwg_Object_SCALE = _dwg_object_SCALE;
      //PDwg_Object_SCALE = ^Dwg_Object_SCALE;

      //P_dwg_object_SORTENTSTABLE = ^_dwg_object_SORTENTSTABLE;
      _dwg_object_SORTENTSTABLE = record
          parent : P_dwg_object_object;
          num_ents : BITCODE_BL;
          sort_ents : PBITCODE_H;
          block_owner : BITCODE_H;
          ents : PBITCODE_H;
        end;
      Dwg_Object_SORTENTSTABLE = _dwg_object_SORTENTSTABLE;
      //PDwg_Object_SORTENTSTABLE = ^Dwg_Object_SORTENTSTABLE;

      //P_dwg_object_SPATIAL_FILTER = ^_dwg_object_SPATIAL_FILTER;
      _dwg_object_SPATIAL_FILTER = record
          parent : P_dwg_object_object;
          num_clip_verts : BITCODE_BS;
          clip_verts : PBITCODE_2RD;
          extrusion : BITCODE_BE;
          origin : BITCODE_3BD;
          display_boundary_on : BITCODE_BS;
          front_clip_on : BITCODE_BS;
          front_clip_z : BITCODE_BD;
          back_clip_on : BITCODE_BS;
          back_clip_z : BITCODE_BD;
          inverse_transform : PBITCODE_BD;
          transform : PBITCODE_BD;
        end;
      Dwg_Object_SPATIAL_FILTER = _dwg_object_SPATIAL_FILTER;
      //PDwg_Object_SPATIAL_FILTER = ^Dwg_Object_SPATIAL_FILTER;

      //P_dwg_object_SPATIAL_INDEX = ^_dwg_object_SPATIAL_INDEX;
      _dwg_object_SPATIAL_INDEX = record
          parent : P_dwg_object_object;
          last_updated : BITCODE_TIMEBLL;
          num1 : BITCODE_BD;
          num2 : BITCODE_BD;
          num3 : BITCODE_BD;
          num4 : BITCODE_BD;
          num5 : BITCODE_BD;
          num6 : BITCODE_BD;
          num_hdls : BITCODE_BL;
          hdls : PBITCODE_H;
          bindata_size : BITCODE_BL;
          bindata : BITCODE_TF;
        end;
      Dwg_Object_SPATIAL_INDEX = _dwg_object_SPATIAL_INDEX;
      //PDwg_Object_SPATIAL_INDEX = ^Dwg_Object_SPATIAL_INDEX;

      //P_dwg_entity_WIPEOUT = ^_dwg_entity_WIPEOUT;
      _dwg_entity_WIPEOUT = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_BL;
          pt0 : BITCODE_3BD;
          uvec : BITCODE_3BD;
          vvec : BITCODE_3BD;
          size : BITCODE_2RD;
          display_props : BITCODE_BS;
          clipping : BITCODE_B;
          brightness : BITCODE_RC;
          contrast : BITCODE_RC;
          fade : BITCODE_RC;
          clip_mode : BITCODE_B;
          clip_boundary_type : BITCODE_BS;
          num_clip_verts : BITCODE_BL;
          clip_verts : PBITCODE_2RD;
          imagedef : BITCODE_H;
          imagedefreactor : BITCODE_H;
        end;
      Dwg_Entity_WIPEOUT = _dwg_entity_WIPEOUT;
      //PDwg_Entity_WIPEOUT = ^Dwg_Entity_WIPEOUT;

      //P_dwg_object_WIPEOUTVARIABLES = ^_dwg_object_WIPEOUTVARIABLES;
      _dwg_object_WIPEOUTVARIABLES = record
          parent : P_dwg_object_object;
          display_frame : BITCODE_BS;
        end;
      Dwg_Object_WIPEOUTVARIABLES = _dwg_object_WIPEOUTVARIABLES;
      //PDwg_Object_WIPEOUTVARIABLES = ^Dwg_Object_WIPEOUTVARIABLES;

      //P_dwg_entity_SECTIONOBJECT = ^_dwg_entity_SECTIONOBJECT;
      _dwg_entity_SECTIONOBJECT = record
          parent : P_dwg_object_entity;
          state : BITCODE_BL;
          flags : BITCODE_BL;
          name : BITCODE_TV;
          vert_dir : BITCODE_3BD;
          top_height : BITCODE_BD;
          bottom_height : BITCODE_BD;
          indicator_alpha : BITCODE_BS;
          indicator_color : BITCODE_CMC;
          num_verts : BITCODE_BL;
          verts : PBITCODE_3BD;
          num_blverts : BITCODE_BL;
          blverts : PBITCODE_3BD;
          section_settings : BITCODE_H;
        end;
      Dwg_Entity_SECTIONOBJECT = _dwg_entity_SECTIONOBJECT;
      //PDwg_Entity_SECTIONOBJECT = ^Dwg_Entity_SECTIONOBJECT;

      //P_dwg_object_VISUALSTYLE = ^_dwg_object_VISUALSTYLE;
      _dwg_object_VISUALSTYLE = record
          parent : P_dwg_object_object;
          description : BITCODE_TV;
          style_type : BITCODE_BL;
          ext_lighting_model : BITCODE_BS;
          internal_only : BITCODE_B;
          face_lighting_model : BITCODE_BL;
          face_lighting_model_int : BITCODE_BS;
          face_lighting_quality : BITCODE_BL;
          face_lighting_quality_int : BITCODE_BS;
          face_color_mode : BITCODE_BL;
          face_color_mode_int : BITCODE_BS;
          face_opacity : BITCODE_BD;
          face_opacity_int : BITCODE_BS;
          face_specular : BITCODE_BD;
          face_specular_int : BITCODE_BS;
          face_modifier : BITCODE_BL;
          face_modifier_int : BITCODE_BS;
          face_mono_color : BITCODE_CMC;
          face_mono_color_int : BITCODE_BS;
          edge_model : BITCODE_BS;
          edge_model_int : BITCODE_BS;
          edge_style : BITCODE_BL;
          edge_style_int : BITCODE_BS;
          edge_intersection_color : BITCODE_CMC;
          edge_intersection_color_int : BITCODE_BS;
          edge_obscured_color : BITCODE_CMC;
          edge_obscured_color_int : BITCODE_BS;
          edge_obscured_ltype : BITCODE_BL;
          edge_obscured_ltype_int : BITCODE_BS;
          edge_intersection_ltype : BITCODE_BL;
          edge_intersection_ltype_int : BITCODE_BS;
          edge_crease_angle : BITCODE_BD;
          edge_crease_angle_int : BITCODE_BS;
          edge_modifier : BITCODE_BL;
          edge_modifier_int : BITCODE_BS;
          edge_color : BITCODE_CMC;
          edge_color_int : BITCODE_BS;
          edge_opacity : BITCODE_BD;
          edge_opacity_int : BITCODE_BS;
          edge_width : BITCODE_BL;
          edge_width_int : BITCODE_BS;
          edge_overhang : BITCODE_BL;
          edge_overhang_int : BITCODE_BS;
          edge_jitter : BITCODE_BL;
          edge_jitter_int : BITCODE_BS;
          edge_silhouette_color : BITCODE_CMC;
          edge_silhouette_color_int : BITCODE_BS;
          edge_silhouette_width : BITCODE_BL;
          edge_silhouette_width_int : BITCODE_BS;
          edge_halo_gap : BITCODE_BL;
          edge_halo_gap_int : BITCODE_BS;
          edge_isolines : BITCODE_BL;
          edge_isolines_int : BITCODE_BS;
          edge_do_hide_precision : BITCODE_B;
          edge_do_hide_precision_int : BITCODE_BS;
          edge_style_apply : BITCODE_BL;
          edge_style_apply_int : BITCODE_BS;
          display_settings : BITCODE_BL;
          display_settings_int : BITCODE_BS;
          display_brightness_bl : BITCODE_BLd;
          display_brightness : BITCODE_BD;
          display_brightness_int : BITCODE_BS;
          display_shadow_type : BITCODE_BL;
          display_shadow_type_int : BITCODE_BS;
          bd2007_45 : BITCODE_BD;
          num_props : BITCODE_BS;
          b_prop1c : BITCODE_B;
          b_prop1c_int : BITCODE_BS;
          b_prop1d : BITCODE_B;
          b_prop1d_int : BITCODE_BS;
          b_prop1e : BITCODE_B;
          b_prop1e_int : BITCODE_BS;
          b_prop1f : BITCODE_B;
          b_prop1f_int : BITCODE_BS;
          b_prop20 : BITCODE_B;
          b_prop20_int : BITCODE_BS;
          b_prop21 : BITCODE_B;
          b_prop21_int : BITCODE_BS;
          b_prop22 : BITCODE_B;
          b_prop22_int : BITCODE_BS;
          b_prop23 : BITCODE_B;
          b_prop23_int : BITCODE_BS;
          b_prop24 : BITCODE_B;
          b_prop24_int : BITCODE_BS;
          bl_prop25 : BITCODE_BL;
          bl_prop25_int : BITCODE_BS;
          bd_prop26 : BITCODE_BD;
          bd_prop26_int : BITCODE_BS;
          bd_prop27 : BITCODE_BD;
          bd_prop27_int : BITCODE_BS;
          bl_prop28 : BITCODE_BL;
          bl_prop28_int : BITCODE_BS;
          c_prop29 : BITCODE_CMC;
          c_prop29_int : BITCODE_BS;
          bl_prop2a : BITCODE_BL;
          bl_prop2a_int : BITCODE_BS;
          bl_prop2b : BITCODE_BL;
          bl_prop2b_int : BITCODE_BS;
          c_prop2c : BITCODE_CMC;
          c_prop2c_int : BITCODE_BS;
          b_prop2d : BITCODE_B;
          b_prop2d_int : BITCODE_BS;
          bl_prop2e : BITCODE_BL;
          bl_prop2e_int : BITCODE_BS;
          bl_prop2f : BITCODE_BL;
          bl_prop2f_int : BITCODE_BS;
          bl_prop30 : BITCODE_BL;
          bl_prop30_int : BITCODE_BS;
          b_prop31 : BITCODE_B;
          b_prop31_int : BITCODE_BS;
          bl_prop32 : BITCODE_BL;
          bl_prop32_int : BITCODE_BS;
          c_prop33 : BITCODE_CMC;
          c_prop33_int : BITCODE_BS;
          bd_prop34 : BITCODE_BD;
          bd_prop34_int : BITCODE_BS;
          edge_wiggle : BITCODE_BL;
          edge_wiggle_int : BITCODE_BS;
          strokes : BITCODE_TV;
          strokes_int : BITCODE_BS;
          b_prop37 : BITCODE_B;
          b_prop37_int : BITCODE_BS;
          bd_prop38 : BITCODE_BD;
          bd_prop38_int : BITCODE_BS;
          bd_prop39 : BITCODE_BD;
          bd_prop39_int : BITCODE_BS;
        end;
      Dwg_Object_VISUALSTYLE = _dwg_object_VISUALSTYLE;
      //PDwg_Object_VISUALSTYLE = ^Dwg_Object_VISUALSTYLE;

      //P_dwg_LIGHTLIST_light = ^_dwg_LIGHTLIST_light;
      _dwg_LIGHTLIST_light = record
          parent : P_dwg_object_LIGHTLIST;
          name : BITCODE_TV;
          handle : BITCODE_H;
        end;
      Dwg_LIGHTLIST_light = _dwg_LIGHTLIST_light;
      //PDwg_LIGHTLIST_light = ^Dwg_LIGHTLIST_light;

      //P_dwg_object_LIGHTLIST = ^_dwg_object_LIGHTLIST;
      _dwg_object_LIGHTLIST = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          num_lights : BITCODE_BL;
          lights : PDwg_LIGHTLIST_light;
        end;
      Dwg_Object_LIGHTLIST = _dwg_object_LIGHTLIST;
      //PDwg_Object_LIGHTLIST = ^Dwg_Object_LIGHTLIST;

      //P_dwg_MATERIAL_color = ^_dwg_MATERIAL_color;
      _dwg_MATERIAL_color = record
          parent : P_dwg_object_object;
          flag : BITCODE_RC;
          factor : BITCODE_BD;
          rgb : BITCODE_BL;
        end;
      Dwg_MATERIAL_color = _dwg_MATERIAL_color;
      //PDwg_MATERIAL_color = ^Dwg_MATERIAL_color;

      //P_dwg_MATERIAL_mapper = ^_dwg_MATERIAL_mapper;
      _dwg_MATERIAL_mapper = record
          parent : P_dwg_object_object;
          blendfactor : BITCODE_BD;
          transmatrix : PBITCODE_BD;
          filename : BITCODE_TV;
          color1 : Dwg_MATERIAL_color;
          color2 : Dwg_MATERIAL_color;
          source : BITCODE_RC;
          projection : BITCODE_RC;
          tiling : BITCODE_RC;
          autotransform : BITCODE_RC;
          texturemode : BITCODE_BS;
        end;
      Dwg_MATERIAL_mapper = _dwg_MATERIAL_mapper;
      //PDwg_MATERIAL_mapper = ^Dwg_MATERIAL_mapper;

      //P_dwg_MATERIAL_gentexture = ^_dwg_MATERIAL_gentexture;
      _dwg_MATERIAL_gentexture = record
          parent : P_dwg_object_MATERIAL;
          genprocname : BITCODE_TV;
          material : P_dwg_object_MATERIAL;
        end;
      Dwg_MATERIAL_gentexture = _dwg_MATERIAL_gentexture;
      //PDwg_MATERIAL_gentexture = ^Dwg_MATERIAL_gentexture;

      //P_dwg_object_MATERIAL = ^_dwg_object_MATERIAL;
      _dwg_object_MATERIAL = record
          parent : P_dwg_object_object;
          name : BITCODE_TV;
          description : BITCODE_TV;
          ambient_color : Dwg_MATERIAL_color;
          diffuse_color : Dwg_MATERIAL_color;
          diffusemap : Dwg_MATERIAL_mapper;
          specular_gloss_factor : BITCODE_BD;
          specular_color : Dwg_MATERIAL_color;
          specularmap : Dwg_MATERIAL_mapper;
          reflectionmap : Dwg_MATERIAL_mapper;
          opacity_percent : BITCODE_BD;
          opacitymap : Dwg_MATERIAL_mapper;
          bumpmap : Dwg_MATERIAL_mapper;
          refraction_index : BITCODE_BD;
          refractionmap : Dwg_MATERIAL_mapper;
          color_bleed_scale : BITCODE_BD;
          indirect_bump_scale : BITCODE_BD;
          reflectance_scale : BITCODE_BD;
          transmittance_scale : BITCODE_BD;
          two_sided_material : BITCODE_B;
          luminance : BITCODE_BD;
          luminance_mode : BITCODE_BS;
          translucence : BITCODE_BD;
          self_illumination : BITCODE_BD;
          reflectivity : BITCODE_BD;
          illumination_model : BITCODE_BL;
          channel_flags : BITCODE_BL;
          mode : BITCODE_BL;
          genprocname : BITCODE_TV;
          genproctype : BITCODE_BS;
          genprocvalbool : BITCODE_B;
          genprocvalint : BITCODE_BS;
          genprocvalreal : BITCODE_BD;
          genprocvaltext : BITCODE_TV;
          genprocvalcolor : BITCODE_CMC;
          genproctableend : BITCODE_B;
          num_gentextures : BITCODE_BS;
          gentextures : PDwg_MATERIAL_gentexture;
        end;
      Dwg_Object_MATERIAL = _dwg_object_MATERIAL;
      //PDwg_Object_MATERIAL = ^Dwg_Object_MATERIAL;

      //P_dwg_object_OBJECT_PTR = ^_dwg_object_OBJECT_PTR;
      _dwg_object_OBJECT_PTR = record
          parent : P_dwg_object_object;
        end;
      Dwg_Object_OBJECT_PTR = _dwg_object_OBJECT_PTR;
      //PDwg_Object_OBJECT_PTR = ^Dwg_Object_OBJECT_PTR;

      //P_dwg_entity_LIGHT = ^_dwg_entity_LIGHT;
      _dwg_entity_LIGHT = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_BL;
          name : BITCODE_TV;
          _type : BITCODE_BL;
          status : BITCODE_B;
          color : BITCODE_CMC;
          plot_glyph : BITCODE_B;
          intensity : BITCODE_BD;
          position : BITCODE_3BD;
          target : BITCODE_3BD;
          attenuation_type : BITCODE_BL;
          use_attenuation_limits : BITCODE_B;
          attenuation_start_limit : BITCODE_BD;
          attenuation_end_limit : BITCODE_BD;
          hotspot_angle : BITCODE_BD;
          falloff_angle : BITCODE_BD;
          cast_shadows : BITCODE_B;
          shadow_type : BITCODE_BL;
          shadow_map_size : BITCODE_BS;
          shadow_map_softness : BITCODE_RC;
          is_photometric : BITCODE_B;
          has_photometric_data : BITCODE_B;
          has_webfile : BITCODE_B;
          webfile : BITCODE_TV;
          physical_intensity_method : BITCODE_BS;
          physical_intensity : BITCODE_BD;
          illuminance_dist : BITCODE_BD;
          lamp_color_type : BITCODE_BS;
          lamp_color_temp : BITCODE_BD;
          lamp_color_preset : BITCODE_BS;
          lamp_color_rgb : BITCODE_BL;
          web_rotation : BITCODE_3BD;
          extlight_shape : BITCODE_BS;
          extlight_length : BITCODE_BD;
          extlight_width : BITCODE_BD;
          extlight_radius : BITCODE_BD;
          webfile_type : BITCODE_BS;
          web_symetry : BITCODE_BS;
          has_target_grip : BITCODE_BS;
          web_flux : BITCODE_BD;
          web_angle1 : BITCODE_BD;
          web_angle2 : BITCODE_BD;
          web_angle3 : BITCODE_BD;
          web_angle4 : BITCODE_BD;
          web_angle5 : BITCODE_BD;
          glyph_display_type : BITCODE_BS;
        end;
      Dwg_Entity_LIGHT = _dwg_entity_LIGHT;
      //PDwg_Entity_LIGHT = ^Dwg_Entity_LIGHT;

      //P_dwg_entity_CAMERA = ^_dwg_entity_CAMERA;
      _dwg_entity_CAMERA = record
          parent : P_dwg_object_entity;
          view : BITCODE_H;
        end;
      Dwg_Entity_CAMERA = _dwg_entity_CAMERA;
      //PDwg_Entity_CAMERA = ^Dwg_Entity_CAMERA;

      //P_dwg_entity_GEOPOSITIONMARKER = ^_dwg_entity_GEOPOSITIONMARKER;
      _dwg_entity_GEOPOSITIONMARKER = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_BS;
          position : BITCODE_3BD;
          radius : BITCODE_BD;
          landing_gap : BITCODE_BD;
          notes : BITCODE_TV;
          text_alignment : BITCODE_RC;
          mtext_visible : BITCODE_B;
          enable_frame_text : BITCODE_B;
          mtext : P_dwg_object;
        end;
      Dwg_Entity_GEOPOSITIONMARKER = _dwg_entity_GEOPOSITIONMARKER;
      //PDwg_Entity_GEOPOSITIONMARKER = ^Dwg_Entity_GEOPOSITIONMARKER;

      //P_dwg_object_GEOMAPIMAGE = ^_dwg_object_GEOMAPIMAGE;
      _dwg_object_GEOMAPIMAGE = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          pt0 : BITCODE_3BD;
          size : BITCODE_2RD;
          display_props : BITCODE_BS;
          clipping : BITCODE_B;
          brightness : BITCODE_RC;
          contrast : BITCODE_RC;
          fade : BITCODE_RC;
          rotation : BITCODE_BD;
          image_width : BITCODE_BD;
          image_height : BITCODE_BD;
          name : BITCODE_TV;
          image_file : BITCODE_BD;
          image_visibility : BITCODE_BD;
          transparency : BITCODE_BS;
          height : BITCODE_BD;
          width : BITCODE_BD;
          show_rotation : BITCODE_B;
          scale_factor : BITCODE_BD;
          geoimage_brightness : BITCODE_BS;
          geoimage_contrast : BITCODE_BS;
          geoimage_fade : BITCODE_BS;
          geoimage_position : BITCODE_BS;
          geoimage_width : BITCODE_BS;
          geoimage_height : BITCODE_BS;
        end;
      Dwg_Object_GEOMAPIMAGE = _dwg_object_GEOMAPIMAGE;
      //PDwg_Object_GEOMAPIMAGE = ^Dwg_Object_GEOMAPIMAGE;

      //P_dwg_entity_HELIX = ^_dwg_entity_HELIX;
      _dwg_entity_HELIX = record
          parent : P_dwg_object_entity;
          flag : BITCODE_BS;
          scenario : BITCODE_BS;
          degree : BITCODE_BS;
          splineflags1 : BITCODE_BL;
          knotparam : BITCODE_BL;
          fit_tol : BITCODE_BD;
          beg_tan_vec : BITCODE_3BD;
          end_tan_vec : BITCODE_3BD;
          rational : BITCODE_B;
          closed_b : BITCODE_B;
          periodic : BITCODE_B;
          weighted : BITCODE_B;
          knot_tol : BITCODE_BD;
          ctrl_tol : BITCODE_BD;
          num_fit_pts : BITCODE_BS;
          fit_pts : PBITCODE_3DPOINT;
          num_knots : BITCODE_BL;
          knots : PBITCODE_BD;
          num_ctrl_pts : BITCODE_BL;
          ctrl_pts : PDwg_SPLINE_control_point;
          major_version : BITCODE_BL;
          maint_version : BITCODE_BL;
          axis_base_pt : BITCODE_3BD;
          start_pt : BITCODE_3BD;
          axis_vector : BITCODE_3BD;
          radius : BITCODE_BD;
          turns : BITCODE_BD;
          turn_height : BITCODE_BD;
          handedness : BITCODE_B;
          constraint_type : BITCODE_RC;
        end;
      Dwg_Entity_HELIX = _dwg_entity_HELIX;
      //PDwg_Entity_HELIX = ^Dwg_Entity_HELIX;

      //P_dwg_entity_EXTRUDEDSURFACE = ^_dwg_entity_EXTRUDEDSURFACE;
      _dwg_entity_EXTRUDEDSURFACE = record
          parent : P_dwg_object_entity;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
          modeler_format_version : BITCODE_BS;
          bindata_size : BITCODE_BL;
          bindata : BITCODE_TF;
          u_isolines : BITCODE_BS;
          v_isolines : BITCODE_BS;
          class_version : BITCODE_BL;
          draft_angle : BITCODE_BD;
          draft_start_distance : BITCODE_BD;
          draft_end_distance : BITCODE_BD;
          twist_angle : BITCODE_BD;
          scale_factor : BITCODE_BD;
          align_angle : BITCODE_BD;
          sweep_entity_transmatrix : PBITCODE_BD;
          path_entity_transmatrix : PBITCODE_BD;
          is_solid : BITCODE_B;
          sweep_alignment_flags : BITCODE_BS;
          path_flags : BITCODE_BS;
          align_start : BITCODE_B;
          bank : BITCODE_B;
          base_point_set : BITCODE_B;
          sweep_entity_transform_computed : BITCODE_B;
          path_entity_transform_computed : BITCODE_B;
          reference_vector_for_controlling_twist : BITCODE_3BD;
          sweep_entity : BITCODE_H;
          path_entity : BITCODE_H;
          sweep_vector : BITCODE_3BD;
          sweep_transmatrix : PBITCODE_BD;
        end;
      Dwg_Entity_EXTRUDEDSURFACE = _dwg_entity_EXTRUDEDSURFACE;
      //PDwg_Entity_EXTRUDEDSURFACE = ^Dwg_Entity_EXTRUDEDSURFACE;

      //P_dwg_entity_SWEPTSURFACE = ^_dwg_entity_SWEPTSURFACE;
      _dwg_entity_SWEPTSURFACE = record
          parent : P_dwg_object_entity;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
          modeler_format_version : BITCODE_BS;
          u_isolines : BITCODE_BS;
          v_isolines : BITCODE_BS;
          class_version : BITCODE_BL;
          sweep_entity_id : BITCODE_BL;
          sweepdata_size : BITCODE_BL;
          sweepdata : BITCODE_TF;
          path_entity_id : BITCODE_BL;
          pathdata_size : BITCODE_BL;
          pathdata : BITCODE_TF;
          draft_angle : BITCODE_BD;
          draft_start_distance : BITCODE_BD;
          draft_end_distance : BITCODE_BD;
          twist_angle : BITCODE_BD;
          scale_factor : BITCODE_BD;
          align_angle : BITCODE_BD;
          sweep_entity_transmatrix : PBITCODE_BD;
          path_entity_transmatrix : PBITCODE_BD;
          is_solid : BITCODE_B;
          sweep_alignment_flags : BITCODE_BS;
          path_flags : BITCODE_BS;
          align_start : BITCODE_B;
          bank : BITCODE_B;
          base_point_set : BITCODE_B;
          sweep_entity_transform_computed : BITCODE_B;
          path_entity_transform_computed : BITCODE_B;
          reference_vector_for_controlling_twist : BITCODE_3BD;
          sweep_entity : BITCODE_H;
          path_entity : BITCODE_H;
        end;
      Dwg_Entity_SWEPTSURFACE = _dwg_entity_SWEPTSURFACE;
      //PDwg_Entity_SWEPTSURFACE = ^Dwg_Entity_SWEPTSURFACE;

      //P_dwg_entity_LOFTEDSURFACE = ^_dwg_entity_LOFTEDSURFACE;
      _dwg_entity_LOFTEDSURFACE = record
          parent : P_dwg_object_entity;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
          modeler_format_version : BITCODE_BS;
          u_isolines : BITCODE_BS;
          v_isolines : BITCODE_BS;
          loft_entity_transmatrix : PBITCODE_BD;
          plane_normal_lofting_type : BITCODE_BL;
          start_draft_angle : BITCODE_BD;
          end_draft_angle : BITCODE_BD;
          start_draft_magnitude : BITCODE_BD;
          end_draft_magnitude : BITCODE_BD;
          arc_length_parameterization : BITCODE_B;
          no_twist : BITCODE_B;
          align_direction : BITCODE_B;
          simple_surfaces : BITCODE_B;
          closed_surfaces : BITCODE_B;
          solid : BITCODE_B;
          ruled_surface : BITCODE_B;
          virtual_guide : BITCODE_B;
          num_cross_sections : BITCODE_BS;
          num_guide_curves : BITCODE_BS;
          cross_sections : PBITCODE_H;
          guide_curves : PBITCODE_H;
          path_curve : BITCODE_H;
        end;
      Dwg_Entity_LOFTEDSURFACE = _dwg_entity_LOFTEDSURFACE;
      //PDwg_Entity_LOFTEDSURFACE = ^Dwg_Entity_LOFTEDSURFACE;

      //P_dwg_entity_NURBSURFACE = ^_dwg_entity_NURBSURFACE;
      _dwg_entity_NURBSURFACE = record
          parent : P_dwg_object_entity;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
          u_isolines : BITCODE_BS;
          v_isolines : BITCODE_BS;
          short170 : BITCODE_BS;
          cv_hull_display : BITCODE_B;
          uvec1 : BITCODE_3BD;
          vvec1 : BITCODE_3BD;
          uvec2 : BITCODE_3BD;
          vvec2 : BITCODE_3BD;
        end;
      Dwg_Entity_NURBSURFACE = _dwg_entity_NURBSURFACE;
      //PDwg_Entity_NURBSURFACE = ^Dwg_Entity_NURBSURFACE;

      //P_dwg_entity_PLANESURFACE = ^_dwg_entity_PLANESURFACE;
      _dwg_entity_PLANESURFACE = record
          parent : P_dwg_object_entity;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
          modeler_format_version : BITCODE_BS;
          u_isolines : BITCODE_BS;
          v_isolines : BITCODE_BS;
          class_version : BITCODE_BL;
        end;
      Dwg_Entity_PLANESURFACE = _dwg_entity_PLANESURFACE;
      //PDwg_Entity_PLANESURFACE = ^Dwg_Entity_PLANESURFACE;

      //P_dwg_entity_REVOLVEDSURFACE = ^_dwg_entity_REVOLVEDSURFACE;
      _dwg_entity_REVOLVEDSURFACE = record
          parent : P_dwg_object_entity;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
          modeler_format_version : BITCODE_BS;
          u_isolines : BITCODE_BS;
          v_isolines : BITCODE_BS;
          class_version : BITCODE_BL;
          id : BITCODE_BL;
          axis_point : BITCODE_3BD;
          axis_vector : BITCODE_3BD;
          revolve_angle : BITCODE_BD;
          start_angle : BITCODE_BD;
          revolved_entity_transmatrix : PBITCODE_BD;
          draft_angle : BITCODE_BD;
          draft_start_distance : BITCODE_BD;
          draft_end_distance : BITCODE_BD;
          twist_angle : BITCODE_BD;
          solid : BITCODE_B;
          close_to_axis : BITCODE_B;
        end;
      Dwg_Entity_REVOLVEDSURFACE = _dwg_entity_REVOLVEDSURFACE;
      //PDwg_Entity_REVOLVEDSURFACE = ^Dwg_Entity_REVOLVEDSURFACE;

      //P_dwg_MESH_edge = ^_dwg_MESH_edge;
      _dwg_MESH_edge = record
          parent : P_dwg_entity_MESH;
          idxfrom : BITCODE_BL;
          idxto : BITCODE_BL;
        end;
      Dwg_MESH_edge = _dwg_MESH_edge;
      //PDwg_MESH_edge = ^Dwg_MESH_edge;

      //P_dwg_entity_MESH = ^_dwg_entity_MESH;
      _dwg_entity_MESH = record
          parent : P_dwg_object_entity;
          dlevel : BITCODE_BS;
          is_watertight : BITCODE_B;
          num_subdiv_vertex : BITCODE_BL;
          subdiv_vertex : PBITCODE_3DPOINT;
          num_vertex : BITCODE_BL;
          vertex : PBITCODE_3DPOINT;
          num_faces : BITCODE_BL;
          faces : PBITCODE_BL;
          num_edges : BITCODE_BL;
          edges : PDwg_MESH_edge;
          num_crease : BITCODE_BL;
          crease : PBITCODE_BD;
        end;
      Dwg_Entity_MESH = _dwg_entity_MESH;
      //PDwg_Entity_MESH = ^Dwg_Entity_MESH;

      //P_dwg_object_SUN = ^_dwg_object_SUN;
      _dwg_object_SUN = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          is_on : BITCODE_B;
          color : BITCODE_CMC;
          intensity : BITCODE_BD;
          has_shadow : BITCODE_B;
          julian_day : BITCODE_BL;
          msecs : BITCODE_BL;
          is_dst : BITCODE_B;
          shadow_type : BITCODE_BL;
          shadow_mapsize : BITCODE_BS;
          shadow_softness : BITCODE_RC;
        end;
      Dwg_Object_SUN = _dwg_object_SUN;
      //PDwg_Object_SUN = ^Dwg_Object_SUN;

      //P_dwg_SUNSTUDY_Dates = ^_dwg_SUNSTUDY_Dates;
      _dwg_SUNSTUDY_Dates = record
          julian_day : BITCODE_BL;
          msecs : BITCODE_BL;
        end;
      Dwg_SUNSTUDY_Dates = _dwg_SUNSTUDY_Dates;
      //PDwg_SUNSTUDY_Dates = ^Dwg_SUNSTUDY_Dates;

      //P_dwg_object_SUNSTUDY = ^_dwg_object_SUNSTUDY;
      _dwg_object_SUNSTUDY = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          setup_name : BITCODE_TV;
          description : BITCODE_TV;
          output_type : BITCODE_BL;
          sheet_set_name : BITCODE_TV;
          use_subset : BITCODE_B;
          sheet_subset_name : BITCODE_TV;
          select_dates_from_calendar : BITCODE_B;
          num_dates : BITCODE_BL;
          dates : PDwg_SUNSTUDY_Dates;
          select_range_of_dates : BITCODE_B;
          start_time : BITCODE_BL;
          end_time : BITCODE_BL;
          interval : BITCODE_BL;
          num_hours : BITCODE_BL;
          hours : PBITCODE_B;
          shade_plot_type : BITCODE_BL;
          numvports : BITCODE_BL;
          numrows : BITCODE_BL;
          numcols : BITCODE_BL;
          spacing : BITCODE_BD;
          lock_viewports : BITCODE_B;
          label_viewports : BITCODE_B;
          page_setup_wizard : BITCODE_H;
          view : BITCODE_H;
          visualstyle : BITCODE_H;
          text_style : BITCODE_H;
        end;
      Dwg_Object_SUNSTUDY = _dwg_object_SUNSTUDY;
      //PDwg_Object_SUNSTUDY = ^Dwg_Object_SUNSTUDY;

      //P_dwg_DATATABLE_row = ^_dwg_DATATABLE_row;
      _dwg_DATATABLE_row = record
          parent : P_dwg_DATATABLE_column;
          value : Dwg_TABLE_value;
        end;
      Dwg_DATATABLE_row = _dwg_DATATABLE_row;
      //PDwg_DATATABLE_row = ^Dwg_DATATABLE_row;

      //P_dwg_DATATABLE_column = ^_dwg_DATATABLE_column;
      _dwg_DATATABLE_column = record
          parent : P_dwg_object_DATATABLE;
          _type : BITCODE_BL;
          text : BITCODE_TV;
          rows : PDwg_DATATABLE_row;
        end;
      Dwg_DATATABLE_column = _dwg_DATATABLE_column;
      //PDwg_DATATABLE_column = ^Dwg_DATATABLE_column;

      //P_dwg_object_DATATABLE = ^_dwg_object_DATATABLE;
      _dwg_object_DATATABLE = record
          parent : P_dwg_object_object;
          flags : BITCODE_BS;
          num_cols : BITCODE_BL;
          num_rows : BITCODE_BL;
          table_name : BITCODE_TV;
          cols : PDwg_DATATABLE_column;
        end;
      Dwg_Object_DATATABLE = _dwg_object_DATATABLE;
      //PDwg_Object_DATATABLE = ^Dwg_Object_DATATABLE;

      //P_dwg_DATALINK_customdata = ^_dwg_DATALINK_customdata;
      _dwg_DATALINK_customdata = record
          parent : P_dwg_object_DATALINK;
          target : BITCODE_H;
          text : BITCODE_TV;
        end;
      Dwg_DATALINK_customdata = _dwg_DATALINK_customdata;
      //PDwg_DATALINK_customdata = ^Dwg_DATALINK_customdata;

      //P_dwg_object_DATALINK = ^_dwg_object_DATALINK;
      _dwg_object_DATALINK = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          data_adapter : BITCODE_TV;
          description : BITCODE_TV;
          tooltip : BITCODE_TV;
          connection_string : BITCODE_TV;
          option : BITCODE_BL;
          update_option : BITCODE_BL;
          bl92 : BITCODE_BL;
          year : BITCODE_BS;
          month : BITCODE_BS;
          day : BITCODE_BS;
          hour : BITCODE_BS;
          minute : BITCODE_BS;
          seconds : BITCODE_BS;
          msec : BITCODE_BS;
          path_option : BITCODE_BS;
          bl93 : BITCODE_BL;
          update_status : BITCODE_TV;
          num_customdata : BITCODE_BL;
          customdata : PDwg_DATALINK_customdata;
          hardowner : BITCODE_H;
        end;
      Dwg_Object_DATALINK = _dwg_object_DATALINK;
      //PDwg_Object_DATALINK = ^Dwg_Object_DATALINK;

      //P_dwg_DIMASSOC_Ref = ^_dwg_DIMASSOC_Ref;
      _dwg_DIMASSOC_Ref = record
          parent : P_dwg_object_DIMASSOC;
          classname : BITCODE_TV;
          osnap_type : BITCODE_RC;
          osnap_dist : BITCODE_BD;
          osnap_pt : BITCODE_3BD;
          num_xrefs : BITCODE_BS;
          xrefs : PBITCODE_H;
          main_subent_type : BITCODE_BS;
          main_gsmarker : BITCODE_BL;
          num_xrefpaths : BITCODE_BS;
          xrefpaths : PBITCODE_TV;
          has_lastpt_ref : BITCODE_B;
          lastpt_ref : BITCODE_3BD;
          num_intsectobj : BITCODE_BL;
          intsectobj : PBITCODE_H;
        end;
      Dwg_DIMASSOC_Ref = _dwg_DIMASSOC_Ref;
      //PDwg_DIMASSOC_Ref = ^Dwg_DIMASSOC_Ref;

      //P_dwg_object_DIMASSOC = ^_dwg_object_DIMASSOC;
      _dwg_object_DIMASSOC = record
          parent : P_dwg_object_object;
          dimensionobj : BITCODE_H;
          associativity : BITCODE_BL;
          trans_space_flag : BITCODE_B;
          rotated_type : BITCODE_RC;
          ref : PDwg_DIMASSOC_Ref;
        end;
      Dwg_Object_DIMASSOC = _dwg_object_DIMASSOC;
      //PDwg_Object_DIMASSOC = ^Dwg_Object_DIMASSOC;

      //P_dwg_ACTIONBODY = ^_dwg_ACTIONBODY;
      _dwg_ACTIONBODY = record
          parent : P_dwg_object_ASSOCNETWORK;
          evaluatorid : BITCODE_TV;
          expression : BITCODE_TV;
          value : BITCODE_BL;
        end;
      Dwg_ACTIONBODY = _dwg_ACTIONBODY;
      //PDwg_ACTIONBODY = ^Dwg_ACTIONBODY;

      //P_dwg_EvalVariant = ^_dwg_EvalVariant;
      _dwg_EvalVariant = record
          code : BITCODE_BS;
          u : record
              case longint of
                0 : ( bd : BITCODE_BD );
                1 : ( bl : BITCODE_BL );
                2 : ( bs : BITCODE_BS );
                3 : ( rc : BITCODE_RC );
                4 : ( text : BITCODE_TV );
                5 : ( handle : BITCODE_H );
              end;
        end;
      Dwg_EvalVariant = _dwg_EvalVariant;
      //PDwg_EvalVariant = ^Dwg_EvalVariant;

      //P_dwg_VALUEPARAM_vars = ^_dwg_VALUEPARAM_vars;
      _dwg_VALUEPARAM_vars = record
          value : Dwg_EvalVariant;
          handle : BITCODE_H;
        end;
      Dwg_VALUEPARAM_vars = _dwg_VALUEPARAM_vars;
      //PDwg_VALUEPARAM_vars = ^Dwg_VALUEPARAM_vars;

      //P_dwg_ASSOCPARAMBASEDACTIONBODY = ^_dwg_ASSOCPARAMBASEDACTIONBODY;
      _dwg_ASSOCPARAMBASEDACTIONBODY = record
          parent : P_dwg_object_object;
          version : BITCODE_BL;
          minor : BITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          l4 : BITCODE_BL;
          l5 : BITCODE_BL;
          assocdep : BITCODE_H;
          num_values : BITCODE_BL;
          values : P_dwg_VALUEPARAM;
        end;
      Dwg_ASSOCPARAMBASEDACTIONBODY = _dwg_ASSOCPARAMBASEDACTIONBODY;
      //PDwg_ASSOCPARAMBASEDACTIONBODY = ^Dwg_ASSOCPARAMBASEDACTIONBODY;

      //P_dwg_ASSOCACTION_Deps = ^_dwg_ASSOCACTION_Deps;
      _dwg_ASSOCACTION_Deps = record
          parent : P_dwg_object_ASSOCACTION;
          is_owned : BITCODE_B;
          dep : BITCODE_H;
        end;
      Dwg_ASSOCACTION_Deps = _dwg_ASSOCACTION_Deps;
      //PDwg_ASSOCACTION_Deps = ^Dwg_ASSOCACTION_Deps;

      //P_dwg_object_ASSOCDEPENDENCY = ^_dwg_object_ASSOCDEPENDENCY;
      _dwg_object_ASSOCDEPENDENCY = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          status : BITCODE_BL;
          is_read_dep : BITCODE_B;
          is_write_dep : BITCODE_B;
          is_attached_to_object : BITCODE_B;
          is_delegating_to_owning_action : BITCODE_B;
          order : BITCODE_BLd;
          dep_on : BITCODE_H;
          has_name : BITCODE_B;
          name : BITCODE_TV;
          depbodyid : BITCODE_BLd;
          readdep : BITCODE_H;
          dep_body : BITCODE_H;
          node : BITCODE_H;
        end;
      Dwg_Object_ASSOCDEPENDENCY = _dwg_object_ASSOCDEPENDENCY;
      //PDwg_Object_ASSOCDEPENDENCY = ^Dwg_Object_ASSOCDEPENDENCY;

      //P_dwg_object_ASSOCVALUEDEPENDENCY = ^_dwg_object_ASSOCVALUEDEPENDENCY;
      _dwg_object_ASSOCVALUEDEPENDENCY = record
          parent : P_dwg_object_object;
          assocdep : Dwg_Object_ASSOCDEPENDENCY;
        end;
      Dwg_Object_ASSOCVALUEDEPENDENCY = _dwg_object_ASSOCVALUEDEPENDENCY;
      //PDwg_Object_ASSOCVALUEDEPENDENCY = ^Dwg_Object_ASSOCVALUEDEPENDENCY;

      //P_dwg_object_ASSOCGEOMDEPENDENCY = ^_dwg_object_ASSOCGEOMDEPENDENCY;
      _dwg_object_ASSOCGEOMDEPENDENCY = record
          parent : P_dwg_object_object;
          assocdep : Dwg_Object_ASSOCDEPENDENCY;
          class_version : BITCODE_BS;
          enabled : BITCODE_B;
          classname : BITCODE_TV;
          dependent_on_compound_object : BITCODE_B;
        end;
      Dwg_Object_ASSOCGEOMDEPENDENCY = _dwg_object_ASSOCGEOMDEPENDENCY;
      //PDwg_Object_ASSOCGEOMDEPENDENCY = ^Dwg_Object_ASSOCGEOMDEPENDENCY;

      //P_dwg_object_ASSOCACTION = ^_dwg_object_ASSOCACTION;
      _dwg_object_ASSOCACTION = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          geometry_status : BITCODE_BL;
          owningnetwork : BITCODE_H;
          actionbody : BITCODE_H;
          action_index : BITCODE_BL;
          max_assoc_dep_index : BITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PDwg_ASSOCACTION_Deps;
          num_owned_params : BITCODE_BL;
          owned_params : PBITCODE_H;
          num_values : BITCODE_BL;
          values : P_dwg_VALUEPARAM;
        end;
      Dwg_Object_ASSOCACTION = _dwg_object_ASSOCACTION;
      //PDwg_Object_ASSOCACTION = ^Dwg_Object_ASSOCACTION;

      //P_dwg_object_ASSOCNETWORK = ^_dwg_object_ASSOCNETWORK;
      _dwg_object_ASSOCNETWORK = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          geometry_status : BITCODE_BL;
          owningnetwork : BITCODE_H;
          actionbody : BITCODE_H;
          action_index : BITCODE_BL;
          max_assoc_dep_index : BITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PDwg_ASSOCACTION_Deps;
          num_owned_params : BITCODE_BL;
          owned_params : PBITCODE_H;
          num_values : BITCODE_BL;
          values : P_dwg_VALUEPARAM;
          network_version : BITCODE_BS;
          network_action_index : BITCODE_BL;
          num_actions : BITCODE_BL;
          actions : PDwg_ASSOCACTION_Deps;
          num_owned_actions : BITCODE_BL;
          owned_actions : PBITCODE_H;
        end;
      Dwg_Object_ASSOCNETWORK = _dwg_object_ASSOCNETWORK;
      //PDwg_Object_ASSOCNETWORK = ^Dwg_Object_ASSOCNETWORK;

      //P_dwg_CONSTRAINTGROUPNODE = ^_dwg_CONSTRAINTGROUPNODE;
      _dwg_CONSTRAINTGROUPNODE = record
          parent : P_dwg_object_ASSOC2DCONSTRAINTGROUP;
          nodeid : BITCODE_BL;
          status : BITCODE_RC;
          num_connections : BITCODE_BL;
          connections : PBITCODE_BL;
        end;
      Dwg_CONSTRAINTGROUPNODE = _dwg_CONSTRAINTGROUPNODE;
      //PDwg_CONSTRAINTGROUPNODE = ^Dwg_CONSTRAINTGROUPNODE;

      //P_dwg_object_ASSOC2DCONSTRAINTGROUP = ^_dwg_object_ASSOC2DCONSTRAINTGROUP;
      _dwg_object_ASSOC2DCONSTRAINTGROUP = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          geometry_status : BITCODE_BL;
          owningnetwork : BITCODE_H;
          actionbody : BITCODE_H;
          action_index : BITCODE_BL;
          max_assoc_dep_index : BITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PDwg_ASSOCACTION_Deps;
          num_owned_params : BITCODE_BL;
          owned_params : PBITCODE_H;
          num_values : BITCODE_BL;
          values : P_dwg_VALUEPARAM;
          version : BITCODE_BL;
          b1 : BITCODE_B;
          workplane : array[0..2] of BITCODE_3BD;
          h1 : BITCODE_H;
          num_actions : BITCODE_BL;
          actions : PBITCODE_H;
          num_nodes : BITCODE_BL;
          nodes : PDwg_CONSTRAINTGROUPNODE;
        end;
      Dwg_Object_ASSOC2DCONSTRAINTGROUP = _dwg_object_ASSOC2DCONSTRAINTGROUP;
      //PDwg_Object_ASSOC2DCONSTRAINTGROUP = ^Dwg_Object_ASSOC2DCONSTRAINTGROUP;

      //P_dwg_object_ASSOCVARIABLE = ^_dwg_object_ASSOCVARIABLE;
      _dwg_object_ASSOCVARIABLE = record
          parent : P_dwg_object_object;
          av_class_version : BITCODE_BS;
          class_version : BITCODE_BS;
          geometry_status : BITCODE_BL;
          owningnetwork : BITCODE_H;
          actionbody : BITCODE_H;
          action_index : BITCODE_BL;
          max_assoc_dep_index : BITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PDwg_ASSOCACTION_Deps;
          num_owned_params : BITCODE_BL;
          owned_params : PBITCODE_H;
          num_values : BITCODE_BL;
          values : P_dwg_VALUEPARAM;
          name : BITCODE_TV;
          t58 : BITCODE_TV;
          evaluator : BITCODE_TV;
          desc : BITCODE_TV;
          value : Dwg_EvalVariant;
          has_t78 : BITCODE_B;
          t78 : BITCODE_TV;
          b290 : BITCODE_B;
        end;
      Dwg_Object_ASSOCVARIABLE = _dwg_object_ASSOCVARIABLE;
      //PDwg_Object_ASSOCVARIABLE = ^Dwg_Object_ASSOCVARIABLE;

      //P_dwg_VALUEPARAM = ^_dwg_VALUEPARAM;
      _dwg_VALUEPARAM = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          name : BITCODE_TV;
          unit_type : BITCODE_BL;
          num_vars : BITCODE_BL;
          vars : PDwg_VALUEPARAM_vars;
          controlled_objdep : BITCODE_H;
        end;
      Dwg_VALUEPARAM = _dwg_VALUEPARAM;
      //PDwg_VALUEPARAM = ^Dwg_VALUEPARAM;

      //P_dwg_EVAL_Node = ^_dwg_EVAL_Node;
      _dwg_EVAL_Node = record
          parent : P_dwg_object_EVALUATION_GRAPH;
          id : BITCODE_BL;
          edge_flags : BITCODE_BL;
          nextid : BITCODE_BLd;
          evalexpr : BITCODE_H;
          node : array[0..3] of BITCODE_BLd;
          active_cycles : BITCODE_B;
        end;
      Dwg_EVAL_Node = _dwg_EVAL_Node;
      //PDwg_EVAL_Node = ^Dwg_EVAL_Node;

      //P_dwg_EVAL_Edge = ^_dwg_EVAL_Edge;
      _dwg_EVAL_Edge = record
          parent : P_dwg_object_EVALUATION_GRAPH;
          id : BITCODE_BL;
          nextid : BITCODE_BLd;
          e1 : BITCODE_BLd;
          e2 : BITCODE_BLd;
          e3 : BITCODE_BLd;
          out_edge : array[0..4] of BITCODE_BLd;
        end;
      Dwg_EVAL_Edge = _dwg_EVAL_Edge;
      //PDwg_EVAL_Edge = ^Dwg_EVAL_Edge;

      //P_dwg_object_EVALUATION_GRAPH = ^_dwg_object_EVALUATION_GRAPH;
      _dwg_object_EVALUATION_GRAPH = record
          parent : P_dwg_object_object;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          first_nodeid : BITCODE_BLd;
          first_nodeid_copy : BITCODE_BLd;
          num_nodes : BITCODE_BL;
          nodes : PDwg_EVAL_Node;
          has_graph : BITCODE_B;
          num_edges : BITCODE_BL;
          edges : PDwg_EVAL_Edge;
        end;
      Dwg_Object_EVALUATION_GRAPH = _dwg_object_EVALUATION_GRAPH;
      //PDwg_Object_EVALUATION_GRAPH = ^Dwg_Object_EVALUATION_GRAPH;

      //P_dwg_object_DYNAMICBLOCKPURGEPREVENTER = ^_dwg_object_DYNAMICBLOCKPURGEPREVENTER;
      _dwg_object_DYNAMICBLOCKPURGEPREVENTER = record
          parent : P_dwg_object_object;
          flag : BITCODE_BS;
          block : BITCODE_H;
        end;
      Dwg_Object_DYNAMICBLOCKPURGEPREVENTER = _dwg_object_DYNAMICBLOCKPURGEPREVENTER;
      //PDwg_Object_DYNAMICBLOCKPURGEPREVENTER = ^Dwg_Object_DYNAMICBLOCKPURGEPREVENTER;

      //P_dwg_object_PERSUBENTMGR = ^_dwg_object_PERSUBENTMGR;
      _dwg_object_PERSUBENTMGR = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          unknown_0 : BITCODE_BL;
          unknown_2 : BITCODE_BL;
          numassocsteps : BITCODE_BL;
          numassocsubents : BITCODE_BL;
          num_steps : BITCODE_BL;
          steps : PBITCODE_BL;
          num_subents : BITCODE_BL;
          subents : PBITCODE_BL;
        end;
      Dwg_Object_PERSUBENTMGR = _dwg_object_PERSUBENTMGR;
      //PDwg_Object_PERSUBENTMGR = ^Dwg_Object_PERSUBENTMGR;

      //P_dwg_object_ASSOCPERSSUBENTMANAGER = ^_dwg_object_ASSOCPERSSUBENTMANAGER;
      _dwg_object_ASSOCPERSSUBENTMANAGER = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          unknown_3 : BITCODE_BL;
          unknown_0 : BITCODE_BL;
          unknown_2 : BITCODE_BL;
          num_steps : BITCODE_BL;
          num_subents : BITCODE_BL;
          steps : PBITCODE_BL;
          subents : PBITCODE_BL;
          unknown_bl6 : BITCODE_BL;
          unknown_bl6a : BITCODE_BL;
          unknown_bl7a : BITCODE_BL;
          unknown_bl7 : BITCODE_BL;
          unknown_bl8 : BITCODE_BL;
          unknown_bl9 : BITCODE_BL;
          unknown_bl10 : BITCODE_BL;
          unknown_bl11 : BITCODE_BL;
          unknown_bl12 : BITCODE_BL;
          unknown_bl13 : BITCODE_BL;
          unknown_bl14 : BITCODE_BL;
          unknown_bl15 : BITCODE_BL;
          unknown_bl16 : BITCODE_BL;
          unknown_bl17 : BITCODE_BL;
          unknown_bl18 : BITCODE_BL;
          unknown_bl19 : BITCODE_BL;
          unknown_bl20 : BITCODE_BL;
          unknown_bl21 : BITCODE_BL;
          unknown_bl22 : BITCODE_BL;
          unknown_bl23 : BITCODE_BL;
          unknown_bl24 : BITCODE_BL;
          unknown_bl25 : BITCODE_BL;
          unknown_bl26 : BITCODE_BL;
          unknown_bl27 : BITCODE_BL;
          unknown_bl28 : BITCODE_BL;
          unknown_bl29 : BITCODE_BL;
          unknown_bl30 : BITCODE_BL;
          unknown_bl31 : BITCODE_BL;
          unknown_bl32 : BITCODE_BL;
          unknown_bl33 : BITCODE_BL;
          unknown_bl34 : BITCODE_BL;
          unknown_bl35 : BITCODE_BL;
          unknown_bl36 : BITCODE_BL;
          unknown_b37 : BITCODE_B;
        end;
      Dwg_Object_ASSOCPERSSUBENTMANAGER = _dwg_object_ASSOCPERSSUBENTMANAGER;
      //PDwg_Object_ASSOCPERSSUBENTMANAGER = ^Dwg_Object_ASSOCPERSSUBENTMANAGER;

      //P_dwg_object_ASSOCACTIONPARAM = ^_dwg_object_ASSOCACTIONPARAM;
      _dwg_object_ASSOCACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
        end;
      Dwg_Object_ASSOCACTIONPARAM = _dwg_object_ASSOCACTIONPARAM;
      //PDwg_Object_ASSOCACTIONPARAM = ^Dwg_Object_ASSOCACTIONPARAM;

      //P_dwg_object_ASSOCOSNAPPOINTREFACTIONPARAM = ^_dwg_object_ASSOCOSNAPPOINTREFACTIONPARAM;
      _dwg_object_ASSOCOSNAPPOINTREFACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          class_version : BITCODE_BS;
          bs1 : BITCODE_BS;
          num_params : BITCODE_BL;
          params : PBITCODE_H;
          has_child_param : BITCODE_B;
          child_status : BITCODE_BS;
          child_id : BITCODE_BL;
          child_param : BITCODE_H;
          h330_2 : BITCODE_H;
          bl2 : BITCODE_BL;
          h330_3 : BITCODE_H;
          status : BITCODE_BS;
          osnap_mode : BITCODE_RC;
          param : BITCODE_BD;
        end;
      Dwg_Object_ASSOCOSNAPPOINTREFACTIONPARAM = _dwg_object_ASSOCOSNAPPOINTREFACTIONPARAM;
      //PDwg_Object_ASSOCOSNAPPOINTREFACTIONPARAM = ^Dwg_Object_ASSOCOSNAPPOINTREFACTIONPARAM;

      //P_dwg_object_ASSOCPOINTREFACTIONPARAM = ^_dwg_object_ASSOCPOINTREFACTIONPARAM;
      _dwg_object_ASSOCPOINTREFACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          class_version : BITCODE_BS;
          bs1 : BITCODE_BS;
          num_params : BITCODE_BL;
          params : PBITCODE_H;
          has_child_param : BITCODE_B;
          child_status : BITCODE_BS;
          child_id : BITCODE_BL;
          child_param : BITCODE_H;
          h330_2 : BITCODE_H;
          bl2 : BITCODE_BL;
          h330_3 : BITCODE_H;
        end;
      Dwg_Object_ASSOCPOINTREFACTIONPARAM = _dwg_object_ASSOCPOINTREFACTIONPARAM;
      //PDwg_Object_ASSOCPOINTREFACTIONPARAM = ^Dwg_Object_ASSOCPOINTREFACTIONPARAM;

      //P_dwg_object_ASSOCASMBODYACTIONPARAM = ^_dwg_object_ASSOCASMBODYACTIONPARAM;
      _dwg_object_ASSOCASMBODYACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          asdap_class_version : BITCODE_BL;
          dep : BITCODE_H;
          class_version : BITCODE_BL;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
        end;
      Dwg_Object_ASSOCASMBODYACTIONPARAM = _dwg_object_ASSOCASMBODYACTIONPARAM;
      //PDwg_Object_ASSOCASMBODYACTIONPARAM = ^Dwg_Object_ASSOCASMBODYACTIONPARAM;

      //P_dwg_object_ASSOCCOMPOUNDACTIONPARAM = ^_dwg_object_ASSOCCOMPOUNDACTIONPARAM;
      _dwg_object_ASSOCCOMPOUNDACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          class_version : BITCODE_BS;
          bs1 : BITCODE_BS;
          num_params : BITCODE_BL;
          params : PBITCODE_H;
          has_child_param : BITCODE_B;
          child_status : BITCODE_BS;
          child_id : BITCODE_BL;
          child_param : BITCODE_H;
          h330_2 : BITCODE_H;
          bl2 : BITCODE_BL;
          h330_3 : BITCODE_H;
        end;
      Dwg_Object_ASSOCCOMPOUNDACTIONPARAM = _dwg_object_ASSOCCOMPOUNDACTIONPARAM;
      //PDwg_Object_ASSOCCOMPOUNDACTIONPARAM = ^Dwg_Object_ASSOCCOMPOUNDACTIONPARAM;

      //P_dwg_object_ASSOCOBJECTACTIONPARAM = ^_dwg_object_ASSOCOBJECTACTIONPARAM;
      _dwg_object_ASSOCOBJECTACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          asdap_class_version : BITCODE_BL;
          dep : BITCODE_H;
          class_version : BITCODE_BS;
        end;
      Dwg_Object_ASSOCOBJECTACTIONPARAM = _dwg_object_ASSOCOBJECTACTIONPARAM;
      //PDwg_Object_ASSOCOBJECTACTIONPARAM = ^Dwg_Object_ASSOCOBJECTACTIONPARAM;

      //P_dwg_object_ASSOCEDGEACTIONPARAM = ^_dwg_object_ASSOCEDGEACTIONPARAM;
      _dwg_object_ASSOCEDGEACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          asdap_class_version : BITCODE_BL;
          dep : BITCODE_H;
          class_version : BITCODE_BL;
          param : BITCODE_H;
          has_action : BITCODE_B;
          action_type : BITCODE_BL;
          subent : BITCODE_H;
        end;
      Dwg_Object_ASSOCEDGEACTIONPARAM = _dwg_object_ASSOCEDGEACTIONPARAM;
      //PDwg_Object_ASSOCEDGEACTIONPARAM = ^Dwg_Object_ASSOCEDGEACTIONPARAM;

      //P_dwg_object_ASSOCFACEACTIONPARAM = ^_dwg_object_ASSOCFACEACTIONPARAM;
      _dwg_object_ASSOCFACEACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          asdap_class_version : BITCODE_BL;
          dep : BITCODE_H;
          class_version : BITCODE_BL;
          index : BITCODE_BL;
        end;
      Dwg_Object_ASSOCFACEACTIONPARAM = _dwg_object_ASSOCFACEACTIONPARAM;
      //PDwg_Object_ASSOCFACEACTIONPARAM = ^Dwg_Object_ASSOCFACEACTIONPARAM;

      //P_dwg_object_ASSOCPATHACTIONPARAM = ^_dwg_object_ASSOCPATHACTIONPARAM;
      _dwg_object_ASSOCPATHACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          class_version : BITCODE_BS;
          bs1 : BITCODE_BS;
          num_params : BITCODE_BL;
          params : PBITCODE_H;
          has_child_param : BITCODE_B;
          child_status : BITCODE_BS;
          child_id : BITCODE_BL;
          child_param : BITCODE_H;
          h330_2 : BITCODE_H;
          bl2 : BITCODE_BL;
          h330_3 : BITCODE_H;
          version : BITCODE_BL;
        end;
      Dwg_Object_ASSOCPATHACTIONPARAM = _dwg_object_ASSOCPATHACTIONPARAM;
      //PDwg_Object_ASSOCPATHACTIONPARAM = ^Dwg_Object_ASSOCPATHACTIONPARAM;

      //P_dwg_object_ASSOCVERTEXACTIONPARAM = ^_dwg_object_ASSOCVERTEXACTIONPARAM;
      _dwg_object_ASSOCVERTEXACTIONPARAM = record
          parent : P_dwg_object_object;
          is_r2013 : BITCODE_BS;
          aap_version : BITCODE_BL;
          name : BITCODE_TV;
          asdap_class_version : BITCODE_BL;
          dep : BITCODE_H;
          class_version : BITCODE_BL;
          pt : BITCODE_3BD;
        end;
      Dwg_Object_ASSOCVERTEXACTIONPARAM = _dwg_object_ASSOCVERTEXACTIONPARAM;
      //PDwg_Object_ASSOCVERTEXACTIONPARAM = ^Dwg_Object_ASSOCVERTEXACTIONPARAM;

      //P_dwg_ASSOCARRAYITEM = ^_dwg_ASSOCARRAYITEM;
      _dwg_ASSOCARRAYITEM = record
          parent : P_dwg_abstractobject_ASSOCARRAYPARAMETERS;
          class_version : BITCODE_BL;
          itemloc : array[0..2] of BITCODE_BL;
          flags : BITCODE_BL;
          is_default_transmatrix : longint;
          x_dir : BITCODE_3BD;
          transmatrix : PBITCODE_BD;
          rel_transform : PBITCODE_BD;
          has_h1 : longint;
          h1 : BITCODE_H;
          h2 : BITCODE_H;
        end;
      Dwg_ASSOCARRAYITEM = _dwg_ASSOCARRAYITEM;
      //PDwg_ASSOCARRAYITEM = ^Dwg_ASSOCARRAYITEM;

      //P_dwg_abstractobject_ASSOCARRAYPARAMETERS = ^_dwg_abstractobject_ASSOCARRAYPARAMETERS;
      _dwg_abstractobject_ASSOCARRAYPARAMETERS = record
          parent : P_dwg_object_object;
          aap_version : BITCODE_BL;
          num_items : BITCODE_BL;
          classname : BITCODE_TV;
          items : PDwg_ASSOCARRAYITEM;
          numitems : BITCODE_BL;
          numrows : BITCODE_BL;
          numlevels : BITCODE_BL;
        end;
      Dwg_Object_ASSOCARRAYPARAMETERS = _dwg_abstractobject_ASSOCARRAYPARAMETERS;
      //PDwg_Object_ASSOCARRAYPARAMETERS = ^Dwg_Object_ASSOCARRAYPARAMETERS;
      Dwg_Object_ASSOCARRAYMODIFYPARAMETERS =_dwg_abstractobject_ASSOCARRAYPARAMETERS;
      Dwg_Object_ASSOCARRAYPATHPARAMETERS = _dwg_abstractobject_ASSOCARRAYPARAMETERS;
      Dwg_Object_ASSOCARRAYPOLARPARAMETERS = _dwg_abstractobject_ASSOCARRAYPARAMETERS;
      Dwg_Object_ASSOCARRAYRECTANGULARPARAMETERS = _dwg_abstractobject_ASSOCARRAYPARAMETERS;

      //P_dwg_object_ASSOCRESTOREENTITYSTATEACTIONBODY = ^_dwg_object_ASSOCRESTOREENTITYSTATEACTIONBODY;
      _dwg_object_ASSOCRESTOREENTITYSTATEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          class_version : BITCODE_BL;
          entity : BITCODE_H;
        end;
      Dwg_Object_ASSOCRESTOREENTITYSTATEACTIONBODY = _dwg_object_ASSOCRESTOREENTITYSTATEACTIONBODY;
      //PDwg_Object_ASSOCRESTOREENTITYSTATEACTIONBODY = ^Dwg_Object_ASSOCRESTOREENTITYSTATEACTIONBODY;

      //P_dwg_ASSOCSURFACEACTIONBODY = ^_dwg_ASSOCSURFACEACTIONBODY;
      _dwg_ASSOCSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          version : BITCODE_BL;
          is_semi_assoc : BITCODE_B;
          l2 : BITCODE_BL;
          is_semi_ovr : BITCODE_B;
          grip_status : BITCODE_BS;
          assocdep : BITCODE_H;
        end;
      Dwg_ASSOCSURFACEACTIONBODY = _dwg_ASSOCSURFACEACTIONBODY;
      //PDwg_ASSOCSURFACEACTIONBODY = ^Dwg_ASSOCSURFACEACTIONBODY;

      //P_dwg_object_ASSOCEXTENDSURFACEACTIONBODY = ^_dwg_object_ASSOCEXTENDSURFACEACTIONBODY;
      _dwg_object_ASSOCEXTENDSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
          option : BITCODE_RC;
        end;
      Dwg_Object_ASSOCEXTENDSURFACEACTIONBODY = _dwg_object_ASSOCEXTENDSURFACEACTIONBODY;
      //PDwg_Object_ASSOCEXTENDSURFACEACTIONBODY = ^Dwg_Object_ASSOCEXTENDSURFACEACTIONBODY;

      //P_dwg_object_ASSOCEXTRUDEDSURFACEACTIONBODY = ^_dwg_object_ASSOCEXTRUDEDSURFACEACTIONBODY;
      _dwg_object_ASSOCEXTRUDEDSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_ASSOCEXTRUDEDSURFACEACTIONBODY = _dwg_object_ASSOCEXTRUDEDSURFACEACTIONBODY;
      //PDwg_Object_ASSOCEXTRUDEDSURFACEACTIONBODY = ^Dwg_Object_ASSOCEXTRUDEDSURFACEACTIONBODY;

      //P_dwg_object_ASSOCPLANESURFACEACTIONBODY = ^_dwg_object_ASSOCPLANESURFACEACTIONBODY;
      _dwg_object_ASSOCPLANESURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_ASSOCPLANESURFACEACTIONBODY = _dwg_object_ASSOCPLANESURFACEACTIONBODY;
      //PDwg_Object_ASSOCPLANESURFACEACTIONBODY = ^Dwg_Object_ASSOCPLANESURFACEACTIONBODY;

      //P_dwg_object_ASSOCLOFTEDSURFACEACTIONBODY = ^_dwg_object_ASSOCLOFTEDSURFACEACTIONBODY;
      _dwg_object_ASSOCLOFTEDSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_ASSOCLOFTEDSURFACEACTIONBODY = _dwg_object_ASSOCLOFTEDSURFACEACTIONBODY;
      //PDwg_Object_ASSOCLOFTEDSURFACEACTIONBODY = ^Dwg_Object_ASSOCLOFTEDSURFACEACTIONBODY;

      //P_dwg_object_ASSOCNETWORKSURFACEACTIONBODY = ^_dwg_object_ASSOCNETWORKSURFACEACTIONBODY;
      _dwg_object_ASSOCNETWORKSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_ASSOCNETWORKSURFACEACTIONBODY = _dwg_object_ASSOCNETWORKSURFACEACTIONBODY;
      //PDwg_Object_ASSOCNETWORKSURFACEACTIONBODY = ^Dwg_Object_ASSOCNETWORKSURFACEACTIONBODY;

      //P_dwg_object_ASSOCOFFSETSURFACEACTIONBODY = ^_dwg_object_ASSOCOFFSETSURFACEACTIONBODY;
      _dwg_object_ASSOCOFFSETSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
          b1 : BITCODE_B;
        end;
      Dwg_Object_ASSOCOFFSETSURFACEACTIONBODY = _dwg_object_ASSOCOFFSETSURFACEACTIONBODY;
      //PDwg_Object_ASSOCOFFSETSURFACEACTIONBODY = ^Dwg_Object_ASSOCOFFSETSURFACEACTIONBODY;

      //P_dwg_object_ASSOCREVOLVEDSURFACEACTIONBODY = ^_dwg_object_ASSOCREVOLVEDSURFACEACTIONBODY;
      _dwg_object_ASSOCREVOLVEDSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_ASSOCREVOLVEDSURFACEACTIONBODY = _dwg_object_ASSOCREVOLVEDSURFACEACTIONBODY;
      //PDwg_Object_ASSOCREVOLVEDSURFACEACTIONBODY = ^Dwg_Object_ASSOCREVOLVEDSURFACEACTIONBODY;

      //P_dwg_object_ASSOCSWEPTSURFACEACTIONBODY = ^_dwg_object_ASSOCSWEPTSURFACEACTIONBODY;
      _dwg_object_ASSOCSWEPTSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_ASSOCSWEPTSURFACEACTIONBODY = _dwg_object_ASSOCSWEPTSURFACEACTIONBODY;
      //PDwg_Object_ASSOCSWEPTSURFACEACTIONBODY = ^Dwg_Object_ASSOCSWEPTSURFACEACTIONBODY;

      //P_dwg_object_ASSOCEDGECHAMFERACTIONBODY = ^_dwg_object_ASSOCEDGECHAMFERACTIONBODY;
      _dwg_object_ASSOCEDGECHAMFERACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
        end;
      Dwg_Object_ASSOCEDGECHAMFERACTIONBODY = _dwg_object_ASSOCEDGECHAMFERACTIONBODY;
      //PDwg_Object_ASSOCEDGECHAMFERACTIONBODY = ^Dwg_Object_ASSOCEDGECHAMFERACTIONBODY;

      //P_dwg_object_ASSOCEDGEFILLETACTIONBODY = ^_dwg_object_ASSOCEDGEFILLETACTIONBODY;
      _dwg_object_ASSOCEDGEFILLETACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
        end;
      Dwg_Object_ASSOCEDGEFILLETACTIONBODY = _dwg_object_ASSOCEDGEFILLETACTIONBODY;
      //PDwg_Object_ASSOCEDGEFILLETACTIONBODY = ^Dwg_Object_ASSOCEDGEFILLETACTIONBODY;

      //P_dwg_object_ASSOCTRIMSURFACEACTIONBODY = ^_dwg_object_ASSOCTRIMSURFACEACTIONBODY;
      _dwg_object_ASSOCTRIMSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
          b1 : BITCODE_B;
          b2 : BITCODE_B;
          distance : BITCODE_BD;
        end;
      Dwg_Object_ASSOCTRIMSURFACEACTIONBODY = _dwg_object_ASSOCTRIMSURFACEACTIONBODY;
      //PDwg_Object_ASSOCTRIMSURFACEACTIONBODY = ^Dwg_Object_ASSOCTRIMSURFACEACTIONBODY;

      //P_dwg_object_ASSOCBLENDSURFACEACTIONBODY = ^_dwg_object_ASSOCBLENDSURFACEACTIONBODY;
      _dwg_object_ASSOCBLENDSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
          b1 : BITCODE_B;
          b2 : BITCODE_B;
          b3 : BITCODE_B;
          b4 : BITCODE_B;
          b5 : BITCODE_B;
          blend_options : BITCODE_BS;
          bs2 : BITCODE_BS;
        end;
      Dwg_Object_ASSOCBLENDSURFACEACTIONBODY = _dwg_object_ASSOCBLENDSURFACEACTIONBODY;
      //PDwg_Object_ASSOCBLENDSURFACEACTIONBODY = ^Dwg_Object_ASSOCBLENDSURFACEACTIONBODY;

      //P_dwg_object_ASSOCFILLETSURFACEACTIONBODY = ^_dwg_object_ASSOCFILLETSURFACEACTIONBODY;
      _dwg_object_ASSOCFILLETSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
          status : BITCODE_BS;
          pt1 : BITCODE_2RD;
          pt2 : BITCODE_2RD;
        end;
      Dwg_Object_ASSOCFILLETSURFACEACTIONBODY = _dwg_object_ASSOCFILLETSURFACEACTIONBODY;
      //PDwg_Object_ASSOCFILLETSURFACEACTIONBODY = ^Dwg_Object_ASSOCFILLETSURFACEACTIONBODY;

      //P_dwg_object_ASSOCPATCHSURFACEACTIONBODY = ^_dwg_object_ASSOCPATCHSURFACEACTIONBODY;
      _dwg_object_ASSOCPATCHSURFACEACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          sab : Dwg_ASSOCSURFACEACTIONBODY;
          pbsab_status : BITCODE_BL;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_ASSOCPATCHSURFACEACTIONBODY = _dwg_object_ASSOCPATCHSURFACEACTIONBODY;
      //PDwg_Object_ASSOCPATCHSURFACEACTIONBODY = ^Dwg_Object_ASSOCPATCHSURFACEACTIONBODY;

      //P_dwg_ASSOCACTIONBODY_action = ^_dwg_ASSOCACTIONBODY_action;
      _dwg_ASSOCACTIONBODY_action = record
          parent : P_dwg_object_ASSOCMLEADERACTIONBODY;
          depid : BITCODE_BL;
          dep : BITCODE_H;
        end;
      Dwg_ASSOCACTIONBODY_action = _dwg_ASSOCACTIONBODY_action;
      //PDwg_ASSOCACTIONBODY_action = ^Dwg_ASSOCACTIONBODY_action;

      //P_dwg_object_ASSOCMLEADERACTIONBODY = ^_dwg_object_ASSOCMLEADERACTIONBODY;
      _dwg_object_ASSOCMLEADERACTIONBODY = record
          parent : P_dwg_object_object;
          aaab_version : BITCODE_BS;
          assoc_dep : BITCODE_H;
          aab_version : BITCODE_BS;
          actionbody : BITCODE_H;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          class_version : BITCODE_BL;
          num_actions : BITCODE_BL;
          actions : PDwg_ASSOCACTIONBODY_action;
        end;
      Dwg_Object_ASSOCMLEADERACTIONBODY = _dwg_object_ASSOCMLEADERACTIONBODY;
      //PDwg_Object_ASSOCMLEADERACTIONBODY = ^Dwg_Object_ASSOCMLEADERACTIONBODY;

      //P_dwg_object_ASSOCALIGNEDDIMACTIONBODY = ^_dwg_object_ASSOCALIGNEDDIMACTIONBODY;
      _dwg_object_ASSOCALIGNEDDIMACTIONBODY = record
          parent : P_dwg_object_object;
          aaab_version : BITCODE_BS;
          assoc_dep : BITCODE_H;
          aab_version : BITCODE_BS;
          actionbody : BITCODE_H;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          class_version : BITCODE_BL;
          r_node : BITCODE_H;
          d_node : BITCODE_H;
        end;
      Dwg_Object_ASSOCALIGNEDDIMACTIONBODY = _dwg_object_ASSOCALIGNEDDIMACTIONBODY;
      //PDwg_Object_ASSOCALIGNEDDIMACTIONBODY = ^Dwg_Object_ASSOCALIGNEDDIMACTIONBODY;

      //P_dwg_object_ASSOC3POINTANGULARDIMACTIONBODY = ^_dwg_object_ASSOC3POINTANGULARDIMACTIONBODY;
      _dwg_object_ASSOC3POINTANGULARDIMACTIONBODY = record
          parent : P_dwg_object_object;
          aaab_version : BITCODE_BS;
          assoc_dep : BITCODE_H;
          aab_version : BITCODE_BS;
          actionbody : BITCODE_H;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          class_version : BITCODE_BS;
          r_node : BITCODE_H;
          d_node : BITCODE_H;
          assocdep : BITCODE_H;
        end;
      Dwg_Object_ASSOC3POINTANGULARDIMACTIONBODY = _dwg_object_ASSOC3POINTANGULARDIMACTIONBODY;
      //PDwg_Object_ASSOC3POINTANGULARDIMACTIONBODY = ^Dwg_Object_ASSOC3POINTANGULARDIMACTIONBODY;

      //P_dwg_object_ASSOCORDINATEDIMACTIONBODY = ^_dwg_object_ASSOCORDINATEDIMACTIONBODY;
      _dwg_object_ASSOCORDINATEDIMACTIONBODY = record
          parent : P_dwg_object_object;
          aaab_version : BITCODE_BS;
          assoc_dep : BITCODE_H;
          aab_version : BITCODE_BS;
          actionbody : BITCODE_H;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          class_version : BITCODE_BL;
          r_node : BITCODE_H;
          d_node : BITCODE_H;
        end;
      Dwg_Object_ASSOCORDINATEDIMACTIONBODY = _dwg_object_ASSOCORDINATEDIMACTIONBODY;
      //PDwg_Object_ASSOCORDINATEDIMACTIONBODY = ^Dwg_Object_ASSOCORDINATEDIMACTIONBODY;

      //P_dwg_object_ASSOCROTATEDDIMACTIONBODY = ^_dwg_object_ASSOCROTATEDDIMACTIONBODY;
      _dwg_object_ASSOCROTATEDDIMACTIONBODY = record
          parent : P_dwg_object_object;
          aaab_version : BITCODE_BS;
          assoc_dep : BITCODE_H;
          aab_version : BITCODE_BS;
          actionbody : BITCODE_H;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          class_version : BITCODE_BS;
          r_node : BITCODE_H;
          d_node : BITCODE_H;
        end;
      Dwg_Object_ASSOCROTATEDDIMACTIONBODY = _dwg_object_ASSOCROTATEDDIMACTIONBODY;
      //PDwg_Object_ASSOCROTATEDDIMACTIONBODY = ^Dwg_Object_ASSOCROTATEDDIMACTIONBODY;

      //P_dwg_object_ASSOCDIMDEPENDENCYBODY = ^_dwg_object_ASSOCDIMDEPENDENCYBODY;
      _dwg_object_ASSOCDIMDEPENDENCYBODY = record
          parent : P_dwg_object_object;
          adb_version : BITCODE_BS;
          dimbase_version : BITCODE_BS;
          name : BITCODE_TV;
          class_version : BITCODE_BS;
        end;
      Dwg_Object_ASSOCDIMDEPENDENCYBODY = _dwg_object_ASSOCDIMDEPENDENCYBODY;
      //PDwg_Object_ASSOCDIMDEPENDENCYBODY = ^Dwg_Object_ASSOCDIMDEPENDENCYBODY;

      //P_dwg_object_BLOCKPARAMDEPENDENCYBODY = ^_dwg_object_BLOCKPARAMDEPENDENCYBODY;
      _dwg_object_BLOCKPARAMDEPENDENCYBODY = record
          parent : P_dwg_object_object;
          adb_version : BITCODE_BS;
          dimbase_version : BITCODE_BS;
          name : BITCODE_TV;
          class_version : BITCODE_BS;
        end;
      Dwg_Object_BLOCKPARAMDEPENDENCYBODY = _dwg_object_BLOCKPARAMDEPENDENCYBODY;
      //PDwg_Object_BLOCKPARAMDEPENDENCYBODY = ^Dwg_Object_BLOCKPARAMDEPENDENCYBODY;

      //P_dwg_ARRAYITEMLOCATOR = ^_dwg_ARRAYITEMLOCATOR;
      _dwg_ARRAYITEMLOCATOR = record
          parent : P_dwg_object_ASSOCARRAYMODIFYACTIONBODY;
          itemloc1 : BITCODE_BL;
          itemloc2 : BITCODE_BL;
          itemloc3 : BITCODE_BL;
        end;
      Dwg_ARRAYITEMLOCATOR = _dwg_ARRAYITEMLOCATOR;
      //PDwg_ARRAYITEMLOCATOR = ^Dwg_ARRAYITEMLOCATOR;

      //P_dwg_object_ASSOCARRAYACTIONBODY = ^_dwg_object_ASSOCARRAYACTIONBODY;
      _dwg_object_ASSOCARRAYACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          aaab_version : BITCODE_BL;
          paramblock : BITCODE_TV;
          transmatrix : PBITCODE_BD;
        end;
      Dwg_Object_ASSOCARRAYACTIONBODY = _dwg_object_ASSOCARRAYACTIONBODY;
      //PDwg_Object_ASSOCARRAYACTIONBODY = ^Dwg_Object_ASSOCARRAYACTIONBODY;

      //P_dwg_object_ASSOCARRAYMODIFYACTIONBODY = ^_dwg_object_ASSOCARRAYMODIFYACTIONBODY;
      _dwg_object_ASSOCARRAYMODIFYACTIONBODY = record
          parent : P_dwg_object_object;
          aab_version : BITCODE_BL;
          pab : Dwg_ASSOCPARAMBASEDACTIONBODY;
          aaab_version : BITCODE_BL;
          paramblock : BITCODE_TV;
          transmatrix : PBITCODE_BD;
          status : BITCODE_BS;
          num_items : BITCODE_BL;
          items : PDwg_ARRAYITEMLOCATOR;
        end;
      Dwg_Object_ASSOCARRAYMODIFYACTIONBODY = _dwg_object_ASSOCARRAYMODIFYACTIONBODY;
      //PDwg_Object_ASSOCARRAYMODIFYACTIONBODY = ^Dwg_Object_ASSOCARRAYMODIFYACTIONBODY;

      //P_dwg_EvalExpr = ^_dwg_EvalExpr;
      _dwg_EvalExpr = record
          parentid : BITCODE_BLd;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          value_code : BITCODE_BSd;
          value : record
              case longint of
                0 : ( num40 : BITCODE_BD );
                1 : ( pt2d : BITCODE_2RD );
                2 : ( pt3d : BITCODE_3BD );
                3 : ( text1 : BITCODE_TV );
                4 : ( long90 : BITCODE_BL );
                5 : ( handle91 : BITCODE_H );
                6 : ( short70 : BITCODE_BS );
              end;
          nodeid : BITCODE_BL;
        end;
      Dwg_EvalExpr = _dwg_EvalExpr;
      //PDwg_EvalExpr = ^Dwg_EvalExpr;

      //P_dwg_ACSH_SubentMaterial = ^_dwg_ACSH_SubentMaterial;
      _dwg_ACSH_SubentMaterial = record
          major : BITCODE_BL;
          minor : BITCODE_BL;
          reflectance : BITCODE_BL;
          displacement : BITCODE_BL;
        end;
      Dwg_ACSH_SubentMaterial = _dwg_ACSH_SubentMaterial;
      //PDwg_ACSH_SubentMaterial = ^Dwg_ACSH_SubentMaterial;

      //P_dwg_ACSH_SubentColor = ^_dwg_ACSH_SubentColor;
      _dwg_ACSH_SubentColor = record
          major : BITCODE_BL;
          minor : BITCODE_BL;
          transparency : BITCODE_BL;
          bl93 : BITCODE_BL;
          is_face_variable : BITCODE_B;
        end;
      Dwg_ACSH_SubentColor = _dwg_ACSH_SubentColor;
      //PDwg_ACSH_SubentColor = ^Dwg_ACSH_SubentColor;

      //P_dwg_ACSH_HistoryNode = ^_dwg_ACSH_HistoryNode;
      _dwg_ACSH_HistoryNode = record
          major : BITCODE_BL;
          minor : BITCODE_BL;
          trans : PBITCODE_BD;
          color : BITCODE_CMC;
          step_id : BITCODE_BL;
          material : BITCODE_H;
        end;
      Dwg_ACSH_HistoryNode = _dwg_ACSH_HistoryNode;
      //PDwg_ACSH_HistoryNode = ^Dwg_ACSH_HistoryNode;

      //P_dwg_object_ACSH_HISTORY_CLASS = ^_dwg_object_ACSH_HISTORY_CLASS;
      _dwg_object_ACSH_HISTORY_CLASS = record
          parent : P_dwg_object_object;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          owner : BITCODE_H;
          h_nodeid : BITCODE_BL;
          show_history : BITCODE_B;
          record_history : BITCODE_B;
        end;
      Dwg_Object_ACSH_HISTORY_CLASS = _dwg_object_ACSH_HISTORY_CLASS;
      //PDwg_Object_ACSH_HISTORY_CLASS = ^Dwg_Object_ACSH_HISTORY_CLASS;

      //P_dwg_object_ACSH_BOX_CLASS = ^_dwg_object_ACSH_BOX_CLASS;
      _dwg_object_ACSH_BOX_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          length : BITCODE_BD;
          width : BITCODE_BD;
          height : BITCODE_BD;
        end;
      Dwg_Object_ACSH_BOX_CLASS = _dwg_object_ACSH_BOX_CLASS;
      //PDwg_Object_ACSH_BOX_CLASS = ^Dwg_Object_ACSH_BOX_CLASS;

      //P_dwg_object_ACSH_WEDGE_CLASS = ^_dwg_object_ACSH_WEDGE_CLASS;
      _dwg_object_ACSH_WEDGE_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          length : BITCODE_BD;
          width : BITCODE_BD;
          height : BITCODE_BD;
        end;
      Dwg_Object_ACSH_WEDGE_CLASS = _dwg_object_ACSH_WEDGE_CLASS;
      //PDwg_Object_ACSH_WEDGE_CLASS = ^Dwg_Object_ACSH_WEDGE_CLASS;

      //P_dwg_object_ACSH_BOOLEAN_CLASS = ^_dwg_object_ACSH_BOOLEAN_CLASS;
      _dwg_object_ACSH_BOOLEAN_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          operation : BITCODE_RCd;
          operand1 : BITCODE_BL;
          operand2 : BITCODE_BL;
        end;
      Dwg_Object_ACSH_BOOLEAN_CLASS = _dwg_object_ACSH_BOOLEAN_CLASS;
      //PDwg_Object_ACSH_BOOLEAN_CLASS = ^Dwg_Object_ACSH_BOOLEAN_CLASS;

      //P_dwg_object_ACSH_BREP_CLASS = ^_dwg_object_ACSH_BREP_CLASS;
      _dwg_object_ACSH_BREP_CLASS = record
          parent : P_dwg_object_object;
          acis_empty : BITCODE_B;
          unknown : BITCODE_B;
          version : BITCODE_BS;
          num_blocks : BITCODE_BL;
          block_size : PBITCODE_BL;
          encr_sat_data : ^Pchar;
          sab_size : BITCODE_BL;
          acis_data : PBITCODE_RC;
          wireframe_data_present : BITCODE_B;
          point_present : BITCODE_B;
          point : BITCODE_3BD;
          isolines : BITCODE_BL;
          isoline_present : BITCODE_B;
          num_wires : BITCODE_BL;
          wires : PDwg_3DSOLID_wire;
          num_silhouettes : BITCODE_BL;
          silhouettes : PDwg_3DSOLID_silhouette;
          _dxf_sab_converted : BITCODE_B;
          acis_empty2 : BITCODE_B;
          extra_acis_data : P_dwg_entity_3DSOLID;
          num_materials : BITCODE_BL;
          materials : PDwg_3DSOLID_material;
          revision_guid : array[0..38] of BITCODE_RC;
          revision_major : BITCODE_BL;
          revision_minor1 : BITCODE_BS;
          revision_minor2 : BITCODE_BS;
          revision_bytes : array[0..8] of BITCODE_RC;
          end_marker : BITCODE_BL;
          history_id : BITCODE_H;
          has_revision_guid : BITCODE_B;
          acis_empty_bit : BITCODE_B;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
        end;
      Dwg_Object_ACSH_BREP_CLASS = _dwg_object_ACSH_BREP_CLASS;
      //PDwg_Object_ACSH_BREP_CLASS = ^Dwg_Object_ACSH_BREP_CLASS;

      //P_dwg_object_ACSH_SWEEP_CLASS = ^_dwg_object_ACSH_SWEEP_CLASS;
      _dwg_object_ACSH_SWEEP_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          direction : BITCODE_3BD;
          bl92 : BITCODE_BL;
          shsw_text_size : BITCODE_BL;
          shsw_text : BITCODE_TF;
          shsw_bl93 : BITCODE_BL;
          shsw_text2_size : BITCODE_BL;
          shsw_text2 : BITCODE_TF;
          draft_angle : BITCODE_BD;
          start_draft_dist : BITCODE_BD;
          end_draft_dist : BITCODE_BD;
          scale_factor : BITCODE_BD;
          twist_angle : BITCODE_BD;
          align_angle : BITCODE_BD;
          sweepentity_transform : PBITCODE_BD;
          pathentity_transform : PBITCODE_BD;
          align_option : BITCODE_RC;
          miter_option : BITCODE_RC;
          has_align_start : BITCODE_B;
          bank : BITCODE_B;
          check_intersections : BITCODE_B;
          shsw_b294 : BITCODE_B;
          shsw_b295 : BITCODE_B;
          shsw_b296 : BITCODE_B;
          pt2 : BITCODE_3BD;
        end;
      Dwg_Object_ACSH_SWEEP_CLASS = _dwg_object_ACSH_SWEEP_CLASS;
      //PDwg_Object_ACSH_SWEEP_CLASS = ^Dwg_Object_ACSH_SWEEP_CLASS;

      //P_dwg_object_ACSH_EXTRUSION_CLASS = ^_dwg_object_ACSH_EXTRUSION_CLASS;
      _dwg_object_ACSH_EXTRUSION_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          direction : BITCODE_3BD;
          bl92 : BITCODE_BL;
          shsw_text_size : BITCODE_BL;
          shsw_text : BITCODE_TF;
          shsw_bl93 : BITCODE_BL;
          shsw_text2_size : BITCODE_BL;
          shsw_text2 : BITCODE_TF;
          draft_angle : BITCODE_BD;
          start_draft_dist : BITCODE_BD;
          end_draft_dist : BITCODE_BD;
          scale_factor : BITCODE_BD;
          twist_angle : BITCODE_BD;
          align_angle : BITCODE_BD;
          sweepentity_transform : PBITCODE_BD;
          pathentity_transform : PBITCODE_BD;
          align_option : BITCODE_RC;
          miter_option : BITCODE_RC;
          has_align_start : BITCODE_B;
          bank : BITCODE_B;
          check_intersections : BITCODE_B;
          shsw_b294 : BITCODE_B;
          shsw_b295 : BITCODE_B;
          shsw_b296 : BITCODE_B;
          pt2 : BITCODE_3BD;
        end;
      Dwg_Object_ACSH_EXTRUSION_CLASS = _dwg_object_ACSH_EXTRUSION_CLASS;
      //PDwg_Object_ACSH_EXTRUSION_CLASS = ^Dwg_Object_ACSH_EXTRUSION_CLASS;

      //P_dwg_object_ACSH_LOFT_CLASS = ^_dwg_object_ACSH_LOFT_CLASS;
      _dwg_object_ACSH_LOFT_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          num_crosssects : BITCODE_BL;
          crosssects : PBITCODE_H;
          num_guides : BITCODE_BL;
          guides : PBITCODE_H;
        end;
      Dwg_Object_ACSH_LOFT_CLASS = _dwg_object_ACSH_LOFT_CLASS;
      //PDwg_Object_ACSH_LOFT_CLASS = ^Dwg_Object_ACSH_LOFT_CLASS;

      //P_dwg_object_ACSH_FILLET_CLASS = ^_dwg_object_ACSH_FILLET_CLASS;
      _dwg_object_ACSH_FILLET_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          bl92 : BITCODE_BL;
          num_edges : BITCODE_BL;
          edges : PBITCODE_BL;
          num_radiuses : BITCODE_BL;
          num_startsetbacks : BITCODE_BL;
          num_endsetbacks : BITCODE_BL;
          radiuses : PBITCODE_BD;
          startsetbacks : PBITCODE_BD;
          endsetbacks : PBITCODE_BD;
        end;
      Dwg_Object_ACSH_FILLET_CLASS = _dwg_object_ACSH_FILLET_CLASS;
      //PDwg_Object_ACSH_FILLET_CLASS = ^Dwg_Object_ACSH_FILLET_CLASS;

      //P_dwg_object_ACSH_CHAMFER_CLASS = ^_dwg_object_ACSH_CHAMFER_CLASS;
      _dwg_object_ACSH_CHAMFER_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          bl92 : BITCODE_BL;
          base_dist : BITCODE_BD;
          other_dist : BITCODE_BD;
          num_edges : BITCODE_BL;
          edges : PBITCODE_BL;
          bl95 : BITCODE_BL;
        end;
      Dwg_Object_ACSH_CHAMFER_CLASS = _dwg_object_ACSH_CHAMFER_CLASS;
      //PDwg_Object_ACSH_CHAMFER_CLASS = ^Dwg_Object_ACSH_CHAMFER_CLASS;

      //P_dwg_object_ACSH_CYLINDER_CLASS = ^_dwg_object_ACSH_CYLINDER_CLASS;
      _dwg_object_ACSH_CYLINDER_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          height : BITCODE_BD;
          major_radius : BITCODE_BD;
          minor_radius : BITCODE_BD;
          x_radius : BITCODE_BD;
        end;
      Dwg_Object_ACSH_CYLINDER_CLASS = _dwg_object_ACSH_CYLINDER_CLASS;
      //PDwg_Object_ACSH_CYLINDER_CLASS = ^Dwg_Object_ACSH_CYLINDER_CLASS;

      //P_dwg_object_ACSH_CONE_CLASS = ^_dwg_object_ACSH_CONE_CLASS;
      _dwg_object_ACSH_CONE_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          height : BITCODE_BD;
          major_radius : BITCODE_BD;
          minor_radius : BITCODE_BD;
          x_radius : BITCODE_BD;
        end;
      Dwg_Object_ACSH_CONE_CLASS = _dwg_object_ACSH_CONE_CLASS;
      //PDwg_Object_ACSH_CONE_CLASS = ^Dwg_Object_ACSH_CONE_CLASS;

      //P_dwg_object_ACSH_PYRAMID_CLASS = ^_dwg_object_ACSH_PYRAMID_CLASS;
      _dwg_object_ACSH_PYRAMID_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          height : BITCODE_BD;
          sides : BITCODE_BL;
          radius : BITCODE_BD;
          topradius : BITCODE_BD;
        end;
      Dwg_Object_ACSH_PYRAMID_CLASS = _dwg_object_ACSH_PYRAMID_CLASS;
      //PDwg_Object_ACSH_PYRAMID_CLASS = ^Dwg_Object_ACSH_PYRAMID_CLASS;

      //P_dwg_object_ACSH_SPHERE_CLASS = ^_dwg_object_ACSH_SPHERE_CLASS;
      _dwg_object_ACSH_SPHERE_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          radius : BITCODE_BD;
        end;
      Dwg_Object_ACSH_SPHERE_CLASS = _dwg_object_ACSH_SPHERE_CLASS;
      //PDwg_Object_ACSH_SPHERE_CLASS = ^Dwg_Object_ACSH_SPHERE_CLASS;

     // P_dwg_object_ACSH_TORUS_CLASS = ^_dwg_object_ACSH_TORUS_CLASS;
      _dwg_object_ACSH_TORUS_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          major_radius : BITCODE_BD;
          minor_radius : BITCODE_BD;
        end;
      Dwg_Object_ACSH_TORUS_CLASS = _dwg_object_ACSH_TORUS_CLASS;
      //PDwg_Object_ACSH_TORUS_CLASS = ^Dwg_Object_ACSH_TORUS_CLASS;

      //P_dwg_object_ACSH_REVOLVE_CLASS = ^_dwg_object_ACSH_REVOLVE_CLASS;
      _dwg_object_ACSH_REVOLVE_CLASS = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          history_node : Dwg_ACSH_HistoryNode;
          major : BITCODE_BL;
          minor : BITCODE_BL;
          axis_pt : BITCODE_3BD;
          direction : BITCODE_2RD;
          revolve_angle : BITCODE_BD;
          start_angle : BITCODE_BD;
          draft_angle : BITCODE_BD;
          bd44 : BITCODE_BD;
          bd45 : BITCODE_BD;
          twist_angle : BITCODE_BD;
          b290 : BITCODE_B;
          is_close_to_axis : BITCODE_B;
          sweep_entity : BITCODE_H;
        end;
      Dwg_Object_ACSH_REVOLVE_CLASS = _dwg_object_ACSH_REVOLVE_CLASS;
      //PDwg_Object_ACSH_REVOLVE_CLASS = ^Dwg_Object_ACSH_REVOLVE_CLASS;

      //P_dwg_entity_NAVISWORKSMODEL = ^_dwg_entity_NAVISWORKSMODEL;
      _dwg_entity_NAVISWORKSMODEL = record
          parent : P_dwg_object_entity;
          flags : BITCODE_BS;
          definition : BITCODE_H;
          transmatrix : PBITCODE_BD;
          unitfactor : BITCODE_BD;
        end;
      Dwg_Entity_NAVISWORKSMODEL = _dwg_entity_NAVISWORKSMODEL;
      //PDwg_Entity_NAVISWORKSMODEL = ^Dwg_Entity_NAVISWORKSMODEL;

      //P_dwg_object_NAVISWORKSMODELDEF = ^_dwg_object_NAVISWORKSMODELDEF;
      _dwg_object_NAVISWORKSMODELDEF = record
          parent : P_dwg_object_object;
          flags : BITCODE_BS;
          path : BITCODE_TV;
          status : BITCODE_B;
          min_extent : BITCODE_3BD;
          max_extent : BITCODE_3BD;
          host_drawing_visibility : BITCODE_B;
        end;
      Dwg_Object_NAVISWORKSMODELDEF = _dwg_object_NAVISWORKSMODELDEF;
      //PDwg_Object_NAVISWORKSMODELDEF = ^Dwg_Object_NAVISWORKSMODELDEF;

      //P_dwg_object_RENDERSETTINGS = ^_dwg_object_RENDERSETTINGS;
      _dwg_object_RENDERSETTINGS = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          name : BITCODE_TV;
          fog_enabled : BITCODE_B;
          fog_background_enabled : BITCODE_B;
          backfaces_enabled : BITCODE_B;
          environ_image_enabled : BITCODE_B;
          environ_image_filename : BITCODE_TV;
          description : BITCODE_TV;
          display_index : BITCODE_BL;
          has_predefined : BITCODE_B;
        end;
      Dwg_Object_RENDERSETTINGS = _dwg_object_RENDERSETTINGS;
      //PDwg_Object_RENDERSETTINGS = ^Dwg_Object_RENDERSETTINGS;

      //P_dwg_object_MENTALRAYRENDERSETTINGS = ^_dwg_object_MENTALRAYRENDERSETTINGS;
      _dwg_object_MENTALRAYRENDERSETTINGS = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          name : BITCODE_TV;
          fog_enabled : BITCODE_B;
          fog_background_enabled : BITCODE_B;
          backfaces_enabled : BITCODE_B;
          environ_image_enabled : BITCODE_B;
          environ_image_filename : BITCODE_TV;
          description : BITCODE_TV;
          display_index : BITCODE_BL;
          has_predefined : BITCODE_B;
          mr_version : BITCODE_BL;
          sampling1 : BITCODE_BL;
          sampling2 : BITCODE_BL;
          sampling_mr_filter : BITCODE_BS;
          sampling_filter1 : BITCODE_BD;
          sampling_filter2 : BITCODE_BD;
          sampling_contrast_color1 : BITCODE_BD;
          sampling_contrast_color2 : BITCODE_BD;
          sampling_contrast_color3 : BITCODE_BD;
          sampling_contrast_color4 : BITCODE_BD;
          shadow_mode : BITCODE_BS;
          shadow_maps_enabled : BITCODE_B;
          ray_tracing_enabled : BITCODE_B;
          ray_trace_depth1 : BITCODE_BL;
          ray_trace_depth2 : BITCODE_BL;
          ray_trace_depth3 : BITCODE_BL;
          global_illumination_enabled : BITCODE_B;
          gi_sample_count : BITCODE_BL;
          gi_sample_radius_enabled : BITCODE_B;
          gi_sample_radius : BITCODE_BD;
          gi_photons_per_light : BITCODE_BL;
          photon_trace_depth1 : BITCODE_BL;
          photon_trace_depth2 : BITCODE_BL;
          photon_trace_depth3 : BITCODE_BL;
          final_gathering_enabled : BITCODE_B;
          fg_ray_count : BITCODE_BL;
          fg_sample_radius_state1 : BITCODE_B;
          fg_sample_radius_state2 : BITCODE_B;
          fg_sample_radius_state3 : BITCODE_B;
          fg_sample_radius1 : BITCODE_BD;
          fg_sample_radius2 : BITCODE_BD;
          light_luminance_scale : BITCODE_BD;
          diagnostics_mode : BITCODE_BS;
          diagnostics_grid_mode : BITCODE_BS;
          diagnostics_grid_float : BITCODE_BD;
          diagnostics_photon_mode : BITCODE_BS;
          diagnostics_bsp_mode : BITCODE_BS;
          export_mi_enabled : BITCODE_B;
          mr_description : BITCODE_TV;
          tile_size : BITCODE_BL;
          tile_order : BITCODE_BS;
          memory_limit : BITCODE_BL;
          diagnostics_samples_mode : BITCODE_B;
          energy_multiplier : BITCODE_BD;
        end;
      Dwg_Object_MENTALRAYRENDERSETTINGS = _dwg_object_MENTALRAYRENDERSETTINGS;
      //PDwg_Object_MENTALRAYRENDERSETTINGS = ^Dwg_Object_MENTALRAYRENDERSETTINGS;

      //P_dwg_object_RAPIDRTRENDERSETTINGS = ^_dwg_object_RAPIDRTRENDERSETTINGS;
      _dwg_object_RAPIDRTRENDERSETTINGS = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          name : BITCODE_TV;
          fog_enabled : BITCODE_B;
          fog_background_enabled : BITCODE_B;
          backfaces_enabled : BITCODE_B;
          environ_image_enabled : BITCODE_B;
          environ_image_filename : BITCODE_TV;
          description : BITCODE_TV;
          display_index : BITCODE_BL;
          has_predefined : BITCODE_B;
          rapidrt_version : BITCODE_BL;
          render_target : BITCODE_BL;
          render_level : BITCODE_BL;
          render_time : BITCODE_BL;
          lighting_model : BITCODE_BL;
          filter_type : BITCODE_BL;
          filter_width : BITCODE_BD;
          filter_height : BITCODE_BD;
        end;
      Dwg_Object_RAPIDRTRENDERSETTINGS = _dwg_object_RAPIDRTRENDERSETTINGS;
      //PDwg_Object_RAPIDRTRENDERSETTINGS = ^Dwg_Object_RAPIDRTRENDERSETTINGS;

      //P_dwg_object_RENDERENVIRONMENT = ^_dwg_object_RENDERENVIRONMENT;
      _dwg_object_RENDERENVIRONMENT = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          fog_enabled : BITCODE_B;
          fog_background_enabled : BITCODE_B;
          fog_color : BITCODE_CMC;
          fog_density_near : BITCODE_BD;
          fog_density_far : BITCODE_BD;
          fog_distance_near : BITCODE_BD;
          fog_distance_far : BITCODE_BD;
          environ_image_enabled : BITCODE_B;
          environ_image_filename : BITCODE_TV;
        end;
      Dwg_Object_RENDERENVIRONMENT = _dwg_object_RENDERENVIRONMENT;
      //PDwg_Object_RENDERENVIRONMENT = ^Dwg_Object_RENDERENVIRONMENT;

      //P_dwg_object_RENDERGLOBAL = ^_dwg_object_RENDERGLOBAL;
      _dwg_object_RENDERGLOBAL = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          _procedure : BITCODE_BL;
          destination : BITCODE_BL;
          save_enabled : BITCODE_B;
          save_filename : BITCODE_TV;
          image_width : BITCODE_BL;
          image_height : BITCODE_BL;
          predef_presets_first : BITCODE_B;
          highlevel_info : BITCODE_B;
        end;
      Dwg_Object_RENDERGLOBAL = _dwg_object_RENDERGLOBAL;
      //PDwg_Object_RENDERGLOBAL = ^Dwg_Object_RENDERGLOBAL;

      //P_dwg_object_RENDERENTRY = ^_dwg_object_RENDERENTRY;
      _dwg_object_RENDERENTRY = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          image_file_name : BITCODE_TV;
          preset_name : BITCODE_TV;
          view_name : BITCODE_TV;
          dimension_x : BITCODE_BL;
          dimension_y : BITCODE_BL;
          start_year : BITCODE_BS;
          start_month : BITCODE_BS;
          start_day : BITCODE_BS;
          start_minute : BITCODE_BS;
          start_second : BITCODE_BS;
          start_msec : BITCODE_BS;
          render_time : BITCODE_BD;
          memory_amount : BITCODE_BL;
          material_count : BITCODE_BL;
          light_count : BITCODE_BL;
          triangle_count : BITCODE_BL;
          display_index : BITCODE_BL;
        end;
      Dwg_Object_RENDERENTRY = _dwg_object_RENDERENTRY;
      //PDwg_Object_RENDERENTRY = ^Dwg_Object_RENDERENTRY;

      //P_dwg_object_MOTIONPATH = ^_dwg_object_MOTIONPATH;
      _dwg_object_MOTIONPATH = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          camera_path : BITCODE_H;
          target_path : BITCODE_H;
          viewtable : BITCODE_H;
          frames : BITCODE_BS;
          frame_rate : BITCODE_BS;
          corner_decel : BITCODE_B;
        end;
      Dwg_Object_MOTIONPATH = _dwg_object_MOTIONPATH;
      //PDwg_Object_MOTIONPATH = ^Dwg_Object_MOTIONPATH;

      //P_dwg_object_CURVEPATH = ^_dwg_object_CURVEPATH;
      _dwg_object_CURVEPATH = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          entity : BITCODE_H;
        end;
      Dwg_Object_CURVEPATH = _dwg_object_CURVEPATH;
      //PDwg_Object_CURVEPATH = ^Dwg_Object_CURVEPATH;

      //P_dwg_object_POINTPATH = ^_dwg_object_POINTPATH;
      _dwg_object_POINTPATH = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          point : BITCODE_3BD;
        end;
      Dwg_Object_POINTPATH = _dwg_object_POINTPATH;
      //PDwg_Object_POINTPATH = ^Dwg_Object_POINTPATH;

      //P_dwg_object_TVDEVICEPROPERTIES = ^_dwg_object_TVDEVICEPROPERTIES;
      _dwg_object_TVDEVICEPROPERTIES = record
          parent : P_dwg_object_object;
          flags : BITCODE_BL;
          max_regen_threads : BITCODE_BS;
          use_lut_palette : BITCODE_BL;
          alt_hlt : BITCODE_BLL;
          alt_hltcolor : BITCODE_BLL;
          geom_shader_usage : BITCODE_BLL;
          blending_mode : BITCODE_BL;
          antialiasing_level : BITCODE_BD;
          bd2 : BITCODE_BD;
        end;
      Dwg_Object_TVDEVICEPROPERTIES = _dwg_object_TVDEVICEPROPERTIES;
      //PDwg_Object_TVDEVICEPROPERTIES = ^Dwg_Object_TVDEVICEPROPERTIES;

      //P_dwg_object_SKYLIGHT_BACKGROUND = ^_dwg_object_SKYLIGHT_BACKGROUND;
      _dwg_object_SKYLIGHT_BACKGROUND = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          sunid : BITCODE_H;
        end;
      Dwg_Object_SKYLIGHT_BACKGROUND = _dwg_object_SKYLIGHT_BACKGROUND;
      //PDwg_Object_SKYLIGHT_BACKGROUND = ^Dwg_Object_SKYLIGHT_BACKGROUND;

      //P_dwg_object_SOLID_BACKGROUND = ^_dwg_object_SOLID_BACKGROUND;
      _dwg_object_SOLID_BACKGROUND = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          color : BITCODE_BLx;
        end;
      Dwg_Object_SOLID_BACKGROUND = _dwg_object_SOLID_BACKGROUND;
      //PDwg_Object_SOLID_BACKGROUND = ^Dwg_Object_SOLID_BACKGROUND;

      //P_dwg_object_IMAGE_BACKGROUND = ^_dwg_object_IMAGE_BACKGROUND;
      _dwg_object_IMAGE_BACKGROUND = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          filename : BITCODE_TV;
          fit_to_screen : BITCODE_B;
          maintain_aspect_ratio : BITCODE_B;
          use_tiling : BITCODE_B;
          offset : BITCODE_2BD;
          scale : BITCODE_2BD;
        end;
      Dwg_Object_IMAGE_BACKGROUND = _dwg_object_IMAGE_BACKGROUND;
      //PDwg_Object_IMAGE_BACKGROUND = ^Dwg_Object_IMAGE_BACKGROUND;

      //P_dwg_object_IBL_BACKGROUND = ^_dwg_object_IBL_BACKGROUND;
      _dwg_object_IBL_BACKGROUND = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          enable : BITCODE_B;
          name : BITCODE_TV;
          rotation : BITCODE_BD;
          display_image : BITCODE_B;
          secondary_background : BITCODE_H;
        end;
      Dwg_Object_IBL_BACKGROUND = _dwg_object_IBL_BACKGROUND;
      //PDwg_Object_IBL_BACKGROUND = ^Dwg_Object_IBL_BACKGROUND;

      //P_dwg_object_GRADIENT_BACKGROUND = ^_dwg_object_GRADIENT_BACKGROUND;
      _dwg_object_GRADIENT_BACKGROUND = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          color_top : BITCODE_BLx;
          color_middle : BITCODE_BLx;
          color_bottom : BITCODE_BLx;
          horizon : BITCODE_BD;
          height : BITCODE_BD;
          rotation : BITCODE_BD;
        end;
      Dwg_Object_GRADIENT_BACKGROUND = _dwg_object_GRADIENT_BACKGROUND;
      //PDwg_Object_GRADIENT_BACKGROUND = ^Dwg_Object_GRADIENT_BACKGROUND;

      //P_dwg_object_GROUND_PLANE_BACKGROUND = ^_dwg_object_GROUND_PLANE_BACKGROUND;
      _dwg_object_GROUND_PLANE_BACKGROUND = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          color_sky_zenith : BITCODE_BLx;
          color_sky_horizon : BITCODE_BLx;
          color_underground_horizon : BITCODE_BLx;
          color_underground_azimuth : BITCODE_BLx;
          color_near : BITCODE_BLx;
          color_far : BITCODE_BLx;
        end;
      Dwg_Object_GROUND_PLANE_BACKGROUND = _dwg_object_GROUND_PLANE_BACKGROUND;
      //PDwg_Object_GROUND_PLANE_BACKGROUND = ^Dwg_Object_GROUND_PLANE_BACKGROUND;

      //P_dwg_object_ANNOTSCALEOBJECTCONTEXTDATA = ^_dwg_object_ANNOTSCALEOBJECTCONTEXTDATA;
      _dwg_object_ANNOTSCALEOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
        end;
      Dwg_Object_ANNOTSCALEOBJECTCONTEXTDATA = _dwg_object_ANNOTSCALEOBJECTCONTEXTDATA;
      //PDwg_Object_ANNOTSCALEOBJECTCONTEXTDATA = ^Dwg_Object_ANNOTSCALEOBJECTCONTEXTDATA;

      //P_dwg_CONTEXTDATA_dict = ^_dwg_CONTEXTDATA_dict;
      _dwg_CONTEXTDATA_dict = record
          parent : P_dwg_CONTEXTDATA_submgr;
          text : BITCODE_TV;
          itemhandle : BITCODE_H;
        end;
      Dwg_CONTEXTDATA_dict = _dwg_CONTEXTDATA_dict;
      //PDwg_CONTEXTDATA_dict = ^Dwg_CONTEXTDATA_dict;

      //P_dwg_CONTEXTDATA_submgr = ^_dwg_CONTEXTDATA_submgr;
      _dwg_CONTEXTDATA_submgr = record
          parent : P_dwg_object_CONTEXTDATAMANAGER;
          handle : BITCODE_H;
          num_entries : BITCODE_BL;
          entries : PDwg_CONTEXTDATA_dict;
        end;
      Dwg_CONTEXTDATA_submgr = _dwg_CONTEXTDATA_submgr;
      //PDwg_CONTEXTDATA_submgr = ^Dwg_CONTEXTDATA_submgr;

      //P_dwg_object_CONTEXTDATAMANAGER = ^_dwg_object_CONTEXTDATAMANAGER;
      _dwg_object_CONTEXTDATAMANAGER = record
          parent : P_dwg_object_object;
          objectcontext : BITCODE_H;
          num_submgrs : BITCODE_BL;
          submgrs : PDwg_CONTEXTDATA_submgr;
        end;
      Dwg_Object_CONTEXTDATAMANAGER = _dwg_object_CONTEXTDATAMANAGER;
      //PDwg_Object_CONTEXTDATAMANAGER = ^Dwg_Object_CONTEXTDATAMANAGER;

      //P_dwg_object_TEXTOBJECTCONTEXTDATA = ^_dwg_object_TEXTOBJECTCONTEXTDATA;
      _dwg_object_TEXTOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          horizontal_mode : BITCODE_BS;
          rotation : BITCODE_BD;
          ins_pt : BITCODE_2RD;
          alignment_pt : BITCODE_2RD;
        end;
      Dwg_Object_TEXTOBJECTCONTEXTDATA = _dwg_object_TEXTOBJECTCONTEXTDATA;
      //PDwg_Object_TEXTOBJECTCONTEXTDATA = ^Dwg_Object_TEXTOBJECTCONTEXTDATA;

      //P_dwg_object_MTEXTOBJECTCONTEXTDATA = ^_dwg_object_MTEXTOBJECTCONTEXTDATA;
      _dwg_object_MTEXTOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          attachment : BITCODE_BL;
          ins_pt : BITCODE_3BD;
          x_axis_dir : BITCODE_3BD;
          rect_height : BITCODE_BD;
          rect_width : BITCODE_BD;
          extents_width : BITCODE_BD;
          extents_height : BITCODE_BD;
          column_type : BITCODE_BL;
          column_width : BITCODE_BD;
          gutter : BITCODE_BD;
          auto_height : BITCODE_B;
          flow_reversed : BITCODE_B;
          num_column_heights : BITCODE_BL;
          column_heights : PBITCODE_BD;
        end;
      Dwg_Object_MTEXTOBJECTCONTEXTDATA = _dwg_object_MTEXTOBJECTCONTEXTDATA;
      //PDwg_Object_MTEXTOBJECTCONTEXTDATA = ^Dwg_Object_MTEXTOBJECTCONTEXTDATA;

      //P_dwg_OCD_Dimension = ^_dwg_OCD_Dimension;
      _dwg_OCD_Dimension = record
          b293 : BITCODE_B;
          def_pt : BITCODE_2RD;
          is_def_textloc : BITCODE_B;
          text_rotation : BITCODE_BD;
          block : BITCODE_H;
          dimtofl : BITCODE_B;
          dimosxd : BITCODE_B;
          dimatfit : BITCODE_B;
          dimtix : BITCODE_B;
          dimtmove : BITCODE_B;
          override_code : BITCODE_RC;
          has_arrow2 : BITCODE_B;
          flip_arrow2 : BITCODE_B;
          flip_arrow1 : BITCODE_B;
        end;
      Dwg_OCD_Dimension = _dwg_OCD_Dimension;
      //PDwg_OCD_Dimension = ^Dwg_OCD_Dimension;

      //P_dwg_object_ALDIMOBJECTCONTEXTDATA = ^_dwg_object_ALDIMOBJECTCONTEXTDATA;
      _dwg_object_ALDIMOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          dimension : Dwg_OCD_Dimension;
          dimline_pt : BITCODE_3BD;
        end;
      Dwg_Object_ALDIMOBJECTCONTEXTDATA = _dwg_object_ALDIMOBJECTCONTEXTDATA;
      //PDwg_Object_ALDIMOBJECTCONTEXTDATA = ^Dwg_Object_ALDIMOBJECTCONTEXTDATA;

      //P_dwg_object_ANGDIMOBJECTCONTEXTDATA = ^_dwg_object_ANGDIMOBJECTCONTEXTDATA;
      _dwg_object_ANGDIMOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          dimension : Dwg_OCD_Dimension;
          arc_pt : BITCODE_3BD;
        end;
      Dwg_Object_ANGDIMOBJECTCONTEXTDATA = _dwg_object_ANGDIMOBJECTCONTEXTDATA;
      //PDwg_Object_ANGDIMOBJECTCONTEXTDATA = ^Dwg_Object_ANGDIMOBJECTCONTEXTDATA;

      //P_dwg_object_DMDIMOBJECTCONTEXTDATA = ^_dwg_object_DMDIMOBJECTCONTEXTDATA;
      _dwg_object_DMDIMOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          dimension : Dwg_OCD_Dimension;
          first_arc_pt : BITCODE_3BD;
          def_pt : BITCODE_3BD;
        end;
      Dwg_Object_DMDIMOBJECTCONTEXTDATA = _dwg_object_DMDIMOBJECTCONTEXTDATA;
      //PDwg_Object_DMDIMOBJECTCONTEXTDATA = ^Dwg_Object_DMDIMOBJECTCONTEXTDATA;

      //P_dwg_object_ORDDIMOBJECTCONTEXTDATA = ^_dwg_object_ORDDIMOBJECTCONTEXTDATA;
      _dwg_object_ORDDIMOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          dimension : Dwg_OCD_Dimension;
          feature_location_pt : BITCODE_3BD;
          leader_endpt : BITCODE_3BD;
        end;
      Dwg_Object_ORDDIMOBJECTCONTEXTDATA = _dwg_object_ORDDIMOBJECTCONTEXTDATA;
      //PDwg_Object_ORDDIMOBJECTCONTEXTDATA = ^Dwg_Object_ORDDIMOBJECTCONTEXTDATA;

      //P_dwg_object_RADIMOBJECTCONTEXTDATA = ^_dwg_object_RADIMOBJECTCONTEXTDATA;
      _dwg_object_RADIMOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          dimension : Dwg_OCD_Dimension;
          first_arc_pt : BITCODE_3BD;
        end;
      Dwg_Object_RADIMOBJECTCONTEXTDATA = _dwg_object_RADIMOBJECTCONTEXTDATA;
      //PDwg_Object_RADIMOBJECTCONTEXTDATA = ^Dwg_Object_RADIMOBJECTCONTEXTDATA;

      //P_dwg_object_RADIMLGOBJECTCONTEXTDATA = ^_dwg_object_RADIMLGOBJECTCONTEXTDATA;
      _dwg_object_RADIMLGOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          dimension : Dwg_OCD_Dimension;
          ovr_center : BITCODE_3BD;
          jog_point : BITCODE_3BD;
        end;
      Dwg_Object_RADIMLGOBJECTCONTEXTDATA = _dwg_object_RADIMLGOBJECTCONTEXTDATA;
      //PDwg_Object_RADIMLGOBJECTCONTEXTDATA = ^Dwg_Object_RADIMLGOBJECTCONTEXTDATA;

      //P_dwg_object_MTEXTATTRIBUTEOBJECTCONTEXTDATA = ^_dwg_object_MTEXTATTRIBUTEOBJECTCONTEXTDATA;
      _dwg_object_MTEXTATTRIBUTEOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          horizontal_mode : BITCODE_BS;
          rotation : BITCODE_BD;
          ins_pt : BITCODE_2RD;
          alignment_pt : BITCODE_2RD;
          enable_context : BITCODE_B;
          context : P_dwg_object;
        end;
      Dwg_Object_MTEXTATTRIBUTEOBJECTCONTEXTDATA = _dwg_object_MTEXTATTRIBUTEOBJECTCONTEXTDATA;
      //PDwg_Object_MTEXTATTRIBUTEOBJECTCONTEXTDATA = ^Dwg_Object_MTEXTATTRIBUTEOBJECTCONTEXTDATA;

      //P_dwg_object_MLEADEROBJECTCONTEXTDATA = ^_dwg_object_MLEADEROBJECTCONTEXTDATA;
      _dwg_object_MLEADEROBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
        end;
      Dwg_Object_MLEADEROBJECTCONTEXTDATA = _dwg_object_MLEADEROBJECTCONTEXTDATA;
      //PDwg_Object_MLEADEROBJECTCONTEXTDATA = ^Dwg_Object_MLEADEROBJECTCONTEXTDATA;

      //P_dwg_object_LEADEROBJECTCONTEXTDATA = ^_dwg_object_LEADEROBJECTCONTEXTDATA;
      _dwg_object_LEADEROBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          num_points : BITCODE_BL;
          points : PBITCODE_3DPOINT;
          b290 : BITCODE_B;
          x_direction : BITCODE_3DPOINT;
          inspt_offset : BITCODE_3DPOINT;
          endptproj : BITCODE_3DPOINT;
        end;
      Dwg_Object_LEADEROBJECTCONTEXTDATA = _dwg_object_LEADEROBJECTCONTEXTDATA;
      //PDwg_Object_LEADEROBJECTCONTEXTDATA = ^Dwg_Object_LEADEROBJECTCONTEXTDATA;

      //P_dwg_object_BLKREFOBJECTCONTEXTDATA = ^_dwg_object_BLKREFOBJECTCONTEXTDATA;
      _dwg_object_BLKREFOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          rotation : BITCODE_BD;
          ins_pt : BITCODE_3BD;
          scale_factor : BITCODE_3BD;
        end;
      Dwg_Object_BLKREFOBJECTCONTEXTDATA = _dwg_object_BLKREFOBJECTCONTEXTDATA;
      //PDwg_Object_BLKREFOBJECTCONTEXTDATA = ^Dwg_Object_BLKREFOBJECTCONTEXTDATA;

      //P_dwg_object_FCFOBJECTCONTEXTDATA = ^_dwg_object_FCFOBJECTCONTEXTDATA;
      _dwg_object_FCFOBJECTCONTEXTDATA = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          is_default : BITCODE_B;
          scale : BITCODE_H;
          location : BITCODE_3BD;
          horiz_dir : BITCODE_3BD;
        end;
      Dwg_Object_FCFOBJECTCONTEXTDATA = _dwg_object_FCFOBJECTCONTEXTDATA;
      //PDwg_Object_FCFOBJECTCONTEXTDATA = ^Dwg_Object_FCFOBJECTCONTEXTDATA;

      //P_dwg_object_DETAILVIEWSTYLE = ^_dwg_object_DETAILVIEWSTYLE;
      _dwg_object_DETAILVIEWSTYLE = record
          parent : P_dwg_object_object;
          mdoc_class_version : BITCODE_BS;
          desc : BITCODE_TV;
          is_modified_for_recompute : BITCODE_B;
          display_name : BITCODE_TV;
          viewstyle_flags : BITCODE_BL;
          class_version : BITCODE_BS;
          flags : BITCODE_BL;
          identifier_style : BITCODE_H;
          identifier_color : BITCODE_CMC;
          identifier_height : BITCODE_BD;
          identifier_exclude_characters : BITCODE_TV;
          identifier_offset : BITCODE_BD;
          identifier_placement : BITCODE_RC;
          arrow_symbol : BITCODE_H;
          arrow_symbol_color : BITCODE_CMC;
          arrow_symbol_size : BITCODE_BD;
          boundary_ltype : BITCODE_H;
          boundary_linewt : BITCODE_BLd;
          boundary_line_color : BITCODE_CMC;
          viewlabel_text_style : BITCODE_H;
          viewlabel_text_color : BITCODE_CMC;
          viewlabel_text_height : BITCODE_BD;
          viewlabel_attachment : BITCODE_BL;
          viewlabel_offset : BITCODE_BD;
          viewlabel_alignment : BITCODE_BL;
          viewlabel_pattern : BITCODE_TV;
          connection_ltype : BITCODE_H;
          connection_linewt : BITCODE_BLd;
          connection_line_color : BITCODE_CMC;
          borderline_ltype : BITCODE_H;
          borderline_linewt : BITCODE_BLd;
          borderline_color : BITCODE_CMC;
          model_edge : BITCODE_RC;
        end;
      Dwg_Object_DETAILVIEWSTYLE = _dwg_object_DETAILVIEWSTYLE;
      //PDwg_Object_DETAILVIEWSTYLE = ^Dwg_Object_DETAILVIEWSTYLE;

      //P_dwg_object_SECTIONVIEWSTYLE = ^_dwg_object_SECTIONVIEWSTYLE;
      _dwg_object_SECTIONVIEWSTYLE = record
          parent : P_dwg_object_object;
          mdoc_class_version : BITCODE_BS;
          desc : BITCODE_TV;
          is_modified_for_recompute : BITCODE_B;
          display_name : BITCODE_TV;
          viewstyle_flags : BITCODE_BL;
          class_version : BITCODE_BS;
          flags : BITCODE_BL;
          identifier_style : BITCODE_H;
          identifier_color : BITCODE_CMC;
          identifier_height : BITCODE_BD;
          arrow_start_symbol : BITCODE_H;
          arrow_end_symbol : BITCODE_H;
          arrow_symbol_color : BITCODE_CMC;
          arrow_symbol_size : BITCODE_BD;
          identifier_exclude_characters : BITCODE_TV;
          identifier_position : BITCODE_BLd;
          identifier_offset : BITCODE_BD;
          arrow_position : BITCODE_BLd;
          arrow_symbol_extension_length : BITCODE_BD;
          plane_ltype : BITCODE_H;
          plane_linewt : BITCODE_BLd;
          plane_line_color : BITCODE_CMC;
          bend_ltype : BITCODE_H;
          bend_linewt : BITCODE_BLd;
          bend_line_color : BITCODE_CMC;
          bend_line_length : BITCODE_BD;
          end_line_overshoot : BITCODE_BD;
          end_line_length : BITCODE_BD;
          viewlabel_text_style : BITCODE_H;
          viewlabel_text_color : BITCODE_CMC;
          viewlabel_text_height : BITCODE_BD;
          viewlabel_attachment : BITCODE_BL;
          viewlabel_offset : BITCODE_BD;
          viewlabel_alignment : BITCODE_BL;
          viewlabel_pattern : BITCODE_TV;
          hatch_color : BITCODE_CMC;
          hatch_bg_color : BITCODE_CMC;
          hatch_pattern : BITCODE_TV;
          hatch_scale : BITCODE_BD;
          hatch_transparency : BITCODE_BLd;
          unknown_b1 : BITCODE_B;
          unknown_b2 : BITCODE_B;
          num_hatch_angles : BITCODE_BL;
          hatch_angles : PBITCODE_BD;
        end;
      Dwg_Object_SECTIONVIEWSTYLE = _dwg_object_SECTIONVIEWSTYLE;
      //PDwg_Object_SECTIONVIEWSTYLE = ^Dwg_Object_SECTIONVIEWSTYLE;

      //P_dwg_object_SECTION_MANAGER = ^_dwg_object_SECTION_MANAGER;
      _dwg_object_SECTION_MANAGER = record
          parent : P_dwg_object_object;
          is_live : BITCODE_B;
          num_sections : BITCODE_BS;
          sections : PBITCODE_H;
        end;
      Dwg_Object_SECTION_MANAGER = _dwg_object_SECTION_MANAGER;
      //PDwg_Object_SECTION_MANAGER = ^Dwg_Object_SECTION_MANAGER;

      //P_dwg_SECTION_geometrysettings = ^_dwg_SECTION_geometrysettings;
      _dwg_SECTION_geometrysettings = record
          parent : P_dwg_SECTION_typesettings;
          num_geoms : BITCODE_BL;
          hexindex : BITCODE_BL;
          flags : BITCODE_BL;
          color : BITCODE_CMC;
          layer : BITCODE_TV;
          ltype : BITCODE_TV;
          ltype_scale : BITCODE_BD;
          plotstyle : BITCODE_TV;
          linewt : BITCODE_BLd;
          face_transparency : BITCODE_BS;
          edge_transparency : BITCODE_BS;
          hatch_type : BITCODE_BS;
          hatch_pattern : BITCODE_TV;
          hatch_angle : BITCODE_BD;
          hatch_spacing : BITCODE_BD;
          hatch_scale : BITCODE_BD;
        end;
      Dwg_SECTION_geometrysettings = _dwg_SECTION_geometrysettings;
      //PDwg_SECTION_geometrysettings = ^Dwg_SECTION_geometrysettings;

      //P_dwg_SECTION_typesettings = ^_dwg_SECTION_typesettings;
      _dwg_SECTION_typesettings = record
          parent : P_dwg_object_SECTION_SETTINGS;
          _type : BITCODE_BS;
          generation : BITCODE_BS;
          num_sources : BITCODE_BL;
          sources : PBITCODE_H;
          destblock : BITCODE_H;
          destfile : BITCODE_TV;
          num_geom : BITCODE_BL;
          geom : PDwg_SECTION_geometrysettings;
        end;
      Dwg_SECTION_typesettings = _dwg_SECTION_typesettings;
      //PDwg_SECTION_typesettings = ^Dwg_SECTION_typesettings;

      //P_dwg_object_SECTION_SETTINGS = ^_dwg_object_SECTION_SETTINGS;
      _dwg_object_SECTION_SETTINGS = record
          parent : P_dwg_object_object;
          curr_type : BITCODE_BS;
          num_types : BITCODE_BL;
          types : PDwg_SECTION_typesettings;
        end;
      Dwg_Object_SECTION_SETTINGS = _dwg_object_SECTION_SETTINGS;
      //PDwg_Object_SECTION_SETTINGS = ^Dwg_Object_SECTION_SETTINGS;

      //P_dwg_object_LAYERFILTER = ^_dwg_object_LAYERFILTER;
      _dwg_object_LAYERFILTER = record
          parent : P_dwg_object_object;
          num_names : BITCODE_BL;
          names : PBITCODE_TV;
        end;
      Dwg_Object_LAYERFILTER = _dwg_object_LAYERFILTER;
      //PDwg_Object_LAYERFILTER = ^Dwg_Object_LAYERFILTER;

      //P_dwg_entity_ARCALIGNEDTEXT = ^_dwg_entity_ARCALIGNEDTEXT;
      _dwg_entity_ARCALIGNEDTEXT = record
          parent : P_dwg_object_entity;
          text_size : BITCODE_D2T;
          xscale : BITCODE_D2T;
          char_spacing : BITCODE_D2T;
          style : BITCODE_TV;
          t2 : BITCODE_TV;
          t3 : BITCODE_TV;
          text_value : BITCODE_TV;
          offset_from_arc : BITCODE_D2T;
          right_offset : BITCODE_D2T;
          left_offset : BITCODE_D2T;
          center : BITCODE_3BD;
          radius : BITCODE_BD;
          start_angle : BITCODE_BD;
          end_angle : BITCODE_BD;
          extrusion : BITCODE_3BD;
          color : BITCODE_BL;
          is_reverse : BITCODE_BS;
          text_direction : BITCODE_BS;
          alignment : BITCODE_BS;
          text_position : BITCODE_BS;
          font_19 : BITCODE_BS;
          bs2 : BITCODE_BS;
          is_underlined : BITCODE_BS;
          bs1 : BITCODE_BS;
          font : BITCODE_BS;
          is_shx : BITCODE_BS;
          wizard_flag : BITCODE_BS;
          arc_handle : BITCODE_H;
        end;
      Dwg_Entity_ARCALIGNEDTEXT = _dwg_entity_ARCALIGNEDTEXT;
      //PDwg_Entity_ARCALIGNEDTEXT = ^Dwg_Entity_ARCALIGNEDTEXT;

      //P_dwg_entity_RTEXT = ^_dwg_entity_RTEXT;
      _dwg_entity_RTEXT = record
          parent : P_dwg_object_entity;
          pt : BITCODE_3BD;
          extrusion : BITCODE_BE;
          rotation : BITCODE_BD;
          height : BITCODE_BD;
          flags : BITCODE_BS;
          text_value : BITCODE_TV;
          style : BITCODE_H;
        end;
      Dwg_Entity_RTEXT = _dwg_entity_RTEXT;
      //PDwg_Entity_RTEXT = ^Dwg_Entity_RTEXT;

      //P_dwg_object_LAYOUTPRINTCONFIG = ^_dwg_object_LAYOUTPRINTCONFIG;
      _dwg_object_LAYOUTPRINTCONFIG = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          flag : BITCODE_BS;
        end;
      Dwg_Object_LAYOUTPRINTCONFIG = _dwg_object_LAYOUTPRINTCONFIG;
      //PDwg_Object_LAYOUTPRINTCONFIG = ^Dwg_Object_LAYOUTPRINTCONFIG;

      //P_dwg_object_ACMECOMMANDHISTORY = ^_dwg_object_ACMECOMMANDHISTORY;
      _dwg_object_ACMECOMMANDHISTORY = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
        end;
      Dwg_Object_ACMECOMMANDHISTORY = _dwg_object_ACMECOMMANDHISTORY;
      //PDwg_Object_ACMECOMMANDHISTORY = ^Dwg_Object_ACMECOMMANDHISTORY;

      //P_dwg_object_ACMESCOPE = ^_dwg_object_ACMESCOPE;
      _dwg_object_ACMESCOPE = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
        end;
      Dwg_Object_ACMESCOPE = _dwg_object_ACMESCOPE;
      //PDwg_Object_ACMESCOPE = ^Dwg_Object_ACMESCOPE;

      //P_dwg_object_ACMESTATEMGR = ^_dwg_object_ACMESTATEMGR;
      _dwg_object_ACMESTATEMGR = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
        end;
      Dwg_Object_ACMESTATEMGR = _dwg_object_ACMESTATEMGR;
      //PDwg_Object_ACMESTATEMGR = ^Dwg_Object_ACMESTATEMGR;

      //P_dwg_object_CSACDOCUMENTOPTIONS = ^_dwg_object_CSACDOCUMENTOPTIONS;
      _dwg_object_CSACDOCUMENTOPTIONS = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
        end;
      Dwg_Object_CSACDOCUMENTOPTIONS = _dwg_object_CSACDOCUMENTOPTIONS;
      //PDwg_Object_CSACDOCUMENTOPTIONS = ^Dwg_Object_CSACDOCUMENTOPTIONS;

      //P_dwg_BLOCKPARAMETER_connection = ^_dwg_BLOCKPARAMETER_connection;
      _dwg_BLOCKPARAMETER_connection = record
          code : BITCODE_BL;
          name : BITCODE_TV;
        end;
      Dwg_BLOCKPARAMETER_connection = _dwg_BLOCKPARAMETER_connection;
      //PDwg_BLOCKPARAMETER_connection = ^Dwg_BLOCKPARAMETER_connection;

      //P_dwg_BLOCKPARAMETER_PropInfo = ^_dwg_BLOCKPARAMETER_PropInfo;
      _dwg_BLOCKPARAMETER_PropInfo = record
          num_connections : BITCODE_BL;
          connections : PDwg_BLOCKPARAMETER_connection;
        end;
      Dwg_BLOCKPARAMETER_PropInfo = _dwg_BLOCKPARAMETER_PropInfo;
      //PDwg_BLOCKPARAMETER_PropInfo = ^Dwg_BLOCKPARAMETER_PropInfo;

      //P_dwg_BLOCKPARAMVALUESET = ^_dwg_BLOCKPARAMVALUESET;
      _dwg_BLOCKPARAMVALUESET = record
          desc : BITCODE_TV;
          flags : BITCODE_BL;
          minimum : BITCODE_BD;
          maximum : BITCODE_BD;
          increment : BITCODE_BD;
          num_valuelist : BITCODE_BS;
          valuelist : PBITCODE_BD;
        end;
      Dwg_BLOCKPARAMVALUESET = _dwg_BLOCKPARAMVALUESET;
      //PDwg_BLOCKPARAMVALUESET = ^Dwg_BLOCKPARAMVALUESET;

      //P_dwg_BLOCKACTION_connectionpts = ^_dwg_BLOCKACTION_connectionpts;
      _dwg_BLOCKACTION_connectionpts = record
          code : BITCODE_BL;
          name : BITCODE_TV;
        end;
      Dwg_BLOCKACTION_connectionpts = _dwg_BLOCKACTION_connectionpts;
      //PDwg_BLOCKACTION_connectionpts = ^Dwg_BLOCKACTION_connectionpts;

      //P_dwg_BLOCKVISIBILITYPARAMETER_state = ^_dwg_BLOCKVISIBILITYPARAMETER_state;
      _dwg_BLOCKVISIBILITYPARAMETER_state = record
          parent : P_dwg_object_BLOCKVISIBILITYPARAMETER;
          name : BITCODE_TV;
          num_blocks : BITCODE_BL;
          blocks : PBITCODE_H;
          num_params : BITCODE_BL;
          params : PBITCODE_H;
        end;
      Dwg_BLOCKVISIBILITYPARAMETER_state = _dwg_BLOCKVISIBILITYPARAMETER_state;
      //PDwg_BLOCKVISIBILITYPARAMETER_state = ^Dwg_BLOCKVISIBILITYPARAMETER_state;

      //P_dwg_object_BLOCKVISIBILITYPARAMETER = ^_dwg_object_BLOCKVISIBILITYPARAMETER;
      _dwg_object_BLOCKVISIBILITYPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_pt : BITCODE_3BD;
          num_propinfos : BITCODE_BL;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          is_initialized : BITCODE_B;
          unknown_bool : BITCODE_B;
          blockvisi_name : BITCODE_TV;
          blockvisi_desc : BITCODE_TV;
          num_blocks : BITCODE_BL;
          blocks : PBITCODE_H;
          num_states : BITCODE_BL;
          states : PDwg_BLOCKVISIBILITYPARAMETER_state;
        end;
      Dwg_Object_BLOCKVISIBILITYPARAMETER = _dwg_object_BLOCKVISIBILITYPARAMETER;
      //PDwg_Object_BLOCKVISIBILITYPARAMETER = ^Dwg_Object_BLOCKVISIBILITYPARAMETER;

      //P_dwg_object_BLOCKVISIBILITYGRIP = ^_dwg_object_BLOCKVISIBILITYGRIP;
      _dwg_object_BLOCKVISIBILITYGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
        end;
      Dwg_Object_BLOCKVISIBILITYGRIP = _dwg_object_BLOCKVISIBILITYGRIP;
      //PDwg_Object_BLOCKVISIBILITYGRIP = ^Dwg_Object_BLOCKVISIBILITYGRIP;

      //P_dwg_object_BLOCKGRIPLOCATIONCOMPONENT = ^_dwg_object_BLOCKGRIPLOCATIONCOMPONENT;
      _dwg_object_BLOCKGRIPLOCATIONCOMPONENT = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          grip_type : BITCODE_BL;
          grip_expr : BITCODE_TV;
        end;
      Dwg_Object_BLOCKGRIPLOCATIONCOMPONENT = _dwg_object_BLOCKGRIPLOCATIONCOMPONENT;
      //PDwg_Object_BLOCKGRIPLOCATIONCOMPONENT = ^Dwg_Object_BLOCKGRIPLOCATIONCOMPONENT;

      //P_dwg_object_BREAKDATA = ^_dwg_object_BREAKDATA;
      _dwg_object_BREAKDATA = record
          parent : P_dwg_object_object;
          num_pointrefs : BITCODE_BL;
          pointrefs : PBITCODE_H;
          dimref : BITCODE_H;
        end;
      Dwg_Object_BREAKDATA = _dwg_object_BREAKDATA;
      //PDwg_Object_BREAKDATA = ^Dwg_Object_BREAKDATA;

      //P_dwg_object_BREAKPOINTREF = ^_dwg_object_BREAKPOINTREF;
      _dwg_object_BREAKPOINTREF = record
          parent : P_dwg_object_object;
        end;
      Dwg_Object_BREAKPOINTREF = _dwg_object_BREAKPOINTREF;
      //PDwg_Object_BREAKPOINTREF = ^Dwg_Object_BREAKPOINTREF;

      //P_dwg_entity_FLIPGRIPENTITY = ^_dwg_entity_FLIPGRIPENTITY;
      _dwg_entity_FLIPGRIPENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_FLIPGRIPENTITY = _dwg_entity_FLIPGRIPENTITY;
      //PDwg_Entity_FLIPGRIPENTITY = ^Dwg_Entity_FLIPGRIPENTITY;

      //P_dwg_entity_LINEARGRIPENTITY = ^_dwg_entity_LINEARGRIPENTITY;
      _dwg_entity_LINEARGRIPENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_LINEARGRIPENTITY = _dwg_entity_LINEARGRIPENTITY;
      //PDwg_Entity_LINEARGRIPENTITY = ^Dwg_Entity_LINEARGRIPENTITY;

      //P_dwg_entity_POLARGRIPENTITY = ^_dwg_entity_POLARGRIPENTITY;
      _dwg_entity_POLARGRIPENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_POLARGRIPENTITY = _dwg_entity_POLARGRIPENTITY;
      //PDwg_Entity_POLARGRIPENTITY = ^Dwg_Entity_POLARGRIPENTITY;

      //P_dwg_entity_ROTATIONGRIPENTITY = ^_dwg_entity_ROTATIONGRIPENTITY;
      _dwg_entity_ROTATIONGRIPENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_ROTATIONGRIPENTITY = _dwg_entity_ROTATIONGRIPENTITY;
      //PDwg_Entity_ROTATIONGRIPENTITY = ^Dwg_Entity_ROTATIONGRIPENTITY;

      //P_dwg_entity_VISIBILITYGRIPENTITY = ^_dwg_entity_VISIBILITYGRIPENTITY;
      _dwg_entity_VISIBILITYGRIPENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_VISIBILITYGRIPENTITY = _dwg_entity_VISIBILITYGRIPENTITY;
      //PDwg_Entity_VISIBILITYGRIPENTITY = ^Dwg_Entity_VISIBILITYGRIPENTITY;

      //P_dwg_entity_XYGRIPENTITY = ^_dwg_entity_XYGRIPENTITY;
      _dwg_entity_XYGRIPENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_XYGRIPENTITY = _dwg_entity_XYGRIPENTITY;
      //PDwg_Entity_XYGRIPENTITY = ^Dwg_Entity_XYGRIPENTITY;

      //P_dwg_entity_ALIGNMENTPARAMETERENTITY = ^_dwg_entity_ALIGNMENTPARAMETERENTITY;
      _dwg_entity_ALIGNMENTPARAMETERENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_ALIGNMENTPARAMETERENTITY = _dwg_entity_ALIGNMENTPARAMETERENTITY;
      //PDwg_Entity_ALIGNMENTPARAMETERENTITY = ^Dwg_Entity_ALIGNMENTPARAMETERENTITY;

      //P_dwg_entity_BASEPOINTPARAMETERENTITY = ^_dwg_entity_BASEPOINTPARAMETERENTITY;
      _dwg_entity_BASEPOINTPARAMETERENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_BASEPOINTPARAMETERENTITY = _dwg_entity_BASEPOINTPARAMETERENTITY;
      //PDwg_Entity_BASEPOINTPARAMETERENTITY = ^Dwg_Entity_BASEPOINTPARAMETERENTITY;

      //P_dwg_entity_FLIPPARAMETERENTITY = ^_dwg_entity_FLIPPARAMETERENTITY;
      _dwg_entity_FLIPPARAMETERENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_FLIPPARAMETERENTITY = _dwg_entity_FLIPPARAMETERENTITY;
      //PDwg_Entity_FLIPPARAMETERENTITY = ^Dwg_Entity_FLIPPARAMETERENTITY;

      //P_dwg_entity_LINEARPARAMETERENTITY = ^_dwg_entity_LINEARPARAMETERENTITY;
      _dwg_entity_LINEARPARAMETERENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_LINEARPARAMETERENTITY = _dwg_entity_LINEARPARAMETERENTITY;
      //PDwg_Entity_LINEARPARAMETERENTITY = ^Dwg_Entity_LINEARPARAMETERENTITY;

      //P_dwg_entity_POINTPARAMETERENTITY = ^_dwg_entity_POINTPARAMETERENTITY;
      _dwg_entity_POINTPARAMETERENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_POINTPARAMETERENTITY = _dwg_entity_POINTPARAMETERENTITY;
      //PDwg_Entity_POINTPARAMETERENTITY = ^Dwg_Entity_POINTPARAMETERENTITY;

      //P_dwg_entity_ROTATIONPARAMETERENTITY = ^_dwg_entity_ROTATIONPARAMETERENTITY;
      _dwg_entity_ROTATIONPARAMETERENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_ROTATIONPARAMETERENTITY = _dwg_entity_ROTATIONPARAMETERENTITY;
      //PDwg_Entity_ROTATIONPARAMETERENTITY = ^Dwg_Entity_ROTATIONPARAMETERENTITY;

      //P_dwg_entity_VISIBILITYPARAMETERENTITY = ^_dwg_entity_VISIBILITYPARAMETERENTITY;
      _dwg_entity_VISIBILITYPARAMETERENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_VISIBILITYPARAMETERENTITY = _dwg_entity_VISIBILITYPARAMETERENTITY;
      //PDwg_Entity_VISIBILITYPARAMETERENTITY = ^Dwg_Entity_VISIBILITYPARAMETERENTITY;

      //P_dwg_entity_XYPARAMETERENTITY = ^_dwg_entity_XYPARAMETERENTITY;
      _dwg_entity_XYPARAMETERENTITY = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_XYPARAMETERENTITY = _dwg_entity_XYPARAMETERENTITY;
      //PDwg_Entity_XYPARAMETERENTITY = ^Dwg_Entity_XYPARAMETERENTITY;

      //P_dwg_object_BLOCKALIGNMENTGRIP = ^_dwg_object_BLOCKALIGNMENTGRIP;
      _dwg_object_BLOCKALIGNMENTGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
          orientation : BITCODE_3BD;
        end;
      Dwg_Object_BLOCKALIGNMENTGRIP = _dwg_object_BLOCKALIGNMENTGRIP;
      //PDwg_Object_BLOCKALIGNMENTGRIP = ^Dwg_Object_BLOCKALIGNMENTGRIP;

      //P_dwg_object_BLOCKALIGNMENTPARAMETER = ^_dwg_object_BLOCKALIGNMENTPARAMETER;
      _dwg_object_BLOCKALIGNMENTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          align_perpendicular : BITCODE_B;
        end;
      Dwg_Object_BLOCKALIGNMENTPARAMETER = _dwg_object_BLOCKALIGNMENTPARAMETER;
      //PDwg_Object_BLOCKALIGNMENTPARAMETER = ^Dwg_Object_BLOCKALIGNMENTPARAMETER;

      //P_dwg_object_BLOCKANGULARCONSTRAINTPARAMETER = ^_dwg_object_BLOCKANGULARCONSTRAINTPARAMETER;
      _dwg_object_BLOCKANGULARCONSTRAINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          dependency : BITCODE_H;
          center_pt : BITCODE_3BD;
          end_pt : BITCODE_3BD;
          expr_name : BITCODE_TV;
          expr_description : BITCODE_TV;
          angle : BITCODE_BD;
          orientation_on_both_grips : BITCODE_B;
          value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKANGULARCONSTRAINTPARAMETER = _dwg_object_BLOCKANGULARCONSTRAINTPARAMETER;
      //PDwg_Object_BLOCKANGULARCONSTRAINTPARAMETER = ^Dwg_Object_BLOCKANGULARCONSTRAINTPARAMETER;

      //P_dwg_object_BLOCKDIAMETRICCONSTRAINTPARAMETER = ^_dwg_object_BLOCKDIAMETRICCONSTRAINTPARAMETER;
      _dwg_object_BLOCKDIAMETRICCONSTRAINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          dependency : BITCODE_H;
          expr_name : BITCODE_TV;
          expr_description : BITCODE_TV;
          distance : BITCODE_BD;
          orientation_on_both_grips : BITCODE_B;
          value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKDIAMETRICCONSTRAINTPARAMETER = _dwg_object_BLOCKDIAMETRICCONSTRAINTPARAMETER;
      //PDwg_Object_BLOCKDIAMETRICCONSTRAINTPARAMETER = ^Dwg_Object_BLOCKDIAMETRICCONSTRAINTPARAMETER;

      //P_dwg_object_BLOCKRADIALCONSTRAINTPARAMETER = ^_dwg_object_BLOCKRADIALCONSTRAINTPARAMETER;
      _dwg_object_BLOCKRADIALCONSTRAINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          dependency : BITCODE_H;
          expr_name : BITCODE_TV;
          expr_description : BITCODE_TV;
          distance : BITCODE_BD;
          value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKRADIALCONSTRAINTPARAMETER = _dwg_object_BLOCKRADIALCONSTRAINTPARAMETER;
      //PDwg_Object_BLOCKRADIALCONSTRAINTPARAMETER = ^Dwg_Object_BLOCKRADIALCONSTRAINTPARAMETER;

      //P_dwg_object_BLOCKARRAYACTION = ^_dwg_object_BLOCKARRAYACTION;
      _dwg_object_BLOCKARRAYACTION = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          display_location : BITCODE_3BD;
          num_actions : BITCODE_BL;
          actions : PBITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          conn_pts : array[0..3] of Dwg_BLOCKACTION_connectionpts;
          column_offset : BITCODE_BD;
          row_offset : BITCODE_BD;
        end;
      Dwg_Object_BLOCKARRAYACTION = _dwg_object_BLOCKARRAYACTION;
      //PDwg_Object_BLOCKARRAYACTION = ^Dwg_Object_BLOCKARRAYACTION;

      //P_dwg_object_BLOCKBASEPOINTPARAMETER = ^_dwg_object_BLOCKBASEPOINTPARAMETER;
      _dwg_object_BLOCKBASEPOINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_pt : BITCODE_3BD;
          num_propinfos : BITCODE_BL;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          pt : BITCODE_3BD;
          base_pt : BITCODE_3BD;
        end;
      Dwg_Object_BLOCKBASEPOINTPARAMETER = _dwg_object_BLOCKBASEPOINTPARAMETER;
      //PDwg_Object_BLOCKBASEPOINTPARAMETER = ^Dwg_Object_BLOCKBASEPOINTPARAMETER;

      //P_dwg_object_BLOCKFLIPACTION = ^_dwg_object_BLOCKFLIPACTION;
      _dwg_object_BLOCKFLIPACTION = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          display_location : BITCODE_3BD;
          num_actions : BITCODE_BL;
          actions : PBITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          conn_pts : array[0..3] of Dwg_BLOCKACTION_connectionpts;
          action_offset_x : BITCODE_BD;
          action_offset_y : BITCODE_BD;
          angle_offset : BITCODE_BD;
        end;
      Dwg_Object_BLOCKFLIPACTION = _dwg_object_BLOCKFLIPACTION;
      //PDwg_Object_BLOCKFLIPACTION = ^Dwg_Object_BLOCKFLIPACTION;

      //P_dwg_object_BLOCKFLIPGRIP = ^_dwg_object_BLOCKFLIPGRIP;
      _dwg_object_BLOCKFLIPGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
          combined_state : BITCODE_BL;
          orientation : BITCODE_3BD;
          upd_state : BITCODE_BS;
          state : BITCODE_BS;
        end;
      Dwg_Object_BLOCKFLIPGRIP = _dwg_object_BLOCKFLIPGRIP;
      //PDwg_Object_BLOCKFLIPGRIP = ^Dwg_Object_BLOCKFLIPGRIP;

      //P_dwg_object_BLOCKFLIPPARAMETER = ^_dwg_object_BLOCKFLIPPARAMETER;
      _dwg_object_BLOCKFLIPPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          flip_label : BITCODE_TV;
          flip_label_desc : BITCODE_TV;
          base_state_label : BITCODE_TV;
          flipped_state_label : BITCODE_TV;
          def_label_pt : BITCODE_3BD;
          bl96 : BITCODE_BL;
          tooltip : BITCODE_TV;
        end;
      Dwg_Object_BLOCKFLIPPARAMETER = _dwg_object_BLOCKFLIPPARAMETER;
      //PDwg_Object_BLOCKFLIPPARAMETER = ^Dwg_Object_BLOCKFLIPPARAMETER;

      //P_dwg_object_BLOCKALIGNEDCONSTRAINTPARAMETER = ^_dwg_object_BLOCKALIGNEDCONSTRAINTPARAMETER;
      _dwg_object_BLOCKALIGNEDCONSTRAINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          dependency : BITCODE_H;
          expr_name : BITCODE_TV;
          expr_description : BITCODE_TV;
          value : BITCODE_BD;
          value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKALIGNEDCONSTRAINTPARAMETER = _dwg_object_BLOCKALIGNEDCONSTRAINTPARAMETER;
      //PDwg_Object_BLOCKALIGNEDCONSTRAINTPARAMETER = ^Dwg_Object_BLOCKALIGNEDCONSTRAINTPARAMETER;

      //P_dwg_object_BLOCKLINEARCONSTRAINTPARAMETER = ^_dwg_object_BLOCKLINEARCONSTRAINTPARAMETER;
      _dwg_object_BLOCKLINEARCONSTRAINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          dependency : BITCODE_H;
          expr_name : BITCODE_TV;
          expr_description : BITCODE_TV;
          value : BITCODE_BD;
          value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKLINEARCONSTRAINTPARAMETER = _dwg_object_BLOCKLINEARCONSTRAINTPARAMETER;
      //PDwg_Object_BLOCKLINEARCONSTRAINTPARAMETER = ^Dwg_Object_BLOCKLINEARCONSTRAINTPARAMETER;

      //P_dwg_object_BLOCKHORIZONTALCONSTRAINTPARAMETER = ^_dwg_object_BLOCKHORIZONTALCONSTRAINTPARAMETER;
      _dwg_object_BLOCKHORIZONTALCONSTRAINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          dependency : BITCODE_H;
          expr_name : BITCODE_TV;
          expr_description : BITCODE_TV;
          value : BITCODE_BD;
          value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKHORIZONTALCONSTRAINTPARAMETER = _dwg_object_BLOCKHORIZONTALCONSTRAINTPARAMETER;
      //PDwg_Object_BLOCKHORIZONTALCONSTRAINTPARAMETER = ^Dwg_Object_BLOCKHORIZONTALCONSTRAINTPARAMETER;

      //P_dwg_object_BLOCKVERTICALCONSTRAINTPARAMETER = ^_dwg_object_BLOCKVERTICALCONSTRAINTPARAMETER;
      _dwg_object_BLOCKVERTICALCONSTRAINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          dependency : BITCODE_H;
          expr_name : BITCODE_TV;
          expr_description : BITCODE_TV;
          value : BITCODE_BD;
          value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKVERTICALCONSTRAINTPARAMETER = _dwg_object_BLOCKVERTICALCONSTRAINTPARAMETER;
      //PDwg_Object_BLOCKVERTICALCONSTRAINTPARAMETER = ^Dwg_Object_BLOCKVERTICALCONSTRAINTPARAMETER;

      //P_dwg_object_BLOCKLINEARGRIP = ^_dwg_object_BLOCKLINEARGRIP;
      _dwg_object_BLOCKLINEARGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
          orientation : BITCODE_3BD;
        end;
      Dwg_Object_BLOCKLINEARGRIP = _dwg_object_BLOCKLINEARGRIP;
      //PDwg_Object_BLOCKLINEARGRIP = ^Dwg_Object_BLOCKLINEARGRIP;

      //P_dwg_object_BLOCKLINEARPARAMETER = ^_dwg_object_BLOCKLINEARPARAMETER;
      _dwg_object_BLOCKLINEARPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          distance_name : BITCODE_TV;
          distance_desc : BITCODE_TV;
          distance : BITCODE_BD;
          value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKLINEARPARAMETER = _dwg_object_BLOCKLINEARPARAMETER;
      //PDwg_Object_BLOCKLINEARPARAMETER = ^Dwg_Object_BLOCKLINEARPARAMETER;

      //P_dwg_BLOCKLOOKUPACTION_lut = ^_dwg_BLOCKLOOKUPACTION_lut;
      _dwg_BLOCKLOOKUPACTION_lut = record
          parent : P_dwg_object_BLOCKLOOKUPACTION;
          conn_pts : array[0..2] of Dwg_BLOCKACTION_connectionpts;
          b282 : BITCODE_B;
          b281 : BITCODE_B;
        end;
      Dwg_BLOCKLOOKUPACTION_lut = _dwg_BLOCKLOOKUPACTION_lut;
      //PDwg_BLOCKLOOKUPACTION_lut = ^Dwg_BLOCKLOOKUPACTION_lut;

      //P_dwg_object_BLOCKLOOKUPACTION = ^_dwg_object_BLOCKLOOKUPACTION;
      _dwg_object_BLOCKLOOKUPACTION = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          display_location : BITCODE_3BD;
          num_actions : BITCODE_BL;
          actions : PBITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          numelems : BITCODE_BL;
          numrows : BITCODE_BL;
          numcols : BITCODE_BL;
          lut : PDwg_BLOCKLOOKUPACTION_lut;
          exprs : PBITCODE_TV;
          b280 : BITCODE_B;
        end;
      Dwg_Object_BLOCKLOOKUPACTION = _dwg_object_BLOCKLOOKUPACTION;
      //PDwg_Object_BLOCKLOOKUPACTION = ^Dwg_Object_BLOCKLOOKUPACTION;

      //P_dwg_object_BLOCKLOOKUPGRIP = ^_dwg_object_BLOCKLOOKUPGRIP;
      _dwg_object_BLOCKLOOKUPGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
        end;
      Dwg_Object_BLOCKLOOKUPGRIP = _dwg_object_BLOCKLOOKUPGRIP;
      //PDwg_Object_BLOCKLOOKUPGRIP = ^Dwg_Object_BLOCKLOOKUPGRIP;

      //P_dwg_object_BLOCKLOOKUPPARAMETER = ^_dwg_object_BLOCKLOOKUPPARAMETER;
      _dwg_object_BLOCKLOOKUPPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_pt : BITCODE_3BD;
          num_propinfos : BITCODE_BL;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          lookup_name : BITCODE_TV;
          lookup_desc : BITCODE_TV;
          index : BITCODE_BL;
          unknown_t : BITCODE_TV;
        end;
      Dwg_Object_BLOCKLOOKUPPARAMETER = _dwg_object_BLOCKLOOKUPPARAMETER;
      //PDwg_Object_BLOCKLOOKUPPARAMETER = ^Dwg_Object_BLOCKLOOKUPPARAMETER;

      //P_dwg_object_BLOCKMOVEACTION = ^_dwg_object_BLOCKMOVEACTION;
      _dwg_object_BLOCKMOVEACTION = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          display_location : BITCODE_3BD;
          num_actions : BITCODE_BL;
          actions : PBITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          conn_pts : array[0..1] of Dwg_BLOCKACTION_connectionpts;
          action_offset_x : BITCODE_BD;
          action_offset_y : BITCODE_BD;
          angle_offset : BITCODE_BD;
        end;
      Dwg_Object_BLOCKMOVEACTION = _dwg_object_BLOCKMOVEACTION;
      //PDwg_Object_BLOCKMOVEACTION = ^Dwg_Object_BLOCKMOVEACTION;

      //P_dwg_object_BLOCKPOINTPARAMETER = ^_dwg_object_BLOCKPOINTPARAMETER;
      _dwg_object_BLOCKPOINTPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_pt : BITCODE_3BD;
          num_propinfos : BITCODE_BL;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          position_name : BITCODE_TV;
          position_desc : BITCODE_TV;
          def_label_pt : BITCODE_3BD;
        end;
      Dwg_Object_BLOCKPOINTPARAMETER = _dwg_object_BLOCKPOINTPARAMETER;
      //PDwg_Object_BLOCKPOINTPARAMETER = ^Dwg_Object_BLOCKPOINTPARAMETER;

      //P_dwg_object_BLOCKPOLARGRIP = ^_dwg_object_BLOCKPOLARGRIP;
      _dwg_object_BLOCKPOLARGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
        end;
      Dwg_Object_BLOCKPOLARGRIP = _dwg_object_BLOCKPOLARGRIP;
      //PDwg_Object_BLOCKPOLARGRIP = ^Dwg_Object_BLOCKPOLARGRIP;

      //P_dwg_object_BLOCKPOLARPARAMETER = ^_dwg_object_BLOCKPOLARPARAMETER;
      _dwg_object_BLOCKPOLARPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          angle_name : BITCODE_TV;
          angle_desc : BITCODE_TV;
          distance_name : BITCODE_TV;
          distance_desc : BITCODE_TV;
          offset : BITCODE_BD;
          angle_value_set : Dwg_BLOCKPARAMVALUESET;
          distance_value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKPOLARPARAMETER = _dwg_object_BLOCKPOLARPARAMETER;
      //PDwg_Object_BLOCKPOLARPARAMETER = ^Dwg_Object_BLOCKPOLARPARAMETER;

      //P_dwg_object_BLOCKPOLARSTRETCHACTION = ^_dwg_object_BLOCKPOLARSTRETCHACTION;
      _dwg_object_BLOCKPOLARSTRETCHACTION = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          display_location : BITCODE_3BD;
          num_actions : BITCODE_BL;
          actions : PBITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          conn_pts : array[0..5] of Dwg_BLOCKACTION_connectionpts;
          num_pts : BITCODE_BL;
          pts : PBITCODE_2RD;
          num_hdls : BITCODE_BL;
          hdls : PBITCODE_H;
          shorts : PBITCODE_BS;
          num_codes : BITCODE_BL;
          codes : PBITCODE_BL;
        end;
      Dwg_Object_BLOCKPOLARSTRETCHACTION = _dwg_object_BLOCKPOLARSTRETCHACTION;
      //PDwg_Object_BLOCKPOLARSTRETCHACTION = ^Dwg_Object_BLOCKPOLARSTRETCHACTION;

      //P_dwg_object_BLOCKPROPERTIESTABLE = ^_dwg_object_BLOCKPROPERTIESTABLE;
      _dwg_object_BLOCKPROPERTIESTABLE = record
          parent : P_dwg_object_object;
        end;
      Dwg_Object_BLOCKPROPERTIESTABLE = _dwg_object_BLOCKPROPERTIESTABLE;
      //PDwg_Object_BLOCKPROPERTIESTABLE = ^Dwg_Object_BLOCKPROPERTIESTABLE;

      //P_dwg_object_BLOCKPROPERTIESTABLEGRIP = ^_dwg_object_BLOCKPROPERTIESTABLEGRIP;
      _dwg_object_BLOCKPROPERTIESTABLEGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
        end;
      Dwg_Object_BLOCKPROPERTIESTABLEGRIP = _dwg_object_BLOCKPROPERTIESTABLEGRIP;
      //PDwg_Object_BLOCKPROPERTIESTABLEGRIP = ^Dwg_Object_BLOCKPROPERTIESTABLEGRIP;

      //P_dwg_object_BLOCKREPRESENTATION = ^_dwg_object_BLOCKREPRESENTATION;
      _dwg_object_BLOCKREPRESENTATION = record
          parent : P_dwg_object_object;
          flag : BITCODE_BS;
          block : BITCODE_H;
        end;
      Dwg_Object_BLOCKREPRESENTATION = _dwg_object_BLOCKREPRESENTATION;
      //PDwg_Object_BLOCKREPRESENTATION = ^Dwg_Object_BLOCKREPRESENTATION;

      //P_dwg_object_BLOCKROTATEACTION = ^_dwg_object_BLOCKROTATEACTION;
      _dwg_object_BLOCKROTATEACTION = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          display_location : BITCODE_3BD;
          num_actions : BITCODE_BL;
          actions : PBITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          offset : BITCODE_3BD;
          conn_pts : array[0..2] of Dwg_BLOCKACTION_connectionpts;
          dependent : BITCODE_B;
          base_pt : BITCODE_3BD;
        end;
      Dwg_Object_BLOCKROTATEACTION = _dwg_object_BLOCKROTATEACTION;
      //PDwg_Object_BLOCKROTATEACTION = ^Dwg_Object_BLOCKROTATEACTION;

      //P_dwg_object_BLOCKROTATIONGRIP = ^_dwg_object_BLOCKROTATIONGRIP;
      _dwg_object_BLOCKROTATIONGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
        end;
      Dwg_Object_BLOCKROTATIONGRIP = _dwg_object_BLOCKROTATIONGRIP;
      //PDwg_Object_BLOCKROTATIONGRIP = ^Dwg_Object_BLOCKROTATIONGRIP;

      //P_dwg_object_BLOCKROTATIONPARAMETER = ^_dwg_object_BLOCKROTATIONPARAMETER;
      _dwg_object_BLOCKROTATIONPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          def_base_angle_pt : BITCODE_3BD;
          angle_name : BITCODE_TV;
          angle_desc : BITCODE_TV;
          angle : BITCODE_BD;
          angle_value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKROTATIONPARAMETER = _dwg_object_BLOCKROTATIONPARAMETER;
      //PDwg_Object_BLOCKROTATIONPARAMETER = ^Dwg_Object_BLOCKROTATIONPARAMETER;

      //P_dwg_object_BLOCKSCALEACTION = ^_dwg_object_BLOCKSCALEACTION;
      _dwg_object_BLOCKSCALEACTION = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          display_location : BITCODE_3BD;
          num_actions : BITCODE_BL;
          actions : PBITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          offset : BITCODE_3BD;
          conn_pts : array[0..4] of Dwg_BLOCKACTION_connectionpts;
          dependent : BITCODE_B;
          base_pt : BITCODE_3BD;
        end;
      Dwg_Object_BLOCKSCALEACTION = _dwg_object_BLOCKSCALEACTION;
      //PDwg_Object_BLOCKSCALEACTION = ^Dwg_Object_BLOCKSCALEACTION;

      //P_dwg_object_BLOCKSTRETCHACTION = ^_dwg_object_BLOCKSTRETCHACTION;
      _dwg_object_BLOCKSTRETCHACTION = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          display_location : BITCODE_3BD;
          num_actions : BITCODE_BL;
          actions : PBITCODE_BL;
          num_deps : BITCODE_BL;
          deps : PBITCODE_H;
          conn_pts : array[0..1] of Dwg_BLOCKACTION_connectionpts;
          num_pts : BITCODE_BL;
          pts : PBITCODE_2RD;
          num_hdls : BITCODE_BL;
          hdls : PBITCODE_H;
          shorts : PBITCODE_BS;
          num_codes : BITCODE_BL;
          codes : PBITCODE_BL;
          action_offset_x : BITCODE_BD;
          action_offset_y : BITCODE_BD;
          angle_offset : BITCODE_BD;
        end;
      Dwg_Object_BLOCKSTRETCHACTION = _dwg_object_BLOCKSTRETCHACTION;
      //PDwg_Object_BLOCKSTRETCHACTION = ^Dwg_Object_BLOCKSTRETCHACTION;

      //P_dwg_object_BLOCKUSERPARAMETER = ^_dwg_object_BLOCKUSERPARAMETER;
      _dwg_object_BLOCKUSERPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_pt : BITCODE_3BD;
          num_propinfos : BITCODE_BL;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          flag : BITCODE_BS;
          assocvariable : BITCODE_H;
          expr : BITCODE_TV;
          value : Dwg_EvalVariant;
          _type : BITCODE_BS;
        end;
      Dwg_Object_BLOCKUSERPARAMETER = _dwg_object_BLOCKUSERPARAMETER;
      //PDwg_Object_BLOCKUSERPARAMETER = ^Dwg_Object_BLOCKUSERPARAMETER;

      //P_dwg_object_BLOCKXYGRIP = ^_dwg_object_BLOCKXYGRIP;
      _dwg_object_BLOCKXYGRIP = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          bg_bl91 : BITCODE_BL;
          bg_bl92 : BITCODE_BL;
          bg_location : BITCODE_3BD;
          bg_insert_cycling : BITCODE_B;
          bg_insert_cycling_weight : BITCODE_BLd;
        end;
      Dwg_Object_BLOCKXYGRIP = _dwg_object_BLOCKXYGRIP;
      //PDwg_Object_BLOCKXYGRIP = ^Dwg_Object_BLOCKXYGRIP;

      //P_dwg_object_BLOCKXYPARAMETER = ^_dwg_object_BLOCKXYPARAMETER;
      _dwg_object_BLOCKXYPARAMETER = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
          name : BITCODE_TV;
          be_major : BITCODE_BL;
          be_minor : BITCODE_BL;
          eed1071 : BITCODE_BL;
          show_properties : BITCODE_B;
          chain_actions : BITCODE_B;
          def_basept : BITCODE_3BD;
          def_endpt : BITCODE_3BD;
          prop1 : Dwg_BLOCKPARAMETER_PropInfo;
          prop2 : Dwg_BLOCKPARAMETER_PropInfo;
          prop3 : Dwg_BLOCKPARAMETER_PropInfo;
          prop4 : Dwg_BLOCKPARAMETER_PropInfo;
          prop_states : PBITCODE_BL;
          parameter_base_location : BITCODE_BS;
          upd_basept : BITCODE_3BD;
          basept : BITCODE_3BD;
          upd_endpt : BITCODE_3BD;
          endpt : BITCODE_3BD;
          x_label : BITCODE_TV;
          x_label_desc : BITCODE_TV;
          y_label : BITCODE_TV;
          y_label_desc : BITCODE_TV;
          x_value : BITCODE_BD;
          y_value : BITCODE_BD;
          x_value_set : Dwg_BLOCKPARAMVALUESET;
          y_value_set : Dwg_BLOCKPARAMVALUESET;
        end;
      Dwg_Object_BLOCKXYPARAMETER = _dwg_object_BLOCKXYPARAMETER;
      //PDwg_Object_BLOCKXYPARAMETER = ^Dwg_Object_BLOCKXYPARAMETER;

      //P_dwg_object_DYNAMICBLOCKPROXYNODE = ^_dwg_object_DYNAMICBLOCKPROXYNODE;
      _dwg_object_DYNAMICBLOCKPROXYNODE = record
          parent : P_dwg_object_object;
          evalexpr : Dwg_EvalExpr;
        end;
      Dwg_Object_DYNAMICBLOCKPROXYNODE = _dwg_object_DYNAMICBLOCKPROXYNODE;
      //PDwg_Object_DYNAMICBLOCKPROXYNODE = ^Dwg_Object_DYNAMICBLOCKPROXYNODE;

      //P_dwg_POINTCLOUD_IntensityStyle = ^_dwg_POINTCLOUD_IntensityStyle;
      _dwg_POINTCLOUD_IntensityStyle = record
          parent : P_dwg_entity_POINTCLOUD;
          min_intensity : BITCODE_BD;
          max_intensity : BITCODE_BD;
          intensity_low_treshold : BITCODE_BD;
          intensity_high_treshold : BITCODE_BD;
        end;
      Dwg_POINTCLOUD_IntensityStyle = _dwg_POINTCLOUD_IntensityStyle;
      //PDwg_POINTCLOUD_IntensityStyle = ^Dwg_POINTCLOUD_IntensityStyle;

      //P_dwg_POINTCLOUD_Clippings = ^_dwg_POINTCLOUD_Clippings;
      _dwg_POINTCLOUD_Clippings = record
          parent : P_dwg_entity_POINTCLOUD;
          is_inverted : BITCODE_B;
          _type : BITCODE_BS;
          num_vertices : BITCODE_BL;
          vertices : PBITCODE_2RD;
          z_min : BITCODE_BD;
          z_max : BITCODE_BD;
        end;
      Dwg_POINTCLOUD_Clippings = _dwg_POINTCLOUD_Clippings;
      //PDwg_POINTCLOUD_Clippings = ^Dwg_POINTCLOUD_Clippings;

      //P_dwg_POINTCLOUDEX_Croppings = ^_dwg_POINTCLOUDEX_Croppings;
      _dwg_POINTCLOUDEX_Croppings = record
          parent : P_dwg_entity_POINTCLOUDEX;
          _type : BITCODE_BS;
          is_inside : BITCODE_B;
          is_inverted : BITCODE_B;
          crop_plane : BITCODE_3BD;
          crop_x_dir : BITCODE_3BD;
          crop_y_dir : BITCODE_3BD;
          num_pts : BITCODE_BL;
          pts : PBITCODE_3BD;
        end;
      Dwg_POINTCLOUDEX_Croppings = _dwg_POINTCLOUDEX_Croppings;
      //PDwg_POINTCLOUDEX_Croppings = ^Dwg_POINTCLOUDEX_Croppings;

      //P_dwg_entity_POINTCLOUD = ^_dwg_entity_POINTCLOUD;
      _dwg_entity_POINTCLOUD = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_BS;
          origin : BITCODE_3BD;
          saved_filename : BITCODE_TV;
          num_source_files : BITCODE_BL;
          source_files : PBITCODE_TV;
          extents_min : BITCODE_3BD;
          extents_max : BITCODE_3BD;
          numpoints : BITCODE_RLL;
          ucs_name : BITCODE_TV;
          ucs_origin : BITCODE_3BD;
          ucs_x_dir : BITCODE_3BD;
          ucs_y_dir : BITCODE_3BD;
          ucs_z_dir : BITCODE_3BD;
          pointclouddef : BITCODE_H;
          reactor : BITCODE_H;
          show_intensity : BITCODE_B;
          intensity_scheme : BITCODE_BS;
          intensity_style : Dwg_POINTCLOUD_IntensityStyle;
          show_clipping : BITCODE_B;
          num_clippings : BITCODE_BL;
          clippings : PDwg_POINTCLOUD_Clippings;
        end;
      Dwg_Entity_POINTCLOUD = _dwg_entity_POINTCLOUD;
      //PDwg_Entity_POINTCLOUD = ^Dwg_Entity_POINTCLOUD;

      //P_dwg_entity_POINTCLOUDEX = ^_dwg_entity_POINTCLOUDEX;
      _dwg_entity_POINTCLOUDEX = record
          parent : P_dwg_object_entity;
          class_version : BITCODE_BS;
          extents_min : BITCODE_3BD;
          extents_max : BITCODE_3BD;
          ucs_origin : BITCODE_3BD;
          ucs_x_dir : BITCODE_3BD;
          ucs_y_dir : BITCODE_3BD;
          ucs_z_dir : BITCODE_3BD;
          is_locked : BITCODE_B;
          pointclouddefex : BITCODE_H;
          reactor : BITCODE_H;
          name : BITCODE_TV;
          show_intensity : BITCODE_B;
          stylization_type : BITCODE_BS;
          intensity_colorscheme : BITCODE_TV;
          cur_colorscheme : BITCODE_TV;
          classification_colorscheme : BITCODE_TV;
          elevation_min : BITCODE_BD;
          elevation_max : BITCODE_BD;
          intensity_min : BITCODE_BL;
          intensity_max : BITCODE_BL;
          intensity_out_of_range_behavior : BITCODE_BS;
          elevation_out_of_range_behavior : BITCODE_BS;
          elevation_apply_to_fixed_range : BITCODE_B;
          intensity_as_gradient : BITCODE_B;
          elevation_as_gradient : BITCODE_B;
          show_cropping : BITCODE_B;
          unknown_bl0 : BITCODE_BL;
          unknown_bl1 : BITCODE_BL;
          num_croppings : BITCODE_BL;
          croppings : PDwg_POINTCLOUDEX_Croppings;
        end;
      Dwg_Entity_POINTCLOUDEX = _dwg_entity_POINTCLOUDEX;
      //PDwg_Entity_POINTCLOUDEX = ^Dwg_Entity_POINTCLOUDEX;

      //P_dwg_object_POINTCLOUDDEF = ^_dwg_object_POINTCLOUDDEF;
      _dwg_object_POINTCLOUDDEF = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          source_filename : BITCODE_TV;
          is_loaded : BITCODE_B;
          numpoints : BITCODE_RLL;
          extents_min : BITCODE_3BD;
          extents_max : BITCODE_3BD;
        end;
      Dwg_Object_POINTCLOUDDEF = _dwg_object_POINTCLOUDDEF;
      //PDwg_Object_POINTCLOUDDEF = ^Dwg_Object_POINTCLOUDDEF;

      //P_dwg_object_POINTCLOUDDEFEX = ^_dwg_object_POINTCLOUDDEFEX;
      _dwg_object_POINTCLOUDDEFEX = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
          source_filename : BITCODE_TV;
          is_loaded : BITCODE_B;
          numpoints : BITCODE_RLL;
          extents_min : BITCODE_3BD;
          extents_max : BITCODE_3BD;
        end;
      Dwg_Object_POINTCLOUDDEFEX = _dwg_object_POINTCLOUDDEFEX;
      //PDwg_Object_POINTCLOUDDEFEX = ^Dwg_Object_POINTCLOUDDEFEX;

      //P_dwg_object_POINTCLOUDDEF_REACTOR = ^_dwg_object_POINTCLOUDDEF_REACTOR;
      _dwg_object_POINTCLOUDDEF_REACTOR = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_POINTCLOUDDEF_REACTOR = _dwg_object_POINTCLOUDDEF_REACTOR;
      //PDwg_Object_POINTCLOUDDEF_REACTOR = ^Dwg_Object_POINTCLOUDDEF_REACTOR;

      //P_dwg_object_POINTCLOUDDEF_REACTOR_EX = ^_dwg_object_POINTCLOUDDEF_REACTOR_EX;
      _dwg_object_POINTCLOUDDEF_REACTOR_EX = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BL;
        end;
      Dwg_Object_POINTCLOUDDEF_REACTOR_EX = _dwg_object_POINTCLOUDDEF_REACTOR_EX;
      //PDwg_Object_POINTCLOUDDEF_REACTOR_EX = ^Dwg_Object_POINTCLOUDDEF_REACTOR_EX;

      //P_dwg_ColorRamp = ^_dwg_ColorRamp;
      _dwg_ColorRamp = record
          parent : P_dwg_POINTCLOUDCOLORMAP_Ramp;
          colorscheme : BITCODE_TV;
          unknown_bl : BITCODE_BL;
          unknown_b : BITCODE_B;
        end;
      Dwg_ColorRamp = _dwg_ColorRamp;
      //PDwg_ColorRamp = ^Dwg_ColorRamp;

      //P_dwg_POINTCLOUDCOLORMAP_Ramp = ^_dwg_POINTCLOUDCOLORMAP_Ramp;
      _dwg_POINTCLOUDCOLORMAP_Ramp = record
          parent : P_dwg_object_POINTCLOUDCOLORMAP;
          class_version : BITCODE_BS;
          num_ramps : BITCODE_BL;
          ramps : PDwg_ColorRamp;
        end;
      Dwg_POINTCLOUDCOLORMAP_Ramp = _dwg_POINTCLOUDCOLORMAP_Ramp;
      //PDwg_POINTCLOUDCOLORMAP_Ramp = ^Dwg_POINTCLOUDCOLORMAP_Ramp;

      //P_dwg_object_POINTCLOUDCOLORMAP = ^_dwg_object_POINTCLOUDCOLORMAP;
      _dwg_object_POINTCLOUDCOLORMAP = record
          parent : P_dwg_object_object;
          class_version : BITCODE_BS;
          def_intensity_colorscheme : BITCODE_TV;
          def_elevation_colorscheme : BITCODE_TV;
          def_classification_colorscheme : BITCODE_TV;
          num_colorramps : BITCODE_BL;
          colorramps : PDwg_POINTCLOUDCOLORMAP_Ramp;
          num_classification_colorramps : BITCODE_BL;
          classification_colorramps : PDwg_POINTCLOUDCOLORMAP_Ramp;
        end;
      Dwg_Object_POINTCLOUDCOLORMAP = _dwg_object_POINTCLOUDCOLORMAP;
      //PDwg_Object_POINTCLOUDCOLORMAP = ^Dwg_Object_POINTCLOUDCOLORMAP;

      //P_dwg_COMPOUNDOBJECTID = ^_dwg_COMPOUNDOBJECTID;
      _dwg_COMPOUNDOBJECTID = record
          parent : P_dwg_object_object;
          has_object : BITCODE_B;
          name : BITCODE_TV;
          &object : BITCODE_H;
        end;
      Dwg_COMPOUNDOBJECTID = _dwg_COMPOUNDOBJECTID;
      //PDwg_COMPOUNDOBJECTID = ^Dwg_COMPOUNDOBJECTID;

      //P_dwg_PARTIAL_VIEWING_INDEX_Entry = ^_dwg_PARTIAL_VIEWING_INDEX_Entry;
      _dwg_PARTIAL_VIEWING_INDEX_Entry = record
          parent : P_dwg_object_PARTIAL_VIEWING_INDEX;
          extents_min : BITCODE_3BD;
          extents_max : BITCODE_3BD;
          &object : BITCODE_H;
        end;
      Dwg_PARTIAL_VIEWING_INDEX_Entry = _dwg_PARTIAL_VIEWING_INDEX_Entry;
      //PDwg_PARTIAL_VIEWING_INDEX_Entry = ^Dwg_PARTIAL_VIEWING_INDEX_Entry;

      //P_dwg_object_PARTIAL_VIEWING_INDEX = ^_dwg_object_PARTIAL_VIEWING_INDEX;
      _dwg_object_PARTIAL_VIEWING_INDEX = record
          parent : P_dwg_object_object;
          num_entries : BITCODE_BL;
          has_entries : BITCODE_B;
          entries : PDwg_PARTIAL_VIEWING_INDEX_Entry;
        end;
      Dwg_Object_PARTIAL_VIEWING_INDEX = _dwg_object_PARTIAL_VIEWING_INDEX;
      //PDwg_Object_PARTIAL_VIEWING_INDEX = ^Dwg_Object_PARTIAL_VIEWING_INDEX;

      //P_dwg_entity_UNKNOWN_ENT = ^_dwg_entity_UNKNOWN_ENT;
      _dwg_entity_UNKNOWN_ENT = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_UNKNOWN_ENT = _dwg_entity_UNKNOWN_ENT;
      //PDwg_Entity_UNKNOWN_ENT = ^Dwg_Entity_UNKNOWN_ENT;

      //P_dwg_object_UNKNOWN_OBJ = ^_dwg_object_UNKNOWN_OBJ;
      _dwg_object_UNKNOWN_OBJ = record
          parent : P_dwg_object_object;
        end;
      Dwg_Object_UNKNOWN_OBJ = _dwg_object_UNKNOWN_OBJ;
      //PDwg_Object_UNKNOWN_OBJ = ^Dwg_Object_UNKNOWN_OBJ;

      //P_dwg_entity_REPEAT = ^_dwg_entity_REPEAT;
      _dwg_entity_REPEAT = record
          parent : P_dwg_object_entity;
        end;
      Dwg_Entity_REPEAT = _dwg_entity_REPEAT;
      //PDwg_Entity_REPEAT = ^Dwg_Entity_REPEAT;

      //P_dwg_entity_ENDREP = ^_dwg_entity_ENDREP;
      _dwg_entity_ENDREP = record
          parent : P_dwg_object_entity;
          num_cols : BITCODE_RS;
          num_rows : BITCODE_RS;
          col_spacing : BITCODE_RD;
          row_spacing : BITCODE_RD;
        end;
      Dwg_Entity_ENDREP = _dwg_entity_ENDREP;
      //PDwg_Entity_ENDREP = ^Dwg_Entity_ENDREP;

      //P_dwg_entity_LOAD = ^_dwg_entity_LOAD;
      _dwg_entity_LOAD = record
          parent : P_dwg_object_entity;
          file_name : BITCODE_TV;
        end;
      Dwg_Entity_LOAD = _dwg_entity_LOAD;
      //PDwg_Entity_LOAD = ^Dwg_Entity_LOAD;

      //P_dwg_entity_3DLINE = ^_dwg_entity_3DLINE;
      _dwg_entity_3DLINE = record
          parent : P_dwg_object_entity;
          start : BITCODE_3RD;
          &nd : BITCODE_3RD;
          extrusion : BITCODE_3RD;
          thickness : BITCODE_RD;
        end;
      Dwg_Entity__3DLINE = _dwg_entity_3DLINE;
      //PDwg_Entity__3DLINE = ^Dwg_Entity__3DLINE;
(** unsupported pragma#pragma pack(1)*)


      //P_dwg_entity_eed_data = ^_dwg_entity_eed_data;
      _dwg_entity_eed_data = record
          code : BITCODE_RC;
          u : record
              case longint of
                0 : ( eed_0 : record
                    length : BITCODE_RS;
                    flag0 : word;
                    _string : array[0..0] of char;
                  end );
                1 : ( eed_0_r2007 : record
                    length : BITCODE_RS;
                    flag0 : word;
                    _string : array[0..0] of dwg_wchar_t;
                  end );
                2 : ( eed_1 : record
                    invalid : array[0..0] of char;
                  end );
                3 : ( eed_2 : record
                    close : BITCODE_RC;
                  end );
                4 : ( eed_3 : record
                    layer : BITCODE_RLL;
                  end );
                5 : ( eed_4 : record
                    length : BITCODE_RC;
                    data : array[0..0] of byte;
                  end );
                6 : ( eed_5 : record
                    entity : dword;
                  end );
                7 : ( eed_10 : record
                    point : BITCODE_3RD;
                  end );
                8 : ( eed_40 : record
                    real : BITCODE_RD;
                  end );
                9 : ( eed_70 : record
                    rs : BITCODE_RS;
                  end );
                10 : ( eed_71 : record
                    rl : BITCODE_RL;
                  end );
              end;
        end;
      Dwg_Eed_Data = _dwg_entity_eed_data;
      //PDwg_Eed_Data = ^Dwg_Eed_Data;

(** unsupported pragma#pragma pack()*)


      //P_dwg_entity_eed = ^_dwg_entity_eed;
      _dwg_entity_eed = record
          size : BITCODE_BS;
          handle : Dwg_Handle;
          data : PDwg_Eed_Data;
          raw : BITCODE_TF;
        end;
      Dwg_Eed = _dwg_entity_eed;
      //PDwg_Eed = ^Dwg_Eed;
(* error 
enum {
in declaration at line 7377 *)
(* error 
enum {
in declaration at line 7388 *)
(* error 
enum {
in declaration at line 7399 *)

      //P_dwg_object_entity = ^_dwg_object_entity;
      _dwg_object_entity = record
          objid : BITCODE_BL;
          tio : record
              case longint of
                0 : ( UNUSED : PDwg_Entity_UNUSED );
                1 : ( DIMENSION_common : PDwg_DIMENSION_common );
                2 : ( _3DFACE : PDwg_Entity__3DFACE );
                3 : ( _3DSOLID : PDwg_Entity__3DSOLID );
                4 : ( ARC : PDwg_Entity_ARC );
                5 : ( ATTDEF : PDwg_Entity_ATTDEF );
                6 : ( ATTRIB : PDwg_Entity_ATTRIB );
                7 : ( BLOCK : PDwg_Entity_BLOCK );
                8 : ( BODY : PDwg_Entity_BODY );
                9 : ( CIRCLE : PDwg_Entity_CIRCLE );
                10 : ( DIMENSION_ALIGNED : PDwg_Entity_DIMENSION_ALIGNED );
                11 : ( DIMENSION_ANG2LN : PDwg_Entity_DIMENSION_ANG2LN );
                12 : ( DIMENSION_ANG3PT : PDwg_Entity_DIMENSION_ANG3PT );
                13 : ( DIMENSION_DIAMETER : PDwg_Entity_DIMENSION_DIAMETER );
                14 : ( DIMENSION_LINEAR : PDwg_Entity_DIMENSION_LINEAR );
                15 : ( DIMENSION_ORDINATE : PDwg_Entity_DIMENSION_ORDINATE );
                16 : ( DIMENSION_RADIUS : PDwg_Entity_DIMENSION_RADIUS );
                17 : ( ELLIPSE : PDwg_Entity_ELLIPSE );
                18 : ( ENDBLK : PDwg_Entity_ENDBLK );
                19 : ( INSERT : PDwg_Entity_INSERT );
                20 : ( LEADER : PDwg_Entity_LEADER );
                21 : ( LINE : PDwg_Entity_LINE );
                22 : ( LOAD : PDwg_Entity_LOAD );
                23 : ( MINSERT : PDwg_Entity_MINSERT );
                24 : ( MLINE : PDwg_Entity_MLINE );
                25 : ( MTEXT : PDwg_Entity_MTEXT );
                26 : ( OLEFRAME : PDwg_Entity_OLEFRAME );
                27 : ( POINT : PDwg_Entity_POINT );
                28 : ( POLYLINE_2D : PDwg_Entity_POLYLINE_2D );
                29 : ( POLYLINE_3D : PDwg_Entity_POLYLINE_3D );
                30 : ( POLYLINE_MESH : PDwg_Entity_POLYLINE_MESH );
                31 : ( POLYLINE_PFACE : PDwg_Entity_POLYLINE_PFACE );
                32 : ( PROXY_ENTITY : PDwg_Entity_PROXY_ENTITY );
                33 : ( RAY : PDwg_Entity_RAY );
                34 : ( REGION : PDwg_Entity_REGION );
                35 : ( SEQEND : PDwg_Entity_SEQEND );
                36 : ( SHAPE : PDwg_Entity_SHAPE );
                37 : ( SOLID : PDwg_Entity_SOLID );
                38 : ( SPLINE : PDwg_Entity_SPLINE );
                39 : ( TEXT : PDwg_Entity_TEXT );
                40 : ( TOLERANCE : PDwg_Entity_TOLERANCE );
                41 : ( TRACE : PDwg_Entity_TRACE );
                42 : ( UNKNOWN_ENT : PDwg_Entity_UNKNOWN_ENT );
                43 : ( VERTEX_2D : PDwg_Entity_VERTEX_2D );
                44 : ( VERTEX_3D : PDwg_Entity_VERTEX_3D );
                45 : ( VERTEX_MESH : PDwg_Entity_VERTEX_MESH );
                46 : ( VERTEX_PFACE : PDwg_Entity_VERTEX_PFACE );
                47 : ( VERTEX_PFACE_FACE : PDwg_Entity_VERTEX_PFACE_FACE );
                48 : ( VIEWPORT : PDwg_Entity_VIEWPORT );
                49 : ( XLINE : PDwg_Entity_XLINE );
                50 : ( CAMERA : PDwg_Entity_CAMERA );
                51 : ( DGNUNDERLAY : PDwg_Entity_DGNUNDERLAY );
                52 : ( DWFUNDERLAY : PDwg_Entity_DWFUNDERLAY );
                53 : ( HATCH : PDwg_Entity_HATCH );
                54 : ( IMAGE : PDwg_Entity_IMAGE );
                55 : ( LIGHT : PDwg_Entity_LIGHT );
                56 : ( LWPOLYLINE : PDwg_Entity_LWPOLYLINE );
                57 : ( MESH : PDwg_Entity_MESH );
                58 : ( MULTILEADER : PDwg_Entity_MULTILEADER );
                59 : ( OLE2FRAME : PDwg_Entity_OLE2FRAME );
                60 : ( PDFUNDERLAY : PDwg_Entity_PDFUNDERLAY );
                61 : ( SECTIONOBJECT : PDwg_Entity_SECTIONOBJECT );
                62 : ( _3DLINE : PDwg_Entity__3DLINE );
                63 : ( ARC_DIMENSION : PDwg_Entity_ARC_DIMENSION );
                64 : ( ENDREP : PDwg_Entity_ENDREP );
                65 : ( HELIX : PDwg_Entity_HELIX );
                66 : ( LARGE_RADIAL_DIMENSION : PDwg_Entity_LARGE_RADIAL_DIMENSION );
                67 : ( PLANESURFACE : PDwg_Entity_PLANESURFACE );
                68 : ( POINTCLOUD : PDwg_Entity_POINTCLOUD );
                69 : ( POINTCLOUDEX : PDwg_Entity_POINTCLOUDEX );
                70 : ( _REPEAT : PDwg_Entity_REPEAT );
                71 : ( WIPEOUT : PDwg_Entity_WIPEOUT );
                72 : ( ALIGNMENTPARAMETERENTITY : PDwg_Entity_ALIGNMENTPARAMETERENTITY );
                73 : ( ARCALIGNEDTEXT : PDwg_Entity_ARCALIGNEDTEXT );
                74 : ( BASEPOINTPARAMETERENTITY : PDwg_Entity_BASEPOINTPARAMETERENTITY );
                75 : ( EXTRUDEDSURFACE : PDwg_Entity_EXTRUDEDSURFACE );
                76 : ( FLIPGRIPENTITY : PDwg_Entity_FLIPGRIPENTITY );
                77 : ( FLIPPARAMETERENTITY : PDwg_Entity_FLIPPARAMETERENTITY );
                78 : ( GEOPOSITIONMARKER : PDwg_Entity_GEOPOSITIONMARKER );
                79 : ( LINEARGRIPENTITY : PDwg_Entity_LINEARGRIPENTITY );
                80 : ( LINEARPARAMETERENTITY : PDwg_Entity_LINEARPARAMETERENTITY );
                81 : ( LOFTEDSURFACE : PDwg_Entity_LOFTEDSURFACE );
                82 : ( MPOLYGON : PDwg_Entity_MPOLYGON );
                83 : ( NAVISWORKSMODEL : PDwg_Entity_NAVISWORKSMODEL );
                84 : ( NURBSURFACE : PDwg_Entity_NURBSURFACE );
                85 : ( POINTPARAMETERENTITY : PDwg_Entity_POINTPARAMETERENTITY );
                86 : ( POLARGRIPENTITY : PDwg_Entity_POLARGRIPENTITY );
                87 : ( REVOLVEDSURFACE : PDwg_Entity_REVOLVEDSURFACE );
                88 : ( ROTATIONGRIPENTITY : PDwg_Entity_ROTATIONGRIPENTITY );
                89 : ( ROTATIONPARAMETERENTITY : PDwg_Entity_ROTATIONPARAMETERENTITY );
                90 : ( RTEXT : PDwg_Entity_RTEXT );
                91 : ( SWEPTSURFACE : PDwg_Entity_SWEPTSURFACE );
                92 : ( TABLE : PDwg_Entity_TABLE );
                93 : ( VISIBILITYGRIPENTITY : PDwg_Entity_VISIBILITYGRIPENTITY );
                94 : ( VISIBILITYPARAMETERENTITY : PDwg_Entity_VISIBILITYPARAMETERENTITY );
                95 : ( XYGRIPENTITY : PDwg_Entity_XYGRIPENTITY );
                96 : ( XYPARAMETERENTITY : PDwg_Entity_XYPARAMETERENTITY );
              end;
          dwg : P_dwg_struct;
          num_eed : BITCODE_BL;
          eed : PDwg_Eed;
          preview_exists : BITCODE_B;
          preview_is_proxy : BITCODE_B;
          preview_size : BITCODE_BLL;
          preview : BITCODE_TF;
          entmode : BITCODE_BB;
          num_reactors : BITCODE_BL;
          is_xdic_missing : BITCODE_B;
          isbylayerlt : BITCODE_B;
          nolinks : BITCODE_B;
          has_ds_data : BITCODE_B;
          color : BITCODE_CMC;
          ltype_scale : BITCODE_BD;
          ltype_flags : BITCODE_BB;
          plotstyle_flags : BITCODE_BB;
          material_flags : BITCODE_BB;
          shadow_flags : BITCODE_RC;
          has_full_visualstyle : BITCODE_B;
          has_face_visualstyle : BITCODE_B;
          has_edge_visualstyle : BITCODE_B;
          invisible : BITCODE_BS;
          linewt : BITCODE_RC;
          flag_r11 : BITCODE_RC;
          opts_r11 : BITCODE_RS;
          extra_r11 : BITCODE_RC;
          color_r11 : BITCODE_RCd;
          elevation_r11 : BITCODE_RD;
          thickness_r11 : BITCODE_RD;
          viewport : BITCODE_H;
          __iterator : BITCODE_BL;
          ownerhandle : BITCODE_H;
          reactors : PBITCODE_H;
          xdicobjhandle : BITCODE_H;
          prev_entity : BITCODE_H;
          next_entity : BITCODE_H;
          layer : BITCODE_H;
          ltype : BITCODE_H;
          material : BITCODE_H;
          shadow : BITCODE_H;
          plotstyle : BITCODE_H;
          full_visualstyle : BITCODE_H;
          face_visualstyle : BITCODE_H;
          edge_visualstyle : BITCODE_H;
        end;
      Dwg_Object_Entity = _dwg_object_entity;
      //PDwg_Object_Entity = ^Dwg_Object_Entity;

      //P_dwg_object_object = ^_dwg_object_object;
      _dwg_object_object = record
          objid : BITCODE_BL;
          tio : record
              case longint of
                0 : ( APPID : PDwg_Object_APPID );
                1 : ( APPID_CONTROL : PDwg_Object_APPID_CONTROL );
                2 : ( BLOCK_CONTROL : PDwg_Object_BLOCK_CONTROL );
                3 : ( BLOCK_HEADER : PDwg_Object_BLOCK_HEADER );
                4 : ( DICTIONARY : PDwg_Object_DICTIONARY );
                5 : ( DIMSTYLE : PDwg_Object_DIMSTYLE );
                6 : ( DIMSTYLE_CONTROL : PDwg_Object_DIMSTYLE_CONTROL );
                7 : ( DUMMY : PDwg_Object_DUMMY );
                8 : ( LAYER : PDwg_Object_LAYER );
                9 : ( LAYER_CONTROL : PDwg_Object_LAYER_CONTROL );
                10 : ( LONG_TRANSACTION : PDwg_Object_LONG_TRANSACTION );
                11 : ( LTYPE : PDwg_Object_LTYPE );
                12 : ( LTYPE_CONTROL : PDwg_Object_LTYPE_CONTROL );
                13 : ( MLINESTYLE : PDwg_Object_MLINESTYLE );
                14 : ( STYLE : PDwg_Object_STYLE );
                15 : ( STYLE_CONTROL : PDwg_Object_STYLE_CONTROL );
                16 : ( UCS : PDwg_Object_UCS );
                17 : ( UCS_CONTROL : PDwg_Object_UCS_CONTROL );
                18 : ( UNKNOWN_OBJ : PDwg_Object_UNKNOWN_OBJ );
                19 : ( VIEW : PDwg_Object_VIEW );
                20 : ( VIEW_CONTROL : PDwg_Object_VIEW_CONTROL );
                21 : ( VPORT : PDwg_Object_VPORT );
                22 : ( VPORT_CONTROL : PDwg_Object_VPORT_CONTROL );
                23 : ( VX_CONTROL : PDwg_Object_VX_CONTROL );
                24 : ( VX_TABLE_RECORD : PDwg_Object_VX_TABLE_RECORD );
                25 : ( ACSH_BOOLEAN_CLASS : PDwg_Object_ACSH_BOOLEAN_CLASS );
                26 : ( ACSH_BOX_CLASS : PDwg_Object_ACSH_BOX_CLASS );
                27 : ( ACSH_CONE_CLASS : PDwg_Object_ACSH_CONE_CLASS );
                28 : ( ACSH_CYLINDER_CLASS : PDwg_Object_ACSH_CYLINDER_CLASS );
                29 : ( ACSH_FILLET_CLASS : PDwg_Object_ACSH_FILLET_CLASS );
                30 : ( ACSH_HISTORY_CLASS : PDwg_Object_ACSH_HISTORY_CLASS );
                31 : ( ACSH_SPHERE_CLASS : PDwg_Object_ACSH_SPHERE_CLASS );
                32 : ( ACSH_TORUS_CLASS : PDwg_Object_ACSH_TORUS_CLASS );
                33 : ( ACSH_WEDGE_CLASS : PDwg_Object_ACSH_WEDGE_CLASS );
                34 : ( BLOCKALIGNMENTGRIP : PDwg_Object_BLOCKALIGNMENTGRIP );
                35 : ( BLOCKALIGNMENTPARAMETER : PDwg_Object_BLOCKALIGNMENTPARAMETER );
                36 : ( BLOCKBASEPOINTPARAMETER : PDwg_Object_BLOCKBASEPOINTPARAMETER );
                37 : ( BLOCKFLIPACTION : PDwg_Object_BLOCKFLIPACTION );
                38 : ( BLOCKFLIPGRIP : PDwg_Object_BLOCKFLIPGRIP );
                39 : ( BLOCKFLIPPARAMETER : PDwg_Object_BLOCKFLIPPARAMETER );
                40 : ( BLOCKGRIPLOCATIONCOMPONENT : PDwg_Object_BLOCKGRIPLOCATIONCOMPONENT );
                41 : ( BLOCKLINEARGRIP : PDwg_Object_BLOCKLINEARGRIP );
                42 : ( BLOCKLOOKUPGRIP : PDwg_Object_BLOCKLOOKUPGRIP );
                43 : ( BLOCKMOVEACTION : PDwg_Object_BLOCKMOVEACTION );
                44 : ( BLOCKROTATEACTION : PDwg_Object_BLOCKROTATEACTION );
                45 : ( BLOCKROTATIONGRIP : PDwg_Object_BLOCKROTATIONGRIP );
                46 : ( BLOCKSCALEACTION : PDwg_Object_BLOCKSCALEACTION );
                47 : ( BLOCKVISIBILITYGRIP : PDwg_Object_BLOCKVISIBILITYGRIP );
                48 : ( CELLSTYLEMAP : PDwg_Object_CELLSTYLEMAP );
                49 : ( DETAILVIEWSTYLE : PDwg_Object_DETAILVIEWSTYLE );
                50 : ( DICTIONARYVAR : PDwg_Object_DICTIONARYVAR );
                51 : ( DICTIONARYWDFLT : PDwg_Object_DICTIONARYWDFLT );
                52 : ( DYNAMICBLOCKPURGEPREVENTER : PDwg_Object_DYNAMICBLOCKPURGEPREVENTER );
                53 : ( FIELD : PDwg_Object_FIELD );
                54 : ( FIELDLIST : PDwg_Object_FIELDLIST );
                55 : ( GEODATA : PDwg_Object_GEODATA );
                56 : ( GROUP : PDwg_Object_GROUP );
                57 : ( IDBUFFER : PDwg_Object_IDBUFFER );
                58 : ( IMAGEDEF : PDwg_Object_IMAGEDEF );
                59 : ( IMAGEDEF_REACTOR : PDwg_Object_IMAGEDEF_REACTOR );
                60 : ( INDEX : PDwg_Object_INDEX );
                61 : ( LAYERFILTER : PDwg_Object_LAYERFILTER );
                62 : ( LAYER_INDEX : PDwg_Object_LAYER_INDEX );
                63 : ( LAYOUT : PDwg_Object_LAYOUT );
                64 : ( MLEADERSTYLE : PDwg_Object_MLEADERSTYLE );
                65 : ( PLACEHOLDER : PDwg_Object_PLACEHOLDER );
                66 : ( PLOTSETTINGS : PDwg_Object_PLOTSETTINGS );
                67 : ( RASTERVARIABLES : PDwg_Object_RASTERVARIABLES );
                68 : ( SCALE : PDwg_Object_SCALE );
                69 : ( SECTIONVIEWSTYLE : PDwg_Object_SECTIONVIEWSTYLE );
                70 : ( SECTION_MANAGER : PDwg_Object_SECTION_MANAGER );
                71 : ( SORTENTSTABLE : PDwg_Object_SORTENTSTABLE );
                72 : ( SPATIAL_FILTER : PDwg_Object_SPATIAL_FILTER );
                73 : ( TABLEGEOMETRY : PDwg_Object_TABLEGEOMETRY );
                74 : ( VBA_PROJECT : PDwg_Object_VBA_PROJECT );
                75 : ( VISUALSTYLE : PDwg_Object_VISUALSTYLE );
                76 : ( WIPEOUTVARIABLES : PDwg_Object_WIPEOUTVARIABLES );
                77 : ( XRECORD : PDwg_Object_XRECORD );
                78 : ( PDFDEFINITION : PDwg_Object_PDFDEFINITION );
                79 : ( DGNDEFINITION : PDwg_Object_DGNDEFINITION );
                80 : ( DWFDEFINITION : PDwg_Object_DWFDEFINITION );
                81 : ( ACSH_BREP_CLASS : PDwg_Object_ACSH_BREP_CLASS );
                82 : ( ACSH_CHAMFER_CLASS : PDwg_Object_ACSH_CHAMFER_CLASS );
                83 : ( ACSH_PYRAMID_CLASS : PDwg_Object_ACSH_PYRAMID_CLASS );
                84 : ( ALDIMOBJECTCONTEXTDATA : PDwg_Object_ALDIMOBJECTCONTEXTDATA );
                85 : ( ASSOC2DCONSTRAINTGROUP : PDwg_Object_ASSOC2DCONSTRAINTGROUP );
                86 : ( ASSOCACTION : PDwg_Object_ASSOCACTION );
                87 : ( ASSOCACTIONPARAM : PDwg_Object_ASSOCACTIONPARAM );
                88 : ( ASSOCARRAYACTIONBODY : PDwg_Object_ASSOCARRAYACTIONBODY );
                89 : ( ASSOCASMBODYACTIONPARAM : PDwg_Object_ASSOCASMBODYACTIONPARAM );
                90 : ( ASSOCBLENDSURFACEACTIONBODY : PDwg_Object_ASSOCBLENDSURFACEACTIONBODY );
                91 : ( ASSOCCOMPOUNDACTIONPARAM : PDwg_Object_ASSOCCOMPOUNDACTIONPARAM );
                92 : ( ASSOCDEPENDENCY : PDwg_Object_ASSOCDEPENDENCY );
                93 : ( ASSOCDIMDEPENDENCYBODY : PDwg_Object_ASSOCDIMDEPENDENCYBODY );
                94 : ( ASSOCEXTENDSURFACEACTIONBODY : PDwg_Object_ASSOCEXTENDSURFACEACTIONBODY );
                95 : ( ASSOCEXTRUDEDSURFACEACTIONBODY : PDwg_Object_ASSOCEXTRUDEDSURFACEACTIONBODY );
                96 : ( ASSOCFACEACTIONPARAM : PDwg_Object_ASSOCFACEACTIONPARAM );
                97 : ( ASSOCFILLETSURFACEACTIONBODY : PDwg_Object_ASSOCFILLETSURFACEACTIONBODY );
                98 : ( ASSOCGEOMDEPENDENCY : PDwg_Object_ASSOCGEOMDEPENDENCY );
                99 : ( ASSOCLOFTEDSURFACEACTIONBODY : PDwg_Object_ASSOCLOFTEDSURFACEACTIONBODY );
                100 : ( ASSOCNETWORK : PDwg_Object_ASSOCNETWORK );
                101 : ( ASSOCNETWORKSURFACEACTIONBODY : PDwg_Object_ASSOCNETWORKSURFACEACTIONBODY );
                102 : ( ASSOCOBJECTACTIONPARAM : PDwg_Object_ASSOCOBJECTACTIONPARAM );
                103 : ( ASSOCOFFSETSURFACEACTIONBODY : PDwg_Object_ASSOCOFFSETSURFACEACTIONBODY );
                104 : ( ASSOCOSNAPPOINTREFACTIONPARAM : PDwg_Object_ASSOCOSNAPPOINTREFACTIONPARAM );
                105 : ( ASSOCPATCHSURFACEACTIONBODY : PDwg_Object_ASSOCPATCHSURFACEACTIONBODY );
                106 : ( ASSOCPATHACTIONPARAM : PDwg_Object_ASSOCPATHACTIONPARAM );
                107 : ( ASSOCPLANESURFACEACTIONBODY : PDwg_Object_ASSOCPLANESURFACEACTIONBODY );
                108 : ( ASSOCPOINTREFACTIONPARAM : PDwg_Object_ASSOCPOINTREFACTIONPARAM );
                109 : ( ASSOCREVOLVEDSURFACEACTIONBODY : PDwg_Object_ASSOCREVOLVEDSURFACEACTIONBODY );
                110 : ( ASSOCTRIMSURFACEACTIONBODY : PDwg_Object_ASSOCTRIMSURFACEACTIONBODY );
                111 : ( ASSOCVALUEDEPENDENCY : PDwg_Object_ASSOCVALUEDEPENDENCY );
                112 : ( ASSOCVARIABLE : PDwg_Object_ASSOCVARIABLE );
                113 : ( ASSOCVERTEXACTIONPARAM : PDwg_Object_ASSOCVERTEXACTIONPARAM );
                114 : ( BLKREFOBJECTCONTEXTDATA : PDwg_Object_BLKREFOBJECTCONTEXTDATA );
                115 : ( BLOCKALIGNEDCONSTRAINTPARAMETER : PDwg_Object_BLOCKALIGNEDCONSTRAINTPARAMETER );
                116 : ( BLOCKANGULARCONSTRAINTPARAMETER : PDwg_Object_BLOCKANGULARCONSTRAINTPARAMETER );
                117 : ( BLOCKARRAYACTION : PDwg_Object_BLOCKARRAYACTION );
                118 : ( BLOCKDIAMETRICCONSTRAINTPARAMETER : PDwg_Object_BLOCKDIAMETRICCONSTRAINTPARAMETER );
                119 : ( BLOCKHORIZONTALCONSTRAINTPARAMETER : PDwg_Object_BLOCKHORIZONTALCONSTRAINTPARAMETER );
                120 : ( BLOCKLINEARCONSTRAINTPARAMETER : PDwg_Object_BLOCKLINEARCONSTRAINTPARAMETER );
                121 : ( BLOCKLINEARPARAMETER : PDwg_Object_BLOCKLINEARPARAMETER );
                122 : ( BLOCKLOOKUPACTION : PDwg_Object_BLOCKLOOKUPACTION );
                123 : ( BLOCKLOOKUPPARAMETER : PDwg_Object_BLOCKLOOKUPPARAMETER );
                124 : ( BLOCKPARAMDEPENDENCYBODY : PDwg_Object_BLOCKPARAMDEPENDENCYBODY );
                125 : ( BLOCKPOINTPARAMETER : PDwg_Object_BLOCKPOINTPARAMETER );
                126 : ( BLOCKPOLARGRIP : PDwg_Object_BLOCKPOLARGRIP );
                127 : ( BLOCKPOLARPARAMETER : PDwg_Object_BLOCKPOLARPARAMETER );
                128 : ( BLOCKPOLARSTRETCHACTION : PDwg_Object_BLOCKPOLARSTRETCHACTION );
                129 : ( BLOCKRADIALCONSTRAINTPARAMETER : PDwg_Object_BLOCKRADIALCONSTRAINTPARAMETER );
                130 : ( BLOCKREPRESENTATION : PDwg_Object_BLOCKREPRESENTATION );
                131 : ( BLOCKROTATIONPARAMETER : PDwg_Object_BLOCKROTATIONPARAMETER );
                132 : ( BLOCKSTRETCHACTION : PDwg_Object_BLOCKSTRETCHACTION );
                133 : ( BLOCKUSERPARAMETER : PDwg_Object_BLOCKUSERPARAMETER );
                134 : ( BLOCKVERTICALCONSTRAINTPARAMETER : PDwg_Object_BLOCKVERTICALCONSTRAINTPARAMETER );
                135 : ( BLOCKVISIBILITYPARAMETER : PDwg_Object_BLOCKVISIBILITYPARAMETER );
                136 : ( BLOCKXYGRIP : PDwg_Object_BLOCKXYGRIP );
                137 : ( BLOCKXYPARAMETER : PDwg_Object_BLOCKXYPARAMETER );
                138 : ( DATALINK : PDwg_Object_DATALINK );
                139 : ( DBCOLOR : PDwg_Object_DBCOLOR );
                140 : ( EVALUATION_GRAPH : PDwg_Object_EVALUATION_GRAPH );
                141 : ( FCFOBJECTCONTEXTDATA : PDwg_Object_FCFOBJECTCONTEXTDATA );
                142 : ( GRADIENT_BACKGROUND : PDwg_Object_GRADIENT_BACKGROUND );
                143 : ( GROUND_PLANE_BACKGROUND : PDwg_Object_GROUND_PLANE_BACKGROUND );
                144 : ( IBL_BACKGROUND : PDwg_Object_IBL_BACKGROUND );
                145 : ( IMAGE_BACKGROUND : PDwg_Object_IMAGE_BACKGROUND );
                146 : ( LEADEROBJECTCONTEXTDATA : PDwg_Object_LEADEROBJECTCONTEXTDATA );
                147 : ( LIGHTLIST : PDwg_Object_LIGHTLIST );
                148 : ( MATERIAL : PDwg_Object_MATERIAL );
                149 : ( MENTALRAYRENDERSETTINGS : PDwg_Object_MENTALRAYRENDERSETTINGS );
                150 : ( MTEXTOBJECTCONTEXTDATA : PDwg_Object_MTEXTOBJECTCONTEXTDATA );
                151 : ( OBJECT_PTR : PDwg_Object_OBJECT_PTR );
                152 : ( PARTIAL_VIEWING_INDEX : PDwg_Object_PARTIAL_VIEWING_INDEX );
                153 : ( POINTCLOUDCOLORMAP : PDwg_Object_POINTCLOUDCOLORMAP );
                154 : ( POINTCLOUDDEF : PDwg_Object_POINTCLOUDDEF );
                155 : ( POINTCLOUDDEFEX : PDwg_Object_POINTCLOUDDEFEX );
                156 : ( POINTCLOUDDEF_REACTOR : PDwg_Object_POINTCLOUDDEF_REACTOR );
                157 : ( POINTCLOUDDEF_REACTOR_EX : PDwg_Object_POINTCLOUDDEF_REACTOR_EX );
                158 : ( PROXY_OBJECT : PDwg_Object_PROXY_OBJECT );
                159 : ( RAPIDRTRENDERSETTINGS : PDwg_Object_RAPIDRTRENDERSETTINGS );
                160 : ( RENDERENTRY : PDwg_Object_RENDERENTRY );
                161 : ( RENDERENVIRONMENT : PDwg_Object_RENDERENVIRONMENT );
                162 : ( RENDERGLOBAL : PDwg_Object_RENDERGLOBAL );
                163 : ( RENDERSETTINGS : PDwg_Object_RENDERSETTINGS );
                164 : ( SECTION_SETTINGS : PDwg_Object_SECTION_SETTINGS );
                165 : ( SKYLIGHT_BACKGROUND : PDwg_Object_SKYLIGHT_BACKGROUND );
                166 : ( SOLID_BACKGROUND : PDwg_Object_SOLID_BACKGROUND );
                167 : ( SPATIAL_INDEX : PDwg_Object_SPATIAL_INDEX );
                168 : ( SUN : PDwg_Object_SUN );
                169 : ( TABLESTYLE : PDwg_Object_TABLESTYLE );
                170 : ( TEXTOBJECTCONTEXTDATA : PDwg_Object_TEXTOBJECTCONTEXTDATA );
                171 : ( ASSOCARRAYMODIFYPARAMETERS : PDwg_Object_ASSOCARRAYMODIFYPARAMETERS );
                172 : ( ASSOCARRAYPATHPARAMETERS : PDwg_Object_ASSOCARRAYPATHPARAMETERS );
                173 : ( ASSOCARRAYPOLARPARAMETERS : PDwg_Object_ASSOCARRAYPOLARPARAMETERS );
                174 : ( ASSOCARRAYRECTANGULARPARAMETERS : PDwg_Object_ASSOCARRAYRECTANGULARPARAMETERS );
                175 : ( ACMECOMMANDHISTORY : PDwg_Object_ACMECOMMANDHISTORY );
                176 : ( ACMESCOPE : PDwg_Object_ACMESCOPE );
                177 : ( ACMESTATEMGR : PDwg_Object_ACMESTATEMGR );
                178 : ( ACSH_EXTRUSION_CLASS : PDwg_Object_ACSH_EXTRUSION_CLASS );
                179 : ( ACSH_LOFT_CLASS : PDwg_Object_ACSH_LOFT_CLASS );
                180 : ( ACSH_REVOLVE_CLASS : PDwg_Object_ACSH_REVOLVE_CLASS );
                181 : ( ACSH_SWEEP_CLASS : PDwg_Object_ACSH_SWEEP_CLASS );
                182 : ( ANGDIMOBJECTCONTEXTDATA : PDwg_Object_ANGDIMOBJECTCONTEXTDATA );
                183 : ( ANNOTSCALEOBJECTCONTEXTDATA : PDwg_Object_ANNOTSCALEOBJECTCONTEXTDATA );
                184 : ( ASSOC3POINTANGULARDIMACTIONBODY : PDwg_Object_ASSOC3POINTANGULARDIMACTIONBODY );
                185 : ( ASSOCALIGNEDDIMACTIONBODY : PDwg_Object_ASSOCALIGNEDDIMACTIONBODY );
                186 : ( ASSOCARRAYMODIFYACTIONBODY : PDwg_Object_ASSOCARRAYMODIFYACTIONBODY );
                187 : ( ASSOCEDGEACTIONPARAM : PDwg_Object_ASSOCEDGEACTIONPARAM );
                188 : ( ASSOCEDGECHAMFERACTIONBODY : PDwg_Object_ASSOCEDGECHAMFERACTIONBODY );
                189 : ( ASSOCEDGEFILLETACTIONBODY : PDwg_Object_ASSOCEDGEFILLETACTIONBODY );
                190 : ( ASSOCMLEADERACTIONBODY : PDwg_Object_ASSOCMLEADERACTIONBODY );
                191 : ( ASSOCORDINATEDIMACTIONBODY : PDwg_Object_ASSOCORDINATEDIMACTIONBODY );
                192 : ( ASSOCPERSSUBENTMANAGER : PDwg_Object_ASSOCPERSSUBENTMANAGER );
                193 : ( ASSOCRESTOREENTITYSTATEACTIONBODY : PDwg_Object_ASSOCRESTOREENTITYSTATEACTIONBODY );
                194 : ( ASSOCROTATEDDIMACTIONBODY : PDwg_Object_ASSOCROTATEDDIMACTIONBODY );
                195 : ( ASSOCSWEPTSURFACEACTIONBODY : PDwg_Object_ASSOCSWEPTSURFACEACTIONBODY );
                196 : ( BLOCKPROPERTIESTABLE : PDwg_Object_BLOCKPROPERTIESTABLE );
                197 : ( BLOCKPROPERTIESTABLEGRIP : PDwg_Object_BLOCKPROPERTIESTABLEGRIP );
                198 : ( BREAKDATA : PDwg_Object_BREAKDATA );
                199 : ( BREAKPOINTREF : PDwg_Object_BREAKPOINTREF );
                200 : ( CONTEXTDATAMANAGER : PDwg_Object_CONTEXTDATAMANAGER );
                201 : ( CSACDOCUMENTOPTIONS : PDwg_Object_CSACDOCUMENTOPTIONS );
                202 : ( CURVEPATH : PDwg_Object_CURVEPATH );
                203 : ( DATATABLE : PDwg_Object_DATATABLE );
                204 : ( DIMASSOC : PDwg_Object_DIMASSOC );
                205 : ( DMDIMOBJECTCONTEXTDATA : PDwg_Object_DMDIMOBJECTCONTEXTDATA );
                206 : ( DYNAMICBLOCKPROXYNODE : PDwg_Object_DYNAMICBLOCKPROXYNODE );
                207 : ( GEOMAPIMAGE : PDwg_Object_GEOMAPIMAGE );
                208 : ( LAYOUTPRINTCONFIG : PDwg_Object_LAYOUTPRINTCONFIG );
                209 : ( MLEADEROBJECTCONTEXTDATA : PDwg_Object_MLEADEROBJECTCONTEXTDATA );
                210 : ( MOTIONPATH : PDwg_Object_MOTIONPATH );
                211 : ( MTEXTATTRIBUTEOBJECTCONTEXTDATA : PDwg_Object_MTEXTATTRIBUTEOBJECTCONTEXTDATA );
                212 : ( NAVISWORKSMODELDEF : PDwg_Object_NAVISWORKSMODELDEF );
                213 : ( ORDDIMOBJECTCONTEXTDATA : PDwg_Object_ORDDIMOBJECTCONTEXTDATA );
                214 : ( PERSUBENTMGR : PDwg_Object_PERSUBENTMGR );
                215 : ( POINTPATH : PDwg_Object_POINTPATH );
                216 : ( RADIMLGOBJECTCONTEXTDATA : PDwg_Object_RADIMLGOBJECTCONTEXTDATA );
                217 : ( RADIMOBJECTCONTEXTDATA : PDwg_Object_RADIMOBJECTCONTEXTDATA );
                218 : ( SUNSTUDY : PDwg_Object_SUNSTUDY );
                219 : ( TABLECONTENT : PDwg_Object_TABLECONTENT );
                220 : ( TVDEVICEPROPERTIES : PDwg_Object_TVDEVICEPROPERTIES );
              end;
          dwg : P_dwg_struct;
          num_eed : BITCODE_BL;
          eed : PDwg_Eed;
          ownerhandle : BITCODE_H;
          num_reactors : BITCODE_BL;
          reactors : PBITCODE_H;
          xdicobjhandle : BITCODE_H;
          is_xdic_missing : BITCODE_B;
          has_ds_data : BITCODE_B;
          handleref : PDwg_Handle;
        end;
      Dwg_Object_Object = _dwg_object_object;
      //PDwg_Object_Object = ^Dwg_Object_Object;

      //P_dwg_class = ^_dwg_class;
      _dwg_class = record
          number : BITCODE_BS;
          proxyflag : BITCODE_BS;
          appname : Pchar;
          cppname : Pchar;
          dxfname : Pchar;
          dxfname_u : BITCODE_TU;
          is_zombie : BITCODE_B;
          item_class_id : BITCODE_BS;
          num_instances : BITCODE_BL;
          dwg_version : BITCODE_BL;
          maint_version : BITCODE_BL;
          unknown_1 : BITCODE_BL;
          unknown_2 : BITCODE_BL;
        end;
      Dwg_Class = _dwg_class;
      //PDwg_Class = ^Dwg_Class;

      //P_dwg_object = ^_dwg_object;
      _dwg_object = record
          size : BITCODE_RL;
          address : PtrUInt;
          _type : BITCODE_BS;
          index : BITCODE_RL;
          fixedtype : DWG_OBJECT_TYPE;
          name : Pchar;
          dxfname : Pchar;
          supertype : DWG_OBJECT_SUPERTYPE;
          tio : record
              case longint of
                0 : ( entity : PDwg_Object_Entity );
                1 : ( &object : PDwg_Object_Object );
              end;
          handle : Dwg_Handle;
          parent : P_dwg_struct;
          klass : PDwg_Class;
          bitsize : BITCODE_RL;
          bitsize_pos : PtrUInt;
          hdlpos : PtrUInt;
          was_bitsize_set : BITCODE_B;
          has_strings : BITCODE_B;
          stringstream_size : BITCODE_RL;
          handlestream_size : BITCODE_UMC;
          common_size : PtrUInt;
          num_unknown_bits : BITCODE_RL;
          unknown_bits : BITCODE_TF;
          num_unknown_rest : BITCODE_RL;
          unknown_rest : BITCODE_TF;
        end;
      Dwg_Object = _dwg_object;
      //PDwg_Object = ^Dwg_Object;
(* error 
  long unsigned int size;
 in member_list *)

      //P_dwg_chain = ^_dwg_chain;
      _dwg_chain = record
              {NOT:
               opts : byte;
               version : Dwg_Version_Type;
               from_version : Dwg_Version_Type;
               fh : pointer;}
               chain : Pointer;//unsigned char *chain;
               size : LongWord;//long unsigned int size;
               byte : LongWord;//long unsigned int byte;
               bit : byte;//unsigned char bit;
        end;
      Dwg_Chain = _dwg_chain;
      //PDwg_Chain = ^Dwg_Chain;

      //PDWG_SECTION_TYPE = ^DWG_SECTION_TYPE;
      DWG_SECTION_TYPE = (SECTION_UNKNOWN = 0,SECTION_HEADER = 1,
        SECTION_AUXHEADER = 2,SECTION_CLASSES = 3,
        SECTION_HANDLES = 4,SECTION_TEMPLATE = 5,
        SECTION_OBJFREESPACE = 6,SECTION_OBJECTS = 7,
        SECTION_REVHISTORY = 8,SECTION_SUMMARYINFO = 9,
        SECTION_PREVIEW = 10,SECTION_APPINFO = 11,
        SECTION_APPINFOHISTORY = 12,SECTION_FILEDEPLIST = 13,
        SECTION_SECURITY,SECTION_VBAPROJECT,
        SECTION_SIGNATURE,SECTION_ACDS,SECTION_INFO,
        SECTION_SYSTEM_MAP);

      //PDWG_SECTION_TYPE_R13 = ^DWG_SECTION_TYPE_R13;
      DWG_SECTION_TYPE_R13 = (SECTION_HEADER_R13 = 0,SECTION_CLASSES_R13 = 1,
        SECTION_HANDLES_R13 = 2,SECTION_2NDHEADER_R13 = 3,
        SECTION_MEASUREMENT_R13 = 4,SECTION_AUXHEADER_R2000 = 5
        );

      //PDWG_SECTION_TYPE_R11 = ^DWG_SECTION_TYPE_R11;
      DWG_SECTION_TYPE_R11 = (SECTION_HEADER_R11 = 0,SECTION_BLOCK = 1,
        SECTION_LAYER = 2,SECTION_STYLE = 3,
        SECTION_LTYPE = 5,SECTION_VIEW = 6,
        SECTION_UCS = 7,SECTION_VPORT = 8,
        SECTION_APPID = 9,SECTION_DIMSTYLE = 10,
        SECTION_VX = 11);

      //P_dwg_section = ^_dwg_section;
      _dwg_section = record
          number : int32;
          size : BITCODE_RL;
          address : uint64;
          objid_r11 : BITCODE_RL;
          parent : BITCODE_RL;
          left : BITCODE_RL;
          right : BITCODE_RL;
          x00 : BITCODE_RL;
          _type : Dwg_Section_Type;
          name : array[0..63] of char;
          section_type : BITCODE_RL;
          decomp_data_size : BITCODE_RL;
          comp_data_size : BITCODE_RL;
          compression_type : BITCODE_RL;
          checksum : BITCODE_RL;
          flags : BITCODE_RS;
        end;
      Dwg_Section = _dwg_section;
      //PDwg_Section = ^Dwg_Section;

      //PDwg_Section_InfoHdr = ^Dwg_Section_InfoHdr;
      Dwg_Section_InfoHdr = record
          num_desc : BITCODE_RL;
          compressed : BITCODE_RL;
          max_size : BITCODE_RL;
          encrypted : BITCODE_RL;
          num_desc2 : BITCODE_RL;
        end;

      //PDwg_Section_Info = ^Dwg_Section_Info;
      Dwg_Section_Info = record
          size : int64;
          num_sections : BITCODE_RL;
          max_decomp_size : BITCODE_RL;
          unknown : BITCODE_RL;
          compressed : BITCODE_RL;
          _type : BITCODE_RL;
          encrypted : BITCODE_RL;
          name : array[0..63] of char;
          fixedtype : Dwg_Section_Type;
          sections : ^PDwg_Section;
        end;

      //P_dwg_SummaryInfo_Property = ^_dwg_SummaryInfo_Property;
      _dwg_SummaryInfo_Property = record
          tag : BITCODE_TU;
          value : BITCODE_TU;
        end;
      Dwg_SummaryInfo_Property = _dwg_SummaryInfo_Property;
      //PDwg_SummaryInfo_Property = ^Dwg_SummaryInfo_Property;

      //P_dwg_FileDepList_Files = ^_dwg_FileDepList_Files;
      _dwg_FileDepList_Files = record
          filename : BITCODE_TV;
          filepath : BITCODE_TV;
          fingerprint : BITCODE_TV;
          version : BITCODE_TV;
          feature_index : BITCODE_RL;
          timestamp : BITCODE_RL;
          filesize : BITCODE_RL;
          affects_graphics : BITCODE_RS;
          refcount : BITCODE_RL;
        end;
      Dwg_FileDepList_Files = _dwg_FileDepList_Files;
      //PDwg_FileDepList_Files = ^Dwg_FileDepList_Files;

      //P_dwg_AcDs_SegmentIndex = ^_dwg_AcDs_SegmentIndex;
      _dwg_AcDs_SegmentIndex = record
          offset : BITCODE_RLL;
          size : BITCODE_RL;
        end;
      Dwg_AcDs_SegmentIndex = _dwg_AcDs_SegmentIndex;
      //PDwg_AcDs_SegmentIndex = ^Dwg_AcDs_SegmentIndex;

      //P_dwg_AcDs_DataIndex_Entry = ^_dwg_AcDs_DataIndex_Entry;
      _dwg_AcDs_DataIndex_Entry = record
          segidx : BITCODE_RL;
          offset : BITCODE_RL;
          schidx : BITCODE_RL;
        end;
      Dwg_AcDs_DataIndex_Entry = _dwg_AcDs_DataIndex_Entry;
      //PDwg_AcDs_DataIndex_Entry = ^Dwg_AcDs_DataIndex_Entry;

      //P_dwg_AcDs_DataIndex = ^_dwg_AcDs_DataIndex;
      _dwg_AcDs_DataIndex = record
          num_entries : BITCODE_RL;
          di_unknown : BITCODE_RL;
          entries : PDwg_AcDs_DataIndex_Entry;
        end;
      Dwg_AcDs_DataIndex = _dwg_AcDs_DataIndex;
      //PDwg_AcDs_DataIndex = ^Dwg_AcDs_DataIndex;

      //P_dwg_AcDs_Data_RecordHdr = ^_dwg_AcDs_Data_RecordHdr;
      _dwg_AcDs_Data_RecordHdr = record
          entry_size : BITCODE_RL;
          unknown : BITCODE_RL;
          handle : BITCODE_RLL;
          offset : BITCODE_RL;
        end;
      Dwg_AcDs_Data_RecordHdr = _dwg_AcDs_Data_RecordHdr;
      //PDwg_AcDs_Data_RecordHdr = ^Dwg_AcDs_Data_RecordHdr;

      //P_dwg_AcDs_Data_Record = ^_dwg_AcDs_Data_Record;
      _dwg_AcDs_Data_Record = record
          data_size : BITCODE_RL;
          blob : PBITCODE_RC;
        end;
      Dwg_AcDs_Data_Record = _dwg_AcDs_Data_Record;
      //PDwg_AcDs_Data_Record = ^Dwg_AcDs_Data_Record;

      //P_dwg_AcDs_Data = ^_dwg_AcDs_Data;
      _dwg_AcDs_Data = record
          record_hdrs : PDwg_AcDs_Data_RecordHdr;
          records : PDwg_AcDs_Data_Record;
        end;
      Dwg_AcDs_Data = _dwg_AcDs_Data;
      //PDwg_AcDs_Data = ^Dwg_AcDs_Data;

      //P_dwg_AcDs_DataBlobRef_Page = ^_dwg_AcDs_DataBlobRef_Page;
      _dwg_AcDs_DataBlobRef_Page = record
          segidx : BITCODE_RL;
          size : BITCODE_RL;
        end;
      Dwg_AcDs_DataBlobRef_Page = _dwg_AcDs_DataBlobRef_Page;
      //PDwg_AcDs_DataBlobRef_Page = ^Dwg_AcDs_DataBlobRef_Page;

      //P_dwg_AcDs_DataBlobRef = ^_dwg_AcDs_DataBlobRef;
      _dwg_AcDs_DataBlobRef = record
          total_data_size : BITCODE_RLL;
          num_pages : BITCODE_RL;
          record_size : BITCODE_RL;
          page_size : BITCODE_RL;
          unknown_1 : BITCODE_RL;
          unknown_2 : BITCODE_RL;
          pages : PDwg_AcDs_DataBlobRef_Page;
        end;
      Dwg_AcDs_DataBlobRef = _dwg_AcDs_DataBlobRef;
      //PDwg_AcDs_DataBlobRef = ^Dwg_AcDs_DataBlobRef;

      //P_dwg_AcDs_DataBlob = ^_dwg_AcDs_DataBlob;
      _dwg_AcDs_DataBlob = record
          data_size : BITCODE_RLL;
          page_count : BITCODE_RL;
          record_size : BITCODE_RL;
          page_size : BITCODE_RL;
          unknown_1 : BITCODE_RL;
          unknown_2 : BITCODE_RL;
          ref : PDwg_AcDs_DataBlobRef;
        end;
      Dwg_AcDs_DataBlob = _dwg_AcDs_DataBlob;
      //PDwg_AcDs_DataBlob = ^Dwg_AcDs_DataBlob;

      //P_dwg_AcDs_DataBlob01 = ^_dwg_AcDs_DataBlob01;
      _dwg_AcDs_DataBlob01 = record
          total_data_size : BITCODE_RLL;
          page_start_offset : BITCODE_RLL;
          page_index : int32;
          page_count : int32;
          page_data_size : BITCODE_RLL;
          page_data : PBITCODE_RC;
        end;
      Dwg_AcDs_DataBlob01 = _dwg_AcDs_DataBlob01;
      //PDwg_AcDs_DataBlob01 = ^Dwg_AcDs_DataBlob01;

      //P_dwg_AcDs_SchemaIndex_Prop = ^_dwg_AcDs_SchemaIndex_Prop;
      _dwg_AcDs_SchemaIndex_Prop = record
          index : BITCODE_RL;
          segidx : BITCODE_RL;
          offset : BITCODE_RL;
        end;
      Dwg_AcDs_SchemaIndex_Prop = _dwg_AcDs_SchemaIndex_Prop;
      //PDwg_AcDs_SchemaIndex_Prop = ^Dwg_AcDs_SchemaIndex_Prop;

      //P_dwg_AcDs_SchemaIndex = ^_dwg_AcDs_SchemaIndex;
      _dwg_AcDs_SchemaIndex = record
          num_props : BITCODE_RL;
          si_unknown_1 : BITCODE_RL;
          props : PDwg_AcDs_SchemaIndex_Prop;
          si_tag : BITCODE_RLL;
          num_prop_entries : BITCODE_RL;
          si_unknown_2 : BITCODE_RL;
          prop_entries : PDwg_AcDs_SchemaIndex_Prop;
        end;
      Dwg_AcDs_SchemaIndex = _dwg_AcDs_SchemaIndex;
      //PDwg_AcDs_SchemaIndex = ^Dwg_AcDs_SchemaIndex;

      //P_dwg_AcDs_Schema_Prop = ^_dwg_AcDs_Schema_Prop;
      _dwg_AcDs_Schema_Prop = record
          flags : BITCODE_RL;
          namidx : BITCODE_RL;
          _type : BITCODE_RL;
          type_size : BITCODE_RL;
          unknown_1 : BITCODE_RL;
          unknown_2 : BITCODE_RL;
          num_values : BITCODE_RS;
          values : PBITCODE_RC;
        end;
      Dwg_AcDs_Schema_Prop = _dwg_AcDs_Schema_Prop;
      //PDwg_AcDs_Schema_Prop = ^Dwg_AcDs_Schema_Prop;

      //P_dwg_AcDs_Schema = ^_dwg_AcDs_Schema;
      _dwg_AcDs_Schema = record
          num_index : BITCODE_RS;
          index : PBITCODE_RLL;
          num_props : BITCODE_RS;
          props : PDwg_AcDs_Schema_Prop;
        end;
      Dwg_AcDs_Schema = _dwg_AcDs_Schema;
      //PDwg_AcDs_Schema = ^Dwg_AcDs_Schema;

      //P_dwg_AcDs_SchemaData_UProp = ^_dwg_AcDs_SchemaData_UProp;
      _dwg_AcDs_SchemaData_UProp = record
          size : BITCODE_RL;
          flags : BITCODE_RL;
        end;
      Dwg_AcDs_SchemaData_UProp = _dwg_AcDs_SchemaData_UProp;
      //PDwg_AcDs_SchemaData_UProp = ^Dwg_AcDs_SchemaData_UProp;

      //P_dwg_AcDs_SchemaData = ^_dwg_AcDs_SchemaData;
      _dwg_AcDs_SchemaData = record
          num_uprops : BITCODE_RL;
          uprops : PDwg_AcDs_SchemaData_UProp;
          num_schemas : BITCODE_RL;
          schemas : PDwg_AcDs_Schema;
          num_propnames : BITCODE_RL;
          propnames : PBITCODE_TV;
        end;
      //PDwg_AcDs_SchemaData = ^Dwg_AcDs_SchemaData;
      Dwg_AcDs_SchemaData = _dwg_AcDs_SchemaData;

      //P_dwg_AcDs_Search_IdIdx = ^_dwg_AcDs_Search_IdIdx;
      _dwg_AcDs_Search_IdIdx = record
          handle : BITCODE_RLL;
          num_ididx : BITCODE_RL;
          ididx : PBITCODE_RLL;
        end;
      Dwg_AcDs_Search_IdIdx = _dwg_AcDs_Search_IdIdx;
      //PDwg_AcDs_Search_IdIdx = ^Dwg_AcDs_Search_IdIdx;

      //P_dwg_AcDs_Search_IdIdxs = ^_dwg_AcDs_Search_IdIdxs;
      _dwg_AcDs_Search_IdIdxs = record
          num_ididx : BITCODE_RL;
          ididx : PDwg_AcDs_Search_IdIdx;
        end;
      Dwg_AcDs_Search_IdIdxs = _dwg_AcDs_Search_IdIdxs;
      //PDwg_AcDs_Search_IdIdxs = ^Dwg_AcDs_Search_IdIdxs;

      //P_dwg_AcDs_Search_Data = ^_dwg_AcDs_Search_Data;
      _dwg_AcDs_Search_Data = record
          schema_namidx : BITCODE_RL;
          num_sortedidx : BITCODE_RL;
          sortedidx : PBITCODE_RLL;
          num_ididxs : BITCODE_RL;
          unknown : BITCODE_RL;
          ididxs : PDwg_AcDs_Search_IdIdxs;
        end;
      Dwg_AcDs_Search_Data = _dwg_AcDs_Search_Data;
      //PDwg_AcDs_Search_Data = ^Dwg_AcDs_Search_Data;

      //P_dwg_AcDs_Search = ^_dwg_AcDs_Search;
      _dwg_AcDs_Search = record
          num_search : BITCODE_RL;
          search : PDwg_AcDs_Search_Data;
        end;
      Dwg_AcDs_Search = _dwg_AcDs_Search;
      //PDwg_AcDs_Search = ^Dwg_AcDs_Search;

      //P_dwg_AcDs_Segment = ^_dwg_AcDs_Segment;
      _dwg_AcDs_Segment = record
          signature : BITCODE_RS;
          name : array[0..6] of BITCODE_RC;
          _type : BITCODE_RCd;
          segment_idx : BITCODE_RL;
          is_blob01 : BITCODE_RL;
          segsize : BITCODE_RL;
          unknown_2 : BITCODE_RL;
          ds_version : BITCODE_RL;
          unknown_3 : BITCODE_RL;
          data_algn_offset : BITCODE_RL;
          objdata_algn_offset : BITCODE_RL;
          padding : array[0..8] of BITCODE_RC;
        end;
      Dwg_AcDs_Segment = _dwg_AcDs_Segment;
      //PDwg_AcDs_Segment = ^Dwg_AcDs_Segment;

      //P_dwg_AcDs = ^_dwg_AcDs;
      _dwg_AcDs = record
          file_signature : BITCODE_RL;
          file_header_size : BITCODE_RL;
          unknown_1 : BITCODE_RL;
          version : BITCODE_RL;
          unknown_2 : BITCODE_RL;
          ds_version : BITCODE_RL;
          segidx_offset : BITCODE_RL;
          segidx_unknown : BITCODE_RL;
          num_segidx : BITCODE_RL;
          schidx_segidx : BITCODE_RL;
          datidx_segidx : BITCODE_RL;
          search_segidx : BITCODE_RL;
          prvsav_segidx : BITCODE_RL;
          file_size : BITCODE_RL;
          total_segments : BITCODE_BL;
          segidx : PDwg_AcDs_SegmentIndex;
          datidx : Dwg_AcDs_DataIndex;
          data : PDwg_AcDs_Data;
          blob01 : Dwg_AcDs_DataBlob;
          schidx : Dwg_AcDs_SchemaIndex;
          schdat : Dwg_AcDs_SchemaData;
          search : Dwg_AcDs_Search;
          segments : PDwg_AcDs_Segment;
        end;
      Dwg_AcDs = _dwg_AcDs;
      //PDwg_AcDs = ^Dwg_AcDs;

      //P_dwg_header = ^_dwg_header;
      _dwg_header = record
          version : Dwg_Version_Type;
          from_version : Dwg_Version_Type;
          is_maint : BITCODE_RC;
          zero_one_or_three : BITCODE_RC;
          numentity_sections : BITCODE_RS;
          numheader_vars : BITCODE_RS;
          thumbnail_address : BITCODE_RL;
          dwg_version : BITCODE_RC;
          maint_version : BITCODE_RC;
          entities_start : BITCODE_RL;
          entities_end : BITCODE_RL;
          blocks_start : BITCODE_RL;
          blocks_size : BITCODE_RL;
          extras_start : BITCODE_RL;
          extras_size : BITCODE_RL;
          codepage : BITCODE_RS;
          unknown_0 : BITCODE_RC;
          app_dwg_version : BITCODE_RC;
          app_maint_version : BITCODE_RC;
          security_type : BITCODE_RL;
          rl_1c_address : BITCODE_RL;
          summaryinfo_address : BITCODE_RL;
          vbaproj_address : BITCODE_RL;
          r2004_header_address : BITCODE_RL;
          sections : BITCODE_RL;
          num_sections : BITCODE_RL;
          section : PDwg_Section;
          section_infohdr : Dwg_Section_InfoHdr;
          section_info : PDwg_Section_Info;
        end;
      Dwg_Header = _dwg_header;
      //PDwg_Header = ^Dwg_Header;
(** unsupported pragma#pragma pack(1)*)


      //P_dwg_R2004_Header = ^_dwg_R2004_Header;
      _dwg_R2004_Header = record
          file_ID_string : array[0..11] of BITCODE_RC;
          header_address : BITCODE_RLx;
          header_size : BITCODE_RL;
          x04 : BITCODE_RL;
          root_tree_node_gap : BITCODE_RLd;
          lowermost_left_tree_node_gap : BITCODE_RLd;
          lowermost_right_tree_node_gap : BITCODE_RLd;
          unknown_long : BITCODE_RL;
          last_section_id : BITCODE_RL;
          last_section_address : BITCODE_RLL;
          second_header_address : BITCODE_RLL;
          numgaps : BITCODE_RL;
          numsections : BITCODE_RL;
          x20 : BITCODE_RL;
          x80 : BITCODE_RL;
          x40 : BITCODE_RL;
          section_map_id : BITCODE_RL;
          section_map_address : BITCODE_RLL;
          section_info_id : BITCODE_RLd;
          section_array_size : BITCODE_RL;
          gap_array_size : BITCODE_RL;
          crc32 : BITCODE_RLx;
          padding : array[0..11] of BITCODE_RC;
          section_type : BITCODE_RL;
          decomp_data_size : BITCODE_RL;
          comp_data_size : BITCODE_RL;
          compression_type : BITCODE_RL;
          checksum : BITCODE_RLx;
        end;
      Dwg_R2004_Header = _dwg_R2004_Header;
      //PDwg_R2004_Header = ^Dwg_R2004_Header;
(** unsupported pragma#pragma pack()*)


      //P_dwg_auxheader = ^_dwg_auxheader;
      _dwg_auxheader = record
          aux_intro : array[0..2] of BITCODE_RC;
          dwg_version : BITCODE_RS;
          maint_version : BITCODE_RL;
          numsaves : BITCODE_RL;
          minus_1 : BITCODE_RL;
          numsaves_1 : BITCODE_RS;
          numsaves_2 : BITCODE_RS;
          zero : BITCODE_RL;
          dwg_version_1 : BITCODE_RS;
          maint_version_1 : BITCODE_RL;
          dwg_version_2 : BITCODE_RS;
          maint_version_2 : BITCODE_RL;
          unknown_6rs : array[0..5] of BITCODE_RS;
          unknown_5rl : array[0..4] of BITCODE_RL;
          TDCREATE : BITCODE_RD;
          TDUPDATE : BITCODE_RD;
          HANDSEED : BITCODE_RL;
          plot_stamp : BITCODE_RL;
          zero_1 : BITCODE_RS;
          numsaves_3 : BITCODE_RS;
          zero_2 : BITCODE_RL;
          zero_3 : BITCODE_RL;
          zero_4 : BITCODE_RL;
          numsaves_4 : BITCODE_RL;
          zero_5 : BITCODE_RL;
          zero_6 : BITCODE_RL;
          zero_7 : BITCODE_RL;
          zero_8 : BITCODE_RL;
          zero_18 : array[0..2] of BITCODE_RS;
        end;
      Dwg_AuxHeader = _dwg_auxheader;
      //PDwg_AuxHeader = ^Dwg_AuxHeader;

      //P_dwg_summaryinfo = ^_dwg_summaryinfo;
      _dwg_summaryinfo = record
          TITLE : BITCODE_TU;
          SUBJECT : BITCODE_TU;
          AUTHOR : BITCODE_TU;
          KEYWORDS : BITCODE_TU;
          COMMENTS : BITCODE_TU;
          LASTSAVEDBY : BITCODE_TU;
          REVISIONNUMBER : BITCODE_TU;
          HYPERLINKBASE : BITCODE_TU;
          TDINDWG : BITCODE_TIMERLL;
          TDCREATE : BITCODE_TIMERLL;
          TDUPDATE : BITCODE_TIMERLL;
          num_props : BITCODE_RS;
          props : PDwg_SummaryInfo_Property;
          unknown1 : BITCODE_RL;
          unknown2 : BITCODE_RL;
        end;
      Dwg_SummaryInfo = _dwg_summaryinfo;
      //PDwg_SummaryInfo = ^Dwg_SummaryInfo;

      //P_dwg_appinfo = ^_dwg_appinfo;
      _dwg_appinfo = record
          class_version : BITCODE_RL;
          num_strings : BITCODE_RL;
          appinfo_name : BITCODE_TU;
          version_checksum : array[0..15] of BITCODE_RC;
          comment_checksum : array[0..15] of BITCODE_RC;
          product_checksum : array[0..15] of BITCODE_RC;
          version : BITCODE_TU;
          comment : BITCODE_TU;
          product_info : BITCODE_TU;
        end;
      Dwg_AppInfo = _dwg_appinfo;
      //PDwg_AppInfo = ^Dwg_AppInfo;

      //P_dwg_filedeplist = ^_dwg_filedeplist;
      _dwg_filedeplist = record
          num_features : BITCODE_RL;
          features : PBITCODE_TV;
          num_files : BITCODE_RL;
          files : PDwg_FileDepList_Files;
        end;
      Dwg_FileDepList = _dwg_filedeplist;
      //PDwg_FileDepList = ^Dwg_FileDepList;

      //P_dwg_security = ^_dwg_security;
      _dwg_security = record
          unknown_1 : BITCODE_RL;
          unknown_2 : BITCODE_RL;
          unknown_3 : BITCODE_RL;
          crypto_id : BITCODE_RL;
          crypto_name : BITCODE_TV;
          algo_id : BITCODE_RL;
          key_len : BITCODE_RL;
          encr_size : BITCODE_RL;
          encr_buffer : BITCODE_TF;
        end;
      Dwg_Security = _dwg_security;
      //PDwg_Security = ^Dwg_Security;

      //P_dwg_vbaproject = ^_dwg_vbaproject;
      _dwg_vbaproject = record
          size : longint;
          unknown_bits : BITCODE_TF;
        end;
      Dwg_VBAProject = _dwg_vbaproject;
      //PDwg_VBAProject = ^Dwg_VBAProject;

      //P_dwg_appinfohistory = ^_dwg_appinfohistory;
      _dwg_appinfohistory = record
          size : longint;
          unknown_bits : BITCODE_TF;
        end;
      Dwg_AppInfoHistory = _dwg_appinfohistory;
      //PDwg_AppInfoHistory = ^Dwg_AppInfoHistory;

      //P_dwg_revhistory = ^_dwg_revhistory;
      _dwg_revhistory = record
          class_version : BITCODE_RL;
          class_minor : BITCODE_RL;
          num_histories : BITCODE_RL;
          histories : PBITCODE_RL;
        end;
      Dwg_RevHistory = _dwg_revhistory;
      //PDwg_RevHistory = ^Dwg_RevHistory;

      //P_dwg_objfreespace = ^_dwg_objfreespace;
      _dwg_objfreespace = record
          zero : BITCODE_RLL;
          num_handles : BITCODE_RLL;
          TDUPDATE : BITCODE_TIMERLL;
          objects_address : BITCODE_RL;
          num_nums : BITCODE_RC;
          max32 : BITCODE_RLL;
          max64 : BITCODE_RLL;
          maxtbl : BITCODE_RLL;
          maxrl : BITCODE_RLL;
          max32_hi : BITCODE_RLL;
          max64_hi : BITCODE_RLL;
          maxtbl_hi : BITCODE_RLL;
          maxrl_hi : BITCODE_RLL;
        end;
      Dwg_ObjFreeSpace = _dwg_objfreespace;
      //PDwg_ObjFreeSpace = ^Dwg_ObjFreeSpace;

      //P_dwg_template = ^_dwg_template;
      _dwg_template = record
          description : BITCODE_TV;
          MEASUREMENT : BITCODE_RS;
        end;
      Dwg_Template = _dwg_template;
      //PDwg_Template = ^Dwg_Template;

      //P_dwg_second_header = ^_dwg_second_header;
      _dwg_second_header = record
          size : BITCODE_RL;
          address : BITCODE_RL;
          version : array[0..11] of BITCODE_RC;
          null_b : array[0..3] of BITCODE_B;
          unknown_10 : BITCODE_RC;
          unknown_rc4 : array[0..3] of BITCODE_RC;
          num_sections : BITCODE_RC;
          section : array[0..5] of record
              nr : BITCODE_RC;
              address : BITCODE_BL;
              size : BITCODE_BL;
            end;
          num_handlers : BITCODE_BS;
          handlers : array[0..15] of record
              size : BITCODE_RC;
              nr : BITCODE_RC;
              data : PBITCODE_RC;
            end;
          junk_r14_1 : BITCODE_RL;
          junk_r14_2 : BITCODE_RL;
        end;
      Dwg_Second_Header = _dwg_second_header;
      //PDwg_Second_Header = ^Dwg_Second_Header;

      //P_dwg_struct = ^_dwg_struct;
      _dwg_struct = record
          header : Dwg_Header;
          num_classes : BITCODE_BS;
          dwg_class : PDwg_Class;
          num_objects : BITCODE_BL;
          num_alloced_objects : BITCODE_BL;
          &object : PDwg_Object;
          num_entities : BITCODE_BL;
          num_object_refs : BITCODE_BL;
          cur_index : BITCODE_BL;
          object_ref : ^PDwg_Object_Ref;
          object_map : {P_inthash}pointer;
          dirty_refs : longint;
          opts : dword;
          header_vars : Dwg_Header_Variables;
          thumbnail : Dwg_Chain;
          r2004_header : Dwg_R2004_Header;
          mspace_block : PDwg_Object;
          pspace_block : PDwg_Object;
          block_control : Dwg_Object_BLOCK_CONTROL;
          auxheader : Dwg_AuxHeader;
          summaryinfo : Dwg_SummaryInfo;
          appinfo : Dwg_AppInfo;
          filedeplist : Dwg_FileDepList;
          security : Dwg_Security;
          vbaproject : Dwg_VBAProject;
          appinfohistory : Dwg_AppInfoHistory;
          revhistory : Dwg_RevHistory;
          objfreespace : Dwg_ObjFreeSpace;
          Template : Dwg_Template;
          acds : Dwg_AcDs;
          second_header : Dwg_Second_Header;
          layout_type : dword;
          num_acis_sab_hdl : dword;
          acis_sab_hdl : PBITCODE_H;
          next_hdl : dword;
        end;
      Dwg_Data = _dwg_struct;
      //PDwg_Data = ^Dwg_Data;

      //PRESBUF_VALUE_TYPE = ^RESBUF_VALUE_TYPE;
      RESBUF_VALUE_TYPE = (DWG_VT_INVALID = 0,DWG_VT_STRING = 1,
        DWG_VT_POINT3D = 2,DWG_VT_REAL = 3,
        DWG_VT_INT16 = 4,DWG_VT_INT32 = 5,
        DWG_VT_INT8 = 6,DWG_VT_BINARY = 7,
        DWG_VT_HANDLE = 8,DWG_VT_OBJECTID = 9,
        DWG_VT_BOOL = 10,DWG_VT_INT64 = 11
        );
      Dwg_Resbuf_Value_Type = RESBUF_VALUE_TYPE;
      //PDwg_Resbuf_Value_Type = ^Dwg_Resbuf_Value_Type;

      //Prgbpalette = ^rgbpalette;
      rgbpalette = record
          r : byte;
          g : byte;
          b : byte;
        end;
      Dwg_RGB_Palette = rgbpalette;
      //PDwg_RGB_Palette = ^Dwg_RGB_Palette;

    const
      bm__dwg_binary_chunk_codepage = $7FFF;
      bp__dwg_binary_chunk_codepage = 0;
      bm__dwg_binary_chunk_is_tu = $8000;
      bp__dwg_binary_chunk_is_tu = 15;

    const
      bm__dwg_entity_eed_data_codepage = $7FFF;
      bp__dwg_entity_eed_data_codepage = 0;
      bm__dwg_entity_eed_data_is_tu = $8000;
      bp__dwg_entity_eed_data_is_tu = 15;
      bm__dwg_entity_eed_data__padding = $7FFF;
      bp__dwg_entity_eed_data__padding = 0;
      //bm__dwg_entity_eed_data_is_tu = $8000;
      //bp__dwg_entity_eed_data_is_tu = 15;

    {function codepage(var a : _dwg_binary_chunk) : dword;
    procedure set_codepage(var a : _dwg_binary_chunk; __codepage : dword);
    function is_tu(var a : _dwg_binary_chunk) : dword;
    procedure set_is_tu(var a : _dwg_binary_chunk; __is_tu : dword);}


implementation

    {function codepage(var a : _dwg_binary_chunk) : dword;
      begin
        codepage:=(a.flag0 and bm__dwg_binary_chunk_codepage) shr bp__dwg_binary_chunk_codepage;
      end;

    procedure set_codepage(var a : _dwg_binary_chunk; __codepage : dword);
      begin
        a.flag0:=a.flag0 or ((__codepage shl bp__dwg_binary_chunk_codepage) and bm__dwg_binary_chunk_codepage);
      end;

    function is_tu(var a : _dwg_binary_chunk) : dword;
      begin
        is_tu:=(a.flag0 and bm__dwg_binary_chunk_is_tu) shr bp__dwg_binary_chunk_is_tu;
      end;

    procedure set_is_tu(var a : _dwg_binary_chunk; __is_tu : dword);
      begin
        a.flag0:=a.flag0 or ((__is_tu shl bp__dwg_binary_chunk_is_tu) and bm__dwg_binary_chunk_is_tu);
      end;}


end.
