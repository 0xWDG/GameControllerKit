//
//  GCKControllerShape.swift
//  GameControllerKit
//
//  Created by Wesley de Groot on 2024-08-19.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/GameControllerKit
//  MIT License
//

import SwiftUI

// MARK: - Shape definitions

/// A SwiftUI `Shape` that draws a simplified PlayStation-style controller
/// silhouette (DualSense / DualShock).
///
/// The outline is designed in a 200 × 130 coordinate space and scales to
/// whatever `CGRect` SwiftUI provides.
public struct GCKPlayStationControllerShape: Shape {
    /// Initialize a PlayStation controller shape.
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 200
        let sy = rect.height / 130

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }

        var path = Path()

        // ── top-left of the flat upper body ──────────────────────────────
        path.move(to: p(30, 0))
        // Top edge
        path.addLine(to: p(170, 0))
        // Top-right corner
        path.addQuadCurve(to: p(195, 25), control: p(195, 0))
        // Right shoulder (curves inward toward grip)
        path.addCurve(to: p(165, 60),
                      control1: p(200, 48),
                      control2: p(185, 52))
        // Right grip – outer edge (going down)
        path.addCurve(to: p(160, 124),
                      control1: p(153, 70),
                      control2: p(174, 118))
        // Right grip – bottom edge
        path.addCurve(to: p(118, 118),
                      control1: p(158, 130),
                      control2: p(138, 130))
        // Right grip – inner edge (going up toward gap)
        path.addCurve(to: p(108, 84),
                      control1: p(113, 112),
                      control2: p(108, 102))
        // Gap arch between the two grips
        path.addCurve(to: p(92, 84),
                      control1: p(108, 68),
                      control2: p(92, 68))
        // Left grip – inner edge (going down)
        path.addCurve(to: p(82, 118),
                      control1: p(92, 102),
                      control2: p(87, 112))
        // Left grip – bottom edge
        path.addCurve(to: p(40, 124),
                      control1: p(62, 130),
                      control2: p(42, 130))
        // Left grip – outer edge (going up)
        path.addCurve(to: p(35, 60),
                      control1: p(26, 118),
                      control2: p(47, 70))
        // Left shoulder (back up to top-left corner)
        path.addCurve(to: p(5, 25),
                      control1: p(15, 52),
                      control2: p(0, 48))
        // Top-left corner
        path.addQuadCurve(to: p(30, 0), control: p(5, 0))
        path.closeSubpath()

        return path
    }
}

/// A SwiftUI `Shape` that draws a simplified Xbox-style controller silhouette.
///
/// The outline is designed in a 200 × 140 coordinate space and scales to
/// whatever `CGRect` SwiftUI provides.
public struct GCKXboxControllerShape: Shape {
    /// Initialize an Xbox controller shape.
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let sx = rect.width / 200
        let sy = rect.height / 140

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }

        var path = Path()

        // ── Xbox has a slightly arched top rather than fully flat ─────────
        path.move(to: p(50, 0))
        // Top arch (subtle arc across the top)
        path.addQuadCurve(to: p(150, 0), control: p(100, 8))
        // Top-right corner
        path.addQuadCurve(to: p(192, 32), control: p(192, 0))
        // Right shoulder (curves inward)
        path.addCurve(to: p(168, 68),
                      control1: p(198, 56),
                      control2: p(188, 60))
        // Right grip – outer edge (going down)
        path.addCurve(to: p(162, 130),
                      control1: p(156, 78),
                      control2: p(175, 122))
        // Right grip – bottom edge
        path.addCurve(to: p(120, 122),
                      control1: p(160, 138),
                      control2: p(140, 138))
        // Right grip – inner edge (going up toward gap)
        path.addCurve(to: p(110, 88),
                      control1: p(115, 116),
                      control2: p(110, 106))
        // Gap arch between grips
        path.addCurve(to: p(90, 88),
                      control1: p(110, 72),
                      control2: p(90, 72))
        // Left grip – inner edge (going down)
        path.addCurve(to: p(80, 122),
                      control1: p(90, 106),
                      control2: p(85, 116))
        // Left grip – bottom edge
        path.addCurve(to: p(38, 130),
                      control1: p(60, 138),
                      control2: p(40, 138))
        // Left grip – outer edge (going up)
        path.addCurve(to: p(32, 68),
                      control1: p(25, 122),
                      control2: p(44, 78))
        // Left shoulder (back up to top-left corner)
        path.addCurve(to: p(8, 32),
                      control1: p(12, 60),
                      control2: p(2, 56))
        // Top-left corner
        path.addQuadCurve(to: p(50, 0), control: p(8, 0))
        path.closeSubpath()

        return path
    }
}

/// A SwiftUI `Shape` that draws a simplified Siri Remote silhouette
/// (tall, pill-shaped rectangle).
public struct GCKSiriRemoteShape: Shape {
    /// Initialize a Siri Remote shape.
    public init() {}

    public func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect,
             cornerRadius: min(rect.width, rect.height) * 0.3)
    }
}

// MARK: - Composite view

/// A view that renders the outline silhouette of the connected controller
/// using the appropriate `Shape` for each ``GCKControllerType``.
///
/// - For PlayStation (DualSense / DualShock): ``GCKPlayStationControllerShape``
/// - For Xbox: ``GCKXboxControllerShape``
/// - For Siri Remote: ``GCKSiriRemoteShape``
/// - For generic / unknown: the system `gamecontroller` SF Symbol
public struct GCKControllerShapeView: View {
    /// The type of controller to render.
    public let controllerType: GCKControllerType?

    /// Initialize with a controller type.
    public init(controllerType: GCKControllerType?) {
        self.controllerType = controllerType
    }

    public var body: some View {
        Group {
            switch controllerType {
            case .dualSense, .dualShock:
                GCKPlayStationControllerShape()
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 120, height: 78)

            case .xbox:
                GCKXboxControllerShape()
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 120, height: 84)

            case .siriRemote:
                GCKSiriRemoteShape()
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 36, height: 80)

            case .generic, .none:
                Image(systemName: "gamecontroller")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Previews

struct GCKControllerShapeViewPreview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            GCKControllerShapeView(controllerType: .dualSense)
            GCKControllerShapeView(controllerType: .xbox)
            GCKControllerShapeView(controllerType: .siriRemote)
            GCKControllerShapeView(controllerType: .generic)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
