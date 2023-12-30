import Foundation

import cVipsWrapper

public class RSPipeline {
    public enum ScalingValue {
        case to(UInt)
        case by(Double)
        case proportional
        case unchanged
    }

    var expectedX: ScalingValue = .unchanged
    var expectedY: ScalingValue = .unchanged
    var inLinearColourSpace = false

    init() {}

    public func run(from source: RSImageSource, to _: String) throws {
        let container = RSContainer(source: source)

        guard let container else {
            throw RSError.failedToLoadImage
        }

        guard let (height, width) = computeNewDimensions(container) else {
            throw RSError.badScalingValuePair
        }

        switch (height, width) {
        case let (.some(h), .some(w)):
            if let input = container.inImage {
                guard vips_thumbnail_image_width_and_height_wrapper(input, &container.outImage, Int32(w), Int32(h)) == 0 else {
                    throw RSError.failedThumbnailingOperation
                }
            } else {
                switch container.source {
                case let .file(name):
                    guard vips_thumbnail_width_and_height_wrapper(name, &container.outImage, Int32(w), Int32(h)) == 0 else {
                        throw RSError.failedThumbnailingOperation
                    }
                case let .data(data):
//                    guard data.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) -> Int32 in
//                        guard let baseAddress = bytes.baseAddress else {
//                            return -1
//                        }
//
//                        return vips_thumbnail_buffer_width_and_height_wrapper(baseAddress, data.count, &container.outImage, Int32(w), Int32(h))
//                    }) == 0 else {
//                        throw RSError.failedThumbnailingOperation
//                    }
                    ()
                }
            }
        case let (.some(h), .none):
            if let input = container.inImage {
                guard vips_thumbnail_image_height_only_wrapper(input, &container.outImage, Int32(h)) == 0 else {
                    throw RSError.failedThumbnailingOperation
                }
            } else {
                switch container.source {
                case let .file(name):
                    ()
                case let .data(data):
                    ()
                }
            }
        case let (.none, .some(w)):
            if let input = container.inImage {
                guard vips_thumbnail_image_width_only_wrapper(input, &container.outImage, Int32(w)) == 0 else {
                    throw RSError.failedThumbnailingOperation
                }
            } else {
                switch container.source {
                case let .file(name):
                    ()
                case let .data(data):
                    ()
                }
            }
        case (.none, .none):
            throw RSError.badScalingValuePair
        }
    }

    public func run(from _: RSImageSource, to _: inout Data) {}

    public func rescale(x: ScalingValue, y: ScalingValue, faster: Bool = false) -> Self {
        expectedX = x
        expectedY = y
        inLinearColourSpace = !faster
        return self
    }

    private var isInputImageRequired: Bool {
        switch (expectedX, expectedY) {
        case (.to, .to), (.to, .proportional), (.proportional, .to):
            inLinearColourSpace
        default:
            true
        }
    }

    private func computeNewDimensions(_ container: RSContainer) -> (height: UInt?, width: UInt?)? {
        let oldHeight: UInt
        let oldWidth: UInt

        if isInputImageRequired {
            oldHeight = 0
            oldWidth = 0
        } else {
            oldHeight = container.inHeight
            oldWidth = container.inWidth
        }

        switch (expectedX, expectedY) {
        case let (.to(xTo), .to(yTo)):
            return (height: xTo, width: yTo)
        case let (.to(xTo), .by(yBy)):
            return (height: xTo, width: UInt(Double(oldWidth) * yBy))
        case let (.to(xTo), .proportional):
            return (height: xTo, width: nil)
        case let (.to(xTo), .unchanged):
            return (height: xTo, width: oldWidth)
        case let (.by(xBy), .to(yTo)):
            return (height: UInt(Double(oldHeight) * xBy), width: yTo)
        case let (.by(xBy), .by(yBy)):
            return (height: UInt(Double(oldHeight) * xBy), width: UInt(Double(oldWidth) * yBy))
        case let (.by(xBy), .proportional):
            return (height: UInt(Double(oldHeight) * xBy), width: nil)
        case let (.by(xBy), .unchanged):
            return (height: UInt(Double(oldHeight) * xBy), width: oldWidth)
        case let (.proportional, .to(yTo)):
            return (height: nil, width: yTo)
        case let (.proportional, .by(yBy)):
            return (height: nil, width: UInt(Double(oldWidth) * yBy))
        case(.proportional, .proportional):
            return nil
        case(.proportional, .unchanged):
            return nil
        case let (.unchanged, .to(yTo)):
            return (height: oldHeight, width: yTo)
        case let (.unchanged, .by(yBy)):
            return (height: oldHeight, width: UInt(Double(oldWidth) * yBy))
        case(.unchanged, .proportional):
            return nil
        case(.unchanged, .unchanged):
            return nil
        }
    }
}
