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
