#!/usr/bin/env python3
import math

print("=" * 80)
print("Arc Rotation Test - Issue #73")
print("=" * 80)

center_x = 152
center_y = 155
center_z = 0
radius = 10
start_angle_deg = 8
end_angle_deg = 94

rotation_center_x = 150
rotation_center_y = 150
rotation_center_z = 0

rotation_angle_deg = 25

print(f"\nOriginal Arc:")
print(f"  Center: ({center_x}, {center_y}, {center_z})")
print(f"  Radius: {radius}")
print(f"  Start Angle: {start_angle_deg}°")
print(f"  End Angle: {end_angle_deg}°")

print(f"\nRotation Parameters:")
print(f"  Rotation Center: ({rotation_center_x}, {rotation_center_y}, {rotation_center_z})")
print(f"  Rotation Angle: {rotation_angle_deg}°")

center_rel_x = center_x - rotation_center_x
center_rel_y = center_y - rotation_center_y

print(f"\nCenter relative to rotation point:")
print(f"  ({center_rel_x}, {center_rel_y})")

rotation_angle_rad = math.radians(rotation_angle_deg)
cos_theta = math.cos(rotation_angle_rad)
sin_theta = math.sin(rotation_angle_rad)

print(f"\nRotation matrix:")
print(f"  [{cos_theta:8.4f}  {-sin_theta:8.4f}]")
print(f"  [{sin_theta:8.4f}   {cos_theta:8.4f}]")

new_center_rel_x = center_rel_x * cos_theta - center_rel_y * sin_theta
new_center_rel_y = center_rel_x * sin_theta + center_rel_y * cos_theta

new_center_x = new_center_rel_x + rotation_center_x
new_center_y = new_center_rel_y + rotation_center_y

print(f"\nRotated center (relative):")
print(f"  ({new_center_rel_x:.4f}, {new_center_rel_y:.4f})")

print(f"\nRotated center (absolute):")
print(f"  ({new_center_x:.4f}, {new_center_y:.4f})")

start_angle_rad = math.radians(start_angle_deg)
end_angle_rad = math.radians(end_angle_deg)

start_point_local_x = radius * math.cos(start_angle_rad)
start_point_local_y = radius * math.sin(start_angle_rad)
end_point_local_x = radius * math.cos(end_angle_rad)
end_point_local_y = radius * math.sin(end_angle_rad)

print(f"\nOriginal arc points (relative to center):")
print(f"  Start: ({start_point_local_x:.4f}, {start_point_local_y:.4f})")
print(f"  End: ({end_point_local_x:.4f}, {end_point_local_y:.4f})")

start_point_world_x = center_x + start_point_local_x
start_point_world_y = center_y + start_point_local_y
end_point_world_x = center_x + end_point_local_x
end_point_world_y = center_y + end_point_local_y

print(f"\nOriginal arc points (world coordinates):")
print(f"  Start: ({start_point_world_x:.4f}, {start_point_world_y:.4f})")
print(f"  End: ({end_point_world_x:.4f}, {end_point_world_y:.4f})")

start_rel_x = start_point_world_x - rotation_center_x
start_rel_y = start_point_world_y - rotation_center_y
end_rel_x = end_point_world_x - rotation_center_x
end_rel_y = end_point_world_y - rotation_center_y

print(f"\nArc points relative to rotation center:")
print(f"  Start: ({start_rel_x:.4f}, {start_rel_y:.4f})")
print(f"  End: ({end_rel_x:.4f}, {end_rel_y:.4f})")

new_start_rel_x = start_rel_x * cos_theta - start_rel_y * sin_theta
new_start_rel_y = start_rel_x * sin_theta + start_rel_y * cos_theta
new_end_rel_x = end_rel_x * cos_theta - end_rel_y * sin_theta
new_end_rel_y = end_rel_x * sin_theta + end_rel_y * cos_theta

new_start_world_x = new_start_rel_x + rotation_center_x
new_start_world_y = new_start_rel_y + rotation_center_y
new_end_world_x = new_end_rel_x + rotation_center_x
new_end_world_y = new_end_rel_y + rotation_center_y

print(f"\nRotated arc points (world coordinates):")
print(f"  Start: ({new_start_world_x:.4f}, {new_start_world_y:.4f})")
print(f"  End: ({new_end_world_x:.4f}, {new_end_world_y:.4f})")

new_start_relative_to_new_center_x = new_start_world_x - new_center_x
new_start_relative_to_new_center_y = new_start_world_y - new_center_y
new_end_relative_to_new_center_x = new_end_world_x - new_center_x
new_end_relative_to_new_center_y = new_end_world_y - new_center_y

print(f"\nRotated arc points (relative to new center):")
print(f"  Start: ({new_start_relative_to_new_center_x:.4f}, {new_start_relative_to_new_center_y:.4f})")
print(f"  End: ({new_end_relative_to_new_center_x:.4f}, {new_end_relative_to_new_center_y:.4f})")

new_start_angle_rad = math.atan2(new_start_relative_to_new_center_y, new_start_relative_to_new_center_x)
new_end_angle_rad = math.atan2(new_end_relative_to_new_center_y, new_end_relative_to_new_center_x)

if new_start_angle_rad < 0:
    new_start_angle_rad += 2 * math.pi
if new_end_angle_rad < 0:
    new_end_angle_rad += 2 * math.pi

new_start_angle_deg = math.degrees(new_start_angle_rad)
new_end_angle_deg = math.degrees(new_end_angle_rad)

print(f"\nNew angles:")
print(f"  Start Angle: {new_start_angle_deg:.4f}° (radians: {new_start_angle_rad:.4f})")
print(f"  End Angle: {new_end_angle_deg:.4f}° (radians: {new_end_angle_rad:.4f})")

print(f"\n" + "=" * 80)
print("EXPECTED RESULT:")
print("=" * 80)
print(f"Arc:")
print(f"  Center X: {new_center_x:.4f}")
print(f"  Center Y: {new_center_y:.4f}")
print(f"  Center Z: {center_z}")
print(f"  Radius: {radius}")
print(f"  Start Angle: {new_start_angle_deg:.0f}°")
print(f"  End Angle: {new_end_angle_deg:.0f}°")

print(f"\n" + "=" * 80)
print("ISSUE DESCRIPTION SAYS:")
print("=" * 80)
print(f"Arc:")
print(f"  Center X: 149.6995")
print(f"  Center Y: 155.3768")
print(f"  Center Z: 0")
print(f"  Radius: 10")
print(f"  Start Angle: 33°")
print(f"  End Angle: 119°")

print(f"\n" + "=" * 80)
print("COMPARISON:")
print("=" * 80)
print(f"Center X: Calculated={new_center_x:.4f}, Expected=149.6995, Match={abs(new_center_x-149.6995)<0.001}")
print(f"Center Y: Calculated={new_center_y:.4f}, Expected=155.3768, Match={abs(new_center_y-155.3768)<0.001}")
print(f"Start Angle: Calculated={new_start_angle_deg:.0f}°, Expected=33°, Match={abs(new_start_angle_deg-33)<1}")
print(f"End Angle: Calculated={new_end_angle_deg:.0f}°, Expected=119°, Match={abs(new_end_angle_deg-119)<1}")

print("\n" + "=" * 80)
print("MIRRORING TEST")
print("=" * 80)

mirror_center_x = 150
mirror_center_y = 150
mirror_axis = "Y"

print(f"\nOriginal Arc:")
print(f"  Center: ({center_x}, {center_y}, {center_z})")
print(f"  Radius: {radius}")
print(f"  Start Angle: {start_angle_deg}°")
print(f"  End Angle: {end_angle_deg}°")

print(f"\nMirroring relative to {mirror_axis} axis at point ({mirror_center_x}, {mirror_center_y})")

mirrored_center_x = 2 * mirror_center_x - center_x
mirrored_center_y = center_y
mirrored_center_z = center_z

print(f"\nMirrored center:")
print(f"  ({mirrored_center_x}, {mirrored_center_y}, {mirrored_center_z})")

mirrored_start_angle_deg = 180 - end_angle_deg
mirrored_end_angle_deg = 180 - start_angle_deg

print(f"\nMirrored angles:")
print(f"  Start Angle: {mirrored_start_angle_deg}°")
print(f"  End Angle: {mirrored_end_angle_deg}°")

print(f"\n" + "=" * 80)
print("EXPECTED RESULT (from issue):")
print("=" * 80)
print(f"Arc:")
print(f"  Center X: 148")
print(f"  Center Y: 155")
print(f"  Center Z: 0")
print(f"  Radius: 10")
print(f"  Start Angle: 86°")
print(f"  End Angle: 172°")

print(f"\n" + "=" * 80)
print("COMPARISON:")
print("=" * 80)
print(f"Center X: Calculated={mirrored_center_x}, Expected=148, Match={mirrored_center_x==148}")
print(f"Center Y: Calculated={mirrored_center_y}, Expected=155, Match={mirrored_center_y==155}")
print(f"Start Angle: Calculated={mirrored_start_angle_deg}°, Expected=86°, Match={mirrored_start_angle_deg==86}")
print(f"End Angle: Calculated={mirrored_end_angle_deg}°, Expected=172°, Match={mirrored_end_angle_deg==172}")
