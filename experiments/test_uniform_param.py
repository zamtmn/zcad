#!/usr/bin/env python3
"""
Test different parameterization methods to find what produces the expected control points
"""

import numpy as np

def basis_function(i, p, u, knots):
    """Compute B-spline basis function"""
    num_ctrl_pts = len(knots) - p - 2
    if abs(u - knots[-1]) < 1e-10:
        return 1.0 if i == num_ctrl_pts else 0.0

    if p == 0:
        if knots[i] <= u < knots[i+1]:
            return 1.0
        elif abs(u - knots[i+1]) < 1e-10 and i+1 == len(knots)-1:
            return 1.0
        else:
            return 0.0

    basis_values = np.zeros(p + 1)

    for j in range(p + 1):
        if knots[i+j] <= u < knots[i+j+1]:
            basis_values[j] = 1.0
        elif abs(u - knots[i+j+1]) < 1e-10 and i+j+1 == len(knots)-1:
            basis_values[j] = 1.0

    for k in range(1, p + 1):
        if basis_values[0] == 0.0:
            saved = 0.0
        else:
            u_right = knots[i+k]
            u_left = knots[i]
            if abs(u_right - u_left) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - u_left) / (u_right - u_left)) * basis_values[0]

        for j in range(p - k + 1):
            u_left = knots[i+j+1]
            u_right = knots[i+j+k+1]

            if basis_values[j+1] == 0.0:
                basis_values[j] = saved
                saved = 0.0
            else:
                if abs(u_right - u_left) < 1e-10:
                    temp = 0.0
                else:
                    temp = ((u_right - u) / (u_right - u_left)) * basis_values[j+1]
                basis_values[j] = saved + temp

                if abs(knots[i+j+k+1] - knots[i+j+1]) < 1e-10:
                    saved = 0.0
                else:
                    saved = ((u - knots[i+j+1]) / (knots[i+j+k+1] - knots[i+j+1])) * basis_values[j+1]

    return basis_values[0]

def evaluate_nurbs(control_points, knots, degree, u):
    """Evaluate NURBS curve at parameter u"""
    point = np.zeros(3)
    for i in range(len(control_points)):
        basis = basis_function(i, degree, u, knots)
        point += basis * control_points[i]
    return point

# Fit points
fit_points = np.array([
    [1583.2136549257, 417.836639195, 0],
    [2346.3909069169, 988.9560396917, 0],
    [1396.2099574179, 1772.3499076297, 0],
    [-392.9605538726, 1716.754213776, 0],
    [-41.2801529313, 2784.8206166348, 0],
    [1717.1218517754, 2954.1482170881, 0],
    [3449.4734564123, 2146.5858149265, 0]
])

# Expected control points
expected_control_points = np.array([
    [1583.2137, 417.8366, 0],
    [1943.9619, 588.3078, 0],
    [2770.7705, 979.0151, 0],
    [1225.7225, 2260.4551, 0],
    [-771.0874, 1052.6822, 0],
    [-50.7662, 3342.0538, 0],
    [1877.21, 3020.2007, 0],
    [2911.8082, 2445.335, 0],
    [3449.4735, 2146.5858, 0]
])

degree = 3
num_fit = len(fit_points)
n = len(expected_control_points) - 1  # n = 8

print("=" * 70)
print("Testing different parameterizations")
print("=" * 70)
print()

# Test 1: Uniform parameterization with standard knot vector
print("Test 1: Uniform parameterization")
params_uniform = np.linspace(0, 1, num_fit)

# Generate knot vector
m = n + degree + 1
knots_uniform = np.zeros(m + 1)
for i in range(degree + 1):
    knots_uniform[i] = 0.0
for j in range(1, n - degree + 1):
    knots_uniform[j + degree] = np.mean(params_uniform[j:j+degree])
for i in range(n + 1, m + 1):
    knots_uniform[i] = 1.0

print(f"  Params: {params_uniform}")
print(f"  Knots: {knots_uniform}")

max_error = 0.0
for i, (fp, param) in enumerate(zip(fit_points, params_uniform)):
    curve_point = evaluate_nurbs(expected_control_points, knots_uniform, degree, param)
    error = np.linalg.norm(curve_point - fp)
    max_error = max(max_error, error)

print(f"  Max error: {max_error:.4f}")
print()

# Test 2: Let's try to find the right parameters by testing what makes the curve pass through the points
print("Test 2: Searching for correct parameters...")

# Use optimization to find the correct parameters
from scipy.optimize import minimize

def objective(params_to_test):
    """Objective function: minimize error between curve and fit points"""
    # Ensure params are sorted and in [0,1]
    params_to_test = np.sort(params_to_test)
    params_full = np.concatenate([[0.0], params_to_test, [1.0]])

    # Generate knot vector
    m = n + degree + 1
    knots_test = np.zeros(m + 1)
    for i in range(degree + 1):
        knots_test[i] = 0.0
    for j in range(1, n - degree + 1):
        knots_test[j + degree] = np.mean(params_full[j:j+degree])
    for i in range(n + 1, m + 1):
        knots_test[i] = 1.0

    total_error = 0.0
    for fp, param in zip(fit_points, params_full):
        try:
            curve_point = evaluate_nurbs(expected_control_points, knots_test, degree, param)
            error = np.linalg.norm(curve_point - fp)
            total_error += error ** 2
        except:
            total_error += 1e10

    return total_error

# Initial guess: uniform spacing for interior points
x0 = np.linspace(0, 1, num_fit)[1:-1]

result = minimize(objective, x0, method='Nelder-Mead', options={'maxiter': 10000})

if result.success:
    best_params = np.sort(result.x)
    params_best = np.concatenate([[0.0], best_params, [1.0]])

    # Generate best knot vector
    m = n + degree + 1
    knots_best = np.zeros(m + 1)
    for i in range(degree + 1):
        knots_best[i] = 0.0
    for j in range(1, n - degree + 1):
        knots_best[j + degree] = np.mean(params_best[j:j+degree])
    for i in range(n + 1, m + 1):
        knots_best[i] = 1.0

    print(f"  Found params: {params_best}")
    print(f"  Found knots: {knots_best}")

    max_error = 0.0
    for fp, param in zip(fit_points, params_best):
        curve_point = evaluate_nurbs(expected_control_points, knots_best, degree, param)
        error = np.linalg.norm(curve_point - fp)
        max_error = max(max_error, error)

    print(f"  Max error: {max_error:.4f}")

    if max_error < 1.0:
        print("  ✅ SUCCESS! Found params that make curve pass through fit points!")
        print()
        print("  Optimal parameters for each fit point:")
        for i, param in enumerate(params_best):
            print(f"    p{i+1}: {param:.10f}")
    else:
        print(f"  ❌ Still too much error")
else:
    print(f"  ❌ Optimization failed")

print()
print("=" * 70)
