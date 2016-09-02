//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func fix<T, U>(_ f: @escaping ((T) -> U) -> (T) -> U) -> (T) -> U {
	return { f(fix(f))($0) }
}
