import Foundation

public extension Dynamic {
	
    public func map<NewValue>(_ transform: @escaping (RawValue) -> NewValue) -> Dynamic<NewValue> {
        let dynamic = Dynamic<NewValue>(transform(rawValue) as NewValue)
		
        self.observe
            { (value) in
                dynamic.rawValue = transform(value)
            }.during(Lifetime.of(dynamic))
		
        return dynamic
    }
	
    public func combine<OtherValue, NewValue>(with otherDynamic: Dynamic<OtherValue>, _ map: @escaping (RawValue, OtherValue) -> NewValue) -> Dynamic<NewValue> {
		
        let dynamic = Dynamic<NewValue>(map(rawValue, otherDynamic.rawValue))
		
        self.observe
            { (value) in
                dynamic.rawValue = map(value, otherDynamic.rawValue)
            }.during(Lifetime.of(dynamic))
		
        otherDynamic.observe
            { (value) in
                dynamic.rawValue = map(self.rawValue, value)
            }.during(Lifetime.of(dynamic))
		
        return dynamic
    }
	
    public func combine<OtherValue, NewValue>(with otherDynamic: Dynamic<OtherValue>, _ flatMap: @escaping (RawValue, OtherValue) -> Dynamic<NewValue>) -> Dynamic<NewValue> {
		
        let initialDynamic = flatMap(rawValue, otherDynamic.rawValue)
		
        let dynamic = Dynamic<NewValue>(initialDynamic.rawValue)
		
        var observation = initialDynamic.observe { (value) in
            dynamic.rawValue = value
        }
		
        self.observe
            { (value) in
                observation.cancel()
                let newDynamic = flatMap(value, otherDynamic.rawValue)
                dynamic.rawValue = newDynamic.rawValue
				
                observation = newDynamic.observe({ (value) in
                    dynamic.rawValue = value
                })
            }.during(Lifetime.of(dynamic))
		
        otherDynamic.observe
            { (value) in
                observation.cancel()
                let newDynamic = flatMap(self.rawValue, value)
                dynamic.rawValue = newDynamic.rawValue
				
                observation = newDynamic.observe({ (value) in
                    dynamic.rawValue = value
                })
            }.during(Lifetime.of(dynamic))
		
        return dynamic
    }
	
    func merge(with otherDynamic: Dynamic<RawValue>) -> Dynamic<RawValue> {
        let dynamic = Dynamic(otherDynamic.rawValue)
		
        self.observe
            { (value) in
                dynamic.rawValue = value
            }.during(Lifetime.of(dynamic))
		
        otherDynamic.observe
            { (value) in
                dynamic.rawValue = value
            }.during(Lifetime.of(dynamic))
		
        return dynamic
    }
	
    func flatMap<NewValue>(_ transform: @escaping (RawValue) -> Dynamic<NewValue>) -> Dynamic<NewValue> {
        let initialDynamic = transform(rawValue)
		
        let dynamic = Dynamic<NewValue>(initialDynamic.rawValue)
		
        var observation = initialDynamic.observe { (value) in
            dynamic.rawValue = value
        }
		
        self.observe
            { (value) in
                observation.cancel()
                let newDynamic = transform(value)
                dynamic.rawValue = newDynamic.rawValue
				
                observation = newDynamic.observe({ (value) in
                    dynamic.rawValue = value
                })
            }.during(Lifetime.of(dynamic))
		
        return dynamic
    }
	
}
