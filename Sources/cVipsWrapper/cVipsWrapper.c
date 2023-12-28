#include "include/cVipsWrapper.h"

VipsImage *vips_image_new_from_file_wrapped(const char *name) {
    return vips_image_new_from_file(name, NULL);
}
