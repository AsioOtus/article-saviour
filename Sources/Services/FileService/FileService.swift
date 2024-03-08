import Foundation
import Logging

public struct FileService {
	let config: Configuration

	let logger = Logger(label: "FileSaver")
	let fileNameFormatter: FileNameFormatter
	let fileManager = FileManager.default

	public init (config: Configuration) {
		self.config = config
		self.fileNameFormatter = .init(config: config)
	}

	public func save (fileMeta: FileMeta, fileContent: Data) throws -> String {
		let fileName = createFileName(fileMeta: fileMeta)
		let targetDirectoryUrl = createTargetDirectoryUrl(username: fileMeta.username)
		let targetFileUrl = targetDirectoryUrl
			.appendingPathComponent(fileName)
			.appendingPathExtension("pdf")

		guard
			let targetDirectoryPath = targetDirectoryUrl.path().removingPercentEncoding,
			let targetFilePath = targetFileUrl.path().removingPercentEncoding
		else { throw Error.percentRemovingFailure }

		try validateFileExistence(fileName: fileName, targetDirectoryPath: targetDirectoryPath)
		try createTargetDirectory(targetDirectoryPath: targetDirectoryPath)
		try save(fileContent: fileContent, fileUrl: targetFileUrl)

		return targetFilePath
	}

	public func validateFileExistence (fileMeta: FileMeta) throws {
		let fileName = createFileName(fileMeta: fileMeta)
		let targetDirectoryUrl = createTargetDirectoryUrl(username: fileMeta.username)

		guard let targetDirectoryPath = targetDirectoryUrl.absoluteString.removingPercentEncoding
		else { throw Error.percentRemovingFailure }

		try validateFileExistence(fileName: fileName, targetDirectoryPath: targetDirectoryPath)
	}
}

private extension FileService {
	func createFileName (fileMeta: FileMeta) -> String {
		fileNameFormatter.format(fileMeta, config)
	}

	func createTargetDirectoryUrl (username: String) -> URL {
		config.useUserGrouping
			? config.directory.appendingPathComponent(username)
			: config.directory
	}

	func createTargetDirectory (targetDirectoryPath: String) throws {
		guard !fileManager.fileExists(atPath: targetDirectoryPath)
		else { return }

		logger.debug("Creating target directory \(targetDirectoryPath)")

		try fileManager.createDirectory(
			atPath: targetDirectoryPath,
			withIntermediateDirectories: false
		)
	}

	func validateFileExistence (fileName: String, targetDirectoryPath: String) throws {
		guard !config.overwriteExistingFiles else { return }

		let isTargetFileExists = try isArticleFileExists(
			fileName: fileName,
			targetDirectoryPath: targetDirectoryPath
		)

		guard !isTargetFileExists else { throw FileService.Error.fileAlreadyExists(fileName) }
	}

	func isArticleFileExists (fileName: String, targetDirectoryPath: String) throws -> Bool {
		let targetDirectoryFileNames = try? fileManager.contentsOfDirectory(atPath: targetDirectoryPath)
		let isExists = targetDirectoryFileNames?.contains { $0.starts(with: fileName) } == true
		return isExists
	}

	func save (fileContent: Data, fileUrl: URL) throws {
		do {
			try fileContent.write(to: fileUrl)
		} catch {
			throw error
		}
	}
}
