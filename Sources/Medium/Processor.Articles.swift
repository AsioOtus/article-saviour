import Logging
import Services

extension Processor {
	public struct Articles {
		let config: Configuration

		let logger = Logger(label: "Processor.Article")

		let articleHtmlParser = HTMLParser.Articles.default
		let articleDownloader = Downloader.Articles.default
		let fileService: FileService

		public init (config: Configuration) {
			self.config = config
			self.fileService = .init(config: config.fileServiceConfiguration)
		}

		public func process () async {
			await withTaskGroup(of: Void.self) { group in
				logger.info(" ----- Articles processing STARTED")

				for articleReference in config.articleReferences {
					group.addTask {
						await processArticle(articleReference: articleReference)
					}
				}

				await group.waitForAll()

				logger.info(" ----- Articles processing COMPLETED")
			}
		}
	}
}

private extension Processor.Articles {
	private func processArticle (articleReference: Article.Reference) async {
		do {
			logger.info("ARTICLE \(articleReference.referenceId) | Processing STARTER")

			logger.trace("ARTICLE \(articleReference.referenceId) | Downloading STARTER")
			let data = try await articleDownloader.download(
				referenceId: articleReference.referenceId,
				username: articleReference.username
			)
			logger.debug("ARTICLE \(articleReference.referenceId) | Downloading COMPLETED")

			logger.trace("ARTICLE \(articleReference.referenceId) | Parsing STARTED")
			let article = try articleHtmlParser.parseHtml(htmlData: data)
			logger.debug("ARTICLE \(articleReference.referenceId) | Parsing COMPLETED")

			logger.trace("ARTICLE \(articleReference.referenceId) | Conversion STARTED")
			let pdfData = try await PDFConversionService().convert(
				htmlString: article.content
			)
			logger.debug("ARTICLE \(articleReference.referenceId) | Conversion COMPLETED")

			logger.trace("ARTICLE \(articleReference.referenceId) | Saving STARTED")
			let fileMeta = FileService.FileMeta(
				title: article.meta.title,
				username: article.meta.username,
				date: article.meta.date
			)
			let targetFilePath = try fileService.save(
				fileMeta: fileMeta,
				fileContent: pdfData
			)
			logger.debug("ARTICLE \(articleReference.referenceId) | Saving COMPLETED | File: \(targetFilePath)")

			logger.info("ARTICLE \(articleReference.referenceId) | Processing COMPLETED | File: \(targetFilePath)")
		} catch FileService.Error.fileAlreadyExists(let fileName) {
			logger.debug("File already exists: \(fileName)")
			logger.info("ARTICLE \(articleReference.referenceId) | Processing COMPLETED | Duplicate")
		} catch {
			logger.error("ARTICLE \(articleReference.referenceId) | Processing FAILED | \(error.localizedDescription)")
		}
	}
}
