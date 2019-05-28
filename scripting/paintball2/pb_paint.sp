public void CreatePaint(float coords[3], int team, int client) 
{
	char bufferss[PLATFORM_MAX_PATH];

	if(team == CS_TEAM_CT) {
		bufferss = "paintball/pb_blue2";
	} else {
		bufferss = "paintball/pb_red2";	
	}
	
	int precacheId = PrecacheDecal(bufferss, true);
	
	TE_SetupBSPDecal(coords, precacheId);
	TE_SendToAll();
	
	/*
	decl Float:vecEyeAng[3];
	GetClientEyeAngles(client, vecEyeAng);
	
	if(vecEyeAng[1]>180.0)
	{
	    vecEyeAng[1]=vecEyeAng[1]-360;
	}
	
	decl Float:vecAng[3];
	vecAng[0]=90.0;
	vecAng[1]=0.0;
	vecAng[2]=-1*vecEyeAng[1];
	
	CreateSprite(0, "paintball/pb_blue2.vmt", coords, vecAng, 0.001, "150", 10.0);*/
}

TE_SetupBSPDecal(const Float:vecOrigin[3], index2) {
	TE_Start("World Decal");
	TE_WriteVector("m_vecOrigin",vecOrigin);
	TE_WriteNum("m_nIndex",index2);
}

stock CreateSprite(iClient, String:sprite[], Float:vOrigin[3], Float:fAng[3], Float:Scale, String:fps[], Float:fLifetime) 
{ 
    //new String:szTemp[64];  
    //Format(szTemp, sizeof(szTemp), "client%i", iClient); 
    //DispatchKeyValue(iClient, "targetname", szTemp); 
    
    new ent = CreateEntityByName("env_sprite"); 
    if (IsValidEdict(ent)) 
    { 
        new String:StrEntityName[64]; Format(StrEntityName, sizeof(StrEntityName), "env_sprite%i", ent); 
        DispatchKeyValue(ent, "model", sprite); 
        DispatchKeyValue(ent, "classname", "env_sprite");
        DispatchKeyValue(ent, "spawnflags", "1");
        DispatchKeyValueFloat(ent, "scale", Scale);
        DispatchKeyValue(ent, "rendermode", "1");
        DispatchKeyValue(ent, "rendercolor", "255 255 255");
        DispatchKeyValue(ent, "framerate", fps);
        DispatchKeyValueVector(ent, "Angles", fAng);
        DispatchSpawn(ent);
        
        TeleportEntity(ent, vOrigin, fAng, NULL_VECTOR); 
        
        CreateTimer(fLifetime, RemoveParticle, ent);
    } 
}

public Action:RemoveParticle(Handle:timer, any:particle)
{
    if(IsValidEdict(particle))
    {
        AcceptEntityInput(particle, "Deactivate");
        AcceptEntityInput(particle, "Kill");
    }
}