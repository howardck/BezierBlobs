*Everything you always wanted to know about superellipses, SwiftUI, animated blob-like objects (of the visual kind), and the intersection thereof.*

This project is a SwiftUI exploration of how to animate a family of superellipse-based curves. It's actually a bit more general than that: the project shows how to animate between any curve, defined simply for our purposes as a `[CGPoint]` array with an accompanying unit vector describing the normal at each `CGPoint`, and any secondary curve you can derive algorithmically from the first one, eg using a simple mapping or similar transformation. The project demonstrates two different examples of this.

`BezierBlobs` runs on both iPhone and the iPad. The user experience at present is somewhat better on iPad, due to some unresolved issues that occur when changing orientation between landscape and portrait on the phone. To be fixed ...

Enjoy!
