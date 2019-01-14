import Foundation

internal let lifetimeKey = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)

public class Lifetime {
	
	private var observations: [UUID: AnyObservation] = [:]
	
	public init() { }
	
	internal func add(observation: AnyObservation) {
		observations[observation.uuid] = observation
	}
	
	public func cancelAllObservations() {
		for observation in observations.values {
			observation.cancel()
		}
		observations.removeAll()
	}
	
	deinit {
		cancelAllObservations()
	}
	
	public static func of(_ object: AnyObject?) -> Lifetime? {
		guard let object = object else {
			return nil
		}
		
		if let lifetime = objc_getAssociatedObject(object, lifetimeKey) as? Lifetime {
			return lifetime
		}
		
		let lifetime = Lifetime()
		objc_setAssociatedObject(object, lifetimeKey, lifetime, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		
		return lifetime
	}
	
}


