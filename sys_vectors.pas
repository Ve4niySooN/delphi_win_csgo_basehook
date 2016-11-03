unit sys_vectors;

interface

uses SysUtils, Windows, Math, sys_cvars, sys_memory, sys_offsets, Winapi.Direct3D9, Winapi.D3DX9;

function CalcAngle(const vec1, vec2: vec3_s): vec3_s;
function CalcBone(Bone: Integer; o_Pointer: DWORD): vec3_t; overload;
function CalcBoneP(Bone: Integer; o_Pointer: DWORD): vec3_s; overload;
function CalcDirection(Angle: vec3_t): vec3_t;
function CalcDistance2D(vFrom, vTo: vec3_t): Single;
function CalcDistance3D(const vFrom, vTo: vec3_t): Single;
function CalcProduct(const vec1, vec2: vec3_t): Single;
function CalcScreen(Origin: vec3_t): vec3_t;
function CalcTrace(Direction, Angles, LeftBottom, RightTop: vec3_t): Boolean;
function CalcVector(vFrom, vTo: vec3_t): Boolean;
function OnRect(x, y, w, h: Single; pos: vec3_t): Boolean;
function VectorAdd(const vec1, vec2: vec3_s): vec3_s;
function VectorAngles(src, dst: vec3_t): vec3_s;
function VectorDiv(const vec1: vec3_s; const Scale: Single): vec3_s;
function VectorHeight(const vec1: vec3_s; const Scale: Single): vec3_s;
function VectorScale(const vec1: vec2_t; const Scale: Single): vec3_s; overload;
function VectorScale(const vec1: vec3_s; const Scale: Single): vec3_s; overload;
function VectorSmooth(vec1, vec2: vec3_t; smooth: Single): vec3_s;
function VectorSubtract(const vec1, vec2: vec3_s): vec3_s;
function VectorVelocity(vec1, vec2, vec3: vec3_s; smooth: Single): vec3_s;

procedure AngleVectors(const Angles, vForward, vRight, vUp: vec3_s);
procedure ClampAngles(const vec: vec3_s);
procedure NormalizeAngles(const vec: vec3_s);
procedure VectorClear(const vec: vec3_s);
procedure VectorCopy(const vec1, vec2: vec3_s);

implementation

procedure ClampAngles(const vec: vec3_s);
begin
  if (vec.x > 89) and (vec.x <= 180) then vec.x := 89;
  if (vec.x > 180) then vec.x := vec.x - 360;
  if (vec.x < -89) then vec.x := -89;
  if (vec.y > 180) then vec.y := vec.y - 360;
  if (vec.y < -180) then vec.y := vec.y + 360;
  vec.Z := 0;
end;

procedure NormalizeAngles(const vec: vec3_s);
var
  l: Single;
begin
  l := Sqrt( vec.x *  vec.x + vec.y *  vec.y + vec.z *  vec.z );
  if l <> 0.0 then
  begin
    vec.X := vec.X / l;
    vec.Y := vec.Y / l;
    vec.Z := vec.Z / l;
  end else
  begin
    vec.x := 0;
    vec.y := 0;
    vec.Z := 1;
  end;
end;

procedure VectorCopy(const vec1, vec2: vec3_s);
begin
  vec3_t(vec2^) := vec3_t(vec1^);
end;

procedure VectorClear(const vec: vec3_s);
begin
  FillChar(vec^, SizeOf(vec3_t), $0);
end;

function CalcAngle(const vec1, vec2: vec3_s): vec3_s;
var
  vAngle, vDelta: vec3_t;
  hyp: Single;
begin
  vDelta.X := vec1.X - vec2.X;
  vDelta.Y := vec1.Y - vec2.Y;
  vDelta.Z := vec1.Z - vec2.Z;

  NormalizeAngles(@vDelta);

  hyp := Sqrt(vDelta.X * vDelta.X + vDelta.Y * vDelta.Y);


  vAngle.X := ArcTan(vDelta.z / hyp) * 57.295779513082;
  vAngle.Y := ArcTan(vDelta.y / vDelta.x) * 57.295779513082;
  vAngle.Z := 0;

  if vDelta.X >= 0 then vAngle.Y := vAngle.Y + 180;

  ClampAngles(@vAngle);
  Result := @vAngle;
end;

function VectorVelocity(vec1, vec2, vec3: vec3_s; smooth: Single): vec3_s;
var
  vec, enemy, local: vec3_t;
begin
 if (smooth = 0) then
 begin
   Result := vec1;
   Exit;
 end;

  vec := vec1^;

  if (vec2 <> nil) then enemy := VectorScale(vec2, smooth)^;
  if (vec3 <> nil) then local := VectorScale(vec3, smooth)^;

  if (vec2 <> nil) then vec  := VectorAdd(@vec, @enemy)^;
  if (vec3 <> nil) then vec  := VectorSubtract(@vec, @local)^;

  Result  := VectorSubtract(@vec, @local);
end;

function VectorSmooth(vec1, vec2: vec3_t; smooth: Single): vec3_s;
var
  Delta, Temp: vec3_t;
begin
  if smooth = 0 then
  begin
    Result := @vec2;
    Exit;
  end;

  Delta := VectorSubtract(@vec1, @vec2)^;
  ClampAngles(@Delta);
  Temp := VectorDiv(@Delta, 100)^;
  Temp := VectorScale(@Temp, smooth)^;
  Result := VectorSubtract(@vec1, @Temp);
end;

function VectorHeight(const vec1: vec3_s; const Scale: Single): vec3_s;
var vec: vec3_t;
begin
  vec.x := vec1.x;
  vec.y := vec1.y;
  vec.z := vec1.z + Scale;
  Result := @vec;
end;

function VectorAngles(src, dst: vec3_t): vec3_s;
var
  delta, vec: vec3_t;
  hyp: Single;
begin
	delta.x := src.x - dst.x;
	delta.y := src.y - dst.y;
	delta.z := src.z - dst.z;

  NormalizeAngles(@delta);

  hyp := sqrt( (delta.x * delta.x) + (delta.y * delta.y) );

  vec.x := ArcTan(delta.z / hyp)       * 57.295779513082;
  vec.y := ArcTan(delta.y / delta.x)   * 57.295779513082;
  vec.z := 0;

  if (delta.x >= 0.0) then vec.y := vec.y + 180.0;

  Result := @vec;
end;

function VectorScale(const vec1: vec2_t; const Scale: Single): vec3_s; overload;
var vec: vec3_t;
begin
  vec.x := vec1.x * Scale;
  vec.y := vec1.y * Scale;
  vec.z := 0;
  Result := @vec;
end;

function VectorDiv(const vec1: vec3_s; const Scale: Single): vec3_s;
var vec: vec3_t;
begin
  vec.x := vec1.x / Scale;
  vec.y := vec1.y / Scale;
  vec.z := vec1.z / Scale;
  Result := @vec;
end;

function OnRect(x, y, w, h: Single; pos: vec3_t): Boolean;
begin
  result := (pos.X > x) and (pos.X < (x + w)) and (pos.Y > y) and (pos.y < (y + h));
end;

function VectorScale(const vec1: vec3_s; const Scale: Single): vec3_s; overload;
var vec: vec3_t;
begin
  vec.x := vec1.x * Scale;
  vec.y := vec1.y * Scale;
  vec.z := vec1.z * Scale;
  Result := @vec;
end;

function VectorSubtract(const vec1, vec2: vec3_s): vec3_s;
var vec: vec3_t;
begin
  vec.x := vec1.x - vec2.x;
  vec.y := vec1.y - vec2.y;
  vec.z := vec1.z - vec2.z;
  Result := @vec;
end;

function VectorAdd(const vec1, vec2: vec3_s): vec3_s;
var vec: vec3_t;
begin
  vec.x := vec1.x + vec2.x;
  vec.y := vec1.y + vec2.y;
  vec.z := vec1.z + vec2.z;
  Result := @vec;
end;

procedure AngleVectors(const Angles, vForward, vRight, vUp: vec3_s);
var
  sr, sp, sy, cr, cp, cy, angle: Single;
begin
  Angle := angles.y * (Pi / 180);
  sy := Sin(Angle);
  cy := Cos(Angle);
  Angle := angles.x * (Pi / 180);
  sp := Sin(Angle);
  cp := Cos(Angle);
  Angle := angles.z * (Pi / 180);
  sr := Sin(Angle);
  cr := Cos(Angle);

  if not (vForward = nil) then
  with vec3_t(vForward^) do
  begin
    x := cp * cy;
    y := cp * sy;
    z := -sp;
  end;

  if not (vRight = nil) then
  with vec3_t(vRight^) do
  begin
    x := -sr * sp * cy - cr * -sy;
    y := -sr * sp * sy - cr * cy;
    z := -sr * cp;
  end;

  if not (vUp = nil) then
  with vec3_t(vUp^) do
  begin
    x := cr * sp * cy - sr * -sy;
    y := cr * sp * sy - sr * cy;
    z := cr * cp;
  end;
end;

function CalcVector(vFrom, vTo: vec3_t): Boolean;
begin
  Result := (vFrom.x = vTo.x) and (vFrom.y = vTo.y) and (vFrom.z = vTo.z);
end;

function CalcBoneP(Bone: Integer; o_Pointer: DWORD): vec3_s; overload;
var
  Read: size_t;
begin
    Result.x := PSingle(Cardinal(o_Pointer + ($30 * Bone + $0C)))^;
    Result.y := PSingle(Cardinal(o_Pointer + ($30 * Bone + $1C)))^;
    Result.z := PSingle(Cardinal(o_Pointer + ($30 * Bone + $2C)))^;
end;

function CalcBone(Bone: Integer; o_Pointer: DWORD): vec3_t; overload;
var
  Read: size_t;
begin
    Result.x := PSingle(Cardinal(o_Pointer + ($30 * Bone + $0C)))^;
    Result.y := PSingle(Cardinal(o_Pointer + ($30 * Bone + $1C)))^;
    Result.z := PSingle(Cardinal(o_Pointer + ($30 * Bone + $2C)))^;
end;

function CalcDistance3D(const vFrom, vTo: vec3_t): Single;
begin
Result := Abs(Sqrt(((vFrom.x - vTo.x) * (vFrom.x - vTo.x)) +
                   ((vFrom.y - vTo.y) * (vFrom.y - vTo.y)) +
                   ((vFrom.z - vTo.z) * (vFrom.z - vTo.z))));
end;

function CalcDistance2D(vFrom, vTo: vec3_t): Single;
begin
  Result := Abs(Sqrt(((vFrom.x - vTo.x) * (vFrom.x - vTo.x)) + ((vFrom.y - vTo.y) * (vFrom.y - vTo.y))));
end;

function CalcDirection(Angle: vec3_t): vec3_t;
var
	tSin, tCos: vec2_t;
begin
	Angle.x := (Angle.x) * 3.14159265 / 180;
	Angle.y := (Angle.y) * 3.14159265 / 180;

	tSin.x := Sin(Angle.y);
	tCos.x := Cos(Angle.y);
	tSin.y := Sin(Angle.x);
	tCos.y := Cos(Angle.x);

	Result.x := tCos.y * tCos.x;
	Result.y := tCos.y * tSin.x;
	Result.z := -tSin.y;
end;

function CalcTrace(Direction, Angles, LeftBottom, RightTop: vec3_t): Boolean;
var
	InDirection: vec3_t; InCount: vec2_t;
	Temp: array [1..6] of Single;
begin
	Result := False;

	InDirection.x := 1 / Direction.x;
	InDirection.y := 1 / Direction.y;
	InDirection.z := 1 / Direction.z;

	if (Direction.x = 0) and ((Angles.x < Min(LeftBottom.x, RightTop.x)) or (Angles.x > Max(LeftBottom.x, RightTop.x))) then Exit;
	if (Direction.y = 0) and ((Angles.y < Min(LeftBottom.y, RightTop.y)) or (Angles.y > Max(LeftBottom.y, RightTop.y))) then Exit;
	if (Direction.z = 0) and ((Angles.z < Min(LeftBottom.z, RightTop.z)) or (Angles.z > Max(LeftBottom.z, RightTop.z))) then Exit;

	Temp[1] := (LeftBottom.x - Angles.x) * InDirection.x;
	Temp[2] := (RightTop.x - Angles.x) * InDirection.x;
	Temp[3] := (LeftBottom.y - Angles.y) * InDirection.y;
	Temp[4] := (RightTop.y - Angles.y) * InDirection.y;
	Temp[5] := (LeftBottom.z - Angles.z) * InDirection.z;
	Temp[6] := (RightTop.z - Angles.z) * InDirection.z;

	InCount.x := Max(Max(Min(Temp[1], Temp[2]), Min(Temp[3], Temp[4])), Min(Temp[5], Temp[6]));
	InCount.y := Min(Min(Max(Temp[1], Temp[2]), Max(Temp[3], Temp[4])), Max(Temp[5], Temp[6]));

	if InCount.x > InCount.y then Exit;
	if InCount.y < 0 then Exit;

	Result := True;
end;

function CalcProduct(const vec1, vec2: vec3_t): Single;
begin
  Result := vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z;
end;


function CalcScreen(Origin: vec3_t): vec3_t;
var
  vec: vec3_t; Read: size_t;
  w, invw, x, y: Single;
  W2S_M: CalcScreenMatrix_t;
begin
  Result.z := 0;

  W2S_M := CalcScreenMatrix_s(Cardinal(Client.Address + o_ViewMatrix))^;

  vec.x := W2S_M.flMatrix[0][0] * origin.x + W2S_M.flMatrix[0][1] * origin.y + W2S_M.flMatrix[0][2] * origin.z + W2S_M.flMatrix[0][3];
  vec.y := W2S_M.flMatrix[1][0] * origin.x + W2S_M.flMatrix[1][1] * origin.y + W2S_M.flMatrix[1][2] * origin.z + W2S_M.flMatrix[1][3];
  w     := W2S_M.flMatrix[3][0] * origin.x + W2S_M.flMatrix[3][1] * origin.y + W2S_M.flMatrix[3][2] * origin.z + W2S_M.flMatrix[3][3];

  if (w < 0.01) then Exit;

  invw   := 1 / w;
  vec.x  := vec.x * invw;
  vec.y  := vec.y * invw;

  Result.x := Info.CenterVec.X + (0.5 * vec.x * Info.Width  + 0.5);
  Result.y := Info.CenterVec.Y - (0.5 * vec.y * Info.Height + 0.5);
  Result.z := 1;
end;

end.
