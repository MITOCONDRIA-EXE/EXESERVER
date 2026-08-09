#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <sqlx>

#define PLUGIN_NAME        "eXe VIP System"
#define PLUGIN_VERSION     "1.0.0"
#define PLUGIN_AUTHOR      "eXe"

#define VIP_DATABASE       "vip_system"
#define VIP_TABLE          "vip_players"

#define VIP_DEFAULT_DAYS   30
#define VIP_ADMIN_FLAG     ADMIN_RCON

#define VIP_TAG            "[VIP]"

new Handle:g_SqlTuple;

new bool:g_IsVip[33];
new g_VipExpire[33];

new const g_VipBenefits[][] =
{
    "Tag VIP",
    "Modelos VIP",
    "Skins de armas",
    "Posibilidad de postularte a admin"
};

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    register_clcmd("say /vip", "cmdVip");
    register_clcmd("say_team /vip", "cmdVip");

    register_concmd("amx_vip_add", "cmdVipAdd", VIP_ADMIN_FLAG, "<jugador> <dias> - Otorga o renueva VIP");
    register_concmd("amx_vip_remove", "cmdVipRemove", VIP_ADMIN_FLAG, "<jugador> - Elimina el VIP");
    register_concmd("amx_vip_check", "cmdVipCheck", VIP_ADMIN_FLAG, "<jugador> - Consulta el VIP");

    register_clcmd("say /vipinfo", "cmdVip");
    register_clcmd("say_team /vipinfo", "cmdVip");

    set_task(60.0, "taskCheckVipExpiration", .flags = "b");

    initializeDatabase();
}

public plugin_end()
{
    if (g_SqlTuple != Empty_Handle)
    {
        SQL_FreeHandle(g_SqlTuple);
    }
}

public client_putinserver(id)
{
    g_IsVip[id] = false;
    g_VipExpire[id] = 0;

    if (is_user_bot(id) || is_user_hltv(id))
    {
        return;
    }

    set_task(2.0, "taskLoadVip", id);
}

public client_disconnected(id)
{
    remove_task(id);

    g_IsVip[id] = false;
    g_VipExpire[id] = 0;
}
public taskLoadVip(id)
{
    if (!is_user_connected(id))
    {
        return;
    }

    loadVip(id);
}

initializeDatabase()
{
    g_SqlTuple = SQL_MakeDbTuple("", "", "", VIP_DATABASE);

    new errorCode;
    new errorMessage[512];

    new Handle:connection = SQL_Connect(
        g_SqlTuple,
        errorCode,
        errorMessage,
        charsmax(errorMessage)
    );

    if (connection == Empty_Handle)
    {
        log_amx(
            "[VIP] Error conectando a SQLite. Codigo: %d. Error: %s",
            errorCode,
            errorMessage
        );

        return;
    }

    new query[1024];

    formatex(
        query,
        charsmax(query),
        "CREATE TABLE IF NOT EXISTS %s (authid TEXT PRIMARY KEY, expire INTEGER NOT NULL DEFAULT 0)",
        VIP_TABLE
    );

    new Handle:result = SQL_PrepareQuery(connection, query);

    if (!SQL_Execute(result))
    {
        new sqlError[512];

        SQL_QueryError(
            result,
            sqlError,
            charsmax(sqlError)
        );

        log_amx("[VIP] Error creando tabla: %s", sqlError);
    }

    SQL_FreeHandle(result);
    SQL_FreeHandle(connection);

    log_amx("[VIP] Base de datos inicializada correctamente.");
}

loadVip(id)
{
    new authid[35];

    get_user_authid(id, authid, charsmax(authid));

    if (equal(authid, "STEAM_ID_PENDING") || equal(authid, "VALVE_ID_LAN"))
    {
        set_task(3.0, "taskLoadVip", id);
        return;
    }

    new query[256];

    formatex(
        query,
        charsmax(query),
        "SELECT expire FROM %s WHERE authid='%s'",
        VIP_TABLE,
        authid
    );

    new data[1];
    data[0] = id;

    SQL_ThreadQuery(
        g_SqlTuple,
        "queryLoadVip",
        query,
        data,
        sizeof(data)
    );
}

public queryLoadVip(
    failState,
    Handle:query,
    errorCode,
    errorMessage[],
    errorData[],
    dataSize,
    Float:queueTime
)
{
    new id = errorData[0];

    if (failState != TQUERY_SUCCESS)
    {
        log_amx(
            "[VIP] Error SQL cargando VIP. Codigo: %d. Error: %s",
            errorCode,
            errorMessage
        );

        return;
    }

    if (!is_user_connected(id))
    {
        return;
    }

    g_IsVip[id] = false;
    g_VipExpire[id] = 0;

    if (SQL_NumResults(query) > 0)
    {
        new expire = SQL_ReadResult(query, 0);

        g_VipExpire[id] = expire;

        if (expire > get_systime())
        {
            g_IsVip[id] = true;

            setVipTag(id);

            set_task(
                3.0,
                "taskShowVipWelcome",
                id
            );
        }
    }
}

public taskShowVipWelcome(id)
{
    if (!is_user_connected(id) || !g_IsVip[id])
    {
        return;
    }

    new remaining[128];

    getRemainingTime(
        g_VipExpire[id],
        remaining,
        charsmax(remaining)
    );

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Tu ^3VIP^1 esta activo. Tiempo restante: ^3%s^1.",
        remaining
    );

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Escribi ^3/vip^1 para consultar tu vencimiento y beneficios."
    );
}

public cmdVip(id)
{
    if (!is_user_connected(id))
    {
        return PLUGIN_HANDLED;
    }

    showVipMenu(id);

    return PLUGIN_HANDLED;
}

showVipMenu(id)
{
    new menu = menu_create(
        "VIP eXe",
        "handleVipMenu"
    );

    if (g_IsVip[id] && g_VipExpire[id] > get_systime())
    {
        new remaining[128];
        new expireDate[64];

        getRemainingTime(
            g_VipExpire[id],
            remaining,
            charsmax(remaining)
        );

        format_time(
            expireDate,
            charsmax(expireDate),
            "%d/%m/%Y %H:%M",
            g_VipExpire[id]
        );

        new item[256];

        formatex(
            item,
            charsmax(item),
            "Estado: \yACTIVO^n\wVence: \y%s^n\wRestante: \y%s",
            expireDate,
            remaining
        );

        menu_additem(
            menu,
            item,
            "1"
        );

        menu_addblank(menu);

        formatex(
            item,
            charsmax(item),
            "\wBeneficios VIP"
        );

        menu_additem(
            menu,
            item,
            "2"
        );

        for (new i = 0; i < sizeof(g_VipBenefits); i++)
        {
            formatex(
                item,
                charsmax(item),
                "\w- %s",
                g_VipBenefits[i]
            );

            menu_additem(
                menu,
                item,
                "3"
            );
        }

        menu_setprop(
            menu,
            MPROP_EXITNAME,
            "Cerrar"
        );

        menu_display(id, menu);

        return;
    }

    new item[256];

    formatex(
        item,
        charsmax(item),
        "Estado: \rNO TIENES VIP^n\wPrecio: \y$2000 ARS"
    );

    menu_additem(
        menu,
        item,
        "1"
    );

    menu_addblank(menu);

    menu_additem(
        menu,
        "\wContacta con un admin para adquirirlo.",
        "2"
    );

    menu_setprop(
        menu,
        MPROP_EXITNAME,
        "Cerrar"
    );

    menu_display(id, menu);
}

public handleVipMenu(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    menu_destroy(menu);

    return PLUGIN_HANDLED;
}

public cmdVipAdd(id, level, cid)
{
    if (!cmd_access(id, level, cid, 3))
    {
        return PLUGIN_HANDLED;
    }

    new targetName[64];
    new daysArgument[16];

    read_argv(1, targetName, charsmax(targetName));
    read_argv(2, daysArgument, charsmax(daysArgument));

    new days = str_to_num(daysArgument);

    if (days <= 0)
    {
        console_print(
            id,
            "[VIP] La cantidad de dias debe ser mayor a 0."
        );

        return PLUGIN_HANDLED;
    }

    new target = findPlayerByName(targetName);

    if (!target)
    {
        console_print(
            id,
            "[VIP] No se encontro al jugador: %s",
            targetName
        );

        return PLUGIN_HANDLED;
    }

    addVip(target, days);

    new targetRealName[64];

    get_user_name(
        target,
        targetRealName,
        charsmax(targetRealName)
    );

    console_print(
        id,
        "[VIP] Se otorgaron %d dias de VIP a %s.",
        days,
        targetRealName
    );

    return PLUGIN_HANDLED;
}

public cmdVipRemove(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
    {
        return PLUGIN_HANDLED;
    }

    new targetName[64];

    read_argv(
        1,
        targetName,
        charsmax(targetName)
    );

    new target = findPlayerByName(targetName);

    if (!target)
    {
        console_print(
            id,
            "[VIP] No se encontro al jugador: %s",
            targetName
        );

        return PLUGIN_HANDLED;
    }

    removeVip(target);

    new targetRealName[64];

    get_user_name(
        target,
        targetRealName,
        charsmax(targetRealName)
    );

    console_print(
        id,
        "[VIP] VIP eliminado de %s.",
        targetRealName
    );

    return PLUGIN_HANDLED;
}

public cmdVipCheck(id, level, cid)
{
    if (!cmd_access(id, level, cid, 2))
    {
        return PLUGIN_HANDLED;
    }

    new targetName[64];

    read_argv(
        1,
        targetName,
        charsmax(targetName)
    );

    new target = findPlayerByName(targetName);

    if (!target)
    {
        console_print(
            id,
            "[VIP] No se encontro al jugador: %s",
            targetName
        );

        return PLUGIN_HANDLED;
    }

    new name[64];

    get_user_name(
        target,
        name,
        charsmax(name)
    );

    if (!g_IsVip[target] || g_VipExpire[target] <= get_systime())
    {
        console_print(
            id,
            "[VIP] %s no tiene VIP activo.",
            name
        );

        return PLUGIN_HANDLED;
    }

    new expireDate[64];
    new remaining[128];

    format_time(
        expireDate,
        charsmax(expireDate),
        "%d/%m/%Y %H:%M",
        g_VipExpire[target]
    );

    getRemainingTime(
        g_VipExpire[target],
        remaining,
        charsmax(remaining)
    );

    console_print(
        id,
        "[VIP] %s | Vence: %s | Restante: %s",
        name,
        expireDate,
        remaining
    );

    return PLUGIN_HANDLED;
}

addVip(id, days)
{
    if (!is_user_connected(id))
    {
        return;
    }

    new authid[35];

    get_user_authid(
        id,
        authid,
        charsmax(authid)
    );

    new currentTime = get_systime();
    new currentExpire = g_VipExpire[id];

    if (currentExpire < currentTime)
    {
        currentExpire = currentTime;
    }

    new newExpire = currentExpire + (days * 86400);

    new query[512];

    formatex(
        query,
        charsmax(query),
        "INSERT OR REPLACE INTO %s (authid, expire) VALUES ('%s', %d)",
        VIP_TABLE,
        authid,
        newExpire
    );

    SQL_ThreadQuery(
        g_SqlTuple,
        "queryVipUpdate",
        query
    );

    g_VipExpire[id] = newExpire;
    g_IsVip[id] = true;

    setVipTag(id);

    new remaining[128];

    getRemainingTime(
        newExpire,
        remaining,
        charsmax(remaining)
    );

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Tu ^3VIP^1 fue activado/renovado por ^3%d dias^1.",
        days
    );

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Tiempo restante: ^3%s^1.",
        remaining
    );
}

removeVip(id)
{
    if (!is_user_connected(id))
    {
        return;
    }

    new authid[35];

    get_user_authid(
        id,
        authid,
        charsmax(authid)
    );

    new query[256];

    formatex(
        query,
        charsmax(query),
        "DELETE FROM %s WHERE authid='%s'",
        VIP_TABLE,
        authid
    );

    SQL_ThreadQuery(
        g_SqlTuple,
        "queryVipUpdate",
        query
    );

    g_IsVip[id] = false;
    g_VipExpire[id] = 0;

    removeVipTag(id);

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Tu ^3VIP^1 fue eliminado."
    );
}

public queryVipUpdate(
    failState,
    Handle:query,
    errorCode,
    errorMessage[],
    errorData[],
    dataSize,
    Float:queueTime
)
{
    if (failState != TQUERY_SUCCESS)
    {
        log_amx(
            "[VIP] Error actualizando base de datos. Codigo: %d. Error: %s",
            errorCode,
            errorMessage
        );
    }
}

public taskCheckVipExpiration()
{
    new currentTime = get_systime();

    for (new id = 1; id <= MaxClients; id++)
    {
        if (!is_user_connected(id))
        {
            continue;
        }

        if (!g_IsVip[id])
        {
            continue;
        }

        if (g_VipExpire[id] <= currentTime)
        {
            expireVip(id);
        }
    }
}

expireVip(id)
{
    new authid[35];

    get_user_authid(
        id,
        authid,
        charsmax(authid)
    );

    new query[256];

    formatex(
        query,
        charsmax(query),
        "DELETE FROM %s WHERE authid='%s'",
        VIP_TABLE,
        authid
    );

    SQL_ThreadQuery(
        g_SqlTuple,
        "queryVipUpdate",
        query
    );

    g_IsVip[id] = false;
    g_VipExpire[id] = 0;

    removeVipTag(id);

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Tu ^3VIP^1 ha vencido."
    );

    client_print_color(
        id,
        print_team_default,
        "^4[eXe]^1 Contacta con un admin si queres renovarlo."
    );
}

setVipTag(id)
{
    if (!is_user_connected(id))
    {
        return;
    }

    new name[32];

    get_user_name(
        id,
        name,
        charsmax(name)
    );

    if (containi(name, VIP_TAG) != -1)
    {
        return;
    }

    new newName[64];

    formatex(
        newName,
        charsmax(newName),
        "%s %s",
        VIP_TAG,
        name
    );

    set_user_info(
        id,
        "name",
        newName
    );
}

removeVipTag(id)
{
    if (!is_user_connected(id))
    {
        return;
    }

    new name[64];

    get_user_name(
        id,
        name,
        charsmax(name)
    );

    new cleanName[64];

    removeVipPrefix(
        name,
        cleanName,
        charsmax(cleanName)
    );

    if (!equal(name, cleanName))
    {
        set_user_info(
            id,
            "name",
            cleanName
        );
    }
}

removeVipPrefix(
    const name[],
    output[],
    outputLen
)
{
    new prefixLen = strlen(VIP_TAG);

    if (strlen(name) > prefixLen + 1)
    {
        if (equal(name, VIP_TAG, prefixLen))
        {
            copy(
                output,
                outputLen,
                name[prefixLen + 1]
            );

            return;
        }
    }

    copy(
        output,
        outputLen,
        name
    );
}

getRemainingTime(
    expireTime,
    output[],
    outputLen
)
{
    new remaining = expireTime - get_systime();

    if (remaining <= 0)
    {
        copy(
            output,
            outputLen,
            "Vencido"
        );

        return;
    }

    new days = remaining / 86400;
    remaining %= 86400;

    new hours = remaining / 3600;
    remaining %= 3600;

    new minutes = remaining / 60;

    if (days > 0)
    {
        if (hours > 0)
        {
            formatex(
                output,
                outputLen,
                "%d dias, %d horas",
                days,
                hours
            );
        }
        else
        {
            formatex(
                output,
                outputLen,
                "%d dias",
                days
            );
        }

        return;
    }

    if (hours > 0)
    {
        formatex(
            output,
            outputLen,
            "%d horas, %d minutos",
            hours,
            minutes
        );

        return;
    }

    formatex(
        output,
        outputLen,
        "%d minutos",
        minutes
    );
}

findPlayerByName(const search[])
{
    new players[32];
    new playerCount;

    get_players(
        players,
        playerCount,
        "ch"
    );

    new player;

    for (new i = 0; i < playerCount; i++)
    {
        player = players[i];

        new name[64];

        get_user_name(
            player,
            name,
            charsmax(name)
        );

        if (equali(name, search))
        {
            return player;
        }
    }

    for (new i = 0; i < playerCount; i++)
    {
        player = players[i];

        new name[64];

        get_user_name(
            player,
            name,
            charsmax(name)
        );

        if (containi(name, search) != -1)
        {
            return player;
        }
    }

    return 0;
}
