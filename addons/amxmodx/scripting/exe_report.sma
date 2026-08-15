#include <amxmodx>
#include <amxmisc>
#include <sockets>

#define PLUGIN "eXe Report"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

#define MAX_MSG 256
#define COOLDOWN 30

#define CHR_DQUOTE 34
#define CHR_BACKSLASH 92
#define CHR_NEWLINE 10
#define CHR_CR 13
#define CHR_TAB 9

new g_cvarRelayUrl
new g_lastReport[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_clcmd("say /report", "cmdReport")
    register_clcmd("say_team /report", "cmdReport")

    g_cvarRelayUrl = register_cvar("exe_report_url", "")
}

public client_disconnected(id)
{
    g_lastReport[id] = 0
}

public cmdReport(id)
{
    new msg[MAX_MSG]
    read_args(msg, charsmax(msg))
    remove_quotes(msg)
    trim(msg)

    if (msg[0] == EOS)
    {
        client_print_color(id, print_team_default, "^4[eXe]^1 Uso: /report <mensaje>")
        return PLUGIN_HANDLED
    }

    new now = get_systime()
    if (now - g_lastReport[id] < COOLDOWN)
    {
        client_print_color(id, print_team_default, "^4[eXe]^1 Espera %d segundos para reportar de nuevo.", COOLDOWN - (now - g_lastReport[id]))
        return PLUGIN_HANDLED
    }
    g_lastReport[id] = now

    new url[256]
    get_pcvar_string(g_cvarRelayUrl, url, charsmax(url))

    if (url[0] == EOS)
    {
        client_print_color(id, print_team_default, "^4[eXe]^1 El reporte no esta configurado en el servidor.")
        return PLUGIN_HANDLED
    }

    new name[32], authid[35], ip[24], mapname[32], hostname[128]
    get_user_name(id, name, charsmax(name))
    get_user_authid(id, authid, charsmax(authid))
    get_user_ip(id, ip, charsmax(ip), 1)
    get_mapname(mapname, charsmax(mapname))
    get_cvar_string("hostname", hostname, charsmax(hostname))

    send_report(url, name, authid, ip, mapname, hostname, msg)

    client_print_color(id, print_team_default, "^4[eXe]^1 Reporte enviado.")

    return PLUGIN_HANDLED
}

send_report(const url[], const name[], const authid[], const ip[], const mapname[], const hostname[], const msg[])
{
    new host[128], path[256]
    new port = 80

    if (!parse_url(url, host, charsmax(host), port, path, charsmax(path)))
        return

    new body[2048]
    build_json(body, charsmax(body), name, authid, ip, mapname, hostname, msg)

    new hostHeader[160]
    if (port == 80)
        copy(hostHeader, charsmax(hostHeader), host)
    else
        formatex(hostHeader, charsmax(hostHeader), "%s:%d", host, port)

    new request[4096]
    new reqlen = formatex(request, charsmax(request),
        "POST %s HTTP/1.1\r\nHost: %s\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s",
        path, hostHeader, strlen(body), body)

    new error
    new socket = socket_open(host, port, SOCKET_TCP, error)

    if (socket < 0)
        return

    socket_send(socket, request, reqlen)
    socket_close(socket)
}

parse_url(const url[], host[], hostlen, &port, path[], pathlen)
{
    new temp[512]
    copy(temp, charsmax(temp), url)

    new pos
    if (equal(temp, "http://", 7))
        pos = 7
    else if (equal(temp, "https://", 8))
        pos = 8
    else
        return 0

    new len = strlen(temp)

    new slash = -1
    for (new i = pos; i < len; i++)
    {
        if (temp[i] == '/')
        {
            slash = i
            break
        }
    }

    new hostEnd
    if (slash == -1)
    {
        hostEnd = len
        copy(path, pathlen, "/")
    }
    else
    {
        hostEnd = slash
        copy(path, pathlen, temp[slash])
    }

    new colon = -1
    for (new i = pos; i < hostEnd; i++)
    {
        if (temp[i] == ':')
        {
            colon = i
            break
        }
    }

    copy(host, hostlen, temp[pos])

    if (colon != -1)
    {
        host[colon - pos] = EOS
        port = str_to_num(temp[colon + 1])
    }
    else
    {
        host[hostEnd - pos] = EOS
        port = 80
    }

    return 1
}

build_json(json[], len, const name[], const authid[], const ip[], const mapname[], const hostname[], const msg[])
{
    new e_name[96], e_authid[96], e_ip[48], e_map[96], e_host[256], e_msg[768]
    json_escape(name, e_name, charsmax(e_name))
    json_escape(authid, e_authid, charsmax(e_authid))
    json_escape(ip, e_ip, charsmax(e_ip))
    json_escape(mapname, e_map, charsmax(e_map))
    json_escape(hostname, e_host, charsmax(e_host))
    json_escape(msg, e_msg, charsmax(e_msg))

    formatex(json, len,
        "{^"server^":^"%s^",^"map^":^"%s^",^"reporter^":^"%s^",^"steamid^":^"%s^",^"ip^":^"%s^",^"message^":^"%s^"}",
        e_host, e_map, e_name, e_authid, e_ip, e_msg)
}

json_escape(const src[], dest[], len)
{
    new pos = 0
    new c
    for (new i = 0; src[i] && pos < len - 2; i++)
    {
        c = src[i]

        if (c == CHR_DQUOTE || c == CHR_BACKSLASH || c == CHR_NEWLINE || c == CHR_CR || c == CHR_TAB)
        {
            dest[pos++] = CHR_BACKSLASH

            switch (c)
            {
                case CHR_DQUOTE:    dest[pos++] = CHR_DQUOTE
                case CHR_BACKSLASH: dest[pos++] = CHR_BACKSLASH
                case CHR_NEWLINE:   dest[pos++] = 'n'
                case CHR_CR:        dest[pos++] = 'r'
                case CHR_TAB:       dest[pos++] = 't'
            }
        }
        else if (c >= 32)
        {
            dest[pos++] = c
        }
    }
    dest[pos] = EOS
}
