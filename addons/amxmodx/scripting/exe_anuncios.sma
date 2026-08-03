#include <amxmodx>

#define INTERVALO 20.0

new const g_Mensajes[][] = {
    "^4[eXe]^1 Escribi ^3/armas^1 para abrir el menu de armas.",
    "^4[eXe]^1 Escribi ^3/rank^1 y ^3/top15^1 para ver tus estadisticas.",
    "^4[eXe]^1 Seguinos en ^3Instagram^1: ^4@exeserver",
    "^4[eXe]^1 Consegui tu ^3VIP^1 por ^4$2000^1.",
    "^4[eXe]^1 WhatsApp:^3 3547 51-5201",
    "^4[eXe]^1 Unite a nuestro ^3Discord^1: ^4discord.gg/BHHX6jAfpc"
};

new g_iMensaje;

public plugin_init()
{
    register_plugin("eXe Anuncios", "1.0", "R4z");

    set_task(INTERVALO, "MostrarMensaje", _, _, _, "b");
}

public MostrarMensaje()
{
    client_print_color(0, print_team_default, "%s", g_Mensajes[g_iMensaje]);

    g_iMensaje++;

    if (g_iMensaje >= sizeof(g_Mensajes))
        g_iMensaje = 0;
}
