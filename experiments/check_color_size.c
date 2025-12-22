#include <stdio.h>
#include <stddef.h>
#include "../cad_source/components/fpdwg/libredwg/dwg.h"

int main() {
    printf("sizeof(Dwg_Color) = %zu\n", sizeof(Dwg_Color));
    printf("sizeof(BITCODE_BB) = %zu\n", sizeof(BITCODE_BB));
    printf("sizeof(BITCODE_BL) = %zu\n", sizeof(BITCODE_BL));

    printf("\n=== Dwg_Color field offsets ===\n");
    printf("offsetof(Dwg_Color, index) = %zu\n", offsetof(Dwg_Color, index));
    printf("offsetof(Dwg_Color, flag) = %zu\n", offsetof(Dwg_Color, flag));
    printf("offsetof(Dwg_Color, raw) = %zu\n", offsetof(Dwg_Color, raw));
    printf("offsetof(Dwg_Color, rgb) = %zu\n", offsetof(Dwg_Color, rgb));
    printf("offsetof(Dwg_Color, method) = %zu\n", offsetof(Dwg_Color, method));
    printf("offsetof(Dwg_Color, name) = %zu\n", offsetof(Dwg_Color, name));
    printf("offsetof(Dwg_Color, book_name) = %zu\n", offsetof(Dwg_Color, book_name));
    printf("offsetof(Dwg_Color, handle) = %zu\n", offsetof(Dwg_Color, handle));
    printf("offsetof(Dwg_Color, alpha_raw) = %zu\n", offsetof(Dwg_Color, alpha_raw));
    printf("offsetof(Dwg_Color, alpha_type) = %zu\n", offsetof(Dwg_Color, alpha_type));
    printf("offsetof(Dwg_Color, alpha) = %zu\n", offsetof(Dwg_Color, alpha));

    return 0;
}
