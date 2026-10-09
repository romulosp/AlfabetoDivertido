"""Author a mobile tutor draft, rig, NLA clips, export and review evidence."""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'godot/assets/models'; OUT.mkdir(parents=True,exist_ok=True)
REVIEW=ROOT/'blender/tucano/review'; REVIEW.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene
scene.render.engine='BLENDER_EEVEE'; scene.eevee.taa_render_samples=16
scene.render.resolution_x=512; scene.render.resolution_y=512; scene.render.resolution_percentage=100
scene.render.film_transparent=True; scene.render.image_settings.color_mode='RGBA'; scene.view_settings.view_transform='Standard'
parts=[]
def material(name,hex):
    m=bpy.data.materials.new(name); node=m.node_tree.nodes.get('Principled BSDF')
    rgb=[int(hex[i:i+2],16)/255 for i in (0,2,4)]
    rgb=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb]
    node.inputs['Base Color'].default_value=(*rgb,1); node.inputs['Roughness'].default_value=.8
    return m
dark=material('Dark','203546'); cream=material('Cream','fff8e7'); orange=material('Orange','ff9f43'); mint=material('Mint','4ecdc4'); white=material('White','ffffff'); pink=material('Pink','ff8caa')
def sphere(name,loc,scale,mat,bone='DEF-body'):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=10,location=loc)
    ob=bpy.context.object; ob.name=name; ob.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    ob.data.materials.append(mat)
    for face in ob.data.polygons: face.use_smooth=True
    parts.append((ob,bone)); return ob
sphere('CR_Tucano_Body_LOD0',(0,0,.67),(.36,.27,.50),dark)
sphere('CR_Tucano_Belly_LOD0',(.05,-.22,.65),(.26,.09,.38),cream)
sphere('CR_Tucano_Head_LOD0',(0,0,1.23),(.34,.31,.32),dark,'DEF-head')
sphere('CR_Tucano_BeakUpper_LOD0',(.37,-.11,1.25),(.45,.18,.15),orange,'DEF-head')
sphere('CR_Tucano_BeakTip_LOD0',(.70,-.10,1.25),(.12,.18,.14),dark,'DEF-head')
sphere('BeakLower',(.39,-.11,1.12),(.38,.15,.05),orange,'DEF-beak')
for side in [-1,1]:
    suffix='L' if side<0 else 'R'
    sphere('CR_Tucano_Wing'+suffix+'_LOD0',(side*.33,0,.70),(.12,.22,.32),mint,'DEF-wing.'+suffix)
    sphere('CR_Tucano_Eye'+suffix+'_LOD0',(side*.10,-.285,1.31),(.105,.035,.11),white,'DEF-head')
    sphere('CR_Tucano_Pupil'+suffix+'_LOD0',(side*.10+.025,-.32,1.31),(.045,.018,.05),dark,'DEF-head')
    sphere('CR_Tucano_Spark'+suffix+'_LOD0',(side*.10+.04,-.337,1.33),(.013,.008,.015),white,'DEF-head')
    sphere('CR_Tucano_Feet'+suffix+'_LOD0',(side*.17,-.11,.08),(.13,.18,.06),orange)
    sphere('CR_Tucano_Leg'+suffix+'_LOD0',(side*.17,0,.16),(.04,.045,.11),orange)
sphere('CR_Tucano_Tail_LOD0',(-.10,.26,.38),(.17,.25,.14),dark)
sphere('CR_Tucano_Cheek_LOD0',(-.17,-.265,1.17),(.06,.025,.035),pink,'DEF-head')

arm_data=bpy.data.armatures.new('TutorSkeleton'); rig=bpy.data.objects.new('TutorRig',arm_data); scene.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig; rig.select_set(True); bpy.ops.object.mode_set(mode='EDIT')
bones=[('DEF-root',(0,0,0),(0,0,.15),None),('DEF-body',(0,0,.15),(0,0,.9),'DEF-root'),('DEF-head',(0,0,1.0),(0,0,1.5),'DEF-body'),('DEF-beak',(.1,-.11,1.12),(.6,-.11,1.12),'DEF-head'),('DEF-wing.L',(-.25,0,.95),(-.4,0,.45),'DEF-body'),('DEF-wing.R',(.25,0,.95),(.4,0,.45),'DEF-body')]
for name,head,tail,parent in bones:
    b=arm_data.edit_bones.new(name); b.head=head; b.tail=tail
    if parent: b.parent=arm_data.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT')
for ob,bone in parts:
    group=ob.vertex_groups.new(name=bone); group.add(list(range(len(ob.data.vertices))),1.0,'REPLACE')
    modifier=ob.modifiers.new('TutorSkin','ARMATURE'); modifier.object=rig; ob.parent=rig
for pb in rig.pose.bones: pb.rotation_mode='XYZ'
rig.animation_data_create()
clips={'idle':(96,True),'talk':(24,True),'celebrate':(24,False),'think':(36,False),'beak_closed':(2,False),'beak_half_open':(2,False),'beak_open':(2,False),'happy':(12,False),'curious':(12,False),'thinking':(12,False),'encouraging':(12,False)}
for name,(end,loop) in clips.items():
    rig.animation_data.action=None
    for pb in rig.pose.bones:
        pb.location=(0,0,0); pb.rotation_euler=(0,0,0); pb.scale=(1,1,1)
    for frame in sorted(set([1,max(2,end//2),end])):
        t=(frame-1)/max(1,end-1); pulse=math.sin(t*math.pi)
        root=rig.pose.bones['DEF-root']; head=rig.pose.bones['DEF-head']; jaw=rig.pose.bones['DEF-beak']
        root.location.z=pulse*(.10 if name=='celebrate' else .012 if name=='idle' else 0)
        head.rotation_euler.y=pulse*(.16 if name in ['think','curious','thinking'] else 0)
        jaw.rotation_euler.x=pulse*.35 if name=='talk' else .20 if name=='beak_half_open' else .40 if name=='beak_open' else 0
        rig.pose.bones['DEF-wing.L'].rotation_euler.y=pulse*(-.35 if name in ['celebrate','happy','encouraging'] else -.025)
        rig.pose.bones['DEF-wing.R'].rotation_euler.y=pulse*(.35 if name in ['celebrate','happy','encouraging'] else .025)
        for pb in rig.pose.bones:
            for prop in ['location','rotation_euler','scale']: pb.keyframe_insert(data_path=prop,frame=frame)
    action=rig.animation_data.action; action.name=name; action.use_fake_user=True
    slot=rig.animation_data.action_slot
    rig.animation_data.action=None
    track=rig.animation_data.nla_tracks.new(); track.name=name
    strip=track.strips.new(name,1,action); strip.action_slot=slot
    track.mute=True
scene.frame_start=1; scene.frame_end=96; scene.render.fps=24
bpy.ops.object.select_all(action='DESELECT')
for ob,_ in parts: ob.select_set(True)
rig.select_set(True); bpy.context.view_layer.objects.active=rig
# Export all named actions, no cameras/lights or reference assets.
bpy.ops.export_scene.gltf(filepath=str(OUT/'tucano.glb'),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True)
triangles=sum(len(ob.data.polygons)*2 for ob,_ in parts)
assert triangles<=15000,triangles
(REVIEW/'manifest.json').write_text(json.dumps({'status':'draft_pending_review','trianglesUpperBound':triangles,'animations':list(clips),'bones':len(bones),'inferred':['back','depth','oppositewing'],'textures':0},indent=2))

bpy.ops.object.camera_add(location=(3,-6,2.6)); camera=bpy.context.object; camera.name='ReviewCamera'; camera.data.type='ORTHO'; camera.data.ortho_scale=2.0; scene.camera=camera
camera.rotation_euler=(Vector((.18,0,.8))-camera.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.light_add(type='AREA',location=(1,-3,4)); bpy.context.object.data.energy=350; bpy.context.object.data.shape='DISK'; bpy.context.object.data.size=4
scene.world.color=(.3,.3,.3)
scene.frame_set(1)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'blender/tucano/tucano.blend'))
for name,loc in [('threequarter',(3,-6,2.6)),('front',(0,-6,1.3)),('side',(6,0,1.3))]:
    camera.location=loc; camera.rotation_euler=(Vector((.18,0,.8))-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(REVIEW/(name+'.png')); bpy.ops.render.render(write_still=True)
print(json.dumps({'model':'tucano.glb','triangles':triangles,'status':'draft'}))
