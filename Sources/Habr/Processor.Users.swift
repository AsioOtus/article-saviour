import Logging
import Services

extension Processor {
	public struct Users {
		let config: Configuration

		let logger = Logger(label: "UserProcessor")

		let hubsFilter = HubsFilter.default
		let userDownloader = Downloader.Users.default
		let articleDownloader = Downloader.Articles.default
		let articleHtmlExtractor = HTMLExtractor.Articles.default
		let fileService: FileService

		public init (config: Configuration) {
			self.config = config
			self.fileService = .init(
				config: config.fileServiceConfiguration
			)
		}

		public func process () async {
			let rawUsers = await withTaskGroup(of: User.Raw?.self) { group in
				logger.info(" ----- User's article IDs downloading STARTED\n")

				for username in config.usernames {
					group.addTask {
						await downloadArticleIds(username: username, config: config)
					}
				}

				var rawUsers: [User.Raw] = []

				for await case .some(let result) in group {
					rawUsers.append(result)
				}

				logger.info(" ----- User's article IDs downloading COMPLETED\n")

				return rawUsers
			}

			await withTaskGroup(of: Void.self) { group in
				logger.info(" ----- Users articles processing STARTED\n")

				for rawUser in rawUsers {
					for articleSnippet in rawUser.articleSnippets {
						group.addTask {
							await processArticle(
								articleSnippet: articleSnippet,
								username: rawUser.name,
								config: config
							)
						}
					}
				}

				await group.waitForAll()

				logger.info(" ----- Users articles processing COMPLETED\n")
			}
		}

		func downloadArticleIds (username: String, config: Configuration) async -> User.Raw? {
			do {
				let articleSnippets = try await userDownloader.downloadArticleSnippets(
					username: username,
					language: config.language
				)

				let filteredArticleSnippets = hubsFilter
					.filterArticleSnippets(articleSnippets: articleSnippets, hubs: config.hubs)

				logger.info("USER \(username) | Filtered articles: \(filteredArticleSnippets.count)\n  \(filteredArticleSnippets.map(\.id).joined(separator: " "))\n")

				return .init(name: username, articleSnippets: filteredArticleSnippets)
			} catch {
				logger.error("User \(username) | Articles IDs downloading FAILED | \(error.localizedDescription)")
				return nil
			}
		}

		func processArticle (articleSnippet: Article.Snippet, username: String, config: Configuration) async {
			do {
				logger.info("USER \(username) | ARTICLE \(articleSnippet.id) | Processing STARTED")

				let fileMeta = FileService.FileMeta(
					title: articleSnippet.meta.title,
					username: articleSnippet.meta.username,
					date: articleSnippet.meta.date
				)
				try fileService.validateFileExistence(fileMeta: fileMeta)

				logger.trace("USER \(username) | ARTICLE \(articleSnippet.id) | Downloading STARTED")
				let data = try await articleDownloader.download(
					articleId: articleSnippet.id,
					language: config.language
				)
				logger.debug("USER \(username) | ARTICLE \(articleSnippet.id) | Downloading COMPLETED")

				logger.trace("USER \(username) | ARTICLE \(articleSnippet.id) | Parsing STARTED")
				let content = try articleHtmlExtractor.extractArticleContent(
					htmlData: data
				)
				logger.debug("USER \(username) | ARTICLE \(articleSnippet.id) | Parsing COMPLETED")

				logger.trace("USER \(username) | ARTICLE \(articleSnippet.id) | Conversion STARTED")
				let pdfData = try await PDFConversionService().convert(htmlString: content.content)
				logger.debug("USER \(username) | ARTICLE \(articleSnippet.id) | Conversion COMPLETED")

				logger.trace("USER \(username) | ARTICLE \(articleSnippet.id) | Saving STARTED")
				let targetFilePath = try fileService.save(fileMeta: fileMeta, fileContent: pdfData)
				logger.debug("USER \(username) | ARTICLE \(articleSnippet.id) | Saving COMPLETED | File: \(targetFilePath)")

				logger.info("USER \(username) | ARTICLE \(articleSnippet.id) | Processing COMPLETED | File: \(targetFilePath)")
			} catch FileService.Error.fileAlreadyExists(let fileName)  {
				logger.debug("File already exists: \(fileName)")
				logger.info("USER \(username) | ARTICLE \(articleSnippet.id) | Processing COMPLETED | Duplicate")
			} catch {
				logger.error("USER \(username) | ARTICLE \(articleSnippet.id) | Processing FAILED | \(error.localizedDescription)")
			}
		}
	}
}
