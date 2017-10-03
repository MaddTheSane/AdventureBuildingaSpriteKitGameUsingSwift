/*
  Copyright (C) 2015 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  Defines the common class for hero characters.
*/

import SpriteKit

class HeroCharacter: Character {
    // MARK: Types
    
    struct Constants {
        static let projectileCollisionRadius: CGFloat = 15.0
        static let projectileSpeed: CGFloat = 480.0
        static let projectileLifetime: TimeInterval = 1.0
        static let projectileFadeOutDuration: TimeInterval = 0.6
    }
    
    // MARK: Properties
    
    var player: Player!
    
    var projectileSoundAction = SKAction.playSoundFileNamed("magicmissile.caf", waitForCompletion: false)

    // MARK: Initializers

    convenience init(atPosition position: CGPoint, withTexture texture: SKTexture? = nil, player: Player) {
        self.init(texture: texture, atPosition: position)
        self.player = player
        
        zRotation = CGFloat.pi
        zPosition = -0.25
        name = "Hero"
    }
    
    // MARK: Setup

    override func configurePhysicsBody() {
        // Assign the physics body; unwrap the physics body to configure it.
        physicsBody = SKPhysicsBody(circleOfRadius: collisionRadius)
        physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
        physicsBody!.collisionBitMask = ColliderType.allButProjectile.rawValue
        physicsBody!.contactTestBitMask = ColliderType.GoblinOrBoss.rawValue
    }

    // MARK: Scene Processing Support

    override func animationDidComplete(_ animation: AnimationState) {
        super.animationDidComplete(animation)

        switch animation {
            case .death:
                let actions = [
                    SKAction.wait(forDuration: 4.0),
                    SKAction.run {
                        self.characterScene.heroWasKilled(self)
                    },
                    SKAction.removeFromParent()
                ]
                run(SKAction.sequence(actions))

            case .attack:
                fireProjectile()

           default:
                () // Do nothing
        }
    }

    override func collidedWith(_ other: SKPhysicsBody) {
        if other.categoryBitMask & ColliderType.GoblinOrBoss.rawValue == 0 {
            return
        }

        if let enemy = other.node as? Character {
            if !enemy.isDying {
                applyDamage(5.0)
                requestedAnimation = .getHit
            }
        }
    }

    func fireProjectile() {
        let projectile = type(of: self).projectile.copy() as! SKSpriteNode
        projectile.position = position
        projectile.zRotation = zRotation

        let emitter = type(of: self).projectileEmitter.copy() as! SKEmitterNode
        emitter.targetNode = scene!.childNode(withName: "world")
        projectile.addChild(emitter)

        characterScene.addNode(projectile, atWorldLayer: .character)
        let rot = zRotation

        let x = -sin(rot) * Constants.projectileSpeed * CGFloat(Constants.projectileLifetime)
        let y =  cos(rot) * Constants.projectileSpeed * CGFloat(Constants.projectileLifetime)
        projectile.run(SKAction.moveBy(x: x, y: y, duration: Constants.projectileLifetime))

        let waitAction = SKAction.wait(forDuration: Constants.projectileFadeOutDuration)
        let fadeAction = SKAction.fadeOut(withDuration: Constants.projectileLifetime - Constants.projectileFadeOutDuration)
        let removeAction = SKAction.removeFromParent()
        let sequence = [waitAction, fadeAction, removeAction]

        projectile.run(SKAction.sequence(sequence))
        projectile.run(projectileSoundAction)

        projectile.userData = [Player.Keys.projectileUserDataPlayer: player]
    }
}
