UNIT uDXGI;

INTERFACE

uses
  Windows, uDXTypes;

{$ALIGN ON}
{$MINENUMSIZE 4}

const
  _FACDXGI = $087A;
  // #define MAKE_HRESULT(sev,fac,code) \
  //   ((HRESULT) (((unsigned long)(sev)<<31) | ((unsigned long)(fac)<<16) | ((unsigned long)(code))) )
  // #define MAKE_DXGI_HRESULT(code) MAKE_HRESULT(1, _FACDXGI, code)
  // #define MAKE_DXGI_STATUS(code)  MAKE_HRESULT(0, _FACDXGI, code)

  DXGI_STATUS_OCCLUDED                      = HRESULT ( (UINT(_FACDXGI) shl 16) or (01) );
  DXGI_STATUS_CLIPPED                       = HRESULT ( (UINT(_FACDXGI) shl 16) or (02) );
  DXGI_STATUS_NO_REDIRECTION                = HRESULT ( (UINT(_FACDXGI) shl 16) or (04) );
  DXGI_STATUS_NO_DESKTOP_ACCESS             = HRESULT ( (UINT(_FACDXGI) shl 16) or (05) );
  DXGI_STATUS_GRAPHICS_VIDPN_SOURCE_IN_USE  = HRESULT ( (UINT(_FACDXGI) shl 16) or (06) );
  DXGI_STATUS_MODE_CHANGED                  = HRESULT ( (UINT(_FACDXGI) shl 16) or (07) );
  DXGI_STATUS_MODE_CHANGE_IN_PROGRESS       = HRESULT ( (UINT(_FACDXGI) shl 16) or (08) );

  DXGI_ERROR_INVALID_CALL                  = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (01) );
  DXGI_ERROR_NOT_FOUND                     = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (02) );
  DXGI_ERROR_MORE_DATA                     = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (03) );
  DXGI_ERROR_UNSUPPORTED                   = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (04) );
  DXGI_ERROR_DEVICE_REMOVED                = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (05) );
  DXGI_ERROR_DEVICE_HUNG                   = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (06) );
  DXGI_ERROR_DEVICE_RESET                  = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (07) );
  DXGI_ERROR_WAS_STILL_DRAWING             = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (10) );
  DXGI_ERROR_FRAME_STATISTICS_DISJOINT     = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (11) );
  DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE  = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (12) );
  DXGI_ERROR_DRIVER_INTERNAL_ERROR         = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (32) );
  DXGI_ERROR_NONEXCLUSIVE                  = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (33) );
  DXGI_ERROR_NOT_CURRENTLY_AVAILABLE       = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (34) );
  DXGI_ERROR_REMOTE_CLIENT_DISCONNECTED    = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (35) );
  DXGI_ERROR_REMOTE_OUTOFMEMORY            = HRESULT ( (UINT(1) shl 31) or (UINT(_FACDXGI) shl 16) or (36) );

  DXGI_RESOURCE_PRIORITY_MINIMUM  = $28000000;
  DXGI_RESOURCE_PRIORITY_LOW      = $50000000;
  DXGI_RESOURCE_PRIORITY_NORMAL   = $78000000;
  DXGI_RESOURCE_PRIORITY_HIGH     = $A0000000;
  DXGI_RESOURCE_PRIORITY_MAXIMUM  = $C8000000;

  DXGI_MAX_SWAP_CHAIN_BUFFERS    = 16;

  DXGI_CPU_ACCESS_NONE           =  0;
  DXGI_CPU_ACCESS_DYNAMIC        =  1;
  DXGI_CPU_ACCESS_READ_WRITE     =  2;
  DXGI_CPU_ACCESS_SCRATCH        =  3;
  DXGI_CPU_ACCESS_FIELD          = 15;

  // DXGI_ENUM_MODES
  DXGI_ENUM_MODES_INTERLACED  = 1;
  DXGI_ENUM_MODES_SCALING     = 2;

  // DXGI_USAGE
  DXGI_USAGE_SHADER_INPUT            = 1 shl (0 + 4);
  DXGI_USAGE_RENDER_TARGET_OUTPUT    = 1 shl (1 + 4);
  DXGI_USAGE_BACK_BUFFER             = 1 shl (2 + 4);
  DXGI_USAGE_SHARED                  = 1 shl (3 + 4);
  DXGI_USAGE_READ_ONLY               = 1 shl (4 + 4);
  DXGI_USAGE_DISCARD_ON_PRESENT      = 1 shl (5 + 4);
  DXGI_USAGE_UNORDERED_ACCESS        = 1 shl (6 + 4);

  // DXGI_SWAP_CHAIN_FLAG
  DXGI_SWAP_CHAIN_FLAG_NONPREROTATED                    = 1;
  DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH                = 2;
  DXGI_SWAP_CHAIN_FLAG_GDI_COMPATIBLE                   = 4;
  // DirectX 11.1
  DXGI_SWAP_CHAIN_FLAG_RESTRICTED_CONTENT               = 8;
  DXGI_SWAP_CHAIN_FLAG_RESTRICT_SHARED_RESOURCE_DRIVER  = 16;
  DXGI_SWAP_CHAIN_FLAG_DISPLAY_ONLY                     = 32;
  DXGI_SWAP_CHAIN_FLAG_FRAME_LATENCY_WAITABLE_OBJECT    = 64;
  DXGI_SWAP_CHAIN_FLAG_FOREGROUND_LAYER                 = 128;
  DXGI_SWAP_CHAIN_FLAG_FULLSCREEN_VIDEO                 = 256;
  DXGI_SWAP_CHAIN_FLAG_YUV_VIDEO                        = 512;

  // DXGI_MAP
  DXGI_MAP_READ     = 1;
  DXGI_MAP_WRITE    = 2;
  DXGI_MAP_DISCARD  = 4;

  // DXGI_PRESENT
  DXGI_PRESENT_TEST                   = $00000001;
  DXGI_PRESENT_DO_NOT_SEQUENCE        = $00000002;
  DXGI_PRESENT_RESTART                = $00000004;
  // DirectX 11.1, since Windows 8
  DXGI_PRESENT_DO_NOT_WAIT            = $00000008;
  DXGI_PRESENT_STEREO_PREFER_RIGHT    = $00000010;
  DXGI_PRESENT_STEREO_TEMPORARY_MONO  = $00000020;
  DXGI_PRESENT_RESTRICT_TO_OUTPUT     = $00000040;
  DXGI_PRESENT_USE_DURATION           = $00000100;

  // DXGI_ADAPTER_FLAGS
  DXGI_ADAPTER_FLAG_NONE = 0;
  DXGI_ADAPTER_FLAG_REMOTE = 1;
  // DirectX 11.1
  DXGI_ADAPTER_FLAG_SOFTWARE = 2;

  // DXGI_MWA_FLAGS
  DXGI_MWA_NO_WINDOW_CHANGES    = 1;
  DXGI_MWA_NO_ALT_ENTER         = 2;
  DXGI_MWA_NO_PRINT_SCREEN      = 4;
  DXGI_MWA_VALID                = 7;

type
  IDXGIObject = interface;
  IDXGIDeviceSubObject = interface;
  IDXGIResource = interface;
  IDXGIKeyedMutex = interface;
  IDXGISurface = interface;
  IDXGISurface1 = interface;
  IDXGIAdapter = interface;
  IDXGIOutput = interface;
  IDXGISwapChain = interface;
  IDXGIFactory = interface;
  IDXGIDevice = interface;
  IDXGIFactory1 = interface;
  IDXGIAdapter1 = interface;
  IDXGIDevice1 = interface;


  LP_IDXGIObject = ^IDXGIObject;
  LP_IDXGIDeviceSubObject = ^IDXGIDeviceSubObject;
  LP_IDXGIResource = ^IDXGIResource;
  LP_IDXGIKeyedMutex = ^IDXGIKeyedMutex;
  LP_IDXGISurface = ^IDXGISurface;
  LP_IDXGISurface1 = ^IDXGISurface1;
  LP_IDXGIAdapter = ^IDXGIAdapter;
  LP_IDXGIOutput = ^IDXGIOutput;
  LP_IDXGISwapChain = ^IDXGISwapChain;
  LP_IDXGIFactory = ^IDXGIFactory;
  LP_IDXGIDevice = ^IDXGIDevice;
  LP_IDXGIFactory1 = ^IDXGIFactory1;
  LP_IDXGIAdapter1 = ^IDXGIAdapter1;
  LP_IDXGIDevice1 = ^IDXGIDevice1;

  LP_IUnknown = ^IUnknown;


  HMONITOR = THandle;

  DXGI_ENUM_MODES = UINT;
  DXGI_USAGE = UINT;
  DXGI_SWAP_CHAIN_FLAGS = UINT;
  DXGI_MAP_FLAGS = UINT;
  DXGI_PRESENT_FLAGS = UINT;
  DXGI_ADAPTER_FLAGS = UINT;
  DXGI_MWA_FLAGS = UINT;


  DXGI_FORMAT =
  (
    DXGI_FORMAT_UNKNOWN                     = 0,
    DXGI_FORMAT_R32G32B32A32_TYPELESS       = 1,
    DXGI_FORMAT_R32G32B32A32_FLOAT          = 2,
    DXGI_FORMAT_R32G32B32A32_UINT           = 3,
    DXGI_FORMAT_R32G32B32A32_SINT           = 4,
    DXGI_FORMAT_R32G32B32_TYPELESS          = 5,
    DXGI_FORMAT_R32G32B32_FLOAT             = 6,
    DXGI_FORMAT_R32G32B32_UINT              = 7,
    DXGI_FORMAT_R32G32B32_SINT              = 8,
    DXGI_FORMAT_R16G16B16A16_TYPELESS       = 9,
    DXGI_FORMAT_R16G16B16A16_FLOAT          = 10,
    DXGI_FORMAT_R16G16B16A16_UNORM          = 11,
    DXGI_FORMAT_R16G16B16A16_UINT           = 12,
    DXGI_FORMAT_R16G16B16A16_SNORM          = 13,
    DXGI_FORMAT_R16G16B16A16_SINT           = 14,
    DXGI_FORMAT_R32G32_TYPELESS             = 15,
    DXGI_FORMAT_R32G32_FLOAT                = 16,
    DXGI_FORMAT_R32G32_UINT                 = 17,
    DXGI_FORMAT_R32G32_SINT                 = 18,
    DXGI_FORMAT_R32G8X24_TYPELESS           = 19,
    DXGI_FORMAT_D32_FLOAT_S8X24_UINT        = 20,
    DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS    = 21,
    DXGI_FORMAT_X32_TYPELESS_G8X24_UINT     = 22,
    DXGI_FORMAT_R10G10B10A2_TYPELESS        = 23,
    DXGI_FORMAT_R10G10B10A2_UNORM           = 24,
    DXGI_FORMAT_R10G10B10A2_UINT            = 25,
    DXGI_FORMAT_R11G11B10_FLOAT             = 26,
    DXGI_FORMAT_R8G8B8A8_TYPELESS           = 27,
    DXGI_FORMAT_R8G8B8A8_UNORM              = 28,
    DXGI_FORMAT_R8G8B8A8_UNORM_SRGB         = 29,
    DXGI_FORMAT_R8G8B8A8_UINT               = 30,
    DXGI_FORMAT_R8G8B8A8_SNORM              = 31,
    DXGI_FORMAT_R8G8B8A8_SINT               = 32,
    DXGI_FORMAT_R16G16_TYPELESS             = 33,
    DXGI_FORMAT_R16G16_FLOAT                = 34,
    DXGI_FORMAT_R16G16_UNORM                = 35,
    DXGI_FORMAT_R16G16_UINT                 = 36,
    DXGI_FORMAT_R16G16_SNORM                = 37,
    DXGI_FORMAT_R16G16_SINT                 = 38,
    DXGI_FORMAT_R32_TYPELESS                = 39,
    DXGI_FORMAT_D32_FLOAT                   = 40,
    DXGI_FORMAT_R32_FLOAT                   = 41,
    DXGI_FORMAT_R32_UINT                    = 42,
    DXGI_FORMAT_R32_SINT                    = 43,
    DXGI_FORMAT_R24G8_TYPELESS              = 44,
    DXGI_FORMAT_D24_UNORM_S8_UINT           = 45,
    DXGI_FORMAT_R24_UNORM_X8_TYPELESS       = 46,
    DXGI_FORMAT_X24_TYPELESS_G8_UINT        = 47,
    DXGI_FORMAT_R8G8_TYPELESS               = 48,
    DXGI_FORMAT_R8G8_UNORM                  = 49,
    DXGI_FORMAT_R8G8_UINT                   = 50,
    DXGI_FORMAT_R8G8_SNORM                  = 51,
    DXGI_FORMAT_R8G8_SINT                   = 52,
    DXGI_FORMAT_R16_TYPELESS                = 53,
    DXGI_FORMAT_R16_FLOAT                   = 54,
    DXGI_FORMAT_D16_UNORM                   = 55,
    DXGI_FORMAT_R16_UNORM                   = 56,
    DXGI_FORMAT_R16_UINT                    = 57,
    DXGI_FORMAT_R16_SNORM                   = 58,
    DXGI_FORMAT_R16_SINT                    = 59,
    DXGI_FORMAT_R8_TYPELESS                 = 60,
    DXGI_FORMAT_R8_UNORM                    = 61,
    DXGI_FORMAT_R8_UINT                     = 62,
    DXGI_FORMAT_R8_SNORM                    = 63,
    DXGI_FORMAT_R8_SINT                     = 64,
    DXGI_FORMAT_A8_UNORM                    = 65,
    DXGI_FORMAT_R1_UNORM                    = 66,
    DXGI_FORMAT_R9G9B9E5_SHAREDEXP          = 67,
    DXGI_FORMAT_R8G8_B8G8_UNORM             = 68,
    DXGI_FORMAT_G8R8_G8B8_UNORM             = 69,
    DXGI_FORMAT_BC1_TYPELESS                = 70,
    DXGI_FORMAT_BC1_UNORM                   = 71,
    DXGI_FORMAT_BC1_UNORM_SRGB              = 72,
    DXGI_FORMAT_BC2_TYPELESS                = 73,
    DXGI_FORMAT_BC2_UNORM                   = 74,
    DXGI_FORMAT_BC2_UNORM_SRGB              = 75,
    DXGI_FORMAT_BC3_TYPELESS                = 76,
    DXGI_FORMAT_BC3_UNORM                   = 77,
    DXGI_FORMAT_BC3_UNORM_SRGB              = 78,
    DXGI_FORMAT_BC4_TYPELESS                = 79,
    DXGI_FORMAT_BC4_UNORM                   = 80,
    DXGI_FORMAT_BC4_SNORM                   = 81,
    DXGI_FORMAT_BC5_TYPELESS                = 82,
    DXGI_FORMAT_BC5_UNORM                   = 83,
    DXGI_FORMAT_BC5_SNORM                   = 84,
    DXGI_FORMAT_B5G6R5_UNORM                = 85,
    DXGI_FORMAT_B5G5R5A1_UNORM              = 86,
    DXGI_FORMAT_B8G8R8A8_UNORM              = 87,
    DXGI_FORMAT_B8G8R8X8_UNORM              = 88,
    DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM  = 89,
    DXGI_FORMAT_B8G8R8A8_TYPELESS           = 90,
    DXGI_FORMAT_B8G8R8A8_UNORM_SRGB         = 91,
    DXGI_FORMAT_B8G8R8X8_TYPELESS           = 92,
    DXGI_FORMAT_B8G8R8X8_UNORM_SRGB         = 93,
    DXGI_FORMAT_BC6H_TYPELESS               = 94,
    DXGI_FORMAT_BC6H_UF16                   = 95,
    DXGI_FORMAT_BC6H_SF16                   = 96,
    DXGI_FORMAT_BC7_TYPELESS                = 97,
    DXGI_FORMAT_BC7_UNORM                   = 98,
    DXGI_FORMAT_BC7_UNORM_SRGB              = 99,

    // DirectX 11.1
    DXGI_FORMAT_AYUV                        = 100,
    DXGI_FORMAT_Y410                        = 101,
    DXGI_FORMAT_Y416                        = 102,
    DXGI_FORMAT_NV12                        = 103,
    DXGI_FORMAT_P010                        = 104,
    DXGI_FORMAT_P016                        = 105,
    DXGI_FORMAT_420_OPAQUE                  = 106,
    DXGI_FORMAT_YUY2                        = 107,
    DXGI_FORMAT_Y210                        = 108,
    DXGI_FORMAT_Y216                        = 109,
    DXGI_FORMAT_NV11                        = 110,
    DXGI_FORMAT_AI44                        = 111,
    DXGI_FORMAT_IA44                        = 112,
    DXGI_FORMAT_P8                          = 113,
    DXGI_FORMAT_A8P8                        = 114,
    DXGI_FORMAT_B4G4R4A4_UNORM              = 115,

    DXGI_FORMAT_FORCE_UINT                  = Integer($FFFFFFFF)
  );


  DXGI_RGB = record
    Red: FLOAT;
    Green: FLOAT;
    Blue: FLOAT;
  end;

  DXGI_RGBA = D3DCOLORVALUE;

  DXGI_GAMMA_CONTROL = record
    Scale: DXGI_RGB;
    Offset: DXGI_RGB;
    GammaCurve: array[0..1024] of DXGI_RGB;
  end;

  LP_DXGI_GAMMA_CONTROL_CAPABILITIES = ^DXGI_GAMMA_CONTROL_CAPABILITIES;
  DXGI_GAMMA_CONTROL_CAPABILITIES = record
    ScaleAndOffsetSupported: BOOL;
    MaxConvertedValue: FLOAT;
    MinConvertedValue: FLOAT;
    NumGammaControlPoints: UINT;
    ControlPointPositions: array[0..1024] of Single;
  end;

  DXGI_RATIONAL = record
    Numerator: UINT;
    Denominator: UINT;
  end;

  DXGI_MODE_SCANLINE_ORDER =
  (
    DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED        = 0,
    DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE        = 1,
    DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST  = 2,
    DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST  = 3
  );

  DXGI_MODE_SCALING =
  (
    DXGI_MODE_SCALING_UNSPECIFIED   = 0,
    DXGI_MODE_SCALING_CENTERED      = 1,
    DXGI_MODE_SCALING_STRETCHED     = 2
  );

  DXGI_MODE_ROTATION =
  (
    DXGI_MODE_ROTATION_UNSPECIFIED  = 0,
    DXGI_MODE_ROTATION_IDENTITY     = 1,
    DXGI_MODE_ROTATION_ROTATE90     = 2,
    DXGI_MODE_ROTATION_ROTATE180    = 3,
    DXGI_MODE_ROTATION_ROTATE270    = 4
  );

  LP_DXGI_MODE_DESC = ^DXGI_MODE_DESC;
  DXGI_MODE_DESC = record
    Width: UINT;
    Height: UINT;
    RefreshRate: DXGI_RATIONAL;
    Format: DXGI_FORMAT;
    ScanlineOrdering: DXGI_MODE_SCANLINE_ORDER;
    Scaling: DXGI_MODE_SCALING;
  end;

  DXGI_SAMPLE_DESC = record
    Count: UINT;
    Quality: UINT;
  end;

  DXGI_FRAME_STATISTICS = record
    PresentCount: UINT;
    PresentRefreshCount: UINT;
    SyncRefreshCount: UINT;
    SyncQPCTime: LARGE_INTEGER;
    SyncGPUTime: LARGE_INTEGER;
  end;

  DXGI_MAPPED_RECT = record
    Pitch: INT;
    pBits: LP_BYTE;
  end;

  LP_LUID = ^LUID;
  LUID = record
    LowPart: DWORD;
    HighPart: LONG;
  end;

  DXGI_ADAPTER_DESC = record
    Description: array[0..127] of WideChar;
    VendorId: UINT;
    DeviceId: UINT;
    SubSysId: UINT;
    Revision: UINT;
    DedicatedVideoMemory: SIZE_T;
    DedicatedSystemMemory: SIZE_T;
    SharedSystemMemory: SIZE_T;
    AdapterLuid: LUID;
  end;

  DXGI_OUTPUT_DESC = record
    DeviceName: array[0..31] of WideChar;
    DesktopCoordinates: TRect;
    AttachedToDesktop: BOOL;
    Rotation: DXGI_MODE_ROTATION;
    Monitor: HMONITOR;
  end;

  LP_DXGI_SHARED_RESOURCE = ^DXGI_SHARED_RESOURCE;
  DXGI_SHARED_RESOURCE = record
    Handle: HANDLE;
  end;

  LP_DXGI_RESIDENCY = ^DXGI_RESIDENCY;
  DXGI_RESIDENCY =
  (
    DXGI_RESIDENCY_FULLY_RESIDENT             = 1,
    DXGI_RESIDENCY_RESIDENT_IN_SHARED_MEMORY  = 2,
    DXGI_RESIDENCY_EVICTED_TO_DISK            = 3
  );

  DXGI_SURFACE_DESC = record
    Width: UINT;
    Height: UINT;
    Format: DXGI_FORMAT;
    SampleDesc: DXGI_SAMPLE_DESC;
  end;

  DXGI_SWAP_EFFECT =
  (
    DXGI_SWAP_EFFECT_DISCARD     = 0,
    DXGI_SWAP_EFFECT_SEQUENTIAL  = 1,
    // DirectX 11.1
    DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL = 3
  );

  DXGI_SWAP_CHAIN_DESC = record
    BufferDesc: DXGI_MODE_DESC;
    SampleDesc: DXGI_SAMPLE_DESC;
    BufferUsage: DXGI_USAGE;
    BufferCount: UINT;
    OutputWindow: HWND;
    Windowed: BOOL;
    SwapEffect: DXGI_SWAP_EFFECT;
    Flags: DXGI_SWAP_CHAIN_FLAGS;
  end;

  DXGI_ADAPTER_DESC1 = record
    Description: array[0..127] of WideChar;
    VendorId: UINT;
    DeviceId: UINT;
    SubSysId: UINT;
    Revision: UINT;
    DedicatedVideoMemory: SIZE_T;
    DedicatedSystemMemory: SIZE_T;
    SharedSystemMemory: SIZE_T;
    AdapterLuid: LUID;
    Flags: DXGI_ADAPTER_FLAGS;
  end;

  DXGI_DISPLAY_COLOR_SPACE = record
    PrimaryCoordinates: array[0..7, 0..1] of Single;
    WhitePoints: array[0..15, 0..1] of Single;
  end;


  IDXGIObject = interface(IUnknown)
    ['{aec22fb8-76f3-4639-9be0-28eb43a67a2e}']

    function SetPrivateData(const Name: TGUID; DataSize: UINT; pData: Pointer): HRESULT;  stdcall;
    function SetPrivateDataInterface(const Name: TGUID; pUnknown: IUnknown): HRESULT;  stdcall;

    function GetPrivateData(const Name: TGUID; var DataSize: UINT; pData: Pointer): HRESULT;  stdcall;
    function GetParent(const riid: TGUID; out pParent: Pointer): HRESULT;  stdcall;
  end;


  IDXGIDeviceSubObject = interface(IDXGIObject)
    ['{3d3e0379-f9de-4d58-bb6c-18d62992f1a6}']

    function GetDevice(const riid: TGUID; out ppDevice): HRESULT;  stdcall;
  end;

  IDXGIResource = interface(IDXGIDeviceSubObject)
    ['{035f3ab4-482e-4e50-b41f-8a7f8bd8960b}']

    function GetSharedHandle(out SharedHandle: HANDLE): HRESULT;  stdcall;
    function GetUsage(out Usage: DXGI_USAGE): HRESULT;  stdcall;

    function SetEvictionPriority(EvictionPriority: UINT): HRESULT;  stdcall;
    function GetEvictionPriority(out EvictionPriority: UINT): HRESULT;  stdcall;
  end;


  IDXGIKeyedMutex = interface(IDXGIDeviceSubObject)
    ['{9d8e1289-d7b3-465f-8126-250e349af85d}']

    function AcquireSync(Key: UInt64; dwMilliseconds: DWORD): HRESULT;  stdcall;
    function ReleaseSync(Key: UInt64): HRESULT;  stdcall;
  end;


  IDXGISurface = interface(IDXGIDeviceSubObject)
    ['{cafcb56c-6ac3-4889-bf47-9e23bbd260ec}']

    function GetDesc(out Desc: DXGI_SURFACE_DESC): HRESULT;  stdcall;
    function Map(out LockedRect: DXGI_MAPPED_RECT; MapFlags: DXGI_MAP_FLAGS): HRESULT;  stdcall;
    function Unmap(): HRESULT;  stdcall;
  end;


  IDXGISurface1 = interface(IDXGISurface)
    ['{4AE63092-6327-4c1b-80AE-BFE12EA32B86}']

    function GetDC(Discard: BOOL; out phdc: HDC): HRESULT;  stdcall;
    function ReleaseDC(pDirtyRect: PRect): HRESULT;  stdcall;
  end;


  IDXGIAdapter = interface(IDXGIObject)
    ['{2411e7e1-12ac-4ccf-bd14-9798e8534dc0}']

    function EnumOutputs(Output: UINT; out pOutput: IDXGIOutput): HRESULT;  stdcall;
    function GetDesc(out Desc: DXGI_ADAPTER_DESC): HRESULT;  stdcall;
    function CheckInterfaceSupport(const InterfaceName: TGUID; out UMDVersion: LARGE_INTEGER): HRESULT;  stdcall;
  end;


  IDXGIOutput = interface(IDXGIObject)
    ['{ae02eedb-c735-4690-8d52-5a8dc20213aa}']

    function GetDesc(out Desc: DXGI_OUTPUT_DESC): HRESULT;  stdcall;
    function GetDisplayModeList(EnumFormat: DXGI_FORMAT; Flags: DXGI_ENUM_MODES; var NumModes: UINT; pDesc: LP_DXGI_MODE_DESC): HRESULT;  stdcall;
    function FindClosestMatchingMode(const ModeToMatch: DXGI_MODE_DESC; out ClosestMatch: DXGI_MODE_DESC; pConcernedDevice: IUnknown): HRESULT;  stdcall;

    function WaitForVBlank(): HRESULT;  stdcall;

    function TakeOwnership(pDevice: IUnknown; Exclusive: BOOL): HRESULT;  stdcall;
    procedure ReleaseOwnership();  stdcall;

    function GetGammaControlCapabilities(out GammaCaps: DXGI_GAMMA_CONTROL_CAPABILITIES): HRESULT;  stdcall;
    function SetGammaControl(const pArray: DXGI_GAMMA_CONTROL): HRESULT;  stdcall;
    function GetGammaControl(out pArray: DXGI_GAMMA_CONTROL): HRESULT;  stdcall;

    function SetDisplaySurface(pScanoutSurface: IDXGISurface): HRESULT;  stdcall;
    function GetDisplaySurfaceData(pDestination: IDXGISurface): HRESULT;  stdcall;

    function GetFrameStatistics(out Stats: DXGI_FRAME_STATISTICS): HRESULT;  stdcall;
  end;


  IDXGISwapChain = interface(IDXGIDeviceSubObject)
    ['{310d36a0-d2e7-4c0a-aa04-6a9d23b8886a}']

    function Present(SyncInterval: UINT; Flags: DXGI_PRESENT_FLAGS): HRESULT;  stdcall;

    function GetBuffer(Buffer: UINT; const riid: TGUID; out pSurface): HRESULT;  stdcall;

    function SetFullscreenState(Fullscreen: BOOL; pTarget: IDXGIOutput): HRESULT;  stdcall;
    function GetFullscreenState(out Fullscreen: BOOL; out pTarget: IDXGIOutput): HRESULT;  stdcall;

    function GetDesc(out Desc: DXGI_SWAP_CHAIN_DESC): HRESULT;  stdcall;

    function ResizeBuffers(BufferCount: UINT; Width, Height: UINT; NewFormat: DXGI_FORMAT; SwapChainFlags: DXGI_SWAP_CHAIN_FLAGS): HRESULT;  stdcall;
    function ResizeTarget(const NewTargetParameters: DXGI_MODE_DESC): HRESULT;  stdcall;

    function GetContainingOutput(out pOutput: IDXGIOutput): HRESULT;  stdcall;
    function GetFrameStatistics(out Stats: DXGI_FRAME_STATISTICS): HRESULT;  stdcall;
    function GetLastPresentCount(out LastPresentCount: UINT): HRESULT;  stdcall;
  end;


  IDXGIFactory = interface(IDXGIObject)
    ['{7b7166ec-21c7-44ae-b21a-c9ae321ae369}']

    function EnumAdapters(Adapter: UINT; out pAdapter: IDXGIAdapter): HRESULT;  stdcall;

    function MakeWindowAssociation(WindowHandle: HWND; Flags: DXGI_MWA_FLAGS): HRESULT;  stdcall;
    function GetWindowAssociation(out WindowHandle: HWND): HRESULT;  stdcall;

    function CreateSwapChain(pDevice: IUnknown; const Desc: DXGI_SWAP_CHAIN_DESC; out pSwapChain: IDXGISwapChain): HRESULT;  stdcall;
    function CreateSoftwareAdapter(Module: HMODULE; out pAdapter: IDXGIAdapter): HRESULT;  stdcall;
  end;


  IDXGIDevice = interface(IDXGIObject)
    ['{54ec77fa-1377-44e6-8c32-88fd5f44c84c}']

    function GetAdapter(out pAdapter: IDXGIAdapter): HRESULT;  stdcall;

    function CreateSurface(const Desc: DXGI_SURFACE_DESC;
                           NumSurfaces: UINT; Usage: DXGI_USAGE;
                           pSharedResource: DXGI_SHARED_RESOURCE;
                           out ppSurface: IDXGISurface): HRESULT;  stdcall;

    function QueryResourceResidency(ppResources: LP_IUnknown; pResidencyStatus: LP_DXGI_RESIDENCY; NumResources: UINT): HRESULT;  stdcall;

    function SetGPUThreadPriority(Priority: INT): HRESULT;  stdcall;
    function GetGPUThreadPriority(out Priority: INT): HRESULT;  stdcall;
  end;


  IDXGIFactory1 = interface(IDXGIFactory)
    ['{770aae78-f26f-4dba-a829-253c83d1b387}']

    function EnumAdapters1(Adapter: UINT; out pAdapter: IDXGIAdapter1): HRESULT;  stdcall;
    function IsCurrent(): BOOL;  stdcall;
  end;


  IDXGIAdapter1 = interface(IDXGIAdapter)
    ['{29038f61-3839-4626-91fd-086879011a05}']

    function GetDesc1(out Desc: DXGI_ADAPTER_DESC1): HRESULT;  stdcall;
  end;


  IDXGIDevice1 = interface(IDXGIDevice)
    ['{77db970f-6276-48ba-ba28-070143b4392c}']

    function SetMaximumFrameLatency(MaxLatency: UINT): HRESULT;  stdcall;
    function GetMaximumFrameLatency(out MaxLatency: UINT): HRESULT;  stdcall;
  end;


  function CreateDXGIFactory(const riid: TGUID; out pFactory: IDXGIFactory): HRESULT;  stdcall;
  function CreateDXGIFactory1(const riid: TGUID; out pFactory: IDXGIFactory1): HRESULT;  stdcall;


  function DXGI_Rational_
           (
             Numerator: UINT = 60;
             Denominator: UINT = 1
           ): DXGI_RATIONAL;  inline;

  function DXGI_ModeDesc
           (
             Width: UINT;
             Height: UINT;
             RefreshRate: DXGI_RATIONAL;
             Format: DXGI_FORMAT;
             ScanlineOrdering: DXGI_MODE_SCANLINE_ORDER = DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
             Scaling: DXGI_MODE_SCALING = DXGI_MODE_SCALING_UNSPECIFIED
           ): DXGI_MODE_DESC;  inline;

  function DXGI_SampleDesc
           (
             Count: UINT = 1;
             Quality: UINT = 0
           ): DXGI_SAMPLE_DESC;  inline;

  function DXGI_SwapChainDesc
           (
             const BufferDesc: DXGI_MODE_DESC;
             const SampleDesc: DXGI_SAMPLE_DESC;
             OutputWindow: HWND;
             Windowed: BOOL = TRUE;
             BufferCount: UINT = 1;
             BufferUsage: DXGI_USAGE = DXGI_USAGE_RENDER_TARGET_OUTPUT;
             SwapEffect: DXGI_SWAP_EFFECT = DXGI_SWAP_EFFECT_DISCARD;
             Flags: DXGI_SWAP_CHAIN_FLAGS = 0
           ): DXGI_SWAP_CHAIN_DESC;  inline;

IMPLEMENTATION

const
  dxgi_dll = 'dxgi.dll';

function CreateDXGIFactory(const riid: TGUID; out pFactory: IDXGIFactory): HRESULT;  stdcall;
  external dxgi_dll name 'CreateDXGIFactory';
function CreateDXGIFactory1(const riid: TGUID; out pFactory: IDXGIFactory1): HRESULT;  stdcall;
  external dxgi_dll name 'CreateDXGIFactory1';


function DXGI_Rational_
         (
           Numerator: UINT;
           Denominator: UINT
         ): DXGI_RATIONAL;  inline;
begin
  Result.Numerator := Numerator;
  Result.Denominator := Denominator;
end;

function DXGI_ModeDesc
         (
           Width: UINT;
           Height: UINT;
           RefreshRate: DXGI_RATIONAL;
           Format: DXGI_FORMAT;
           ScanlineOrdering: DXGI_MODE_SCANLINE_ORDER;
           Scaling: DXGI_MODE_SCALING
         ): DXGI_MODE_DESC;  inline;
begin
  Result.Width := Width;
  Result.Height := Height;
  Result.RefreshRate := RefreshRate;
  Result.Format := Format;
  Result.ScanlineOrdering := ScanlineOrdering;
  Result.Scaling := Scaling;
end;

function DXGI_SampleDesc
         (
           Count: UINT;
           Quality: UINT
         ): DXGI_SAMPLE_DESC;  inline;
begin
  Result.Count := Count;
  Result.Quality := Quality;
end;

function DXGI_SwapChainDesc
         (
           const BufferDesc: DXGI_MODE_DESC;
           const SampleDesc: DXGI_SAMPLE_DESC;
           OutputWindow: HWND;
           Windowed: BOOL;
           BufferCount: UINT;
           BufferUsage: DXGI_USAGE;
           SwapEffect: DXGI_SWAP_EFFECT;
           Flags: DXGI_SWAP_CHAIN_FLAGS
         ): DXGI_SWAP_CHAIN_DESC;  inline;
begin
  Result.BufferDesc := BufferDesc;
  Result.SampleDesc := SampleDesc;
  Result.BufferUsage := BufferUsage;
  Result.BufferCount := BufferCount;
  Result.OutputWindow := OutputWindow;
  Result.Windowed := Windowed;
  Result.SwapEffect := SwapEffect;
  Result.Flags := Flags;
end;

END.
