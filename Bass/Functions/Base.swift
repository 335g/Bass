//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func id<T>(x: T) -> T {
	return x
}

public func const<T, U>(x: T) -> U -> T {
	return { _ in x }
}
