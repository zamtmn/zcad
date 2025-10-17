#!/usr/bin/env python3
"""
Debug the basis function evaluation at u=1.0 for i=3.
"""

def basis_function_debug(i, p, u, knots):
    """Debug version with print statements."""
    print(f"\n=== BasisFunction(i={i}, p={p}, u={u}) ===")
    print(f"Knots: {knots}")
    print(f"Length(knots): {len(knots)}")

    # Special case for degree 0
    if p == 0:
        cond1 = u >= knots[i] and u < knots[i+1]
        cond2 = u == knots[i+1] and i == len(knots)-2
        print(f"Degree 0:")
        print(f"  Condition 1: ({u} >= {knots[i]}) and ({u} < {knots[i+1]}) = {cond1}")
        print(f"  Condition 2: ({u} == {knots[i+1]}) and ({i} == {len(knots)-2}) = {cond2}")
        if cond1:
            return 1.0
        elif cond2:
            return 1.0
        else:
            return 0.0

    # Use triangular table
    N = [0.0] * (p + 1)

    # Initialize degree 0
    print(f"Initializing degree 0:")
    for j in range(p + 1):
        cond1 = u >= knots[i+j] and u < knots[i+j+1]
        cond2 = u == knots[i+j+1] and (i+j) == len(knots)-2
        print(f"  j={j}: knots[{i+j}]={knots[i+j]}, knots[{i+j+1}]={knots[i+j+1]}")
        print(f"    Cond1: ({u} >= {knots[i+j]}) and ({u} < {knots[i+j+1]}) = {cond1}")
        print(f"    Cond2: ({u} == {knots[i+j+1]}) and ({i+j} == {len(knots)-2}) = {cond2}")

        if cond1:
            N[j] = 1.0
        elif cond2:
            N[j] = 1.0
        else:
            N[j] = 0.0
        print(f"    N[{j}] = {N[j]}")

    print(f"After degree 0 initialization: N = {N}")

    # Build up to degree p
    for k in range(1, p + 1):
        print(f"\nBuilding degree {k}:")

        # Handle left end
        if N[0] == 0.0:
            saved = 0.0
        else:
            uright = knots[i+k]
            uleft = knots[i]
            if abs(uright - uleft) < 1e-10:
                saved = 0.0
            else:
                saved = ((u - uleft) / (uright - uleft)) * N[0]
        print(f"  Initial saved = {saved}")

        # Process middle terms
        for j in range(p - k + 1):
            print(f"  j={j}:")
            uleft = knots[i+j+1]
            uright = knots[i+j+k+1]

            if N[j+1] == 0.0:
                N[j] = saved
                saved = 0.0
                print(f"    N[j+1]==0, so N[{j}]={N[j]}, saved=0")
            else:
                if abs(uright - uleft) < 1e-10:
                    temp = 0.0
                else:
                    temp = ((uright - u) / (uright - uleft)) * N[j+1]
                N[j] = saved + temp
                print(f"    temp={(uright - u) / (uright - uleft) if abs(uright - uleft) >= 1e-10 else 0}*{N[j+1]}={temp}")
                print(f"    N[{j}] = {saved} + {temp} = {N[j]}")

                if abs(knots[i+j+k+1] - knots[i+j+1]) < 1e-10:
                    saved = 0.0
                else:
                    saved = ((u - knots[i+j+1]) / (knots[i+j+k+1] - knots[i+j+1])) * N[j+1]
                print(f"    new saved = {saved}")

        print(f"  After degree {k}: N = {N}")

    result = N[0]
    print(f"\nFinal result: N_{i},{p}({u}) = {result}")
    return result

# Test case: 4 points, degree 3, knots = [0,0,0,0,1,1,1,1]
knots = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0]
u = 1.0
i = 3
p = 3

result = basis_function_debug(i, p, u, knots)
print(f"\n{'='*70}")
print(f"RESULT: N_{i},{p}({u}) = {result}")
print(f"EXPECTED: 1.0")
print(f"{'='*70}")
