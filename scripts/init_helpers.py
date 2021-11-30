import bpy
import mathutils
from mathutils import Matrix, Vector

import math
import os

def init_scene(scene_id='Scene', cam_obj_id='endo_cam', scale=1):
    assert scene_id in bpy.data.scenes.keys()
    scene = bpy.data.scenes[scene_id]
        
    # Set Render Properties
    scene.render.engine = 'CYCLES' #BLENDER_EVEE
    scene.cycles.device = 'GPU'
    # Set Render Sampling Properties
    scene.cycles.progressive = 'PATH'
    scene.cycles.samples = 16 #32 #128
    scene.cycles.preview_samples = 3 #32
    # Set Render LightPaths Properties
    scene.cycles.max_bounces = 1 #12
    scene.cycles_curves.use_curves = False #True
    
    # Set Output Properties
    scene.render.resolution_x = 1080 #1920
    scene.render.resolution_y = 1080
    scene.render.resolution_percentage = 100
    scene.render.pixel_aspect_x = 1
    scene.render.pixel_aspect_y = 1
    scene.render.image_settings.file_format = 'JPEG'
    scene.render.image_settings.color_mode = 'RGB'
    scene.render.use_compositing = True
    scene.render.use_sequencer = False
    scene.render.dither_intensity = 0 #dither noise: 0-200
    
    # Set Scene Properties
    scene.camera = bpy.data.objects[cam_obj_id] #set cam for rendering
    scene.unit_settings.system='METRIC'
    scene.unit_settings.scale_length = scale  #set unit scale of scene to default 1m
    scene.unit_settings.system_rotation = 'DEGREES'
    scene.unit_settings.length_unit = 'METERS'
    
def init_global_delta_transform(): #####
    for obj in bpy.data.objects:
        obj.delta_location = obj.delta_rotation_euler = Vector((0,0,0))
        obj.delta_scale = Vector((1,1,1))    

def init_object(obj_id='bladder_full', loc=Vector((0,0,0)), \
                rot=Vector((-30, 0.0, 0.0)) * math.pi/180, \
                scale=Vector((0.01,0.01,0.01))):
    assert obj_id in bpy.data.objects.keys()
    obj = bpy.data.objects[obj_id]
    
    # Set Object Transform Properties
    obj.location = loc
    obj.rotation_mode = 'XYZ'
    obj.rotation_euler = rot 
    obj.scale = scale

def init_light(light_id, type):
    light = bpy.data.lights[light_id]

    if type == 'POINT':
        light.type = 'POINT'
        light.specular_factor = 1 # only in Eevee engine
        light.shadow_soft_size = 0 # in blender unit
    elif type == 'AREA':
        light.type = 'AREA'
        light.shape = 'DISK'
        light.size = 0.01 # in blender unit
    light.color = (1.0, 1.0, 1.0)
    light.energy = 0.05 #0.2 # in blender unit
    light.cycles.max_bounces = 1 #1024
    
def init_camera(cam_id):
    cam = bpy.data.cameras[cam_id]
    # Viewport display setting
    cam.display_size = 0.1 # in blender unit
    
    # Camera render setting
    cam.clip_start = 0
    cam.clip_end = 1000
    # Camera parameter setting
    cam.type = 'PERSP'
    cam.shift_x = 0.0 # position of optical center at center of FOV
    cam.shift_y = 0.0
    cam.dof.use_dof = True
    cam.dof.focus_distance = 50 * 0.001 # depth of focus: 50mm
    cam.dof.aperture_fstop = 2.8
    cam.sensor_fit = 'HORIZONTAL'
    cam.sensor_width =  18   # in mm
    cam.lens_unit = 'FOV'
    cam.angle = 120 * math.pi/180 # in Radians
    
def main():
    init_scene()
    init_global_delta_transform()
    init_camera(cam_id='Camera'); init_light(light_id='Light', type='POINT');
    init_light(light_id='Point', type='POINT')
    init_object(obj_id='bladder_inner', loc=Vector((0,0,0)), rot=Vector((-30, 0.0, 0.0)) * math.pi/180, scale=Vector((0.01,0.01,0.01)))
    init_object(obj_id='bladder_outer', loc=Vector((0,0,0)), rot=Vector((-30, 0.0, 0.0)) * math.pi/180, scale=Vector((0.01,0.01,0.01)))
    init_object(obj_id='bladder_sphere', loc=Vector((0,0,0)), rot=Vector((0.0, 0.0, 0.0)), scale=Vector((4,4,4)))
    init_object(obj_id='grid_sphere', loc=Vector((0,0,0)), rot=Vector((0.0, 0.0, 0.0)), scale=Vector((4,4,4)))
    print('Initialization done.')
    
if __name__ == "__main__": 
    main()