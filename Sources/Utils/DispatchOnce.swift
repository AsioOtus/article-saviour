import Foundation

public class DispatchOnce {
	private let semaphore = DispatchSemaphore(value: 1)

	public private(set) var isPerformed: Bool = false

	private let action: () -> Void

	public init (_ action: @escaping () -> Void) {
		self.action = action
	}

	public func perform () {
		semaphore.wait()

		guard !isPerformed else {
			semaphore.signal()
			return
		}

		isPerformed = true
		semaphore.signal()

		action()
	}
}
