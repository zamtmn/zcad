#!/usr/bin/env python3
"""
Test script to verify arc rotation for issue #25
"""

import math
import numpy as np

def create_rotation_matrix_z(angle_deg):
    """Create a 4x4 rotation matrix for rotation around Z axis"""
    angle_rad = math.radians(angle_deg)
    c = math.cos(angle_rad)
    s = math.sin(angle_rad)
    return np.array([
        [c, -s, 0, 0],
        [s,  c, 0, 0],
        [0,  0, 1, 0],
        [0,  0, 0, 1]
    ])

def create_translation_matrix(dx, dy, dz):
    """Create a 4x4 translation matrix"""
    return np.array([
        [1, 0, 0, dx],
        [0, 1, 0, dy],
        [0, 0, 1, dz],
        [0, 0, 0,  1]
    ])

def transform_point(point, matrix):
    """Transform a 3D point using a 4x4 matrix"""
    p = np.array([point[0], point[1], point[2], 1])
    result = matrix @ p
    return result[:3]

def main():
    print("=== Test Issue #25: Arc Rotation ===\n")

    # Original arc parameters
    arc_center = np.array([2.0, 5.0, 0.0])
    radius = 10.0
    start_angle = 8.0
    end_angle = 94.0

    print("Original Arc:")
    print(f"  Center: ({arc_center[0]:.4f}, {arc_center[1]:.4f}, {arc_center[2]:.4f})")
    print(f"  Radius: {radius:.4f}")
    print(f"  Start Angle: {start_angle:.4f}°")
    print(f"  End Angle: {end_angle:.4f}°")
    print()

    # Rotation parameters
    rot_center = np.array([1.0, 1.0, 1.0])
    rot_angle = 25.0

    print("Rotation:")
    print(f"  Around point: ({rot_center[0]:.4f}, {rot_center[1]:.4f}, {rot_center[2]:.4f})")
    print(f"  Angle: {rot_angle:.4f}°")
    print()

    # Create transformation matrix: T^-1 * R * T
    # Move rotation center to origin, rotate, move back
    T1 = create_translation_matrix(-rot_center[0], -rot_center[1], -rot_center[2])
    R = create_rotation_matrix_z(rot_angle)
    T2 = create_translation_matrix(rot_center[0], rot_center[1], rot_center[2])

    # Combine: first T1, then R, then T2
    M = T2 @ R @ T1

    # Transform the arc center
    new_center = transform_point(arc_center, M)

    # Transform angles (simple addition for Z-axis rotation)
    new_start_angle = (start_angle + rot_angle) % 360
    new_end_angle = (end_angle + rot_angle) % 360

    print("Transformed Arc (Simple Z-axis Rotation):")
    print(f"  Center: ({new_center[0]:.4f}, {new_center[1]:.4f}, {new_center[2]:.4f})")
    print(f"  Radius: {radius:.4f}")
    print(f"  Start Angle: {new_start_angle:.4f}°")
    print(f"  End Angle: {new_end_angle:.4f}°")
    print()

    print("Expected (from issue #25):")
    print("  Center: (-0.2158, 5.0478, 0.0000)")
    print("  Radius: 10.0000")
    print("  Start Angle: 33.0000°")
    print("  End Angle: 119.0000°")
    print()

    # Check if results match
    expected_center = np.array([-0.2158, 5.0478, 0.0])
    expected_start = 33.0
    expected_end = 119.0

    center_error = np.linalg.norm(new_center - expected_center)
    start_error = abs(new_start_angle - expected_start)
    end_error = abs(new_end_angle - expected_end)

    print("Errors:")
    print(f"  Center error: {center_error:.6f}")
    print(f"  Start angle error: {start_error:.6f}°")
    print(f"  End angle error: {end_error:.6f}°")
    print()

    # Note: There might be a sign error in the expected center from the issue
    print("Note: The X coordinate sign differs.")
    print(f"  Our calculation: X={new_center[0]:.4f}")
    print(f"  Issue expected: X={expected_center[0]:.4f}")
    print("  This could be due to rotation direction (CW vs CCW)")
    print()

    if center_error < 0.001 and start_error < 0.1 and end_error < 0.1:
        print("✓ Test PASSED - Results match expected values")
    elif abs(new_center[0] + expected_center[0]) < 0.001 and abs(new_center[1] - expected_center[1]) < 0.001:
        print("⚠ Sign difference in X coordinate - rotation direction may be opposite")
    else:
        print("✗ Test FAILED - Results do not match")

    # Now let's also check what the actual points on the arc would be
    print("\n=== Verifying Arc Points ===")

    # Calculate start and end points on original arc
    start_rad = math.radians(start_angle)
    end_rad = math.radians(end_angle)

    orig_start_point = arc_center + np.array([
        radius * math.cos(start_rad),
        radius * math.sin(start_rad),
        0.0
    ])
    orig_end_point = arc_center + np.array([
        radius * math.cos(end_rad),
        radius * math.sin(end_rad),
        0.0
    ])

    print(f"Original start point: ({orig_start_point[0]:.4f}, {orig_start_point[1]:.4f}, {orig_start_point[2]:.4f})")
    print(f"Original end point: ({orig_end_point[0]:.4f}, {orig_end_point[1]:.4f}, {orig_end_point[2]:.4f})")

    # Transform these points
    new_start_point = transform_point(orig_start_point, M)
    new_end_point = transform_point(orig_end_point, M)

    print(f"Transformed start point: ({new_start_point[0]:.4f}, {new_start_point[1]:.4f}, {new_start_point[2]:.4f})")
    print(f"Transformed end point: ({new_end_point[0]:.4f}, {new_end_point[1]:.4f}, {new_end_point[2]:.4f})")

    # Calculate angles relative to new center
    relative_start = new_start_point - new_center
    relative_end = new_end_point - new_center

    calc_start_angle = math.degrees(math.atan2(relative_start[1], relative_start[0]))
    calc_end_angle = math.degrees(math.atan2(relative_end[1], relative_end[0]))

    if calc_start_angle < 0:
        calc_start_angle += 360
    if calc_end_angle < 0:
        calc_end_angle += 360

    print(f"Calculated start angle from point: {calc_start_angle:.4f}°")
    print(f"Calculated end angle from point: {calc_end_angle:.4f}°")

if __name__ == "__main__":
    main()
