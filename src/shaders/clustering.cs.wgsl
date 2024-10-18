// DONE-2: implement the light clustering compute shader

// ------------------------------------
// Calculating cluster bounds:
// ------------------------------------
// For each cluster (X, Y, Z):
//     - Calculate the screen-space bounds for this cluster in 2D (XY).
//     - Calculate the depth bounds for this cluster in Z (near and far planes).
//     - Convert these screen and depth bounds into view-space coordinates.
//     - Store the computed bounding box (AABB) for the cluster.

// ------------------------------------
// Assigning lights to clusters:
// ------------------------------------
// For each cluster:
//     - Initialize a counter for the number of lights in this cluster.

//     For each light:
//         - Check if the light intersects with the cluster’s bounding box (AABB).
//         - If it does, add the light to the cluster's light list.
//         - Stop adding lights if the maximum number of lights is reached.

//     - Store the number of lights assigned to this cluster.
@group(${bindGroup_scene}) @binding(0) var<uniform> cameraUniforms: CameraUniforms;
@group(${bindGroup_scene}) @binding(1) var<storage, read> lightSet: LightSet;
@group(${bindGroup_scene}) @binding(2) var<storage, read_write> clusterSet: ClusterSet;

struct ClusterBounds {
    min: vec3f,
    max: vec3f
};

// Function to compute the AABB for a cluster in view space
fn computeClusterBounds(clusterIdx: u32) -> ClusterBounds {
    let clusterIdx_x: u32 = clusterIdx % clusterSet.clusterCountX;
    let clusterIdx_y: u32 = (clusterIdx / clusterSet.clusterCountX) % clusterSet.clusterCountY;
    let clusterIdx_z: u32 = clusterIdx / (clusterSet.clusterCountX * clusterSet.clusterCountY);

    // Calculate the screen-space (NDC) bounds for this cluster in 2D (XY)
    let ndc_cluster_width:  f32 = 2.0 / f32(clusterSet.clusterCountX);
    let ndc_cluster_height: f32 = 2.0 / f32(clusterSet.clusterCountY);
    let ndc_cluster_minX:   f32 = -1.0 + f32(clusterIdx_x) * ndc_cluster_width;
    let ndc_cluster_minY:   f32 = -1.0 + f32(clusterIdx_y) * ndc_cluster_height;
    let ndc_cluster_maxX:   f32 = ndc_cluster_minX + ndc_cluster_width;
    let ndc_cluster_maxY:   f32 = ndc_cluster_minY + ndc_cluster_height;

    // Transform XY bounds from screen-space (NDC) to view space
    let view_cluster_minX: f32 = cameraUniforms.invProjMat[0][0] * ndc_cluster_minX + cameraUniforms.invProjMat[3][0];
    let view_cluster_minY: f32 = cameraUniforms.invProjMat[1][1] * ndc_cluster_minY + cameraUniforms.invProjMat[3][1];
    let view_cluster_maxX: f32 = cameraUniforms.invProjMat[0][0] * ndc_cluster_maxX + cameraUniforms.invProjMat[3][0];
    let view_cluster_maxY: f32 = cameraUniforms.invProjMat[1][1] * ndc_cluster_maxY + cameraUniforms.invProjMat[3][1];

    // Calculate the ratio for the depth partitioning in view space
    let view_depth_step: f32 = pow(cameraUniforms.farPlane / cameraUniforms.nearPlane, 1.0 / f32(clusterSet.clusterCountZ));

    // Calculate view-space Z bounds for the current cluster
    let view_cluster_minZ: f32 = cameraUniforms.nearPlane * pow(view_depth_step, f32(clusterIdx_z));
    let view_cluster_maxZ: f32 = cameraUniforms.nearPlane * pow(view_depth_step, f32(clusterIdx_z + 1u));

    return ClusterBounds(vec3f(view_cluster_minX, view_cluster_minY, view_cluster_minZ), vec3f(view_cluster_maxX, view_cluster_maxY, view_cluster_maxZ));
}

// Function to check if a light (as a sphere) intersects a cluster's AABB
fn sphereIntersectsAABB(sphereCenter: vec3f, sphereRadius: f32, aabbMin: vec3f, aabbMax: vec3f) -> bool {
    let closestPoint = clamp(sphereCenter, aabbMin, aabbMax);
    let distance = length(sphereCenter - closestPoint);
    return distance <= sphereRadius;
}

@compute
@workgroup_size(${clusteringWorkgroupSize})
fn main(@builtin(global_invocation_id) globalIdx: vec3u) {
    let clusterIdx: u32 = globalIdx.x;
    if (clusterIdx >= clusterSet.clusterCount) {
        return;
    }

    // ------------------------------------
    // Compute the AABB for this cluster in view space
    // ------------------------------------
    let clusterBounds: ClusterBounds = computeClusterBounds(clusterIdx);
    let aabbMin: vec3f = clusterBounds.min;
    let aabbMax: vec3f = clusterBounds.max;

    // Store the computed bounding box (AABB) for the cluster
    clusterSet.clusters[clusterIdx].aabbMin = aabbMin;
    clusterSet.clusters[clusterIdx].aabbMax = aabbMax;

    // ------------------------------------
    // Assign lights to the current cluster
    // ------------------------------------

    // Initialize a counter for the number of lights in this cluster
    var cluster_lightCount: u32 = 0u;
    var cluster_lightIndices: array<u32, ${maxLightsPerCluster}> = array<u32, ${maxLightsPerCluster}>();

    // For each light
    for (var lightIdx: u32 = 0u; lightIdx < lightSet.numLights; lightIdx++) {
        let view_light_pos = cameraUniforms.viewMat * vec4f(lightSet.lights[lightIdx].pos, 1.0);

        // Check if the light intersects with the cluster’s bounding box (AABB)
        if (sphereIntersectsAABB(view_light_pos.xyz, ${lightRadius}, aabbMin, aabbMax)) {
            // Add this light to the cluster's light list if there is space
            if (cluster_lightCount < ${maxLightsPerCluster}) {
                cluster_lightIndices[cluster_lightCount] = lightIdx;
                cluster_lightCount++;
            } else {
                // Stop early if the cluster's light list is full
                break;
            }
        }
    }

    // Store the number of lights assigned to this cluster
    clusterSet.clusters[clusterIdx].lightCount = cluster_lightCount;

    // Update this cluster's light list
    if (cluster_lightCount > 0u) {
        for (var i: u32 = 0u; i < cluster_lightCount; i++) {
            clusterSet.clusters[clusterIdx].lightIndices[i] = cluster_lightIndices[i];
        }
    }
}