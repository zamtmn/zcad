UNIT uD3Dcompiler;

INTERFACE

uses
  Windows, uDxTypes, uD3Dcommon;

{$ALIGN ON}
{$MINENUMSIZE 4}

const
  D3D_COMPRESS_SHADER_KEEP_ALL_PARTS = $00000001;

  D3D_DISASM_ENABLE_COLOR_CODE             = $00000001;
  D3D_DISASM_ENABLE_DEFAULT_VALUE_PRINTS   = $00000002;
  D3D_DISASM_ENABLE_INSTRUCTION_NUMBERING  = $00000004;
  D3D_DISASM_ENABLE_INSTRUCTION_CYCLE      = $00000008;
  D3D_DISASM_DISABLE_DEBUG_INFO            = $00000010;

//----------------------------------------------------------------------------
// D3DCOMPILE flags:
// -----------------
// D3DCOMPILE_DEBUG
//   Insert debug file/line/type/symbol information.
//
// D3DCOMPILE_SKIP_VALIDATION
//   Do not validate the generated code against known capabilities and
//   constraints.  This option is only recommended when compiling shaders
//   you KNOW will work.  (ie. have compiled before without this option.)
//   Shaders are always validated by D3D before they are set to the device.
//
// D3DCOMPILE_SKIP_OPTIMIZATION
//   Instructs the compiler to skip optimization steps during code generation.
//   Unless you are trying to isolate a problem in your code using this option
//   is not recommended.
//
// D3DCOMPILE_PACK_MATRIX_ROW_MAJOR
//   Unless explicitly specified, matrices will be packed in row-major order
//   on input and output from the shader.
//
// D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR
//   Unless explicitly specified, matrices will be packed in column-major
//   order on input and output from the shader.  This is generally more
//   efficient, since it allows vector-matrix multiplication to be performed
//   using a series of dot-products.
//
// D3DCOMPILE_PARTIAL_PRECISION
//   Force all computations in resulting shader to occur at partial precision.
//   This may result in faster evaluation of shaders on some hardware.
//
// D3DCOMPILE_FORCE_VS_SOFTWARE_NO_OPT
//   Force compiler to compile against the next highest available software
//   target for vertex shaders.  This flag also turns optimizations off,
//   and debugging on.
//
// D3DCOMPILE_FORCE_PS_SOFTWARE_NO_OPT
//   Force compiler to compile against the next highest available software
//   target for pixel shaders.  This flag also turns optimizations off,
//   and debugging on.
//
// D3DCOMPILE_NO_PRESHADER
//   Disables Preshaders. Using this flag will cause the compiler to not
//   pull out static expression for evaluation on the host cpu
//
// D3DCOMPILE_AVOID_FLOW_CONTROL
//   Hint compiler to avoid flow-control constructs where possible.
//
// D3DCOMPILE_PREFER_FLOW_CONTROL
//   Hint compiler to prefer flow-control constructs where possible.
//
// D3DCOMPILE_ENABLE_STRICTNESS
//   By default, the HLSL/Effect compilers are not strict on deprecated syntax.
//   Specifying this flag enables the strict mode. Deprecated syntax may be
//   removed in a future release, and enabling syntax is a good way to make
//   sure your shaders comply to the latest spec.
//
// D3DCOMPILE_ENABLE_BACKWARDS_COMPATIBILITY
//   This enables older shaders to compile to 4_0 targets.
//
//----------------------------------------------------------------------------

  D3DCOMPILE_DEBUG                           = (1 shl 0);
  D3DCOMPILE_SKIP_VALIDATION                 = (1 shl 1);
  D3DCOMPILE_SKIP_OPTIMIZATION               = (1 shl 2);
  D3DCOMPILE_PACK_MATRIX_ROW_MAJOR           = (1 shl 3);
  D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR        = (1 shl 4);
  D3DCOMPILE_PARTIAL_PRECISION               = (1 shl 5);
  D3DCOMPILE_FORCE_VS_SOFTWARE_NO_OPT        = (1 shl 6);
  D3DCOMPILE_FORCE_PS_SOFTWARE_NO_OPT        = (1 shl 7);
  D3DCOMPILE_NO_PRESHADER                    = (1 shl 8);
  D3DCOMPILE_AVOID_FLOW_CONTROL              = (1 shl 9);
  D3DCOMPILE_PREFER_FLOW_CONTROL             = (1 shl 10);
  D3DCOMPILE_ENABLE_STRICTNESS               = (1 shl 11);
  D3DCOMPILE_ENABLE_BACKWARDS_COMPATIBILITY  = (1 shl 12);
  D3DCOMPILE_IEEE_STRICTNESS                 = (1 shl 13);
  D3DCOMPILE_OPTIMIZATION_LEVEL0             = (1 shl 14);
  D3DCOMPILE_OPTIMIZATION_LEVEL1             = 0;
  D3DCOMPILE_OPTIMIZATION_LEVEL2             = (1 shl 14) or (1 shl 15);
  D3DCOMPILE_OPTIMIZATION_LEVEL3             = (1shl 15);
  D3DCOMPILE_RESERVED16                      = (1 shl 16);
  D3DCOMPILE_RESERVED17                      = (1 shl 17);
  D3DCOMPILE_WARNINGS_ARE_ERRORS             = (1 shl 18);

//----------------------------------------------------------------------------
// D3DCOMPILE_EFFECT flags:
// -------------------------------------
// These flags are passed in when creating an effect, and affect
// either compilation behavior or runtime effect behavior
//
// D3DCOMPILE_EFFECT_CHILD_EFFECT
//   Compile this .fx file to a child effect. Child effects have no
//   initializers for any shared values as these are initialied in the
//   master effect (pool).
//
// D3DCOMPILE_EFFECT_ALLOW_SLOW_OPS
//   By default, performance mode is enabled.  Performance mode
//   disallows mutable state objects by preventing non-literal
//   expressions from appearing in state object definitions.
//   Specifying this flag will disable the mode and allow for mutable
//   state objects.
//
//----------------------------------------------------------------------------

  D3DCOMPILE_EFFECT_CHILD_EFFECT             = (1 shl 0);
  D3DCOMPILE_EFFECT_ALLOW_SLOW_OPS           = (1 shl 1);

  // D3DCOMPILER_STRIP_FLAGS
  D3DCOMPILER_STRIP_REFLECTION_DATA  = 1;
  D3DCOMPILER_STRIP_DEBUG_INFO       = 2;
  D3DCOMPILER_STRIP_TEST_BLOBS       = 4;

type
  D3DCOMPILER_STRIP_FLAGS = UINT;

  D3D_BLOB_PART =
  (
    D3D_BLOB_INPUT_SIGNATURE_BLOB,
    D3D_BLOB_OUTPUT_SIGNATURE_BLOB,
    D3D_BLOB_INPUT_AND_OUTPUT_SIGNATURE_BLOB,
    D3D_BLOB_PATCH_CONSTANT_SIGNATURE_BLOB,
    D3D_BLOB_ALL_SIGNATURE_BLOB,
    D3D_BLOB_DEBUG_INFO,
    D3D_BLOB_LEGACY_SHADER,
    D3D_BLOB_XNA_PREPASS_SHADER,
    D3D_BLOB_XNA_SHADER,

    // Test parts are only produced by special compiler versions and so
    // are usually not present in shaders.
    D3D_BLOB_TEST_ALTERNATE_SHADER = $8000,
    D3D_BLOB_TEST_COMPILE_DETAILS,
    D3D_BLOB_TEST_COMPILE_PERF
  );

  LP_D3D_SHADER_DATA = ^D3D_SHADER_DATA;
  D3D_SHADER_DATA = record
    pBytecode: Pointer;
    BytecodeLength: SIZE_T;
  end;


  //----------------------------------------------------------------------------
  // D3DCompile:
  // ----------
  // Compile source text into bytecode appropriate for the given target.
  //----------------------------------------------------------------------------

  function D3DCompile
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             pSourceName: LPCSTR;
             pDefines: LP_D3D_SHADER_MACRO;
             pInclude: ID3DInclude;
             pEntrypoint: LPCSTR;
             pTarget: LPCSTR;
             Flags1: UINT;  // shader compile options
             Flags2: UINT;  // effect compile options
             out pCode: ID3DBlob;
             {out} ppErrorMsgs: LP_ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DPreprocess:
  // ----------
  // Process source text with the compiler's preprocessor and return
  // the resulting text.
  //----------------------------------------------------------------------------

  function D3DPreprocess
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             pSourceName: LPCSTR;
             pDefines: LP_D3D_SHADER_MACRO;
             pInclude: ID3DInclude;
             out pCodeText: ID3DBlob;
             {out} ppErrorMsgs: LP_ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DGetDebugInfo:
  // -----------------------
  // Gets shader debug info.  Debug info is generated by D3DCompile and is
  // embedded in the body of the shader.
  //----------------------------------------------------------------------------

  function D3DGetDebugInfo
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             out pDebugInfo: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DReflect:
  // ----------
  // Shader code contains metadata that can be inspected via the
  // reflection APIs.
  //----------------------------------------------------------------------------

  function D3DReflect
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             const pInterface: TGUID;
             out pReflector
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DDisassemble:
  // ----------------------
  // Takes a binary shader and returns a buffer containing text assembly.
  //----------------------------------------------------------------------------

  function D3DDisassemble
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             Flags: UINT;
             szComments: LPCSTR;
             out pDisassembly: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DDisassemble10Effect:
  // -----------------------
  // Takes a D3D10 effect interface and returns a
  // buffer containing text assembly.
  //----------------------------------------------------------------------------
  {
  function D3DDisassemble10Effect
           (
             pEffect: ID3D10Effect;
             Flags: UINT;
             out pDisassembly: ID3DBlob
           ): HRESULT;  stdcall;
  }
  //----------------------------------------------------------------------------
  // D3DGetInputSignatureBlob:
  // -----------------------
  // Retrieve the input signature from a compilation result.
  //----------------------------------------------------------------------------

  function D3DGetInputSignatureBlob
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             out pSignatureBlob: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DGetOutputSignatureBlob:
  // -----------------------
  // Retrieve the output signature from a compilation result.
  //----------------------------------------------------------------------------

  function D3DGetOutputSignatureBlob
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             out pSignatureBlob: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DGetInputAndOutputSignatureBlob:
  // -----------------------
  // Retrieve the input and output signatures from a compilation result.
  //----------------------------------------------------------------------------

  function D3DGetInputAndOutputSignatureBlob
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             out pSignatureBlob: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DStripShader:
  // -----------------------
  // Removes unwanted blobs from a compilation result
  //----------------------------------------------------------------------------

  function D3DStripShader
           (
             pShaderBytecode: Pointer;
             BytecodeLength: SIZE_T;
             uStripFlags: D3DCOMPILER_STRIP_FLAGS;
             out pStrippedBlob: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DGetBlobPart:
  // -----------------------
  // Extracts information from a compilation result.
  //----------------------------------------------------------------------------

  function D3DGetBlobPart
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             Part: D3D_BLOB_PART;
             Flags: UINT;
             out pPart: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DCompressShaders:
  // -----------------------
  // Compresses a set of shaders into a more compact form.
  //----------------------------------------------------------------------------

  function D3DCompressShaders
           (
             nNumShaders: UINT;
             pShaderdata: LP_D3D_SHADER_DATA;
             uFlags: UINT;
             out pCompressedData: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DDecompressShaders:
  // -----------------------
  // Decompresses one or more shaders from a compressed set.
  //----------------------------------------------------------------------------

  function D3DDecompressShaders
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             uNumShaders: UINT;
             uStartIndex: UINT;
             pIndices: LP_UINT;
             uFlags: UINT;
             out pShaders: ID3DBlob
           ): HRESULT;  stdcall;

  //----------------------------------------------------------------------------
  // D3DCreateBlob:
  // -----------------------
  // Create an ID3DBlob instance.
  //----------------------------------------------------------------------------

  function D3DCreateBlob(Size: SIZE_T; out pBlob: ID3DBlob): HRESULT;  stdcall;


IMPLEMENTATION

const
  d3dcompiler_dll = 'd3dcompiler_43.dll';


function D3DCompile
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           pSourceName: LPCSTR;
           pDefines: LP_D3D_SHADER_MACRO;
           pInclude: ID3DInclude;
           pEntrypoint: LPCSTR;
           pTarget: LPCSTR;
           Flags1: UINT;
           Flags2: UINT;
           out pCode: ID3DBlob;
           {out} ppErrorMsgs: LP_ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DCompile';

function D3DPreprocess
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           pSourceName: LPCSTR;
           pDefines: LP_D3D_SHADER_MACRO;
           pInclude: ID3DInclude;
           out pCodeText: ID3DBlob;
           {out} ppErrorMsgs: LP_ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DPreprocess';

function D3DGetDebugInfo
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           out pDebugInfo: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DGetDebugInfo';

function D3DReflect
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           const pInterface: TGUID;
           out pReflector
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DReflect';

function D3DDisassemble
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           Flags: UINT;
           szComments: LPCSTR;
           out pDisassembly: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DDisassemble';

function D3DGetInputSignatureBlob
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           out pSignatureBlob: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DGetInputSignatureBlob';

function D3DGetOutputSignatureBlob
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           out pSignatureBlob: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DGetOutputSignatureBlob';

function D3DGetInputAndOutputSignatureBlob
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           out pSignatureBlob: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DGetInputAndOutputSignatureBlob';

function D3DStripShader
         (
           pShaderBytecode: Pointer;
           BytecodeLength: SIZE_T;
           uStripFlags: D3DCOMPILER_STRIP_FLAGS;
           out pStrippedBlob: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DStripShader';

function D3DGetBlobPart
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           Part: D3D_BLOB_PART;
           Flags: UINT;
           out pPart: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DGetBlobPart';

function D3DCompressShaders
         (
           nNumShaders: UINT;
           pShaderdata: LP_D3D_SHADER_DATA;
           uFlags: UINT;
           out pCompressedData: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DCompressShaders';

function D3DDecompressShaders
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           uNumShaders: UINT;
           uStartIndex: UINT;
           pIndices: LP_UINT;
           uFlags: UINT;
           out pShaders: ID3DBlob
         ): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DDecompressShaders';

function D3DCreateBlob(Size: SIZE_T; out pBlob: ID3DBlob): HRESULT;  stdcall;
  external d3dcompiler_dll name 'D3DCreateBlob';

END.
