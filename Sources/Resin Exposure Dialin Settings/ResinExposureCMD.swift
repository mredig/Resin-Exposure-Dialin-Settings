import Foundation
import ArgumentParser
import Resin_Exposure_Dialin_Settings_lib

@main
struct ResinExposure: ParsableCommand {

	@Argument(help: "Path to the input cfg file", transform: URL.init(fileURLWithPath:))
	var inputPath: URL

	@Argument(help: "Path to the output directory", transform: {
		let url = URL(fileURLWithPath: $0)
		var isDir: ObjCBool = false
		FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)

		guard isDir.boolValue == true else { throw SimpleError(message: "Output directory is not a directory!") }
		return url
	})
	var outputPath: URL

	@Option(name: [.customShort("t"), .long], help: "The name of the resin profile")
	var resinName: String?

	@Option(name: .shortAndLong, help: "Number of iterations")
	var iterations: Int = 5

	@Option(name: .shortAndLong, help: "Mode: Adhesion ('a', 'adhesion', or '0') or base layer time ('b', 'baseLayerTime', '1')")
	var mode: Mode = .baseLayerTime

	@Option(name: .customShort("r"), help: "Range for tests (e.g. 2.0...4.0)")
	var testRange: ClosedRange<TimeInterval>

	@Option(name: .long, help: "Recommended time from manufacturer")
	var recommendedTime: TimeInterval?



	enum Mode: String, ExpressibleByArgument {
		case adhesion
		case baseLayerTime

		init?(argument: String) {
			switch argument {
			case "a", "adhesion", "0":
				self = .adhesion
			case "b", "baseLayerTime", "1":
				self = .baseLayerTime
			default: return nil
			}
		}
	}

	private static let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 4
		return formatter
	}()

	func run() throws {
		let inputData = try Data(contentsOf: inputPath)

		let svg = try SVGXParsing(data: inputData)

//		print(try svg.getSVGData())
//		let xml = try XMLDocument(data: svgData)
//
//		guard
//			let svgInfo = try xml.nodes(forXPath: "/svg[1]/printparams[1]").first as? XMLElement
//		else { throw SimpleError(message: "Unable to parse SVGX file") }
//
//		print(svgInfo)

		print(svg)

//		let config = try ResinExposureDialinSetting(title: resinName, data: inputData)
//
//		print("Loading \(inputPath.lastPathComponent) and naming it '\(config.title)' - iterating \(iterations) times between \(testRange.lowerBound) and \(testRange.upperBound) for \(mode)")
//
//		let outputDirectory = outputPath.appendingPathComponent(config.title)
//		try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
//
//		func export(mode: Mode, timeValue: TimeInterval) throws {
//			var newConfig = config
//
//			guard let titleTime = Self.numberFormatter.string(from: timeValue as NSNumber) else { return }
//
//			switch mode {
//			case .adhesion:
//				newConfig.bottomLayerExposureTime = timeValue
//				newConfig.title.append(" - \(titleTime)s bottom exposure")
//			case .baseLayerTime:
//				newConfig.baseLayerTime = timeValue
//				newConfig.title.append(" - \(titleTime)s normal exposure")
//			}
//
//			let outputFile = outputDirectory
//				.appendingPathComponent(newConfig.title)
//				.appendingPathExtension("cfg")
//
//			try newConfig.generateConfigFile().write(to: outputFile, atomically: true, encoding: .utf8)
//		}
//
//		for timeValue in stride(from: testRange.lowerBound, through: testRange.upperBound, by: ((testRange.upperBound - (testRange.lowerBound)) / TimeInterval(iterations - 1))) {
//			try export(mode: mode, timeValue: timeValue)
//		}
//
//		if let recommendedTime {
//			try export(mode: mode, timeValue: recommendedTime)
//		}
	}
}

extension ClosedRange: ExpressibleByArgument where Bound == TimeInterval {
	public init?(argument: String) {
		let parts = (argument as NSString) // I'm getting a weird error saying `String.split` is only available in macOS 13.0 and later, but that defintely shouldn't be the case... either way, this should work
			.components(separatedBy: "...")
			.compactMap(TimeInterval.init)

		guard parts.count == 2 else { return nil }

		self = parts[0]...parts[1]
	}
}
