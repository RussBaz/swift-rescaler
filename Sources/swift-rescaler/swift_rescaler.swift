import cVipsWrapper
import Foundation

public final class VipsManager {
    public enum ImageSource {
        case file(name: String)
        case data(Data)
    }

    public enum ScalingType {
        case to(UInt32)
        case by(Double)
        case proportional
        case unchanged
    }

    public class VipsContainer {
        let filename: String?
        let inImage: UnsafeMutablePointer<VipsImage>
        var outImage: UnsafeMutablePointer<VipsImage>?

        init(image: UnsafeMutablePointer<VipsImage>) {
            inImage = image
            outImage = nil
            filename = if let name = vips_image_get_filename(image) {
                String(cString: name)
            } else {
                nil
            }
        }

        init?(filename: String) {
            let running = (try? VipsManager.shared.running) ?? false
            guard running, let image = vips_image_new_from_file_wrapper(filename) else {
                return nil
            }

            self.filename = if let name = vips_image_get_filename(image) {
                String(cString: name)
            } else {
                nil
            }
            inImage = image
            outImage = nil
        }

        deinit {
            g_object_unref(inImage)
            if let outImage {
                g_object_unref(outImage)
            }
        }

        public func scale(x scaleX: ScalingType, y scaleY: ScalingType) {
            let x: UInt32
            let y: UInt32

            let oldX = vips_image_get_width(inImage)
            let oldY = vips_image_get_height(inImage)

            let scaleXBy: Double
            let scaleYBy: Double

            switch (scaleX, scaleY) {
            case let (.to(xTo), .to(yTo)):
                x = xTo
                scaleXBy = Double(x) / Double(oldX)
                y = yTo
                scaleYBy = Double(y) / Double(oldY)
            case let (.to(xTo), .by(yBy)):
                x = xTo
                scaleXBy = Double(x) / Double(oldX)
                scaleYBy = yBy
                y = UInt32(Double(oldY) * scaleYBy)
            case let (.to(xTo), .proportional):
                x = xTo
                scaleXBy = Double(x) / Double(oldX)
                scaleYBy = scaleXBy
                y = UInt32(Double(oldY) * scaleYBy)
            case let (.to(xTo), .unchanged):
                x = xTo
                scaleXBy = Double(x) / Double(oldX)
                y = UInt32(oldY)
                scaleYBy = 1
            case let (.by(xBy), .to(yTo)):
                scaleXBy = xBy
                x = UInt32(Double(oldX) * scaleXBy)
                y = yTo
                scaleYBy = Double(y) / Double(oldY)
            case let (.by(xBy), .by(yBy)):
                scaleXBy = xBy
                x = UInt32(Double(oldX) * scaleXBy)
                scaleYBy = yBy
                y = UInt32(Double(oldY) * scaleYBy)
            case let (.by(xBy), .proportional):
                scaleXBy = xBy
                x = UInt32(Double(oldX) * scaleXBy)
                scaleYBy = scaleXBy
                y = UInt32(Double(oldY) * scaleYBy)
            case let (.by(xBy), .unchanged):
                scaleXBy = xBy
                x = UInt32(Double(oldX) * scaleXBy)
                y = UInt32(oldY)
                scaleYBy = 1
            case let (.proportional, .to(yTo)):
                y = yTo
                scaleYBy = Double(y) / Double(oldY)
                scaleXBy = scaleYBy
                x = UInt32(Double(oldX) * scaleXBy)
            case let (.proportional, .by(yBy)):
                scaleYBy = yBy
                y = UInt32(Double(oldY) * scaleYBy)
                scaleXBy = scaleYBy
                x = UInt32(Double(oldX) * scaleXBy)
            case(.proportional, .proportional):
                x = UInt32(oldX)
                scaleXBy = 1
                y = UInt32(oldY)
                scaleYBy = 1
            case(.proportional, .unchanged):
                x = UInt32(oldX)
                scaleXBy = 1
                y = UInt32(oldY)
                scaleYBy = 1
            case let (.unchanged, .to(yTo)):
                x = UInt32(oldX)
                scaleXBy = 1
                y = yTo
                scaleYBy = Double(y) / Double(oldY)
            case let (.unchanged, .by(yBy)):
                x = UInt32(oldX)
                scaleXBy = 1
                scaleYBy = yBy
                y = UInt32(Double(oldY) * scaleYBy)
            case(.unchanged, .proportional):
                x = UInt32(oldX)
                scaleXBy = 1
                y = UInt32(oldY)
                scaleYBy = 1
            case(.unchanged, .unchanged):
                x = UInt32(oldX)
                scaleXBy = 1
                y = UInt32(oldY)
                scaleYBy = 1
            }
        }
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

    public static func shutdown() {
        instance = nil
    }

    public let running = true

    private init() throws {
        guard vips_init(CommandLine.arguments.first ?? "") == 0 else {
            throw RSError.failedToInit
        }
    }

    deinit {
        vips_shutdown()
    }

    public func load(_ filenames: String...) -> [VipsContainer] {
        filenames.compactMap { VipsContainer(filename: $0) }
    }

    public static func pipeline() -> RSPipeline {
        RSPipeline()
    }
}
