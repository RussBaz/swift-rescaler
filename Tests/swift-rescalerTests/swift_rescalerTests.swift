@testable import swift_rescaler
import XCTest

final class swift_rescalerTests: XCTestCase {
    func testExample() throws {
        let pathPrefix = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .relativePath
        let images = try VipsManager.shared.load("\(pathPrefix)/mini_merlion.jpeg")

        XCTAssertEqual(images.count, 1)
    }
}
