import XCTest
@testable import Resin_Exposure_Dialin_Settings

final class Resin_Exposure_Dialin_SettingsTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(Resin_Exposure_Dialin_Settings().text, "Hello, World!")

		let data = Data([
			0x1C,
			0x00,
			0x00,
			0x00,
		])

		let little = try data.integerValue(of: UInt32.self, endianness: .little)
		let big = try data.integerValue(of: UInt32.self, endianness: .big)

		XCTAssertEqual(28, little)
		XCTAssertEqual(469762048, big)
    }
}
