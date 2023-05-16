Superellipses are great for this type of exploration for a number of reasons.

1) They're  interesting structures in their own right and can vary greatly in appearance, depending on the values of the several parameters that are passed in to our `model.calculateSuperEllipse() method.

2) One of those parameters, `numPoints`, stipulates the number of vertices to be plotting. This value can provide as coarse or as fine-grained an approximation of a hypothetically perfect superellipse as we like.

3) In addition to calculating a `CGPoint` for each vertex, we also calculate the orthogonal (or normal) at each point as a `CGVector`. Our model stores these as an array of tuples:

	`baseCurve = [(vertex: CGPoint, normal: CGVector)]`
	
	where `baseCurve` is the main defining curve for the SuperEllipse. Most other curves used in the animation are derived from this one.
  
Being able to derive and store the normal for each vertex allows us to slide our vertex markers in and out along them to  provide a variety of differing animation outcomes with very little code.  As one example, although we don't use it in this app, we can easily use our `baseCurve`'s normals to efficiently compute a secondary `offset` curve that shrinks or enlarges our SuperEllipse by any `offset` amount that we like:

	`secondaryCurve  = baseCurve.map{ $0.newPoint(at: offset: along: $1)}`
	
where `newPoint` is a `CGPoint` extension in which a positive offset moves our vertex outward from the superellipse (thus creating a larger superellipse) and a negative one moves it inward (thus creating a smaller one). The  `along: $1` argument is the `CGVector` normal we calculated for each `CGPoint` vertex in our initial baseCurve.
