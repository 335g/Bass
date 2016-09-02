//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func pack<A, B, C>(_ value: C, with: (A, B)) -> (A, B, C) {
	return (with.0, with.1, value)
}

public func pack<A, B, C, D>(_ value: D, with: (A, B, C)) -> (A, B, C, D) {
	return (with.0, with.1, with.2, value)
}

public func pack<A, B, C, D, E>(_ value: E, with: (A, B, C, D)) -> (A, B, C, D, E) {
	return (with.0, with.1, with.2, with.3, value)
}
