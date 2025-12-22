#include <stdio.h>
#include <stddef.h>
#include "../cad_source/components/fpdwg/libredwg/dwg.h"

int main() {
    printf("=== Dwg_Object_Entity Field Offsets (C) ===\n");
    printf("offsetof(Dwg_Object_Entity, objid) = %zu\n", offsetof(Dwg_Object_Entity, objid));
    printf("offsetof(Dwg_Object_Entity, tio) = %zu\n", offsetof(Dwg_Object_Entity, tio));
    printf("offsetof(Dwg_Object_Entity, dwg) = %zu\n", offsetof(Dwg_Object_Entity, dwg));
    printf("offsetof(Dwg_Object_Entity, num_eed) = %zu\n", offsetof(Dwg_Object_Entity, num_eed));
    printf("offsetof(Dwg_Object_Entity, eed) = %zu\n", offsetof(Dwg_Object_Entity, eed));
    printf("offsetof(Dwg_Object_Entity, preview_exists) = %zu\n", offsetof(Dwg_Object_Entity, preview_exists));
    printf("offsetof(Dwg_Object_Entity, preview_is_proxy) = %zu\n", offsetof(Dwg_Object_Entity, preview_is_proxy));
    printf("offsetof(Dwg_Object_Entity, preview_size) = %zu\n", offsetof(Dwg_Object_Entity, preview_size));
    printf("offsetof(Dwg_Object_Entity, preview) = %zu\n", offsetof(Dwg_Object_Entity, preview));
    printf("offsetof(Dwg_Object_Entity, entmode) = %zu\n", offsetof(Dwg_Object_Entity, entmode));
    printf("offsetof(Dwg_Object_Entity, num_reactors) = %zu\n", offsetof(Dwg_Object_Entity, num_reactors));
    printf("offsetof(Dwg_Object_Entity, is_xdic_missing) = %zu\n", offsetof(Dwg_Object_Entity, is_xdic_missing));
    printf("offsetof(Dwg_Object_Entity, isbylayerlt) = %zu\n", offsetof(Dwg_Object_Entity, isbylayerlt));
    printf("offsetof(Dwg_Object_Entity, nolinks) = %zu\n", offsetof(Dwg_Object_Entity, nolinks));
    printf("offsetof(Dwg_Object_Entity, has_ds_data) = %zu\n", offsetof(Dwg_Object_Entity, has_ds_data));
    printf("offsetof(Dwg_Object_Entity, color) = %zu\n", offsetof(Dwg_Object_Entity, color));
    printf("offsetof(Dwg_Object_Entity, ltype_scale) = %zu\n", offsetof(Dwg_Object_Entity, ltype_scale));
    printf("offsetof(Dwg_Object_Entity, ltype_flags) = %zu\n", offsetof(Dwg_Object_Entity, ltype_flags));
    printf("offsetof(Dwg_Object_Entity, plotstyle_flags) = %zu\n", offsetof(Dwg_Object_Entity, plotstyle_flags));
    printf("offsetof(Dwg_Object_Entity, material_flags) = %zu\n", offsetof(Dwg_Object_Entity, material_flags));
    printf("offsetof(Dwg_Object_Entity, shadow_flags) = %zu\n", offsetof(Dwg_Object_Entity, shadow_flags));
    printf("offsetof(Dwg_Object_Entity, has_full_visualstyle) = %zu\n", offsetof(Dwg_Object_Entity, has_full_visualstyle));
    printf("offsetof(Dwg_Object_Entity, has_face_visualstyle) = %zu\n", offsetof(Dwg_Object_Entity, has_face_visualstyle));
    printf("offsetof(Dwg_Object_Entity, has_edge_visualstyle) = %zu\n", offsetof(Dwg_Object_Entity, has_edge_visualstyle));
    printf("offsetof(Dwg_Object_Entity, invisible) = %zu\n", offsetof(Dwg_Object_Entity, invisible));
    printf("offsetof(Dwg_Object_Entity, linewt) = %zu\n", offsetof(Dwg_Object_Entity, linewt));
    printf("offsetof(Dwg_Object_Entity, flag_r11) = %zu\n", offsetof(Dwg_Object_Entity, flag_r11));
    printf("offsetof(Dwg_Object_Entity, opts_r11) = %zu\n", offsetof(Dwg_Object_Entity, opts_r11));
    printf("offsetof(Dwg_Object_Entity, extra_r11) = %zu\n", offsetof(Dwg_Object_Entity, extra_r11));
    printf("offsetof(Dwg_Object_Entity, color_r11) = %zu\n", offsetof(Dwg_Object_Entity, color_r11));
    printf("offsetof(Dwg_Object_Entity, elevation_r11) = %zu\n", offsetof(Dwg_Object_Entity, elevation_r11));
    printf("offsetof(Dwg_Object_Entity, thickness_r11) = %zu\n", offsetof(Dwg_Object_Entity, thickness_r11));
    printf("offsetof(Dwg_Object_Entity, viewport) = %zu\n", offsetof(Dwg_Object_Entity, viewport));
    printf("offsetof(Dwg_Object_Entity, __iterator) = %zu\n", offsetof(Dwg_Object_Entity, __iterator));
    printf("offsetof(Dwg_Object_Entity, ownerhandle) = %zu\n", offsetof(Dwg_Object_Entity, ownerhandle));
    printf("offsetof(Dwg_Object_Entity, reactors) = %zu\n", offsetof(Dwg_Object_Entity, reactors));
    printf("offsetof(Dwg_Object_Entity, xdicobjhandle) = %zu\n", offsetof(Dwg_Object_Entity, xdicobjhandle));
    printf("offsetof(Dwg_Object_Entity, prev_entity) = %zu\n", offsetof(Dwg_Object_Entity, prev_entity));
    printf("offsetof(Dwg_Object_Entity, next_entity) = %zu\n", offsetof(Dwg_Object_Entity, next_entity));
    printf("offsetof(Dwg_Object_Entity, layer) = %zu\n", offsetof(Dwg_Object_Entity, layer));
    printf("offsetof(Dwg_Object_Entity, ltype) = %zu\n", offsetof(Dwg_Object_Entity, ltype));
    printf("offsetof(Dwg_Object_Entity, material) = %zu\n", offsetof(Dwg_Object_Entity, material));
    printf("offsetof(Dwg_Object_Entity, shadow) = %zu\n", offsetof(Dwg_Object_Entity, shadow));
    printf("offsetof(Dwg_Object_Entity, plotstyle) = %zu\n", offsetof(Dwg_Object_Entity, plotstyle));
    printf("offsetof(Dwg_Object_Entity, full_visualstyle) = %zu\n", offsetof(Dwg_Object_Entity, full_visualstyle));
    printf("offsetof(Dwg_Object_Entity, face_visualstyle) = %zu\n", offsetof(Dwg_Object_Entity, face_visualstyle));
    printf("offsetof(Dwg_Object_Entity, edge_visualstyle) = %zu\n", offsetof(Dwg_Object_Entity, edge_visualstyle));
    printf("\nTotal size = %zu\n", sizeof(Dwg_Object_Entity));

    return 0;
}
