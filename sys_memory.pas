unit sys_memory;

interface

uses
  SysUtils, Windows, MMSystem, TlHelp32, PsApi, sys_cvars, sys_offsets;

type
  THMemory = class(TObject)
    public
      function Read(Address: Cardinal): Cardinal;
      function ReadEx(Address: Cardinal): Cardinal;
      function Compare(Address, Pattern, Size: Cardinal): Boolean;
      function FindPattern(StartAddr, EndAddr: Cardinal; const Pattern: Pointer; PatternSize: Cardinal; Offset: Longint): Pointer; overload;
      procedure Replace(const Address, Pattern: Pointer; const Size: Cardinal);
      procedure ReplaceF(Address: Cardinal; Pattern: Pointer; Size: Cardinal);
      procedure ReplaceEx(const Address, Pattern: Pointer; Size: Cardinal);
  end;

type
  THSystem = class(TObject)
    public
      function GetModuleBase(ProcessID: Cardinal; MName: String): Pointer;
      function GetProcessID(ProcessName : string ) : DWORD ;
      function GetModuleSize(Address: LongWord): LongWord;
      function GetWinVersion: winversion_t;
  end;

type
  THEngine = class(TObject)

  var
	// IClientEntityList, 	VClientEntityList003
	Ent_ClientEntity: 	function: Pointer; 	// 3
	Ent_Highest: 		    function: Integer; 	// 6
	Ent_MaxEntity: 		  function: Integer; 	// 8

	// IGameMovement, 	GameMovement001
	Move_PlayerMinS: function(P: Boolean): vec3_t; // 5
	Move_PlayerMaxS: function(P: Boolean): vec3_t; // 6
	Move_PlayerView: function(P: Boolean): vec3_t; // 7

	// PEngineTable, VEngineClient014
	nPlayerInfo:	  function(Ent: Integer; pInfo: Pointer): Boolean; // 8
	nConVisible:	  function: Boolean; // 11
	nLocalPlayer:	  function: Integer; // 12
	nGetViewAngles:	procedure(vec: vec3_s); // 19
	nSetViewAngles:	procedure(vec: vec3_s); // 20

	nInGame:		  function: Boolean; // 26
	nInConnected:	function: Boolean; // 27
	nClientCmd: 	procedure(const Str: PAnsiChar); // 108

    public
      function VisibleMask(Address: Cardinal; Index: Integer): Boolean;
      function GetViewPosition(flags: cardinal): vec3_t;
      function CurState: Cardinal;

      function MouseEvent(S: Byte): Cardinal;
      function FullUpdate: Boolean;
      function Method(const intf; methodIndex: Integer): Pointer;
      function Table(p: cardinal; methodIndex: Integer): Pointer;
  end;

type
  THCheck = class(TObject)
    public
      function Vector(vec: vec3_t; const t: Byte = 0): Boolean;
      function KeyEvent(Key: Word): Boolean;
      function KeyAsync(Key: Word): Boolean;
  end;

type
  THFind = class(TObject)
    public
      function FullUpdate: Pointer;
      function TraceLine: Pointer;
      function CreateMove1: Pointer;
      function CreateMove2: Pointer;
      function MaxPlayers: Pointer;
      function SendPacket: Pointer;
      function ForceAttack: Pointer;
      function Traverce: Pointer;
      function pInterface: Pointer;
  end;

var
  Mem: THMemory;
  Sys: THSystem;
  Engine: THEngine;
  Check: THCheck;
  Find: THFind;


  //#define GMOR_PATTERN "\xFF\x15\x00\x00\x00\x00\x8B\xF8\x85\xDB\x74\x1F\x80\x7B\x4F\x00\x74\x19\x85\xFF\x75\x15"
  //#define GMOR_MASK "xx????xxxxxxxxxxxxxxxx"

  Mask_D3DReset_7:  array [0..14] of Byte = ($57,$FF,$15,$FF,$FF,$FF,$FF,$8B,$45,$0C,$33,$F6,$39,$70,$20);
  Mask_D3DReset_8:  array [0..18] of Byte = ($33,$C9,$39,$4F,$20,$75,$79,$8D,$44,$24,$38,$89,$44,$24,$1C,$32,$C0,$8B,$DE);
  Mask_D3DReset_9:  array [0..12] of Byte = ($8B,$CE,$E8,$00,$00,$00,$00,$8B,$4E,$0C,$48,$F7,$D8);
  Mask_D3DReset_0:  array [0..12] of Byte = ($8B,$CE,$E8,$FF,$FF,$FF,$FF,$8B,$4E,$0C,$48,$F7,$D8);

  Mask_D3DEScene_7: array [0..53] of Byte = ($57,$FF,$15,$FF,$FF,$FF,$FF,$E9,$FF,$FF,$FF,$FF,$39,$5F,$18,$74,$07,$57,$FF,$15,$FF,$FF,$FF,$FF,$B8,$FF,$FF,$FF,$FF,$8B,$4D,$F4,$64,$89,$0D,$FF,$FF,$FF,$FF,$59,$5F,$5E,$5B,$8B,$E5,$5D,$C2,$04,$00,$68,$AD,$06,$FF,$FF);
  Mask_D3DEScene_8: array [0..22] of Byte = ($33,$C0,$E8,$FF,$FF,$FF,$FF,$C2,$04,$00,$8B,$DF,$EB,$8E,$53,$FF,$15,$FF,$FF,$FF,$FF,$EB,$90);
  Mask_D3DEScene_9: array [0..22] of Byte = ($33,$C0,$E8,$FF,$FF,$FF,$FF,$C2,$04,$00,$8B,$DF,$EB,$8E,$53,$FF,$15,$FF,$FF,$FF,$FF,$EB,$90);
  Mask_D3DEScene_0: array [0..22] of Byte = ($33,$C0,$E8,$FF,$FF,$FF,$FF,$C2,$04,$00,$8B,$DF,$EB,$8E,$53,$FF,$15,$FF,$FF,$FF,$FF,$EB,$90);

  Mask_TraceLine:   array [0..10] of Byte = ($55,$8B,$EC,$83,$E4,$F0,$83,$EC,$7C,$56,$52);
  Mask_GlowObject:  array [0..13] of Byte = ($A1,$FF,$FF,$FF,$FF,$A8,$01,$75,$FF,$0F,$57,$C0,$C7,$05);
  Mask_Traverce:    array [0..30] of Byte = ($55,$8B,$EC,$8B,$01,$FF,$75,$08,$FF,$90,$FF,$FF,$FF,$FF,$FF,$75,$10,$8B,$C8,$FF,$75,$0C,$8B,$10,$FF,$52,$0C,$5D,$C2,$0C,$FF);
  Mask_CreateMove1:  array [0..24] of Byte = ($55,$8B,$EC,$83,$EC,$08,$FF,$15,$FF,$FF,$FF,$FF,$84,$C0,$74,$32,$A1,$FF,$FF,$FF,$FF,$89,$45,$F8,$A1);
  Mask_CreateMove2: array [0..43] of Byte = ($55,$8B,$EC,$8B,$FF,$FF,$FF,$FF,$FF,$85,$C9,$75,$06,$B0,$01,$5D,$C2,$08,$00,$8B,$01,$FF,$75,$0C,$F3,$0F,$10,$45,$08,$51,$8B,$FF,$FF,$FF,$FF,$FF,$F3,$0F,$11,$04,$24,$FF,$D0,$5D);
  Mask_VClient:     array [0..9]  of Byte = ($56,$43,$6C,$69,$65,$6E,$74,$30,$31,$37);
  Mask_ForceUpdate: array [0..12] of Byte = ($3B,$91,$FF,$FF,$FF,$FF,$74,$07,$40,$74,$E1,$32,$C0); // +2
  Mask_MaxPlayers:  array [0..8] of Byte = ($40,$DF,$34,$54,$24,$EC,$87,$58,$0C); // + $24
  Mask_SendPacket:  array [0..4] of Byte = ($B3,$01,$8B,$01,$8B); // + $1;
  Mask_ForceAttack: array [0..2] of Byte = ($A8,$01,$BF); // + 13
  Mask_DrawPoints:  array [0..5] of Byte = ($8B,$7C,$24,$10,$03,$F8); //

  //Mask_EntityList:  array [] of Byte = ($E6,$04,$81,$C6,$FF,$FF,$FF,$FF,$89);

implementation

function THCheck.Vector(vec: vec3_t; const t: Byte = 0): Boolean;
begin
  case t of
    0: Result := (vec.z = 1) and (vec.x > 0) and (vec.y > 0) and (vec.x < Info.Width) and (vec.y < Info.Height);
    1: Result := (Abs(vec.y) > 0)  and (Abs(vec.x) > 0)  and (Abs(vec.z) > 0)  and
                 (Abs(vec.y) < 360) and (Abs(vec.x) < 360) and (Abs(vec.z) < 360);
    2: Result := (vec.x <> 0) and (vec.y <> 0) and (vec.z <> 0) and (Abs(vec.y) < 16384) and (Abs(vec.x) < 16384) and (Abs(vec.z) < 16384);
  end;
end;

function THCheck.KeyAsync(Key: Word): Boolean;
begin
  Result := GetAsyncKeyState(Key) <> 0;
end;

function THCheck.KeyEvent(Key: Word): Boolean;
begin
  Result := (Word(GetKeyState(Key)) and $8000) <> 0;
end;

function THEngine.MouseEvent(S: Byte): Cardinal;
begin
  if (S = WP_INFO) then
  begin
    Result := Mem.Read(Cardinal(Client.Address + o_ForceAttack));
    Exit;
  end;

  Mem.Replace(Ptr(Client.Address + o_ForceAttack), @S, SizeOf(Byte));
end;

function THEngine.Method(const intf; methodIndex: Integer): Pointer;
begin
  Result := Pointer(Pointer(DWORD(Pointer(intf)^) + methodIndex * 4)^);
end;

function THEngine.Table(p: cardinal; methodIndex: Integer): Pointer;
begin
  Result := Pointer(Pointer(DWORD(Ptr(p)^) + methodIndex * 4)^);
end;

function THFind.SendPacket: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $4CAE000, @Mask_SendPacket, SizeOf(Mask_SendPacket), 1);
end;

function THFind.ForceAttack: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $4CAE000, @Mask_ForceAttack, SizeOf(Mask_ForceAttack), 13);
end;

function THFind.Traverce: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $4CAE000, @Mask_Traverce, SizeOf(Mask_Traverce), 0);
end;

function THFind.CreateMove1: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $4CAE000, @Mask_CreateMove1, SizeOf(Mask_CreateMove1), 0);
end;

function THFind.CreateMove2: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $4CAE000, @Mask_CreateMove2, SizeOf(Mask_CreateMove2), 0);
end;


function THFind.MaxPlayers: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $4CAE000, @Mask_MaxPlayers, SizeOf(Mask_MaxPlayers), 0);
end;

function THFind.TraceLine: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $1FFFFF, @Mask_TraceLine, SizeOf(Mask_TraceLine), 0);
end;

function THFind.pInterface: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $4CAE000, @Mask_VClient, SizeOf(Mask_VClient), 0);
end;

function THFind.FullUpdate: Pointer;
begin
  Result := Mem.FindPattern(Client.Address, Client.Address + $4CAE000, @Mask_ForceUpdate, SizeOf(Mask_ForceUpdate), 2);
end;


function THEngine.FullUpdate: Boolean;
begin
  PInteger(Mem.Read(EFuncs.Address + o_ClientState) + $16C)^ := (-1);
end;

function THEngine.CurState: Cardinal;
begin
  Result := Mem.Read(Mem.Read(EFuncs.Address + o_ClientState) + $100);
end;


function THEngine.VisibleMask(Address: Cardinal; Index: Integer): Boolean;
var
	Mask: LongWord; Read: SIZE_T;
begin
  Mask := Mem.Read(Address + $97C);
  Result := Boolean(Mask and (1 shl (Index - 1)) = (1 shl (Index - 1)));
end;

procedure Log(OutputDbgString: String; value: real);
begin
 OutputDebugString(PWideChar(' - '+OutputDbgString+' \ '+floattostr(value)+'     - '));
end;

function THEngine.GetViewPosition(flags: cardinal): vec3_t;
begin
  result.x := 0;
  result.y := 0;
  result.z := 64;
  if (flags = 263) or (flags = 775) then result.z := result.z - 15;
end;

function THMemory.Compare(Address, Pattern, Size: Cardinal): Boolean;
var
 B: Byte;
 i: Cardinal;
begin
  for i := 0 to Size - 1 do
  begin
    B := PByte(Pattern + i)^;
    if (PByte(Address + i)^ <> B) and (B <> $FF) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

procedure THMemory.Replace(const Address, Pattern: Pointer; const Size: Cardinal);
var
  i: Cardinal;
  Protect, Protect2: Cardinal;
begin
  VirtualProtect(Address, Size, PAGE_EXECUTE_READWRITE, Protect);
  for i := 0 to Size - 1 do PByte(Cardinal(Address) + i)^ := PByte(Cardinal(Pattern) + i)^;
  VirtualProtect(Address, Size, Protect, Protect2);
end;

procedure THMemory.ReplaceF(Address: Cardinal; Pattern: Pointer; Size: Cardinal);
var
  i: Cardinal;
begin
  for i := 0 to Size - 1 do
  PByte(Cardinal(Address) + i)^ := PByte(Cardinal(Pattern) + i)^;
end;

function THMemory.FindPattern(StartAddr, EndAddr: Cardinal; const Pattern: Pointer; PatternSize: Cardinal; Offset: Longint): Pointer;
var
  i: Integer;
begin
  for i := StartAddr to EndAddr - (1 + PatternSize) do
  if Mem.Compare(i, Cardinal(Pattern), PatternSize) then
  begin
    Result := Pointer(i + Offset);
    Exit;
  end;
  Result := nil;
end;

function THMemory.Read(Address: Cardinal): Cardinal;
begin
  Result := PCardinal(Cardinal(Address))^;
end;

// External: ===================================================================

procedure THMemory.ReplaceEx(const Address, Pattern: Pointer; Size: Cardinal);
var
  Write: size_t;
  Protect, Protect2: Cardinal;
begin
  VirtualProtectEx(Base.HProcess, Pointer(Address), Size, PAGE_EXECUTE_READWRITE, Protect);
  WriteProcessMemory(Base.HProcess, Address, Pattern, Size, Write);
  VirtualProtectEx(Base.HProcess, Pointer(Address), Size, Protect, Protect2);
end;

function THMemory.ReadEx(Address: Cardinal): Cardinal;
var
  Read: size_t;
begin
  ReadProcessMemory(Base.HProcess, Ptr(Address), @Result, 4, Read);
end;

// End of external; ============================================================

function THSystem.GetWinVersion: winversion_t;
var
  OSVersionInfo : TOSVersionInfo;
begin
  Result := wvUnknown;
  OSVersionInfo.dwOSVersionInfoSize := sizeof(TOSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
  begin
    case OSVersionInfo.DwMajorVersion of
      3:  Result := wvNT3;
      4:
      case OSVersionInfo.DwMinorVersion of
        0:  if OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then Result := wvNT4 else Result := wv95;
        10: Result := wv98;
        90: Result := wvME;
      end;
      5:
      case OSVersionInfo.DwMinorVersion of
        0: Result := wvW2K;
        1: Result := wvXP;
        2: Result := wv2003;
      end;
      6:  Result := wvVista;
      7:  Result := wv7;
      8:  Result := wv8;
      9:  Result := wv81;
      10: Result := wv10;
    end;
  end;
end;

function THSystem.GetModuleSize(Address: LongWord): LongWord;
asm
  add eax, dword ptr [eax.TImageDosHeader._lfanew]
  mov eax, dword ptr [eax.TImageNtHeaders.OptionalHeader.SizeOfImage]
end;

function THSystem.GetModuleBase(ProcessID: Cardinal; MName: String): Pointer;
var
   Modules         : Array of HMODULE;
   cbNeeded, i     : Cardinal;
   ModuleInfo      : TModuleInfo;
   ModuleName      : Array[0..MAX_PATH] of Char;
   PHandle         : THandle;
begin
  Result := nil;
  SetLength(Modules, 1024);
  PHandle := OpenProcess(PROCESS_QUERY_INFORMATION + PROCESS_VM_READ, False, ProcessID);
  if (PHandle <> 0) then
  begin
    EnumProcessModules(PHandle,  @Modules[0], 1024 * SizeOf(HMODULE), cbNeeded);
    SetLength(Modules, cbNeeded div SizeOf(HMODULE));
    for i := 0 to Length(Modules) - 1 do
    begin
      GetModuleBaseName(PHandle, Modules[i], ModuleName, SizeOf(ModuleName));
      if AnsiCompareText(MName, ModuleName) = 0 then
      begin
        GetModuleInformation(PHandle, Modules[i],  @MoDuleInfo, SizeOf(ModuleInfo));
        Result := ModuleInfo.lpBaseOfDll;
        CloseHandle(PHandle);
        Exit;
      end;
    end;
  end;
end;

function THSystem.GetProcessID(ProcessName: string): DWORD;
var
  Handle:tHandle;
  Process:tProcessEntry32;
  GotProcess:Boolean;
begin
  Handle:=CreateToolHelp32SnapShot(TH32CS_SNAPALL,0) ;
  Process.dwSize:=SizeOf(Process);
  GotProcess := Process32First(Handle,Process);
  {$B-}
    if GotProcess and (Process.szExeFile<>ProcessName) then
    repeat GotProcess := Process32Next(Handle,Process);
    until (not GotProcess) or (Process.szExeFile=ProcessName);
  {$B+}
  if GotProcess then Result := Process.th32ProcessID else Result := 0;
  CloseHandle(Handle);
end;

end.
