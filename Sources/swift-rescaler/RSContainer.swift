import cVipsWrapper
import Foundation

public class RSContainer {
    let source: RSImageSource
    var iImage: UnsafeMutablePointer<VipsImage>?
    var oImage: UnsafeMutablePointer<VipsImage>?

    init(source imageSource: RSImageSource, in inputImage: UnsafeMutablePointer<VipsImage>? = nil, out outputImage: UnsafeMutablePointer<VipsImage>? = nil) {
        source = imageSource
        iImage = inputImage
        outImage = outputImage
    }

    init?(source imageSource: RSImageSource, preload: Bool = false) {
        source = imageSource
        oImage = nil

        if preload {
            guard (try? VipsManager.shared.running) ?? false else {
                return nil
            }

            switch source {
            case let .file(name):
                guard let image = vips_image_new_from_file_wrapper(name) else {
                    return nil
                }

                iImage = image
            case let .data(data):
                guard let image = data.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) -> UnsafeMutablePointer<VipsImage>? in
                    guard let baseAddress = bytes.baseAddress else {
                        return nil
                    }

                    return vips_image_new_from_buffer_wrapper(baseAddress, data.count, nil)
                }) else {
                    return nil
                }

                iImage = image
            }
        } else {
            iImage = nil
        }
    }

    deinit {
        if let inImage {
            g_object_unref(inImage)
        }
        if let outImage {
            g_object_unref(outImage)
        }
    }

    var inWidth: UInt {
        guard let inImage else { return 0 }
        let width = vips_image_get_width(inImage)

        guard width > 0 else { return 0 }
        return UInt(width)
    }

    var outWidth: UInt {
        guard let outImage else { return 0 }
        let width = vips_image_get_width(outImage)

        guard width > 0 else { return 0 }
        return UInt(width)
    }

    var inHeight: UInt {
        guard let inImage else { return 0 }
        let height = vips_image_get_height(inImage)

        guard height > 0 else { return 0 }
        return UInt(height)
    }

    var outHeight: UInt {
        guard let outImage else { return 0 }
        let height = vips_image_get_height(outImage)

        guard height > 0 else { return 0 }
        return UInt(height)
    }

    var filename: String? {
        guard let inImage else { return nil }
        
        return if let name = vips_image_get_filename(inImage) {
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

    var outImage: UnsafeMutablePointer<VipsImage>? {
        get {
            oImage
        }
        set {
            if let oImage {
                g_object_unref(oImage)
            }

            oImage = newValue
        }
    }

    var inImage: UnsafeMutablePointer<VipsImage>? {
        get {
            iImage
        }
        set {
            if let iImage {
                g_object_unref(iImage)
            }

            iImage = newValue
        }
    }

    func load() throws {
        if inImage == nil, oImage == nil {
            guard (try? VipsManager.shared.running) ?? false else {
                throw RSError.notRunning
            }

            switch source {
            case let .file(name):
                guard let image = vips_image_new_from_file_wrapper(name) else {
                    throw RSError.failedToLoadImage
                }

                outImage = image
            case let .data(data):
                guard let image = data.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) -> UnsafeMutablePointer<VipsImage>? in
                    guard let baseAddress = bytes.baseAddress else {
                        return nil
                    }

                    return vips_image_new_from_buffer_wrapper(baseAddress, data.count, nil)
                }) else {
                    throw RSError.failedToLoadImage
                }

                outImage = image
            }
        }
    }

    func save(to filename: String) throws {
        try load()
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
