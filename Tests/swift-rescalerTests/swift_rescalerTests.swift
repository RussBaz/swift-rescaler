@testable import swift_rescaler
import XCTest

final class swift_rescalerTests: XCTestCase {
    func testExample() throws {
        let pathPrefix = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .relativePath
        let images = try VipsManager.shared.load("\(pathPrefix)/samples/mini_merlion.jpeg")

        XCTAssertEqual(images.count, 1)

        let pipe = try VipsManager.shared.pipeline()

        try pipe.rescale(x: .to(256), y: .proportional)
            .run(from: .file(name: "\(pathPrefix)/samples/mini_merlion.jpeg"), to: "\(pathPrefix)/samples/mini_merlion_256.jpeg")
    }
}
