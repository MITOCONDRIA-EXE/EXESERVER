#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Admin Chat Color"
#define VERSION "1.0"
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

	if (get_user_flags(id) & ADMIN_KICK)
	{
		new szTeam[16]
		get_user_team(id, szTeam, charsmax(szTeam))

		format(szMessage, charsmax(szMessage), "^x04[ADMIN]^x03 %s^x01:  %s", szName, szMessage)

		new iPlayers[32], iNum
		get_players(iPlayers, iNum, "ch")

		for (new i = 0; i < iNum; i++)
		{
			message_begin(MSG_ONE, get_user_msgid("SayText"), _, iPlayers[i])
			write_byte(id)
			write_string(szMessage)
			message_end()
		}

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public hook_sayteam(id)
{
	new szMessage[192], szName[32]
	read_args(szMessage, charsmax(szMessage))
	remove_quotes(szMessage)

	if (!is_valid_message(szMessage))
		return PLUGIN_CONTINUE

	get_user_name(id, szName, charsmax(szName))

	if (get_user_flags(id) & ADMIN_KICK)
	{
		new szTeam[16]
		get_user_team(id, szTeam, charsmax(szTeam))

		format(szMessage, charsmax(szMessage), "^x04[ADMIN]^x03 %s^x01 (@Team):  %s", szName, szMessage)

		new iPlayers[32], iNum
		get_players(iPlayers, iNum, "ch")

		for (new i = 0; i < iNum; i++)
		{
			if (get_user_team(id) == get_user_team(iPlayers[i]))
			{
				message_begin(MSG_ONE, get_user_msgid("SayText"), _, iPlayers[i])
				write_byte(id)
				write_string(szMessage)
				message_end()
			}
		}

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

bool:is_valid_message(const szMessage[])
{
	if (strlen(szMessage) == 0)
		return false

	if (szMessage[0] == '/' || szMessage[0] == '!' || szMessage[0] == '@')
		return false

	return true
}
