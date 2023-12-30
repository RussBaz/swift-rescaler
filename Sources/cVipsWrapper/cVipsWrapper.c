#include "include/cVipsWrapper.h"

VipsImage *vips_image_new_from_file_wrapper(const char *filename) {
    return vips_image_new_from_file(filename, NULL);
}

VipsImage *vips_image_new_from_buffer_wrapper(const void *buf, size_t len, const char *option_string) {
    return vips_image_new_from_buffer(buf, len, option_string, NULL);
}

int vips_image_write_to_file_wrapper(VipsImage *image, const char *filename) {
    return vips_image_write_to_file(image, filename, NULL);
}

int vips_image_write_to_buffer_wrapper(VipsImage *image, const char *suffix, void **buf, size_t *size) {
    return vips_image_write_to_buffer(image, suffix, buf, size, NULL);
}

int vips_thumbnail_width_only_wrapper(const char *filename, VipsImage **out, int width, gboolean linear) {
    return vips_thumbnail(filename, out, width, "linear", linear, NULL);
}

int vips_thumbnail_height_only_wrapper(const char *filename, VipsImage **out, int height, gboolean linear) {
    return vips_thumbnail(filename, out, VIPS_MAX_COORD, "height", height, "linear", linear, NULL);
}

int vips_thumbnail_width_and_height_wrapper(const char *filename, VipsImage **out, int width, int height, gboolean linear) {
    return vips_thumbnail(filename, out, width, "height", height, "linear", linear, NULL);
}

int vips_thumbnail_buffer_width_only_wrapper(void *buf, size_t len, VipsImage **out, int width, gboolean linear) {
    return vips_thumbnail_buffer(buf, len, out, width, "linear", linear, NULL);
}

int vips_thumbnail_buffer_height_only_wrapper(void *buf, size_t len, VipsImage **out, int height, gboolean linear) {
    return vips_thumbnail_buffer(buf, len, out, VIPS_MAX_COORD, "height", height, "linear", linear, NULL);
}

int vips_thumbnail_buffer_width_and_height_wrapper(void *buf, size_t len, VipsImage **out, int width, int height, gboolean linear) {
    return vips_thumbnail_buffer(buf, len, out, width, "height", height, "linear", linear, NULL);
}

int vips_thumbnail_image_width_only_wrapper(VipsImage *in, VipsImage **out, int width, gboolean linear) {
    return vips_thumbnail_image(in, out, width, "linear", linear, NULL);
}

int vips_thumbnail_image_height_only_wrapper(VipsImage *in, VipsImage **out, int height, gboolean linear) {
    return vips_thumbnail_image(in, out, VIPS_MAX_COORD, "height", height, "linear", linear, NULL);
}

int vips_thumbnail_image_width_and_height_wrapper(VipsImage *in, VipsImage **out, int width, int height, gboolean linear) {
    return vips_thumbnail_image(in, out, width, "height", height, "linear", linear, NULL);
}
