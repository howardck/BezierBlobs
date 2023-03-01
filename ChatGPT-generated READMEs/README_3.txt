My input:
I want to create a GitHub project that explores how to use SwiftUI to to create a superellipse-based Shape object from a parametric equation that stores an array of [CGPoint, CGVector] pairs describing the vertices on the curve, as well as the unit vectors describing their orthogonals. I then want to create an animation by moving the decorative markers at each vertex in and out along those orthogonals. Can you restate that objective in a way that might be suitable to include as a simple description in a README?

ChatGPT responds:
That sounds like an interesting project. Here is a possible way to restate your objective for a README:

This project demonstrates how to use SwiftUI to create a custom Shape object based on a superellipse equation1. A superellipse is a generalization of an ellipse that can have different degrees of roundness or squareness2. The Shape object takes an array of [CGPoint, CGVector] pairs as input, where each pair represents a vertex on the superellipse curve and its orthogonal unit vector3. The project also shows how to animate the Shape object by moving markers along the orthogonal vectors at each vertex.

This project explores using SwiftUI to create a superellipse-based Shape object using a parametric equation that creates an array of [CGPoint, CGVector] pairs describing the curve, where each `CGPoint` is a vertex on the curve and its corresponding `CGVector` is a unit vector describing the orthogonal (aka normal) at that point. The input argument `numPoints`  to the `SuperEllipse()` initializer ` describes the number of desired vertices , which in turn determines how good or bad an approximation the curve should be to its geometric ideal.


