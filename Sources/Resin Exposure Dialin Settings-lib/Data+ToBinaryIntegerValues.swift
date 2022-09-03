import Foundation

public extension Data {
	enum Endianness {
		case big
		case little
	}

	func integerValue<T: BinaryInteger>(of type: T.Type, endianness: Endianness = .little) throws -> T {
		var rVal: T = 0
		guard
			count == (rVal.bitWidth / 8)
		else { throw SimpleError(message: "Incorrect byte size") }

		let bytes = endianness == .little ? self : Data(self.reversed())

		for byte in bytes.enumerated() {
			rVal |= T(byte.element) << (byte.offset * 8)
		}

		return rVal
	}
}
