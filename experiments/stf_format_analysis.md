# STF Format Analysis - Issue #422

## Sample STF File Structure

Based on analysis of the provided sample file (sample.stf.txt), the correct structure is:

```
[VERSION]
STFF=1.0.5
Progname=Revit
Progvers=2021

[PROJECT]
Name=+++������-���
Date=2025-10-27
Operator=Bobrov.V
NrRooms=20
Room1=ROOM.R1
Room2=ROOM.R2
...
Room20=ROOM.R20

[ROOM.R1]
Name=28 �������
Height=2.8
WorkingPlane=0
NrPoints=12
Point1=-11.94 -17.186
Point2=-11.94 -19.841
...
Point12=-9.34 -17.186
R_Ceiling=0.75
NrLums=0
NrStruct=0
NrFurns=0

[ROOM.R2]
...

[ROOM.R11]
Name=45 ����������
Height=2.8
WorkingPlane=0.8
NrPoints=4
Point1=-11.94 -24.031
...
R_Ceiling=0.75
Lum1=KLED
Lum1.Pos=-10.98 -25.138 2.45
Lum1.Rot=0 0 90
Lum2=KLED
Lum2.Pos=-7.14 -25.138 2.45
Lum2.Rot=0 0 90
Lum3=KLED
Lum3.Pos=-9.06 -25.138 2.45
Lum3.Rot=0 0 90
NrLums=3
NrStruct=0
NrFurns=0

[KLED]
Manufacturer=
Name=
OrderNr=
Box=1 1 0
Shape=0
Load=14
Flux=0
NrLamps=1
MountingType=1

[KLED]
Manufacturer=
Name=
OrderNr=
Box=1 1 0
Shape=0
Load=14
Flux=0
NrLamps=1
MountingType=1

[KLED]
Manufacturer=
Name=
OrderNr=
Box=1 1 0
Shape=0
Load=14
Flux=0
NrLamps=1
MountingType=1

[ROOM.R12]
...
```

## Key Observations

1. **NO STOREY/FLOOR sections**: The sample file does NOT contain `[STOREY.Sx]` sections at all
2. **NO FloorLevel field in rooms**: Rooms don't have a `FloorLevel=` field
3. **Luminaire definitions immediately after room**: Each room's luminaire type definitions appear immediately after the room section, not at the end
4. **Multiple definitions for same type**: Each luminaire instance gets its own type definition section (e.g., 3x `[KLED]` sections for 3 KLED luminaires)

## Issues in Current Implementation

### In `uzvdialuxmanager.pas`:

1. **Line 1787-1789**: Writes `WriteSTFFloors(stfFile)` which creates `[STOREY.Sx]` sections - WRONG, should be removed
2. **Line 1367**: Writes `FloorLevel=` field - WRONG, should be removed
3. **Line 1807**: Writes all luminaire types at the end with `WriteSTFLuminaireTypes()` - WRONG order
4. **Line 1391-1411**: `WriteSTFLuminaireTypes()` writes one definition per unique type - WRONG, should write one per instance

### Correct Approach:

- Remove STOREY sections completely
- Remove FloorLevel field from rooms
- Write luminaire type definitions immediately after each room (one definition per luminaire instance, not per type)
- Remove the final batch luminaire type writing

## Required Changes

1. Remove `WriteSTFFloors()` call
2. Remove `FloorLevel=` line in `WriteSTFRoom()`
3. Modify `WriteRoomLuminaires()` to write luminaire definitions immediately after room
4. Remove final `WriteSTFLuminaireTypes()` call
5. Update `WriteSTFProjectSection()` to NOT write NrStoreys/Storey references
