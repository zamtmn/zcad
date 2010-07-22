unit sysvar;
interface
uses system;
var
   DWG_DrawMode:GDBInteger;
   DWG_OSMode:GDBInteger;
   DWG_PolarMode:GDBInteger;
   DWG_CLayer:GDBInteger;
   DWG_CLinew:GDBInteger;
   DWG_SystmGeometryDraw:GDBBoolean;
   DWG_HelpGeometryDraw:GDBBoolean;
   DWG_MaxGrid:GDBInteger;
   DWG_StepGrid:GDBDouble;
   DWG_DrawGrid:GDBBoolean;
   DWG_EditInSubEntry:GDBBoolean;
   DWG_SelectedObjToInsp:GDBBoolean;

   DSGN_TraceAutoInc:GDBBoolean;

   VIEW_CommandLineVisible:GDBBoolean;
   VIEW_HistoryLineVisible:GDBBoolean;
   VIEW_ObjInspVisible:GDBBoolean;

   PMenuProjType:GDBPointer;
   PMenuCommandLine:GDBPointer;
   PMenuHistoryLine:GDBPointer;
   PMenuStatusPanel:GDBPointer;
   PMenuDebugObjInsp:GDBPointer;
   StatusPanelVisible:GDBBoolean;

   DISP_ZoomFactor:GDBDouble;
   DISP_CursorSize:GDBInteger;
   DISP_OSSize:GDBDouble;
   DISP_DrawZAxis:GDBBoolean;
   DISP_ColorAxis:GDBBoolean;

   RD_PanObjectDegradation:GDBBoolean;
   RD_LineSmooth:GDBBoolean;
   RD_MaxLineWidth:GDBDouble;
   RD_MaxPointSize:GDBDouble;
   RD_Vendor:GDBString;
   RD_Renderer:GDBString;
   RD_Version:GDBString;
   RD_MaxWidth:GDBInteger;
   RD_BackGroundColor:RGB;
   RD_Restore_Mode:TRestoreMode;
   RD_LastRenderTime:GDBInteger;

   SAVE_Auto_Interval:GDBInteger;
   SAVE_Auto_Current_Interval:GDBInteger;
   SAVE_Auto_FileName:GDBString;

   SYS_RunTime:GDBInteger;
   SYS_Version:GDBString;
   SYS_ActiveMouse:GDBBoolean;
   SYS_SystmGeometryColor:GDBInteger;
   SYS_IsHistoryLineCreated:GDBBoolean;

   PATH_Device_Library:GDBString;
   PATH_Program_Run:GDBString;

   ShowHiddenFieldInObjInsp:GDBBoolean;

   testGDBBoolean:GDBBoolean;
   pi:GDBDouble;
implementation
begin
     DISP_ZoomFactor:=1.624;
     DISP_CursorSize:=6;
     DISP_OSSize:=10.0;
     DISP_DrawZAxis:=false;
     DISP_ColorAxis:=false;
     DWG_DrawMode:=0;
     DWG_CLayer:=0;
     DWG_CLinew:=-1;
     DWG_OSMode:=6119;
     DWG_PolarMode:=1;
     DSGN_TraceAutoInc:=false;
     pi:=3.14159265359;
     RD_BackGroundColor.r:=0;
     RD_BackGroundColor.g:=0;
     RD_BackGroundColor.b:=0;
     RD_BackGroundColor.a:=255;
     RD_Restore_Mode:=WND_Texture;
     SAVE_Auto_Interval:=180;
     SAVE_Auto_Current_Interval:=SAVE_Auto_Interval;
     SAVE_Auto_FileName:='*autosave\autosave.dxf';
     PATH_Program_Run:='Неопределен';
     DWG_MaxGrid:=99;
     DWG_StepGrid:=10;
     DWG_DrawGrid:=false;
     RD_PanObjectDegradation:=true;
     RD_LineSmooth:=false;
     VIEW_CommandLineVisible:=true;
     VIEW_HistoryLineVisible:=true;
     VIEW_ObjInspVisible:=true;
     DWG_EditInSubEntry:=false;
     SYS_Version:='заебись';
     SYS_ActiveMouse:=true;
     SYS_IsHistoryLineCreated:=false;
     PATH_Device_Library:='*ZCADLibrary\';
     ShowHiddenFieldInObjInsp:=false;
     SYS_SystmGeometryColor:=250;
     DWG_SystmGeometryDraw:=false;
     DWG_HelpGeometryDraw:=true;
     DWG_SelectedObjToInsp:=true;
end.
