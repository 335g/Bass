//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func curry<A, B, C>(f: (A, B) -> C) -> A -> B -> C {
	return { a in { b in f(a, b) } }
}

public func curry<A, B, C, D>(f: (A, B, C) -> D) -> A -> B -> C -> D {
	return { a in { b in { c in f(a, b, c) } } }
}

public func curry<A, B, C, D, E>(f: (A, B, C, D) -> E) -> A -> B -> C -> D -> E {
	return { a in { b in { c in { d in f(a, b, c, d) } } } }
}

public func uncurry<A, B, C>(f: A -> B -> C) -> (A, B) -> C {
	return { f($0)($1) }
}

public func uncurry<A, B, C, D>(f: A -> B -> C -> D) -> (A, B, C) -> D {
	return { f($0)($1)($2) }
}

public func uncurry<A, B, C, D, E>(f: A -> B -> C -> D -> E) -> (A, B, C, D) -> E {
	return { f($0)($1)($2)($3) }
}
