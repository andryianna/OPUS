//
//  SceneManager.swift
//  OpusTV
//
//  Created by Simone Boscaglia on 08/03/25.
//

import SpriteKit
import SwiftUI

// Metto qui tutti gli oggetti a cui devono avere accesso altre classi
class SceneManager {
    @ObservedObject var mpcManager: MPCManager = MPCManager.shared

    var scene : SKScene?
    var light : Light?
    let inventory = Inventory(position: .zero)
    var populator : Populator? = nil
    
    var sceneState : SceneState = .sala
    var minigameState : MinigameState = .hidden
    
    var stanze : [SceneState : Stanza] = [.sala: sala,.cucina : cucina,.laboratorio : laboratorio,.libreria: libreria, .title: titolo]
    let sceneNames : [MinigameState : String] = [
        .hidden : "GameScene",
        .labirinto : "Labirinto",
        .pozione : "Pozione"
    ]
    var savedScenes : [MinigameState : SKScene?] = [
        .hidden : nil,
        .labirinto : nil,
        .pozione : nil
    ]
    
    var xGyro : CGFloat = 0.0
    var yGyro : CGFloat = 0.0
    var zGyro : CGFloat = 0.0
    
    var heartRate : Double = -1
    
    var hasInitializedMainScene : Bool = false
    var hasCollectedWater : Bool = false
    var hasPaintingMoved : Bool = false
    var hasMoved: Bool = false
    var poisonCollected = false
    
    var textManager : TextManager = TextManager(textNode: SKLabelNode())
    
    init() {
        mpcManager.delegate = self
        mpcManager.startService()
    }
    
    func assignScene(scene : SKScene) {
        self.scene = scene
        let lightNode = scene.childNode(withName: "torch") as! SKLightNode
        let cursor = scene.childNode(withName: "cursor") as! SKSpriteNode
        self.light = Light(lightNode: lightNode, cursor: cursor)
        self.populator = Populator(scene: self.scene!)
    }
    
    func initializePopulator() {
        guard self.scene != nil else {print("Trying to initialize populator but scene not assigned"); return}
        self.populator = Populator(scene: self.scene!)
    }
    
    func populate() {
        guard let populator = self.populator else {print("Trying to populate but populator not assigned"); return}
        for (_, stanza) in stanze {
            populator.populate(room: stanza)
            stanza.node?.position = CGPoint.zero
            stanza.hide()
        }
    }
    
    func depopulate() {
        guard let populator = self.populator else {print("Trying to depopulate but populator not assigned"); return}
        for (_, stanza) in stanze {
            populator.depopulate(room: stanza)
        }
    }
    
    func removeAntonio(){
        DispatchQueue.main.async {
            let antonio = self.scene?.childNode(withName: "sala")!.childNode(withName: "antonio")
            antonio!.removeFromParent()
        }
    }
    
    func firstBoot(){
        if sceneState == .sala && !hasCollectedWater{
            self.textManager.changeText("Hey I'm kinda thirsty")
            self.textManager.showForDuration(5)
            self.textManager.changeText("Could you grab me some water please?")
            self.textManager.showForDuration(5)
            self.textManager.textNode.zPosition = 7
        }
    }
    
    func getCurrentScene() -> SceneState{
        return sceneState
    }
    
    func selectRoom(_ newScene : SceneState) {
        guard (minigameState == .hidden) else { print("Trying to select room in minigame"); return }
        stanze[sceneState]?.hide()
        stanze[newScene]?.setup()
        stanze[newScene]?.show()
        sceneState = newScene
    }
    
    func phoneTouch() {
        self.light?.touch()
    }
    
    func recalibrate() {
        self.light?.move(to:CGPoint.zero)
    }
    
    func switchToMinigame(state : MinigameState) {
        if state == .hidden { // Se sei nel gioco principale
            depopulate()
        }
        if self.savedScenes[self.minigameState] == nil {
            print("saving scene")
            self.savedScenes[self.minigameState] = self.scene
        }
        
        self.minigameState = state

        // faccio prima l'unwrap dal dictionary e poi l'unwrap dell'optional del tipo
        if let value = savedScenes[self.minigameState], let savedScene = value {
            print("accessing saved scene")
            self.scene?.view?.presentScene(savedScene, transition: .crossFade(withDuration: 0.5))
        } else {
            guard let sceneName = sceneNames[state] else {print("Could not find new scene name"); return}
            let newScene = SKScene(fileNamed: sceneName)
            newScene!.size = CGSize(width: 1920, height: 1080)
            newScene?.scaleMode = .aspectFit
            self.scene?.view?.presentScene(newScene!, transition: .crossFade(withDuration: 0.5))
        }

        return;
    }
}

let sceneManager = SceneManager()
