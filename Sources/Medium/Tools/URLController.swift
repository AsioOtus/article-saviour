import Foundation

struct URLController {
	static let `default` = Self()

	func articleUrl (referenceId: String, username: String) -> URL {
		.init(string: "https://medium.com/\(username)/\(referenceId)")!
	}

	func userUrl (username: String) -> URL {
		.init(string: "https://medium.com/\(username)")!
	}
}
