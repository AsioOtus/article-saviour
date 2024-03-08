extension FileService {
	public enum Error: Swift.Error {
		case general(String)
		case percentRemovingFailure
		case fileAlreadyExists(String)
		case fileSystem(Swift.Error)
	}
}
