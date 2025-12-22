#!/usr/bin/env python3
"""
Experiment to test the synchmain frame switching logic.
This script simulates the frame creation and switching to verify the implementation.
"""

class MockFrame:
    def __init__(self, name):
        self.name = name
        self.parent = None
        self.align = 'alClient'
        self.visible = False

    def show(self):
        self.visible = True
        print(f"Frame {self.name} is now visible")

class MockPanel:
    def __init__(self, name):
        self.name = name

class MockForm:
    def __init__(self):
        self.current_frame = None
        self.panel_synch = MockPanel("PanelSynch")

    def show_frame(self, frame_class):
        # Simulate the ShowFrame method
        if self.current_frame:
            print(f"Freeing current frame: {self.current_frame.name}")
            self.current_frame = None

        self.current_frame = frame_class()
        self.current_frame.parent = self.panel_synch
        self.current_frame.align = 'alClient'
        self.current_frame.show()

        print(f"Switched to frame: {self.current_frame.name}")

# Mock frame classes
class TVElectrNav(MockFrame):
    def __init__(self):
        super().__init__("TVElectrNav")

class TLowVoltNav(MockFrame):
    def __init__(self):
        super().__init__("TLowVoltNav")

class TSpecificationNav(MockFrame):
    def __init__(self):
        super().__init__("TSpecificationNav")

class TDBNav(MockFrame):
    def __init__(self):
        super().__init__("TDBNav")

def test_frame_switching():
    print("Testing frame switching logic...")

    form = MockForm()

    # Test switching to different frames
    print("\n1. Switching to TVElectrNav:")
    form.show_frame(TVElectrNav)

    print("\n2. Switching to TLowVoltNav:")
    form.show_frame(TLowVoltNav)

    print("\n3. Switching to TSpecificationNav:")
    form.show_frame(TSpecificationNav)

    print("\n4. Switching to TDBNav:")
    form.show_frame(TDBNav)

    print("\n5. Switching back to TVElectrNav:")
    form.show_frame(TVElectrNav)

    print("\nFrame switching test completed successfully!")

if __name__ == "__main__":
    test_frame_switching()