import Foundation

internal let valueObservationKey = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)

public extension Dynamic {
	
	public convenience init<Base: NSObject>(observing object: Base, keyPath: KeyPath<Base, RawValue>) {
		self.init(object[keyPath: keyPath])
		
		let valueObservation = object.observe(keyPath, options: .new) { [unowned self] (_, value) in
			self.rawValue = value.newValue!
		}
		objc_setAssociatedObject(self, valueObservationKey, valueObservation, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	
}
