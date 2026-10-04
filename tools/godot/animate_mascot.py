"""Build an editable flat mascot in Blender and render transparent animation frames."""
import bpy
import math
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'apps/alfabeto-godot/assets/mascot'
SOURCE = ROOT / 'assets/blender'
OUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
scene = bpy.context.scene
scene.render.engine = 'BLENDER_EEVEE'
scene.eevee.taa_render_samples = 8
scene.render.resolution_x, scene.render.resolution_y = 220, 240
scene.render.resolution_percentage = 100
scene.render.film_transparent = True
scene.render.image_settings.file_format = 'PNG'
scene.render.image_settings.color_mode = 'RGBA'
scene.render.fps = 24
scene.view_settings.view_transform = 'Standard'
scene.world.color = (0, 0, 0)

def empty(name, xy):
    obj = bpy.data.objects.new(name, None)
    scene.collection.objects.link(obj)
    obj.location = (xy[0], 120-xy[1], 0)
    return obj

body = empty('Romulo_Penha', (52, 115))
wing = empty('Asa', (29, 63))
wing.parent = body
wing.matrix_parent_inverse = body.matrix_world.inverted()
bpy.context.view_layer.update()

def material(color):
    mat = bpy.data.materials.new(color)
    mat.use_nodes = True
    n = mat.node_tree.nodes
    n.clear()
    output = n.new('ShaderNodeOutputMaterial')
    emission = n.new('ShaderNodeEmission')
    rgb = [int(color[i:i+2], 16)/255 for i in (1, 3, 5)]
    rgb = [v/12.92 if v <= .04045 else ((v+.055)/1.055)**2.4 for v in rgb]
    emission.inputs['Color'].default_value = (*rgb, 1)
    mat.node_tree.links.new(emission.outputs[0], output.inputs[0])
    return mat

materials = {}
layer = 0
def shape(name, points, color, parent=body):
    global layer
    layer += .03
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata([(x, 120-y, layer) for x, y in points], [], [list(range(len(points)))])
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(obj)
    if color not in materials: materials[color] = material(color)
    obj.data.materials.append(materials[color])
    # Preserve world coordinates when parenting to the animation pivots.
    bpy.context.view_layer.update()
    obj.parent = parent
    obj.matrix_parent_inverse = parent.matrix_world.inverted()
    return obj

def ellipse(name, x, y, rx, ry, color, parent=body):
    return shape(name, [(x+rx*math.cos(t*math.tau/64), y+ry*math.sin(t*math.tau/64)) for t in range(64)], color, parent)

def cubic(a, b, c, d):
    return [tuple((1-t)**3*a[i]+3*(1-t)**2*t*b[i]+3*(1-t)*t*t*c[i]+t**3*d[i] for i in range(2)) for t in [j/20 for j in range(21)]]

def stroke(name, points, radius, color):
    # Rounded strokes represented by overlapping circles, editable geometry.
    for k, (a, b) in enumerate(zip(points, points[1:])):
        dx, dy = b[0]-a[0], b[1]-a[1]
        length = math.hypot(dx, dy)
        for j in range(max(2, int(length/radius)*2)):
            t = j/(max(2, int(length/radius)*2)-1)
            ellipse(f'{name}_{k}_{j}', a[0]+dx*t, a[1]+dy*t, radius, radius, color)

shape('Cauda', [(30,72),(16,102),(38,96)], '#203546')
stroke('Pernas', [(44,106),(44,115)], 3.5, '#e98423')
stroke('PernaDireita', [(62,105),(62,115)], 3.5, '#e98423')
stroke('PeEsquerdo', [(39,115),(52,115)], 2.5, '#e98423')
stroke('PeDireito', [(57,115),(70,115)], 2.5, '#e98423')
ellipse('Corpo',53,76,30,35,'#203546')
ellipse('Barriga',59,82,19,26,'#fff8e7')
shape('AsaTurquesa', cubic((29,63),(14,66),(17,97),(35,100))+cubic((35,100),(45,92),(48,71),(29,63)), '#4ecdc4', wing)
ellipse('Cabeca',55,35,27,27,'#203546')
shape('Bico', cubic((65,18),(104,10),(112,27),(102,46))+cubic((102,46),(89,51),(72,44),(67,39)), '#ff9f43')
shape('PontaBico', cubic((99,18),(111,23),(111,36),(103,46))+[(90,47),(96,19)], '#203546')
stroke('LinhaBico', [(72,34),(94,36)], 1, '#df7824')
ellipse('Olho',56,29,10,10,'#ffffff')
ellipse('Pupila',59,30,5,5,'#203546')
ellipse('Brilho',61,28,1.6,1.6,'#ffffff')
stroke('Sorriso', cubic((51,45),(56,49),(61,49),(66,44)), .9, '#fff8e7')
ellipse('Bochecha',44,41,5,3,'#ff6b9d')

bpy.ops.object.camera_add(location=(55, 60, 500))
camera = bpy.context.object
camera.name = 'CameraSprites'
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 120
scene.camera = camera

def key(frame, lift=0, angle=0, sx=1, sy=1, flap=0):
    body.location = (52, 5+lift, 0)
    body.rotation_euler = (0,0,math.radians(angle))
    body.scale = (sx,sy,1)
    wing.rotation_euler.z = math.radians(flap)
    for prop in ('location','rotation_euler','scale'): body.keyframe_insert(data_path=prop, frame=frame)
    wing.keyframe_insert(data_path='rotation_euler', frame=frame)

key(1); key(49, sy=1.018, flap=-3); key(97)
key(110); key(114, sx=1.04, sy=.96); key(119, lift=7, sx=.98, sy=1.02, flap=-18); key(125, lift=2, flap=5); key(129)
key(140); key(145, angle=-7, flap=5); key(149, angle=4); key(154)
body.animation_data.action.name = 'Romulo_Espera_Acerto_Tentativa'
wing.animation_data.action.name = 'Asa_Espera_Acerto_Tentativa'
for name, frame in [('Espera',1),('Acerto',110),('Tentativa',140)]: scene.timeline_markers.new(name, frame=frame)
scene.frame_end = 154
scene.frame_set(1)
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'romulo-penha.blend'))

clips = [('idle',1,97,16,4.0,True),('happy',110,129,10,12.5,False),('confused',140,154,8,13.333333,False)]
resources = []
animations = []
for name, start, end, count, fps, loop in clips:
    ids = []
    for i in range(count):
        frame = round(start+(end-start)*i/(count-1))
        scene.frame_set(frame)
        filename = f'{name}_{i:02}.png'
        scene.render.filepath = str(OUT/filename)
        bpy.ops.render.render(write_still=True)
        ident = len(resources)+1
        resources.append(f'[ext_resource type="Texture2D" path="res://assets/mascot/{filename}" id="{ident}"]')
        ids.append('{"duration": 1.0, "texture": ExtResource("%s")}' % ident)
    animations.append('{"frames": [%s], "loop": %s, "name": &"%s", "speed": %s}' % (', '.join(ids), str(loop).lower(), name, fps))
(OUT/'animations.tres').write_text('[gd_resource type="SpriteFrames" load_steps=%d format=3]\n\n%s\n\n[resource]\nanimations = [%s]\n' % (len(resources)+1,'\n'.join(resources),',\n'.join(animations)), encoding='utf-8')
print('Rendered 34 Blender frames and saved editable mascot source.')
