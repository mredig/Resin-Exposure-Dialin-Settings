import Foundation

public struct SVGXParsing {

	private let fullSVGXData: Data

	private let xmlData: XMLDocument

	private let params: XMLElement
	private let projectionTime: XMLElement
	private let projectionAdjustment: XMLElement

	public init(data: Data) throws {
		self.fullSVGXData = data
		self.xmlData = try XMLDocument(data: try Self.getSVGData(from: data))
		self.params = try (xmlData.nodes(forXPath: "/svg[1]/printparams[1]").first as? XMLElement).unwrap()
		self.projectionTime = try (xmlData.nodes(forXPath: "/svg[1]/printparams[1]/projectiontime[1]").first as? XMLElement).unwrap()
		self.projectionAdjustment = try (xmlData.nodes(forXPath: "/svg[1]/printparams[1]/projectionadjust[1]").first as? XMLElement).unwrap()
	}

	private static func getSVGData(from data: Data) throws -> Data {
		guard
			data[0..<10] == Data("DLP-II 1.1".utf8)
		else { throw SimpleError(message: "Incorrect format") }

		var currentOffset = 16
		let _ = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt() // preview 1 offset
		currentOffset += 4
		let _ = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt() // preview 2 offset
		currentOffset += 4
		let svgOffset = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt()

		return data[svgOffset...]
	}
}

extension SVGXParsing: CustomDebugStringConvertible, CustomStringConvertible {
	public var description: String {
		"SVGXParsing\n\tparams: \(params)\n\tprojectionTime: \(projectionTime)\n\tprojectionAdjustment: \(projectionAdjustment)"
	}

	public var debugDescription: String {
		description
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


extension Optional {
	func unwrap() throws -> Wrapped {
		switch self {
		case .some(let value):
			return value
		case .none:
			throw SimpleError(message: "Error unwrapping optional of type: \(Wrapped.self)")
		}
	}
}
