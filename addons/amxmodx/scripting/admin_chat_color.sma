#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Admin Chat Color"
#define VERSION "1.3"
#define AUTHOR "eXe Server"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say", "hook_say")
	register_clcmd("say_team", "hook_sayteam")
}

public hook_say(id)
{
	new szMessage[192], szName[32]
	read_args(szMessage, charsmax(szMessage))
	remove_quotes(szMessage)

	if (!is_valid_message(szMessage))
		return PLUGIN_CONTINUE

	get_user_name(id, szName, charsmax(szName))

	new flags = get_user_flags(id)
	if (!(flags & ADMIN_RESERVATION))
		return PLUGIN_CONTINUE

	if (flags & ADMIN_RCON)
	{
		client_print_color(0, print_team_red, "^x04[OWNER] %s^x01:  %s", szName, szMessage)
	}
	else if (flags & ADMIN_KICK)
	{
		new iPlayers[32], iNum
		get_players(iPlayers, iNum, "ch")
		for (new i = 0; i < iNum; i++)
			client_print_color(iPlayers[i], iPlayers[i], "^x04[ADMIN] %s^x01:  %s", szName, szMessage)
	}
	else
	{
		new iPlayers[32], iNum
		get_players(iPlayers, iNum, "ch")
		for (new i = 0; i < iNum; i++)
			client_print_color(iPlayers[i], print_team_blue, "^x04[VIP] %s^x01:  %s", szName, szMessage)
	}

	return PLUGIN_HANDLED
}

public hook_sayteam(id)
{
	new szMessage[192], szName[32]
	read_args(szMessage, charsmax(szMessage))
	remove_quotes(szMessage)

	if (!is_valid_message(szMessage))
		return PLUGIN_CONTINUE

	get_user_name(id, szName, charsmax(szName))

	new flags = get_user_flags(id)
	if (!(flags & ADMIN_RESERVATION))
		return PLUGIN_CONTINUE

	if (flags & ADMIN_RCON)
	{
		client_print_color(0, print_team_red, "^x04[OWNER] %s^x01 (@Team):  %s", szName, szMessage)
	}
	else if (flags & ADMIN_KICK)
	{
		new iPlayers[32], iNum
		get_players(iPlayers, iNum, "ch")
		for (new i = 0; i < iNum; i++)
		{
			if (get_user_team(id) == get_user_team(iPlayers[i]))
				client_print_color(iPlayers[i], iPlayers[i], "^x04[ADMIN] %s^x01 (@Team):  %s", szName, szMessage)
		}
	}
	else
	{
		new iPlayers[32], iNum
		get_players(iPlayers, iNum, "ch")
		for (new i = 0; i < iNum; i++)
		{
			if (get_user_team(id) == get_user_team(iPlayers[i]))
				client_print_color(iPlayers[i], print_team_blue, "^x04[VIP] %s^x01 (@Team):  %s", szName, szMessage)
		}
	}

	return PLUGIN_HANDLED
}

bool:is_valid_message(const szMessage[])
{
	if (strlen(szMessage) == 0)
		return false
	if (szMessage[0] == '/' || szMessage[0] == '!' || szMessage[0] == '@')
		return false
	return true
}
