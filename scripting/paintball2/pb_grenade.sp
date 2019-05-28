public Action Event_GrenadeStarted(Handle event, const char[] name, bool dontBroadcast) 
{
	int entity = GetEventInt(event, "entityid");
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	StindingGlow(pos, GetClientTeam(client));
	
	int i;
	float TimerTime = 0.1;
	float angle = -180.0;
	
	for (i = 0; i < 21; i++)
	{
		DataPack pack;
		TimerTime += 0.1;
		angle += 20.0;
		CreateDataTimer(TimerTime, ShootGrenadeBullet, pack);
		pack.WriteCell(client);
		pack.WriteFloat(pos[0]);
		pack.WriteFloat(pos[1]);
		pack.WriteFloat(pos[2]);
		pack.WriteFloat(angle);
	}
	
	
	//Teleport explosion away
	float org[3];
	org[0] = 10000.0;
	org[1] = 10000.0;
	org[2] = 10000.0;
	TeleportEntity(entity, org, NULL_VECTOR, NULL_VECTOR);
	
	
}

public Action ShootGrenadeBullet(Handle timer, Handle pack)
{
	int client;
	float pos[3], ang;
	ResetPack(pack);
	client = ReadPackCell(pack);
	pos[0] = ReadPackFloat(pack);
	pos[1] = ReadPackFloat(pack);
	pos[2] = ReadPackFloat(pack);
	ang = ReadPackFloat(pack);
	
	BulletModelShoot(client, -1, "weapon_grenade", 120, pos, ang);
}


public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{	
	if(GRENADE_ENABLE == 1)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));

		int random = GetRandomInt(1, 100);
		if(random <= GRENADE_CHANCE)
			GivePlayerItem(client, "weapon_hegrenade");
		
		
		//int random2 = GetRandomInt(1, 100);
		
		
	}
	
	
}