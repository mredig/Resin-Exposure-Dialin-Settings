import Foundation

public struct SVGXParsing {

	private let data: Data
//	var svgData: Data {
//
//	}

	public init(data: Data) {
		self.data = data
	}

	public func getSVGData() throws -> Data {
		guard
			data[0..<10] == Data("DLP-II 1.1".utf8)
		else { throw SimpleError(message: "Incorrect format") }

		var currentOffset = 16
		let preview1Offset = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt()
		currentOffset += 4
		let preview2Offset = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt()
		currentOffset += 4
		let svgOffset = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt()

//		print(preview1Offset, preview2Offset, svgOffset)
		return data[svgOffset...]
//		let asdf: UInt32 = .ini
	}
}


public extension Data {
	enum Endianness {
		case big
		case little
	}

	func uInt32(endianness: Endianness = .little) throws -> UInt32 {
		try integerValue(of: UInt32.self, endianness: endianness)
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

public extension BinaryInteger {
	func toInt() -> Int {
		Int(self)
	}
}
