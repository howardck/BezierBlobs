I want you to help me write a README for a GitHub SwiftUI-based project I've created that uses a parametric equation to calculate the vertices and orthogonals (or normals) of a superellipse, creates a SwiftUI Shape object that renders those superellipses on-screen, and shows several different methods of animating those Shapes by mapping, or transforming one set of vertices into another. The more complex and interesting of the two animations  moves the markers depicting the vertices in and out along the orthogonal at each vertex to produce an animated-blob type of effect.

Please derive your README from the two existing README's at https://github.com/howardck/BezierBlobs and https://github.com/howardck/BezierBlobs_README.

----------------------------------------------------------------------------------

# Superellipse Shapes

This is a SwiftUI-based project that uses a parametric equation to calculate the vertices and orthogonals (or normals) of a superellipse, creates a SwiftUI Shape object that renders those superellipses on-screen, and shows several different methods of animating those Shapes by mapping, or transforming one set of vertices into another.

The more complex and interesting of the two animations moves the markers depicting the vertices in and out along the orthogonal at each vertex to produce an animated-blob type of effect.

## Features

- Calculate vertices and orthogonals of superellipses using parametric equations
- Create SwiftUI Shape objects from superellipse vertices
- Animate Shape objects by transforming vertices
- Apply different easing functions to animations
- Control animation parameters such as speed, duration and loop count

## Installation

To run this project, you need Xcode 13 or later and iOS 15 or later.

- Clone this repository to your local machine
- Open SuperellipseShapes.xcodeproj in Xcode
- Select an iOS simulator or device as the target
- Build and run the project

## Usage

The main screen of the app shows four buttons that correspond to four different animation modes:

- Static: Shows a static superellipse with no animation
- Simple: Shows a simple animation that transforms one superellipse into another with linear interpolation
- Complex: Shows a complex animation that moves the vertices along the orthogonals with sinusoidal interpolation
- Random: Shows a random animation that transforms one superellipse into another with random interpolation

You can tap on any button to see the corresponding animation. You can also tap on any part of the screen (except for buttons) to toggle between showing and hiding markers for vertices and orthogonals.

You can adjust various parameters of the animations by tapping on the gear icon on the top right corner. This will open a settings screen where you can change values such as:

- Number of vertices: The number of points used to draw each superellipse (from 3 to 100)
- Superellipse exponent: The exponent value used in the parametric equation (from 0.1 to 10)
- Animation speed: The speed factor applied to each animation cycle (from 0.1x to 10x)
- Animation duration: The duration of each animation cycle in seconds (from 0.5s to 10s)
- Animation loop count: The number of times each animation repeats (from 1 to infinite)

You can also reset all parameters to their default values by tapping on the reset button on the top left corner.

## License

This project is licensed under MIT License - see LICENSE file for details.

## Credits

This project is inspired by these two projects:

[BezierBlobs](https://github.com/howardck/BezierBlobs): A SwiftUI-based app that uses Bezier curves instead of parametric equations.

[BezierBlobs_README](https://github.com/howardck/BezierBlobs_README): A detailed README file for BezierBlobs app.
