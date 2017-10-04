/*
  Copyright (C) 2015 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  Defines the class for a character in Adventure.
*/

import SpriteKit

enum AnimationState: UInt32 {
    case idle = 0, walk, attack, getHit, death
}

enum MoveDirection {
    case forward, left, right, back
}

struct ColliderType : OptionSet {
	let rawValue: UInt32
	private init(_ value: UInt32) { self.init(rawValue: value) }
	init(rawValue value: UInt32) { self.rawValue = value }
	
    static var hero: ColliderType {
        return ColliderType(1 << 0)
    }
    static var goblinOrBoss: ColliderType {
        return ColliderType(1 << 1)
    }
    static var projectile: ColliderType {
        return ColliderType(1 << 2)
    }
    static var wall: ColliderType {
        return ColliderType(1 << 3)
    }
    static var cave: ColliderType {
        return ColliderType(1 << 4)
    }
	
    static var all: ColliderType {
        return [ColliderType.hero, ColliderType.goblinOrBoss, ColliderType.projectile, ColliderType.wall, ColliderType.cave]
    }
    static var allButProjectile: ColliderType {
        return [ColliderType.hero, ColliderType.goblinOrBoss, ColliderType.wall, ColliderType.cave]
    }
}

class Character: ParallaxSprite {
    // MARK: Properties
    
    var isDying = false
    var isAttacking = false
    var health = 100.0
    var animated = true
    var animationSpeed: CGFloat = 1.0/28.0
    var movementSpeed: CGFloat = 200.0
    var rotationSpeed: CGFloat = 0.06
    var requestedAnimation = AnimationState.idle
    var shadowBlob = SKSpriteNode()
    
    var collisionRadius: CGFloat {
        return 40.0
    }
    
    var characterScene: AdventureScene {
        return self.scene as! AdventureScene
    }
    
    class var characterType: CharacterType {
        return inferCharacterType(self)
    }

    class var idleAnimationFrames: [SKTexture] {
        get {
            return SharedTextures.textures[characterType]?[SharedTextures.Keys.idle] ?? []
        }
        set {
            var texturesForCharacterType = SharedTextures.textures[characterType] ?? [String: [SKTexture]]()
            texturesForCharacterType[SharedTextures.Keys.idle] = newValue
            SharedTextures.textures[characterType] = texturesForCharacterType
        }
    }

    class var walkAnimationFrames: [SKTexture] {
        get {
            return SharedTextures.textures[characterType]?[SharedTextures.Keys.walk] ?? []
        }
        set {
            var texturesForCharacterType = SharedTextures.textures[characterType] ?? [String: [SKTexture]]()
            texturesForCharacterType[SharedTextures.Keys.walk] = newValue
            SharedTextures.textures[characterType] = texturesForCharacterType
        }
    }

    class var attackAnimationFrames: [SKTexture] {
        get {
            return SharedTextures.textures[characterType]?[SharedTextures.Keys.attack] ?? []
        }
        set {
            var texturesForCharacterType = SharedTextures.textures[characterType] ?? [String: [SKTexture]]()
            texturesForCharacterType[SharedTextures.Keys.attack] = newValue
            SharedTextures.textures[characterType] = texturesForCharacterType
        }
    }

    class var getHitAnimationFrames: [SKTexture] {
        get {
            return SharedTextures.textures[characterType]?[SharedTextures.Keys.hit] ?? []
        }
        set {
            var texturesForCharacterType = SharedTextures.textures[characterType] ?? [String: [SKTexture]]()
            texturesForCharacterType[SharedTextures.Keys.hit] = newValue
            SharedTextures.textures[characterType] = texturesForCharacterType
        }
    }

    class var deathAnimationFrames: [SKTexture] {
        get {
            return SharedTextures.textures[characterType]?[SharedTextures.Keys.death] ?? []
        }
        set {
            var texturesForCharacterType = SharedTextures.textures[characterType] ?? [String: [SKTexture]]()
            texturesForCharacterType[SharedTextures.Keys.death] = newValue
            SharedTextures.textures[characterType] = texturesForCharacterType
        }
    }
    
    class var projectile: SKSpriteNode {
        get {
            return SharedSprites.sprites[characterType]?[SharedSprites.Keys.projectile] ?? SKSpriteNode()
        }
        set {
            var spritesForCharacterType = SharedSprites.sprites[characterType] ?? [String: SKSpriteNode]()
            spritesForCharacterType[SharedSprites.Keys.projectile] = newValue
            SharedSprites.sprites[characterType] = spritesForCharacterType
        }
    }

    class var damageEmitter: SKEmitterNode {
        get {
            return SharedEmitters.emitters[characterType]?[SharedEmitters.Keys.damage] ?? SKEmitterNode()
        }
        set {
            var emittersForCharacterType = SharedEmitters.emitters[characterType] ?? [String: SKEmitterNode]()
            emittersForCharacterType[SharedEmitters.Keys.damage] = newValue
            SharedEmitters.emitters[characterType] = emittersForCharacterType
        }
    }
    
    class var deathEmitter: SKEmitterNode {
        get {
            return SharedEmitters.emitters[characterType]?[SharedEmitters.Keys.death] ?? SKEmitterNode()
        }
        set {
            var emittersForCharacterType = SharedEmitters.emitters[characterType] ?? [String: SKEmitterNode]()
            emittersForCharacterType[SharedEmitters.Keys.death] = newValue
            SharedEmitters.emitters[characterType] = emittersForCharacterType
        }
    }
    
    class var projectileEmitter: SKEmitterNode {
        get {
            return SharedEmitters.emitters[characterType]?[SharedEmitters.Keys.projectile] ?? SKEmitterNode()
        }
        set {
            var emittersForCharacterType = SharedEmitters.emitters[characterType] ?? [String: SKEmitterNode]()
            emittersForCharacterType[SharedEmitters.Keys.projectile] = newValue
            SharedEmitters.emitters[characterType] = emittersForCharacterType
        }
    }

    class var damageAction: SKAction {
        get {
            return SharedActions.actions[characterType]?[SharedActions.Keys.damage] ?? SKAction()
        }
        set {
            var actionsForCharacterType = SharedActions.actions[characterType] ?? [String: SKAction]()
            actionsForCharacterType[SharedActions.Keys.damage] = newValue
            SharedActions.actions[characterType] = actionsForCharacterType
        }
    }

    // MARK: Initializers

    convenience init(sprites: [SKSpriteNode], atPosition position: CGPoint, usingOffset offset: CGFloat) {
        self.init(sprites: sprites, usingOffset: offset)

        sharedInitAtPosition(position)
    }

    convenience init(texture: SKTexture?, atPosition position: CGPoint) {
        let size = texture != nil ? texture!.size() : CGSize(width: 0, height: 0)
        self.init(texture: texture, color: SKColor.white, size: size)

        sharedInitAtPosition(position)
    }

    func sharedInitAtPosition(_ position: CGPoint) {
        let atlas = SKTextureAtlas(named: "Environment")

        shadowBlob = SKSpriteNode(texture: atlas.textureNamed("blobShadow"))
        shadowBlob.zPosition = -1.0

        self.position = position

        configurePhysicsBody()
    }
    
    // MARK: NSCopying
    
    override func copy(with zone: NSZone?) -> Any {
        let character = super.copy(with: zone) as! Character
        character.isDying = isDying
        character.isAttacking = isAttacking
        character.health = health
        character.animated = animated
        character.animationSpeed = animationSpeed
        character.movementSpeed = movementSpeed
        character.rotationSpeed = rotationSpeed
        character.requestedAnimation = requestedAnimation
        character.shadowBlob = shadowBlob.copy() as! SKSpriteNode
        return character
    }
    
    // MARK: Setup
    
    func configurePhysicsBody() {}
    
    override func setScale(_ scale: CGFloat) {
        super.setScale(scale)
        shadowBlob.setScale(scale)
    }
    
    // MARK: Scene Processing Support

    func updateWithTimeSinceLastUpdate(_ interval: TimeInterval) {
        shadowBlob.position = position
        
        if !animated {
            return
        }
        resolveRequestedAnimation()
    }

    func animationDidComplete(_ animation: AnimationState) {}
    
    func collidedWith(_ other: SKPhysicsBody) {}
    
    @discardableResult
    func applyDamage( _ damage1: Double, projectile: SKNode? = nil) -> Bool {
        var damage = damage1
        if let proj = projectile {
            damage *= Double(proj.alpha)
        }
        
        health -= damage
        
        if health > 0.0 {
            let emitter = type(of: self).damageEmitter.copy() as! SKEmitterNode
            characterScene.addNode(emitter, atWorldLayer: .aboveCharacter)
            
            emitter.position = position
            runOneShotEmitter(emitter, withDuration: 0.15)
            
            run(type(of: self).damageAction)
            return false
        }
        
        performDeath()
        return true
    }

    func performAttackAction() {
        if isAttacking {
            return
        }
        
        isAttacking = true
        requestedAnimation = .attack
    }
    
    func performDeath() {
        health = 0.0
        isDying = true
        requestedAnimation = .death
    }
    
    func reset() {
        health = 100.0
        isDying = false
        isAttacking = false
        animated = true
        requestedAnimation = .idle
        shadowBlob.alpha = 1.0
    }

    // MARK: Character Animation
    
    func resolveRequestedAnimation() {
        let (frames, key) = animationFramesAndKeyForState(requestedAnimation)

        fireAnimationForState(requestedAnimation, usingTextures: frames, withKey: key)

        requestedAnimation = isDying ? .death : .idle
    }

    func animationFramesAndKeyForState(_ state: AnimationState) -> ([SKTexture], String) {
        switch state {
            case .walk:
               return (type(of: self).walkAnimationFrames, "anim_walk")

            case .attack:
                return (type(of: self).attackAnimationFrames, "anim_attack")

            case .getHit:
                return (type(of: self).getHitAnimationFrames, "anim_gethit")

            case .death:
                return (type(of: self).deathAnimationFrames, "anim_death")

            case .idle:
                return (type(of: self).idleAnimationFrames, "anim_idle")
        }
    }

    func fireAnimationForState(_ animationState: AnimationState, usingTextures frames: [SKTexture], withKey key: String) {
        let animAction = action(forKey: key)

        if animAction != nil || frames.count < 1 {
            return
        }

        let animationAction = SKAction.animate(with: frames, timePerFrame: TimeInterval(animationSpeed), resize: true, restore: false)
        let blockAction = SKAction.run {
            self.animationHasCompleted(animationState)
        }

        run(SKAction.sequence([animationAction, blockAction]), withKey: key)
    }

    func animationHasCompleted(_ animationState: AnimationState) {
        if isDying {
            animated = false
            shadowBlob.run(SKAction.fadeOut(withDuration: 1.5))
        }

        animationDidComplete(animationState)

        if isAttacking {
            isAttacking = false
        }
    }

    func fadeIn(_ duration: TimeInterval) {
        let fadeAction = SKAction.fadeIn(withDuration: duration)

        alpha = 0.0
        run(fadeAction)

        shadowBlob.alpha = 0.0
        shadowBlob.run(fadeAction)
    }
    
    // MARK: Movement Handling
    
    func moveIn(direction: MoveDirection, timeInterval: TimeInterval) {
        var action: SKAction!
        
        switch direction {
        case .forward:
            let x = -sin(zRotation) * movementSpeed * CGFloat(timeInterval)
            let y =  cos(zRotation) * movementSpeed * CGFloat(timeInterval)
            action = SKAction.moveBy(x: x, y: y, duration: timeInterval)
            
        case .back:
            let x =  sin(zRotation) * movementSpeed * CGFloat(timeInterval)
            let y = -cos(zRotation) * movementSpeed * CGFloat(timeInterval)
            action = SKAction.moveBy(x: x, y: y, duration: timeInterval)
            
        case .left:
            action = SKAction.rotate(byAngle: rotationSpeed, duration:timeInterval)
            
        case .right:
            action = SKAction.rotate(byAngle: -rotationSpeed, duration:timeInterval)
        }
        
        if action != nil {
            requestedAnimation = .walk
            run(action)
        }
    }
    
    @discardableResult
    func face(position: CGPoint) -> CGFloat {
        let angle = adjustAssetOrientation(position.radiansToPoint(self.position))
        
        let action = SKAction.rotate(toAngle: angle, duration: 0)
        
        run(action)

        return angle
    }
    
    func move(towards targetPosition: CGPoint, timeInterval: TimeInterval) {
        // Grab an immutable position in case Sprite Kit changes it underneath us.
        let currentPosition = position
        let deltaX = targetPosition.x - currentPosition.x
        let deltaY = targetPosition.y - currentPosition.y
        let maximumDistance = movementSpeed * CGFloat(timeInterval)
        
        moveFrom(currentPosition: currentPosition, byDeltaX: deltaX, deltaY: deltaY, maximumDistance: maximumDistance)
    }
    
    func moveInDirection(_ direction: CGVector, withTimeInterval timeInterval: TimeInterval, facing: CGPoint? = nil) {
        // Grab an immutable position in case Sprite Kit changes it underneath us.
        let currentPosition = position
        let deltaX = movementSpeed * direction.dx
        let deltaY = movementSpeed * direction.dy
        let maximumDistance = movementSpeed * CGFloat(timeInterval)
        
        moveFrom(currentPosition: currentPosition, byDeltaX: deltaX, deltaY: deltaY, maximumDistance: maximumDistance, facing: facing)
    }
    
    func moveFrom(currentPosition: CGPoint, byDeltaX dx: CGFloat, deltaY dy: CGFloat, maximumDistance: CGFloat, facing: CGPoint? = nil) {
        let targetPosition = CGPoint(x: currentPosition.x + dx, y: currentPosition.y + dy)
        
        let angle = adjustAssetOrientation(targetPosition.radiansToPoint(currentPosition))
        
        if facing != nil {
            let facePosition = currentPosition + facing!
            face(position: facePosition)
        }
        else {
            face(position: targetPosition)
        }
        
        let distRemaining = hypot(dx, dy)
        if distRemaining < maximumDistance {
            position = targetPosition
        } else {
            let x = currentPosition.x - (maximumDistance * sin(angle))
            let y = currentPosition.y + (maximumDistance * cos(angle))
            position = CGPoint(x: x, y: y)
        }
        
        if !isAttacking {
            requestedAnimation = .walk
        }
    }

    // MARK: Scene Interactions
    
    func add(to scene: AdventureScene) {
        scene.addNode(self, atWorldLayer: .character)
        scene.addNode(shadowBlob, atWorldLayer: .belowCharacter)
    }

    override func removeFromParent() {
        shadowBlob.removeFromParent()
        super.removeFromParent()
    }
}
