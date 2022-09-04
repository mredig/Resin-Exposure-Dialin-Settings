import Foundation

public struct SVGXParsing {

	private let fullSVGXData: Data
	private let previewAndHeaderData: Data

	private let xmlData: XMLDocument

	private let params: XMLElement
	private let projectionTime: XMLElement
	private let projectionAdjustment: XMLElement

	static private let materialname = "materialname"
	public var materialName: XMLNode? {
		get { getNode(for: Self.materialname, on: \.params) }
		set { setNode(node: newValue, for: Self.materialname, on: \.params) }
	}

	static private let layerheight = "layerheight"
	public var layerHeight: XMLNode? {
		get { getNode(for: Self.layerheight, on: \.params) }
		set { setNode(node: newValue, for: Self.layerheight, on: \.params) }
	}

	static private let lightintensity = "lightintensity"
	public var lightIntensity: XMLNode? {
		get { getNode(for: Self.lightintensity, on: \.params) }
		set { setNode(node: newValue, for: Self.lightintensity, on: \.params) }
	}

	static private let resolutionx = "resolutionx"
	public var resolutionX: XMLNode? {
		get { getNode(for: Self.resolutionx, on: \.params) }
		set { setNode(node: newValue, for: Self.resolutionx, on: \.params) }
	}

	static private let resolutiony = "resolutiony"
	public var resolutionY: XMLNode? {
		get { getNode(for: Self.resolutiony, on: \.params) }
		set { setNode(node: newValue, for: Self.resolutiony, on: \.params) }
	}

	static private let displaywidth = "displaywidth"
	public var displayWidth: XMLNode? {
		get { getNode(for: Self.displaywidth, on: \.params) }
		set { setNode(node: newValue, for: Self.displaywidth, on: \.params) }
	}

	static private let displayheight = "displayheight"
	public var displayHeight: XMLNode? {
		get { getNode(for: Self.displayheight, on: \.params) }
		set { setNode(node: newValue, for: Self.displayheight, on: \.params) }
	}

	static private let machinez = "machinez"
	public var machineZ: XMLNode? {
		get { getNode(for: Self.machinez, on: \.params) }
		set { setNode(node: newValue, for: Self.machinez, on: \.params) }
	}

	static private let attachlayer = "attachlayer"
	public var attachLayer: XMLNode? {
		get { getNode(for: Self.attachlayer, on: \.projectionTime) }
		set { setNode(node: newValue, for: Self.attachlayer, on: \.projectionTime) }
	}

	static private let buildinlayer = "buildinlayer"
	public var buildInLayer: XMLNode? {
		get { getNode(for: Self.buildinlayer, on: \.projectionTime) }
		set { setNode(node: newValue, for: Self.buildinlayer, on: \.projectionTime) }
	}

	static private let attachtime = "attachtime"
	public var attachTime: XMLNode? {
		get { getNode(for: Self.attachtime, on: \.projectionTime) }
		set { setNode(node: newValue, for: Self.attachtime, on: \.projectionTime) }
	}

	static private let basetime = "basetime"
	public var baseTime: XMLNode? {
		get { getNode(for: Self.basetime, on: \.projectionTime) }
		set { setNode(node: newValue, for: Self.basetime, on: \.projectionTime) }
	}

	static private let projectionAdjustX = "x"
	public var projectionAdjustX: XMLNode? {
		get { getNode(for: Self.projectionAdjustX, on: \.projectionAdjustment) }
		set { setNode(node: newValue, for: Self.projectionAdjustX, on: \.projectionAdjustment) }

	}

	static private let projectionAdjustY = "y"
	public var projectionAdjustY: XMLNode? {
		get { getNode(for: Self.projectionAdjustY, on: \.projectionAdjustment) }
		set { setNode(node: newValue, for: Self.projectionAdjustY, on: \.projectionAdjustment) }
	}

	public init(data: Data) throws {
		self.fullSVGXData = data
		let (previewData, svgData) = try Self.getSVGData(from: data)
		self.previewAndHeaderData = previewData
		self.xmlData = try XMLDocument(data: svgData)
		self.params = try (xmlData.nodes(forXPath: "/svg[1]/printparams[1]").first as? XMLElement).unwrap()
		self.projectionTime = try (xmlData.nodes(forXPath: "/svg[1]/printparams[1]/projectiontime[1]").first as? XMLElement).unwrap()
		self.projectionAdjustment = try (xmlData.nodes(forXPath: "/svg[1]/printparams[1]/projectionadjust[1]").first as? XMLElement).unwrap()
	}

	private func getNode(for key: String, on keypath: KeyPath<SVGXParsing, XMLElement>) -> XMLNode? {
		self[keyPath: keypath].attribute(forName: key)
	}

	private func setNode(node: XMLNode?, for key: String, on keypath: KeyPath<SVGXParsing, XMLElement>) {
		self[keyPath: keypath].removeAttribute(forName: key)
		node?.name = key
		node.map {
			self[keyPath: keypath].addAttribute($0)
		}
	}

	private static func getSVGData(from data: Data) throws -> (previewAndHeader: Data, svgData:Data) {
		guard
			data[0..<10] == Data("DLP-II 1.1".utf8)
		else { throw SimpleError(message: "Incorrect format") }

		var currentOffset = 16
		let _ = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt() // preview 1 offset
		currentOffset += 4
		let _ = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt() // preview 2 offset
		currentOffset += 4
		let svgOffset = try data[currentOffset..<currentOffset + 4].integerValue(of: UInt32.self).toInt()

		return (data[..<svgOffset], data[svgOffset...])
	}
}

extension SVGXParsing: CustomDebugStringConvertible, CustomStringConvertible {
	public var description: String {
		debugDescription
	}

	public var debugDescription: String {
		"""
		SVGXParsing:
			materialName: \(materialName?.stringValue ?? "nil")
			layerHeight: \(layerHeight?.stringValue ?? "nil")
			lightIntensity: \(lightIntensity?.stringValue ?? "nil")
			resolutionX: \(resolutionX?.stringValue ?? "nil")
			resolutionY: \(resolutionY?.stringValue ?? "nil")
			displayWidth: \(displayWidth?.stringValue ?? "nil")
			displayHeight: \(displayHeight?.stringValue ?? "nil")
			machineZ: \(machineZ?.stringValue ?? "nil")
			attachLayer: \(attachLayer?.stringValue ?? "nil")
			buildInLayer: \(buildInLayer?.stringValue ?? "nil")
			attachTime: \(attachTime?.stringValue ?? "nil")
			baseTime: \(baseTime?.stringValue ?? "nil")
			projectionAdjustX: \(projectionAdjustX?.stringValue ?? "nil")
			projectionAdjustY: \(projectionAdjustY?.stringValue ?? "nil")
		"""
	}
}
