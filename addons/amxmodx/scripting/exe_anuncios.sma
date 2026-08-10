#include <amxmodx>

#define INTERVALO 30.0

new const g_Mensajes[][] = {
    "^4[eXe]^1 Escribi ^3/VIP^1 para saber nuestros ^3planes y beneficios^1.",
    "^4[eXe]^1 Por ^3queja o consulta^1 entra al ^4Discord^1 de la comunidad y abri un ^3ticket.^1 Si hay un ^4admin o mod activo^1, ellos ^3responderan tu consulta.^1",
    "^4[eXe]^1 Usa ^3/armas^1 para activar o desactivar el ^3menu de armas.^1",
    "^4[eXe]^1 Escribi ^3/rangos^1 para ver la ^3tabla de rangos y bajas necesarias.^1",
    "^4[eXe]^1 Skins de armas: ^3/knife /m4 /ak /dk /awp^1",
    "^4[eXe]^1 ^3Presiona la tecla E^1 para usar el ^4paracaidas^1",
    "^4[eXe]^1 Escribi ^3/rank^1 y ^3/top15^1 para ver ^3tus estadisticas.^1",
    "^4[eXe]^1 Modelos de player: escribi ^3/skins^1",
    "^4[eXe]^1 Usa ^3/armas^1 para activar o desactivar el ^3menu de armas.^1",
    "^4[eXe]^1 Doble salto ^3presiona la tecla ESPACIO x2^1",
    "^4[eXe]^1 ^4Colabora con tu donacion^1 asi podemos ^3mantener la comunidad de pie y seguir disfrutando juntos!^1 Gracias por estar.",
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
