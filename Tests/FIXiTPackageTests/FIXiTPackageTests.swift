import FIXiT
import XCTest

final class FIXiTPackageTests: XCTestCase {
    func testContextExecutesJavaScript() {
        XCTAssertEqual(FIXiT.context().evaluateScript("6 * 7")?.toInt32(), 42)
    }
}
