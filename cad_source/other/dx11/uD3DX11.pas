UNIT uD3DX11;

INTERFACE

uses
  Windows, uDxTypes, uDXGI, uD3Dcommon, uD3D11;

{$ALIGN ON}
{$MINENUMSIZE 4}

const
  D3DX11_SDK_VERSION     = 43;

  D3DX11_DEFAULT         = (UINT(INT(-1)));
  D3DX11_FROM_FILE       = (UINT(INT(-3)));
  DXGI_FORMAT_FROM_FILE  = (DXGI_FORMAT(INT(-3)));

  _FACDD = $0876;
 // #define MAKE_HRESULT(sev,fac,code) \
 //     ((HRESULT) (((unsigned long)(sev)<<31) | ((unsigned long)(fac)<<16) | ((unsigned long)(code))) )
 // MAKE_DDHRESULT( code )  MAKE_HRESULT( 1, _FACDD, code )

  _FACD3D = $0876;
 // #define MAKE_D3DHRESULT( code )  MAKE_HRESULT( 1, _FACD3D, code )
 // #define MAKE_D3DSTATUS( code )  MAKE_HRESULT( 0, _FACD3D, code )

  D3DERR_INVALIDCALL      = ( 1 shl 31 ) or ( _FACD3D shl 16 ) or ( 2156 );
  D3DERR_WASSTILLDRAWING  = ( 1 shl 31 ) or ( _FACD3D shl 16 ) or (  540 );

type
  ID3DX11DataLoader = interface;
  ID3DX11DataProcessor = interface;
  ID3DX11ThreadPump = interface;


  LP_HRESULT = ^HRESULT;

  D3DX11_ERR =
  (
    D3DX11_ERR_CANNOT_MODIFY_INDEX_BUFFER  = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2900),
    D3DX11_ERR_INVALID_MESH                = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2901),
    D3DX11_ERR_CANNOT_ATTR_SORT            = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2902),
    D3DX11_ERR_SKINNING_NOT_SUPPORTED      = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2903),
    D3DX11_ERR_TOO_MANY_INFLUENCES         = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2904),
    D3DX11_ERR_INVALID_DATA                = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2905),
    D3DX11_ERR_LOADED_MESH_HAS_NO_DATA     = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2906),
    D3DX11_ERR_DUPLICATE_NAMED_FRAGMENT    = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2907),
    D3DX11_ERR_CANNOT_REMOVE_LAST_ITEM     = ( 1 shl 31 ) or ( _FACDD shl 16 ) or (2908)
  );

//----------------------------------------------------------------------------
// D3DX11_FILTER flags:
// ------------------
//
// A valid filter must contain one of these values:
//
//  D3DX11_FILTER_NONE
//      No scaling or filtering will take place.  Pixels outside the bounds
//      of the source image are assumed to be transparent black.
//  D3DX11_FILTER_POINT
//      Each destination pixel is computed by sampling the nearest pixel
//      from the source image.
//  D3DX11_FILTER_LINEAR
//      Each destination pixel is computed by linearly interpolating between
//      the nearest pixels in the source image.  This filter works best
//      when the scale on each axis is less than 2.
//  D3DX11_FILTER_TRIANGLE
//      Every pixel in the source image contributes equally to the
//      destination image.  This is the slowest of all the filters.
//  D3DX11_FILTER_BOX
//      Each pixel is computed by averaging a 2x2(x2) box pixels from
//      the source image. Only works when the dimensions of the
//      destination are half those of the source. (as with mip maps)
//
// And can be OR'd with any of these optional flags:
//
//  D3DX11_FILTER_MIRROR_U
//      Indicates that pixels off the edge of the texture on the U-axis
//      should be mirrored, not wraped.
//  D3DX11_FILTER_MIRROR_V
//      Indicates that pixels off the edge of the texture on the V-axis
//      should be mirrored, not wraped.
//  D3DX11_FILTER_MIRROR_W
//      Indicates that pixels off the edge of the texture on the W-axis
//      should be mirrored, not wraped.
//  D3DX11_FILTER_MIRROR
//      Same as specifying D3DX11_FILTER_MIRROR_U | D3DX11_FILTER_MIRROR_V |
//      D3DX11_FILTER_MIRROR_V
//  D3DX11_FILTER_DITHER
//      Dithers the resulting image using a 4x4 order dither pattern.
//  D3DX11_FILTER_SRGB_IN
//      Denotes that the input data is in sRGB (gamma 2.2) colorspace.
//  D3DX11_FILTER_SRGB_OUT
//      Denotes that the output data is in sRGB (gamma 2.2) colorspace.
//  D3DX11_FILTER_SRGB
//      Same as specifying D3DX11_FILTER_SRGB_IN | D3DX11_FILTER_SRGB_OUT
//
//----------------------------------------------------------------------------

  D3DX11_FILTER_FLAG =
  (
    D3DX11_FILTER_NONE             =   (1 shl 0),
    D3DX11_FILTER_POINT            =   (2 shl 0),
    D3DX11_FILTER_LINEAR           =   (3 shl 0),
    D3DX11_FILTER_TRIANGLE         =   (4 shl 0),
    D3DX11_FILTER_BOX              =   (5 shl 0),

    D3DX11_FILTER_MIRROR_U         =   (1 shl 16),
    D3DX11_FILTER_MIRROR_V         =   (2 shl 16),
    D3DX11_FILTER_MIRROR_W         =   (4 shl 16),
    D3DX11_FILTER_MIRROR           =   (7 shl 16),

    D3DX11_FILTER_DITHER           =   (1 shl 19),
    D3DX11_FILTER_DITHER_DIFFUSION =   (2 shl 19),

    D3DX11_FILTER_SRGB_IN          =   (1 shl 21),
    D3DX11_FILTER_SRGB_OUT         =   (2 shl 21),
    D3DX11_FILTER_SRGB             =   (3 shl 21)
  );

//----------------------------------------------------------------------------
// D3DX11_NORMALMAP flags:
// ---------------------
// These flags are used to control how D3DX11ComputeNormalMap generates normal
// maps.  Any number of these flags may be OR'd together in any combination.
//
//  D3DX11_NORMALMAP_MIRROR_U
//      Indicates that pixels off the edge of the texture on the U-axis
//      should be mirrored, not wraped.
//  D3DX11_NORMALMAP_MIRROR_V
//      Indicates that pixels off the edge of the texture on the V-axis
//      should be mirrored, not wraped.
//  D3DX11_NORMALMAP_MIRROR
//      Same as specifying D3DX11_NORMALMAP_MIRROR_U | D3DX11_NORMALMAP_MIRROR_V
//  D3DX11_NORMALMAP_INVERTSIGN
//      Inverts the direction of each normal
//  D3DX11_NORMALMAP_COMPUTE_OCCLUSION
//      Compute the per pixel Occlusion term and encodes it into the alpha.
//      An Alpha of 1 means that the pixel is not obscured in anyway, and
//      an alpha of 0 would mean that the pixel is completly obscured.
//
//----------------------------------------------------------------------------

  D3DX11_NORMALMAP_FLAG =
  (
    D3DX11_NORMALMAP_MIRROR_U            =   (1 shl 16),
    D3DX11_NORMALMAP_MIRROR_V            =   (2 shl 16),
    D3DX11_NORMALMAP_MIRROR              =   (3 shl 16),
    D3DX11_NORMALMAP_INVERTSIGN          =   (8 shl 16),
    D3DX11_NORMALMAP_COMPUTE_OCCLUSION   =   (16 shl 16)
  );

//----------------------------------------------------------------------------
// D3DX11_CHANNEL flags:
// -------------------
// These flags are used by functions which operate on or more channels
// in a texture.
//
// D3DX11_CHANNEL_RED
//     Indicates the red channel should be used
// D3DX11_CHANNEL_BLUE
//     Indicates the blue channel should be used
// D3DX11_CHANNEL_GREEN
//     Indicates the green channel should be used
// D3DX11_CHANNEL_ALPHA
//     Indicates the alpha channel should be used
// D3DX11_CHANNEL_LUMINANCE
//     Indicates the luminaces of the red green and blue channels should be
//     used.
//
//----------------------------------------------------------------------------

  D3DX11_CHANNEL_FLAG =
  (
    D3DX11_CHANNEL_RED           =    (1 shl 0),
    D3DX11_CHANNEL_BLUE          =    (1 shl 1),
    D3DX11_CHANNEL_GREEN         =    (1 shl 2),
    D3DX11_CHANNEL_ALPHA         =    (1 shl 3),
    D3DX11_CHANNEL_LUMINANCE     =    (1 shl 4)
  );

//----------------------------------------------------------------------------
// D3DX11_IMAGE_FILE_FORMAT:
// ---------------------
// This enum is used to describe supported image file formats.
//
//----------------------------------------------------------------------------

  D3DX11_IMAGE_FILE_FORMAT =
  (
    D3DX11_IFF_BMP          = 0,
    D3DX11_IFF_JPG          = 1,
    D3DX11_IFF_PNG          = 3,
    D3DX11_IFF_DDS          = 4,
    D3DX11_IFF_TIFF         = 10,
    D3DX11_IFF_GIF          = 11,
    D3DX11_IFF_WMP          = 12,
    D3DX11_IFF_FORCE_DWORD  = $7FFFFFFF
  );

//----------------------------------------------------------------------------
// D3DX11_SAVE_TEXTURE_FLAG:
// ---------------------
// This enum is used to support texture saving options.
//
//----------------------------------------------------------------------------

  D3DX11_SAVE_TEXTURE_FLAG =
  (
    D3DX11_STF_USEINPUTBLOB = $0001
  );

//----------------------------------------------------------------------------
// D3DX11_IMAGE_INFO:
// ---------------
// This structure is used to return a rough description of what the
// the original contents of an image file looked like.
//
//  Width
//      Width of original image in pixels
//  Height
//      Height of original image in pixels
//  Depth
//      Depth of original image in pixels
//  ArraySize
//      Array size in textures
//  MipLevels
//      Number of mip levels in original image
//  MiscFlags
//      Miscellaneous flags
//  Format
//      D3D format which most closely describes the data in original image
//  ResourceDimension
//      D3D11_RESOURCE_DIMENSION representing the dimension of texture stored in the file.
//      D3D11_RESOURCE_DIMENSION_TEXTURE1D, 2D, 3D
//  ImageFileFormat
//      D3DX11_IMAGE_FILE_FORMAT representing the format of the image file.
//----------------------------------------------------------------------------

  LP_D3DX11_IMAGE_INFO = ^D3DX11_IMAGE_INFO;
  D3DX11_IMAGE_INFO = record
    Width: UINT;
    Height: UINT;
    Depth: UINT;
    ArraySize: UINT;
    MipLevels: UINT;
    MiscFlags: UINT;
    Format: DXGI_FORMAT;
    ResourceDimension: D3D11_RESOURCE_DIMENSION;
    ImageFileFormat: D3DX11_IMAGE_FILE_FORMAT;
  end;

//////////////////////////////////////////////////////////////////////////////
// Image File APIs ///////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// D3DX11_IMAGE_LOAD_INFO:
// ---------------
// This structure can be optionally passed in to texture loader APIs to
// control how textures get loaded. Pass in D3DX11_DEFAULT for any of these
// to have D3DX automatically pick defaults based on the source file.
//
//  Width
//      Rescale texture to Width texels wide
//  Height
//      Rescale texture to Height texels high
//  Depth
//      Rescale texture to Depth texels deep
//  FirstMipLevel
//      First mip level to load
//  MipLevels
//      Number of mip levels to load after the first level
//  Usage
//      D3D11_USAGE flag for the new texture
//  BindFlags
//      D3D11 Bind flags for the new texture
//  CpuAccessFlags
//      D3D11 CPU Access flags for the new texture
//  MiscFlags
//      Reserved. Must be 0
//  Format
//      Resample texture to the specified format
//  Filter
//      Filter the texture using the specified filter (only when resampling)
//  MipFilter
//      Filter the texture mip levels using the specified filter (only if
//      generating mips)
//  pSrcInfo
//      (optional) pointer to a D3DX11_IMAGE_INFO structure that will get
//      populated with source image information
//----------------------------------------------------------------------------

  LP_D3DX11_IMAGE_LOAD_INFO = ^D3DX11_IMAGE_LOAD_INFO;
  D3DX11_IMAGE_LOAD_INFO = record
    Width: UINT;
    Height: UINT;
    Depth: UINT;
    FirstMipLevel: UINT;
    MipLevels: UINT;
    Usage: D3D11_USAGE;
    BindFlags: UINT;
    CpuAccessFlags: UINT;
    MiscFlags: UINT;
    Format: DXGI_FORMAT;
    Filter: UINT;
    MipFilter: UINT;
    pSrcInfo: LP_D3DX11_IMAGE_INFO;
  end;

  LP_D3DX11_TEXTURE_LOAD_INFO = ^D3DX11_TEXTURE_LOAD_INFO;
  D3DX11_TEXTURE_LOAD_INFO = record
    pSrcBox: LP_D3D11_BOX;
    pDstBox: LP_D3D11_BOX;
    SrcFirstMip: UINT;
    DstFirstMip: UINT;
    NumMips: UINT;
    SrcFirstElement: UINT;
    DstFirstElement: UINT;
    NumElements: UINT;
    Filter: UINT;
    MipFilter: UINT;
  end;


  ID3DX11DataLoader = interface(IUnknown)
    function Load(): HRESULT;  stdcall;
    function Decompress(out pData: Pointer; pcBytes: LP_SIZE_T): HRESULT;  stdcall;
    function Destroy(): HRESULT;  stdcall;
  end;

  ID3DX11DataProcessor = interface(IUnknown)
    function Process(pData: Pointer; cBytes: SIZE_T): HRESULT;  stdcall;
    function CreateDeviceObject(out ppDataObject: Pointer): HRESULT;  stdcall;
    function Destroy(): HRESULT;  stdcall;
  end;

  ID3DX11ThreadPump = interface(IUnknown)
    ['{C93FECFA-6967-478a-ABBC-402D90621FCB}']

    function AddWorkItem(pDataLoader: ID3DX11DataLoader; pDataProcessor: ID3DX11DataProcessor; pHResult: LP_HRESULT; out ppDeviceObject: Pointer): HRESULT;  stdcall;
    function GetWorkItemCount(): UINT;  stdcall;

    function WaitForAllItems(): HRESULT;  stdcall;
    function ProcessDeviceWorkItems(iWorkItemCount: UINT): HRESULT;  stdcall;

    function PurgeAllItems(): HRESULT;  stdcall;
    function GetQueueStatus(pIoQueue, pProcessQueue, pDeviceQueue: LP_UINT): HRESULT;  stdcall;
  end;



  function D3DX11CheckVersion(D3DSdkVersion, D3DX11SdkVersion: UINT): HRESULT;  stdcall;
  function D3DX11DebugMute(Mute: BOOL): BOOL;  stdcall;
  function D3DX11CreateThreadPump(cIoThreads, cProcThreads: UINT; out pThreadPump: ID3DX11ThreadPump): HRESULT;  stdcall;
  function D3DX11UnsetAllDeviceObjects(pContext: ID3D11DeviceContext): HRESULT;  stdcall;

//-------------------------------------------------------------------------------
// GetImageInfoFromFile/Resource/Memory:
// ------------------------------
// Fills in a D3DX11_IMAGE_INFO struct with information about an image file.
//
// Parameters:
//  pSrcFile
//      File name of the source image.
//  pSrcModule
//      Module where resource is located, or NULL for module associated
//      with image the os used to create the current process.
//  pSrcResource
//      Resource name.
//  pSrcData
//      Pointer to file in memory.
//  SrcDataSize
//      Size in bytes of file in memory.
//  pPump
//      Optional pointer to a thread pump object to use.
//  pSrcInfo
//      Pointer to a D3DX11_IMAGE_INFO structure to be filled in with the
//      description of the data in the source image file.
//  pHResult
//      Pointer to a memory location to receive the return value upon completion.
//      Maybe NULL if not needed.
//      If pPump != NULL, pHResult must be a valid memory location until the
//      the asynchronous execution completes.
//-------------------------------------------------------------------------------

  function D3DX11GetImageInfoFromFileA
           (
             pSrcFile: LPCSTR;
             pPump: ID3DX11ThreadPump;
             out SrcInfo: D3DX11_IMAGE_INFO;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11GetImageInfoFromFileW
           (
             pSrcFile: LPCWSTR;
             pPump: ID3DX11ThreadPump;
             out pSrcInfo: D3DX11_IMAGE_INFO;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11GetImageInfoFromResourceA
           (
             hSrcModule: HMODULE;
             pSrcResource: LPCSTR;
             pPump: ID3DX11ThreadPump;
             out SrcInfo: D3DX11_IMAGE_INFO;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11GetImageInfoFromResourceW
           (
             hSrcModule: HMODULE;
             pSrcResource: LPCWSTR;
             pPump: ID3DX11ThreadPump;
             out SrcInfo: D3DX11_IMAGE_INFO;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11GetImageInfoFromMemory
           (
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             pPump: ID3DX11ThreadPump;
             out SrcInfo: D3DX11_IMAGE_INFO;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

//////////////////////////////////////////////////////////////////////////////
// Create/Save Texture APIs //////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// D3DX11CreateTextureFromFile/Resource/Memory:
// D3DX11CreateShaderResourceViewFromFile/Resource/Memory:
// -----------------------------------
// Create a texture object from a file or resource.
//
// Parameters:
//
//  pDevice
//      The D3D device with which the texture is going to be used.
//  pSrcFile
//      File name.
//  hSrcModule
//      Module handle. if NULL, current module will be used.
//  pSrcResource
//      Resource name in module
//  pvSrcData
//      Pointer to file in memory.
//  SrcDataSize
//      Size in bytes of file in memory.
//  pLoadInfo
//      Optional pointer to a D3DX11_IMAGE_LOAD_INFO structure that
//      contains additional loader parameters.
//  pPump
//      Optional pointer to a thread pump object to use.
//  ppTexture
//      [out] Created texture object.
//  ppShaderResourceView
//      [out] Shader resource view object created.
//  pHResult
//      Pointer to a memory location to receive the return value upon completion.
//      Maybe NULL if not needed.
//      If pPump != NULL, pHResult must be a valid memory location until the
//      the asynchronous execution completes.
//
//----------------------------------------------------------------------------


// FromFile

  function D3DX11CreateShaderResourceViewFromFileA
           (
             pDevice: ID3D11Device;
             pSrcFile: LPCSTR;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pShaderResourceView: ID3D11ShaderResourceView;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CreateShaderResourceViewFromFileW
           (
             pDevice: ID3D11Device;
             pSrcFile: LPCWSTR;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pShaderResourceView: ID3D11ShaderResourceView;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CreateTextureFromFileA
           (
             pDevice: ID3D11Device;
             pSrcFile: LPCSTR;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pTexture: ID3D11Resource;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CreateTextureFromFileW
           (
             pDevice: ID3D11Device;
             pSrcFile: LPCWSTR;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pTexture: ID3D11Resource;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

// FromResource (resources in dll/exes)

  function D3DX11CreateShaderResourceViewFromResourceA
           (
             pDevice: ID3D11Device;
             hSrcModule: HMODULE;
             pSrcResource: LPCSTR;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pShaderResourceView: ID3D11ShaderResourceView;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CreateShaderResourceViewFromResourceW
           (
             pDevice: ID3D11Device;
             hSrcModule: HMODULE;
             pSrcResource: LPCWSTR;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pShaderResourceView: ID3D11ShaderResourceView;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CreateTextureFromResourceA
           (
             pDevice: ID3D11Device;
             hSrcModule: HMODULE;
             pSrcResource: LPCSTR;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pTexture: ID3D11Resource;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CreateTextureFromResourceW
           (
             pDevice: ID3D11Device;
             hSrcModule: HMODULE;
             pSrcResource: LPCWSTR;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pTexture: ID3D11Resource;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

// FromFileInMemory

  function D3DX11CreateShaderResourceViewFromMemory
           (
             pDevice: ID3D11Device;
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pShaderResourceView: ID3D11ShaderResourceView;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CreateTextureFromMemory
           (
             pDevice: ID3D11Device;
             pSrcData: Pointer;
             SrcDataSize: SIZE_T;
             pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
             pPump: ID3DX11ThreadPump;
             out pTexture: ID3D11Resource;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

//////////////////////////////////////////////////////////////////////////////
// Misc Texture APIs /////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// D3DX11LoadTextureFromTexture:
// ----------------------------
// Load a texture from a texture.
//
// Parameters:
//
//----------------------------------------------------------------------------

  function D3DX11LoadTextureFromTexture
           (
             pContext: ID3D11DeviceContext;
             pSrcTexture: ID3D11Resource;
             pLoadInfo: LP_D3DX11_TEXTURE_LOAD_INFO;
             pDstTexture: ID3D11Resource
           ): HRESULT;  stdcall;

//----------------------------------------------------------------------------
// D3DX11FilterTexture:
// ------------------
// Filters mipmaps levels of a texture.
//
// Parameters:
//  pBaseTexture
//      The texture object to be filtered
//  SrcLevel
//      The level whose image is used to generate the subsequent levels.
//  MipFilter
//      D3DX11_FILTER flags controlling how each miplevel is filtered.
//      Or D3DX11_DEFAULT for D3DX11_FILTER_BOX,
//
//----------------------------------------------------------------------------

  function D3DX11FilterTexture
           (
             pContext: ID3D11DeviceContext;
             pTexture: ID3D11Resource;
             SrcLevel: UINT;
             MipFilter: UINT
           ): HRESULT;  stdcall;

//----------------------------------------------------------------------------
// D3DX11SaveTextureToFile:
// ----------------------
// Save a texture to a file.
//
// Parameters:
//  pDestFile
//      File name of the destination file
//  DestFormat
//      D3DX11_IMAGE_FILE_FORMAT specifying file format to use when saving.
//  pSrcTexture
//      Source texture, containing the image to be saved
//
//----------------------------------------------------------------------------

  function D3DX11SaveTextureToFileA
           (
             pContext: ID3D11DeviceContext;
             pSrcTexture: ID3D11Resource;
             DestFormat: D3DX11_IMAGE_FILE_FORMAT;
             pDestFile: LPCSTR
           ): HRESULT;  stdcall;

  function D3DX11SaveTextureToFileW
           (
             pContext: ID3D11DeviceContext;
             pSrcTexture: ID3D11Resource;
             DestFormat: D3DX11_IMAGE_FILE_FORMAT;
             pDestFile: LPCWSTR
           ): HRESULT;  stdcall;

//----------------------------------------------------------------------------
// D3DX11SaveTextureToMemory:
// ----------------------
// Save a texture to a blob.
//
// Parameters:
//  pSrcTexture
//      Source texture, containing the image to be saved
//  DestFormat
//      D3DX11_IMAGE_FILE_FORMAT specifying file format to use when saving.
//  ppDestBuf
//      address of a d3dxbuffer pointer to return the image data
//  Flags
//      optional flags
//----------------------------------------------------------------------------

  function D3DX11SaveTextureToMemory
           (
             pContext: ID3D11DeviceContext;
             pSrcTexture: ID3D11Resource;
             DestFormat: D3DX11_IMAGE_FILE_FORMAT;
             out pDestBuf: ID3DBlob;
             Flags: UINT
           ): HRESULT;  stdcall;

//----------------------------------------------------------------------------
// D3DX11ComputeNormalMap:
// ---------------------
// Converts a height map into a normal map.  The (x,y,z) components of each
// normal are mapped to the (r,g,b) channels of the output texture.
//
// Parameters
//  pSrcTexture
//      Pointer to the source heightmap texture
//  Flags
//      D3DX11_NORMALMAP flags
//  Channel
//      D3DX11_CHANNEL specifying source of height information
//  Amplitude
//      The constant value which the height information is multiplied by.
//  pDestTexture
//      Pointer to the destination texture
//---------------------------------------------------------------------------

  function D3DX11ComputeNormalMap
           (
             pContext: ID3D11DeviceContext;
             pSrcTexture: ID3D11Texture2D;
             Flags: UINT;
             Channel: UINT;
             Amplitude: FLOAT;
             pDestTexture: ID3D11Texture2D
           ): HRESULT;  stdcall;

//----------------------------------------------------------------------------
// D3DX11SHProjectCubeMap:
// ----------------------
//  Projects a function represented in a cube map into spherical harmonics.
//
//  Parameters:
//   Order
//      Order of the SH evaluation, generates Order^2 coefs, degree is Order-1
//   pCubeMap
//      CubeMap that is going to be projected into spherical harmonics
//   pROut
//      Output SH vector for Red.
//   pGOut
//      Output SH vector for Green
//   pBOut
//      Output SH vector for Blue
//
//---------------------------------------------------------------------------

  function D3DX11SHProjectCubeMap
           (
             pContext: ID3D11DeviceContext;
             Order: UINT;
             pCubeMap: ID3D11Texture2D;
             pROut: LP_FLOAT;
             pGOut: LP_FLOAT;
             pBOut: LP_FLOAT
           ): HRESULT;  stdcall;

//----------------------------------------------------------------------------
// D3DX11Compile:
// ------------------
// Compiles an effect or shader.
//
// Parameters:
//  pSrcFile
//      Source file name.
//  hSrcModule
//      Module handle. if NULL, current module will be used.
//  pSrcResource
//      Resource name in module.
//  pSrcData
//      Pointer to source code.
//  SrcDataLen
//      Size of source code, in bytes.
//  pDefines
//      Optional NULL-terminated array of preprocessor macro definitions.
//  pInclude
//      Optional interface pointer to use for handling #include directives.
//      If this parameter is NULL, #includes will be honored when compiling
//      from file, and will error when compiling from resource or memory.
//  pFunctionName
//      Name of the entrypoint function where execution should begin.
//  pProfile
//      Instruction set to be used when generating code.  Currently supported
//      profiles are "vs_1_1",  "vs_2_0", "vs_2_a", "vs_2_sw", "vs_3_0",
//                   "vs_3_sw", "vs_4_0", "vs_4_1",
//                   "ps_2_0",  "ps_2_a", "ps_2_b", "ps_2_sw", "ps_3_0",
//                   "ps_3_sw", "ps_4_0", "ps_4_1",
//                   "gs_4_0",  "gs_4_1",
//                   "tx_1_0",
//                   "fx_4_0",  "fx_4_1"
//      Note that this entrypoint does not compile fx_2_0 targets, for that
//      you need to use the D3DX9 function.
//  Flags1
//      See D3D10_SHADER_xxx flags.
//  Flags2
//      See D3D10_EFFECT_xxx flags.
//  ppShader
//      Returns a buffer containing the created shader.  This buffer contains
//      the compiled shader code, as well as any embedded debug and symbol
//      table info.  (See D3D10GetShaderConstantTable)
//  ppErrorMsgs
//      Returns a buffer containing a listing of errors and warnings that were
//      encountered during the compile.  If you are running in a debugger,
//      these are the same messages you will see in your debug output.
//  pHResult
//      Pointer to a memory location to receive the return value upon completion.
//      Maybe NULL if not needed.
//      If pPump != NULL, pHResult must be a valid memory location until the
//      the asynchronous execution completes.
//----------------------------------------------------------------------------

  function D3DX11CompileFromFileA
           (
             pSrcFile: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pFunctionName: LPCSTR; pProfile: LPCSTR;
             Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
             out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CompileFromFileW
           (
             pSrcFile: LPCWSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pFunctionName: LPCSTR; pProfile: LPCSTR;
             Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
             out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CompileFromResourceA
           (
             hSrcModule: HMODULE; pSrcResource: LPCSTR;
             pSrcFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pFunctionName: LPCSTR; pProfile: LPCSTR;
             Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
             out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CompileFromResourceW
           (
             hSrcModule: HMODULE; pSrcResource: LPCWSTR;
             pSrcFileName: LPCWSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pFunctionName: LPCSTR; pProfile: LPCSTR;
             Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
             out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11CompileFromMemory
           (
             pSrcData: LPCSTR; SrcDataLen: SIZE_T;
             pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pFunctionName: LPCSTR; pProfile: LPCSTR;
             Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
             out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11PreprocessShaderFromFileA
           (
             pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pPump: ID3DX11ThreadPump;
             out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11PreprocessShaderFromFileW
           (
             pFileName: LPCWSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pPump: ID3DX11ThreadPump;
             out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11PreprocessShaderFromMemory
           (
             pSrcData: LPCSTR; SrcDataSize: SIZE_T;
             pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pPump: ID3DX11ThreadPump;
             out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11PreprocessShaderFromResourceA
           (
             hModule: HMODULE; pResourceName: LPCSTR;
             pSrcFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pPump: ID3DX11ThreadPump;
             out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

  function D3DX11PreprocessShaderFromResourceW
           (
             hModule: HMODULE; pResourceName: LPCWSTR;
             pSrcFileName: LPCWSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pPump: ID3DX11ThreadPump;
             out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
             pHResult: LP_HRESULT
           ): HRESULT;  stdcall;

//----------------------------------------------------------------------------
// Async processors
//----------------------------------------------------------------------------

  function D3DX11CreateAsyncCompilerProcessor
           (
             pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             pFunctionName: LPCSTR; pProfile: LPCSTR;
             Flags1, Flags2: UINT;
             out pCompileShader: ID3DBlob; ppErrorBuffer: LP_ID3DBlob;
             out pProcessor: ID3DX11DataProcessor
           ): HRESULT;  stdcall;

  function D3DX11CreateAsyncShaderPreprocessProcessor
           (
             pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
             out pShaderText: ID3DBlob; ppErrorBuffer: LP_ID3DBlob;
             out pProcessor: ID3DX11DataProcessor
           ): HRESULT;  stdcall;

//----------------------------------------------------------------------------
// D3DX11 Asynchronous texture I/O (advanced mode)
//----------------------------------------------------------------------------

  function D3DX11CreateAsyncFileLoaderA(pFileName: LPCSTR; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  function D3DX11CreateAsyncFileLoaderW(pFileName: LPCWSTR; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  function D3DX11CreateAsyncMemoryLoader(pData: Pointer; cbData: SIZE_T; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  function D3DX11CreateAsyncResourceLoaderA(hSrcModule: HMODULE; pSrcResource: LPCSTR; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  function D3DX11CreateAsyncResourceLoaderW(hSrcModule: HMODULE; pSrcResource: LPCWSTR; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;

  function D3DX11CreateAsyncTextureProcessor(pDevice: ID3D11Device; pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO; out pDataProcessor: ID3DX11DataProcessor): HRESULT;  stdcall;
  function D3DX11CreateAsyncTextureInfoProcessor(pImageInfo: LP_D3DX11_IMAGE_INFO; out pDataProcessor: ID3DX11DataProcessor): HRESULT;  stdcall;
  function D3DX11CreateAsyncShaderResourceViewProcessor(pDevice: ID3D11Device; pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO; out pDataProcessor: ID3DX11DataProcessor): HRESULT;  stdcall;


IMPLEMENTATION

const
  d3dx11_dll = 'd3dx11_43.dll';

function D3DX11CheckVersion(D3DSdkVersion, D3DX11SdkVersion: UINT): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CheckVersion';
function D3DX11DebugMute(Mute: BOOL): BOOL;  stdcall;
  external d3dx11_dll name 'D3DX11DebugMute';
function D3DX11CreateThreadPump(cIoThreads, cProcThreads: UINT; out pThreadPump: ID3DX11ThreadPump): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateThreadPump';
function D3DX11UnsetAllDeviceObjects(pContext: ID3D11DeviceContext): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11UnsetAllDeviceObjects';

function D3DX11GetImageInfoFromFileA
         (
           pSrcFile: LPCSTR;
           pPump: ID3DX11ThreadPump;
           out SrcInfo: D3DX11_IMAGE_INFO;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11GetImageInfoFromFileA';

function D3DX11GetImageInfoFromFileW
         (
           pSrcFile: LPCWSTR;
           pPump: ID3DX11ThreadPump;
           out pSrcInfo: D3DX11_IMAGE_INFO;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11GetImageInfoFromFileW';

function D3DX11GetImageInfoFromResourceA
         (
           hSrcModule: HMODULE;
           pSrcResource: LPCSTR;
           pPump: ID3DX11ThreadPump;
           out SrcInfo: D3DX11_IMAGE_INFO;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11GetImageInfoFromResourceA';

function D3DX11GetImageInfoFromResourceW
         (
           hSrcModule: HMODULE;
           pSrcResource: LPCWSTR;
           pPump: ID3DX11ThreadPump;
           out SrcInfo: D3DX11_IMAGE_INFO;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11GetImageInfoFromResourceW';

function D3DX11GetImageInfoFromMemory
         (
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           pPump: ID3DX11ThreadPump;
           out SrcInfo: D3DX11_IMAGE_INFO;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11GetImageInfoFromMemory';

function D3DX11CreateShaderResourceViewFromFileA
         (
           pDevice: ID3D11Device;
           pSrcFile: LPCSTR;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pShaderResourceView: ID3D11ShaderResourceView;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateShaderResourceViewFromFileA';

function D3DX11CreateShaderResourceViewFromFileW
         (
           pDevice: ID3D11Device;
           pSrcFile: LPCWSTR;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pShaderResourceView: ID3D11ShaderResourceView;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateShaderResourceViewFromFileW';

function D3DX11CreateTextureFromFileA
         (
           pDevice: ID3D11Device;
           pSrcFile: LPCSTR;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pTexture: ID3D11Resource;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateTextureFromFileA';

function D3DX11CreateTextureFromFileW
         (
           pDevice: ID3D11Device;
           pSrcFile: LPCWSTR;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pTexture: ID3D11Resource;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateTextureFromFileW';

function D3DX11CreateShaderResourceViewFromResourceA
         (
           pDevice: ID3D11Device;
           hSrcModule: HMODULE;
           pSrcResource: LPCSTR;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pShaderResourceView: ID3D11ShaderResourceView;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateShaderResourceViewFromResourceA';

function D3DX11CreateShaderResourceViewFromResourceW
         (
           pDevice: ID3D11Device;
           hSrcModule: HMODULE;
           pSrcResource: LPCWSTR;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pShaderResourceView: ID3D11ShaderResourceView;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateShaderResourceViewFromResourceW';

function D3DX11CreateTextureFromResourceA
         (
           pDevice: ID3D11Device;
           hSrcModule: HMODULE;
           pSrcResource: LPCSTR;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pTexture: ID3D11Resource;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateTextureFromResourceA';

function D3DX11CreateTextureFromResourceW
         (
           pDevice: ID3D11Device;
           hSrcModule: HMODULE;
           pSrcResource: LPCWSTR;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pTexture: ID3D11Resource;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateTextureFromResourceW';

function D3DX11CreateShaderResourceViewFromMemory
         (
           pDevice: ID3D11Device;
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pShaderResourceView: ID3D11ShaderResourceView;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateShaderResourceViewFromMemory';

function D3DX11CreateTextureFromMemory
         (
           pDevice: ID3D11Device;
           pSrcData: Pointer;
           SrcDataSize: SIZE_T;
           pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO;
           pPump: ID3DX11ThreadPump;
           out pTexture: ID3D11Resource;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateTextureFromMemory';

function D3DX11LoadTextureFromTexture
         (
           pContext: ID3D11DeviceContext;
           pSrcTexture: ID3D11Resource;
           pLoadInfo: LP_D3DX11_TEXTURE_LOAD_INFO;
           pDstTexture: ID3D11Resource
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11LoadTextureFromTexture';

function D3DX11FilterTexture
         (
           pContext: ID3D11DeviceContext;
           pTexture: ID3D11Resource;
           SrcLevel: UINT;
           MipFilter: UINT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11FilterTexture';

function D3DX11SaveTextureToFileA
         (
           pContext: ID3D11DeviceContext;
           pSrcTexture: ID3D11Resource;
           DestFormat: D3DX11_IMAGE_FILE_FORMAT;
           pDestFile: LPCSTR
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11SaveTextureToFileA';

function D3DX11SaveTextureToFileW
         (
           pContext: ID3D11DeviceContext;
           pSrcTexture: ID3D11Resource;
           DestFormat: D3DX11_IMAGE_FILE_FORMAT;
           pDestFile: LPCWSTR
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11SaveTextureToFileW';

function D3DX11SaveTextureToMemory
         (
           pContext: ID3D11DeviceContext;
           pSrcTexture: ID3D11Resource;
           DestFormat: D3DX11_IMAGE_FILE_FORMAT;
           out pDestBuf: ID3DBlob;
           Flags: UINT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11SaveTextureToMemory';

function D3DX11ComputeNormalMap
         (
           pContext: ID3D11DeviceContext;
           pSrcTexture: ID3D11Texture2D;
           Flags: UINT;
           Channel: UINT;
           Amplitude: FLOAT;
           pDestTexture: ID3D11Texture2D
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11ComputeNormalMap';

function D3DX11SHProjectCubeMap
         (
           pContext: ID3D11DeviceContext;
           Order: UINT;
           pCubeMap: ID3D11Texture2D;
           pROut: LP_FLOAT;
           pGOut: LP_FLOAT;
           pBOut: LP_FLOAT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11SHProjectCubeMap';

function D3DX11CompileFromFileA
         (
           pSrcFile: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pFunctionName: LPCSTR; pProfile: LPCSTR;
           Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
           out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CompileFromFileA';

function D3DX11CompileFromFileW
         (
           pSrcFile: LPCWSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pFunctionName: LPCSTR; pProfile: LPCSTR;
           Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
           out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CompileFromFileW';

function D3DX11CompileFromResourceA
         (
           hSrcModule: HMODULE; pSrcResource: LPCSTR;
           pSrcFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pFunctionName: LPCSTR; pProfile: LPCSTR;
           Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
           out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CompileFromResourceA';

function D3DX11CompileFromResourceW
         (
           hSrcModule: HMODULE; pSrcResource: LPCWSTR;
           pSrcFileName: LPCWSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pFunctionName: LPCSTR; pProfile: LPCSTR;
           Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
           out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CompileFromResourceW';

function D3DX11CompileFromMemory
         (
           pSrcData: LPCSTR; SrcDataLen: SIZE_T;
           pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pFunctionName: LPCSTR; pProfile: LPCSTR;
           Flags1, Flags2: UINT; pPump: ID3DX11ThreadPump;
           out pShader: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CompileFromMemory';

function D3DX11PreprocessShaderFromFileA
         (
           pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pPump: ID3DX11ThreadPump;
           out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11PreprocessShaderFromFileA';

function D3DX11PreprocessShaderFromFileW
         (
           pFileName: LPCWSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pPump: ID3DX11ThreadPump;
           out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11PreprocessShaderFromFileW';

function D3DX11PreprocessShaderFromMemory
         (
           pSrcData: LPCSTR; SrcDataSize: SIZE_T;
           pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pPump: ID3DX11ThreadPump;
           out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11PreprocessShaderFromMemory';

function D3DX11PreprocessShaderFromResourceA
         (
           hModule: HMODULE; pResourceName: LPCSTR;
           pSrcFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pPump: ID3DX11ThreadPump;
           out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11PreprocessShaderFromResourceA';

function D3DX11PreprocessShaderFromResourceW
         (
           hModule: HMODULE; pResourceName: LPCWSTR;
           pSrcFileName: LPCWSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pPump: ID3DX11ThreadPump;
           out pShaderText: ID3DBlob; ppErrorMsgs: LP_ID3DBlob;
           pHResult: LP_HRESULT
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11PreprocessShaderFromResourceW';

//----------------------------------------------------------------------------
// Async processors
//----------------------------------------------------------------------------

function D3DX11CreateAsyncCompilerProcessor
         (
           pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           pFunctionName: LPCSTR; pProfile: LPCSTR;
           Flags1, Flags2: UINT;
           out pCompileShader: ID3DBlob; ppErrorBuffer: LP_ID3DBlob;
           out pProcessor: ID3DX11DataProcessor
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncCompilerProcessor';

function D3DX11CreateAsyncShaderPreprocessProcessor
         (
           pFileName: LPCSTR; pDefines: LP_D3D_SHADER_MACRO; pInclude: ID3DInclude;
           out pShaderText: ID3DBlob; ppErrorBuffer: LP_ID3DBlob;
           out pProcessor: ID3DX11DataProcessor
         ): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncShaderPreprocessProcessor';

//----------------------------------------------------------------------------
// D3DX11 Asynchronous texture I/O (advanced mode)
//----------------------------------------------------------------------------

function D3DX11CreateAsyncFileLoaderA(pFileName: LPCSTR; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncFileLoaderA';
function D3DX11CreateAsyncFileLoaderW(pFileName: LPCWSTR; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncFileLoaderW';
function D3DX11CreateAsyncMemoryLoader(pData: Pointer; cbData: SIZE_T; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncMemoryLoader';
function D3DX11CreateAsyncResourceLoaderA(hSrcModule: HMODULE; pSrcResource: LPCSTR; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncResourceLoaderA';
function D3DX11CreateAsyncResourceLoaderW(hSrcModule: HMODULE; pSrcResource: LPCWSTR; out pDataLoader: ID3DX11DataLoader): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncResourceLoaderW';

function D3DX11CreateAsyncTextureProcessor(pDevice: ID3D11Device; pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO; out pDataProcessor: ID3DX11DataProcessor): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncTextureProcessor';
function D3DX11CreateAsyncTextureInfoProcessor(pImageInfo: LP_D3DX11_IMAGE_INFO; out pDataProcessor: ID3DX11DataProcessor): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncTextureInfoProcessor';
function D3DX11CreateAsyncShaderResourceViewProcessor(pDevice: ID3D11Device; pLoadInfo: LP_D3DX11_IMAGE_LOAD_INFO; out pDataProcessor: ID3DX11DataProcessor): HRESULT;  stdcall;
  external d3dx11_dll name 'D3DX11CreateAsyncShaderResourceViewProcessor';

END.
