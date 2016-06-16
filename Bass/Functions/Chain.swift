//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func • <A, B, C>(_ f: (B) -> C, _ g: (A) -> B) -> (A) -> C {
	return { f(g($0)) }
}

public func • <A, B, C>(_ f: (B?) -> C, _ g: (A) -> B) -> (A) -> C {
	return { f(g($0)) }
}

public func • <A, B, C>(_ f: (B) -> C, _ g: (A?) -> B) -> (A) -> C {
	return { f(g($0)) }
}

public func • <A, B, C>(_ f: (B?) -> C, _ g: (A?) -> B) -> (A) -> C {
	return { f(g($0)) }
}
