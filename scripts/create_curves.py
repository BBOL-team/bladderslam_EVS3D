bpy.ops.mesh.primitive_z_function_surface(equation="0.5*sin(3.14*10*x-3.14/2)", div_x=256, div_y=3, size_x=2, size_y=1)
bpy.ops.mesh.delete(type='VERT')
bpy.ops.mesh.delete(type='VERT')
bpy.ops.object.editmode_toggle()
bpy.ops.object.convert(target='CURVE')

bpy.ops.object.modifier_add(type='SIMPLE_DEFORM')
bpy.context.object.modifiers["SimpleDeform"].deform_method = 'BEND'
bpy.context.object.modifiers["SimpleDeform"].angle = 3.14159
bpy.ops.object.modifier_add(type='SIMPLE_DEFORM')
bpy.context.object.modifiers["SimpleDeform.001"].deform_method = 'BEND'
bpy.context.object.modifiers["SimpleDeform.001"].deform_axis = 'Z'
bpy.context.object.modifiers["SimpleDeform.001"].angle = 6.28319
# need to apply modifiers to facilitate set of origin.
bpy.ops.object.modifier_apply(apply_as='DATA', modifier="SimpleDeform")
bpy.ops.object.modifier_apply(apply_as='DATA', modifier="SimpleDeform.001")

bpy.context.object.scale[0] = 0.095
bpy.context.object.scale[1] = 0.095
bpy.context.object.scale[2] = 0.095

bpy.ops.object.origin_set(type='ORIGIN_CENTER_OF_VOLUME', center='MEDIAN')
bpy.context.object.location = (0,0,0)
