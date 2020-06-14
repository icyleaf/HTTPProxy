import UIKit.UIColor

protocol ColorScheme {
    
    var backgroundColor: UIColor {get}
    
    var foregroundColor: UIColor {get}
    
    var selectedColor: UIColor {get}

    var primaryTextColor: UIColor {get}

    var secondaryTextColor: UIColor {get}

    var highlightedTextColor: UIColor {get}
    
    var semanticColorPositive: UIColor {get}

    var semanticColorNegative: UIColor {get}
}

struct DarkColorScheme: ColorScheme {
    var backgroundColor: UIColor {
        UIColor.black
    }
    
    var foregroundColor: UIColor {
        UIColor(rgbColorCodeRed: 30, green: 30, blue: 30)
    }

    var selectedColor: UIColor {
        UIColor(rgbColorCodeRed: 13, green: 121, blue: 255)
    }
    
    var primaryTextColor: UIColor {
        UIColor.white
    }
    
    var secondaryTextColor: UIColor {
        UIColor(rgbColorCodeRed: 148, green: 148, blue: 148)
    }
    
    var highlightedTextColor: UIColor {
        UIColor(rgbColorCodeRed: 230, green: 134, blue: 11)
    }
    
    var semanticColorPositive: UIColor {
        UIColor(rgbColorCodeRed: 87, green: 159, blue: 43)
    }
    
    var semanticColorNegative: UIColor {
        UIColor(rgbColorCodeRed: 255, green: 0, blue: 0)
    }
}

struct LightColorScheme: ColorScheme {
    var backgroundColor: UIColor {
        .white
    }
    
    var foregroundColor: UIColor {
        UIColor(rgbColorCodeRed: 241, green: 241, blue: 241)
    }
    
    var selectedColor: UIColor {
        UIColor(rgbColorCodeRed: 13, green: 99, blue: 203)
    }
    
    var primaryTextColor: UIColor {
        UIColor(rgbColorCodeRed: 44, green: 47, blue: 51)
    }
    
    var secondaryTextColor: UIColor {
        UIColor(rgbColorCodeRed: 71, green: 75, blue: 79)
    }
    
    var highlightedTextColor: UIColor {
        UIColor(rgbColorCodeRed: 230, green: 104, blue: 15)
    }
    
    var semanticColorPositive: UIColor {
        UIColor(rgbColorCodeRed: 87, green: 159, blue: 43)
    }
    
    var semanticColorNegative: UIColor {
        UIColor(rgbColorCodeRed: 255, green: 0, blue: 0)
    }
}
