*Everything you always wanted to know about superellipses, SwiftUI, animated blobby-like things, and the intersection thereof.*

This app does some fun SwiftUI stuff with superellipse `Shape` objects and animation. We can build a `SuperEllipse` shape using a parametric equation. We can approximate the SuperEllipse we're building with `numPoints` line segments; the more points, the smoother the final curve. Even with a fairly small number of points though, Catmull-Rom smoothing lets up smooth the curve even further.

In addition to calculating and storing an (x, y) `CGPoint` for every point on the circumference of the curve, we can also calculate a (dX, xy) `CGVector` unit vector representing the slope of the normal (or orthogonal) at each point. GIven the unit vector (dX, dY) at a particular point, we can easily move outward or inward from each point along its normal. Here's a bit of code that calculates a new point 100 pixels further out along the normal:




[MAKING TEST CHANGE 19SEPT22](what say you?)
[prior change was online; this is on my macbook]
and more online ...

## BezierBlobs

#### Delta Wing

The "Delta Wing" superellipse is built from just six vertices.

<img src="README-resources/1.DeltaWing.gif" width="900"/>

The stationary white dashed "baseCurve" in the background shows the six points calculated by [SEParametrics](BezierBlobs/SEParametrics.swift).

TEST TEST TEST

<img src="GIFs/5-1.gif" width="900"/>

#### Rorschach


Things get particularly interesting when `n` is less than 2.

<img src="README-resources/2.Rorschach.gif" width="900"/>

#### Markers moving magically!

<img src="README-resources/3.Circle-markers.gif" width="900"/>


This project is nominally a SwiftUI exploration of how to animate a family of curves based on superellipses. I use the word "nominally" because it's actually more general than that: the project shows how to animate between any curve, defined simply for our purposes as a `[CGPoint]` array, and any secondary curve you can derive algorithmically from the first one, eg using a simple mapping or similar transformation. This project demonstrates two different examples of this: 

a somewhat amorphous, blobby-type thing I've used as a user-interface element in past apps:




and an animation that shows two sets of vertex markers counter-rotating against each other along two circumferences of a circle:


`BezierBlobs` runs on both iPhone and the iPad. The user experience at present is somewhat better on iPad, due to some unresolved issues that occur when changing orientation between landscape and portrait on the phone. Hopefully to be fixed ...

I'm not accepting PR's but will try to respond to comments and suggestions at howardk@fatdog.com. Enjoy.

<img src = "https://github.com/howardck/BezierBlobs_README/blob/main/images/iPhoneSE Point Accurate [0.666].png" width="666" />

and a moving one ...

<img src = "https://github.com/howardck/BezierBlobs_README/blob/main/images/5-2.gif" />

<!-- Here's another example of an animated superellipse blob in action. It's from a short video of my *ABC Jump* game in action. You can see a [`BezierBlob` animation](http://fatdog.com/abcJump/video/NewGame_IPAD.mov) about twelve seconds in.
-->
