*Everything you always wanted to know about SwiftUI, superellipses, animated blobbie-type things, and the intersection thereof.*

<br/>

**0.DeltaWing.GIF**
<br/>
DeltaWing/Not Smoothed/Not Randomized/Vertex Markers Only<br/>

Now is the time for all good men to come to the aid of their party. To help one and other, and to help this great (or not so great -- whatever) nation of ours once and for all discourage the scourge of all that is unhold and plays no role in the hopes and dreams of men. And women too for all that matter!!!<br/>

<img align="center" src="_GIFs/0.DeltaWing.gif" width="667">

This is what I want to say about DeltaWing #000000000000000. And a fine beast it is, no matter what you think of it and its kin, in life previous and left afterward. In other words, onward!!!<br/>

**1.DeltaWing.GIF**
<br/>
DeltaWing/Not Smoothed/Not Randomized<br/>

Now is the time for all good men to come to the aid of their party. To help one and other, and to help this great (or not so great -- whatever) nation of ours once and for all discourage the scourge of all that is unhold and plays no role in the hopes and dreams of men. And women too for all that matter!!!<br/>

<img align="center" src="_GIFs/1.DeltaWing.gif" width="667">

This is what I want to say about DeltaWing #111111111111111. And a fine beast it is, no matter what you think of it and its kin, in life previous and left afterward. In other words, onward!!!<br/>

**2.DeltaWing.GIF**
<br/>
DeltaWing/Smoothed/Not Randomized<br/>

Now is the time for all good men to come to the aid of their party. To help one and other, and to help this great (or not so great -- whatever) nation of ours once and for all discourage the scourge of all that is unhold and plays no role in the hopes and dreams of men. And women too for all that matter!!! </br>

<img align="center" src="_GIFs/2.DeltaWing.gif" width="667">

This is what I want to say about DeltaWing #22222222222222. And a fine beast it is, no matter what you think of it and its kin, in life previous and left afterward. In other words, onward!!! <br/>

**3.DeltaWing.gif**
<br/>
DeltaWing/Smoothed/Randomized</br>

Now is the time for all good men to come to the aid of their party. To help one and other, and to help this great (or not so great -- whatever) nation of ours once and for all discourage the scourge of all that is unhold and plays no role in the hopes and dreams of men. And women too for all that matter!!!<br/>

<img align="center" src="_GIFs/4.DeltaWing.gif" width="667">


<!--
<img src="GIFs/LayersChooser(iPhone14).PNG" height="500">
->

<br/>

Here's a **`SuperEllipse`** `Shape` object with 6 vertices. The odd-numbered vertices are shown in red, the even-numbered one in blue. Just because.

When we calculate the coordinates of the vertices (a `[CGPoint]` array), we can also calculate the normal vector at each of the vertices.

This project is an exploration of how to animate a family of superellipse-based curves in SwiftUI. Actually it's a bit more general than that: the project shows how to animate between any superellipse-based curve, defined for our purposes as a `[CGPoint, CGVector]` array, where the `CGPoints` are the calculated vertices of the superellipse and the `CGVectors` are their corresponding normals, or orthogonals, and any secondary curve you can derive algorithmically from the first, eg using a simple mapping or transformation. 

`BezierBlobs` runs on both iPhone and the iPad. The user experience at present is better on iPad, due to some unresolved issues that occur when changing orientation between landscape and portrait on the phone. To be fixed (hopefully) ...

Enjoy!
