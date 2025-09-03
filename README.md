# ABBP – FullScreen3DView
![demo](https://github.com/tsogp/capstone-gui/blob/master/demo.gif)

ABBP is a software system designed to simulate and visualize palletizing processes in warehouses.  
It is composed of two main components:  

1. **Python algorithm server** – receives a package list, validates its format, and computes an optimal placement of boxes on a pallet.  
2. **C++/Qt GUI application** – visualizes the palletizing process in real time with 3D animations, offering both autoplay and manual controls.  

The GUI follows an MVC architecture, where:
- **Model & Controller** are implemented in C++.
- **View** is implemented in QML using Qt Design Studio.  

The system allows workers and managers to preview palletizing steps, load package lists (manually or from JSON), and interact with the 3D simulation. This design separates computation (CPU-intensive, cloud-hosted in future) from visualization (client-side), ensuring scalability and responsiveness.

## Features
- Load pallet and package lists (manual input or JSON file).  
- Validate package structure (name, x/y/z coordinates, weight, load capacity, etc.).  
- Real-time 3D rendering of palletizing process with Qt Quick 3D.  
- Autoplay and manual step-through of box placement animations.  
- Multiple pallet types (Euro, Industrial, Asia).  
- Python backend for algorithm, Qt/C++ frontend for visualization.  

## Build Instructions

### Requirements
- **Qt 6.9+** (Core, Gui, Quick, Quick3D, QuickControls2, Test modules)  
- **CMake 3.16+**  
- **C++17 compatible compiler**  
- Python 3 (for running the algorithm server)  

### Build
```bash
git clone https://github.com/tsogp/capstone-gui
cd FullScreen3DView
mkdir build && cd build
cmake ..
cmake --build .
```

On successful build, run the application:
```bash
./appFullScreen3DView
```
