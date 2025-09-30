extends Node2D
class_name ShardRenderer

@export var shard_sim: ShardSim
@export var multimesh_instance: MultiMeshInstance2D
@export var shard_radius: float = 6.0

var _multimesh: MultiMesh
var _colors: PackedColorArray = PackedColorArray()

func _ready() -> void:
    if multimesh_instance == null:
        multimesh_instance = MultiMeshInstance2D.new()
        add_child(multimesh_instance)
    _multimesh = MultiMesh.new()
    _multimesh.transform_format = MultiMesh.TRANSFORM_2D
    _multimesh.color_format = MultiMesh.COLOR_FLOAT
    _multimesh.instance_count = 0
    _multimesh.mesh = _build_circle_mesh()
    multimesh_instance.multimesh = _multimesh

func _build_circle_mesh() -> Mesh:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    var segments: int = 12
    for i in range(segments):
        var angle_a: float = TAU * float(i) / float(segments)
        var angle_b: float = TAU * float(i + 1) / float(segments)
        st.add_color(Color.WHITE)
        st.add_vertex(Vector3(0, 0, 0))
        st.add_color(Color.WHITE)
        st.add_vertex(Vector3(cos(angle_a) * shard_radius, sin(angle_a) * shard_radius, 0))
        st.add_color(Color.WHITE)
        st.add_vertex(Vector3(cos(angle_b) * shard_radius, sin(angle_b) * shard_radius, 0))
    return st.commit()

func update_mesh() -> void:
    if shard_sim == null:
        return
    if shard_sim.shard_radius != shard_radius:
        shard_radius = shard_sim.shard_radius
        _multimesh.mesh = _build_circle_mesh()
    var states := shard_sim.get_states()
    var positions := shard_sim.get_positions()
    var count: int = positions.size()
    _ensure_capacity(count)
    var visible: int = 0
    for i in count:
        if states[i] == ShardSim.STATE_INACTIVE:
            continue
        var transform := Transform2D.IDENTITY
        transform.origin = positions[i]
        _multimesh.set_instance_transform_2d(visible, transform)
        _multimesh.set_instance_color(visible, _colors[min(visible, _colors.size() - 1)])
        visible += 1
    _multimesh.visible_instance_count = visible

func _ensure_capacity(count: int) -> void:
    if _multimesh.instance_count >= count:
        return
    _multimesh.instance_count = count
    _colors.resize(count)
    for i in count:
        var hue: float = float(i % 360) / 360.0
        _colors[i] = Color.from_hsv(hue, 0.65, 0.95, 0.85)
