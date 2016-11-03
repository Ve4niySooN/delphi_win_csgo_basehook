unit sys_main;

interface

uses SysUtils, Windows, DDetours, MMSystem;

procedure Init_Start;

var
  cCreateInterface, eCreateInterface: function(cszSteamDLLAppsystemInterfaceVersion: PAnsiChar; pError: PInteger): Pointer; cdecl;

implementation

uses  sys_cvars, sys_memory, sys_buttons, sys_drawing, sys_hooking, sys_offsets, sys_vectors;

function HUD_Key_Event(eventcode, keynum: Integer; const Binding: PChar): Integer; stdcall;
begin
  Result := nHUD_Key_Event(eventcode, keynum, binding);
end;

function CL_CreateMove(sequence_number: Integer; frametime: Single; active: Boolean): Integer; stdcall;
begin
  Result := nCL_CreateMove(sequence_number, frametime, active);
end;

procedure Init_Main;
var
  PClientTable, PEngineTable, PEntityTable, PMovemtTable: Pointer;
begin

  // Init:
  PClientTable := cCreateInterface('VClient017', nil);
  PMovemtTable := cCreateInterface('GameMovement001', nil);
  PEngineTable := eCreateInterface('VEngineClient014', nil);
  PEntityTable := eCreateInterface('VClientEntityList003', nil);

  // PEntityTable:
	@Engine.Ent_ClientEntity  := Engine.Method(PEntityTable, 3);
	@Engine.Ent_Highest       := Engine.Method(PEntityTable, 6);
	@Engine.Ent_MaxEntity     := Engine.Method(PEntityTable, 8);

  // PMovemtTable:
	@Engine.Move_PlayerMinS  := Engine.Method(PMovemtTable, 5);
	@Engine.Move_PlayerMaxS  := Engine.Method(PMovemtTable, 6);
	@Engine.Move_PlayerView  := Engine.Method(PMovemtTable, 7);

  // PEngineTable:
  @Engine.nPlayerInfo     := Engine.Method(PEngineTable, 8);
  @Engine.nConVisible     := Engine.Method(PEngineTable, 11);
  @Engine.nLocalPlayer    := Engine.Method(PEngineTable, 12);
  @Engine.nGetViewAngles  := Engine.Method(PEngineTable, 19);
  @Engine.nSetViewAngles  := Engine.Method(PEngineTable, 20);
  @Engine.nInGame         := Engine.Method(PEngineTable, 26);
  @Engine.nInConnected    := Engine.Method(PEngineTable, 27);
  @Engine.nClientCmd      := Engine.Method(PEngineTable, 108);

  // Find:
  nFullUpdate   := Find.FullUpdate;
  nForceAttack  := Find.ForceAttack;

  // Hook:
  @nHUD_Key_Event := InterceptCreate(Engine.Method(PClientTable, 20), @HUD_Key_Event);
  @nCL_CreateMove := InterceptCreate(Engine.Method(PClientTable, 21), @CL_CreateMove);

  // Initialization:
  Init := True;
end;

procedure Init_Start;
var
  Handle, i: Integer; Output: file of Byte;
  Z: Pointer;
label Refresh;
begin
  Handle := CreateEvent(nil, True, False, PChar('_BaseHook' + IntToHex(GetCurrentProcessID + $FF, 6)));
  if Handle <> ERROR then
  begin
    Base.HProcess := OpenProcess(PROCESS_ALL_ACCESS, False, Base.HID);

    while Base.HProcess = 0 do
    Base.HProcess := OpenProcess(PROCESS_ALL_ACCESS, False, Base.HID);

    begin Refresh:
      Client.Address := Cardinal(Sys.GetModuleBase(Base.HID, 'client.dll'));
      EFuncs.Address := Cardinal(Sys.GetModuleBase(Base.HID, 'engine.dll'));
      D3DLib.Address := Cardinal(Sys.GetModuleBase(Base.HID, 'd3d9.dll'));
      WaitForSingleObject(Handle, 90);

      if (Client.Address = 0) or (EFuncs.Address = 0) or (D3DLib.Address = 0)
      then goto Refresh;
    end;

    @cCreateInterface := GetProcAddress(GetModuleHandle('client.dll'), 'CreateInterface');
    @eCreateInterface := GetProcAddress(GetModuleHandle('engine.dll'), 'CreateInterface');

    while (Device = nil) do WaitForSingleObject(Handle, 90);

    BeginThread(nil, 32, @Init_Main,    nil, 0, Base.HThread);
  end;
end;

end.

