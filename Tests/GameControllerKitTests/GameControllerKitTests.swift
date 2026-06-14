//
//  GameControllerKitTests.swift
//  GameControllerKit
//
//  Created by Wesley de Groot on 2024-08-19.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/GameControllerKit
//  MIT License
//
import XCTest
@testable import GameControllerKit

@MainActor
final class GameControllerKitTests: XCTestCase {
    func testMockControllerState() {
        let gameControllerKit = GameControllerKit(observesControllers: false)

        XCTAssertFalse(gameControllerKit.isConnected)

        gameControllerKit.mockController(type: .xbox)
        gameControllerKit.sendMockAction(.buttonA)

        XCTAssertTrue(gameControllerKit.isConnected)
        XCTAssertEqual(gameControllerKit.controllerType, .xbox)
        XCTAssertEqual(gameControllerKit.lastAction, .buttonA)

        gameControllerKit.sendMockAction(.buttonA, pressed: false)

        XCTAssertEqual(gameControllerKit.lastAction, .none)
    }

    func testThumbstickDirectionUsesDeadZoneAndSectors() {
        XCTAssertEqual(GCKMovePosition(xPosition: 0.1, yPosition: 0.1), .centered)
        XCTAssertEqual(GCKMovePosition(xPosition: 0.8, yPosition: 0.8), .upRight)
        XCTAssertEqual(GCKMovePosition(xPosition: -1, yPosition: 0), .left)
        XCTAssertEqual(GCKMovePosition(xPosition: 0, yPosition: -1), .down)
    }

    func testMockThumbstickUpdatesDiscreteState() {
        let gameControllerKit = GameControllerKit(observesControllers: false)
        gameControllerKit.mockController(type: .dualSense)

        gameControllerKit.sendMockAction(.leftThumbstick(x: 0.8, y: 0.8))

        XCTAssertEqual(gameControllerKit.leftThumbstick, .upRight)
        XCTAssertEqual(gameControllerKit.lastAction.position, .upRight)
    }
}
