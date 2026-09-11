from __future__ import annotations

import json
from pathlib import Path

import bpy


root = Path(bpy.data.filepath).resolve().parents[1]
render_dir = root / "renders"
moon_collection = bpy.data.collections.get("M1_MOON_MAN_BLOCKOUT")

mesh_objects = [obj for obj in moon_collection.objects if obj.type == "MESH"] if moon_collection else []
armatures = [obj for obj in bpy.data.objects if obj.type == "ARMATURE"]
missing_renders = [
    name
    for name in (
        "01_front.png",
        "02_side.png",
        "03_back.png",
        "04_three_quarter.png",
        "05_r6_comparison.png",
        "06_black_silhouette.png",
        "07_between_trees_dark.png",
        "08_behind_rock.png",
        "09_corridor_dark.png",
        "10_flashlight_test.png",
    )
    if not (render_dir / name).exists()
]

result = {
    "blend_file": bpy.data.filepath,
    "moon_collection_present": moon_collection is not None,
    "moon_mesh_objects": len(mesh_objects),
    "armature_objects": len(armatures),
    "bones": sum(len(obj.data.bones) for obj in armatures),
    "materials": sorted(material.name for material in bpy.data.materials),
    "reference_packed": bool(bpy.data.images.get("HomemLua_concept.png") and bpy.data.images["HomemLua_concept.png"].packed_file),
    "missing_renders": missing_renders,
    "valid_m1": moon_collection is not None and len(mesh_objects) == 17 and not armatures and not missing_renders,
}
print("M1_VALIDATION")
print(json.dumps(result, indent=2, ensure_ascii=False))
if not result["valid_m1"]:
    raise SystemExit(1)
