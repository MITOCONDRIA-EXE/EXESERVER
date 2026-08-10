#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <sqlx>

#define PLUGIN_NAME        "Sistema VIP - eXe Server"
#define PLUGIN_VERSION     "1.0.3"
#define PLUGIN_AUTHOR      "eXe.R4z"

#define VIP_DATABASE       "vip_system"
#define VIP_TABLE          "vip_players"

#define VIP_DEFAULT_DAYS   30
#define VIP_ADMIN_FLAG     ADMIN_RCON

#define VIP_TAG            "[VIP]"

new Handle:g_SqlTuple;

new bool:g_IsVip[33];
new g_VipExpire[33];
new g_VipKey[33][32];

new const g_VipBenefits[][] =
{
    "Tag [VIP] en tu nombre",
    "Skins de armas y modelos exclusivos VIP",
    "ROL VIP en el servidor de discord y Chances para postulacion de administrador",
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
    g_VipKey[id][0] = EOS;

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
    g_VipKey[id][0] = EOS;
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
        "CREATE TABLE IF NOT EXISTS %s (authid TEXT PRIMARY KEY, expire INTEGER NOT NULL DEFAULT 0, vip_key TEXT DEFAULT '')",
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

    formatex(query, charsmax(query),
        "ALTER TABLE %s ADD COLUMN vip_key TEXT DEFAULT ''", VIP_TABLE);
    result = SQL_PrepareQuery(connection, query);
    SQL_Execute(result);
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
        "SELECT expire, vip_key FROM %s WHERE authid='%s'",
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
    g_VipKey[id][0] = EOS;

    if (SQL_NumResults(query) > 0)
    {
        new expire = SQL_ReadResult(query, 0);

        g_VipExpire[id] = expire;

        SQL_ReadResult(query, 1, g_VipKey[id], charsmax(g_VipKey[]));

        if (expire > get_systime())
        {
            g_IsVip[id] = true;

            set_user_flags(id, get_user_flags(id) | ADMIN_RESERVATION);
            writeVipToUsersIni(id);

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
        "^4[eXe]^1 Tu ^3VIP^1 esta activo. Tiempo restante: ^3%s^1. ID: ^3%s",
        remaining,
        g_VipKey[id]
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

	showVipMotd(id);

	return PLUGIN_HANDLED;
}

showVipMotd(id)
{
	static szMotd[1536]
	new iLen = 0

	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "<html><head><style>")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "body{background:#1a1a2e;color:#e0e0e0;font-family:Arial;margin:0;padding:8px}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "h1{text-align:center;color:#00e5ff;font-size:18px;margin:0 0 6px}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "h2{color:#ffd700;font-size:13px;margin:8px 0 3px}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, ".intro{text-align:center;color:#a0a0a0;font-size:12px;margin-bottom:8px}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, ".active{text-align:center;font-size:15px;padding:6px;background:#0a3d0a;color:#4caf50;font-weight:bold;margin:6px 0}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, ".info{background:#16213e;padding:8px;margin:6px 0;font-size:12px}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, ".info b{color:#00e5ff}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "ul{padding-left:18px;margin:0;font-size:12px}li{padding:2px 0}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "table{width:100%%;border-collapse:collapse}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "th{background:#16213e;color:#00e5ff;padding:4px;font-size:11px;border:1px solid #0f3460}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "td{padding:3px;font-size:11px;text-align:center;border:1px solid #0f3460}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, ".cmds td{text-align:left}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, ".discount{color:#ffd700;font-weight:bold}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, ".tag{background:#ffd700;color:#1a1a2e;font-size:9px;padding:1px 4px;font-weight:bold}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "</style></head><body>")

	if (g_IsVip[id] && g_VipExpire[id] > get_systime())
	{
		new remaining[64]
		new expireDate[32]
		new name[32]

		get_user_name(id, name, charsmax(name))
		getRemainingTime(g_VipExpire[id], remaining, charsmax(remaining))
		format_time(expireDate, charsmax(expireDate), "%d/%m/%Y", g_VipExpire[id])

		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<h1>Bienvenido nuevamente, <b>%s</b>!</h1>", name)
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<div class=^"active^">VIP ACTIVO</div>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<div class=^"info^"><b>Vencimiento:</b> %s<br><b>Tiempo restante:</b> %s</div>",
			expireDate, remaining)
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<table class=^"cmds^">")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><th>Comandos</th><th>Descripcion</th></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td><b>/skin</b></td><td>Skin de jugador</td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td><b>/ak</b></td><td>Skin de AK-47</td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td><b>/m4</b></td><td>Skin de M4A1</td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td><b>/awp</b></td><td>Skin de AWP</td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td><b>/dk</b></td><td>Skin de Deagle</td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td><b>/knife</b></td><td>Skin de cuchillo</td></tr>")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td><b>/vip</b></td><td>Ver vencimiento de tu VIP</td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "</table>")
	}
	else
	{
		new name[32]
		get_user_name(id, name, charsmax(name))

		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<h1>Hola <b>%s</b>!, bienvenido al sistema VIP!</h1>", name)
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<h2>Beneficios</h2><ul>")

		for (new i = 0; i < sizeof(g_VipBenefits); i++)
		{
			iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
				"<li>%s</li>", g_VipBenefits[i])
		}

		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "</ul>")

		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<h2>Planes y Precios</h2><table>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><th>Plan</th><th>Precio</th><th>Descuento</th></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td>1 Mes</td><td>$2000</td><td>-</td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td>2 Meses</td><td class=^"discount^">$3600</td><td><span class=^"tag^">10%% OFF</span></td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"<tr><td>3 Meses</td><td class=^"discount^">$5400</td><td><span class=^"tag^">10%% OFF</span></td></tr>")
		iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
			"</table>")
	}

	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "</body></html>")

	show_motd(id, szMotd, "Sistema VIP - eXe Server")
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

    if (g_VipKey[id][0] == EOS)
    {
        new seed = newExpire + random_num(10000, 99999);
        formatex(g_VipKey[id], charsmax(g_VipKey[]), "vip_%d", seed % 100000);
    }

    new query[512];

    formatex(
        query,
        charsmax(query),
        "INSERT OR REPLACE INTO %s (authid, expire, vip_key) VALUES ('%s', %d, '%s')",
        VIP_TABLE,
        authid,
        newExpire,
        g_VipKey[id]
    );

    SQL_ThreadQuery(
        g_SqlTuple,
        "queryVipUpdate",
        query
    );

    g_VipExpire[id] = newExpire;
    g_IsVip[id] = true;

    set_user_flags(id, get_user_flags(id) | ADMIN_RESERVATION);
    writeVipToUsersIni(id);

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
        "^4[eXe]^1 Tiempo restante: ^3%s^1. ID: ^3%s",
        remaining,
        g_VipKey[id]
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
    g_VipKey[id][0] = EOS;

    if (!(get_user_flags(id) & ADMIN_KICK))
    {
        set_user_flags(id, get_user_flags(id) & ~ADMIN_RESERVATION);
    }

    removeVipFromUsersIni(id);

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
    g_VipKey[id][0] = EOS;

    if (!(get_user_flags(id) & ADMIN_KICK))
    {
        set_user_flags(id, get_user_flags(id) & ~ADMIN_RESERVATION);
    }

    removeVipFromUsersIni(id);

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

writeVipToUsersIni(id)
{
    new authid[35];
    get_user_authid(id, authid, charsmax(authid));

    if (equal(authid, "STEAM_ID_PENDING") || equal(authid, "VALVE_ID_LAN"))
        return;

    new configsdir[128];
    get_configsdir(configsdir, charsmax(configsdir));

    new userfile[256];
    formatex(userfile, charsmax(userfile), "%s/users.ini", configsdir);

    new file = fopen(userfile, "rt");
    if (file)
    {
        new line[256];
        while (fgets(file, line, charsmax(line)))
        {
            stripReturn(line);

            if (containi(line, authid) != -1)
            {
                fclose(file);
                return;
            }
        }
        fclose(file);
    }

    file = fopen(userfile, "at");
    if (file)
    {
        new entry[256];
        formatex(entry, charsmax(entry), "^"%s^" ^"^" ^"b^" ^"ce^"", authid);
        fputs(file, entry);
        fputs(file, "^n");
        fclose(file);
    }

    server_cmd("amx_reloadadmins");
}

removeVipFromUsersIni(id)
{
    if (get_user_flags(id) & ADMIN_KICK)
        return;

    new authid[35];
    get_user_authid(id, authid, charsmax(authid));

    if (equal(authid, "STEAM_ID_PENDING") || equal(authid, "VALVE_ID_LAN"))
        return;

    new configsdir[128];
    get_configsdir(configsdir, charsmax(configsdir));

    new userfile[256];
    formatex(userfile, charsmax(userfile), "%s/users.ini", configsdir);

    new tempfile[256];
    formatex(tempfile, charsmax(tempfile), "%s/users_temp.ini", configsdir);

    new file = fopen(userfile, "rt");
    if (!file)
        return;

    new temp = fopen(tempfile, "wt");
    if (!temp)
    {
        fclose(file);
        return;
    }

    new line[256];
    while (fgets(file, line, charsmax(line)))
    {
        stripReturn(line);

        if (containi(line, authid) == -1)
        {
            fputs(temp, line);
            fputs(temp, "^n");
        }
    }

    fclose(file);
    fclose(temp);

    delete_file(userfile);
    rename_file(tempfile, userfile, 1);

    server_cmd("amx_reloadadmins");
}

stripReturn(line[])
{
    new len = strlen(line);
    if (len > 0 && line[len - 1] == '^r')
        line[len - 1] = EOS;
}
