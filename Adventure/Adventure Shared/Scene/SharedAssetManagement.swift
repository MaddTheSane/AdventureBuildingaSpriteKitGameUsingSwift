/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Useful structures for organizing and storing shared assets.
*/

import SpriteKit

/// Allows adopters to advertise that they have shared assets that require loading and can load them.
protocol SharedAssetProvider {
    static func loadSharedAssets()
}

enum CharacterType {
    case archer, warrior, cave, goblin, boss
}

/// This function uses pattern matching to infer the appropriate enum value based on the type provided.
func inferCharacterType(_ fromType: Character.Type) -> CharacterType {
    switch fromType {
        case is Goblin.Type:
            return .goblin
        case is Cave.Type:
            return .cave
        case is Boss.Type:
            return .boss
        case is Warrior.Type:
            return .warrior
        case is Archer.Type:
            return .archer
        default:
            fatalError("Unknown type provided for \(#function).")
    }
}

/// Holds shared animation textures for the various character types. Keys are provided for the inner dictionary.
struct SharedTextures {
    enum Keys: String {
        case idle = "textures.idle"
        case walk = "textures.walk"
        case attack = "textures.attack"
        case hit = "textures.hit"
        case death = "textures.death"
    }
    
    static var textures = [CharacterType: [Keys: [SKTexture]]]()
}

/// Holds shared sprites for the various character types. Keys are provided for the inner dictionary.
struct SharedSprites {
    enum Keys: String {
        case projectile = "sprites.projectile"
        case deathSplort = "sprites.deathSplort"
    }
    
    static var sprites = [CharacterType: [Keys: SKSpriteNode]]()
}

/// Holds shared emitters for the various character types. Keys are provided for the inner dictionary.
struct SharedEmitters {
    enum Keys: String {
        case damage = "emitters.damage"
        case death = "emitters.death"
        case projectile = "emitters.projectile"
    }
    
    static var emitters = [CharacterType: [Keys: SKEmitterNode]]()
}

/// Holds shared actions for the various character types. Keys are provided for the inner dictionary.
struct SharedActions {
    struct Keys {
        static var damage = "actions.damage"
    }
    
    static var actions = [CharacterType: [String: SKAction]]()
}
