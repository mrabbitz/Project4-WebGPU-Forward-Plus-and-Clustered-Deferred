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

Forward rendering is the default method, where each object in the scene is drawn one by one, and lighting is calculated per object using shaders.
Every object is rendered directly to the screen, and all the necessary lighting and shading calculations are done in a single pass.

**Advantages:**

- **Simplicity:** Forward rendering is straightforward to implement and understand.

- **Flexibility:** Allows for full-quality shaders and effects to be applied to each object, with no restriction on the type or complexity of shaders used.

**Disadvantages:**

- **Overdraw:** One of the biggest drawbacks is overdraw, where multiple objects get drawn on top of each other. Each time an overlapping object is drawn, the GPU re-runs the expensive lighting and shading calculations, even though only the top-most pixel is visible. This becomes inefficient, especially in scenes with many overlapping objects.

- **Lighting performance:** As the number of lights in the scene increases, the performance can degrade significantly because every light needs to be calculated per object.


**Deferred Rendering**

Deferred rendering addresses some of the inefficiencies of forward rendering, particularly overdraw, by splitting the rendering process into two major passes:

**Geometry Pass (G-buffer Creation):** In the first pass, instead of calculating the final shaded output for each object immediately, the renderer outputs basic scene information - such as pixel color, normals, depth (z-position), and other data - into a set of screen-sized buffers called the G-buffer.

**Lighting Pass:** Once the scene's geometry has been processed into the G-buffer, the second pass uses this data to calculate lighting only for the pixels that are visible on the screen. Each pixel’s final lighting is processed exactly once, regardless of how many objects overlap in that pixel.

**Advantages:**

- **No Overdraw:** Deferred rendering eliminates the issue of overdraw. Since lighting calculations are only done in the lighting pass, the GPU doesn’t waste time on objects that are hidden behind others.

- **Scalable with many lights:** Deferred rendering is well-suited for scenes with many lights, as the cost of processing lights is decoupled from the number of objects in the scene. Lights only affect the pixels they overlap in screen space.

**Disadvantages:**

- **High memory usage:** The G-buffer requires a large amount of memory since it stores detailed information for every pixel in the scene. This can be especially demanding on memory bandwidth and can be a bottleneck on lower-end GPUs.

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
