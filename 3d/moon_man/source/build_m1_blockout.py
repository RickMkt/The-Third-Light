from __future__ import annotations

import json
import math
import os
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
RENDER_DIR = ROOT / "renders"
REFERENCE_PATH = ROOT / "reference" / "HomemLua_concept.png"
BLEND_PATH = ROOT / "source" / "MoonMan_M1_Blockout.blend"
METRICS_PATH = ROOT / "M1_metrics.json"

RENDER_DIR.mkdir(parents=True, exist_ok=True)


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials, bpy.data.cameras, bpy.data.lights):
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
    roughness: float = 0.75,
    metallic: float = 0.0,
    emission: tuple[float, float, float, float] | None = None,
    emission_strength: float = 0.0,
) -> bpy.types.Material:
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = color
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if emission is not None and "Emission Color" in shader.inputs:
        shader.inputs["Emission Color"].default_value = emission
        shader.inputs["Emission Strength"].default_value = emission_strength
    return material


def apply_material(obj: bpy.types.Object, material: bpy.types.Material) -> None:
    obj.data.materials.clear()
    obj.data.materials.append(material)


def smooth(obj: bpy.types.Object) -> None:
    if obj.type != "MESH":
        return
    for polygon in obj.data.polygons:
        polygon.use_smooth = True


def ellipsoid(
    name: str,
    location: tuple[float, float, float],
    scale: tuple[float, float, float],
    material: bpy.types.Material,
    collection: bpy.types.Collection,
    segments: int = 16,
    rings: int = 10,
    rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    apply_material(obj, material)
    smooth(obj)
    move_to_collection(obj, collection)
    return obj


def segment(
    name: str,
    start: tuple[float, float, float],
    end: tuple[float, float, float],
    radius_x: float,
    radius_y: float,
    material: bpy.types.Material,
    collection: bpy.types.Collection,
    segments: int = 14,
    rings: int = 8,
) -> bpy.types.Object:
    start_v = Vector(start)
    end_v = Vector(end)
    direction = end_v - start_v
    obj = ellipsoid(
        name,
        tuple((start_v + end_v) * 0.5),
        (radius_x, radius_y, direction.length * 0.54),
        material,
        collection,
        segments=segments,
        rings=rings,
    )
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0.0, 0.0, 1.0)).rotation_difference(direction.normalized())
    obj.rotation_mode = "XYZ"
    return obj


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
    if bevel > 0:
        modifier = obj.modifiers.new("Blockout_Bevel", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
    apply_material(obj, material)
    move_to_collection(obj, collection)
    return obj


def cylinder(
    name: str,
    location: tuple[float, float, float],
    radius: float,
    depth: float,
    material: bpy.types.Material,
    collection: bpy.types.Collection,
    vertices: int = 12,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location)
    obj = bpy.context.object
    obj.name = name
    apply_material(obj, material)
    move_to_collection(obj, collection)
    return obj


def create_moon_man(collection: bpy.types.Collection, body_mat: bpy.types.Material, head_mat: bpy.types.Material) -> dict[str, bpy.types.Object]:
    objects: dict[str, bpy.types.Object] = {}

    # 11.6-stud target. The segmented construction keeps future joints readable
    # without introducing a rig during M1.
    objects["pelvis"] = ellipsoid("MoonMan_Pelvis", (0.0, 0.02, 5.22), (0.54, 0.36, 0.62), body_mat, collection)
    objects["abdomen"] = ellipsoid("MoonMan_Abdomen", (0.0, -0.10, 6.28), (0.52, 0.34, 1.18), body_mat, collection)
    objects["chest"] = ellipsoid("MoonMan_Chest", (0.0, -0.28, 7.48), (0.73, 0.40, 1.14), body_mat, collection)
    objects["neck"] = ellipsoid("MoonMan_Neck", (0.0, -0.50, 8.88), (0.32, 0.30, 0.42), body_mat, collection, segments=14, rings=8)
    objects["head"] = ellipsoid("MoonMan_Head", (0.0, -0.69, 10.32), (1.17, 1.02, 1.17), head_mat, collection, segments=32, rings=18)

    hip_l = (-0.46, 0.03, 5.14)
    hip_r = (0.46, 0.03, 5.14)
    knee_l = (-0.56, -0.02, 2.96)
    knee_r = (0.56, -0.02, 2.96)
    ankle_l = (-0.58, -0.12, 0.55)
    ankle_r = (0.58, -0.12, 0.55)

    objects["left_upper_leg"] = segment("MoonMan_LeftUpperLeg", hip_l, knee_l, 0.31, 0.29, body_mat, collection)
    objects["right_upper_leg"] = segment("MoonMan_RightUpperLeg", hip_r, knee_r, 0.31, 0.29, body_mat, collection)
    objects["left_lower_leg"] = segment("MoonMan_LeftLowerLeg", knee_l, ankle_l, 0.25, 0.23, body_mat, collection)
    objects["right_lower_leg"] = segment("MoonMan_RightLowerLeg", knee_r, ankle_r, 0.25, 0.23, body_mat, collection)
    objects["left_foot"] = ellipsoid("MoonMan_LeftFoot", (-0.58, -0.40, 0.31), (0.33, 0.80, 0.28), body_mat, collection, rotation=(math.radians(4), 0.0, 0.0))
    objects["right_foot"] = ellipsoid("MoonMan_RightFoot", (0.58, -0.40, 0.31), (0.33, 0.80, 0.28), body_mat, collection, rotation=(math.radians(4), 0.0, 0.0))

    shoulder_l = (-0.76, -0.30, 8.03)
    shoulder_r = (0.76, -0.30, 8.03)
    elbow_l = (-1.18, -0.42, 5.96)
    elbow_r = (1.18, -0.42, 5.96)
    wrist_l = (-1.31, -0.57, 3.83)
    wrist_r = (1.31, -0.57, 3.83)

    objects["left_upper_arm"] = segment("MoonMan_LeftUpperArm", shoulder_l, elbow_l, 0.27, 0.25, body_mat, collection)
    objects["right_upper_arm"] = segment("MoonMan_RightUpperArm", shoulder_r, elbow_r, 0.27, 0.25, body_mat, collection)
    objects["left_forearm"] = segment("MoonMan_LeftForearm", elbow_l, wrist_l, 0.23, 0.21, body_mat, collection)
    objects["right_forearm"] = segment("MoonMan_RightForearm", elbow_r, wrist_r, 0.23, 0.21, body_mat, collection)
    objects["left_hand"] = ellipsoid("MoonMan_LeftHand_Blockout", (-1.34, -0.62, 3.08), (0.31, 0.24, 0.83), body_mat, collection, segments=14, rings=8, rotation=(math.radians(-2), 0.0, math.radians(-3)))
    objects["right_hand"] = ellipsoid("MoonMan_RightHand_Blockout", (1.34, -0.62, 3.08), (0.31, 0.24, 0.83), body_mat, collection, segments=14, rings=8, rotation=(math.radians(-2), 0.0, math.radians(3)))

    root = bpy.data.objects.new("MoonMan_M1_ROOT", None)
    root.empty_display_type = "PLAIN_AXES"
    root.empty_display_size = 1.0
    collection.objects.link(root)
    root["stage"] = "M1_BLOCKOUT"
    root["roblox_target_height_studs"] = 11.6
    root["has_rig"] = False
    root["has_uv_final"] = False
    root["has_final_textures"] = False
    return objects


def create_r6_dummy(collection: bpy.types.Collection, material: bpy.types.Material) -> list[bpy.types.Object]:
    x = 3.25
    parts = [
        cube("R6_Torso", (x, 0.0, 3.45), (2.0, 1.0, 2.0), material, collection, 0.08),
        cube("R6_Head", (x, 0.0, 4.95), (1.75, 1.15, 1.0), material, collection, 0.12),
        cube("R6_LeftArm", (x - 1.5, 0.0, 3.45), (1.0, 1.0, 2.0), material, collection, 0.08),
        cube("R6_RightArm", (x + 1.5, 0.0, 3.45), (1.0, 1.0, 2.0), material, collection, 0.08),
        cube("R6_LeftLeg", (x - 0.5, 0.0, 1.45), (1.0, 1.0, 2.0), material, collection, 0.08),
        cube("R6_RightLeg", (x + 0.5, 0.0, 1.45), (1.0, 1.0, 2.0), material, collection, 0.08),
    ]
    root = bpy.data.objects.new("R6_ScaleReference_ROOT", None)
    root.empty_display_type = "CUBE"
    root.empty_display_size = 0.4
    collection.objects.link(root)
    root["approx_height_studs"] = 5.45
    return parts


def create_reference(collection: bpy.types.Collection) -> None:
    if not REFERENCE_PATH.exists():
        return
    image = bpy.data.images.load(str(REFERENCE_PATH), check_existing=True)
    try:
        image.pack()
    except RuntimeError:
        pass
    bpy.ops.object.empty_add(type="IMAGE", location=(-9.5, 2.8, 6.0), rotation=(math.radians(90), 0.0, 0.0))
    ref = bpy.context.object
    ref.name = "REF_HomemLua_Concept_Main"
    ref.data = image
    ref.empty_display_size = 10.5
    ref.color[3] = 0.72
    ref.hide_render = True
    move_to_collection(ref, collection)


def create_environment(
    base: bpy.types.Collection,
    trees: bpy.types.Collection,
    rocks: bpy.types.Collection,
    corridor: bpy.types.Collection,
    ground_mat: bpy.types.Material,
    tree_mat: bpy.types.Material,
    rock_mat: bpy.types.Material,
) -> None:
    cube("ENV_Ground", (0.0, 0.0, -0.18), (50.0, 50.0, 0.35), ground_mat, base)

    tree_specs = [(-3.1, 0.8, 7.2, 0.44), (3.0, 1.1, 8.2, 0.48), (-5.0, 2.8, 9.0, 0.58), (5.1, 3.4, 8.6, 0.52)]
    for index, (x, y, height, radius) in enumerate(tree_specs, start=1):
        cylinder(f"ENV_Tree_{index:02d}_Trunk", (x, y, height * 0.5), radius, height, tree_mat, trees, vertices=10)
        bpy.ops.mesh.primitive_cone_add(vertices=10, radius1=radius * 3.3, radius2=0.12, depth=height * 0.64, location=(x, y, height * 0.74))
        foliage = bpy.context.object
        foliage.name = f"ENV_Tree_{index:02d}_Foliage"
        apply_material(foliage, tree_mat)
        move_to_collection(foliage, trees)

    rock_specs = [(-0.95, -3.0, 3.0, (1.65, 1.1, 3.0)), (-2.65, -0.7, 1.45, (1.5, 1.2, 1.5)), (1.95, 2.4, 1.25, (1.3, 1.0, 1.3))]
    for index, (x, y, z, scale) in enumerate(rock_specs, start=1):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.0, location=(x, y, z))
        rock = bpy.context.object
        rock.name = f"ENV_Rock_{index:02d}"
        rock.scale = scale
        rock.rotation_euler = (0.18 * index, 0.09 * index, 0.31 * index)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        apply_material(rock, rock_mat)
        move_to_collection(rock, rocks)

    cube("ENV_Corridor_Left", (-4.2, 5.2, 4.0), (3.4, 24.0, 8.0), rock_mat, corridor, 0.35)
    cube("ENV_Corridor_Right", (4.2, 5.2, 4.0), (3.4, 24.0, 8.0), rock_mat, corridor, 0.35)


def create_camera() -> bpy.types.Object:
    data = bpy.data.cameras.new("M1_Presentation_Camera")
    camera = bpy.data.objects.new("M1_Presentation_Camera", data)
    bpy.context.scene.collection.objects.link(camera)
    bpy.context.scene.camera = camera
    data.lens = 58
    data.sensor_width = 36
    data.clip_start = 0.05
    data.clip_end = 300
    return camera


def point_camera(camera: bpy.types.Object, location: tuple[float, float, float], target: tuple[float, float, float], ortho: float | None = None, lens: float = 58.0) -> None:
    camera.location = location
    direction = Vector(target) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    if ortho is None:
        camera.data.type = "PERSP"
        camera.data.lens = lens
    else:
        camera.data.type = "ORTHO"
        camera.data.ortho_scale = ortho


def make_light(name: str, kind: str, location: tuple[float, float, float], energy: float, color: tuple[float, float, float], size: float = 4.0) -> bpy.types.Object:
    data = bpy.data.lights.new(name, kind)
    data.energy = energy
    data.color = color
    if kind == "AREA":
        data.shape = "DISK"
        data.size = size
    obj = bpy.data.objects.new(name, data)
    obj.location = location
    bpy.context.scene.collection.objects.link(obj)
    return obj


def aim_light(light_obj: bpy.types.Object, target: tuple[float, float, float]) -> None:
    direction = Vector(target) - light_obj.location
    light_obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def set_world(color: tuple[float, float, float, float], strength: float) -> None:
    world = bpy.context.scene.world
    background = world.node_tree.nodes.get("Background")
    background.inputs["Color"].default_value = color
    background.inputs["Strength"].default_value = strength


def set_collection_visibility(collection: bpy.types.Collection, visible: bool) -> None:
    collection.hide_render = not visible
    collection.hide_viewport = False


def set_all_lights(lights: dict[str, bpy.types.Object], neutral: bool, flashlight: bool, head_glow: bool, rim: float = 0.0) -> None:
    lights["key"].data.energy = 1800 if neutral else 0
    lights["fill"].data.energy = 650 if neutral else 0
    lights["back"].data.energy = 1300 if neutral else rim
    lights["flashlight"].data.energy = 3500 if flashlight else 0
    lights["head_glow"].data.energy = 55 if head_glow else 0


def render(name: str) -> None:
    scene = bpy.context.scene
    scene.render.filepath = str(RENDER_DIR / f"{name}.png")
    bpy.ops.render.render(write_still=True)


def collection_bounds(collection: bpy.types.Collection) -> tuple[Vector, Vector]:
    points: list[Vector] = []
    for obj in collection.objects:
        if obj.type != "MESH":
            continue
        points.extend(obj.matrix_world @ Vector(corner) for corner in obj.bound_box)
    minimum = Vector((min(p.x for p in points), min(p.y for p in points), min(p.z for p in points)))
    maximum = Vector((max(p.x for p in points), max(p.y for p in points), max(p.z for p in points)))
    return minimum, maximum


def triangle_count(collection: bpy.types.Collection) -> int:
    count = 0
    for obj in collection.objects:
        if obj.type != "MESH":
            continue
        count += sum(max(0, len(poly.vertices) - 2) for poly in obj.data.polygons)
    return count


clear_scene()
scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 720
scene.render.resolution_y = 720
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.film_transparent = False
scene.render.use_file_extension = True
scene.render.image_settings.color_mode = "RGBA"
scene.render.resolution_percentage = 100
scene.view_settings.view_transform = "AgX"
try:
    scene.view_settings.look = "AgX - Medium High Contrast"
except TypeError:
    pass
scene.render.engine = "BLENDER_EEVEE_NEXT"

world = bpy.data.worlds.new("M1_World")
world.use_nodes = True
scene.world = world

moon_collection = make_collection("M1_MOON_MAN_BLOCKOUT")
r6_collection = make_collection("M1_R6_SCALE_REFERENCE")
reference_collection = make_collection("M1_REFERENCE")
base_collection = make_collection("M1_ENV_BASE")
trees_collection = make_collection("M1_ENV_TREES")
rocks_collection = make_collection("M1_ENV_ROCKS")
corridor_collection = make_collection("M1_ENV_CORRIDOR")

body_mat = make_material("MAT_MoonMan_Body_Blockout", (0.016, 0.018, 0.024, 1.0), roughness=0.84)
head_mat = make_material(
    "MAT_MoonMan_Head_Blockout",
    (0.62, 0.35, 0.09, 1.0),
    roughness=0.66,
    emission=(1.0, 0.45, 0.07, 1.0),
    emission_strength=0.55,
)
silhouette_mat = make_material(
    "MAT_MoonMan_Silhouette_Test",
    (0.0, 0.0, 0.0, 1.0),
    roughness=1.0,
    emission=(0.0, 0.0, 0.0, 1.0),
    emission_strength=1.0,
)
r6_mat = make_material("MAT_R6_Scale_Reference", (0.48, 0.52, 0.58, 1.0), roughness=0.72)
ground_mat = make_material("MAT_Environment_Ground", (0.022, 0.025, 0.032, 1.0), roughness=0.95)
tree_mat = make_material("MAT_Environment_Tree", (0.008, 0.012, 0.010, 1.0), roughness=0.96)
rock_mat = make_material("MAT_Environment_Rock", (0.035, 0.042, 0.052, 1.0), roughness=0.94)

moon_objects = create_moon_man(moon_collection, body_mat, head_mat)
create_r6_dummy(r6_collection, r6_mat)
create_reference(reference_collection)
create_environment(base_collection, trees_collection, rocks_collection, corridor_collection, ground_mat, tree_mat, rock_mat)

camera = create_camera()
lights = {
    "key": make_light("M1_Key", "AREA", (-6.0, -8.0, 13.0), 1800, (0.68, 0.78, 1.0), 6.0),
    "fill": make_light("M1_Fill", "AREA", (6.0, -5.0, 8.0), 650, (0.34, 0.48, 0.72), 5.0),
    "back": make_light("M1_Rim", "AREA", (0.0, 5.5, 11.0), 1300, (0.95, 0.45, 0.18), 5.0),
    "flashlight": make_light("M1_Flashlight_Test", "SPOT", (0.0, -12.0, 4.4), 0, (0.72, 0.82, 1.0)),
    "head_glow": make_light("M1_Head_Glow", "POINT", (0.0, -0.72, 10.4), 0, (1.0, 0.43, 0.08)),
}
lights["flashlight"].data.spot_size = math.radians(42)
lights["flashlight"].data.spot_blend = 0.58
lights["flashlight"].data.shadow_soft_size = 0.18
lights["head_glow"].data.shadow_soft_size = 2.2
aim_light(lights["key"], (0.0, 0.0, 6.0))
aim_light(lights["fill"], (0.0, 0.0, 5.0))
aim_light(lights["back"], (0.0, 0.0, 7.5))
aim_light(lights["flashlight"], (0.0, -0.2, 6.1))

# Save the authored source before rendering presentation variants.
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH), compress=True)


def configure_neutral(show_r6: bool = False) -> None:
    set_collection_visibility(moon_collection, True)
    set_collection_visibility(r6_collection, show_r6)
    set_collection_visibility(base_collection, True)
    set_collection_visibility(trees_collection, False)
    set_collection_visibility(rocks_collection, False)
    set_collection_visibility(corridor_collection, False)
    set_all_lights(lights, neutral=True, flashlight=False, head_glow=True)
    set_world((0.018, 0.022, 0.032, 1.0), 0.24)
    scene.view_settings.look = "AgX - Medium High Contrast"
    scene.view_settings.exposure = 0.0


configure_neutral(False)
point_camera(camera, (0.0, -27.0, 6.0), (0.0, -0.05, 5.65), ortho=14.0)
render("01_front")

point_camera(camera, (25.0, 0.0, 6.0), (0.0, -0.12, 5.65), ortho=14.0)
render("02_side")

point_camera(camera, (0.0, 27.0, 6.0), (0.0, 0.0, 5.65), ortho=14.0)
render("03_back")

point_camera(camera, (16.5, -22.0, 8.2), (0.0, -0.05, 5.75), ortho=None, lens=68.0)
render("04_three_quarter")

configure_neutral(True)
point_camera(camera, (1.1, -29.0, 6.0), (1.1, 0.0, 5.65), ortho=14.3)
render("05_r6_comparison")

# Pure black silhouette against a flat light background.
set_collection_visibility(r6_collection, False)
original_materials: dict[str, bpy.types.Material] = {}
for obj in moon_collection.objects:
    if obj.type == "MESH" and obj.data.materials:
        original_materials[obj.name] = obj.data.materials[0]
        apply_material(obj, silhouette_mat)
set_all_lights(lights, neutral=False, flashlight=False, head_glow=False)
set_world((0.72, 0.72, 0.72, 1.0), 1.0)
scene.view_settings.look = "AgX - Medium High Contrast"
scene.view_settings.exposure = 0.0
point_camera(camera, (0.0, -27.0, 6.0), (0.0, -0.05, 5.65), ortho=14.0)
render("06_black_silhouette")
for obj in moon_collection.objects:
    if obj.name in original_materials:
        apply_material(obj, original_materials[obj.name])

# Dark forest: the head is the first read, the body remains a narrow interruption.
set_collection_visibility(base_collection, True)
set_collection_visibility(trees_collection, True)
set_collection_visibility(rocks_collection, False)
set_collection_visibility(corridor_collection, False)
set_all_lights(lights, neutral=False, flashlight=False, head_glow=True, rim=500)
lights["key"].data.energy = 350
lights["fill"].data.energy = 120
set_world((0.006, 0.010, 0.022, 1.0), 0.12)
scene.view_settings.look = "AgX - Medium High Contrast"
scene.view_settings.exposure = 0.2
point_camera(camera, (0.0, -26.0, 5.0), (0.0, 0.0, 5.9), ortho=None, lens=70.0)
render("07_between_trees_dark")

# Partial occlusion behind a stone mass.
set_collection_visibility(trees_collection, True)
set_collection_visibility(rocks_collection, True)
set_all_lights(lights, neutral=False, flashlight=False, head_glow=True, rim=420)
lights["key"].data.energy = 400
lights["fill"].data.energy = 110
scene.view_settings.exposure = 0.15
point_camera(camera, (0.0, -24.0, 5.2), (0.0, 0.0, 5.8), ortho=None, lens=68.0)
render("08_behind_rock")

# End of a narrow corridor, with only a faint cold edge and the warm head.
set_collection_visibility(trees_collection, False)
set_collection_visibility(rocks_collection, False)
set_collection_visibility(corridor_collection, True)
set_all_lights(lights, neutral=False, flashlight=False, head_glow=True, rim=330)
lights["key"].data.energy = 260
lights["fill"].data.energy = 70
set_world((0.005, 0.008, 0.018, 1.0), 0.10)
scene.view_settings.exposure = 0.10
point_camera(camera, (0.0, -28.0, 4.4), (0.0, 0.0, 5.8), ortho=None, lens=58.0)
render("09_corridor_dark")

# Flashlight analogue: tight cool cone reveals just enough body volume.
set_collection_visibility(corridor_collection, False)
set_collection_visibility(trees_collection, True)
set_collection_visibility(rocks_collection, True)
set_all_lights(lights, neutral=False, flashlight=True, head_glow=True, rim=145)
set_world((0.002, 0.004, 0.010, 1.0), 0.05)
scene.view_settings.exposure = 0.05
lights["flashlight"].location = (0.0, -12.0, 4.4)
aim_light(lights["flashlight"], (0.0, -0.15, 6.15))
point_camera(camera, (0.0, -22.0, 4.9), (0.0, 0.0, 5.8), ortho=None, lens=58.0)
render("10_flashlight_test")

# Final authored file opens in the clean 3/4 review view.
configure_neutral(True)
point_camera(camera, (16.5, -22.0, 8.2), (0.5, -0.05, 5.75), ortho=None, lens=68.0)

minimum, maximum = collection_bounds(moon_collection)
height = maximum.z - minimum.z
head_diameter = 2.34
upper_arm = (Vector((-0.76, -0.30, 8.03)) - Vector((-1.18, -0.42, 5.96))).length
forearm = (Vector((-1.18, -0.42, 5.96)) - Vector((-1.31, -0.57, 3.83))).length
hand_length = 1.66
metrics = {
    "stage": "M1_BLOCKOUT",
    "total_height_studs": round(height, 3),
    "target_height_studs": 11.6,
    "r6_reference_height_studs": 5.45,
    "height_ratio_vs_r6": round(height / 5.45, 3),
    "head_diameter_studs": head_diameter,
    "head_to_height_ratio_percent": round(head_diameter / height * 100, 1),
    "shoulder_joint_width_studs": 1.52,
    "visible_shoulder_width_studs": 2.0,
    "arm_length_shoulder_to_fingertip_studs": round(upper_arm + forearm + hand_length, 3),
    "approx_triangle_count": triangle_count(moon_collection),
    "mesh_objects": sum(1 for obj in moon_collection.objects if obj.type == "MESH"),
    "rig": False,
    "bones": 0,
    "final_uv": False,
    "final_textures": False,
    "renders": [f"{index:02d}_{name}.png" for index, name in enumerate([
        "front", "side", "back", "three_quarter", "r6_comparison", "black_silhouette",
        "between_trees_dark", "behind_rock", "corridor_dark", "flashlight_test"
    ], start=1)],
}
with METRICS_PATH.open("w", encoding="utf-8") as handle:
    json.dump(metrics, handle, indent=2, ensure_ascii=False)

root = moon_collection.objects.get("MoonMan_M1_ROOT")
if root:
    for key, value in metrics.items():
        if isinstance(value, (str, int, float, bool)):
            root[key] = value

bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH), compress=True)
print("M1_BLOCKOUT_COMPLETE")
print(json.dumps(metrics, indent=2, ensure_ascii=False))
