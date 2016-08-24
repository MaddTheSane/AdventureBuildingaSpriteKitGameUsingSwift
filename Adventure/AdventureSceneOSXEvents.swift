/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Defines OS X-specific extensions to the layered character scene.
*/

import SpriteKit

extension AdventureScene {
    // MARK: Types
    
    /// Represents different types of user input that result in actions.
    fileprivate enum KeyEventFlag {
        case moveForward
        case moveLeft
        case moveRight
        case moveBackward
        case fire

        /// The mapping from key events to their player actions.
        fileprivate static let keyMapping: [UnicodeScalar: KeyEventFlag] = [
            "w":                    .moveForward,
            UnicodeScalar(0xF700)!:  .moveForward,
            "s":                    .moveBackward,
            UnicodeScalar(0xF701)!:  .moveBackward,
            "d":                    .moveRight,
            UnicodeScalar(0xF703)!:  .moveRight,
            "a":                    .moveLeft,
            UnicodeScalar(0xF702)!:  .moveLeft,
            " ":                    .fire
        ]
        
        // MARK: Initializers
        
        init?(unicodeScalar: UnicodeScalar) {
            if let event = KeyEventFlag.keyMapping[unicodeScalar] {
                self = event
            }
            else {
                return nil
            }
        }
    }
    
    // MARK: Event Handling
    
    override func keyDown(with event: NSEvent) {
        handleKeyEvent(event, keyDown: true)
    }
    
    override func keyUp(with event: NSEvent) {
        handleKeyEvent(event, keyDown: false)
    }
    
    // MARK: Convenience
    
    fileprivate func handleKeyEvent(_ event: NSEvent, keyDown: Bool) {
        if event.modifierFlags.contains(.numericPad) {
            if let charactersIgnoringModifiers = event.charactersIgnoringModifiers {
                applyEventsFromEventString(charactersIgnoringModifiers, keyDown: keyDown)
            }
        }
        
        if let characters = event.characters {
            applyEventsFromEventString(characters, keyDown: keyDown)
        }
    }
    
    func applyEventsFromEventString(_ eventString: String, keyDown: Bool) {
        for key in eventString.unicodeScalars {
            if let flag = KeyEventFlag(unicodeScalar: key) {
                switch flag {
                    case .moveForward: defaultPlayer.moveForward = keyDown
                    case .moveBackward: defaultPlayer.moveBackward = keyDown
                    case .moveLeft: defaultPlayer.moveLeft = keyDown
                    case .moveRight: defaultPlayer.moveRight = keyDown
                    case .fire: defaultPlayer.fireAction = keyDown
                }
            }
        }
    }
}
