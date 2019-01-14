extension Dynamic: Decodable where RawValue: Decodable { }

extension Dynamic: Encodable where RawValue: Encodable {
	
	public func encode(to encoder: Encoder) throws {
		try rawValue.encode(to: encoder)
	}
	
}

public protocol AnyDynamic {
	var anyValue: Any { get }
	@discardableResult func observeAny(_ observer: @escaping (Any) -> Void) -> AnyObservation
}

extension Dynamic: AnyDynamic {
	public var anyValue: Any {
		return rawValue
	}
	
	public func observeAny(_ observer: @escaping (Any) -> Void) -> AnyObservation {
		return self.observe { (value) in
			observer(value)
		}
	}
}
