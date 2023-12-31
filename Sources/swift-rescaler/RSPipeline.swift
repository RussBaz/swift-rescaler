import Foundation

import cVipsWrapper

public class RSPipeline {
    public enum ScalingValue {
        case to(UInt)
        case by(Double)
        case proportional
        case unchanged
    }

    var expectedWidth: ScalingValue = .unchanged
    var expectedHeight: ScalingValue = .unchanged
    var inLinearColourSpace = false
    var rescale = false

    init() {}

    @discardableResult
    public func run(from source: RSImageSource, to filename: String) throws -> RSContainer {
        let container = RSContainer(source: source)

        guard let container else {
            throw RSError.failedToLoadImage
        }
        

        if rescale {
            guard let (width, height) = computeNewDimensions(container) else {
                throw RSError.badScalingValuePair
            }

            try runThumbnail(container, width: width, height: height)
        }

        removeAllMetadata(container)
        try container.save(to: filename)

        return container
    }

    public func run(from _: RSImageSource, to _: inout Data) {}

    public func rescale(width: ScalingValue, height: ScalingValue) -> Self {
        expectedWidth = width
        expectedHeight = height
        inLinearColourSpace = false
        rescale = true
        return self
    }

    private var isInputImageRequired: Bool {
        switch (expectedWidth, expectedHeight) {
        case (.to, .to), (.to, .proportional), (.proportional, .to):
            inLinearColourSpace
        default:
            true
        }
    }

    private func removeAllMetadata(_ container: RSContainer) {
        var fields: [String] = []
        if let outImage = container.outImage {
            if var rawFieldNames = vips_image_get_fields(outImage) {
                while let cs = rawFieldNames.pointee {
                    fields.append(String(cString: cs))
                    rawFieldNames += 1
                }
            }
        }

        for field in fields {
            vips_image_remove(container.outImage, field)
        }
    }

    private func runThumbnail(_ container: RSContainer, width: UInt?, height: UInt?) throws {
        let linear: Int32 = if inLinearColourSpace { 1 } else { 0 }
        var image: UnsafeMutablePointer<VipsImage>?
        switch (width, height) {
        case let (.some(w), .some(h)):
            if let input = container.inImage {
                guard vips_thumbnail_image_width_and_height_wrapper(input, &image, Int32(w), Int32(h), linear) == 0 else {
                    throw RSError.failedThumbnailingOperation
                }
            } else {
                switch container.source {
                case let .file(name):
                    guard vips_thumbnail_width_and_height_wrapper(name, &image, Int32(w), Int32(h), linear) == 0 else {
                        throw RSError.failedThumbnailingOperation
                    }
                case let .data(data):
                    var mutableDate = data
                    guard mutableDate.withUnsafeMutableBytes({ (bytes: UnsafeMutableRawBufferPointer) -> Int32 in
                        guard let baseAddress = bytes.baseAddress else {
                            return -1
                        }

                        return vips_thumbnail_buffer_width_and_height_wrapper(baseAddress, data.count, &image, Int32(w), Int32(h), linear)
                    }) == 0 else {
                        throw RSError.failedThumbnailingOperation
                    }
                }
            }
        case let (.none, .some(h)):
            if let input = container.inImage {
                guard vips_thumbnail_image_height_only_wrapper(input, &image, Int32(h), linear) == 0 else {
                    throw RSError.failedThumbnailingOperation
                }
            } else {
                switch container.source {
                case let .file(name):
                    guard vips_thumbnail_height_only_wrapper(name, &image, Int32(h), linear) == 0 else {
                        throw RSError.failedThumbnailingOperation
                    }
                case let .data(data):
                    var mutableDate = data
                    guard mutableDate.withUnsafeMutableBytes({ (bytes: UnsafeMutableRawBufferPointer) -> Int32 in
                        guard let baseAddress = bytes.baseAddress else {
                            return -1
                        }

                        return vips_thumbnail_buffer_height_only_wrapper(baseAddress, data.count, &image, Int32(h), linear)
                    }) == 0 else {
                        throw RSError.failedThumbnailingOperation
                    }
                }
            }
        case let (.some(w), .none):
            if let input = container.inImage {
                guard vips_thumbnail_image_width_only_wrapper(input, &image, Int32(w), linear) == 0 else {
                    throw RSError.failedThumbnailingOperation
                }
            } else {
                switch container.source {
                case let .file(name):
                    guard vips_thumbnail_width_only_wrapper(name, &image, Int32(w), linear) == 0 else {
                        throw RSError.failedThumbnailingOperation
                    }
                case let .data(data):
                    var mutableDate = data
                    guard mutableDate.withUnsafeMutableBytes({ (bytes: UnsafeMutableRawBufferPointer) -> Int32 in
                        guard let baseAddress = bytes.baseAddress else {
                            return -1
                        }

                        return vips_thumbnail_buffer_width_only_wrapper(baseAddress, data.count, &image, Int32(w), linear)
                    }) == 0 else {
                        throw RSError.failedThumbnailingOperation
                    }
                }
            }
        case (.none, .none):
            throw RSError.badScalingValuePair
        }

        guard let image else {
            throw RSError.failedThumbnailingOperation
        }

        container.outImage = image
    }

    private func computeNewDimensions(_ container: RSContainer) -> (width: UInt?, height: UInt?)? {
        let oldHeight: UInt
        let oldWidth: UInt

        if isInputImageRequired {
            oldHeight = 0
            oldWidth = 0
        } else {
            oldHeight = container.inHeight
            oldWidth = container.inWidth
        }

        switch (expectedWidth, expectedHeight) {
        case let (.to(wTo), .to(hTo)):
            return (width: wTo, height: hTo)
        case let (.to(wTo), .by(hTo)):
            return (width: wTo, height: UInt(Double(oldHeight) * hTo))
        case let (.to(wTo), .proportional):
            return (width: wTo, height: nil)
        case let (.to(wTo), .unchanged):
            return (width: wTo, height: oldHeight)
        case let (.by(wBy), .to(hTo)):
            return (width: UInt(Double(oldWidth) * wBy), height: hTo)
        case let (.by(wBy), .by(hBy)):
            return (width: UInt(Double(oldWidth) * wBy), height: UInt(Double(oldHeight) * hBy))
        case let (.by(wBy), .proportional):
            return (width: UInt(Double(oldWidth) * wBy), height: nil)
        case let (.by(wBy), .unchanged):
            return (width: UInt(Double(oldWidth) * wBy), height: oldHeight)
        case let (.proportional, .to(hTo)):
            return (width: nil, height: hTo)
        case let (.proportional, .by(hBy)):
            return (width: nil, height: UInt(Double(oldHeight) * hBy))
        case(.proportional, .proportional):
            return nil
        case(.proportional, .unchanged):
            return nil
        case let (.unchanged, .to(hTo)):
            return (width: oldWidth, height: hTo)
        case let (.unchanged, .by(hBy)):
            return (width: oldWidth, height: UInt(Double(oldHeight) * hBy))
        case(.unchanged, .proportional):
            return nil
        case(.unchanged, .unchanged):
            return nil
        }
    }
}
