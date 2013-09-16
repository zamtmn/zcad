{$DEFINE TCommand  := TGDBVertexChangeCommand}
{$DEFINE PTCommand := PTGDBVertexChangeCommand}
{$DEFINE TData     := GDBVertex}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBCameraBasePropChangeCommand}
{$DEFINE PTCommand := PTGDBCameraBasePropChangeCommand}
{$DEFINE TData     := GDBCameraBaseProp}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBStringChangeCommand}
{$DEFINE PTCommand := PTGDBStringChangeCommand}
{$DEFINE TData     := GDBString}
  {$I TGChangeCommandIMPL.inc}

{$DEFINE TCommand  := TGDBPoinerChangeCommand}
{$DEFINE PTCommand := PTGDBPoinerChangeCommand}
{$DEFINE TData     := GDBPointer}
  {$I TGChangeCommandIMPL.inc}
