begin
     CDSC_temp:=CDSC_temp+Entity.SerialConnection;
     Entity.GC_NumberInGroup:=CDSC_temp;

     Entity.GC_HeadDevice:=cable.GC_HeadDevice;
     Entity.GC_HDGroup:=cable.GC_HDGroup;
     Entity.GC_HDShortName:=cable.GC_HDShortName;
end.
