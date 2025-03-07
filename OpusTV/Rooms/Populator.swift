//
//  RoomGenerator.swift
//  OpusTV
//
//  Created by Simone Boscaglia on 06/03/25.
//

import SpriteKit


// Populates the room with Interactable Sprites
class Populator {
    
    // Rimuove gli sprite normali e li sostituisce con quelli con cui si può interagire
    func populate(interactables: [InteractiveSprite], room: Stanza) {
        for interactable in interactables {
            guard let name = interactable.name else {print("Interactable in room \(room.state) has no name"); return}
            guard let node = room.node else {print("Room \(room.state) has no node"); return}
            let child = node.childNode(withName: name)
            if let child = child as? SKSpriteNode {
                interactable.assignSprite(sprite: child)
                child.removeFromParent()
                node.addChild(interactable)
            }
        }
        
    }
}
