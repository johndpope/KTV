//
// Created by Alexander Babaev on 02.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation
import UIKit

extension KTVValue {
    var colorValue:UIColor {
        var result:UIColor = UIColor.magentaColor()

        if case .color(let value) = self {
            let (red, green, blue, alpha) = ColorUtils.colorFromHex(value)
            result = UIColor(colorLiteralRed:Float(red), green:Float(green), blue:Float(blue), alpha:Float(alpha))
        }

        return result
    }
}