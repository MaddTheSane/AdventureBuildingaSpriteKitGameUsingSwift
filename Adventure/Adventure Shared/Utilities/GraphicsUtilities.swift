/*
  Copyright (C) 2015 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  Defines basic graphics utilities used throughout Adventure
*/

import SpriteKit

func loadFramesFromAtlasWithName(_ atlasName: String) -> [SKTexture] {
    let atlas = SKTextureAtlas(named: atlasName)
    return (atlas.textureNames).sorted().map { atlas.textureNamed($0) }
}

func unitRandom() -> CGFloat {
    let quotient = CGFloat(arc4random()) / CGFloat(UInt32.max)
    return quotient
}

/// The assets are all facing Y down, so offset by half pi to get into X right facing
func adjustAssetOrientation(_ r: CGFloat) -> CGFloat {
    return r + (CGFloat.pi * 0.5)
}

extension CGPoint {
    func distanceToPoint(_ point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }

    func radiansToPoint(_ point: CGPoint) -> CGFloat {
        let deltaX = point.x - x
        let deltaY = point.y - y

        return atan2(deltaY, deltaX)
    }
}

/// Adds the coordinates of the two points together.
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func runOneShotEmitter(_ emitter: SKEmitterNode, withDuration duration: CGFloat) {
    let waitAction = SKAction.wait(forDuration: TimeInterval(duration))
    let birthRateSet = SKAction.run { emitter.particleBirthRate = 0.0 }
    let waitAction2 = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime + emitter.particleLifetimeRange))
    let removeAction = SKAction.removeFromParent()

    let sequence = [ waitAction, birthRateSet, waitAction2, removeAction]
    emitter.run(SKAction.sequence(sequence))
}
