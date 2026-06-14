//
//  GameControllerKit.swift
//  GameControllerKit
//
//  Created by Wesley de Groot on 2024-08-19.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/GameControllerKit
//  MIT License
//

import CoreHaptics
import Foundation
import GameController
import OSLog

/// Game Controller Kit
///
/// GameControllerKit is a Swift package that makes it easy to work with
/// game controllers on iOS, macOS, and tvOS. It provides a simple API to
/// connect to game controllers, read input from them, and control their
/// lights and haptics.
@MainActor
public final class GameControllerKit: ObservableObject {
    /// Event Handler
    public typealias GCKEventHandler = (_ action: GCKAction, _ pressed: Bool, _ controller: GCKController) -> Void

    /// The type of game controller that is currently connected, if any.
    /// This property is nil if no controller is connected.
    @Published
    public private(set) var controllerType: GCKControllerType?

    /// The game controller that is currently connected, if any. (this is always the first controller)
    @Published
    public private(set) var controller: GCKController?

    /// The game controllers that are currently connected, if any.
    @Published
    public private(set) var controllers: [GCKController] = []

    /// The current state of the left thumbstick.
    @Published
    public private(set) var leftThumbstick: GCKMovePosition = .centered

    /// The current state of the right thumbstick.
    @Published
    public private(set) var rightThumbstick: GCKMovePosition = .centered

    /// The last action done by the controller
    @Published
    public private(set) var lastAction: GCKAction = .none

    /// Action handler for the actions performed by the user on the controller
    private var eventHandler: GCKEventHandler?

    /// Game Controller Kit logger.
    private let logger: Logger

    /// Notification observer tokens owned by this instance.
    private var notificationTokens: [NSObjectProtocol] = []

    /// Whether the current published connection is supplied by mock state.
    private var isUsingMockController = false

    private static let defaultLogger = Logger(
        subsystem: "nl.wesleydegroot.GameControllerKit",
        category: "GameControllerKit"
    )

    /// Indicates whether a game controller is currently connected.
    public var isConnected: Bool {
        controllerType != nil
    }

    /// Initializes a new GameControllerKit instance.
    /// It sets up notification observers for when game controllers connect or disconnect.
    ///
    /// - Parameters:
    ///   - logger: Custom ``Logger`` instance.
    ///   - observesControllers: Whether to observe physical controller connections.
    public init(logger: Logger? = nil, observesControllers: Bool = true) {
        self.logger = logger ?? Self.defaultLogger

        guard observesControllers else {
            return
        }

        notificationTokens.append(NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.synchronizeControllers()
                }
            }
        ))

        notificationTokens.append(NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.synchronizeControllers()
                }
            }
        ))

        synchronizeControllers()
    }

    deinit {
        for token in notificationTokens {
            NotificationCenter.default.removeObserver(token)
        }
    }

    /// Set color of the controllers light
    ///
    /// Use the light settings to signal the user or to create a more immersive experience.
    /// If the controller doesn’t provide light settings, this property is nil.
    ///
    /// - Parameter color: Color
    public func set(color: GCColor) {
        controller?.light?.color = color
    }

    /// Set the event handler
    ///
    /// This function allows you to setup a custom event handler, 
    /// which you need to receive inputs from the controller.
    ///
    /// - Parameter handler: event handler
    public func set(handler: @escaping GCKEventHandler) {
        self.eventHandler = handler
    }

    /// Removes the custom event handler and restores default event logging.
    public func resetHandler() {
        eventHandler = nil
    }

    /// Presents a mock controller through the same published state used by the controller view.
    ///
    /// Physical controller notifications are ignored until ``stopMockingController()`` is called.
    ///
    /// - Parameter type: Controller type to present.
    public func mockController(type: GCKControllerType = .generic) {
        isUsingMockController = true
        controller = nil
        controllers = []
        controllerType = type
        resetInputState()
    }

    /// Publishes an input action for the currently mocked controller.
    ///
    /// - Parameters:
    ///   - action: Action to publish.
    ///   - pressed: Whether a button action is pressed.
    public func sendMockAction(_ action: GCKAction, pressed: Bool = true) {
        guard isUsingMockController else {
            return
        }

        updatePublishedInput(action: action, pressed: pressed)
    }

    /// Stops presenting mock state and returns to connected physical controllers.
    public func stopMockingController() {
        isUsingMockController = false
        synchronizeControllers()
    }

    /// Plays random colors on your controller (if supported)
    /// This is currently only supported on a DualSense and DualShock controller (Playstation)
    public func randomColors() {
        for counter in 0...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(counter)) { [weak self] in
                self?.set(color: .gckRandom)
            }
        }
    }

    /// Play haptics
    ///
    /// This plays haptics (vibrations) on the gamecontroller.
    ///
    /// - Parameter url: Haptics file
    public func playHaptics(url: URL) {
        guard let haptics = self.controller?.haptics?.createEngine(withLocality: .default) else {
            logger.fault("Couldn't initialize haptics")
            return
        }

        do {
            // Start the engine in case it's idle.
            try haptics.start()

            // Tell the engine to play a pattern.
            try haptics.playPattern(from: url)
        } catch {
            // Process engine startup errors.
            logger.fault("An error occured playing haptics: \(error).")
        }
    }

    // MARK: - Controller synchronization

    private func synchronizeControllers() {
        guard !isUsingMockController else {
            return
        }

        let connectedControllers = GCController.controllers()
        controllers = connectedControllers

        for (index, currentController) in connectedControllers.enumerated() {
            currentController.playerIndex = GCControllerPlayerIndex(rawValue: index) ?? .indexUnset
            setupController(controller: currentController)
        }

        guard let primaryController = connectedControllers.first else {
            controller = nil
            controllerType = nil
            resetInputState()
            return
        }

        controller = primaryController
        controllerType = primaryController.gckControllerType
        logger.info(
            "Using controller \(primaryController.productCategory) as the primary controller."
        )
    }
}

// MARK: - Controller input mapping

private extension GameControllerKit {
    /// Set up controller
    ///
    /// This function sets up the controller, 
    /// it looks which type it is and then map the elements to the corresponding responders.
    ///
    /// - Parameter controller: Controller
    func setupController(controller: GCController) {
        var buttons: [(GCControllerButtonInput?, GCKAction)] = []

        guard let gamepad = controller.extendedGamepad else {
            return
        }

        buttons.append(contentsOf: standardButtons(for: gamepad))
        buttons.append(contentsOf: specializedButtons(for: controller))

        for (button, action) in buttons {
            button?.valueChangedHandler = { [weak self, weak controller] (_, _, pressed) in
                guard let self, let controller else {
                    return
                }

                self.updatePublishedInput(action: action, pressed: pressed)
                self.emit(action: action, pressed: pressed, controller: controller)
            }
        }

        gamepad.leftThumbstick.valueChangedHandler = { [weak self, weak controller] (_, xPosition, yPosition) in
            self?.handleThumbstick(
                action: .leftThumbstick(x: xPosition, y: yPosition),
                controller: controller
            )
        }

        gamepad.rightThumbstick.valueChangedHandler = { [weak self, weak controller] (_, xPosition, yPosition) in
            self?.handleThumbstick(
                action: .rightThumbstick(x: xPosition, y: yPosition),
                controller: controller
            )
        }
    }

    private func standardButtons(for gamepad: GCExtendedGamepad) -> [(GCControllerButtonInput?, GCKAction)] {
        [
            (gamepad.buttonA, .buttonA),
            (gamepad.buttonB, .buttonB),
            (gamepad.buttonX, .buttonX),
            (gamepad.buttonY, .buttonY),
            (gamepad.leftShoulder, .leftShoulder),
            (gamepad.rightShoulder, .rightShoulder),
            (gamepad.leftTrigger, .leftTrigger),
            (gamepad.rightTrigger, .rightTrigger),
            (gamepad.buttonMenu, .buttonMenu),
            (gamepad.buttonOptions, .buttonOptions),
            (gamepad.buttonHome, .buttonHome),
            (gamepad.leftThumbstickButton, .leftThumbstickButton),
            (gamepad.rightThumbstickButton, .rightThumbstickButton),
            (gamepad.dpad.up, .dpadUp),
            (gamepad.dpad.down, .dpadDown),
            (gamepad.dpad.left, .dpadLeft),
            (gamepad.dpad.right, .dpadRight)
        ]
    }

    private func specializedButtons(for controller: GCController) -> [(GCControllerButtonInput?, GCKAction)] {
        if let gamepad = controller.physicalInputProfile as? GCDualSenseGamepad {
            return touchpadButtons(for: gamepad)
        }

        if let gamepad = controller.physicalInputProfile as? GCDualShockGamepad {
            return touchpadButtons(for: gamepad)
        }

        if let gamepad = controller.physicalInputProfile as? GCXboxGamepad {
            return [
                (gamepad.buttonShare, .shareButton),
                (gamepad.paddleButton1, .paddleButton1),
                (gamepad.paddleButton2, .paddleButton2),
                (gamepad.paddleButton3, .paddleButton3),
                (gamepad.paddleButton4, .paddleButton4)
            ]
        }

        return []
    }

    private func touchpadButtons(for gamepad: GCDualSenseGamepad) -> [(GCControllerButtonInput?, GCKAction)] {
        touchpadButtons(
            button: gamepad.touchpadButton,
            primary: gamepad.touchpadPrimary,
            secondary: gamepad.touchpadSecondary
        )
    }

    private func touchpadButtons(for gamepad: GCDualShockGamepad) -> [(GCControllerButtonInput?, GCKAction)] {
        touchpadButtons(
            button: gamepad.touchpadButton,
            primary: gamepad.touchpadPrimary,
            secondary: gamepad.touchpadSecondary
        )
    }

    private func touchpadButtons(
        button: GCControllerButtonInput,
        primary: GCControllerDirectionPad,
        secondary: GCControllerDirectionPad
    ) -> [(GCControllerButtonInput?, GCKAction)] {
        [
            (button, .touchpadButton),
            (primary.up, .touchpadPrimaryUp),
            (primary.right, .touchpadPrimaryRight),
            (primary.left, .touchpadPrimaryLeft),
            (primary.down, .touchpadPrimaryDown),
            (secondary.up, .touchpadSecondaryUp),
            (secondary.right, .touchpadSecondaryRight),
            (secondary.down, .touchpadSecondaryDown),
            (secondary.left, .touchpadSecondaryLeft)
        ]
    }

    private func handleThumbstick(action: GCKAction, controller: GCController?) {
        let position = action.position

        switch action {
        case .leftThumbstick:
            if leftThumbstick != position {
                leftThumbstick = position
                lastAction = action
            }
        case .rightThumbstick:
            if rightThumbstick != position {
                rightThumbstick = position
                lastAction = action
            }
        default:
            return
        }

        if let controller {
            emit(action: action, pressed: false, controller: controller)
        }
    }

    private func updatePublishedInput(action: GCKAction, pressed: Bool) {
        switch action {
        case .leftThumbstick, .rightThumbstick:
            handleThumbstick(action: action, controller: nil)
        default:
            lastAction = pressed ? action : .none
        }
    }

    private func resetInputState() {
        leftThumbstick = .centered
        rightThumbstick = .centered
        lastAction = .none
    }

    func emit(action: GCKAction, pressed: Bool, controller: GCController) {
        if let eventHandler {
            eventHandler(action, pressed, controller)
            return
        }

        let actionDescription = String(describing: action)
        let stateDescription = pressed ? "pressed" : "released"
        let playerIndex = controller.playerIndex.rawValue
        logger.info("Controller #\(playerIndex), button \(actionDescription) is \(stateDescription).")
    }
}

extension GCColor {
    /// Random color
    ///
    /// - Returns: A random color.
    public static var gckRandom: GCColor {
        GCColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }

    /// Random color.
    @available(*, deprecated, renamed: "gckRandom")
    public static var GCKRandom: GCColor {
        gckRandom
    }
}
// swiftlint:disable:this file_length
