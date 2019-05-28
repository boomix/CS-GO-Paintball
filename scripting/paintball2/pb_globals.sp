//Configs

#define MP7_RELOADTIME 		3.00
#define SHOOT_DELAY			0.00003
//#define BALL_GRAVITY		0.2
//#define BULLET_SPEED		1600.0

#define BALLMODEL 		"models/pb/red-ball.mdl"
#define BALLMODEL2 		"models/pb/blue-ball.mdl"
#define SHOTSOUND		"paintball/pbg.mp3"

#define SHOTENDSOUND	"paintball/pb1.mp3"
#define SHOTENDSOUND2	"paintball/pb3.mp3"

//End configs


#define LoopAllPlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
if(IsClientInGame(%1) && IsPlayerAlive(%1))


Handle GrenadeEnable;
Handle GranadeChance;

int GRENADE_ENABLE;
int GRENADE_CHANCE;


int g_iPlayerPrevButton[MAXPLAYERS + 1];
bool b_IsReloading[MAXPLAYERS + 1] = false;
bool b_JustFired[MAXPLAYERS + 1] = false;
int i_LastAmmo[MAXPLAYERS + 1];
int i_LastWeapon[MAXPLAYERS + 1];
bool b_JustTookWeapon[MAXPLAYERS + 1];
Handle WeaponTookTimer[MAXPLAYERS+1];


char g_PaintballConfig[PLATFORM_MAX_PATH + 1];

bool 	b_IsGunAutomic[MAXPLAYERS + 1];
bool 	b_HWShootable[MAXPLAYERS + 1];
float 	i_HWBulletSpeed[MAXPLAYERS + 1];
float 	f_HWBulletGravity[MAXPLAYERS + 1];
float 	f_HWAccuracy[MAXPLAYERS + 1];
//float 	f_HWRunningSpeed[MAXPLAYERS + 1];
float 	f_HWReloadingSpeed[MAXPLAYERS + 1];
float 	f_HWSwitchGunSpeed[MAXPLAYERS + 1];
float 	f_HWTimeBetweenShots[MAXPLAYERS + 1];
float 	f_HWJumpAccuracy[MAXPLAYERS + 1];

bool b_autowepswitch[MAXPLAYERS + 1];



//Set default values
public void OnClientPutInServer(int client)
{
	b_IsReloading[client] = false;
	b_JustFired[client] = false;
	b_JustTookWeapon[client] = false;
	WeaponTookTimer[client] = null;
	
	SDKHook(client, SDKHook_WeaponSwitchPost,	WeaponEquipPost);
	SDKHook(client, SDKHook_WeaponDrop,			WeaponDrop);
	
	QueryClientConVar(client, "cl_autowepswitch", ConVar_QueryClient);
	
}

void SetDefaultPlayerCvars(int client)
{
	b_IsReloading[client] = false;
	b_JustFired[client] = false;
	b_JustTookWeapon[client] = false;
	WeaponTookTimer[client] = null;
}
