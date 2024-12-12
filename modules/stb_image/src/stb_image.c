#include <stddef.h>

void* (*hystbi_malloc)(void*, size_t size);
void  (*hystbi_free)(void*, void*);
void* (*hystbi_realloc)(void*, void* ptr, size_t size);

void* hystbi_allocator;

#define STBI_MALLOC(size) hystbi_malloc(hystbi_allocator, size);
#define STBI_REALLOC(ptr, size) hystbi_realloc(hystbi_allocator, ptr, size);
#define STBI_FREE(ptr) hystbi_free(hystbi_allocator, ptr);

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"