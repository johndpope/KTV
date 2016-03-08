//
// Created by Alexander Babaev on 02.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public struct ColorUtils {
    public static func colorFromHex(hexString:String) -> (red:Double, green:Double, blue:Double, alpha:Double) {
        let hex:String = hexString.hasPrefix("#") ?
                         hexString.substringFromIndex(hexString.startIndex.successor()) :
                         hexString

        var red:Double = 0
        var green:Double = 0
        var blue:Double = 0
        var alpha:Double = 255

        let length = hex.characters.count

        func hexIndex(index:Int, _ numberWidth:Int) -> Double {
            let range = Range(hex.startIndex.advancedBy(numberWidth*index)..<hex.startIndex.advancedBy(numberWidth*(index + 1)))
            return Double(Int(hex.substringWithRange(range), radix:16) ?? 0)
        }

        if (length == 8) {
            // RGBA
            red = hexIndex(0, 2)
            green = hexIndex(1, 2)
            blue = hexIndex(2, 2)
            alpha = hexIndex(3, 2)
        } else if (length == 6) {
            // RGB
            red = hexIndex(0, 2)
            green = hexIndex(1, 2)
            blue = hexIndex(2, 2)
        } else if (length == 3) {
            // RGB
            red = hexIndex(0, 1)
            green = hexIndex(1, 1)
            blue = hexIndex(2, 1)

            red = red + red*16
            green = green + green*16
            blue = blue + blue*16
        }

        return (red/255.0, green/255.0, blue/255.0, alpha/255.0)
    }

    public static func colorToHex(r:Double, _ g:Double, _ b:Double, _ a:Double) -> String {
        if a > 0.99 {
            return String(format:"#%2X%2X%2X", Int(r*255), Int(g*255), Int(b*255))
        } else {
            return String(format:"#%2X%2X%2X%2X", Int(r*255), Int(g*255), Int(b*255), Int(a*255))
        }
    }
}