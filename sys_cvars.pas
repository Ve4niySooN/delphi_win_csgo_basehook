unit sys_cvars;

interface

uses SysUtils, Windows, Math;

const
  HEADER_LUMPS    = 64;
  MAX_MAP_NODES   = 65536;
  MAX_MAP_PLANES  = 65536;
  MAX_MAP_LEAFS   = 65536;

	SIGNONSTATE_NONE        = 0;
	SIGNONSTATE_CHALLENGE   = 1;
	SIGNONSTATE_CONNECTED   = 2;
	SIGNONSTATE_NEW         = 3;
	SIGNONSTATE_PRESPAWN    = 4;
	SIGNONSTATE_SPAWN       = 5;
	SIGNONSTATE_FULL        = 6;
  SIGNONSTATE_CHANGELEVEL = 7;

  WP_WRONG    = 0;
  WP_VALID    = 1;
  WP_AIMING   = 2;
  WP_SNIPERS  = 3;
  WP_STOP     = 4;
  WP_SHOT     = 5;
  WP_INFO     = 6;

type
  name_s = ^name_t;
  name_t = array [0..16] of WideChar;

  vec4_s = ^vec4_t;
  vec4_t = record
    X, Y, Z, W: Single;
  end;

  vec3_s = ^vec3_t;
  vec3_t = packed record
    X, Y, Z: Single;
  end;

  vec2_s = ^vec2_t;
  vec2_t = packed record
    X, Y: Single;
  end;

  vertex2_t = record
    x, y, z, w: Single;
    U, V: single;
  end;

  rvec3_s = ^rvec3_t;
  rvec3_t = record
    X, Y, Z: Real;
  end;

  ray_s = ^ray_t;
  ray_t = record
    m_Start, m_Delta, m_StartOffset, m_Extents: vec3_t;
    m_IsRay, m_IsSwept: Boolean;
    class function Init(_start, _end: vec3_s): ray_t; static; inline;
  end;

  cplane_s = ^cplane_t;
  cplane_t = packed record
    Normal: vec3_t;
    Dist: Single;
    vType: Byte;
    Signbits: Byte;
    Pad: array [0..1] of Byte;
  end;

  csurface_s = ^csurface_t;
  csurface_t = record
    Name: PChar;
    surfaceProps: short;
    flags: USHORT;
  end;

  int3_t = record
    A, B, C: Integer;
  end;

  color_t = record
    R, G, B, A: Single;
  end;

  glow_t = record
    pEntity: Cardinal;
    color: color_t;
    unk1: array [1..4] of Integer;
    m_bRenderWhenOccluded, m_bRenderWhenUnoccluded, m_bFullBloom: Boolean;
  end;

  module_t = record
    Address, Size: Cardinal;
  end;

  base_t = record
    HProcess: THandle;
    HWindow, HID, HThread: Cardinal;
  end;

  link_s = ^link_t;
  link_t = record
    Prev, Next: link_s;
  end;

  plane_s = ^plane_t;
  plane_t = record
    vPlaneNormal: vec3_t;
    Distance: Single;
  end;

  edict_s   = ^edict_t;
  entvars_s = ^entvars_t;
  entvars_t = record
    ClassName, GlobalName: Longint;
    Origin, OldOrigin, Velocity, BaseVelocity, CLBaseVelocity, MoveDir, Angles,
    AngleVelocity, PunchAngle, ViewAngle, EndPos, StartPos: vec3_t;
    ImpactTime, StartTime: Single;
    FixAngle: Longint;
    IdealPitch, PitchSpeed, IdealYaw, YawSpeed: Single;
    ModelIndex, Model, ViewModel, WeaponModel: Longint;
    AbsMin, AbsMax, MinS, MaxS, Size: vec3_t;
    LifeTime, NextThink: Single;
    MoveType, Solid, Skin, Body, Effects: Longint;
    Gravity, Friction: Single;
    LightLevel, Sequence, GaitSequence: Longint;
    Frame, AnimTime, FrameRate: Single;
    Controller: array[1..4] of Byte;
    Blending: array[1..2] of Byte;
    Scale: Single;
    RenderMode: Longint;
    RenderAmt: Single;
    RenderColor: vec3_t;
    RenderFX: Longint;
    Health, Frags: Single;
    Weapons: Longint;
    TakeDamage: Single;
    DeadFlag: Longint;
    ViewOffset: vec3_t;
    Button, Impulse: Longint;
    Chain, DmgInflictor, Enemy, AimEnt, Owner, GroundEntity: edict_s;
    SpawnFlags, Flags, ColorMap, Team: Longint;
    MaxHealth, TeleportTime, ArmorType, ArmorValue: Single;
    WaterLevel, WaterType, Target, TargetName, NetName, Message: Longint;
    DmgTake, DmgSave, Damage, DmgTime: Single;
    Noise, Noise2, Noise3, Noise4: Longint;
    Speed, AirFinished, PainFinished, RadSuitFinished: Single;
    ContainingEntity: edict_s;
    PlayerClass: Longint;
    MaxSpeed, FOV: Single;
    WeaponAnim, PushMSec, InDuck, TimeStepSound, SwimTime, DuckTime, StepLeft: Longint;
    FallVelocity: Single;
    GameState, OldButtons, GroupInfo, iUser1, iUser2, iUser3, iUser4: Longint;
    fUser1, fUser2, fUser3, fUser4: Single;
    vUser1, vUser2, vUser3, vUser4: vec3_t;
    eUser1, eUser2, eUser3, eUser4: edict_s;
  end;

  edict_t = record
    Free, SerialNumber: Longint;
    Area: link_t;
    HeadNode, NumLeafs: Longint;
    LeafNums: array[1..48] of Smallint;
    FreeTime: Single;
    pvPrivateData: Pointer;
    v: entvars_t;
  end;

  user_t = record
    Vector: vec3_t;
    unknown: array [0..10] of DWORD;
    Health: Integer;
    Name: array [0..32] of WideChar;
  end;

  usercmd_s = ^usercmd_t;
  usercmd_t = record
    Skip: Pointer;
    Number, Tick: Integer;
    ViewAngles, AimDirection: vec3_t;
    ForwardMove, SideMove, UpMove: Single;
    Buttons: Integer;
    Impulse: Byte;
    WeaponSelect, WeaponSubtype, RandomSeed: Integer;
    MouseDX, MouseDY: SHORT;
    Predicted: Boolean;
    Skiping: array[1..24] of Byte;
  end;

  info_t = record
    Width, Height: Integer;
    CenterVec, BoneVec: vec3_t;
    Center: TPoint;
    Window, Client: TRect;
  end;

  trace_s = ^trace_t;
  trace_t = packed record
    vStart: vec3_t;
    vEnd: vec3_t;
    Plane: cplane_t;
    Fraction: Single;
    Contents: Integer;
    dispFlags: USHORT;
    AllSolid: Boolean;
    StartSolid: Boolean;
    fractionleftsolid: Single;
    Surface: csurface_t;
    hitgroup: Integer;
    physicsbone: Short;
    worldSurfaceIndex: UShort;
    m_pEntityHit: Pointer;
    hitbox: Integer;
  end;

  trc_t = record
    Src, Dst, Ray, Vec: vec3_t;
    Result: trace_t;
  end;

  CalcScreenMatrix_s = ^CalcScreenMatrix_t;
  CalcScreenMatrix_t = record
	  flMatrix: array [0..3, 0..3] of Single;
  end;

  vertex_t = record
    x, y, z: Single;
    color: Cardinal;
    class function Create(x, y, z: Single; Color: Cardinal): vertex_t; static; inline;
  end;

  winversion_t = (wvUnknown, wv95, wv98, wvME, wvNT3, wvNT4, wvW2K, wvXP, wv2003, wvVista, wv7, wv8, wv81, wv10);

var
  Init:        Boolean = False;

  nCreateInterface: function(const pName: PWideChar; pReturnCode: PINT): Pointer; stdcall;
  nCL_CreateMove:   function(sequence_number: Integer; frametime: Single; active: Boolean): Integer; stdcall;
  nHUD_Key_Event:   function(eventcode, keynum: Integer; const Binding: PChar): Integer; stdcall;
  nHUD_Shutdown:    procedure; stdcall;
  nTraverce:        procedure(vguiPanel: UINT; forceRepaint: Boolean; allowForce: Boolean); stdcall;
  nTraceLine:       procedure(const vecAbsStart: vec3_s; const vecAbsEnd: vec3_s; mask: UINT; const ignore: Pointer; collisionGroup: Integer; ptr: trace_t) = nil; //register;

  nFullUpdate:      Pointer = nil;
  nMaxPlayers:      Pointer = nil;
  nForceAttack:     Pointer = nil;
  nDrawPoints:      Pointer = nil;

  // -----------------------
  Info: info_t; Base: base_t;
  Client, EFuncs, D3DLib: module_t;
  // -----------------------

function TraceLine(vec1: vec3_s; vec2: vec3_s; mask: Cardinal; Skip: Cardinal): trace_t;

implementation

uses sys_vectors, sys_offsets, sys_memory;

class function vertex_t.Create(x, y, z: Single; color: Cardinal): vertex_t;
begin
  result.x := x;
  result.y := y;
  result.z := z;
  result.color := color;
end;

class function ray_t.Init(_start, _end: vec3_s): ray_t;
begin
  Result.m_Delta := VectorSubtract(_end, _start)^;
  Result.m_IsSwept := (Result.m_Delta.X <> 0) and (Result.m_Delta.Y <> 0) and (Result.m_Delta.Z <> 0);
  VectorClear(@Result.m_Extents);
  Result.m_IsRay := True;
  VectorClear(@Result.m_StartOffset);
  VectorCopy(_start, @Result.m_Start);
end;

function TraceLine(vec1: vec3_s; vec2: vec3_s; mask: Cardinal; Skip: Cardinal): trace_t;
var
  tr:  trace_t; sp: pointer;
begin
  if @nTraceLine = nil then @nTraceLine := Find.TraceLine;
  if Assigned(vec1) and Assigned(vec2) then
  begin
    if Check.Vector(vec1^, 2) and Check.Vector(vec2^, 2) then
    begin
      asm
        lea     eax,        tr;
        push    eax;
        push    0;
        mov     esi,        skip;
        push    esi;
        push    mask;
        mov     edx,        vec2;
        mov     ecx,        vec1;
        call    nTraceLine;
        add     esp,        $10;
      end;
      Result := tr;
    end;
  end;
end;

end.
