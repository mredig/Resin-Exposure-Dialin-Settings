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
		get { params.attribute(forName: Self.materialname) }
		set {
			params.removeAttribute(forName: Self.materialname)
			newValue?.name = Self.materialname
			newValue.map {
				params.addAttribute($0)
			}
		}
	}

	static private let layerheight = "layerheight"
	public var layerHeight: XMLNode? {
		get { params.attribute(forName: Self.layerheight) }
		set {
			params.removeAttribute(forName: Self.layerheight)
			newValue?.name = Self.layerheight
			newValue.map {
				params.addAttribute($0)
			}
		}
	}

	static private let lightintensity = "lightintensity"
	public var lightIntensity: XMLNode? {
		get { params.attribute(forName: Self.lightintensity) }
		set {
			params.removeAttribute(forName: Self.lightintensity)
			newValue?.name = Self.lightintensity
			newValue.map {
				params.addAttribute($0)
			}
		}
	}

	static private let resolutionx = "resolutionx"
	public var resolutionX: XMLNode? {
		get { params.attribute(forName: Self.resolutionx) }
		set {
			params.removeAttribute(forName: Self.resolutionx)
			newValue?.name = Self.resolutionx
			newValue.map {
				params.addAttribute($0)
			}
		}
	}


	static private let resolutiony = "resolutiony"
	public var resolutionY: XMLNode? {
		get { params.attribute(forName: Self.resolutiony) }
		set {
			params.removeAttribute(forName: Self.resolutiony)
			newValue?.name = Self.resolutiony
			newValue.map {
				params.addAttribute($0)
			}
		}
	}

	static private let displaywidth = "displaywidth"
	public var displayWidth: XMLNode? {
		get { params.attribute(forName: Self.displaywidth) }
		set {
			params.removeAttribute(forName: Self.displaywidth)
			newValue?.name = Self.displaywidth
			newValue.map {
				params.addAttribute($0)
			}
		}
	}

	static private let displayheight = "displayheight"
	public var displayHeight: XMLNode? {
		get { params.attribute(forName: Self.displayheight) }
		set {
			params.removeAttribute(forName: Self.displayheight)
			newValue?.name = Self.displayheight
			newValue.map {
				params.addAttribute($0)
			}
		}
	}

	static private let machinez = "machinez"
	public var machineZ: XMLNode? {
		get { params.attribute(forName: Self.machinez) }
		set {
			params.removeAttribute(forName: Self.machinez)
			newValue?.name = Self.machinez
			newValue.map {
				params.addAttribute($0)
			}
		}
	}

	static private let attachlayer = "attachlayer"
	public var attachLayer: XMLNode? {
		get { projectionTime.attribute(forName: Self.attachlayer) }
		set {
			projectionTime.removeAttribute(forName: Self.attachlayer)
			newValue?.name = Self.attachlayer
			newValue.map {
				projectionTime.addAttribute($0)
			}
		}
	}

	static private let buildinlayer = "buildinlayer"
	public var buildInLayer: XMLNode? {
		get { projectionTime.attribute(forName: Self.buildinlayer) }
		set {
			projectionTime.removeAttribute(forName: Self.buildinlayer)
			newValue?.name = Self.buildinlayer
			newValue.map {
				projectionTime.addAttribute($0)
			}
		}
	}

	static private let attachtime = "attachtime"
	public var attachTime: XMLNode? {
		get { projectionTime.attribute(forName: Self.attachtime) }
		set {
			projectionTime.removeAttribute(forName: Self.attachtime)
			newValue?.name = Self.attachtime
			newValue.map {
				projectionTime.addAttribute($0)
			}
		}
	}

	static private let basetime = "basetime"
	public var baseTime: XMLNode? {
		get { projectionTime.attribute(forName: Self.basetime) }
		set {
			projectionTime.removeAttribute(forName: Self.basetime)
			newValue?.name = Self.basetime
			newValue.map {
				projectionTime.addAttribute($0)
			}
		}
	}

	static private let projectionAdjustX = "x"
	public var projectionAdjustX: XMLNode? {
		get { projectionAdjustment.attribute(forName: Self.projectionAdjustX) }
		set {
			projectionAdjustment.removeAttribute(forName: Self.projectionAdjustX)
			newValue?.name = Self.projectionAdjustX
			newValue.map {
				projectionAdjustment.addAttribute($0)
			}
		}
	}

	static private let projectionAdjustY = "y"
	public var projectionAdjustY: XMLNode? {
		get { projectionAdjustment.attribute(forName: Self.projectionAdjustY) }
		set {
			projectionAdjustment.removeAttribute(forName: Self.projectionAdjustY)
			newValue?.name = Self.projectionAdjustY
			newValue.map {
				projectionAdjustment.addAttribute($0)
			}
		}
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
