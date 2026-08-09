#include <amxmodx>

#define INTERVALO 20.0

new const g_Mensajes[][] = {
    "^4[eXe]^1 Reserva y compra tu ^3VIP^1 y disfruta de ^3modelos y skins de armas unicas^1, ^3tag VIP^1 y chance de postulacion a ^3admin^1!",
    "^4[eXe]^1 Consegui tu ^3VIP por 2000$ ARS.^1",
    "^4[eXe]^1 Por ^3queja o consulta^1 entra al ^4Discord^1 de la comunidad y abri un ^3ticket.^1 Si hay un ^4admin o mod activo^1, ellos ^3responderan tu consulta.^1",
    "^4[eXe]^1 Escribi ^3/rank^1 y ^3/top15^1 para ver ^3tus estadisticas.^1",
    "^4[eXe]^1 ^3WhatsApp:^1 ^4https://chat.whatsapp.com/IwmVjqkYABX9G1epKXZhHI",
    "^4[eXe]^1 ^3Unite a nuestro Discord:^1 ^4discord.gg/BHHX6jAfpc",
    "^4[eXe]^1 ^3Presiona la tecla E^1 para usar el ^4paracaidas^1",
    "^4[eXe]^1 Skins de armas: ^3/knife /m4 /ak /dk /awp^1",
    "^4[eXe]^1 Modelos de player: escribi ^3/skins^1",
    "^4[eXe]^1 Escribi ^3/armas^1 para abrir el ^3menu de armas.^1",
    "^4[eXe]^1 Doble salto ^3presiona la tecla ESPACIO x2^1",
    "^4[eXe]^1 ^4Colabora con tu donacion^1 asi podemos ^3mantener la comunidad de pie y seguir disfrutando juntos!^1 Gracias por estar.",
    "^4[eXe]^1 Alias para donaciones ^3exe.server.mp^1 ",
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
