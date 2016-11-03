unit sys_drawing;

interface

uses Windows, SysUtils, Classes, Direct3D9, D3DX9, DXTypes, sys_cvars;

type
  TDraw = class(TObject)
    public
	    procedure Clear(x, y, w, h: Single; Color: D3DColor);
      procedure FillRGB(x, y, w, h: Single; Color: D3DColor);
      procedure FillRGBA(x, y, w, h: Single; color: D3DColor);
      procedure Line(Pos1, Pos2: vec2_t; w: Single; Color: D3DColor); overload;
      procedure Line(x1, y1, x2, y2, w: Single; Color: D3DColor); overload;
      procedure Line(Pos1, Pos2: vec3_t; w: Single; Color: D3DColor); overload;
      procedure Image(x, y, w, h: Single; i: Integer);
      procedure Text(x, y: Single; Text: string; color: D3DCOLOR);
      procedure CenterText(x, y: Single; Text: string; color: D3DCOLOR);
      procedure Box(x, y, w, h, thickness: single; color: D3DCOLOR);
      procedure FilledBox(x, y, w, h, thickness: single; color, bordercolor: D3DCOLOR);
      procedure AngleBox(x, y, width, height, thickness: single; color: D3DCOLOR; const i_h: Integer = 9; const i_w: Integer = 4);
      procedure CrossBox(x, y, width, height, thickness: single; color: D3DCOLOR);
      procedure Circle(cx, cy, r, w: Single; color: D3DCOLOR);
  end;

var
  Draw: TDraw;

implementation

uses sys_hooking;

procedure TDraw.Circle(cx, cy, r, w: Single; color: D3DCOLOR);
const
  num_segments = 32;
var
  theta, c, s, t, x, y: Single;
  i: Integer; vec: array [0..num_segments] of vec2_t;
begin
  if (Device = nil) then Exit;

  theta := 2 * 3.14 / num_segments;
  c := cos(theta);
  s := sin(theta);

  x := r;
  y := 0;

  vec[0].X := x + cx;
  vec[0].Y := y + cy;
  t := x;
  x := c * x - s * y;
  y := s * t + c * y;

  for i := 1 to num_segments - 1 do
  begin
    vec[i].X := x + cx;
    vec[i].Y := y + cy;

    Draw.Line(vec[i - 1], vec[i], w, Color);

		t := x;
		x := c * x - s * y;
		y := s * t + c * y;
  end;

  vec[num_segments].X := x + cx;
  vec[num_segments].Y := y + cy;
  Draw.Line(vec[num_segments - 1], vec[num_segments], w, Color);
end;

procedure TDraw.FilledBox(x, y, w, h, thickness: single; color, bordercolor: D3DCOLOR);
begin
  if (Device = nil) then Exit;

  Draw.FillRGB(x, y, w, thickness, bordercolor);
  Draw.FillRGB(x, y, thickness, h, bordercolor);
  Draw.FillRGB(x + w, y, thickness, h, bordercolor);
  Draw.FillRGB(x, y + h, w + 1, thickness, bordercolor);
  Draw.FillRGB(x+1, y+1, w-1, h-1, color);
end;

procedure TDraw.CrossBox(x, y, width, height, thickness: single; color: D3DCOLOR);
var
  scr_h, scr_w: Integer;
begin
  if (Device = nil) then Exit;

  scr_h := Round(height / 4);
  scr_w := Round(width  / 4);

  Draw.FillRGB(x, y, thickness, scr_h + 1, color);
  Draw.FillRGB(x + 1, y, scr_w, thickness, color);
  Draw.FillRGB(x, y + height - scr_h, thickness, scr_h + 1, color);
  Draw.FillRGB(x + 1, y + height, scr_w, thickness, color);

  Draw.FillRGB(x + width - scr_w - 1, y + height, scr_w, thickness, color);
  Draw.FillRGB(x + width - 1, y, thickness, scr_h, color);
  Draw.FillRGB(x + width - 1, y + height - scr_h, thickness, scr_h, color);
  Draw.FillRGB(x + width - scr_w - 1, y, scr_w, thickness, color);
end;

procedure TDraw.AngleBox(x, y, width, height, thickness: single; color: D3DCOLOR; const i_h: Integer = 9; const i_w: Integer = 4);
var
  scr_h, scr_w: Single;
begin
  if (Device = nil) then Exit;

  scr_h := height / i_h;
  scr_w := width  / i_w;

  Draw.FillRGB(x, y, thickness, scr_h + 1, color);
  Draw.FillRGB(x + 1, y, scr_w, thickness, color);
  Draw.FillRGB(x, y + height - scr_h, thickness, scr_h + 1, color);
  Draw.FillRGB(x + 1, y + height, scr_w, thickness, color);

  Draw.FillRGB(x + width - scr_w - 1, y + height, scr_w, thickness, color);
  Draw.FillRGB(x + width - 1, y, thickness, scr_h, color);
  Draw.FillRGB(x + width - 1, y + height - scr_h, thickness, scr_h + thickness, color);
  Draw.FillRGB(x + width - scr_w - 1, y, scr_w, thickness, color);
end;

procedure TDraw.Box(x, y, w, h, thickness: single; color: D3DCOLOR);
begin
  if (Device = nil) then Exit;

  Draw.FillRGB(x, y, w, thickness, Color);
  Draw.FillRGB(x, y, thickness, h, Color);
  Draw.FillRGB(x + w - 1, y, thickness, h + thickness, Color);
  Draw.FillRGB(x, y + h, w + 1, thickness, Color);
end;

procedure TDraw.CenterText(x, y: Single; Text: string; color: D3DCOLOR);
var
  TextRect: TRect;
begin
  if (Device = nil) or (Text = '') then Exit;

  TextRect := Rect(Round(x),Round(y),Round(x),Round(y));
  g_Font.DrawTextW(nil, PChar(Text), -1, @TextRect, DT_CENTER or DT_NOCLIP, color);
end;

procedure TDraw.Image(x, y, w, h: Single; i: Integer);
var
  matrixPOS, matrixFORM, matrix: D3DXMATRIX;
begin
  if (Device = nil) then Exit;

  {
  D3DXMatrixTranslation(matrix, x, y, 0);
  //DXMatrixScaling(matrixFORM, ((Info.Width * w) / 100) / Info.Width, ((Info.Height * h) / 100) / Info.Height, 0);
  //D3DXMatrixScaling(matrixFORM, ((Info.Width * w) / 100) / IImage[i].Width, ((Info.Height * h) / 100) / IImage[i].Height, 0);
  //D3DXMatrixScaling(matrixFORM, w, h, 0);
  //D3DXMatrixMultiply(matrix, matrixFORM, matrixPOS);

  g_Image._begin
  if (Device = nil) then Exit;
(D3DXSPRITE_ALPHABLEND);
    g_Image.SetTransform(matrix);
    g_Image.Draw(Images, nil, nil, nil, $FFFFFFFF);
  g_Image._End;
  }
end;

procedure TDraw.Text(x, y: Single; Text: string; color: D3DCOLOR);
var
  TextRect: TRect;
begin
  if (Device = nil) or (Text = '') then Exit;

  TextRect := Rect(Round(x),Round(y), 0, 0);
  g_Font.DrawTextW(nil, PChar(Text), -1, @TextRect, DT_LEFT or DT_NOCLIP, color);
end;

procedure TDraw.FillRGBA(x, y, w, h: Single; color: D3DColor);
type
  vertex = record
    pos1, pos2, pos3, pos4: single;
    color: d3dcolor;
    end;

var
  qV: array [1..4] of vertex;

  function CreateVertex(pos1, pos2, pos3, pos4: single; color: d3dcolor): vertex;
  begin
    result.pos1   := pos1;
    result.pos2   := pos2;
    result.pos3   := pos3;
    result.pos4   := pos4;
    result.color  := color;
  end;

begin
  if (Device = nil) then Exit;

  qV[1] := CreateVertex(x, y + h, 0, 3, color);
  qV[2] := CreateVertex(x, y, 0, 6, color);
  qV[3] := CreateVertex(x + w, y + h, 0, 9, color);
  qV[4] := CreateVertex(x + w, y, 0, 12, color);

  Device.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, qV, sizeof(vertex));
end;

procedure TDraw.FillRGB(x, y, w, h: Single; Color: D3DColor);
var
  Rec: TRect;
begin
  if (Device = nil) then Exit;
  Rec := Rect(Round(x), Round(y), Round(x + w), Round(y + h));
  Device.Clear(1, @Rec, D3DCLEAR_TARGET, color, 0, 0);
end;

procedure TDraw.Clear(x, y, w, h: Single; Color: D3DColor);
var
  Rec: TRect;
begin
  if (Device = nil) then Exit;

  Rec := Rect(Round(x), Round(y), Round(x + w), Round(y + h));
  Device.Clear(1, @Rec, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, color, 0, 0);
end;

procedure TDraw.Line(x1, y1, x2, y2, w: Single; Color: D3DColor);
var
  qV: array [1..2] of D3DXVECTOR2;
begin
  if (Device = nil) then Exit;

  qV[1].x := x1;
  qV[1].y := y1;
  qV[2].x := x2;
  qV[2].y := y2;

  g_Line.SetAntialias(True);
  g_Line.SetWidth(w);
  g_Line._begin;
    g_Line.Draw(@qV, 2, color);
  g_Line._End;
end;

procedure TDraw.Line(Pos1, Pos2: vec2_t; w: Single; Color: D3DColor);
begin
  if (Device = nil) then Exit;
  Draw.Line(Pos1.X, Pos1.y, Pos2.x, Pos2.y, w, Color);
end;

procedure TDraw.Line(Pos1, Pos2: vec3_t; w: Single; Color: D3DColor);
begin
  if (Device = nil) then Exit;
  Draw.Line(Pos1.X, Pos1.y, Pos2.x, Pos2.y, w, Color);
end;

end.
