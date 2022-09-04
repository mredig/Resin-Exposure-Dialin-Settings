import Foundation
import ArgumentParser
import Resin_Exposure_Dialin_Settings_lib

@main
struct ResinExposure: ParsableCommand {

	@Argument(help: "Path to the input svgx file", transform: URL.init(fileURLWithPath:))
	var inputPath: URL

	@Argument(help: "Path to the output directory", transform: {
		let url = URL(fileURLWithPath: $0)
		var isDir: ObjCBool = false
		FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)

		guard isDir.boolValue == true else { throw SimpleError(message: "Output directory is not a directory!") }
		return url
	})
	var outputPath: URL

	@Option(name: [.customShort("t"), .long], help: "The base name of the output files")
	var outputName: String

	@Option(name: .shortAndLong, help: "Number of iterations")
	var iterations: Int = 5

	@Option(name: .customShort("r"), help: "Range for tests (e.g. 2.0...4.0)")
	var testRange: ClosedRange<TimeInterval>

	@Option(name: .long, help: "Recommended time from manufacturer")
	var recommendedTime: TimeInterval?

	private static let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 4
		return formatter
	}()

	func run() throws {
		let inputData = try Data(contentsOf: inputPath)

		let svg = try SVGXParsing(data: inputData)

		let outputDirectory = outputPath.appendingPathComponent(outputName)
		try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

		let adhesionFactor: Double = 10

		func export(timeValue: TimeInterval) throws {
			guard let titleTime = Self.numberFormatter.string(from: timeValue as NSNumber) else { return }

			svg.attachTime?.stringValue = "\(timeValue * adhesionFactor)"
			svg.baseTime?.stringValue = titleTime

			let outputFile = outputDirectory
				.appendingPathComponent("\(outputName)-\(titleTime)s")
				.appendingPathExtension("svgx")

			let outputFileData = svg.renderedData()
			try outputFileData.write(to: outputFile)
		}

		for timeValue in stride(from: testRange.lowerBound, through: testRange.upperBound, by: ((testRange.upperBound - (testRange.lowerBound)) / TimeInterval(iterations - 1))) {
			try export(timeValue: timeValue)
		}

		if let recommendedTime {
			try export(timeValue: recommendedTime)
		}
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
