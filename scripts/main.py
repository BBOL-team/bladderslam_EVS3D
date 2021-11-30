import bpy
import sys
import os
import shutil
import importlib
import json

dir = os.path.dirname(bpy.data.filepath) + '/scripts'
if not dir in sys.path:
    sys.path.append(dir)
import init_helpers, get_helpers, set_helpers
# this next part forces a reload in case you edit the source after you first start the blender session
importlib.reload(init_helpers)
from init_helpers import *
importlib.reload(get_helpers)
from get_helpers import *
importlib.reload(set_helpers)
from set_helpers import *

def scan_and_render(data_folder, frame_fd, frame_num, model_id, traj_id, traj_scale, light_id, render_mode, lens_distortion, \
                    apply_deform, deform_max, deform_cycle, save_render, save_traj, save_video): 
    # Initialization
    init_helpers.main()
    set_hide_render(bpy.data.objects)
    set_hide_viewport(bpy.data.objects)
#    cam = bpy.data.scenes['Scene'].camera
    cam = bpy.data.objects['endo_cam']
    K = get_calibration_matrix_K_from_blender(cam.data)
    print(K)

    # Set cam traj and model, light
    set_cam_trajectory(curve_id=traj_id, delta_scale=traj_scale)
    set_model(obj_id=model_id) # enable model in renderer and set camera track object
    set_hide_render([bpy.data.objects[light_id], cam], False)
    set_hide_viewport([bpy.data.objects[light_id], cam], False)
    
    # Set rendering params
    if render_mode == 'SNAPSHOT': # quite slow
        for area in bpy.context.screen.areas:
            if area.type == 'VIEW_3D':
                for space in area.spaces:
                    if space.type == 'VIEW_3D':
                        space.overlay.show_overlays = False
                        space.show_gizmo = False
                        space.shading.type = 'MATERIAL'
                        break
    bpy.data.scenes["Scene"].node_tree.nodes["Lens Distortion"].inputs[1].default_value = lens_distortion
    filepath = data_folder + '/' + frame_fd + '/'
    if not os.path.exists(filepath):
        os.makedirs(filepath)
        
    cam_extmat_tq_gt = [] if save_traj else None
    # Start frames generation
    for i in range(frame_num):
        cam.constraints["Follow Path"].offset_factor = i * 1.0/frame_num
        if not apply_deform:
            bpy.data.objects[model_id].active_shape_key_index = 0
        else:
            bpy.data.objects[model_id].active_shape_key_index = 1
            bpy.data.objects[model_id].active_shape_key.value = i%int(frame_num/deform_cycle) * 1.0/(frame_num/deform_cycle) * deform_max
        bpy.data.scenes['Scene'].render.filepath = filepath+'cysto_'+format(i, '06d')
        if render_mode == 'SNAPSHOT':
            bpy.ops.render.opengl(animation=False, render_keyed_only=False, sequencer=False, write_still=save_render, view_context=True)
        elif render_mode == 'RENDER':
            bpy.ops.render.render(animation=False, write_still=save_render, use_viewport=False)
        if save_traj:
            _, RT = get_3x4_RT_matrix_from_blender(cam)
#            tq = get_tq_from_matrix(RT)
            tq = get_tq_from_matrix(cam.matrix_world)
            tq.insert(0, i)
#            print(tq)
            cam_extmat_tq_gt.append(tq)
    if save_traj:
        cam_extmat_tq_gt = np.matrix(cam_extmat_tq_gt)
        np.savetxt(data_folder+"/cam_wmat_tq_gt.txt", cam_extmat_tq_gt, fmt='%.5f')
    if save_video:
        generate_video_from_frames(frame_dir=filepath, vid_name='video_cysto.avi', frame_rate=10)
        configure_base_data_folder(data_folder, template_folder, cysto_frame_start=0, cysto_frame_end=frame_num)
    print('Scanning and rendering finished!')

def generate_video_from_frames(frame_dir, vid_name, frame_rate):
    # run matlab function in terminal
    os.system("matlab -nodisplay -nojvm -r \"cd('/home/hpl/Documents/cysto3D/EndoVidSynthesis/evs-3d/scripts/'); convert_frames2video('"+frame_dir+"','"+vid_name+"', "+str(frame_rate)+");exit;\"")
    
    # sequencer not working
#    files = os.listdir(frame_dir)
#    frame_names = []
#    for i in range(frame_num):
#        fn = prefix+format(i, num_fmt)+fmt
#        if fn not in files:
#            raise SystemExit('Error: frame doesn\'t exit!')
#        frame_names.append({"name":fn})
#    print(frame_names)
#    bpy.ops.sequencer.image_strip_add(directory=frame_dir, files=frame_names, channel=1, frame_start=0, frame_end=frame_num-1) 
#    
#    scene = bpy.data.scenes[scene_id]
#    scene.frame_end = frame_num
#    scene.render.image_settings.file_format = 'AVI_RAW'
#    scene.render.image_settings.color_mode = 'RGB'
#    scene.render.use_compositing = False
#    scene.render.use_sequencer = True
#    scene.render.dither_intensity = 0 #dither noise: 0-200
#    
#    scene.render.filepath = vid_dir + '/' + vid_name
#    bpy.ops.render.render(animation=True)
    
def calc_frame_num_wconstspeed(traj_id):
    length_dict = {'Sine_sphere_turn6': 12, 'Sine_sphere_turn8': 16, 'Sine_sphere_turn10': 20, 'Sine_inner_turn10': 20, \
                    'Sine_sphere_turn12': 24, 'Sine_sphere_turn14': 28, \
                    'Spiral_sphere_turn6': 24, 'Spiral_sphere_turn8': 32, 'Spiral_sphere_turn10': 40, 'Spiral_inner_turn10': 40, \
                    'Spiral_sphere_turn12': 48, 'Spiral_sphere_turn14': 56}
    frame_num = length_dict[traj_id] * 10    
    return frame_num

def configure_base_data_folder(data_folder, template_folder, cysto_frame_start, cysto_frame_end):
    shutil.copy(template_folder+'/camera_params.json', data_folder)
    
    shutil.copy(template_folder+'/data_config.json', data_folder)
    file = open(data_folder+'/data_config.json', "r")
    json_obj = json.load(file)
    file.close()
    json_obj["base_path"] = '/'.join(data_folder.split('/')[0:-1])
    file = open(data_folder+'/data_config.json', "w")
    json.dump(json_obj, file, sort_keys=True, indent=4, separators=(',', ': '))
    file.close()
    
    shutil.copy(template_folder+'/frame_ranges_and_selection.json', data_folder)
    file = open(data_folder+'/frame_ranges_and_selection.json', "r")
    json_obj = json.load(file)
    file.close()
    json_obj["cysto_frame_range"] = [cysto_frame_start, cysto_frame_end]
    file = open(data_folder+'/frame_ranges_and_selection.json', "w")
    json.dump(json_obj, file, sort_keys=True, indent=4, separators=(',', ': '))
    file.close()
    
if __name__ == "__main__":   
    light_id = 'Point'
    render_mode = 'RENDER' 
    template_folder = '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/templates'
    
    lens_distortion = 0
    apply_deform = False
    deform_max = 1.0
    deform_cycle = 3
    traj_scale = 1 # 1-2
    
    model_id = 'bladder_sphere'                   
    apply_deform = False
    traj_id = 'Sine_sphere_turn10' # using this since length can be scaled easier
    s = 1
    traj_scale = 1.0
    frame_num = int(round(traj_scale*calc_frame_num_wconstspeed(traj_id)))   # note to change frame number based on traj scale   
    data_folder = '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Mo-Tsis_t10_s'+str(s)+'-rachTex/base_data'
#    scan_and_render(data_folder, 'raw_cysto', frame_num, 'bladder_inner', traj_id, traj_scale, light_id, render_mode, lens_distortion, \
#                        apply_deform, deform_max, deform_cycle, save_render=True, save_traj=True, save_video=True)                            
    scan_and_render(data_folder, 'raw_grid', frame_num, 'grid_inner', traj_id, traj_scale, light_id, render_mode, lens_distortion, \
                        apply_deform, deform_max, deform_cycle, save_render=True, save_traj=False, save_video=False)   

    data_folder = '/home/hpl/Documents/cysto3D/EndoVidSynthesis/data/Ms-Tsis_t10_s'+str(s)+'-rachTex/base_data'
    scan_and_render(data_folder, 'raw_cysto', frame_num, 'bladder_sphere', traj_id, traj_scale, light_id, render_mode, lens_distortion, \
                        apply_deform, deform_max, deform_cycle, save_render=True, save_traj=True, save_video=True)  
    scan_and_render(data_folder, 'raw_grid', frame_num, 'grid_sphere', traj_id, traj_scale, light_id, render_mode, lens_distortion, \
                        apply_deform, deform_max, deform_cycle, save_render=True, save_traj=False, save_video=False)