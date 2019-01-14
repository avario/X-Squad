import Foundation

public class Dynamic<RawValue>: RawRepresentable {
	
	public typealias ObserverClosure = (RawValue) -> Void
	
	private var observers: [UUID: ObserverClosure] = [:]
	
	public internal(set) var rawValue: RawValue {
		didSet {
			for observer in observers.values {
				observer(rawValue)
			}
		}
	}
	
	required public convenience init?(rawValue: RawValue) {
		self.init(rawValue)
	}
	
	public init(_ value: RawValue) {
		self.rawValue = value
	}
	
	public func observe(_ observer: @escaping ObserverClosure) -> Observation {
		let uuid = UUID()
		observers[uuid] = observer
		return Observation(
			uuid: uuid,
			dynamic: self)
	}
	
	internal func remove(observation: Observation) {
		observers.removeValue(forKey: observation.uuid)
	}
	
	public required convenience init(from decoder: Decoder) throws {
		guard let DecodableRawValue = RawValue.self as? Decodable.Type else {
			throw DecodingError.typeMismatch(RawValue.self, DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "The RawValue of Dynamic must be encodable to initialise from a decoder."))
		}
		
		self.init(try DecodableRawValue.init(from: decoder) as! RawValue)
	}
	
}

public class WritableDynamic<RawValue>: Dynamic<RawValue> {
	
	public var value: RawValue {
		get { return rawValue }
		set { rawValue = newValue }
	}
	
//	@available(*, unavailable, message: "Writing dynamics cannot be initialised from KVO.")
	
}

public class EventDynamic: Dynamic<Void> {
	
	public func invoke() {
		self.rawValue = Void()
	}
	
	public init() {
		super.init(Void())
	}
	
	public required convenience init(from decoder: Decoder) throws {
		throw DecodingError.typeMismatch(EventDynamic.self, DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "EventDynamic cannot be decoded"))
	}
	
	required public convenience init?(rawValue: RawValue) {
		self.init()
	}
	
}
