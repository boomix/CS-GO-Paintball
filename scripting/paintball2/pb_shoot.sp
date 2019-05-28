public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVelocity[3], float fAngles[3], int &iWeapon) 
{
	
	if(GameRules_GetProp("m_bFreezePeriod") == 0 && GetEntProp(client, Prop_Send, "m_bIsDefusing") == 0)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			
			//Get weapon data
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon > 0)
			{
				char WeaponName[128];
				GetEntityClassname(weapon, WeaponName, sizeof(WeaponName));	
				
				
				//Check if it is any paintball weapon
				if(!b_JustTookWeapon[client] && b_HWShootable[client])
				{
					
					int ammo = GetEntProp(weapon, Prop_Send, "m_iClip1");
					
					//Detect, when player wants to reload
					if(GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount") != 0 && GetPrimaryClipCount(weapon) != ammo)
					{
						if(iButtons & IN_RELOAD && !(g_iPlayerPrevButton[client] & IN_RELOAD) && !b_IsReloading[client] && !(iButtons & IN_ATTACK))
							WeaponReload(client, weapon);
							
						if(ammo == 0)
							WeaponReload(client, weapon);
					}
						
					//Detect if weapon just reloaded
					if(ammo > i_LastAmmo[client] && weapon == i_LastWeapon[client] && b_IsReloading[client])
						JustReloaded(client, weapon);
					
					//Shooting stuff
					if(!b_IsReloading[client] && ammo > 0 && !b_JustTookWeapon[client])
					{
						
						BlockRealShooting(weapon);
						
						if(!(g_iPlayerPrevButton[client] & IN_ATTACK) && iButtons & IN_ATTACK)
							ShootBullet(client, weapon, ammo);
		
						else if (iButtons & IN_ATTACK && b_IsGunAutomic[client])
							ShootBullet(client, weapon, ammo);
							
					}
					
					i_LastAmmo[client] 			= ammo;
					i_LastWeapon[client] 		= weapon;
					g_iPlayerPrevButton[client] = iButtons;
				
				}
				
			}
			
		}
		
	}
	
	return Plugin_Continue;
}


void ShootBullet(int client, int weapon, int ammo)
{
	if(!b_JustFired[client] && !b_IsReloading[client] && ammo > 0)
	{
		//Spam delay
		b_JustFired[client] = true;
		CreateTimer(f_HWTimeBetweenShots[client], AllowShootAgain, client);	
		
		//Set default stuff
		SetEntProp(client, Prop_Send, "m_iShotsFired", GetEntProp(client, Prop_Send, "m_iShotsFired") + 1);
		SetEntProp(weapon, Prop_Send, "m_iClip1", ammo - 1);
		
		//Burst enable
		BulletModelShoot(client, weapon);
		
	}
	
}

void BulletModelShoot(int client, int weapon, char weaponNames[120] = " ", int grenadeEntity = 0, float grenadePos[3] = {0.0, 0.0, 0.0}, float angz = 0.0)
{
	//Play shooting sound
	EmitSoundToAllAny(SHOTSOUND, client);  
	
	//Create main ball
	int ent = CreateEntityByName("decoy_projectile");
	DispatchSpawn(ent);
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	SetEntityGravity(ent, f_HWBulletGravity[client]);
	
	//Set ball model based on team
	if(GetClientTeam(client) == CS_TEAM_T) {
		SetEntityModel(ent, BALLMODEL);
		CreateGlow(ent, CS_TEAM_T);
	} else {
		SetEntityModel(ent, BALLMODEL2);
		CreateGlow(ent, CS_TEAM_CT);
	}
	
	//SetEntProp(ent, Prop_Send, "m_usSolidFlags", 12); // FSOLID_NOT_SOLID|FSOLID_TRIGGER 
	//SetEntProp(ent, Prop_Data, "m_nSolidType", 6); // SOLID_VPHYSICS 
	//SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1); // COLLISION_GROUP_DEBRIS  
	
	float final[3];
	float playerpos[3], playerangle[3], vecfwr[3], newvel[3];	

	if(grenadeEntity == 0)
	{
		//Shake player screen
		ShakeScreen(client, 2.0);
		
		//Shoot bullet
		GetClientEyePosition(client, playerpos);
		GetClientEyeAngles(client, playerangle);
		GetAngleVectors(playerangle, vecfwr, NULL_VECTOR, NULL_VECTOR);		
		NormalizeVector(vecfwr, newvel);
		ScaleVector(newvel, i_HWBulletSpeed[client]);
		
		AddInFrontOf(playerpos, playerangle, 20.0, final);
		
		//Accuracy
					
		if (GetEntityFlags(client) & FL_ONGROUND) {
 			
 			int random = GetRandomInt(1, 3);
			if(random == 1)
				newvel[0] += GetRandomFloat(0.0, f_HWAccuracy[client]);
			else if(random == 2) 
				newvel[0] -= GetRandomFloat(0.0, f_HWAccuracy[client]);
			random = GetRandomInt(1, 3);	
			if(random == 1)
				newvel[1] += GetRandomFloat(0.0, f_HWAccuracy[client]);
			else if(random == 2)
				newvel[1] -= GetRandomFloat(0.0, f_HWAccuracy[client]);
			random = GetRandomInt(1, 3);
			if(random == 1)
				newvel[2] += GetRandomFloat(0.0, f_HWAccuracy[client]);
			else if(random == 2)
				newvel[2] -= GetRandomFloat(0.0, f_HWAccuracy[client]);
		} 
		else {
			int random = GetRandomInt(1, 3);
			if(random == 1)
				newvel[0] += GetRandomFloat(0.0, f_HWJumpAccuracy[client]);
			else if(random == 2)
				newvel[0] -= GetRandomFloat(0.0, f_HWJumpAccuracy[client]);
			random = GetRandomInt(1, 3);
			if(random == 1)
				newvel[1] += GetRandomFloat(0.0, f_HWJumpAccuracy[client]);
			else if(random == 2)
				newvel[1] -= GetRandomFloat(0.0, f_HWJumpAccuracy[client]);
			random = GetRandomInt(1, 3);
			if(random == 1)
				newvel[2] += GetRandomFloat(0.0, f_HWJumpAccuracy[client]);
			else if(random == 2)
				newvel[2] -= GetRandomFloat(0.0, f_HWJumpAccuracy[client]);
				
		}

		
	} else {	
		
		//Grenade / DON'T TOCH CODE :]
		
		//GetEntPropVector(grenadeEntity, Prop_Send, "m_vecOrigin", final);
		final = grenadePos;
		
		//Generate random angles
		float ang[3];
		//GetClientEyeAngles(client, ang);
		ang[0] = GetRandomFloat(4.0, -35.0 );
		ang[1] = angz;
		ang[2] = 0.0;
		
		GetAngleVectors(ang, vecfwr, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecfwr, newvel);
		
		//Give the angle velocity
		ScaleVector(newvel, 500.0);
		
		//Reset grenade gravity
		SetEntityGravity(ent, 2.0);

	}
		
	//Track, when bullet toch something
	SDKHook(ent, SDKHook_StartTouch, BulletTochSomething);
	
	TeleportEntity(ent, final, NULL_VECTOR, newvel);
	
	//Set weapon shot with
	if(StrEqual(weaponNames, " "))
	{		
		char WeaponName[120];
		GetEntityClassname(weapon, WeaponName, sizeof(WeaponName));
		SetEntPropString(ent, Prop_Data, "m_iName", WeaponName);
		
		if(StrEqual(WeaponName, "weapon_awp"))
			CS_SwitchToWeapon(client, weapon);
		
	} else {
		SetEntPropString(ent, Prop_Data, "m_iName", weaponNames);
	}
}

public BulletTochSomething(int entity, int client) 
{
	
	//Check if with the bullet everything is fine
	if (!IsValidEntity(entity)) 
		return;

	//Check for window
	char classname[120];
	GetEntityClassname(client, classname, sizeof(classname));
	
	//PrintToChatAll("%s", classname);
	
	//Continiue to fly if toch vent, window
	if(StrContains(classname, "break") != -1 || StrContains(classname, "decoy") != -1)
		return;

	
	int shooter = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	//PrintToChatAll("%i hit %i", shooter, client);
	
	//Continiue to fly if touch himself
	if(client == shooter)
		return;
	
	//If shot a player
	if(0 < client <= MaxClients) {
		if(IsClientInGame(shooter))
		{
			if(GetClientTeam(client) == CS_TEAM_T && GetClientTeam(shooter) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_CT && GetClientTeam(shooter) == CS_TEAM_T) {
				if(IsClientInGame(client) && IsClientInGame(shooter) && IsPlayerAlive(client))
				{
					char WeaponName[120];
					GetEntPropString(entity, Prop_Data, "m_iName", WeaponName, sizeof(WeaponName));
					DealDamage(client, 100, shooter, DMG_VEHICLE, WeaponName);
				}
			}
		}
	}
	
	//Player random touch sound
	int random = GetRandomInt(1, 2);
	
	if(random == 1)
		EmitSoundToAllAny(SHOTENDSOUND, entity);
	else if(random == 2)
		EmitSoundToAllAny(SHOTENDSOUND2, entity);
		
	//Create end paint	
	float origin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
	if(GetClientTeam(shooter) == CS_TEAM_T)
		CreatePaint(origin, CS_TEAM_T, shooter);
	else
		CreatePaint(origin, CS_TEAM_CT, shooter);
	
	
	//Unhook ball
	SDKUnhook(entity, SDKHook_StartTouch, BulletTochSomething);
	
	//Kill ball entity
	AcceptEntityInput(entity, "kill");	

	
}






public Action AllowShootAgain(Handle tmr, any client)
{
	b_JustFired[client] = false;
} 


void WeaponReload(int client, int weapon)
{
	UnBlockRealShooting(weapon);
	b_IsReloading[client] = true;
}

void JustReloaded(int client, int weapon)
{
	BlockRealShooting(weapon);
	
	char WeaponName[128];
	GetEntityClassname(weapon, WeaponName, sizeof(WeaponName));	
	
	CreateTimer(f_HWReloadingSpeed[client], ReloadAnimationFinished, client);
}

public Action ReloadAnimationFinished(Handle tmr, any client)
{
	b_IsReloading[client] = false;
}

void BlockRealShooting(int weapon)
{
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", 2.0 + GetGameTime());
}

void UnBlockRealShooting(int weapon)
{
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() -2);
}

stock void AddInFrontOf(float vecOrigin[3], float vecAngle[3], float units, float output[3])
{
	float vecAngVectors[3];
	vecAngVectors = vecAngle; //Don't change input
	GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
	for (int i; i < 3; i++)
	output[i] = vecOrigin[i] + (vecAngVectors[i] * units);
}

stock DealDamage(nClientVictim, nDamage, nClientAttacker = 0, nDamageType = DMG_GENERIC, char sWeapon[] = "")
{
    if(nClientVictim > 0 && IsValidEntity(nClientVictim) && IsClientInGame(nClientVictim) && nDamage > 0) {
	    int EntityPointHurt = CreateEntityByName("point_hurt");
	    if(EntityPointHurt != 0)
	    {
            char sDamage[16];
            IntToString(nDamage, sDamage, sizeof(sDamage));

            char sDamageType[32];
            IntToString(nDamageType, sDamageType, sizeof(sDamageType));

            DispatchKeyValue(nClientVictim,                 "targetname",           "war3_hurtme");
            DispatchKeyValue(EntityPointHurt,               "DamageTarget", "war3_hurtme");
            DispatchKeyValue(EntityPointHurt,               "Damage",                               sDamage);
            DispatchKeyValue(EntityPointHurt,               "DamageType",           sDamageType);
            if(!StrEqual(sWeapon, ""))
                    DispatchKeyValue(EntityPointHurt,       "classname",            sWeapon);
            DispatchSpawn(EntityPointHurt);
            AcceptEntityInput(EntityPointHurt,      "Hurt",                                 (nClientAttacker != 0) ? nClientAttacker : -1);
            DispatchKeyValue(EntityPointHurt,               "classname",            "point_hurt");
            DispatchKeyValue(nClientVictim,                 "targetname",           "war3_donthurtme");

            RemoveEdict(EntityPointHurt);
	    }
    }
}



public void ConVar_QueryClient(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(IsClientInGame(client))
	{
		if(result == ConVarQuery_Okay)
		{
			b_autowepswitch[client] = StringToInt(cvarValue) ? true : false;
		}
	}
}

//Mega / giga function that no one knows about

void CS_SwitchToWeapon(int client, int weapon)
{
	//Check if autoswitch enabled
	if(b_autowepswitch[client])
	{
		
		CS_DropWeapon(client, weapon, false, false);
		EquipPlayerWeapon(client, weapon);
		
	} else {
		
		int WeaponToSwitch = -1;
		
		//Primary weapon
		int weapons = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
		if(weapons == weapon)
			WeaponToSwitch = weapons;
		if(weapons > 0)
			CS_DropWeapon(client, weapons, false, false);
			
		//Secondary
		int weapons2 = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
		if(weapons2 == weapon)
			WeaponToSwitch = weapons2;
		if(weapons2 > 0)
			CS_DropWeapon(client, weapons2, false, false);
		
		//Knife
		int weapons3 = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
		if(weapons3 == weapon)
			WeaponToSwitch = weapons3;
		if(weapons3 > 0)
			CS_DropWeapon(client, weapons3, false, false);
		
		//Grenade
		int weapons4 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
		if(weapons4 == weapon)
			WeaponToSwitch = weapons4;
		if(weapons4 > 0)
			CS_DropWeapon(client, weapons4, false, false);
		
		//Grenade x2
		int weapons5 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
		if(weapons5 == weapon)
			WeaponToSwitch = weapons5;
		if(weapons5 > 0)
			CS_DropWeapon(client, weapons5, false, false);
			
		//Grenade x3
		int weapons6 = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
		if(weapons6 == weapon)
			WeaponToSwitch = weapons6;
		if(weapons6 > 0)
			CS_DropWeapon(client, weapons6, false, false);
			
		//C4
		int weapons7 = GetPlayerWeaponSlot(client, CS_SLOT_C4);
		if(weapons7 == weapon)
			WeaponToSwitch = weapons7;
		if(weapons7 > 0)
			CS_DropWeapon(client, weapons7, false, false);
		
		//Switch to weapon
		if(WeaponToSwitch > 0)
			EquipPlayerWeapon(client, WeaponToSwitch);
		
		if(weapons > 0 && weapons != WeaponToSwitch)
			EquipPlayerWeapon(client, weapons);
		if(weapons2 > 0 && weapons2 != WeaponToSwitch)
		EquipPlayerWeapon(client, weapons2);
		if(weapons3 > 0 && weapons3 != WeaponToSwitch)
			EquipPlayerWeapon(client, weapons3);
		if(weapons4 > 0 && weapons4 != WeaponToSwitch)
			EquipPlayerWeapon(client, weapons4);
		if(weapons5 > 0 && weapons5 != WeaponToSwitch)
			EquipPlayerWeapon(client, weapons5);
		if(weapons6 > 0 && weapons6 != WeaponToSwitch)
			EquipPlayerWeapon(client, weapons6);
		if(weapons7 > 0 && weapons7 != WeaponToSwitch)
			EquipPlayerWeapon(client, weapons7);
		
		
	}	
	
}

int GetPrimaryClipCount(int weapon)
{
	char WeaponName[128];
	GetEntityClassname(weapon, WeaponName, sizeof(WeaponName));
	
	//Rifles and pistols
	if(	StrEqual(WeaponName, "weapon_ak47") || 
		StrEqual(WeaponName, "weapon_aug") || 
		StrEqual(WeaponName, "weapon_m4a1") || 
		StrEqual(WeaponName, "weapon_mac10") ||
		StrEqual(WeaponName, "weapon_mp7") ||
		StrEqual(WeaponName, "weapon_mp9") ||
		StrEqual(WeaponName, "weapon_sg556") ||
		StrEqual(WeaponName, "weapon_elite"))
		return 30;
	
	else if(StrEqual(WeaponName, "weapon_galilar"))
		return 35;
	
	else if(StrEqual(WeaponName, "weapon_famas") ||
			StrEqual(WeaponName, "weapon_ump45"))
		return 25;
		
	else if(StrEqual(WeaponName, "weapon_awp") || 
			StrEqual(WeaponName, "weapon_ssg08")) 
		return 10;
		
	else if(StrEqual(WeaponName, "weapon_awp") || 
			StrEqual(WeaponName, "weapon_ssg08") ||
			StrEqual(WeaponName, "weapon_fiveseven") ||
			StrEqual(WeaponName, "weapon_glock")) 
		return 20;
	
	else if(StrEqual(WeaponName, "weapon_m4a1_silencer")) 
		return 20;
		
	//PISTOLS	
		
	else if(StrEqual(WeaponName, "weapon_deagle"))
		return 7;
	
	else if(StrEqual(WeaponName, "weapon_revolver"))
		return 8;	
		
	else if(StrEqual(WeaponName, "weapon_revolver"))
		return 8;	
		
	else if(StrEqual(WeaponName, "weapon_hkp2000") || 
			StrEqual(WeaponName, "weapon_p250"))
		return 13;
		
	else if(StrEqual(WeaponName, "weapon_tec9"))
		return 8;	
	
	else if(StrEqual(WeaponName, "weapon_usp_silencer"))
		return 12;
		
	else
		return -1;
	
}