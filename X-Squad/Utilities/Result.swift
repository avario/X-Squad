public enum Result<Value> {
	case success(Value)
	case failure(Error)
}

public typealias Response<Value> = (Result<Value>) -> Void
