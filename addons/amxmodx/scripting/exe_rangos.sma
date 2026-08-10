#include <amxmodx>

#define PLUGIN "Sistema de rangos - eXe Server"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

new const g_szRanks[][] = {
	"Plata I",
	"Plata II",
	"Plata III",
	"Plata IV",
	"Plata Elite",
	"Oro Nova I",
	"Oro Nova II",
	"Oro Nova III",
	"Maestro Guardian I",
	"Maestro Guardian II",
	"Maestro Guardian X",
	"Sheriff",
	"Aguila",
	"Aguila Legendaria",
	"Supreme",
	"Global Elite",
	"Legendary",
	".eXe"
}

new const g_iThresholds[] = {
	0,
	50,
	100,
	150,
	200,
	300,
	400,
	550,
	700,
	900,
	1100,
	1350,
	1600,
	1900,
	2200,
	3000,
	3500,
	6000
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /rangos", "cmd_rangos")
	register_clcmd("say_team /rangos", "cmd_rangos")
	register_clcmd("say /ranks", "cmd_rangos")
	register_clcmd("say_team /ranks", "cmd_rangos")
}

public cmd_rangos(id)
{
	static szMotd[2048]
	new iLen = 0

	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "<html><head><style>")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "body{background:#1a1a2e;color:#e0e0e0;font-family:Consolas;margin:0;padding:8px}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "table{width:100%%;border-collapse:collapse;margin-top:6px}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "th{background:#16213e;color:#00e5ff;padding:5px;font-size:12px;border:1px solid #0f3460}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "td{padding:4px 6px;font-size:12px;text-align:center;border:1px solid #0f3460}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, ".r{color:#e74c3c;font-weight:bold}")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "</style></head><body>")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "<table>")
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "<tr><th>#</th><th>Rangos</th><th>Bajas Necesarias</th></tr>")

	new iTotalRanks = sizeof(g_szRanks)

	for (new i = 0; i < iTotalRanks; i++)
	{
		if (i == iTotalRanks - 1)
		{
			iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
				"<tr class=^"r^"><td>%d</td><td>%s</td><td>%d+</td></tr>",
				i + 1, g_szRanks[i], g_iThresholds[i])
		}
		else
		{
			iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen,
				"<tr><td>%d</td><td>%s</td><td>%d</td></tr>",
				i + 1, g_szRanks[i], g_iThresholds[i])
		}
	}

	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "</table></body></html>")
	show_motd(id, szMotd, "Sistema de rangos - eXe Server")
	return PLUGIN_HANDLED
}
