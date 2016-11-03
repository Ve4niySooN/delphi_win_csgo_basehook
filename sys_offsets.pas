unit sys_offsets;

interface

uses SysUtils, Windows, Math, Winapi.D3DX9, Winapi.Direct3D9, sys_cvars;

const
  P_TARGET        = -2;
  P_LOCAL         = -1;
  P_INVALID       = 0;

  TR_SHOT         = $46004003;
  TR_VISIBLE      = $4600400B;

var
  o_LocalPlayer:  Cardinal = $0;
  o_EntityList:   Cardinal = $0;
  o_ViewMatrix:   Cardinal = $0;
  o_RadarBase:    Cardinal = $0;
  o_GlowObject:   Cardinal = $0;
  o_GameResource: Cardinal = $0;
  o_ClientState:  Cardinal = $0;
  o_GlobalVars:   Cardinal = $0;
  o_ForceAttack:  Cardinal = $0;

const
  m_viewAngles          = $4D0C;

  m_iifestate           = $25B;
  m_iRadar              = $54;
  m_iBoneMatrix         = $2698;
  m_iIndex              = $64;
  m_iValid              = $e9;

  m_hOwnerEntity        = $148;
  m_bSpotted            = $939;
  m_bSpottedByMask      = $97C;
  m_vecOrigin           = $134;
  m_iTeamNum            = $F0;

  m_vecViewOffset       = $104;
  m_fFlags              = $100;
  m_vecVelocity         = $110;

  m_iHealth             = $FC;
  m_iArmor              = $A9F8;

  m_angEyeAngles        = $A9FC;

  m_vecPunch            = $301C;
  m_inScope             = $389C;
  m_inWalk              = $389D;

  m_hActiveWeapon         = $2EE8;
  m_AttributeManager      = $2D70;
  m_Item                  = $2DB0;
  m_iItemDefinitionIndex  = $2F88;
  m_InReload              = $3245;

  m_Shots                 = $A2C0;


implementation


end.

