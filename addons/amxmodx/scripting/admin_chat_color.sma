#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Admin Chat Color"
#define VERSION "1.2"
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

	new szFormatted[256]

	if (flags & ADMIN_RCON)
		formatex(szFormatted, charsmax(szFormatted), "^x04[OWNER] ^x03%s^x01:  %s", szName, szMessage)
	else if (flags & ADMIN_KICK)
		formatex(szFormatted, charsmax(szFormatted), "^x04[ADMIN] ^x03%s^x01:  %s", szName, szMessage)
	else
		formatex(szFormatted, charsmax(szFormatted), "^x04[VIP] ^x03%s^x01:  %s", szName, szMessage)

	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ch")
	for (new i = 0; i < iNum; i++)
		send_message(iPlayers[i], szFormatted, id)

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

	new szFormatted[256]

	if (flags & ADMIN_RCON)
		formatex(szFormatted, charsmax(szFormatted), "^x04[OWNER] ^x03%s^x01 (@Team):  %s", szName, szMessage)
	else if (flags & ADMIN_KICK)
		formatex(szFormatted, charsmax(szFormatted), "^x04[ADMIN] ^x03%s^x01 (@Team):  %s", szName, szMessage)
	else
		formatex(szFormatted, charsmax(szFormatted), "^x04[VIP] ^x03%s^x01 (@Team):  %s", szName, szMessage)

	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ch")

	for (new i = 0; i < iNum; i++)
	{
		if (get_user_team(id) == get_user_team(iPlayers[i]))
			send_message(iPlayers[i], szFormatted, id)
	}

	return PLUGIN_HANDLED
}

send_message(target, const msg[], sender = 0)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, target)
	write_byte(sender)
	write_string(msg)
	message_end()
}

bool:is_valid_message(const szMessage[])
{
	if (strlen(szMessage) == 0)
		return false
	if (szMessage[0] == '/' || szMessage[0] == '!' || szMessage[0] == '@')
		return false
	return true
}
