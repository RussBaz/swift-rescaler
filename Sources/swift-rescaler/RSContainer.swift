import cVipsWrapper
import Foundation

public class RSContainer {
    let source: RSImageSource
    let inImage: UnsafeMutablePointer<VipsImage>?
    var outImage: UnsafeMutablePointer<VipsImage>?

    init(source imageSource: RSImageSource, in inputImage: UnsafeMutablePointer<VipsImage>? = nil, out outputImage: UnsafeMutablePointer<VipsImage>? = nil) {
        source = imageSource
        inImage = inputImage
        outImage = outputImage
    }

    init?(source imageSource: RSImageSource, preload: Bool = false) {
        source = imageSource
        outImage = nil

        if preload {
            guard (try? VipsManager.shared.running) ?? false else {
                return nil
            }

            switch source {
            case let .file(name):
                guard let image = vips_image_new_from_file_wrapper(name) else {
                    return nil
                }

                inImage = image
            case let .data(data):
                guard let image = data.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) -> UnsafeMutablePointer<VipsImage>? in
                    guard let baseAddress = bytes.baseAddress else {
                        return nil
                    }

                    return vips_image_new_from_buffer_wrapper(baseAddress, data.count, nil)
                }) else {
                    return nil
                }

                inImage = image
            }
        } else {
            inImage = nil
        }
    }

    deinit {
        g_object_unref(inImage)
        if let outImage {
            g_object_unref(outImage)
        }
    }

    var inWidth: UInt {
        let width = vips_image_get_width(inImage)

        guard width > 0 else { return 0 }
        return UInt(width)
    }

    var outWidth: UInt {
        let width = vips_image_get_width(outImage)

        guard width > 0 else { return 0 }
        return UInt(width)
    }

    var inHeight: UInt {
        let height = vips_image_get_height(inImage)

        guard height > 0 else { return 0 }
        return UInt(height)
    }

    var outHeight: UInt {
        let height = vips_image_get_height(outImage)

        guard height > 0 else { return 0 }
        return UInt(height)
    }

    var filename: String? {
        if let name = vips_image_get_filename(inImage) {
            String(cString: name)
        } else {
            nil
        }
    }

    var inputImage: VipsImage? {
        if let inImage {
            return inImage.pointee
        }

        return nil
    }

    var outputImage: VipsImage? {
        if let outImage {
            return outImage.pointee
        }

        return nil
    }

    func save(to filename: String) throws {
        if let outImage {
            guard vips_image_write_to_file_wrapper(outImage, filename) == 0 else {
                throw RSError.failedSavingToFile
            }
        } else if let inImage {
            guard vips_image_write_to_file_wrapper(inImage, filename) == 0 else {
                throw RSError.failedSavingToFile
            }
        } else {
            throw RSError.nothingToSaveToFile
        }
    }

    func save(to _: inout Data) throws {
        if let outImage {
//            try data.withUnsafeMutableBytes { bytes in
//                guard let baseAddress = bytes.baseAddress else {
//                    throw RSError.failedSavingToBuffer
//                }
//
//                vips_image_write_to_buffer_wrapper(outImage, "[]", &baseAddress, data.count)
//            }
        }
    }
}
