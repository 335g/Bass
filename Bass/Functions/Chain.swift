//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func • <A, B, C>(f: B -> C, g: A -> B) -> A -> C {
	return { f(g($0)) }
}

public func • <A, B, C>(f: B? -> C, g: A -> B) -> A -> C {
	return { f(g($0)) }
}

public func • <A, B, C>(f: B -> C, g: A? -> B) -> A -> C {
	return { f(g($0)) }
}

public func • <A, B, C>(f: B? -> C, g: A? -> B) -> A -> C {
	return { f(g($0)) }
}