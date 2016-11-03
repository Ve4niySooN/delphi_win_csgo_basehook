unit sys_hooking;

interface

uses Windows, SysUtils, Classes, DDetours, Direct3D9, D3DX9,
  sys_drawing, sys_cvars, sys_memory, sys_vectors, sys_offsets;

var
  Device:   IDirect3DDevice9 = nil;
  g_Font:   ID3DXFont = nil;
  g_Line:   ID3DXLine = nil;

  nEndScene:   function(Self: Pointer): HResult stdcall = nil;
  nReset:      function(const Self; const pPresentationParameters: TD3DPresentParameters): HResult; stdcall;
  nD3DCreate:  function(SDKVersion: LongWord): DWORD stdcall = nil;
  nD3DDevice:  function(Self: Pointer; Adapter: LongWord;
               DeviceType: TD3DDevType; hFocusWindow: HWND; BehaviorFlags: DWord;
               pPresentationParameters: PD3DPresentParameters;
               out ppReturnedDeviceInterface: IDirect3DDevice9) : HRESULT stdcall = nil;

  function EndScene(Self: pointer): HResult; stdcall;
  function Reset(const Self; const pPresentationParameters: TD3DPresentParameters): HResult; stdcall;
  function D3DCreate(SDKVersion: LongWord): DWORD; stdcall;

  procedure D3D_Resize;
  procedure D3D_Hook;

implementation

procedure D3DXVarCreate;
const
  font_size   = 12;
  font_name   = 'Microsoft Sans Serif';
  font_style  = FW_SEMIBOLD;
begin
  if (Device <> nil) then
  begin
    D3DXCreateFont(Device, font_size, 0, font_style, 1, false, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, DRAFT_QUALITY, DEFAULT_PITCH or FF_DONTCARE, font_name, g_Font);
    D3DXCreateLine(Device, g_Line);
  end;
end;

procedure D3DXVarDestroy;
begin
  g_Font.OnLostDevice;
  g_Line.OnLostDevice;
end;

var
  ExamplePrint: Boolean = True;

function EndScene(Self: pointer): HResult; stdcall;
begin
  if ExamplePrint and Engine.nConVisible then
  begin
    ExamplePrint := False;
    Engine.nClientCmd('echo "[Delphi] Simple BaseHook by Ve4niySooN"');
  end;
  Result := nEndScene(Self);
end;

function Reset(const Self; const pPresentationParameters: TD3DPresentParameters): HResult; stdcall;
begin
  D3DXVarDestroy;
  Result := nReset(Self, pPresentationParameters);
  if Result = D3D_OK then D3DXVarCreate;
end;

procedure D3D_Resize;
var
  Viewport: D3DVIEWPORT9;
begin
  Device.GetViewport(Viewport);

  Info.Width        := Viewport.Width;
  Info.Height       := Viewport.Height;
  Info.Center.X     := Viewport.Width   div 2;
  Info.Center.Y     := Viewport.Height  div 2;


  Info.CenterVec.X  := Info.Center.X;
  Info.CenterVec.Y  := Info.Center.Y;
end;

function D3DMethod(const intf; methodIndex: DWORD): Pointer;
begin
  Result := Pointer(Pointer(DWORD(Pointer(intf)^) + methodIndex * 4)^);
end;

function D3DDevice(Self: pointer; Adapter: LongWord; DeviceType: TD3DDevType;
  hFocusWindow: HWND; BehaviorFlags: DWord; pPresentationParameters: PD3DPresentParameters;
  out ppReturnedDeviceInterface: IDirect3DDevice9): HRESULT; stdcall;
begin
  Result := nD3DDevice(self, adapter, DeviceType, hFocusWindow, BehaviorFlags, pPresentationParameters, ppReturnedDeviceInterface);
  Device := ppReturnedDeviceInterface;

  D3DXVarCreate;

  @nReset    := InterceptCreate(D3DMethod(ppReturnedDeviceInterface,  16), @Reset);
  @nEndScene := InterceptCreate(D3DMethod(ppReturnedDeviceInterface,  42), @EndScene);
end;

function D3DCreate(SDKVersion: LongWord): DWORD; stdcall;
begin
  Result := nD3DCreate(SDKVersion);
  if (Result <> 0) then
  begin
    if (@nD3DDevice = nil) then InterceptRemove(@nD3DDevice);
    @nD3DDevice := InterceptCreate(D3DMethod(Result,  16), @D3DDevice);
  end;
end;

procedure D3D_Hook;
var
  Ptr_D3DModule: Cardinal;
  Ptr_D3DCreate: Pointer;
begin
  Ptr_D3DModule := LoadLibrary('d3d9.dll');
  if (Ptr_D3DModule <> 0) then
  begin
    Ptr_D3DCreate := GetProcAddress(Ptr_D3DModule, 'Direct3DCreate9');
    if Cardinal(Ptr_D3DCreate) <> 0 then
    @nD3DCreate := InterceptCreate(Ptr_D3DCreate, @D3DCreate);
  end;
end;

end.
