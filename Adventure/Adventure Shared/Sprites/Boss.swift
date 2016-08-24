/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines the class for the boss enemy character.
*/

import SpriteKit

final class Boss: EnemyCharacter, SharedAssetProvider {
    // MARK: Initialization
    
    convenience init(atPosition position: CGPoint) {
        let atlas = SKTextureAtlas(named: "Boss_Idle")
        let bossTexture = atlas.textureNamed("boss_idle_0001")
        self.init(texture: bossTexture, atPosition: position)
        
        movementSpeed = movementSpeed * 0.35
        animationSpeed = 1.0 / 35.0
        
        zPosition = -0.25
        name = "Boss"
        
        isAttacking = false
        
        let chaseIntelligence = ChaseArtificialIntelligence(character: self)
        
        // A boss has longer arms in proportion to the torso (`collisionRadius`), so quadruple rather than double.
        chaseIntelligence.attackRadius = collisionRadius * 4.0
        
        intelligence = chaseIntelligence
    }
    
    // MARK: Setup
    
    override func configurePhysicsBody() {
        // Assign the physics body; unwrap the physics body to configure it.
        physicsBody = SKPhysicsBody(circleOfRadius: collisionRadius)
        
        // Our object type for collisions.
        physicsBody!.categoryBitMask = ColliderType.GoblinOrBoss.rawValue
        
        // Collides with these objects.
        physicsBody!.collisionBitMask = ColliderType.all.rawValue
        
        // We want notifications for colliding with these objects.
        physicsBody!.contactTestBitMask = ColliderType.Projectile.rawValue
    }
    
    // MARK: Scene Processing Support
    
    override func animationDidComplete(_ animationState: AnimationState) {
        super.animationDidComplete(animationState)
        
        if animationState == AnimationState.death {
            removeAllActions()
            let actions = [
                SKAction.wait(forDuration: 3.0),
                SKAction.fadeOut(withDuration: 2.0),
                SKAction.removeFromParent()
            ]
            
            run(SKAction.sequence(actions))
        }
    }
    
    override func collidedWith(_ otherBody: SKPhysicsBody) {
        if isDying {
            return
        }
        
        if (otherBody.categoryBitMask & ColliderType.Projectile.rawValue) == ColliderType.Projectile.rawValue {
            requestedAnimation = AnimationState.getHit
            let damage = 2.0
            let killed = applyDamage(damage, projectile: otherBody.node)
            
            if killed {
                characterScene.addToScore(1000, afterEnemyKillWithProjectile: otherBody.node!)
            }
        }
    }
    
    override func performDeath() {
        removeAllActions()
        super.performDeath()
    }
    
    // MARK: Asset Pre-loading
    
    class func loadSharedAssets() {
        idleAnimationFrames = loadFramesFromAtlasWithName("Boss_Idle")
        walkAnimationFrames = loadFramesFromAtlasWithName("Boss_Walk")
        attackAnimationFrames = loadFramesFromAtlasWithName("Boss_Attack")
        getHitAnimationFrames = loadFramesFromAtlasWithName("Boss_GetHit")
        deathAnimationFrames = loadFramesFromAtlasWithName("Boss_Death")
        damageEmitter = SKEmitterNode(fileNamed: "BossDamage")!
        
        let actions = [
            SKAction.colorize(with: SKColor.white, colorBlendFactor: 1.0, duration: 0.0),
            SKAction.wait(forDuration: 0.5),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ]
        
        damageAction = SKAction.sequence(actions)
    }
}
