#include <amxmodx>
#include <fakemeta>

#define PLUGIN "eXe Custom Flashlight"
#define VERSION "1.1"
#define AUTHOR "eXe Server"

// AJUSTES DE ILUMINACIÓN
new const FLASHLIGHT_COLOR[3] = { 160, 160, 160 } // Color (RGB). Valores más bajos = luz más tenue
#define FLASHLIGHT_RADIUS 8                        // Radio del punto (Antes era 16). Menor número = luz más chica
#define FLASHLIGHT_DECAY 2                         // Desvanecimiento al alejarse

new bool:g_bHasFlashlight[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_message(get_user_msgid("Flashlight"), "MessageFlashlight")
    register_forward(FM_CmdStart, "fw_CmdStart")
    register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
}

public client_disconnected(id)
{
    g_bHasFlashlight[id] = false
}

public MessageFlashlight(msgId, msgDest, id)
{
    return PLUGIN_HANDLED
}

public fw_CmdStart(id, uc_handle, seed)
{
    if (!is_user_alive(id))
        return FMRES_IGNORED

    new impulse = get_uc(uc_handle, UC_Impulse)

    if (impulse == 100)
    {
        g_bHasFlashlight[id] = !g_bHasFlashlight[id]
        
        emit_sound(id, CHAN_ITEM, "items/flashlight1.wav", 0.4, ATTN_NORM, 0, PITCH_NORM)

        set_uc(uc_handle, UC_Impulse, 0)
        return FMRES_HANDLED
    }

    return FMRES_IGNORED
}

public fw_PlayerPreThink(id)
{
    if (!is_user_alive(id) || !g_bHasFlashlight[id])
        return FMRES_IGNORED

    new Float:origin[3], Float:viewOfs[3], Float:start[3], Float:aim[3], Float:end[3]

    pev(id, pev_origin, origin)
    pev(id, pev_view_ofs, viewOfs)
    
    start[0] = origin[0] + viewOfs[0]
    start[1] = origin[1] + viewOfs[1]
    start[2] = origin[2] + viewOfs[2]

    velocity_by_aim(id, 1000, aim)

    end[0] = start[0] + aim[0]
    end[1] = start[1] + aim[1]
    end[2] = start[2] + aim[2]

    new tr = create_tr2()
    engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, id, tr)

    new Float:endPos[3]
    get_tr2(tr, TR_vecEndPos, endPos)
    free_tr2(tr)

    // Proyección de luz suavizada
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_DLIGHT)
    engfunc(EngFunc_WriteCoord, endPos[0])
    engfunc(EngFunc_WriteCoord, endPos[1])
    engfunc(EngFunc_WriteCoord, endPos[2])
    write_byte(FLASHLIGHT_RADIUS)              // Radio ajustado
    write_byte(FLASHLIGHT_COLOR[0])            // R
    write_byte(FLASHLIGHT_COLOR[1])            // G
    write_byte(FLASHLIGHT_COLOR[2])            // B
    write_byte(1)                              // Vida
    write_byte(FLASHLIGHT_DECAY)               // Decay
    message_end()

    return FMRES_IGNORED
}