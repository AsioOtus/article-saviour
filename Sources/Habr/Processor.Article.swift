import Logging
import Services

extension Processor {
	public struct Articles {
		let config: Configuration

		let logger = Logger(label: "Processor.Article")

		let articleDownloader = Downloader.Articles.default
		let articleHtmlExtractor = HTMLExtractor.Articles.default
		let fileService: FileService

		public init (config: Configuration) {
			self.config = config
			self.fileService = .init(config: config.fileServiceConfiguration)
		}
	}
}

public extension Processor.Articles {
	func process () async {
		await withTaskGroup(of: Void.self) { group in
			logger.info(" ----- Articles processing STARTED")

			for article in config.articles {
				group.addTask {
					await processArticle(articleId: article)
				}
			}

			await group.waitForAll()

			logger.info(" ----- Articles processing COMPLETED")
		}
	}

	func processArticle (articleId: String) async {
		do {
			logger.info("ARTICLE \(articleId) | Processing STARTER")

			logger.trace("ARTICLE \(articleId) | Downloading STARTER")
			let data = try await articleDownloader.download(
				articleId: articleId,
				language: config.language
			)
			logger.debug("ARTICLE \(articleId) | Downloading COMPLETED")

			logger.trace("ARTICLE \(articleId) | Parsing STARTED")
			let content = try articleHtmlExtractor.extractArticleContent(
				htmlData: data
			)
			logger.debug("ARTICLE \(articleId) | Parsing COMPLETED")

			logger.trace("ARTICLE \(articleId) | Conversion STARTED")
			let pdfData = try await PDFConversionService().convert(
				htmlString: content.content
			)
			logger.debug("ARTICLE \(articleId) | Conversion COMPLETED")

			logger.trace("ARTICLE \(articleId) | Saving STARTED")
			let fileMeta = FileService.FileMeta(
				title: content.meta.title,
				username: content.meta.username,
				date: content.meta.date
			)
			let targetFilePath = try fileService.save(
				fileMeta: fileMeta,
				fileContent: pdfData
			)
			logger.debug("ARTICLE \(articleId) | Saving COMPLETED | File: \(targetFilePath)")

			logger.info("ARTICLE \(articleId) | Processing COMPLETED | File: \(targetFilePath)")
		} catch FileService.Error.fileAlreadyExists(let fileName) {
			logger.debug("File already exists: \(fileName)")
			logger.info("ARTICLE \(articleId) | Processing COMPLETED | Duplicate")
		} catch {
			logger.error("ARTICLE \(articleId) | Processing FAILED | \(error.localizedDescription)")
		}
	}
}
