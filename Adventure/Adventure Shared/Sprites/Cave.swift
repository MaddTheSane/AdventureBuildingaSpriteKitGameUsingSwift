/*
  Copyright (C) 2015 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  Defines the class for a goblin cave.
*/

import SpriteKit

final class Cave: EnemyCharacter, SharedAssetProvider {
    // MARK: Types
    
    struct Constants {
        static let goblinCapacity = 5
        static let sharedGoblinCapacity = 32
    }
    
    struct Shared {
        // The template will be populated when `loadSharedAssets()` is called on the class.
        static var template: Cave!
        static var goblinAllocation = 0
    }
    
    // MARK: Properties
    
    var smokeEmitter: SKEmitterNode?
    var timeUntilNextGenerate: CGFloat = 5000.0
    var activeGoblins = [Goblin]()
    var inactiveGoblins = [Goblin]()
    
    override var collisionRadius: CGFloat {
        return 90.0
    }
    
    // MARK: NSCopying
    
    override func copy(with zone: NSZone?) -> Any {
        let cave = super.copy(with: zone) as! Cave
        cave.smokeEmitter = smokeEmitter?.copy() as? SKEmitterNode
        cave.timeUntilNextGenerate = timeUntilNextGenerate
        cave.activeGoblins = [Goblin]()
        cave.inactiveGoblins = [Goblin]()
        cave.shadowBlob = shadowBlob.copy() as! SKSpriteNode
        cave.shadowBlob.name = "caveShadow"
        return cave
    }
    
    // MARK: Setup

    override func configurePhysicsBody() {
        // Assign the physics body; unwrap the physics body to configure it.
        physicsBody = SKPhysicsBody(circleOfRadius: collisionRadius)
        physicsBody!.isDynamic = false
        physicsBody!.categoryBitMask = ColliderType.cave.rawValue
        physicsBody!.collisionBitMask = ColliderType.all.rawValue
        physicsBody!.contactTestBitMask = ColliderType.projectile.rawValue
        
        animated = false
        zPosition = -0.85
    }

    // MARK: Scene Processing Support
    
    override func updateWithTimeSinceLastUpdate(_ interval: TimeInterval) {
        super.updateWithTimeSinceLastUpdate(interval) // this triggers the update in the SpawnAI

        for goblin in activeGoblins {
            goblin.updateWithTimeSinceLastUpdate(interval)
        }
    }
    
    override func collidedWith(_ other: SKPhysicsBody) {
        if health > 0.0 {
            if (other.categoryBitMask & ColliderType.projectile.rawValue) == ColliderType.projectile.rawValue {
                let damage = 10.0
                applyCaveDamage(damage, projectile: other.node!)
            }
        }
    }
    
    func applyCaveDamage(_ damage: Double, projectile: SKNode) {
        let killed = super.applyDamage(damage)
        if killed {
            // give the player some points
        }
        
        // show damage
        updateSmokeForHealth()
        
        // show damage on parallax stacks
        for node in children {
            node.run(type(of: self).damageAction)
        }
    }
    
    func updateSmokeForHealth() {
        if health > 75.0 || smokeEmitter != nil {
            return
        }
        
        let emitter: SKEmitterNode = Cave.deathEmitter.copy() as! SKEmitterNode
        emitter.position = position
        emitter.zPosition = -0.8
        smokeEmitter = emitter
        characterScene.addNode(emitter, atWorldLayer: .aboveCharacter)
    }
    
    override func performDeath() {
        super.performDeath()
        
        let splort = Cave.deathSplort.copy() as! SKSpriteNode
        splort.zPosition = -1.0
        splort.zRotation = virtualZRotation
        splort.position = position
        splort.alpha = 0.1
        splort.run(SKAction.fadeAlpha(to: 1.0, duration: 0.5))
        
        characterScene.addNode(splort, atWorldLayer: .belowCharacter)
        
        run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.0, duration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        if let smoke = smokeEmitter {
            smoke.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run {
                    smoke.particleBirthRate = 2.0
                },
                SKAction.wait(forDuration: 2.0),
                SKAction.run {
                    smoke.particleBirthRate = 0.0
                },
                SKAction.wait(forDuration: 10.0),
                SKAction.fadeAlpha(to: 0.0, duration: 0.5),
                SKAction.removeFromParent()
                ]))
        }
    }
    
    override func reset() {
        super.reset()
        
        animated = false
    }

    // MARK: Goblin Targeting
    
    func stopGoblinsFromTargettingHero(_ target: Character) {
        for goblin in activeGoblins {
            goblin.intelligence.target = nil
        }
    }

    // MARK: Spawning
    
    func generate() {
        if Constants.sharedGoblinCapacity > 0 && Shared.goblinAllocation >= Constants.sharedGoblinCapacity {
            return
        }

        if inactiveGoblins.count > 0 {
            let goblin = inactiveGoblins.removeLast()

            let offset = collisionRadius * 0.75
            let rot = adjustAssetOrientation(virtualZRotation)
            goblin.position = position + CGPoint(x: cos(rot)*offset, y: sin(rot)*offset)

            goblin.add(to: characterScene)

            goblin.zPosition = -1.0

            goblin.fadeIn(0.5)

            activeGoblins.append(goblin)

            Shared.goblinAllocation += 1
        }
    }

    func recycle(_ goblin: Goblin) {
        goblin.reset()
        if let index = activeGoblins.firstIndex(of: goblin) {
            activeGoblins.remove(at: index)
        }
        inactiveGoblins.append(goblin)
        Shared.goblinAllocation -= 1
    }
    
    // MARK: Asset Pre-loading
    
    class func loadSharedAssets() {
        let atlas = SKTextureAtlas(named: "Environment")
        
        let fire: SKEmitterNode = SKEmitterNode(fileNamed: "CaveFire")!
        fire.zPosition = 1
        let smoke: SKEmitterNode = SKEmitterNode(fileNamed: "CaveFireSmoke")!
        
        let torch = SKNode()
        torch.addChild(fire)
        torch.addChild(smoke)
        
        let caveBase = SKSpriteNode(texture: atlas.textureNamed("cave_base"))
        
        torch.position = CGPoint(x: 83, y: 83)
        caveBase.addChild(torch)
        
        let torchB = torch.copy() as! SKNode
        torch.position = CGPoint(x: -83, y: 83)
        caveBase.addChild(torchB)
        
        let caveTop = SKSpriteNode(texture: atlas.textureNamed("cave_top"))
        
        damageEmitter = SKEmitterNode(fileNamed: "CaveDamage")!
        deathEmitter = SKEmitterNode(fileNamed: "CaveDeathSmoke")!
        
        deathSplort = SKSpriteNode(texture: atlas.textureNamed("cave_destroyed"))
        
        damageAction = SKAction.sequence([
            SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: 0.0),
            SKAction.wait(forDuration: 0.25),
            SKAction.colorize(withColorBlendFactor: 0.0, duration:0.1)
        ])
        
        let sprites = [
            caveBase,
            caveTop
        ]
        Shared.template = Cave(sprites: sprites, atPosition: CGPoint.zero, usingOffset: 50.0)
        Shared.template.movementSpeed = 0.0
        Shared.template.name = "goblinCave"
    }
}
