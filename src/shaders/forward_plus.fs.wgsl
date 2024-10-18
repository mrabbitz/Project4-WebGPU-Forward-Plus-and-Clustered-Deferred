// DONE-2: implement the Forward+ fragment shader

// See naive.fs.wgsl for basic fragment shader setup; this shader should use light clusters instead of looping over all lights

// ------------------------------------
// Shading process:
// ------------------------------------
// Determine which cluster contains the current fragment.
// Retrieve the number of lights that affect the current fragment from the cluster’s data.
// Initialize a variable to accumulate the total light contribution for the fragment.
// For each light in the cluster:
//     Access the light's properties using its index.
//     Calculate the contribution of the light based on its position, the fragment’s position, and the surface normal.
//     Add the calculated contribution to the total light accumulation.
// Multiply the fragment’s diffuse color by the accumulated light contribution.
// Return the final color, ensuring that the alpha component is set appropriately (typically to 1).
@group(${bindGroup_scene}) @binding(0) var<uniform> cameraUniforms: CameraUniforms;
@group(${bindGroup_scene}) @binding(1) var<storage, read> lightSet: LightSet;
@group(${bindGroup_scene}) @binding(2) var<storage, read> clusterSet: ClusterSet;

@group(${bindGroup_material}) @binding(0) var diffuseTex: texture_2d<f32>;
@group(${bindGroup_material}) @binding(1) var diffuseTexSampler: sampler;

const EPSILON = 1e-5;

struct FragmentInput
{
    @location(0) pos: vec3f,
    @location(1) nor: vec3f,
    @location(2) uv: vec2f
}

@fragment
fn main(in: FragmentInput) -> @location(0) vec4f
{
    let diffuseColor = textureSample(diffuseTex, diffuseTexSampler, in.uv);
    if (diffuseColor.a < 0.5f) {
        discard;
    }

    // Determine which cluster contains the current fragment
    let clip_pos = cameraUniforms.viewProjMat * vec4(in.pos, 1.0);
    let ndc_pos = clip_pos.xyz / clip_pos.w;
    var ndc_pos_0_1 = ndc_pos * 0.5 + 0.5;
    ndc_pos_0_1.x = clamp(ndc_pos_0_1.x, 0.0, 1.0 - EPSILON);
    ndc_pos_0_1.y = clamp(ndc_pos_0_1.y, 0.0, 1.0 - EPSILON);
    let clusterIdx_x = u32(floor(ndc_pos_0_1.x * f32(clusterSet.clusterCountX)));
    let clusterIdx_y = u32(floor(ndc_pos_0_1.y * f32(clusterSet.clusterCountY)));

    // Calculate the depth partition (Z cluster index)
    let view_pos = cameraUniforms.viewMat * vec4(in.pos, 1.0);
    let view_depth_step = pow(cameraUniforms.farPlane / cameraUniforms.nearPlane, 1.0 / f32(clusterSet.clusterCountZ));
    let view_depth_partition = u32(log(view_pos.z / cameraUniforms.nearPlane) / log(view_depth_step));

    // Compute the cluster index based on X, Y, and Z coordinates
    var clusterIdx = clusterIdx_x + 
                     clusterIdx_y * clusterSet.clusterCountX + 
                     view_depth_partition * clusterSet.clusterCountX * clusterSet.clusterCountY;
    
    clusterIdx = clamp(clusterIdx, 0u, clusterSet.clusterCount - 1u);

    // Get the cluster bounds (AABB) for the current cluster
    let cluster = clusterSet.clusters[clusterIdx];
    let aabbMin = cluster.aabbMin;
    let aabbMax = cluster.aabbMax;

    // Initialize total light contribution for the current fragment
    var totalLightContribution = vec3f(0, 0, 0);

    // Iterate over lights in the cluster
    let lightCount = cluster.lightCount;
    for (var i = 0u; i < lightCount; i++) {
        let lightIdx = cluster.lightIndices[i];
        let light = lightSet.lights[lightIdx];
        totalLightContribution += calculateLightContrib(light, in.pos, in.nor);
    }

    // Compute the final color by multiplying the diffuse color by the accumulated light contribution
    let finalColor = diffuseColor.rgb * totalLightContribution;
    return vec4(finalColor, 1.0);
}