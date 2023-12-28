#ifndef cVipsWrapper_h
#define cVipsWrapper_h

#include <stdio.h>
#include "vips/vips.h"

// Wrapers exist because swift cannot handle varadic in C.
VipsImage *vips_image_new_from_file_wrapped(const char *name);

#endif /* cVipsWrapper_h */
