import bpy
from mathutils import Matrix, Vector
def set_hide_render(objects, hide=True):
    for object in objects:
        object.hide_render = hide
def set_hide_viewport(objects, hide=True):
    for object in objects:
        object.hide_viewport = hide

def set_parent(parent, child):
    bpy.context.view_layer.objects.active = None
    bpy.ops.object.select_all(action='DESELECT')   # deselect & deactivate all objects first
    child.select_set(True)
    parent.select_set(True)
    bpy.context.view_layer.objects.active = parent  # make parent the active object (i.e. the lastlt selected obj)
    bpy.ops.object.parent_set(type='OBJECT', xmirror=False, keep_transform=False)
    
def set_cam_trajectory(curve_id, delta_scale):
    curve = bpy.data.objects[curve_id]
    set_hide_render([curve], hide=False)
    set_hide_viewport([curve], hide=False)
    curve.delta_scale = Vector((delta_scale,delta_scale,delta_scale))
    follow_constraint = bpy.data.scenes['Scene'].camera.constraints["Follow Path"]
    follow_constraint.target = curve
    follow_constraint.use_curve_follow = True
    follow_constraint.use_fixed_location = True
    follow_constraint.use_curve_radius = False
    follow_constraint.offset_factor = 0.5
    follow_constraint.forward_axis = 'FORWARD_Y'
    follow_constraint.up_axis = 'UP_Z'
    follow_constraint.influence = 1


def set_model(obj_id):
    model = bpy.data.objects[obj_id]
    set_hide_render([model], hide=False)
    set_hide_viewport([model], hide=False)    
    track_constraint = bpy.data.scenes['Scene'].camera.constraints["Track To"]
    track_constraint.target = model
    track_constraint.track_axis = 'TRACK_Z'
    track_constraint.up_axis = 'UP_Y'
    track_constraint.use_target_z = False
    track_constraint.target_space = 'WORLD'
    track_constraint.owner_space = 'WORLD'
    track_constraint.influence = 1
