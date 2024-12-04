#include <stddef.h>

typedef struct STBIVTable {
    void* (*malloc)(size_t size);
    void  (*free)(void*);
    void* (*realloc)(void* ptr, size_t size);
} STBIVTable ;

STBIVTable vtable;

#define STBI_MALLOC(size) vtable.malloc(size);
#define STBI_REALLOC(ptr, size) vtable.realloc(ptr, size);
#define STBI_FREE(ptr) vtable.free(ptr);

extern void set_vtable(STBIVTable table) {
    vtable = table;
}

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"