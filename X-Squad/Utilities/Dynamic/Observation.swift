import Foundation

public extension Dynamic {
	
	public struct Observation {
		public let uuid: UUID
		internal weak var dynamic: Dynamic<RawValue>?
		
		public func cancel() {
			dynamic?.remove(observation: self)
		}
		
		@discardableResult public func during(_ lifeTime: Lifetime?) -> Observation {
			if let lifeTime = lifeTime {
				lifeTime.add(observation: self)
			} else {
				cancel()
			}
			return self
		}
	}
	
}

public protocol AnyObservation {
	var uuid: UUID { get }
	func cancel()
	
	@discardableResult func during(_ lifeTime: Lifetime?) -> Self
}

extension Dynamic.Observation: AnyObservation { }
