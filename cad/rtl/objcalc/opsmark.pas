begin
     Entity.GC_NumberInGroup:=CDSC_temp;
     CDSC_temp:=CDSC_temp+Entity.SerialConnection;

     Entity.GC_HeadDevice:=Cable.GC_HeadDevice;
     Entity.GC_HDGroup:=Cable.GC_HDGroup;
     Entity.GC_HDShortName:=Cable.GC_HDShortName;
end.
