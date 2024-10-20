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

## Part 2: Rendering Methods Overview

### Forward Rendering (Naive)
Forward Rendering is the standard method that most rendering engines use.
In this pipeline, the GPU processes each object (or geometry) sequentially.
Each object is projected, broken down into vertices, and transformed into fragments (pixels).
These fragments are fully shaded and processed one at a time to produce the final image.

**Advantages:**
- **Simplicity:** Easy to implement and understand, ideal for simpler scenes.
- **Flexibility:** Supports diverse, high-quality shaders and effects for each object.

**Disadvantages:**
- **Overdraw:** Inefficient in scenes with overlapping objects, as it recalculates lighting for every fragment, wasting resources.
- **High Lighting Cost:** Requires lighting calculations for every fragment, leading to exponential computational costs as the number of lights increases.

### Clustered Forward Rendering
Clustered Forward Rendering improves the traditional forward method by organizing lights into 3D clusters based on their positions in view space.
This technique allows the GPU to efficiently determine which lights affect each fragment, significantly reducing the number of lighting calculations needed.

**Advantages:**
- **Efficient Light Management:** Reduces the number of lights processed per fragment, enhancing performance in complex scenes with many lights.
- **Scalability:** Handles increased light counts effectively, maintaining performance.

**Disadvantages:**
- **Complexity:** More complex to implement than naive forward rendering, requiring additional data structures for clustering.
- **Memory Overhead:** Introduces some memory overhead for storing cluster information.

### Clustered Deferred Rendering
Clustered Deferred Rendering combines the advantages of deferred rendering with clustered light management.
In this approach, geometry is processed in one pass to create a G-buffer, followed by a separate lighting pass that calculates lighting only for the relevant fragments.
This method optimizes rendering performance for scenes with many dynamic lights by minimizing overdraw and enabling efficient light calculations.

**Advantages:**
- **No Overdraw:** Calculates lighting only for visible pixels, processing each pixel once, regardless of object overlap.
- **Scalability:** Performance depends primarily on screen resolution and the number of lights rather than the object count.

**Disadvantages:**
- **High Memory Usage:** The G-buffer requires significant memory bandwidth, which can be a bottleneck for lower-end GPUs.
- **Limited Flexibility:** Challenges in handling effects like transparency or custom shading due to pre-defined G-buffer data.
- **Complex Shaders:** Requires an "uber shader" for the lighting pass, which can become complex and harder to manage.

## Part 3: Performance Analysis
**Terms**
- Frames Per Second (FPS): the measurment of performance in this section. FPS is measured using [stats.js](https://github.com/mrdoob/stats.js).
- Max Lights Per Cluster (MLPC): represents the allocated buffer size for a given 3D cluster such that up to this number can be represented in a cluster. 
- Loss of Quality (LOQ): when the accurate representation of the scene is diminished.

### 3.1: FPS vs Scene Light Count
**Section 3.1 fixed variables: MLPC of 512**

![](img/fps_lightCount.png)

| Scene Light Count | Forward (Naive) FPS | Clusterd Forward FPS | Clustered Deferred FPS |
| ----------------- | ------------------- | -------------------- | ---------------------- |
| 500               | 13                  | 7                    | 35                     |
| 1,000             | 6                   | 6                    | 32                     |
| 1,500             | 4                   | 6                    | 31                     |
| 2,000             | 3                   | 6                    | 30                     |
| 2,500             | 2                   | 6                    | 29                     |
| 3,000             | 1                   | 6                    | 28                     |
| 3,500             | < 1                 | 5                    | 27                     |
| 4,000             | < 1                 | 5                    | 26                     |
| 4,500             | < 1                 | 5                    | 26                     |
| 5,000             | < 1                 | 5                    | 25                     |

### 3.2 FPS vs Max Lights Per Cluster (MLPC)
**Section 3.2 fixed variables: Scene Light Count of 2048**

![](img/fps_mlpc.png)


| MLPC | Clustered Deferred FPS | LOQ - Lighting | LOQ - Tiling |
| ---- | ---------------------- | -------------- | ------------ |
| 50   | 157                    | Y              | Y            |
| 100  | 78                     | Y              | Y            |
| 150  | 73                     | Maybe          | Y            |
| 200  | 64                     | N              | N            |
| 250  | 57                     | N              | N            |
| 300  | 52                     | N              | N            |
| 350  | 46                     | N              | N            |
| 400  | 40                     | N              | N            |
| 450  | 34                     | N              | N            |
| 500  | 30                     | N              | N            |

## References
- [WebGPU Samples - Deferred Rendering](https://webgpu.github.io/webgpu-samples/?sample=deferredRendering)

## Credits

- [Vite](https://vitejs.dev/)
- [loaders.gl](https://loaders.gl/)
- [dat.GUI](https://github.com/dataarts/dat.gui)
- [stats.js](https://github.com/mrdoob/stats.js)
- [wgpu-matrix](https://github.com/greggman/wgpu-matrix)
