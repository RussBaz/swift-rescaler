#ifndef cVipsWrapper_h
#define cVipsWrapper_h

#include <stdio.h>
#include "vips/vips.h"

// Wrapers exist because swift cannot handle varadic in C.
VipsImage *vips_image_new_from_file_wrapper(const char *name);
VipsImage *vips_image_new_from_buffer_wrapper(const void *buf, size_t len, const char *option_string);

int vips_thumbnail_width_only_wrapper(const char *filename, VipsImage **out, int width);
int vips_thumbnail_height_only_wrapper(const char *filename, VipsImage **out, int height);
int vips_thumbnail_width_and_height_wrapper(const char *filename, VipsImage **out, int width, int height);
int vips_thumbnail_buffer_width_only_wrapper(void *buf, size_t len, VipsImage **out, int width);
int vips_thumbnail_buffer_height_only_wrapper(void *buf, size_t len, VipsImage **out, int height);
int vips_thumbnail_buffer_width_and_height_wrapper(void *buf, size_t len, VipsImage **out, int width, int height);
int vips_thumbnail_image_width_only_wrapper(VipsImage *in, VipsImage **out, int width);
int vips_thumbnail_image_height_only_wrapper(VipsImage *in, VipsImage **out, int height);
int vips_thumbnail_image_width_and_height_wrapper(VipsImage *in, VipsImage **out, int width, int height);

#endif /* cVipsWrapper_h */
