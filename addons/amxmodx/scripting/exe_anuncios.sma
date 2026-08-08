#include <amxmodx>

#define INTERVALO 20.0

new const g_Mensajes[][] = {
    "^4[eXe]^1 Escribi ^3/armas^1 para abrir el ^3menu de armas.^1",
    "^4[eXe]^1 Escribi ^3/rank^1 y ^3/top15^1 para ver ^3tus estadisticas.^1",
    "^4[eXe]^1 Consegui tu ^4VIP^1 por ^3$2000ARS^1.",
    "^4[eXe] WhatsApp:^1 ^3https://chat.whatsapp.com/IwmVjqkYABX9G1epKXZhHI",
    "^4[eXe] Unite a nuestro Discord:^1 ^3discord.gg/BHHX6jAfpc"
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
