WebGPU Forward, Clustered Forward, and Clustered Deferred Shading
======================

**University of Pennsylvania, CIS 5650: GPU Programming and Architecture, Project 4**

* Michael Rabbitz
  * [LinkedIn](https://www.linkedin.com/in/mike-rabbitz)
* Tested on: **Google Chrome 130.0** on Windows 10, i7-9750H @ 2.60GHz 32GB, RTX 2060 6GB (Personal)

## Live Demo
http://mrabbitz.github.io/Project4-WebGPU-Forward-Plus-and-Clustered-Deferred

**Your browser must support WebGPU** - check [here](https://webgpureport.org/)

**For a list of browsers and versions that do/don't support WebGPU** - check [here](https://caniuse.com/webgpu)

**You should also utilize your machine's high-performance GPU, if available**

## Demo GIF
**Note there is a loss of quality from GIF capture**
![](img/clustered_deferred.gif)

## Part 1: Introduction

This project explores multiple rendering techniques using WebGPU, focusing on how different methods handle varying numbers of lights, a key aspect of efficient scene rendering.
The goal is to compare and contrast the performance and implementation complexity of different approaches, particularly when scaling up the number of lights in a scene.

Three rendering methods are implemented:
- Forward (Naive)
- Clustered Forward
- Clustered Deferred

### Rendering Methods Overview

#### Forward vs Deferred Rendering
In modern rendering, Forward Rendering and Deferred Rendering are two common approaches used to handle scene lighting and shading.
Each has its strengths and weaknesses, depending on the complexity of the scene, especially in terms of how many lights need to be processed.

**Forward Rendering**

Forward rendering is the standard, out-of-the-box method that most rendering engines use. In this pipeline, the GPU processes each object (or geometry) one by one.
Each object is projected, broken down into vertices, and then transformed into fragments (pixels).
These fragments are fully shaded and processed, one at a time, to produce the final image that appears on the screen.

**Advantages:**
- **Simplicity:** Forward rendering is straightforward to implement and understand, making it suitable for simpler scenes and engines.
- **Flexibility:** Each object can use different, high-quality shaders and effects, without restrictions. Forward rendering allows for full per-object customization.

**Disadvantages:**
- **Overdraw:** Forward rendering can become inefficient in scenes where objects overlap, as it recalculates lighting and shading for each object even if only the top-most fragment (pixel) is visible. This redundancy wastes processing power.
- **Lighting performance:** Lighting calculations must be performed for every visible fragment of every object, and for every light in the scene. As the number of lights or objects increases, the computational cost grows exponentially.


**Deferred Rendering**

Deferred rendering takes a different approach by postponing (or deferring) the lighting calculations until after all objects have been processed. Instead of shading each object as it's rendered, deferred rendering separates the geometry and lighting stages into two passes:

1) **Geometry Pass (G-buffer Creation):** All objects are first rendered into several screen-sized buffers called the G-buffer. These buffers store per-pixel data like color, normals, depth (z-position), and other information needed for shading, but lighting is not calculated in this pass.
2) **Lighting Pass:** After the entire scene has been rendered into the G-buffer, lighting calculations are performed only for the visible pixels (fragments) in the final image. This process ensures that each pixel is shaded only once, regardless of how many objects overlap or how complex the scene is.

**Advantages:**
- **No Overdraw:** Deferred rendering eliminates overdraw by calculating lighting only for visible pixels. Even in scenes with overlapping objects, each pixel is processed only once.
- **Scalable with many lights:** The lighting calculations are decoupled from the number of objects, meaning the performance mainly depends on screen resolution and the number of lights.

**Disadvantages:**
- **High memory usage:** The G-buffer requires significant memory bandwidth, as it stores detailed data for every pixel. This can be a bottleneck for older or lower-end GPUs.
- **Limited flexibility:** Since the G-buffer stores pre-defined data like color, normals, and depth, it can be challenging to handle certain effects, such as transparency or custom shading techniques. Deferred rendering can struggle with effects like refractions or transparency that depend on information from multiple layers of geometry.
- **Complex shaders:** The lighting pass typically requires an "uber shader" that can handle all the various lighting and shading models for the scene, which can make the shader complex and harder to manage.



#### Naive, Tiled, and Clustered Techniques







## References
- [WebGPU Samples - Deferred Rendering](https://webgpu.github.io/webgpu-samples/?sample=deferredRendering)

## Credits

- [Vite](https://vitejs.dev/)
- [loaders.gl](https://loaders.gl/)
- [dat.GUI](https://github.com/dataarts/dat.gui)
- [stats.js](https://github.com/mrdoob/stats.js)
- [wgpu-matrix](https://github.com/greggman/wgpu-matrix)
