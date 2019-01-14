public extension Dynamic {
	
    @discardableResult public func update<Base: AnyObject>(_ object: Base, keyPath: ReferenceWritableKeyPath<Base, RawValue>) -> Observation {
		object[keyPath: keyPath] = rawValue
		return observe
			{ [unowned object] (value) in
				object[keyPath: keyPath] = value
			}.during(Lifetime.of(object))
	}
	
	@discardableResult public func update<Base: AnyObject>(_ object: Base, keyPath: ReferenceWritableKeyPath<Base, RawValue?>) -> Observation {
		object[keyPath: keyPath] = rawValue
		return observe
			{ [unowned object] (value) in
				object[keyPath: keyPath] = value
			}.during(Lifetime.of(object))
	}
	
}
