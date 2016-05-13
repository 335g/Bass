//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func undefined<T>(message: String = "called undefined()") -> T {
	fatalError(message)
}
