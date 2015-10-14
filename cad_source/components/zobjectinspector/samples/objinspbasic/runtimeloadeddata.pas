unit runtimeloadeddata;
uses system;
interface
type
  TMyEnum=(MyEnum1,MyEnum2,MyEnum3,MyEnum4);
  TSubData=packed record
           a,b,c:TMyEnum;
  end;
  TMyArray=packed array[0..10] of TSubData;
  PTOtherData=^TOtherData;
  TOtherData=packed record
    data1:GDBInteger;
    data2:GDBInteger;
    data3:GDBInteger;
  end;
  TData1=packed record
    subdata1,subdata2,subdata3:TSubData;
    dataI:GDBInteger;
    dataD:GDBDouble;
    dataS:GDBString;
    arr:TMyArray;
    pointerToOtherData:PTOtherData;
  end;
implementation
begin
end.
