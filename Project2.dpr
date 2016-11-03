library Project2;

uses
  SysUtils, Windows, Classes,
  sys_main, sys_hooking, sys_cvars, sys_memory;

{$R *.res}

procedure Init_Thread;
var
  MName: String;
  Mutex: THandle;
begin
  Base.HID := Sys.GetProcessID('csgo.exe');
  if Base.HID <> GetCurrentProcessID then Halt;

  Randomize;
  D3D_Hook;

  MName := '_' + IntToHex(GetCurrentProcessID + $FF, 6);
  Mutex := OpenMutex(MUTEX_ALL_ACCESS, False, PChar(MName));

  if not (Mutex = 0) then
  begin
    CloseHandle(Mutex);
    Halt;
  end;

  CreateMutex(nil, False, PChar(MName));
  BeginThread(nil, 32, @Init_Start, nil, 0, Base.HThread);
end;

exports Init_Thread;

begin
  Init_Thread;
end.
