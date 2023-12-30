//
//  DropViewDelegate.swift
//  HGFcollective
//
//  Created by William Dolke on 30/12/2023.
//

import Foundation
import SwiftUI

struct DropViewDelegate: DropDelegate {
    let destinationItem: Asset
    @Binding var images: [Asset]
    @Binding var draggedItem: Asset?

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        // Swap images
        if let draggedItem {
            let fromIndex = images.firstIndex(of: draggedItem)
            if let fromIndex {
                let toIndex = images.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.images.move(fromOffsets: IndexSet(integer: fromIndex),
                                         toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}
