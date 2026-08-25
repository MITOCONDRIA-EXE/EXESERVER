#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <reapi>

new bool:g_bAutoMenu[33]
new bool:g_bUsado[33]
new g_iComboSelected[33]

enum _:WeaponCombo
{
    WC_Name[24],
    WC_W1[20],
    WC_W2[20],
    WC_CSW1,
    WC_CSW2,
    WC_Ammo1,
    WC_Ammo2
}

new const gCombos[][WeaponCombo] =
{
    { "AK-47 + Deagle", "weapon_ak47", "weapon_deagle", CSW_AK47, CSW_DEAGLE, 90, 35 },
    { "M4A1 + Deagle", "weapon_m4a1", "weapon_deagle", CSW_M4A1, CSW_DEAGLE, 90, 35 },
    { "AWP + USP", "weapon_awp", "weapon_usp", CSW_AWP, CSW_USP, 30, 48 },
    { "FAMAS + Glock", "weapon_famas", "weapon_glock18", CSW_FAMAS, CSW_GLOCK18, 75, 120 },
    { "Galil + Deagle", "weapon_galil", "weapon_deagle", CSW_GALIL, CSW_DEAGLE, 90, 35 },
    { "AK-47 + USP", "weapon_ak47", "weapon_usp", CSW_AK47, CSW_USP, 90, 48 },
    { "AWP + Deagle", "weapon_awp", "weapon_deagle", CSW_AWP, CSW_DEAGLE, 30, 35 },
    { "M4A1 + Glock", "weapon_m4a1", "weapon_glock18", CSW_M4A1, CSW_GLOCK18, 90, 120 }
}

public plugin_init()
{
    register_plugin("Menu de Armas", "1.5", "MITO")

    register_clcmd("say /armas", "cmd_armas")
    register_clcmd("say armas", "cmd_armas")

    RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn", 1)
}

public client_putinserver(id)
{
    g_bAutoMenu[id] = true
    g_bUsado[id] = false
    g_iComboSelected[id] = 0
}

public client_disconnected(id)
{
    remove_task(id)

    g_bAutoMenu[id] = false
    g_bUsado[id] = false
    g_iComboSelected[id] = 0
}

public fw_PlayerSpawn(id)
{
    if (!is_user_connected(id))
        return

    g_bUsado[id] = false
    g_iComboSelected[id] = 0

    remove_task(id)

    if (g_bAutoMenu[id])
        set_task(0.5, "show_menu_armas", id)
}

public cmd_armas(id)
{
    if (!is_user_connected(id))
        return PLUGIN_HANDLED

    g_bAutoMenu[id] = !g_bAutoMenu[id]

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Menu de armas al spawnear: %s",
        g_bAutoMenu[id] ? "^4ACTIVADO" : "^4DESACTIVADO"
    )

    return PLUGIN_HANDLED
}

public show_menu_armas(id)
{
    if (!is_user_connected(id))
        return PLUGIN_HANDLED

    if (!is_user_alive(id))
    {
        client_print_color(
            id,
            print_team_default,
            "^4[eXe]^1 Tenes que estar vivo para ^3elegir armas."
        )

        return PLUGIN_HANDLED
    }

    if (g_bUsado[id])
    {
        client_print_color(
            id,
            print_team_default,
            "^4[eXe]^1 Ya has elegido ^3armas esta ronda."
        )

        return PLUGIN_HANDLED
    }

    new menu = menu_create(
        "\yCombos de Armas\w:",
        "menu_armas_handler"
    )

    for (new i = 0; i < sizeof(gCombos); i++)
        menu_additem(menu, gCombos[i][WC_Name])

    menu_setprop(menu, MPROP_EXITNAME, "Salir")
    menu_display(id, menu)

    return PLUGIN_HANDLED
}

public menu_armas_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    if (!is_user_alive(id))
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    if (g_bUsado[id])
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    if (item < 0 || item >= sizeof(gCombos))
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    g_iComboSelected[id] = item
    g_bUsado[id] = true

    remove_task(id)

    set_task(0.10, "task_give_combo", id)

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Armas: ^3%s",
        gCombos[item][WC_Name]
    )

    menu_destroy(menu)

    return PLUGIN_HANDLED
}


public task_give_combo(id)
{
    if (!is_user_alive(id))
        return

    new combo = g_iComboSelected[id]

    if (combo < 0 || combo >= sizeof(gCombos))
        return

    rg_remove_items_by_slot(id, PRIMARY_WEAPON_SLOT)
    rg_remove_items_by_slot(id, PISTOL_SLOT)

    give_item(id, gCombos[combo][WC_W1])
    give_item(id, gCombos[combo][WC_W2])

    cs_set_user_bpammo(id, gCombos[combo][WC_CSW1], gCombos[combo][WC_Ammo1])
    cs_set_user_bpammo(id, gCombos[combo][WC_CSW2], gCombos[combo][WC_Ammo2])

    rg_remove_items_by_slot(id, GRENADE_SLOT)

    give_item(id, "weapon_hegrenade")
    give_item(id, "weapon_flashbang")
    give_item(id, "weapon_flashbang")
    give_item(id, "weapon_smokegrenade")

    cs_set_user_bpammo(id, CSW_HEGRENADE, 1)
    cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
    cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 1)
}
