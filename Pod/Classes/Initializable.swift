//
//  Initializable.swift
//  SideMenu
//
//  Created by Jon Kent on 7/2/19.
//

import Foundation

protocol InitializableClass: AnyObject {
    init()
}

extension InitializableClass {
    init(_ block: (Self) -> Void) {
        self.init()
        block(self)
    }
    
    @discardableResult func with(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

protocol InitializableStruct {
    init()
}

extension InitializableStruct {
    
    internal init(_ block: (inout Self) -> Void) {
        self.init()
        block(&self)
    }
    
    @discardableResult
    internal mutating func with(_ block: (inout Self) -> Void) -> Self {
        block(&self)
        return self
    }
}
