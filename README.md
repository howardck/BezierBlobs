*Everything you always wanted to know about SwiftUI, superellipses, animated blobbie-type things, and the intersection thereof.*

This project is an exploration of how to animate a family of superellipse-based curves in SwiftUI. Actually it's a bit more general than that: the project shows how to animate between any superellipse-based curve, defined for our purposes as a `[CGPoint, CGVector]` array, where the `CGPoints` are the calculated vertices of the superellipse and the `CGVectors` are their corresponding normals, or orthogonals, and any secondary curve you can derive algorithmically from the first, eg using a simple mapping or transformation. 

MY GIF IS BELOW ME
<img align="right" src="README_resources/NEW_DeltaWing_Gifs/DeltaWingFixedUnsmoothed.gif">
MY GIF IS ABOVE ME

<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

<!--
---- DeltaWingFixedUnsmoothed ----
![me](https://github.com/howardck/BezierBlobs/blob/main/BezierBlobs/README_resources/NEW_DeltaWing_Gifs/DeltaWingFixedUnsmoothed.gif)

</br>
</br>

---- DeltaWingRandomUnsmoothed ----
![me](https://github.com/howardck/BezierBlobs/blob/main/BezierBlobs/README_resources/NEW_DeltaWing_Gifs/DeltaWingRandomUnsmoothed.gif)


</br>

-->

<--
![me](https://github.com/howardck/BezierBlobs/blob/main/BezierBlobs/README_resources/Delta_fixed_unsmoothed_1.RESIZED.gif)

<img src="./README_resources/Delta_fixed_unsmoothed_1.gif" width="600" height="400"/>

![me](https://github.com/howardck/BezierBlobs/blob/main/BezierBlobs/README_resources/Delta_fixed_unsmoothed_1.RESIZED_3.gif)

![me](https://github.com/howardck/BezierBlobs/blob/main/BezierBlobs/README_resources/Delta_fixed_unsmoothed_1.gif)

![me](/README_resources/Delta_fixed_unsmoothed_1.gif)
->

</br>
The project demonstrates two different examples, one the aforementioned ***animating blob*** effect; the other an ***orbital*** effect in which the vertex points of the curve travel along its circumference in orbit-like fashion.

<--
<img align="left" src="/README_resources/Delta_fixed_unsmoothed_1.gif width=566">
->
<!--
https://github.com/howardck/BezierBlobs/blob/main/BezierBlobs/README_resources/Delta_fixed_unsmoothed_1.gif
->

TEST TEST

<!-- width="640"> ->

`BezierBlobs` runs on both iPhone and the iPad. The user experience at present is better on iPad, due to some unresolved issues that occur when changing orientation between landscape and portrait on the phone. To be fixed (hopefully) ...

Enjoy!
