#include <amxmodx>
#include <amxmisc>

#define PLUGIN "eXe Scoreboard Tags"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_message(get_user_msgid("ScoreAttrib"), "MessageScoreAttrib")
    register_message(get_user_msgid("ScoreInfo"), "MessageScoreInfo")
}

bool:is_vip(id)
{
    new flags = get_user_flags(id)

    if (!(flags & ADMIN_RESERVATION))
        return false

    if (flags & ADMIN_KICK)
        return false

    return true
}

public MessageScoreAttrib(msgId, msgDest, id)
{
    new player = get_msg_arg_int(1)

    if (player < 1 || player > MaxClients)
        return PLUGIN_CONTINUE

    if (!is_vip(player))
        return PLUGIN_CONTINUE

    new attrib = get_msg_arg_int(2)

    set_msg_arg_int(2, ARG_BYTE, attrib | 4)

    return PLUGIN_CONTINUE
}

public MessageScoreInfo(msgId, msgDest, id)
{
    new player = get_msg_arg_int(1)

    if (player < 1 || player > MaxClients)
        return PLUGIN_CONTINUE

    if (!(get_user_flags(player) & ADMIN_KICK))
        return PLUGIN_CONTINUE

    new name[40]
    get_msg_arg_string(6, name, charsmax(name))

    if (contain(name, "[ADMIN]") != -1)
        return PLUGIN_CONTINUE

    new tag[] = " [ADMIN]"
    new maxLen = 32 - strlen(tag)

    if (strlen(name) > maxLen)
        name[maxLen] = EOS

    new newName[40]
    formatex(newName, charsmax(newName), "%s%s", name, tag)

    set_msg_arg_string(6, newName)

    return PLUGIN_CONTINUE
}
