//Kento Edition: 
//Add "Orange" Color
//Change yellow to x09
//MAX_MESSAGE_LENGTH 200 ~ 1000
#if defined _colors_included
 #endinput
#endif
#define _colors_included
 
#define MAX_MESSAGE_LENGTH 1000
#define MAX_COLORS 12

#define SERVER_INDEX 0
#define NO_INDEX -1
#define NO_PLAYER -2

enum Colors
{
 	Color_Default = 0,
	Color_Darkred,
	Color_Pink,
	Color_Green,
	Color_Yellow,
	Color_Red,
	Color_Gray,
	Color_Blue,
	Color_Darkblue,
	Color_Purple,
	Color_Lightgreen,
	Color_Orange,
}

/* Colors' properties */
char CTag[][] = 	  {"{NORMAL}", "{DARKRED}", "{PINK}", "{GREEN}", "{YELLOW}", "{LIGHTGREEN}", "{RED}", "{GRAY}",  "{BLUE}", "{DARKBLUE}", "{PURPLE}",  "{ORANGE}"};
char CTagCode[][] =  {"\x01",  	"\x02",   	"\x03",   "\x04",     "\x09",  		"\x06",  	 "\x07",   "\x08",    "\x0B",    "\x0C",      "\x0E",	"\x10"};
bool CTagReqSayText2[] = {false, false, false, false, false, false, false, false, false, false, false, false};
bool CEventIsHooked = false;
bool CSkipList[MAXPLAYERS+1] = {false,...};

/* Game default profile */
bool CProfile_Colors[] = {true, false, false, false, false, false, false, false, false, false, false, false};
int CProfile_TeamIndex[] = {NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX, NO_INDEX};
bool CProfile_SayText2 = false;

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags.
 *
 * @param client	  Client index.
 * @param szMessage   Message (formatting rules).
 * @return			  No return
 * 
 * On error/Errors:   If the client is not connected an error will be thrown.
 */
stock void CPrintToChat(int client, const char[] szMessage, any ...)
{
	if (client <= 0 || client > MaxClients)
		ThrowError("Invalid client index %d", client);
	
	if (!IsClientInGame(client))
		ThrowError("Client %d is not in game", client);
	
	char szBuffer[MAX_MESSAGE_LENGTH];
	char szCMessage[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(client);
	
	Format(szBuffer, sizeof(szBuffer), "\x01%s", szMessage);
	VFormat(szCMessage, sizeof(szCMessage), szBuffer, 3);
	
	int index = CFormat(szCMessage, sizeof(szCMessage));
	
	if (index == NO_INDEX)
		PrintToChat(client, "%s", szCMessage);
	else
		CSayText2(client, index, szCMessage);
}

stock void CReplyToCommand(int client, const char[] szMessage, any ...)
{
	
	char szCMessage[MAX_MESSAGE_LENGTH];
	VFormat(szCMessage, sizeof(szCMessage), szMessage, 3);
	
	if (client == 0)
	{
		CRemoveTags(szCMessage, sizeof(szCMessage));
		PrintToServer("%s", szCMessage);
	}
	else if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(szCMessage, sizeof(szCMessage));
		PrintToConsole(client, "%s", szCMessage);
	}
	else
	{
		CPrintToChat(client, "%s", szCMessage);
	}
}


/**
 * Prints a message to all clients in the chat area.
 * Supports color tags.
 *
 * @param client	  Client index.
 * @param szMessage   Message (formatting rules)
 * @return			  No return
 */
stock void CPrintToChatAll(const char[] szMessage, any ...)
{
	char szBuffer[MAX_MESSAGE_LENGTH];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && !CSkipList[i])
		{
			SetGlobalTransTarget(i);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 2);
			
			CPrintToChat(i, "%s", szBuffer);
		}
		
		CSkipList[i] = false;
	}
}

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param client	  Client index.
 * @param author	  Author index whose color will be used for teamcolor tag.
 * @param szMessage   Message (formatting rules).
 * @return			  No return
 * 
 * On error/Errors:   If the client or author are not connected an error will be thrown.
 */
stock void CPrintToChatEx(int client, int author, const char[] szMessage, any ...)
{
	if (client <= 0 || client > MaxClients)
		ThrowError("Invalid client index %d", client);
	
	if (!IsClientInGame(client))
		ThrowError("Client %d is not in game", client);
	
	if (author < 0 || author > MaxClients)
		ThrowError("Invalid client index %d", author);
	
	char szBuffer[MAX_MESSAGE_LENGTH];
	char szCMessage[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(client);
	
	Format(szBuffer, sizeof(szBuffer), "\x01%s", szMessage);
	VFormat(szCMessage, sizeof(szCMessage), szBuffer, 4);
	
	int index = CFormat(szCMessage, sizeof(szCMessage), author);
	
	if (index == NO_INDEX)
		PrintToChat(client, "%s", szCMessage);
	else
		CSayText2(client, author, szCMessage);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param author	  Author index whos color will be used for teamcolor tag.
 * @param szMessage   Message (formatting rules).
 * @return			  No return
 * 
 * On error/Errors:   If the author is not connected an error will be thrown.
 */
stock void CPrintToChatAllEx(int author, const char[] szMessage, any ...)
{
	if (author < 0 || author > MaxClients)
		ThrowError("Invalid client index %d", author);
	
	if (!IsClientInGame(author))
		ThrowError("Client %d is not in game", author);
	
	char szBuffer[MAX_MESSAGE_LENGTH];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && !CSkipList[i])
		{
			SetGlobalTransTarget(i);
			VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
			
			CPrintToChatEx(i, author, "%s", szBuffer);
		}
		
		CSkipList[i] = false;
	}
}

/**
 * Removes color tags from the string.
 *
 * @param szMessage   String.
 * @return			  No return
 */
stock void CRemoveTags(char[] szMessage, int maxlength)
{
	for (int i = 0; i < MAX_COLORS; i++)
		ReplaceString(szMessage, maxlength, CTag[i], "", false);
	
	ReplaceString(szMessage, maxlength, "{teamcolor}", "", false);
}

/**
 * Checks whether a color is allowed or not
 *
 * @param tag   		Color Tag.
 * @return			 	True when color is supported, otherwise false
 */
stock int CColorAllowed(Colors color)
{
	if (!CEventIsHooked)
	{
		CSetupProfile();
		
		CEventIsHooked = true;
	}
	
	return CProfile_Colors[color];
}

/**
 * Replace the color with another color
 * Handle with care!
 *
 * @param color   			color to replace.
 * @param newColor   		color to replace with.
 * @noreturn
 */
stock void CReplaceColor(Colors color, Colors newColor)
{
	if (!CEventIsHooked)
	{
		CSetupProfile();
		
		CEventIsHooked = true;
	}
	
	CProfile_Colors[color] = CProfile_Colors[newColor];
	CProfile_TeamIndex[color] = CProfile_TeamIndex[newColor];
	
	CTagReqSayText2[color] = CTagReqSayText2[newColor];
	Format(CTagCode[color], sizeof(CTagCode[]), CTagCode[newColor])
}

/**
 * This function should only be used right in front of
 * CPrintToChatAll or CPrintToChatAllEx and it tells
 * to those funcions to skip specified client when printing
 * message to all clients. After message is printed client will
 * no more be skipped.
 * 
 * @param client   Client index
 * @return		   No return
 */
stock void CSkipNextClient(int client)
{
	if (client <= 0 || client > MaxClients)
		ThrowError("Invalid client index %d", client);
	
	CSkipList[client] = true;
}

/**
 * Replaces color tags in a string with color codes
 *
 * @param szMessage   String.
 * @param maxlength   Maximum length of the string buffer.
 * @return			  Client index that can be used for SayText2 author index
 * 
 * On error/Errors:   If there is more then one team color is used an error will be thrown.
 */
stock int CFormat(char[] szMessage, int maxlength, int author=NO_INDEX)
{
	char szGameName[30];
	
	GetGameFolderName(szGameName, sizeof(szGameName));
	
	/* Hook event for auto profile setup on map start */
	if (!CEventIsHooked)
	{
		CSetupProfile();
		HookEvent("server_spawn", CEvent_MapStart, EventHookMode_PostNoCopy);
		
		CEventIsHooked = true;
	}
	
	int iRandomPlayer = NO_INDEX;
	
	// On CS:GO set invisible precolor
	if (StrEqual(szGameName, "csgo", false)) 
		Format(szMessage, maxlength, " \x01\x0B\x01%s", szMessage);
	
	/* If author was specified replace {teamcolor} tag */
	if (author != NO_INDEX)
	{
		if (CProfile_SayText2)
		{
			ReplaceString(szMessage, maxlength, "{teamcolor}", "\x03", false);
			
			iRandomPlayer = author;
		}
		/* If saytext2 is not supported by game replace {teamcolor} with green tag  */
		else
			ReplaceString(szMessage, maxlength, "{teamcolor}", CTagCode[Color_Green], false);
	}
	else
		ReplaceString(szMessage, maxlength, "{teamcolor}", "", false);
	
	/* For other color tags we need a loop */
	for (int i = 0; i < MAX_COLORS; i++)
	{
		/* If tag not found - skip */
		if (StrContains(szMessage, CTag[i], false) == -1)
			continue;
			
		/* If tag is not supported by game replace it with green tag */
		else if (!CProfile_Colors[i])
			ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green], false);
		
		/* If tag doesn't need saytext2 simply replace */
		else if (!CTagReqSayText2[i])
			ReplaceString(szMessage, maxlength, CTag[i], CTagCode[i], false);

		/* Tag needs saytext2 */
		else
		{
			/* If saytext2 is not supported by game replace tag with green tag */
			if (!CProfile_SayText2)
				ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green], false);
				
			/* Game supports saytext2 */
			else 
			{
				/* If random player for tag wasn't specified replace tag and find player */
				if (iRandomPlayer == NO_INDEX)
				{
					/* Searching for valid client for tag */
					iRandomPlayer = CFindRandomPlayerByTeam(CProfile_TeamIndex[i]);
					
					/* If player not found replace tag with green color tag */
					if (iRandomPlayer == NO_PLAYER)
						ReplaceString(szMessage, maxlength, CTag[i], CTagCode[Color_Green], false);

					/* If player was found simply replace */
					else
						ReplaceString(szMessage, maxlength, CTag[i], CTagCode[i], false);
					
				}
				/* If found another team color tag throw error */
				else
				{
					//ReplaceString(szMessage, maxlength, CTag[i], "");
					ThrowError("Using two team colors in one message is not allowed");
				}
			}
			
		}
	}
	
	return iRandomPlayer;
}

/**
 * Founds a random player with specified team
 *
 * @param color_team  Client team.
 * @return			  Client index or NO_PLAYER if no player found
 */
stock int CFindRandomPlayerByTeam(int color_team)
{
	if (color_team == SERVER_INDEX)
		return 0;
	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == color_team)
				return i;
		}	
	}

	return NO_PLAYER;
}

/**
 * Sends a SayText2 usermessage to a client
 *
 * @param szMessage   Client index
 * @param maxlength   Author index
 * @param szMessage   Message
 * @return			  No return.
 */
stock void CSayText2(int client, int author, const char[] szMessage)
{
	Handle hBuffer = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	
	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
	{
		PbSetInt(hBuffer, "ent_idx", author);
		PbSetBool(hBuffer, "chat", true);
		PbSetString(hBuffer, "msg_name", szMessage);
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
	}
	else
	{
		BfWriteByte(hBuffer, author);
		BfWriteByte(hBuffer, true);
		BfWriteString(hBuffer, szMessage);
	}
	
	EndMessage();
}

/**
 * Creates game color profile 
 * This function must be edited if you want to add more games support
 *
 * @return			  No return.
 */
stock void CSetupProfile()
{
	char szGameName[30];
	GetGameFolderName(szGameName, sizeof(szGameName));
	
	if (StrEqual(szGameName, "csgo", false))
	{
		CProfile_Colors[Color_Darkred] = true;
		CProfile_Colors[Color_Pink] = true;
		CProfile_Colors[Color_Green] = true;
		CProfile_Colors[Color_Yellow] = true;
		CProfile_Colors[Color_Red] = true;
		CProfile_Colors[Color_Gray] = true;
		CProfile_Colors[Color_Blue] = true;
		CProfile_Colors[Color_Darkblue] = true;
		CProfile_Colors[Color_Purple] = true;
		CProfile_Colors[Color_Lightgreen] = true;
		CProfile_Colors[Color_Orange] = true;
		CProfile_TeamIndex[Color_Red] = 2;
		CProfile_TeamIndex[Color_Blue] = 3;
		CProfile_SayText2 = true;
	}
	/* Profile for other games */
	else
	{
		if (GetUserMessageId("SayText2") == INVALID_MESSAGE_ID)
		{
			CProfile_SayText2 = false;
		}
		else
		{
			CProfile_Colors[Color_Red] = true;
			CProfile_Colors[Color_Blue] = true;
			CProfile_TeamIndex[Color_Red] = 2;
			CProfile_TeamIndex[Color_Blue] = 3;
			CProfile_SayText2 = true;
		}
	}
}

public Action CEvent_MapStart(Handle event, const char[] name, bool dontBroadcast)
{
	CSetupProfile();
	
	for (int i = 1; i <= MaxClients; i++)
		CSkipList[i] = false;
}