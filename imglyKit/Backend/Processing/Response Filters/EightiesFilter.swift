//
//  EightiesFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYEightiesFilter) public class EightiesFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Eighties")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension EightiesFilter: EffectFilter {
    public var displayName: String {
        return "80s"
    }

    public var filterType: FilterType {
        return .Eighties
    }
}