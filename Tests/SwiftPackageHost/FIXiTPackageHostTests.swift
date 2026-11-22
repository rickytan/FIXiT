import XCTest
@testable import FIXiTPackageHost

final class FIXiTPackageHostTests: XCTestCase {
    func testLoadsBundledJavaScript() {
        let (functionType, result) = FIXiTPackageIntegration.bootstrap()
        XCTAssertEqual(functionType, "function")
        XCTAssertEqual(result, 42)
    }

    func testPatchesObjectiveCMethod() {
        let (original, patched) = FIXiTPackageIntegration.patchMethod()
        XCTAssertEqual(original, "original")
        XCTAssertEqual(patched, "patched")
    }
}
