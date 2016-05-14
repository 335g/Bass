//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

extension Array: Semigroup {
	public func mappend(x: Array) -> Array {
		return self + x
	}
}

extension Array: Monoid {
	public static var mempty: Array {
		return []
	}
}

extension Array: Foldable {
	public func foldr<T>(initial: T, _ f: Element -> T -> T) -> T {
		return reverse().reduce(initial){ f($1)($0) }
	}
	
	public func foldl<T>(initial: T, _ f: T -> Element -> T) -> T {
		return reduce(initial, combine: uncurry(f))
	}
	
	public func null() -> Bool {
		return isEmpty
	}
	
	public func length() -> Int {
		return count
	}
	
	public func find(predicate: Element -> Bool) throws -> Element? {
		guard let index = indexOf(predicate) else {
			return nil
		}
		
		return self[index]
	}
	
	public func toList() -> [Element] {
		return self
	}
}