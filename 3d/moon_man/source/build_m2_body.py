from __future__ import annotations

import json
import math
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
RENDER_DIR = ROOT / "renders"
BLEND_PATH = ROOT / "source" / "MoonMan_M2_Body.blend"
METRICS_PATH = ROOT / "M2_metrics.json"
REFERENCE_PATH = ROOT / "reference" / "HomemLua_concept.png"

RENDER_DIR.mkdir(parents=True, exist_ok=True)


def clear_scene() -> None:
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    for collection in list(bpy.data.collections):
        bpy.data.collections.remove(collection)
    for datablocks in (
        bpy.data.meshes,
        bpy.data.curves,
        bpy.data.materials,
        bpy.data.cameras,
        bpy.data.lights,
    ):
        for datablock in list(datablocks):
            if datablock.users == 0:
                datablocks.remove(datablock)


def make_collection(name: str) -> bpy.types.Collection:
    collection = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(collection)
    return collection


def move_to_collection(obj: bpy.types.Object, collection: bpy.types.Collection) -> None:
    for current in list(obj.users_collection):
        current.objects.unlink(obj)
    collection.objects.link(obj)


def make_material(
    name: str,
    color: tuple[float, float, float, float],
    roughness: float,
    emission_color: tuple[float, float, float, float] | None = None,
    emission_strength: float = 0.0,
) -> bpy.types.Material:
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    shader = next(node for node in material.node_tree.nodes if node.type == "BSDF_PRINCIPLED")
    shader.inputs["Base Color"].default_value = color
    shader.inputs["Roughness"].default_value = roughness
    if emission_color is not None and "Emission Color" in shader.inputs:
        shader.inputs["Emission Color"].default_value = emission_color
        shader.inputs["Emission Strength"].default_value = emission_strength
    return material


def apply_material(obj: bpy.types.Object, material: bpy.types.Material) -> None:
    obj.data.materials.clear()
    obj.data.materials.append(material)


def smooth(obj: bpy.types.Object) -> None:
    if obj.type == "MESH":
        for polygon in obj.data.polygons:
            polygon.use_smooth = True


def ellipsoid(
    name: str,
    location: tuple[float, float, float],
    scale: tuple[float, float, float],
    material: bpy.types.Material,
    collection: bpy.types.Collection,
    segments: int = 24,
    rings: int = 14,
    rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=segments,
        ring_count=rings,
        location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    apply_material(obj, material)
    smooth(obj)
    move_to_collection(obj, collection)
    return obj


def tube_segment(
    name: str,
    points: list[tuple[float, float, float]],
    radii: list[tuple[float, float]],
    material: bpy.types.Material,
    collection: bpy.types.Collection,
    sides: int = 16,
) -> bpy.types.Object:
    if len(points) != len(radii):
        raise ValueError("points and radii must have matching lengths")
    vertices: list[tuple[float, float, float]] = []
    faces: list[tuple[int, ...]] = []
    for point, radius in zip(points, radii):
        px, py, pz = point
        rx, ry = radius
        for index in range(sides):
            angle = math.tau * index / sides
            vertices.append((px + math.cos(angle) * rx, py + math.sin(angle) * ry, pz))
    for ring in range(len(points) - 1):
        start = ring * sides
        nxt = (ring + 1) * sides
        for index in range(sides):
            following = (index + 1) % sides
            faces.append((start + index, start + following, nxt + following, nxt + index))
    faces.append(tuple(reversed(range(sides))))
    last = (len(points) - 1) * sides
    faces.append(tuple(last + index for index in range(sides)))
    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    collection.objects.link(obj)
    apply_material(obj, material)
    smooth(obj)
    obj.data.polygons[-2].use_smooth = False
    obj.data.polygons[-1].use_smooth = False
    return obj


def torso_mesh(material: bpy.types.Material, collection: bpy.types.Collection) -> bpy.types.Object:
    # Ring profile remains narrow and nearly tubular. The Y offsets produce the
    # approved forward-observing posture without an extreme hunch.
    profile = [
        (5.05, 0.00, 0.48, 0.33),
        (5.45, -0.02, 0.57, 0.36),
        (6.05, -0.08, 0.50, 0.32),
        (6.75, -0.16, 0.51, 0.33),
        (7.45, -0.26, 0.62, 0.38),
        (8.05, -0.36, 0.73, 0.42),
        (8.48, -0.42, 0.62, 0.38),
        (8.96, -0.47, 0.36, 0.28),
    ]
    sides = 32
    vertices: list[tuple[float, float, float]] = []
    faces: list[tuple[int, ...]] = []
    for z, y, rx, ry in profile:
        for index in range(sides):
            angle = math.tau * index / sides
            vertices.append((math.cos(angle) * rx, y + math.sin(angle) * ry, z))
    for ring in range(len(profile) - 1):
        start = ring * sides
        nxt = (ring + 1) * sides
        for index in range(sides):
            following = (index + 1) % sides
            faces.append((start + index, start + following, nxt + following, nxt + index))
    faces.append(tuple(reversed(range(sides))))
    last = (len(profile) - 1) * sides
    faces.append(tuple(last + index for index in range(sides)))
    mesh = bpy.data.meshes.new("MoonMan_M2_Torso_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new("MoonMan_M2_Torso", mesh)
    collection.objects.link(obj)
    apply_material(obj, material)
    smooth(obj)
    obj.data.polygons[-2].use_smooth = False
    obj.data.polygons[-1].use_smooth = False
    return obj


def finger(
    side: str,
    label: str,
    points: list[tuple[float, float, float]],
    base_radius: float,
    material: bpy.types.Material,
    collection: bpy.types.Collection,
) -> list[bpy.types.Object]:
    result: list[bpy.types.Object] = []
    for index in range(len(points) - 1):
        radius_a = base_radius * (1.0 - index * 0.12)
        radius_b = base_radius * (0.82 - index * 0.12)
        start = Vector(points[index])
        end = Vector(points[index + 1])
        middle = start.lerp(end, 0.5)
        bend = Vector((0.0, -0.018, 0.0))
        result.append(
            tube_segment(
                f"MoonMan_M2_{side}_{label}_{index + 1:02d}",
                [tuple(start), tuple(middle + bend), tuple(end)],
                [(radius_a, radius_a * 0.78), ((radius_a + radius_b) * 0.5, (radius_a + radius_b) * 0.39), (radius_b, radius_b * 0.78)],
                material,
                collection,
                sides=10,
            )
        )
    return result


def create_hand(
    sign: float,
    material: bpy.types.Material,
    collection: bpy.types.Collection,
) -> list[bpy.types.Object]:
    side = "Right" if sign > 0 else "Left"
    cx = 1.37 * sign
    palm = ellipsoid(
        f"MoonMan_M2_{side}_Palm",
        (cx, -0.56, 3.50),
        (0.30, 0.20, 0.50),
        material,
        collection,
        segments=24,
        rings=14,
        rotation=(math.radians(-3), 0.0, math.radians(2.5 * sign)),
    )
    objects = [palm]
    offsets = {
        "Index": (-0.16, 0.92, 0.072),
        "Middle": (-0.05, 1.04, 0.076),
        "Ring": (0.07, 0.97, 0.071),
        "Pinky": (0.18, 0.80, 0.062),
    }
    for label, (raw_x, length, radius) in offsets.items():
        x = cx + raw_x * sign
        start = (x, -0.57, 3.18)
        mid = (x + 0.015 * sign, -0.59, 3.18 - length * 0.52)
        end = (x + 0.025 * sign, -0.61, 3.18 - length)
        objects.extend(finger(side, label, [start, mid, end], radius, material, collection))
    thumb_start = (cx + 0.27 * sign, -0.55, 3.56)
    thumb_mid = (cx + 0.43 * sign, -0.59, 3.28)
    thumb_end = (cx + 0.48 * sign, -0.61, 3.02)
    objects.extend(finger(side, "Thumb", [thumb_start, thumb_mid, thumb_end], 0.085, material, collection))
    return objects


def create_foot(
    sign: float,
    material: bpy.types.Material,
    collection: bpy.types.Collection,
) -> bpy.types.Object:
    side = "Right" if sign > 0 else "Left"
    profile = [
        (0.35, 0.20, 0.34, 0.54),
        (0.02, 0.02, 0.35, 0.55),
        (-0.48, 0.00, 0.37, 0.42),
        (-0.95, 0.00, 0.39, 0.30),
        (-1.22, 0.04, 0.27, 0.22),
    ]
    sides = 16
    cx = 0.56 * sign
    vertices: list[tuple[float, float, float]] = []
    faces: list[tuple[int, ...]] = []
    for y, z_bottom, half_width, z_top in profile:
        center_z = (z_bottom + z_top) * 0.5
        rz = (z_top - z_bottom) * 0.5
        for index in range(sides):
            angle = math.tau * index / sides
            vertices.append((cx + math.cos(angle) * half_width, y, center_z + math.sin(angle) * rz))
    for ring in range(len(profile) - 1):
        start = ring * sides
        nxt = (ring + 1) * sides
        for index in range(sides):
            following = (index + 1) % sides
            faces.append((start + index, start + following, nxt + following, nxt + index))
    faces.append(tuple(reversed(range(sides))))
    last = (len(profile) - 1) * sides
    faces.append(tuple(last + index for index in range(sides)))
    mesh = bpy.data.meshes.new(f"MoonMan_M2_{side}_Foot_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(f"MoonMan_M2_{side}_Foot", mesh)
    collection.objects.link(obj)
    apply_material(obj, material)
    smooth(obj)
    bevel = obj.modifiers.new("M2_FootSoftness", "BEVEL")
    bevel.width = 0.055
    bevel.segments = 3
    return obj


def create_body(
    collection: bpy.types.Collection,
    body_material: bpy.types.Material,
    head_material: bpy.types.Material,
) -> list[bpy.types.Object]:
    objects: list[bpy.types.Object] = []
    objects.append(torso_mesh(body_material, collection))
    objects.append(ellipsoid("MoonMan_M2_Pelvis", (0.0, 0.0, 5.18), (0.56, 0.36, 0.55), body_material, collection))

    # Head is 6% smaller than the approved M1 sphere. Its top remains at
    # approximately 11.5 studs; the neck is deliberately short and nearly hidden.
    objects.append(ellipsoid("MoonMan_M2_Neck", (0.0, -0.50, 9.13), (0.27, 0.24, 0.17), body_material, collection, 20, 12))
    objects.append(ellipsoid("MoonMan_M2_Head_Placeholder", (0.0, -0.62, 10.40), (1.10, 0.96, 1.10), head_material, collection, 32, 20))

    for sign, side in ((-1.0, "Left"), (1.0, "Right")):
        shoulder = (0.70 * sign, -0.39, 8.18)
        elbow = (1.18 * sign, -0.48, 6.02)
        wrist = (1.34 * sign, -0.55, 3.92)
        objects.append(ellipsoid(f"MoonMan_M2_{side}_Shoulder", shoulder, (0.27, 0.25, 0.30), body_material, collection, 20, 12))
        objects.append(tube_segment(
            f"MoonMan_M2_{side}_UpperArm",
            [shoulder, (0.91 * sign, -0.43, 7.24), elbow],
            [(0.25, 0.23), (0.235, 0.215), (0.22, 0.20)],
            body_material,
            collection,
        ))
        objects.append(ellipsoid(f"MoonMan_M2_{side}_Elbow", elbow, (0.23, 0.21, 0.25), body_material, collection, 18, 10))
        objects.append(tube_segment(
            f"MoonMan_M2_{side}_Forearm",
            [elbow, (1.29 * sign, -0.52, 4.93), wrist],
            [(0.22, 0.20), (0.20, 0.18), (0.17, 0.16)],
            body_material,
            collection,
        ))
        objects.extend(create_hand(sign, body_material, collection))

        hip = (0.43 * sign, 0.00, 5.16)
        knee = (0.54 * sign, -0.06, 2.96)
        ankle = (0.56 * sign, -0.10, 0.58)
        objects.append(tube_segment(
            f"MoonMan_M2_{side}_UpperLeg",
            [hip, (0.49 * sign, -0.02, 4.15), knee],
            [(0.31, 0.29), (0.285, 0.265), (0.25, 0.235)],
            body_material,
            collection,
            sides=18,
        ))
        objects.append(ellipsoid(f"MoonMan_M2_{side}_Knee", knee, (0.255, 0.235, 0.27), body_material, collection, 18, 10))
        objects.append(tube_segment(
            f"MoonMan_M2_{side}_LowerLeg",
            [knee, (0.56 * sign, -0.08, 1.75), ankle],
            [(0.245, 0.225), (0.22, 0.20), (0.19, 0.18)],
            body_material,
            collection,
            sides=18,
        ))
        objects.append(create_foot(sign, body_material, collection))

    root = bpy.data.objects.new("MoonMan_M2_ROOT", None)
    root.empty_display_type = "PLAIN_AXES"
    root.empty_display_size = 0.8
    collection.objects.link(root)
    root["stage"] = "M2_BODY_REFINEMENT"
    root["m1_approved"] = True
    root["head_scale_change_percent"] = -6.0
    root["target_height_studs"] = 11.5
    root["has_detailed_head"] = False
    root["has_final_textures"] = False
    root["has_rig"] = False
    return objects


def cube(
    name: str,
    location: tuple[float, float, float],
    dimensions: tuple[float, float, float],
    material: bpy.types.Material,
    collection: bpy.types.Collection,
    bevel: float = 0.0,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    apply_material(obj, material)
    if bevel:
        modifier = obj.modifiers.new("R6_Bevel", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
    move_to_collection(obj, collection)
    return obj


def create_r6(collection: bpy.types.Collection, material: bpy.types.Material) -> list[bpy.types.Object]:
    x = 3.2
    parts = [
        cube("M2_R6_Torso", (x, 0.0, 3.45), (2.0, 1.0, 2.0), material, collection, 0.08),
        cube("M2_R6_Head", (x, 0.0, 4.95), (1.75, 1.15, 1.0), material, collection, 0.10),
        cube("M2_R6_LeftArm", (x - 1.5, 0.0, 3.45), (1.0, 1.0, 2.0), material, collection, 0.08),
        cube("M2_R6_RightArm", (x + 1.5, 0.0, 3.45), (1.0, 1.0, 2.0), material, collection, 0.08),
        cube("M2_R6_LeftLeg", (x - 0.5, 0.0, 1.45), (1.0, 1.0, 2.0), material, collection, 0.08),
        cube("M2_R6_RightLeg", (x + 0.5, 0.0, 1.45), (1.0, 1.0, 2.0), material, collection, 0.08),
    ]
    return parts


def create_reference(collection: bpy.types.Collection) -> None:
    if not REFERENCE_PATH.exists():
        return
    image = bpy.data.images.load(str(REFERENCE_PATH), check_existing=True)
    try:
        image.pack()
    except RuntimeError:
        pass
    bpy.ops.object.empty_add(type="IMAGE", location=(-5.5, 2.5, 6.0), rotation=(math.radians(90), 0.0, 0.0))
    obj = bpy.context.object
    obj.name = "M2_Concept_Reference"
    obj.data = image
    obj.empty_display_size = 5.0
    obj.hide_render = True
    move_to_collection(obj, collection)


def look_at(obj: bpy.types.Object, target: tuple[float, float, float]) -> None:
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def create_camera(collection: bpy.types.Collection) -> bpy.types.Object:
    data = bpy.data.cameras.new("M2_Presentation_Camera_Data")
    camera = bpy.data.objects.new("M2_Presentation_Camera", data)
    collection.objects.link(camera)
    data.type = "ORTHO"
    data.ortho_scale = 12.7
    bpy.context.scene.camera = camera
    return camera


def create_light(
    name: str,
    light_type: str,
    location: tuple[float, float, float],
    energy: float,
    color: tuple[float, float, float],
    collection: bpy.types.Collection,
) -> bpy.types.Object:
    data = bpy.data.lights.new(f"{name}_Data", type=light_type)
    data.energy = energy
    data.color = color
    light = bpy.data.objects.new(name, data)
    light.location = location
    collection.objects.link(light)
    return light


def render_scene(
    filename: str,
    camera: bpy.types.Object,
    location: tuple[float, float, float],
    target: tuple[float, float, float],
    ortho_scale: float,
    resolution: tuple[int, int],
) -> None:
    scene = bpy.context.scene
    camera.location = location
    camera.data.ortho_scale = ortho_scale
    look_at(camera, target)
    scene.render.resolution_x, scene.render.resolution_y = resolution
    scene.render.filepath = str(RENDER_DIR / filename)
    bpy.ops.render.render(write_still=True)


def set_collection_render(collection: bpy.types.Collection, visible: bool) -> None:
    collection.hide_render = not visible
    for obj in collection.all_objects:
        obj.hide_render = not visible


def set_world(color: tuple[float, float, float, float], strength: float) -> None:
    world = bpy.context.scene.world
    world.use_nodes = True
    background = next(node for node in world.node_tree.nodes if node.type == "BACKGROUND")
    background.inputs["Color"].default_value = color
    background.inputs["Strength"].default_value = strength


clear_scene()

scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE"
scene.render.image_settings.file_format = "PNG"
scene.render.film_transparent = False
scene.render.resolution_percentage = 100
scene.render.image_settings.color_mode = "RGBA"
scene.render.image_settings.color_depth = "8"
scene.render.resolution_x = 640
scene.render.resolution_y = 760
scene.render.resolution_percentage = 100
scene.view_settings.look = "AgX - Medium High Contrast"
set_world((0.012, 0.015, 0.022, 1.0), 0.35)

model_collection = make_collection("M2_MOON_MAN_BODY")
r6_collection = make_collection("M2_R6_SCALE_REFERENCE")
reference_collection = make_collection("M2_REFERENCE")
stage_collection = make_collection("M2_PRESENTATION")
environment_collection = make_collection("M2_DARK_TEST")

body_material = make_material("MAT_MoonMan_Body_M2", (0.009, 0.011, 0.015, 1.0), 0.88)
head_material = make_material(
    "MAT_MoonMan_Head_Placeholder_M2",
    (0.54, 0.36, 0.16, 1.0),
    0.72,
    (0.95, 0.56, 0.20, 1.0),
    0.32,
)
r6_material = make_material("MAT_M2_R6", (0.38, 0.42, 0.48, 1.0), 0.68)
stage_material = make_material("MAT_M2_Stage", (0.045, 0.052, 0.065, 1.0), 0.92)
tree_material = make_material("MAT_M2_DarkEnvironment", (0.008, 0.011, 0.013, 1.0), 0.96)
silhouette_material = make_material("MAT_M2_Silhouette", (0.0002, 0.0002, 0.0002, 1.0), 1.0)

body_objects = create_body(model_collection, body_material, head_material)
r6_objects = create_r6(r6_collection, r6_material)
create_reference(reference_collection)

ground = cube("M2_Ground", (0.0, 0.0, -0.13), (24.0, 24.0, 0.25), stage_material, stage_collection)
camera = create_camera(stage_collection)
key = create_light("M2_Key", "AREA", (-5.0, -7.0, 12.0), 1050.0, (1.0, 0.78, 0.58), stage_collection)
key.data.shape = "DISK"
key.data.size = 5.0
look_at(key, (0.0, 0.0, 6.0))
fill = create_light("M2_Fill", "AREA", (5.0, -4.0, 8.0), 700.0, (0.35, 0.50, 0.82), stage_collection)
fill.data.size = 4.0
look_at(fill, (0.0, 0.0, 5.8))
rim = create_light("M2_Rim", "AREA", (0.0, 4.5, 10.0), 900.0, (0.42, 0.55, 1.0), stage_collection)
rim.data.size = 3.0
look_at(rim, (0.0, 0.0, 6.5))

# Lightweight dark-test masses only; they are not part of the game map.
for index, x in enumerate((-5.2, -3.7, 3.9, 5.3)):
    trunk = cube(f"M2_DarkTree_{index + 1}", (x, 2.2 + abs(x) * 0.12, 4.5), (0.55, 0.55, 9.0), tree_material, environment_collection, 0.14)
    trunk.rotation_euler[1] = math.radians((index - 1.5) * 2.0)
for index, x in enumerate((-2.5, 2.7)):
    cube(f"M2_DarkRock_{index + 1}", (x, 1.4, 2.0), (2.0, 1.8, 4.0), tree_material, environment_collection, 0.35)

flashlight = create_light("M2_Flashlight", "SPOT", (0.0, -10.0, 4.8), 3600.0, (0.55, 0.68, 1.0), environment_collection)
flashlight.data.spot_size = math.radians(26.0)
flashlight.data.spot_blend = 0.40
flashlight.data.shadow_soft_size = 0.24
look_at(flashlight, (0.0, -0.25, 5.6))
head_glow = create_light("M2_HeadGlow", "POINT", (0.0, -0.64, 10.4), 28.0, (1.0, 0.55, 0.18), environment_collection)
head_glow.data.shadow_soft_size = 1.0

set_collection_render(r6_collection, False)
set_collection_render(reference_collection, False)
set_collection_render(environment_collection, False)

render_scene("M2_01_front.png", camera, (0.0, -22.0, 5.75), (0.0, -0.15, 5.75), 12.4, (640, 760))
render_scene("M2_02_side.png", camera, (20.0, 0.0, 5.75), (0.0, -0.15, 5.75), 12.4, (640, 760))
render_scene("M2_03_back.png", camera, (0.0, 22.0, 5.75), (0.0, -0.15, 5.75), 12.4, (640, 760))
camera.data.type = "ORTHO"
render_scene("M2_04_three_quarter.png", camera, (10.5, -18.0, 7.0), (0.0, -0.10, 5.75), 12.8, (700, 760))

scene.view_layers[0].material_override = silhouette_material
set_world((0.30, 0.30, 0.30, 1.0), 0.8)
camera.data.type = "ORTHO"
render_scene("M2_05_silhouette.png", camera, (0.0, -22.0, 5.75), (0.0, -0.15, 5.75), 12.4, (640, 760))
scene.view_layers[0].material_override = None
set_world((0.012, 0.015, 0.022, 1.0), 0.35)

camera.data.type = "PERSP"
camera.data.lens = 72.0
render_scene("M2_06_hands_close.png", camera, (4.8, -10.5, 4.4), (0.0, -0.52, 3.25), 5.5, (900, 650))

set_collection_render(r6_collection, True)
camera.data.type = "ORTHO"
render_scene("M2_07_r6_comparison.png", camera, (1.2, -24.0, 5.75), (1.2, -0.10, 5.75), 13.0, (820, 760))
set_collection_render(r6_collection, False)

set_collection_render(environment_collection, True)
key.hide_render = True
fill.hide_render = True
rim.hide_render = True
set_world((0.0005, 0.001, 0.002, 1.0), 0.12)
camera.data.type = "PERSP"
camera.data.lens = 52.0
render_scene("M2_08_dark_test.png", camera, (9.0, -20.0, 6.8), (0.0, -0.10, 5.8), 13.2, (820, 760))

# Restore a useful inspection state before saving.
key.hide_render = False
fill.hide_render = False
rim.hide_render = False
set_collection_render(environment_collection, False)
set_collection_render(r6_collection, False)
set_world((0.012, 0.015, 0.022, 1.0), 0.35)
camera.data.type = "ORTHO"
camera.location = (0.0, -22.0, 5.75)
camera.data.ortho_scale = 12.4
look_at(camera, (0.0, -0.15, 5.75))

for obj in body_objects:
    obj.hide_set(False)
for obj in r6_objects:
    obj.hide_set(True)
for obj in environment_collection.objects:
    obj.hide_set(True)
reference_collection.hide_viewport = True

mesh_objects = [obj for obj in body_objects if obj.type == "MESH"]
depsgraph = bpy.context.evaluated_depsgraph_get()
triangles = 0
for obj in mesh_objects:
    evaluated = obj.evaluated_get(depsgraph)
    mesh = evaluated.to_mesh()
    mesh.calc_loop_triangles()
    triangles += len(mesh.loop_triangles)
    evaluated.to_mesh_clear()

minimum_z = min((obj.matrix_world @ Vector(corner)).z for obj in mesh_objects for corner in obj.bound_box)
maximum_z = max((obj.matrix_world @ Vector(corner)).z for obj in mesh_objects for corner in obj.bound_box)
metrics = {
    "stage": "M2_BODY_REFINEMENT",
    "m1_approved": True,
    "total_height_studs": round(maximum_z - minimum_z, 3),
    "head_reduction_percent": 6.0,
    "head_diameter_studs": 2.2,
    "neck_visible_height_studs": 0.34,
    "approx_triangle_count": triangles,
    "mesh_objects": len(mesh_objects),
    "finger_meshes": len([obj for obj in mesh_objects if any(label in obj.name for label in ("Thumb", "Index", "Middle", "Ring", "Pinky"))]),
    "rig": False,
    "bones": 0,
    "detailed_face": False,
    "final_uv": False,
    "final_textures": False,
    "renders": [
        "M2_01_front.png",
        "M2_02_side.png",
        "M2_03_back.png",
        "M2_04_three_quarter.png",
        "M2_05_silhouette.png",
        "M2_06_hands_close.png",
        "M2_07_r6_comparison.png",
        "M2_08_dark_test.png",
    ],
}
METRICS_PATH.write_text(json.dumps(metrics, indent=2), encoding="utf-8")

bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH))

# Put the live viewport in a clean front view.
bpy.ops.object.select_all(action="DESELECT")
for obj in mesh_objects:
    obj.select_set(True)
if mesh_objects:
    bpy.context.view_layer.objects.active = mesh_objects[0]
for window in bpy.context.window_manager.windows:
    for area in window.screen.areas:
        if area.type != "VIEW_3D":
            continue
        region = next((item for item in area.regions if item.type == "WINDOW"), None)
        if region is None:
            continue
        space = area.spaces.active
        space.overlay.show_extras = False
        with bpy.context.temp_override(window=window, area=area, region=region, space_data=space):
            bpy.ops.view3d.view_axis(type="FRONT", align_active=False)
            bpy.ops.view3d.view_selected(use_all_regions=False)

print("M2_COMPLETE", json.dumps(metrics))
