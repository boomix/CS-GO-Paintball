public CreateGlow(int entity, int team) {

	float clientposition[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", clientposition);
	clientposition[2] += 40.0;
	
	
	int GLOW_ENTITY = CreateEntityByName("env_glow");
	SetEntProp(GLOW_ENTITY, Prop_Data, "m_nBrightness", 2, 4);
	
	DispatchKeyValue(GLOW_ENTITY, "model", "sprites/ledglow.vmt");
		
	if(team == CS_TEAM_T) {
		DispatchKeyValue(GLOW_ENTITY, "rendercolor", "255 0 0 10");	
		DispatchKeyValue(GLOW_ENTITY, "rendermode", "3");
		DispatchKeyValue(GLOW_ENTITY, "renderfx", "14");
		DispatchKeyValue(GLOW_ENTITY, "scale", "0.1");
		DispatchKeyValue(GLOW_ENTITY, "renderamt", "255");
	} else if(team == CS_TEAM_CT) {
		DispatchKeyValue(GLOW_ENTITY, "rendermode", "3");
		DispatchKeyValue(GLOW_ENTITY, "renderfx", "14");
		DispatchKeyValue(GLOW_ENTITY, "scale", "1");
		DispatchKeyValue(GLOW_ENTITY, "renderamt", "255");
		DispatchKeyValue(GLOW_ENTITY, "rendercolor", "0 0 255 255");
	}
	DispatchSpawn(GLOW_ENTITY);
	AcceptEntityInput(GLOW_ENTITY, "ShowSprite");
	clientposition[2] += -42;
	TeleportEntity(GLOW_ENTITY, clientposition, NULL_VECTOR, NULL_VECTOR);
	
	char target[20];
	FormatEx(target, sizeof(target), "glowclient_%d", entity);
	DispatchKeyValue(entity, "targetname", target);
	SetVariantString(target);
	AcceptEntityInput(GLOW_ENTITY, "SetParent");
	AcceptEntityInput(GLOW_ENTITY, "TurnOn");

}

public StindingGlow(float pos[3], int team) {
	
	int GLOW_ENTITY = CreateEntityByName("env_glow");
	SetEntProp(GLOW_ENTITY, Prop_Data, "m_nBrightness", 2, 4);
	
	DispatchKeyValue(GLOW_ENTITY, "model", "sprites/ledglow.vmt");
		
	if(team == CS_TEAM_T) {
		DispatchKeyValue(GLOW_ENTITY, "rendercolor", "255 0 0 150");	
		DispatchKeyValue(GLOW_ENTITY, "rendermode", "3");
		DispatchKeyValue(GLOW_ENTITY, "renderfx", "255");
		DispatchKeyValue(GLOW_ENTITY, "scale", "0.5");
		DispatchKeyValue(GLOW_ENTITY, "renderamt", "255");
	} else if(team == CS_TEAM_CT) {
		DispatchKeyValue(GLOW_ENTITY, "rendercolor", "0 0 255 255");
		DispatchKeyValue(GLOW_ENTITY, "rendermode", "3");
		DispatchKeyValue(GLOW_ENTITY, "renderfx", "255");
		DispatchKeyValue(GLOW_ENTITY, "scale", "3");
		DispatchKeyValue(GLOW_ENTITY, "renderamt", "255");
	}
	
	DispatchSpawn(GLOW_ENTITY);
	AcceptEntityInput(GLOW_ENTITY, "ShowSprite");
	TeleportEntity(GLOW_ENTITY, pos, NULL_VECTOR, NULL_VECTOR);
	
	CreateTimer(2.7, RemoveEntityTmr, GLOW_ENTITY);

}

public Action RemoveEntityTmr(Handle tmr, any entity)
{
	if(IsValidEntity(entity))
		AcceptEntityInput(entity, "Kill");
}

