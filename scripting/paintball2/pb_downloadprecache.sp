public void OnConfigsExecuted()
{
	
	//Add sound files for download
	char SoundPath[250]; 
	Format(SoundPath, sizeof(SoundPath), "sound/%s", SHOTSOUND);
	AddFileToDownloadsTable(SoundPath);
	
	Format(SoundPath, sizeof(SoundPath), "sound/%s", SHOTENDSOUND);
	AddFileToDownloadsTable(SoundPath);
	Format(SoundPath, sizeof(SoundPath), "sound/%s", SHOTENDSOUND2);
	AddFileToDownloadsTable(SoundPath);
	
	
	//Add material files for download
	AddFileToDownloadsTable("models/pb/blue-ball.dx80.vtx");
	AddFileToDownloadsTable("models/pb/blue-ball.dx90.vtx");
	AddFileToDownloadsTable("models/pb/blue-ball.mdl");
	AddFileToDownloadsTable("models/pb/blue-ball.phy");
	AddFileToDownloadsTable("models/pb/blue-ball.sw.vtx");
	AddFileToDownloadsTable("models/pb/blue-ball.vvd");
	AddFileToDownloadsTable("models/pb/red-ball.dx80.vtx");
	AddFileToDownloadsTable("models/pb/red-ball.dx90.vtx");
	AddFileToDownloadsTable("models/pb/red-ball.mdl");
	AddFileToDownloadsTable("models/pb/red-ball.phy");
	AddFileToDownloadsTable("models/pb/red-ball.sw.vtx");
	AddFileToDownloadsTable("models/pb/red-ball.vvd");
	AddFileToDownloadsTable("materials/models/pb/blue-ball/blue.vmt");
	AddFileToDownloadsTable("materials/models/pb/red-ball/red.vmt");
	AddFileToDownloadsTable("materials/paintball/red.vmt");
	AddFileToDownloadsTable("materials/paintball/red.vtf");
	AddFileToDownloadsTable("materials/paintball/blue.vmt");
	AddFileToDownloadsTable("materials/paintball/blue.vtf");
	
	AddFileToDownloadsTable("materials/paintball/pb_red2.vmt");
	AddFileToDownloadsTable("materials/paintball/pb_red2.vtf");
	AddFileToDownloadsTable("materials/paintball/pb_blue2.vmt");
	AddFileToDownloadsTable("materials/paintball/pb_blue2.vtf");
	
	//Precache stuff
	PrecacheSoundAny(SHOTSOUND);
	PrecacheSoundAny(SHOTENDSOUND);
	PrecacheSoundAny(SHOTENDSOUND2);
	PrecacheModel(BALLMODEL);
	PrecacheModel(BALLMODEL2);
	//PrecacheModel("paintball/pb_blue2.vmt");
	PrecacheModel("sprites/ledglow.vmt");
	
	SetCvar("mp_ct_default_secondary", 	"weapon_glock");
	SetCvar("mp_t_default_secondary", 	"weapon_glock");
	SetCvar("mp_ct_default_primary", 	"weapon_mp7");
	SetCvar("mp_t_default_primary", 	"weapon_mp7");
	SetCvar("mp_buytime", 				"0");
	SetCvar("mp_maxmoney", 				"0");
	
	
	BuildPath(Path_SM, g_PaintballConfig, sizeof(g_PaintballConfig), "configs/paintball/weapons.txt");
	
	
}

public void OnMapStart()
{
	SetCvar("mp_ct_default_secondary", 	"weapon_glock");
	SetCvar("mp_t_default_secondary", 	"weapon_glock");
	SetCvar("mp_ct_default_primary", 	"weapon_mp7");
	SetCvar("mp_t_default_primary", 	"weapon_mp7");
	SetCvar("mp_buytime", 				"0");
	SetCvar("mp_maxmoney", 				"0");
}

stock void SetCvar(char[] scvar, char[] svalue)
{
	Handle cvar = FindConVar(scvar);
	SetConVarString(cvar, svalue, true);
	
	int flags = GetConVarFlags(cvar);
	SetConVarFlags(cvar, flags & ~FCVAR_NOTIFY);
}
