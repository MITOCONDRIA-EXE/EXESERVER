#include <amxmodx>
#include <amxmisc>

#define PLUGIN "eXe Scoreboard Tags"
#define VERSION "3.0"
#define AUTHOR "eXe Server"

#define SCOREATTRIB_VIP (1<<2)

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    // Intercepta la actualización de la tabla de puntuación (TAB)
    register_message(get_user_msgid("ScoreAttrib"), "MessageScoreAttrib")
}

// Verifica si el jugador debe llevar el texto "VIP" en el TAB (VIP o Admin)
bool:should_have_vip_tab(id)
{
    if (!is_user_connected(id))
        return false

    new flags = get_user_flags(id)

    // Acepta Flag 'b' (VIP) o Flag 'c' (ADMIN)
    return ((flags & ADMIN_RESERVATION) || (flags & ADMIN_KICK))
}

// Añade el texto "VIP" en la columna de estado del TAB mientras estén vivos
public MessageScoreAttrib(msgId, msgDest, id)
{
    new player = get_msg_arg_int(1)

    if (player < 1 || player > MaxClients)
        return PLUGIN_CONTINUE

    if (!should_have_vip_tab(player))
        return PLUGIN_CONTINUE

    new attrib = get_msg_arg_int(2)

    // Si el jugador está vivo (no tiene la marca 1 = DEAD), forzamos VIP (4)
    if (!(attrib & 1))
    {
        set_msg_arg_int(2, ARG_BYTE, attrib | SCOREATTRIB_VIP)
    }

    return PLUGIN_CONTINUE
}

// Diferenciación: Agrega [ADMIN] al nombre del jugador si tiene Flag 'c'
public client_putinserver(id)
{
    if (!is_user_connected(id))
        return

    // Si el usuario es ADMIN (Flag 'c')
    if (get_user_flags(id) & ADMIN_KICK)
    {
        set_task(1.0, "AddAdminTag", id)
    }
}

public AddAdminTag(id)
{
    if (!is_user_connected(id))
        return

    new name[32]
    get_user_name(id, name, charsmax(name))

    // Evita duplicar la etiqueta si ya la tiene puesta
    if (containi(name, "[ADMIN]") != -1)
        return

    new tag[] = " [ADMIN]"
    new maxLen = 31 - strlen(tag)

    if (strlen(name) > maxLen)
        name[maxLen] = EOS

    new newName[32]
    formatex(newName, charsmax(newName), "%s%s", name, tag)

    // Actualiza el nombre en el servidor para que se refleje en el TAB
    set_user_info(id, "name", newName)
}