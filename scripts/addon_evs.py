bl_info = {
    "name": "Add-on Template",
    "description": "",
    "author": "p2or",
    "version": (0, 0, 3),
    "blender": (2, 80, 0),
    "location": "3D View > Tools",
    "warning": "", # used for warning icon and text in addons panel
    "wiki_url": "",
    "tracker_url": "",
    "category": "Development"
}


import bpy
import sys
import os
import importlib

dir = os.path.dirname(bpy.data.filepath) + '/scripts'
if not dir in sys.path:
    sys.path.append(dir)
import main, set_helpers
# this next part forces a reload in case you edit the source after you first start the blender session
importlib.reload(main)
from main import *
importlib.reload(set_helpers)
from set_helpers import *

from bpy.props import (StringProperty,
                       BoolProperty,
                       IntProperty,
                       FloatProperty,
                       FloatVectorProperty,
                       EnumProperty,
                       PointerProperty,
                       )
from bpy.types import (Panel,
                       Menu,
                       Operator,
                       PropertyGroup,
                       )


# ------------------------------------------------------------------------
#    Scene Properties
# ------------------------------------------------------------------------

class MyProperties(PropertyGroup):
    
    apply_deform: BoolProperty(
        name="Enable deformation",
        description="Apply deformation on model during endoscopy",
        default = False
        )
    deform_max: FloatProperty(
        name = "Deform max",
        description = "This determines amplitude of deformation from basis shape",
        default = 0.5,
        min = 0,
        max = 1
        )   
    deform_cycle: IntProperty(
        name = "Deform cycle",
        description="This determines the frequency of deformation",
        default = 3,
        min = 1,
        max = 1000
        )     
    use_room_light: BoolProperty(
        name="Use room light",
        description="Use point light source in the center of model",
        default = False
        )
    lens_distortion: FloatProperty(
        name = "Lens distortion",
        description = "Imaging distance",
        default = 0,
        min = 0,
        max = 1
        )
    frame_num: IntProperty(
        name = "Frame #",
        description="Frame number",
        default = 100,
        min = 1,
        max = 1000
        )

    traj_scale: FloatProperty(
        name = "Distance",
        description = "Imaging distance",
        default = 0.01,
        min = 0.01,
        max = 0.03
        )

    folder: StringProperty(
        name="Folder",
        description="Assign folder name.",
        default="",
        maxlen=1024,
        )

    data_dir: StringProperty(
        name = "Directory",
        description="Choose data directory.",
        default="",
        maxlen=1024,
        subtype='DIR_PATH'
        )

    model_id: EnumProperty(
        name="Bladder model",
        description="Select bladder model",
        items=[ ('bladder_inner', "bladder model", ""),
                ('bladder_sphere', "sphere model", ""),
               ]
        )
    traj_id: EnumProperty(
        name="Trajectory curve",
        description="Select scan trajectory",
        items=[ ('Spiral_inner_turn10', "bladder spiral", ""),
                ('Spiral_sphere', "spherical spiral", ""),
                ('Sine_inner', "bladder sine", ""),
                ('Sine_sphere', "spherical sine", ""),
               ]
        )
# ------------------------------------------------------------------------
#    Operators
# ------------------------------------------------------------------------

class WM_OT_HelloWorld(Operator):
    bl_label = "Print Values Operator"
    bl_idname = "wm.hello_world"

    def execute(self, context):
        scene = context.scene
        mytool = scene.evs_tool

        # print the values to the console
        print("Hello World")
        print("bool state:", mytool.use_room_light)
        print("int value:", mytool.frame_num)
        print("float value:", mytool.traj_scale)
        print("string value:", mytool.folder)
        print("enum state:", mytool.model_id)

        return {'FINISHED'}
    
class op_generate_frames(Operator):
    bl_label = "Generate Synthesized Frames"
    bl_idname = "evs.generate_frames"

    def execute(self, context):
        scene = context.scene
        mytool = scene.evs_tool
        
        filepath = mytool.data_dir + mytool.folder + '/base_data/raw_cysto/'
        if not os.path.exists(filepath):
            os.makedirs(filepath)
        model_id = mytool.model_id
        apply_deform = mytool.apply_deform
        deform_max = mytool.deform_max
        deform_cycle = mytool.deform_cycle
        traj_id = mytool.traj_id
        traj_scale = mytool.traj_scale
        frame_num = mytool.frame_num
        
        light_id = 'Point' if mytool.use_room_light else 'endo_light'
        lens_distortion =  mytool.lens_distortion
        render_mode = 'RENDER'
        print("Starting to generate frames:")
        scan_and_render(filepath, frame_num, model_id, traj_id, traj_scale, \
                        light_id, render_mode, lens_distortion, \
                        apply_deform, deform_max, deform_cycle)
        print("Frames rendering finished.")
        return {'FINISHED'}
def set_viewport_shading(context, type):
    for area in context.screen.areas:
        if area.type == 'VIEW_3D':
            for space in area.spaces:
                if space.type == 'VIEW_3D':
                    space.overlay.show_overlays = False
                    space.show_gizmo = False
                    space.shading.type = type
                    break
class op_clear_viewport(Operator):
    bl_label = "Clear viewport"
    bl_idname = "evs.clear_viewport"

    def execute(self, context):
        scene = context.scene
        for obj in scene.objects:
            obj.hide_viewport = True
        return {'FINISHED'}
class op_preview_model(Operator):
    bl_label = "Preview selected model"
    bl_idname = "evs.preview_model"

    def execute(self, context):
        scene = context.scene
        set_hide_viewport(bpy.data.collections['models'].objects, hide=True)
        
        mytool = scene.evs_tool
        set_model(obj_id=mytool.model_id)
        scene.objects[mytool.model_id].hide_viewport = False  
        return {'FINISHED'}
           
class op_preview_trajectory(Operator):
    bl_label = "Preview selected trajectory"
    bl_idname = "evs.preview_traj"

    def execute(self, context):
        scene = context.scene
        set_hide_viewport(bpy.data.collections['trajectories'].objects, hide=True)
        
        mytool = scene.evs_tool
        set_cam_trajectory(curve_id=mytool.traj_id, scale=mytool.traj_scale)
        scene.objects[mytool.traj_id].hide_viewport = False  
        scene.objects[mytool.traj_id].select_set(True)
        return {'FINISHED'}    

class op_preview_deformation(Operator): # TODO: NOT working
    bl_label = "Preview assigned deformation"
    bl_idname = "evs.preview_deform"

    def execute(self, context):
        scene = context.scene
        mytool = scene.evs_tool
        scene.camera.hide_viewport = False
        for i in range(mytool.frame_num):
            scene.camera.constraints["Follow Path"].offset_factor = i * 1.0/mytool.frame_num
            if mytool.apply_deform:
                bpy.data.objects[mytool.model_id].active_shape_key_index = 1
                bpy.data.objects[mytool.model_id].active_shape_key.value = i%int(mytool.frame_num/mytool.deform_cycle) * 1.0/(mytool.frame_num/mytool.deform_cycle) * mytool.deform_max
        bpy.data.objects[mytool.model_id].active_shape_key_index = 0
        return {'FINISHED'}         

class op_set_material_shading(Operator):
    bl_label = ""
    bl_idname = "evs.set_material_shading"
    def execute(self, context):   
        set_viewport_shading(context, type='MATERIAL')
        return {'FINISHED'}  

class op_set_wireframe_shading(Operator):
    bl_label = ""
    bl_idname = "evs.set_wireframe_shading"
    def execute(self, context):   
        set_viewport_shading(context, type='WIREFRAME')
        return {'FINISHED'}  
# ------------------------------------------------------------------------
#    Menus
# ------------------------------------------------------------------------
class PreviewShadingMenu(bpy.types.Menu):
    bl_label = "Select"
    bl_idname = "evs.PreviewShadingMenu"

    def draw(self, context):
        layout = self.layout

        # Built-in operators
        layout.operator("evs.set_material_shading", text="Material shading")
        layout.operator("evs.set_wireframe_shading", text="Wireframe shading")

class OBJECT_MT_CustomMenu(bpy.types.Menu):
    bl_label = "Select"
    bl_idname = "OBJECT_MT_custom_menu"

    def draw(self, context):
        layout = self.layout

        # Built-in operators
        layout.operator("evs.clear_viewport", text="Clear viewport")
        layout.operator("evs.preview_traj", text="Preview selected trajectory")
        layout.operator("evs.preview_model", text="Preview selected model")
        layout.operator("evs.preview_deform", text="Preview assigned deformation")

# ------------------------------------------------------------------------
#    Panel in Object Mode
# ------------------------------------------------------------------------

class OBJECT_PT_CustomPanel(Panel):
    bl_label = "EndoVideoSynthesis"
    bl_idname = "OBJECT_PT_custom_panel"
    bl_space_type = "VIEW_3D"   
    bl_region_type = "UI"
    bl_category = "EVS"
    bl_context = "objectmode"   


    @classmethod
    def poll(self,context):
        return context.object is not None

    def draw(self, context):
        layout = self.layout
        scene = context.scene
        mytool = scene.evs_tool

        layout.menu(PreviewShadingMenu.bl_idname, text='Preview shading type', icon='SCENE')
        layout.menu(OBJECT_MT_CustomMenu.bl_idname, text="Preview", icon="OPTIONS")
        layout.separator()
        box = layout.box()
        box.prop(mytool, "model_id", text="Model") 
        box.prop(mytool, "apply_deform")
        row = box.row()
        row.prop(mytool, "deform_max")
        row.prop(mytool, "deform_cycle")
        
        box = layout.box()
        box.prop(mytool, "traj_id", text="Trajectory") 
        row = box.row()
        row.prop(mytool, "traj_scale")
        row.prop(mytool, "frame_num")
        layout.separator()
        
        box = layout.box()
        box.prop(mytool, "use_room_light")
        box = layout.box()
        box.prop(mytool, "lens_distortion")
        
        layout.prop(mytool, "folder")
        layout.prop(mytool, "data_dir")
        layout.operator("evs.generate_frames")
        
        layout.separator()

# ------------------------------------------------------------------------
#    Registration
# ------------------------------------------------------------------------

classes = (
    MyProperties,
    WM_OT_HelloWorld,
    OBJECT_MT_CustomMenu,
    OBJECT_PT_CustomPanel,
    PreviewShadingMenu,
    op_generate_frames,
    op_clear_viewport,
    op_preview_trajectory,
    op_preview_model,
    op_preview_deformation,
    op_set_material_shading,
    op_set_wireframe_shading,
)

def register():
    from bpy.utils import register_class
    for cls in classes:
        register_class(cls)

    bpy.types.Scene.evs_tool = PointerProperty(type=MyProperties)

def unregister():
    from bpy.utils import unregister_class
    for cls in reversed(classes):
        unregister_class(cls)
    del bpy.types.Scene.evs_tool


if __name__ == "__main__":
    register()
#    unregister()
