*Everything you always wanted to know about superellipses, animated blob-like objects of the visual kind, and the intersection thereof.*

This project is a SwiftUI exploration of how to animate a family of superellipse-based curves. Actually, it's a bit more general than that: the project shows how to animate between any curve, defined simply for our purposes as a `[CGPoint, CGVector]` array, where the `CGPoints` are the calculated vertices of the superellipse and the `CGVectors` are their corresponding normals, or orthogonals, and a secondary curve you are able to derive algorithmically from the first one, eg using a simple mapping or transformation. 
</br>
</br>
The project demonstrates two different examples, one the aforementioned *animating blob* effect; the other in which the vertex points on the curve travel in orbit-like fashion along its circumference.

<img align="right" src="README_resources/Delta-unsmoothed:fixed_5.gif">

TEST TEST

<!-- width="640"> ->

`BezierBlobs` runs on both iPhone and the iPad. The user experience at present is somewhat better on iPad, due to some unresolved issues that occur when changing orientation between landscape and portrait on the phone. To be fixed ...

Enjoy!
