//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func id<T>(_ x: T) -> T {
	return x
}

public func const<T, U>(_ x: T) -> (U) -> T {
	return { _ in x }
}
