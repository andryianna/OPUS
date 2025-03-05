//
//  GameScene.swift
//  templateSpriteKit
//
//  Created by Ignazio Finizio on 07/04/22.
//

import SpriteKit

enum minigameState {
    case hidden
    case cauldron
    case insect
}

enum sceneState {
    case room
    case kitchen
    case library
    case laboratory
    case minigame
    case test
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let mpcManager: MPCManager = MPCManager.shared
//    let device : PhoneConnection = PhoneConnection.shared
    var objectSelected : Bool = false
    
    
    var width : CGFloat = 1920
    var height : CGFloat = 1080
    
    var light : Light?
    let sensibility : CGFloat = 2000//30
    
    var xGyro : CGFloat = 0.0
    var yGyro : CGFloat = 0.0
    var zGyro : CGFloat = 0.0
    
    var xAcc : CGFloat = 0.0
    var yAcc : CGFloat = 0.0
    var zAcc : CGFloat = 0.0

    var gameState : sceneState = .room
    var minigame : minigameState = .hidden
    
    // START OF THE GAME
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        let lightNode = childNode(withName: "torch") as! SKLightNode
        let cursor = childNode(withName: "cursor") as! SKSpriteNode
        light = Light(lightNode: lightNode, cursor: cursor, scene: self)
        
        mpcManager.delegate = self
        mpcManager.startService()
        

        
//        let chest = InteractiveSprite(texture: SKTexture(imageNamed: "paper"), color: .clear, size: CGSize(width: 100, height: 100)) { sprite in
////            sprite.run(SKAction.sequence([
////                SKAction.scale(by: 1.2, duration: 0.2),
////                SKAction.scale(to: 1.0, duration: 0.2)
////            ]))
//            print("Chest opened at position: \(sprite.position)")
//        }
//        chest.position = CGPoint(x: 0, y: 0)
//        addChild(chest)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {}
    
    func didEnd(_ contact: SKPhysicsContact) {}
    
    
    override func update(_ currentTime: TimeInterval) {
        light?.smoothUpdate()
        
        if !(gameState == .minigame) {
            light?.highlightObjects()
        }
    }
    
    func switchScene() {
        let sala = childNode(withName: "sala")
        let room = childNode(withName: "test")
        
        if gameState == .room {
            sala?.position = CGPoint(x:0, y:0)
            room?.position = CGPoint(x:3000, y:3000)
        } else if gameState == .test {
            sala?.position = CGPoint(x:3000, y:3000)
            room?.position = CGPoint(x:0, y:0)
        }
        
        if gameState == .test { gameState = .room } else { gameState = .test }
        
    }
    
    func phoneTouch() {
        let cursor = childNode(withName: "cursor") as! SKSpriteNode
        guard let cursorBody = cursor.physicsBody else { return }
        
        let contacts = cursorBody.allContactedBodies()
        for sprite in contacts {
            if let interactive = sprite.node as? InteractiveSprite {
                interactive.action?(interactive)
            }
        }
    }
    
    func recalibrate() {
        light?.setPosition(to:CGPoint.zero)
    }
    
    
}

