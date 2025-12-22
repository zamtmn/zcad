#include <stdio.h>
#include <stddef.h>
#include "../cad_source/components/fpdwg/libredwg/dwg.h"

int main() {
    printf("=== C Structure Sizes ===\n");
    printf("sizeof(Dwg_Object) = %zu\n", sizeof(Dwg_Object));
    printf("sizeof(Dwg_Object_Entity) = %zu\n", sizeof(Dwg_Object_Entity));
    printf("sizeof(Dwg_Object_Object) = %zu\n", sizeof(Dwg_Object_Object));
    printf("sizeof(Dwg_Handle) = %zu\n", sizeof(Dwg_Handle));
    printf("sizeof(Dwg_Class) = %zu\n", sizeof(Dwg_Class));

    printf("\n=== C Structure Field Offsets for Dwg_Object ===\n");
    printf("offsetof(Dwg_Object, size) = %zu\n", offsetof(Dwg_Object, size));
    printf("offsetof(Dwg_Object, address) = %zu\n", offsetof(Dwg_Object, address));
    printf("offsetof(Dwg_Object, type) = %zu\n", offsetof(Dwg_Object, type));
    printf("offsetof(Dwg_Object, index) = %zu\n", offsetof(Dwg_Object, index));
    printf("offsetof(Dwg_Object, fixedtype) = %zu\n", offsetof(Dwg_Object, fixedtype));
    printf("offsetof(Dwg_Object, name) = %zu\n", offsetof(Dwg_Object, name));
    printf("offsetof(Dwg_Object, dxfname) = %zu\n", offsetof(Dwg_Object, dxfname));
    printf("offsetof(Dwg_Object, supertype) = %zu\n", offsetof(Dwg_Object, supertype));
    printf("offsetof(Dwg_Object, tio) = %zu\n", offsetof(Dwg_Object, tio));
    printf("offsetof(Dwg_Object, handle) = %zu\n", offsetof(Dwg_Object, handle));
    printf("offsetof(Dwg_Object, parent) = %zu\n", offsetof(Dwg_Object, parent));
    printf("offsetof(Dwg_Object, klass) = %zu\n", offsetof(Dwg_Object, klass));
    printf("offsetof(Dwg_Object, bitsize) = %zu\n", offsetof(Dwg_Object, bitsize));

    printf("\n=== C Structure Field Offsets for Dwg_Object_Entity ===\n");
    printf("offsetof(Dwg_Object_Entity, objid) = %zu\n", offsetof(Dwg_Object_Entity, objid));
    printf("offsetof(Dwg_Object_Entity, tio) = %zu\n", offsetof(Dwg_Object_Entity, tio));
    printf("offsetof(Dwg_Object_Entity, dwg) = %zu\n", offsetof(Dwg_Object_Entity, dwg));
    printf("offsetof(Dwg_Object_Entity, num_eed) = %zu\n", offsetof(Dwg_Object_Entity, num_eed));
    printf("offsetof(Dwg_Object_Entity, eed) = %zu\n", offsetof(Dwg_Object_Entity, eed));

    printf("\n=== Pointer sizes ===\n");
    printf("sizeof(void*) = %zu\n", sizeof(void*));
    printf("sizeof(size_t) = %zu\n", sizeof(size_t));
    printf("sizeof(BITCODE_RL) = %zu\n", sizeof(BITCODE_RL));
    printf("sizeof(BITCODE_BS) = %zu\n", sizeof(BITCODE_BS));
    printf("sizeof(BITCODE_BL) = %zu\n", sizeof(BITCODE_BL));
    printf("sizeof(DWG_OBJECT_TYPE) = %zu\n", sizeof(enum DWG_OBJECT_TYPE));
    printf("sizeof(Dwg_Object_Supertype) = %zu\n", sizeof(Dwg_Object_Supertype));

    return 0;
}
