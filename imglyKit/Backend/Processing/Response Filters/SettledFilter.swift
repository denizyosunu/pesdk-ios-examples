//
//  SettledFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYSettledFilter) public class SettledFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Settled")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SettledFilter: EffectFilter {
    public var displayName: String {
        return "Settled"
    }

    public var filterType: FilterType {
        return .Settled
    }
}