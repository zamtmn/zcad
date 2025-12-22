# Connection Manager Module Architecture

## Overview

This document describes the architectural reorganization of the Connection Manager module. The module is responsible for managing electrical device connections, building hierarchies, and exporting data to various database formats.

## Problem Statement

The original architecture had all files in a single flat directory with mixed concerns:
- Database operations (SQLite and Access) mixed with business logic
- Drawing entity interactions scattered across multiple files
- GUI code tightly coupled with data access logic
- No clear separation of responsibilities

## New Architecture

The module has been reorganized into a layered architecture with clear separation of concerns:

```
connectmanager/
├── core/                          [Business Logic Layer]
│   ├── uzvmcmanager.pas          - Main orchestrator/facade
│   └── uzvmchierarchy.pas        - Device hierarchy business logic
├── database/                      [Data Access Layer]
│   ├── uzvmcsqlite.pas           - SQLite connection and operations
│   ├── uzvmcaccess.pas           - MS Access database operations
│   └── uzvmcdbconsts.pas         - Database constants
├── drawing/                       [Drawing Interaction Layer]
│   └── uzvmcdrawing.pas          - CAD drawing entity extraction
└── gui/                           [Presentation Layer]
    ├── dispatcherconnectionmanager.pas/.lfm
    └── synchmain.pas/.lfm
```

## Layer Responsibilities

### 1. Core (Business Logic)
**Purpose:** Contains the domain logic and orchestrates operations between layers.

**Files:**
- `uzvmcmanager.pas` - Main entry point, coordinates all operations
- `uzvmchierarchy.pas` - Device hierarchy building algorithms

**Key Classes:**
- `TConnectionManager` - Facade pattern, coordinates database, drawing, and hierarchy operations
- `THierarchyBuilder` - Builds device hierarchies using recursive algorithms

### 2. Database (Data Access)
**Purpose:** Handles all database interactions, isolating persistence logic.

**Files:**
- `uzvmcsqlite.pas` - SQLite database management
- `uzvmcaccess.pas` - MS Access database export
- `uzvmcdbconsts.pas` - Shared constants

**Key Classes:**
- `TSQLiteConnectionManager` - Manages SQLite connections, handles CRUD operations
- `TAccessDBExporter` - Exports data to MS Access via ODBC

**Benefits:**
- Easy to test database operations independently
- Can switch database implementations without affecting business logic
- Connection management centralized

### 3. Drawing (CAD Integration)
**Purpose:** Extracts data from CAD drawing entities.

**Files:**
- `uzvmcdrawing.pas` - Drawing entity data collection

**Key Classes:**
- `TDeviceDataCollector` - Collects device information from drawing entities
- `TDeviceData` - Data transfer object for device information

**Benefits:**
- Drawing interaction logic isolated from business logic
- Easier to mock for testing
- Can support different drawing formats in the future

### 4. GUI (Presentation)
**Purpose:** User interface components.

**Files:**
- `dispatcherconnectionmanager.pas/.lfm` - Main connection manager UI
- `synchmain.pas/.lfm` - Main form container

**Benefits:**
- GUI can be modified without affecting business logic
- Can add different UI implementations (e.g., console, web)

## Usage Example

```pascal
var
  manager: TConnectionManager;
begin
  manager := TConnectionManager.Create(drawingPath);
  try
    manager.CreateTemporaryDatabase;
    manager.AddHierarchyColumns;

    manager.ExportToAccessDatabase('D:\mydb.accdb');
  finally
    manager.Free;
  end;
end;
```

## Migration from Old Architecture

### Old Files → New Files Mapping

| Old File                     | New Location/File               | Notes                          |
|------------------------------|----------------------------------|--------------------------------|
| uzvmcdbconsts.pas            | database/uzvmcdbconsts.pas      | Moved as-is                    |
| uzvelcreatetempdb.pas        | database/uzvmcsqlite.pas        | Refactored into class          |
| uzvelcontroltempdb.pas       | core/uzvmchierarchy.pas         | Hierarchy logic extracted      |
| uzvmanagerconnect.pas        | core/uzvmcmanager.pas           | Orchestration logic            |
| uzvelaccessdbcontrol.pas     | database/uzvmcaccess.pas        | Access DB operations isolated  |
| dispatcherconnectionmanager  | gui/dispatcherconnectionmanager | Moved to GUI folder            |
| synchmain                    | gui/synchmain                    | Moved to GUI folder            |

### Old Files Status
The old files remain in the root directory for backward compatibility but should be considered deprecated. They can be removed after all dependencies are updated.

## Key Improvements

1. **Separation of Concerns**: Each layer has a single, well-defined responsibility
2. **Testability**: Layers can be tested independently with mock objects
3. **Maintainability**: Changes in one layer don't cascade to others
4. **Extensibility**: Easy to add new database types or drawing formats
5. **Code Reuse**: Core business logic can be used from different UIs
6. **Reduced Coupling**: Dependencies flow in one direction (GUI → Core → Database/Drawing)

## Future Enhancements

1. **Low-current electrical systems**: Can add new modules following the same pattern
2. **Different database backends**: Can add PostgreSQL, MySQL support in database layer
3. **REST API**: Can add API layer on top of core business logic
4. **Import/Export formats**: Can add Excel, CSV support alongside Access

## Dependencies

### Layer Dependencies (Allowed)
```
GUI → Core → {Database, Drawing}
Database ← Core → Drawing
```

### Anti-patterns (Not Allowed)
- Database → Core (database shouldn't know about business logic)
- Drawing → Core (drawing shouldn't know about business logic)
- Database → Drawing (cross-layer dependencies)

## Design Patterns Used

1. **Facade Pattern**: `TConnectionManager` provides simplified interface
2. **Separation of Concerns**: Clear layer boundaries
3. **Dependency Injection**: Managers composed from specialized components
4. **Data Transfer Object**: `TDeviceData` for transferring data between layers

## Conclusion

This architecture provides a solid foundation for future development of the connection manager module. The clear separation of concerns makes the code easier to understand, test, and extend.
