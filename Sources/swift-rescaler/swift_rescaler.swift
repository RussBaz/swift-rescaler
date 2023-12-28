import cVipsWrapper

public final class VipsManager {
    public class VipsContainer {
        let inImage: UnsafeMutablePointer<VipsImage>
        var outImage: UnsafeMutablePointer<VipsImage>?

        init(image: UnsafeMutablePointer<VipsImage>) {
            inImage = image
            outImage = nil
        }

        init?(filename: String) {
            guard let image = vips_image_new_from_file_wrapped(filename) else {
                return nil
            }

            inImage = image
            outImage = nil
        }

        deinit {
            g_object_unref(inImage)
            g_object_unref(outImage)
        }
    }

    public enum VipsError: Error {
        case failedToInit
    }

    private static var instance: VipsManager?

    public static var shared: VipsManager {
        get throws {
            if let instance {
                return instance
            } else {
                instance = try VipsManager()
                return instance!
            }
        }
    }

    private init() throws {
        guard vips_init(CommandLine.arguments.first ?? "") == 0 else {
            throw VipsError.failedToInit
        }
    }

    deinit {
        vips_shutdown()
    }

    func shutdown() {
        vips_shutdown()
    }

    func load(_ filenames: String...) -> [VipsContainer] {
        filenames.compactMap { VipsContainer(filename: $0) }
    }
}
