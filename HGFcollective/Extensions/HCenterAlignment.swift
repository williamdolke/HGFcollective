//
//  HCenterAlignment.swift
//  HGFcollective
//
//  Created by William Dolke on 15/01/2023.
//

import Foundation
import SwiftUI

extension HorizontalAlignment {
   private enum HCenterAlignment: AlignmentID {
      static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
         return dimensions[HorizontalAlignment.center]
      }
   }
   static let hCentered = HorizontalAlignment(HCenterAlignment.self)
}
