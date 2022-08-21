import Foundation

public struct ResinExposureDialinSetting {
	private var _title: String
	public var title: String {
		get { settings["currProfileName"] ?? _title }
		set {
			_title = newValue
			settings["currProfileName"] = newValue
		}
	}
	public var settings: [String: String]

	public var baseLayerTime: TimeInterval? {
		get { settings["normalExposureTime"].flatMap(TimeInterval.init) }
		set { settings["normalExposureTime"] = newValue.map { String($0) } }
	}

	public var bottomLayerExposureTime: TimeInterval? {
		get { settings["bottomLayerExposureTime"].flatMap(TimeInterval.init) }
		set { settings["bottomLayerExposureTime"] = newValue.map { String($0) } }
	}

	public init(title: String, settings: [String : String]) {
		self._title = title
		self.settings = settings

		self.title = title // synchronize values
	}

	public init(title: String? = nil, data: Data) throws {
		guard let cfgString = String(data: data, encoding: .utf8) else { throw SimpleError(message: "Could not stringify input data") }

		let lines: [String] = cfgString
			.split(separator: "\n")
			.map(String.init)
			.compactMap { line in
				guard line.hasPrefix("@@") else { return nil }
				return line.replacingOccurrences(of: ##"@@.*@@"##, with: "", options: .regularExpression)
			}

		var settings = lines.reduce(into: [String: String]()) {
			let parts = $1.split(separator: ":").map(String.init)
			guard parts.count == 2 else { return }
			$0[parts[0]] = parts[1]
		}

		let finalTitle = title ?? settings["currProfileName"] ?? "Unknown"
		settings["currProfileName"] = finalTitle
		self.init(title: finalTitle, settings: settings)
	}

	public func generateConfigFile() -> String {
		settings
			.reduce(into: "") {
				$0.append("@@\(title)@@\($1.key):\($1.value)\n")
			}
	}
}
