stock ShakeScreen(int client, float Amp=1.0)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		Handle message = StartMessageOne("Shake", client, 0);
		if(message != null)
		{
			PbSetInt(message, "command", 0);
			PbSetFloat(message, "local_amplitude", Amp);
			PbSetFloat(message, "frequency", 255.0);
			PbSetFloat(message, "duration", 0.2);
			EndMessage();
		}
	}
}