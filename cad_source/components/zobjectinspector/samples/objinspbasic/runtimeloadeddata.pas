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
    data1:Integer;
    data2:Integer;
    data3:Integer;
  end;
  TData1=packed record
    subdata1,subdata2,subdata3:TSubData;
    dataI:Integer;
    dataD:Double;
    dataS:String;
    arr:TMyArray;
    pointerToOtherData:PTOtherData;
  end;
implementation
begin
end.
