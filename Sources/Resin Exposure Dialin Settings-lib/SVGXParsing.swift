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

