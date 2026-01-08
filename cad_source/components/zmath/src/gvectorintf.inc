    type
      TCoordType=TT;
      TCoordArray=array [0..ArrS-1] of T;
      TSelf=VectorTypeName<T,TT>;
    const
      ArrH=High(TCoordArray);
      ArrL=Low(TCoordArray);

    function SqrLength:Double;inline;
    function Length:Double;inline;
    {$IfNDef IntParam}
    function NormalizeVertex:TSelf;inline;
    {$EndIf}
    function Add(const Vector2:TSelf):TSelf;inline;
    function Sub(const Vector2:TSelf):TSelf;inline;

    class operator +(const l,r:TSelf):TSelf;inline;
    class operator -(const l,r:TSelf):TSelf;inline;
    class operator -(const r:TSelf):TSelf;inline;
    class operator *(const l:TSelf;const r:T):TSelf;inline;
    class operator *(const l,r:TSelf):Real;inline;
    {$IfNDef IntParam}
    class operator /(const l:TSelf;const r:Real):TSelf;inline;
    {$EndIf}
