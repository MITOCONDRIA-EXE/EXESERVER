#include <amxmodx>
#include <fakemeta>

public plugin_init() {
    register_plugin("Game Description Changer", "1.0", "eXe")
    register_forward(FM_GetGameDescription, "fw_GetGameDescription")
}

public fw_GetGameDescription() {
    forward_return(FMV_STRING, "DeathMatch | eXe")
    return FMRES_SUPERCEDE
}