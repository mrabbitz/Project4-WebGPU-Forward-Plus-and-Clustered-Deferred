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
- **Forward (Naive)**
- **Clustered Forward**
- **Clustered Deferred**

### Rendering Methods Overview

#### Forward Rendering (Naive)
Forward Rendering is the standard, straightforward method commonly employed by rendering engines. In this pipeline, the GPU processes each object sequentially, converting them into fragments (pixels) while calculating lighting for every visible fragment from all lights in the scene. This approach can become inefficient as the number of lights increases, leading to redundant calculations for overlapping objects.

**Advantages:**
- **Simplicity:** Easy to implement and understand, ideal for simpler scenes.
- **Flexibility:** Supports diverse, high-quality shaders and effects for each object.

**Disadvantages:**
-**Overdraw:** Inefficient in scenes with overlapping objects, as it recalculates lighting for every fragment, wasting resources.
-**Lighting Performance:** Requires lighting calculations for every fragment of every object, resulting in exponential computational costs as the number of lights or objects increases.

#### Clustered Forward Rendering
Clustered Forward Rendering enhances the traditional forward method by organizing lights into 3D clusters based on their positions in view space. This technique allows the GPU to efficiently determine which lights affect each fragment, significantly reducing the number of lighting calculations required. As a result, it improves performance in complex scenes with a high density of lights.

**Advantages:**
- **Efficient Light Management:** Reduces the number of lights processed per fragment, improving performance in complex scenes.
- **Scalability:** Effectively handles increased light counts without significantly impacting performance.

**Disadvantages:**
- **Complexity:** More complex to implement than naive forward rendering, requiring additional data structures for clustering.
- **Memory Overhead:** Introduces some memory overhead for storing cluster information.

#### Clustered Deferred Rendering
Clustered Deferred Rendering combines the advantages of deferred rendering with clustered light management. In this approach, geometry is processed in one pass to create a G-buffer, followed by a separate lighting pass that calculates lighting only for the relevant fragments. This method optimizes rendering performance for scenes with many dynamic lights by minimizing overdraw and enabling efficient light calculations, regardless of scene complexity.

**Advantages:**
- **No Overdraw:** Calculates lighting only for visible pixels, processing each pixel once, regardless of object overlap.
- **Scalable:** Performance is primarily dependent on screen resolution and the number of lights, rather than the object count.

**Disadvantages:**
- **High Memory Usage:** The G-buffer requires significant memory bandwidth, which can be a bottleneck for lower-end GPUs.
- **Limited Flexibility:** Challenges in handling effects like transparency or custom shading due to pre-defined G-buffer data.
- **Complex Shaders:** Requires an "uber shader" for the lighting pass, which can become complex and harder to manage.


## References
- [WebGPU Samples - Deferred Rendering](https://webgpu.github.io/webgpu-samples/?sample=deferredRendering)

## Credits

- [Vite](https://vitejs.dev/)
- [loaders.gl](https://loaders.gl/)
- [dat.GUI](https://github.com/dataarts/dat.gui)
- [stats.js](https://github.com/mrdoob/stats.js)
- [wgpu-matrix](https://github.com/greggman/wgpu-matrix)
