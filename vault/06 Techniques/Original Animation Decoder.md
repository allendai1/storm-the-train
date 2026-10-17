---
tags: [technique, decoding, original-game, animation, python]
status: implemented
updated: 2026-10-17
---
# Original Animation Decoder

## When to use
To read the original game's character animations (`assets/Models/*.cm`) and sprite atlases
(`assets/Atlases/*`): to regenerate the viewer data, render reference frames, or start a
retarget to our R15 rig. Findings are in [[Original Game - Animations]].

## The formats (from the engine's own loader, decompiled 2026-10-17)
**`.cm` model** (`CaResource_Model2::SerialiseIn`): little-endian **chunks** of
`[u32 id][u32 size][data]`; strings are a 1-byte length plus the characters.
- **Chunk 0** (12 bytes): magic `0x54FE23DD`, version 26, flags.
- **Chunk 2**, the animation hierarchy, holding sub-chunks:
  - **1:** `u32 bones`, `u32 frames`, `f32 fps` (15), `u32 values`, `f32 values[]`
    (every channel's per-frame samples), `i32 parent[bones]`, then per bone
    `i32 index + name`.
  - **4:** `u32 count`, then per channel 6 × i32: **type** (0 = X, 1 = Y, 2 = rotation in
    radians), frames, **offset** into the values, unused, **bone index**, unused. A
    channel's value at frame f is `values[offset + f]`.
  - **5:** the rest pose, per bone `f32 x, y, rotation`.
- **Chunk 7**, the sprites: `u32 n`, then n × 10 floats (the quad corners
  `x0,y0, x1,y0, x1,y1, x0,y1`, then a **depth** for draw order and one unused value), n
  default texture names, and n × (`i32 index + mesh name`). Meshes attach to bones by name
  (`mesh_chr_armR` → `xform_r_arm`; weapon meshes go to a hand).
- **Chunk 10**, the clips: `u32 n`, then n × (`name`, `u16 first frame`, `u16 last frame`).
- **Maths:** each bone's local transform is translate(x, y) · rotate(r); world =
  parent world · local; Y points up. Units are the original's 1× pixels (15 px ≈ 1 stud).

**Atlases:** `*.atlas` is a Lua table of sprites (`name, w, h, x, y`); `*0.pvr` is a PVR v2
texture, format `0x12` (**uncompressed RGBA 8888**), 52-byte header, stored **bottom-up**
(flip it vertically before cropping).

## Steps
Run from the repository root with Python 3 and Pillow.
1. `python cm.py "vault/05 Assets/Original Game/assets/Models/chr_graham.cm"` prints a
   model's bones, channels, sprites and clips.
2. `python atlas.py sprites players_hres enemies_hres characters_2x_hres` cuts every
   sprite into `sprites/`.
3. `python render.py 77 64 90` renders Graham at frames 77, 64 and 90 into
   `graham_test.png` (a quick check).
4. `python export.py` writes `anim_data.json` (62 characters, sprites as data URIs), the
   data behind the viewer page.

### `cm.py`
```python
import struct,sys,json
def rd_str(d,o):
    n=d[o]; return d[o+1:o+1+n].split(b"\0")[0].decode("latin1"), o+1+n
def chunks(d,off,end):
    while off+8<=end:
        cid,size=struct.unpack_from("<II",d,off); yield cid,off+8,size; off=off+8+size
def parse(path):
    d=open(path,"rb").read(); m={"file":path.split("/")[-1]}
    for cid,b,sz in chunks(d,0,len(d)):
        if cid==0: m["magic"],m["version"],m["flags"]=struct.unpack_from("<III",d,b)
        elif cid==2:
            for sid,sb,ssz in chunks(d,b,b+sz):
                if sid==1:
                    o=sb; ntr,=struct.unpack_from("<I",d,o); o+=4
                    nfr,fps,nval=struct.unpack_from("<IfI",d,o); o+=12
                    vals=list(struct.unpack_from(f"<{nval}f",d,o)); o+=4*nval
                    parents=list(struct.unpack_from(f"<{ntr}i",d,o)); o+=4*ntr
                    names=[]
                    for i in range(ntr):
                        idx,=struct.unpack_from("<i",d,o); o+=4
                        s,o=rd_str(d,o); names.append((idx,s))
                    m.update(ntr=ntr,frames=nfr,fps=fps,values=vals,parents=parents,trnames=names,tail=sb+ssz-o)
                elif sid==4:
                    nb,=struct.unpack_from("<I",d,sb)
                    m["bindings"]=[struct.unpack_from("<6i",d,sb+4+i*24) for i in range(nb)]
                elif sid==5:
                    m["rest"]=[struct.unpack_from("<3f",d,sb+i*12) for i in range(ssz//12)]
        elif cid==7:
            n,=struct.unpack_from("<I",d,b); o=b+4
            quads=[struct.unpack_from("<10f",d,o+i*40) for i in range(n)]; o+=40*n
            mn=[]
            for i in range(n): s,o=rd_str(d,o); mn.append(s)
            maps=[]
            for i in range(n):
                idx,=struct.unpack_from("<i",d,o); o+=4; s,o=rd_str(d,o); maps.append((idx,s))
            m.update(meshes=mn,quads=quads,meshmap=maps,mtail=b+sz-o)
        elif cid==10:
            n,=struct.unpack_from("<I",d,b); o=b+4; clips=[]
            for i in range(n):
                s,o=rd_str(d,o); a,e=struct.unpack_from("<HH",d,o); o+=4; clips.append((s,a,e))
            m["clips"]=clips
        else: m.setdefault("other",[]).append((cid,sz))
    return m
if __name__=="__main__":
    m=parse(sys.argv[1])
    print({k:m[k] for k in ("file","version","ntr","frames","fps","tail","mtail") if k in m})
    print("parents",m["parents"]); print("transforms",m["trnames"])
    print("bindings",m["bindings"][:12]); print("rest",[tuple(round(x,2) for x in r) for r in m["rest"]])
    print("meshes",list(zip(m["meshes"],m["meshmap"]))[:20])
    print("quad0",[round(x,2) for x in m["quads"][0]])
    print("clips",len(m["clips"]),m["clips"])
```

### `atlas.py`
```python
import struct,re,sys,os
from PIL import Image
A="vault/05 Assets/Original Game/assets/Atlases/"
def load_pvr(p):
    d=open(p,"rb").read()
    hl,h,w,mip,flags,size,bpp,rm,gm,bm,am=struct.unpack_from("<11I",d,0)
    assert flags&0xff==0x12 and bpp==32, (p,hex(flags),bpp)
    img=Image.frombytes("RGBA",(w,h),d[hl:hl+w*h*4])
    return img.transpose(Image.FLIP_TOP_BOTTOM)
out=sys.argv[1]; names=sys.argv[2:]
for n in names:
    txt=open(A+n+".atlas").read()
    img=load_pvr(A+n+"0.pvr")
    # PVR origin: check orientation later; save whole atlas for inspection
    img.save(f"{out}/_{n}.png")
    for m in re.finditer(r'name="([^"]+)", w=(\d+), h=(\d+), x=(\d+), y=(\d+)(?:, rotated=(\w+))?',txt):
        nm,w,h,x,y,rot=m.group(1),*map(int,m.group(2,3,4,5)),m.group(6)
        img.crop((x,y,x+w,y+h)).save(f"{out}/{nm}")
    print(n, img.size, len(re.findall('name=',txt)))
```

### `render.py`
```python
import sys,math,os
sys.path.insert(0,os.path.dirname(__file__))
from cm import parse
from PIL import Image
S=os.path.dirname(__file__)+"/sprites/"
M="vault/05 Assets/Original Game/assets/Models/"
def xform_for(mesh):
    n=mesh.replace("mesh_","")
    table={"chr_head":"xform_head","chr_body":"xform_body"}
    if n in table: return table[n]
    for part in ("hand","forearm","arm","leg"):
        for side,s in (("L","l"),("R","r")):
            if n==f"chr_{part}{side}": return f"xform_{s}_{part}"
    if n.startswith("wpn_") and n.endswith("_r"): return "xform_r_hand"
    if n.startswith("wpn_") and n.endswith("_l"): return "xform_l_hand"
    if n.startswith("wpn_"): return "xform_l_hand"
    return "xform_body"
def local(m,f):
    pose=[list(r) for r in m["rest"]]
    vals=m["values"]
    for typ,cnt,off,_,tr,_ in m["bindings"]:
        pose[tr][typ]=vals[off+min(f,cnt-1)]
    return pose
def mul(a,b):
    return [a[0]*b[0]+a[2]*b[1], a[1]*b[0]+a[3]*b[1], a[0]*b[2]+a[2]*b[3], a[1]*b[2]+a[3]*b[3], a[0]*b[4]+a[2]*b[5]+a[4], a[1]*b[4]+a[3]*b[5]+a[5]]
def world(m,f):
    pose=local(m,f); W=[None]*m["ntr"]
    for i in range(m["ntr"]):
        x,y,r=pose[i]; c,s=math.cos(r),math.sin(r); L=[c,s,-s,c,x,y]
        p=m["parents"][i]; W[i]=L if p<0 else mul(W[p],L)
    return W
def render(model,frame,tex,show,scale=3,size=(220,220)):
    m=parse(M+model); W=world(m,frame)
    tname={i:n for i,n in m["trnames"]}; tidx={n:i for i,n in m["trnames"]}
    meshname={i:n for i,n in m["meshmap"]}
    canvas=Image.new("RGBA",(size[0]*scale,size[1]*scale),(205,205,205,255))
    order=sorted(range(len(m["meshes"])),key=lambda i:m["quads"][i][8])
    for i in order:
        mn=meshname[i]
        if mn not in show: continue
        q=m["quads"][i]; x0,y0,x1,y1=q[0],q[1],q[4],q[5]
        img=Image.open(S+tex(mn,m["meshes"][i])).convert("RGBA")
        T=W[tidx[xform_for(mn)]]
        # map image pixel (u,v) -> local (x0+u*(x1-x0)/w, y1-v*(y1-y0)/h) -> world -> screen (cx+X*s, cy-Y*s)
        w,h=img.size; sx=(x1-x0)/w; sy=(y1-y0)/h
        cx,cy=size[0]/2*scale,size[1]*0.8*scale
        # affine screen = A*[u,v,1]; local = [x0+u*sx, y1-v*sy]
        a,b,c_,d,e,f_=T
        # world = (a*lx+c_*ly+e, b*lx+d*ly+f_)
        # screen x = cx+scale*(a*(x0+u sx)+c_*(y1-v sy)+e); screen y = cy-scale*(b*(...)+d*(...)+f_)
        A=[scale*a*sx, -scale*c_*sy, cx+scale*(a*x0+c_*y1+e),
           -scale*b*sx, scale*d*sy, cy-scale*(b*x0+d*y1+f_)]
        # PIL transform needs inverse (screen->image)
        det=A[0]*A[4]-A[1]*A[3]
        inv=[A[4]/det,-A[1]/det,(A[1]*A[5]-A[4]*A[2])/det,-A[3]/det,A[0]/det,(A[3]*A[2]-A[0]*A[5])/det]
        layer=img.transform(canvas.size,Image.AFFINE,inv,resample=Image.BILINEAR)
        canvas.alpha_composite(layer)
    return canvas
if __name__=="__main__":
    char="graham"
    def tex(mesh,default):
        n=mesh.replace("mesh_","")
        if n.startswith("chr_"): return f"{n}_{char}_3.png"
        if n.startswith("wpn_dualRifles"): return "wpn_rifle.png"
        return n+".png"
    show={"mesh_chr_head","mesh_chr_body","mesh_chr_armL","mesh_chr_armR","mesh_chr_forearmL","mesh_chr_forearmR","mesh_chr_handL","mesh_chr_handR","mesh_chr_legL","mesh_chr_legR","mesh_wpn_dualRifles_r"}
    frames=[int(a) for a in sys.argv[1:]] or [0,77,64,90,4]
    row=Image.new("RGBA",(660*len(frames),660))
    for k,fr in enumerate(frames): row.paste(render("chr_graham.cm",fr,tex,show),(660*k,0))
    row.save(os.path.dirname(__file__)+"/graham_test.png")
```

### `export.py`
```python
import sys,os,re,json,base64,io,glob
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from cm import parse
from PIL import Image
B="vault/05 Assets/Original Game/"
M=B+"assets/Models/"; S=os.path.dirname(os.path.abspath(__file__))+"/sprites/"
IMG={}
def img_key(fn):
    if fn in IMG: return fn
    p=S+fn
    if not os.path.exists(p): return None
    im=Image.open(p).convert("RGBA"); buf=io.BytesIO(); im.save(buf,"PNG",optimize=True)
    IMG[fn]="data:image/png;base64,"+base64.b64encode(buf.getvalue()).decode(); return fn
def bone_for(mesh,bones,side_default="r"):
    n=mesh.lower().replace("mesh_","").replace("weapon_","wpn_")
    if "xform_"+mesh.replace("mesh_","") in bones: return "xform_"+mesh.replace("mesh_","")
    for part in ("forearm","hand","arm","leg"):
        for s in ("l","r"):
            if f"{part}{s}"==n.split("_")[-1] or f"{s}_{part}" in n or n.endswith(f"{part}{s}"): 
                b=f"xform_{s}_{part}"
                if b in bones: return b
    if "head" in n: return "xform_head"
    if n.startswith("wpn_"):
        if n.endswith("_l"): return "xform_l_hand"
        if n.endswith("_r"): return "xform_r_hand"
        return f"xform_{side_default}_hand"
    return "xform_body"
def base(m):
    bones={n:i for i,n in m["trnames"]}
    vals=[round(v,4) for v in m["values"]]
    return dict(fps=m["fps"],frames=m["frames"],parents=m["parents"],
        rest=[[round(a,3) for a in r] for r in m["rest"]],
        bind=[[t,o,tr] for t,c,o,_,tr,_ in m["bindings"]],values=vals,
        clips=sorted([[c,a,e] for c,a,e in m["clips"]],key=lambda c:c[1])), bones
AGENTS={"graham":"Graham → our Max Mayhem","mason":"Mason → our Brick","cowgirl":"Cowgirl (unreleased Wild West agent)",
 "carrera":"Carrera","carrera_bear":"Carrera Bear","deadZed":"Dead Zed","graham_dino":"Dino Graham","hal":"Hal",
 "mason_kitty":"Kitty Mason","wei":"Wei","rogue":"Razor (rogue)","bingoBango":"Bingo Bango","bob":"Bob"}
LEFT_WPN={"rocketLauncher"}
out=[]
for key,label in AGENTS.items():
    m=parse(M+f"chr_{key}.cm"); d,bones=base(m)
    meshname={i:n for i,n in m["meshmap"]}
    parts=[]
    for i,q in enumerate(m["quads"]):
        mn=meshname[i]; tex=m["meshes"][i]
        if mn.startswith("mesh_chr_"):
            part=mn[9:]; fn=None
            for st in (3,2,1):
                for nm in (key,key.lower()):
                    if os.path.exists(S+f"chr_{part}_{nm}_{st}.png"): fn=f"chr_{part}_{nm}_{st}.png"; break
                if fn: break
            group="body"
        else:
            fn={"weapon_gail_dual_revolver":"wpn_revolver.png"}.get(tex,tex+".png"); group=mn.replace("mesh_","")
        k=img_key(fn) if fn else None
        if not k: continue
        side="l" if any(w in mn for w in LEFT_WPN) else "r"
        parts.append(dict(bone=bones[bone_for(mn,bones,side)],q=[round(q[0],2),round(q[1],2),round(q[4],2),round(q[5],2)],z=q[8],img=k,g=group))
    d.update(id=key,label=label,kind="agent",parts=parts); out.append(d)
# enemies
ENEMY={"ninja_1":"melee grunt → Bandana Bandit","ninja_2":"spin-jumper → Rodeo Kid","ninja_3":"spin-jumper","ninja_4":"coward / lobber → Dynamite Dan",
 "ninja_5":"agile mid → Lasso Lucy","ninja_6":"berserker mid → Big Bart","ninja_7":"shield mid → Saloon Door Sam","ninja_8":"berserker boss → McGraw",
 "ninja_9":"shield boss","ninja_10":"agile minion","horror_1":"undead","horror_2":"undead","horror_3":"undead","horror_4":"skull thrower → Six-Shooter",
 "horror_5":"teleporter mid","horror_6":"berserker mid","horror_7":"stake thrower mid","horror_8":"teleport boss","horror_9":"spawn boss → Ma Rattler",
 "horror_10":"undead minion","future_1":"grunt","future_2":"hover","future_3":"hover gunner","future_4":"chain bomb","future_5":"agile mid",
 "future_6":"berserker mid","future_7":"shield mid","future_8":"spawner boss","future_9":"berserker boss","future_10":"minion"}
cache={}
def lua_block(txt,start):
    i=txt.index("{",start); depth=0
    for j in range(i,len(txt)):
        if txt[j]=="{": depth+=1
        elif txt[j]=="}":
            depth-=1
            if depth==0: return txt[i:j+1]
for eid,label in ENEMY.items():
    txt=open(B+f"scripts/Enemies/{eid}.lua").read()
    txt=re.sub(r"--[^\n]*","",txt)
    for am in re.finditer(r"ArchetypeSetup\[(\d+)\]\s*=",txt):
        blk=lua_block(txt,am.end())
        f=re.search(r'archetypeFile\s*=\s*"([^"]+)"',blk).group(1)
        if f not in cache: cache[f]=parse(M+f)
        m=cache[f]; d,bones=base(m)
        anims={}
        ab=re.search(r"anims\s*=",blk)
        if ab:
            a=lua_block(blk,ab.end())
            for s in re.finditer(r"(\w+)\s*=\s*\{([^}]*)\}",a):
                anims[s.group(1)]=re.findall(r'"([^"]+)"',s.group(2))
        meshs={}
        mb=re.search(r"meshs\s*=",blk)
        if mb:
            for s in re.finditer(r'(\w+)\s*=\s*"([^"]+)"',lua_block(blk,mb.end())): meshs[s.group(1)]=s.group(2)
        meshname={i:n for i,n in m["meshmap"]}
        parts=[]
        for i,q in enumerate(m["quads"]):
            mn=meshname[i]
            if mn not in meshs: continue
            k=img_key(meshs[mn])
            if not k: continue
            parts.append(dict(bone=bones[bone_for(mn,bones)],q=[round(q[0],2),round(q[1],2),round(q[4],2),round(q[5],2)],z=q[8],img=k,g="body"))
        n=int(am.group(1))
        d.update(id=f"{eid}" + (f"_{n}" if n>1 else ""),label=f"{eid}{'' if n==1 else f' (form {n})'}: {label}",kind="enemy",theme=eid.split("_")[0],parts=parts,states=anims,model=f)
        out.append(d)
data={"models":out,"images":IMG}
s=json.dumps(data,separators=(",",":"))
open(os.path.dirname(os.path.abspath(__file__))+"/anim_data.json","w").write(s)
print(len(out),"models",len(IMG),"images",round(len(s)/1e6,2),"MB")
for d in out: 
    if not d["parts"]: print("NO PARTS",d["id"])
```

## Converting clips to Blender (R15)
Turns an original clip into an **action on our R15 rig** (the rig in `Max_Spin.blend` and
`Max_Rifle.blend`: a bone per R15 part, pointing +Z, roll 0, see [[Blender to Roblox Animation]]),
as a **block-out to polish**, not a finished animation.

**Ready-made files** in `05 Assets/Animations/` (built 2026-10-17 on copies of the local
session's rigs; only the imported actions are in them):
- `Original_Clips_Agents.blend`: 101 actions, `Orig_Graham_*` (for Max), `Orig_Mason_*`
  (for Brick) and `Orig_Cowgirl_*`, on the rifle rig.
- `Original_Clips_Enemies.blend`: 110 actions named `Orig_<our enemy>_<STATE>_<clip>`
  (BandanaBandit, RodeoKid, DynamiteDan, LassoLucy, BigBart, SaloonDoorSam, McGraw,
  MaRattler), every clip their original's script uses.

**How the mapping works** (`to_r15.py`):
- The original only rotates bones in the screen plane, which for our side-on character is
  a rotation about each R15 joint's **local X** (+X swings a hanging limb forward, the
  same sense as the original's anticlockwise rotation).
- It measures **where each original limb points** in every frame (shoulder → elbow,
  elbow → hand, body pivot → head), not the raw bone angles, so sprite drawing offsets
  don't skew the result. The R15 angle is the one that points our limb the same way:
  body → `LowerTorso` (the Root joint), head → `Head` (Neck), arms → `UpperArm` /
  `LowerArm` / `Hand`. `UpperTorso` stays 0 (the original has one body piece).
- **Legs use two-bone IK** onto the original's foot (the bottom of the leg sprite), with
  the knee bending forward and the foot kept level, because the original's legs are
  single rigid sprites and ours have knees.
- **Head and hands** are measured against the original's rest pose.
- The body's bob is a `LowerTorso` offset, scaled by hip-to-shoulder height. **Airborne
  clips** (spin, jump, drop, hover, the leap jump) keep only the bob within the clip; the
  height comes from physics.
- **Timing is kept:** the original's 15 fps frames land on every other frame at 30 fps,
  linear in between. Loops end on the last original frame (Roblox wraps to the start).
- **Enemies** have no forearms in the original, so their elbows stay at 0.

**Checked** on 2026-10-17 by evaluating the actions in Blender 5.2 and drawing Max's rig
side-on next to the original frames: idle, run, fire, jump, spin, damage (Graham), the
cowgirl's revolver fire, Big Bart's berserker wind-up, the Bandana Bandit's sai attack
and the Rodeo Kid's spin pose all read like the original.

**Limits to fix by hand when polishing:**
- No depth: nothing twists or reaches across the body; the left hand doesn't grip a rifle
  (use step 8 of [[Blender to Roblox Animation]] for the two-handed hold).
- The original is chibi (big head, short legs), so a pose reads differently on R15
  proportions; exaggerate where needed.
- The original's `SPIN` is a held tuck: the code spins the character. Our `Max_Spin`
  already exists.
- The original's clips are longer than several of ours in [[Feel and Look Asset Specs]];
  retime in Blender or with the track's playback speed.

**Regenerate or convert other characters:**
1. `python make_clips_json.py <Name> <model.cm> clips.json [clip names…]` (all clips if
   none are given).
2. `blender <rig>.blend --python import_original_clips.py -- clips.json [out.blend]`
   adds the actions (`Orig_<Name>_<clip>`) and optionally saves a copy.
3. Polish, then export with steps 4–5 of [[Blender to Roblox Animation]].

### `to_r15.py`
```python
"""Convert an original 2D clip into R15 joint angles (rotation about each joint's local X,
Roblox's screen-plane axis for a side-on character) plus a LowerTorso offset in studs."""
import sys,os,math,json
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from cm import parse
M="vault/05 Assets/Original Game/assets/Models/"
# R15 joint heights (studs) of our rig, from Max_Rifle.blend: hip, shoulder (for scale).
R15_HIP, R15_SHOULDER = 2.19, 3.987
AIRBORNE=("SPIN","JUMP","JUMP_FIRE","DROP","JE_HOVER","NTE_JUMP","N_SPIN","N_JUMP")
R15_THIGH, R15_SHIN = 2.19-1.32, 1.32-0.393
def wrap(a):
    while a>math.pi: a-=2*math.pi
    while a<=-math.pi: a+=2*math.pi
    return a
def local_pose(m,f):
    pose=[list(r) for r in m["rest"]]
    for typ,cnt,off,_,tr,_ in m["bindings"]: pose[tr][typ]=m["values"][off+min(f,cnt-1)]
    return pose
def convert(model_file, clip_name, quads_by_bone=None):
    m=parse(M+model_file)
    idx={n:i for i,n in m["trnames"]}
    clip=next(c for c in m["clips"] if c[0]==clip_name)
    dflt=next((c for c in m["clips"] if "default_pose" in c[0]),clip)
    # leaf bones: point along their sprite's centre (body-part meshes only)
    meshname={i:n for i,n in m["meshmap"]}
    leafvec={}; legfoot={}
    for i,q in enumerate(m["quads"]):
        nn=meshname[i].lower()
        for s in "lr":
            if (nn.endswith(f"leg{s}") or nn.endswith(f"{s}_leg")) and f"xform_{s}_leg" in idx:
                legfoot[s]=((q[0]+q[4])/2, q[1])  # bottom centre of the leg sprite (the foot)
    for i,q in enumerate(m["quads"]):
        n=meshname[i].lower()
        for part,bone in (("head","xform_head"),("handl","xform_l_hand"),("handr","xform_r_hand"),("legl","xform_l_leg"),("legr","xform_r_leg"),("l_hand","xform_l_hand"),("r_hand","xform_r_hand"),("l_leg","xform_l_leg"),("r_leg","xform_r_leg")):
            if n.endswith(part) and bone in idx and bone not in leafvec:
                leafvec[bone]=((q[0]+q[4])/2,(q[1]+q[5])/2)
    child={"xform_body":"xform_head","xform_r_arm":"xform_r_forearm","xform_l_arm":"xform_l_forearm","xform_r_forearm":"xform_r_hand","xform_l_forearm":"xform_l_hand"}
    for s in "rl":
        if f"xform_{s}_forearm" not in idx: child[f"xform_{s}_arm"]=f"xform_{s}_hand"
    def frame_angles(f):
        pose=local_pose(m,f); n=m["ntr"]
        wrot=[0.0]*n; wpos=[(0.0,0.0)]*n
        for i in range(n):
            x,y,r=pose[i]; p=m["parents"][i]
            if p<0: wrot[i]=r; wpos[i]=(x,y)
            else:
                c,s=math.cos(wrot[p]),math.sin(wrot[p])
                wpos[i]=(wpos[p][0]+c*x-s*y, wpos[p][1]+s*x+c*y); wrot[i]=wrot[p]+r
        def dir_(b):
            i=idx[b]
            if b in child and child[b] in idx:
                cx,cy,_=pose[idx[child[b]]]; v=(cx,cy)
            elif b in leafvec: v=leafvec[b]
            else: v=(0,-1)
            return wrot[i]+math.atan2(v[1],v[0])
        th={b:dir_(b) for b in idx if b!="root"}
        out={}
        torso=th["xform_body"]
        out["LowerTorso"]=wrap(torso-math.pi/2)
        out["UpperTorso"]=0.0
        out["Head"]=wrap(th["xform_head"]-torso)
        for s,S in (("r","Right"),("l","Left")):
            out[f"{S}UpperArm"]=wrap(th[f"xform_{s}_arm"]-torso+math.pi)
            if f"xform_{s}_forearm" in idx:
                out[f"{S}LowerArm"]=wrap(th[f"xform_{s}_forearm"]-th[f"xform_{s}_arm"])
                out[f"{S}Hand"]=wrap(th[f"xform_{s}_hand"]-th[f"xform_{s}_forearm"])
            else:
                out[f"{S}LowerArm"]=0.0
                out[f"{S}Hand"]=wrap(th[f"xform_{s}_hand"]-th[f"xform_{s}_arm"])
            out[f"{S}UpperLeg"]=wrap(th[f"xform_{s}_leg"]-torso+math.pi)
            out[f"{S}LowerLeg"]=0.0; out[f"{S}Foot"]=0.0
        feet={}
        for s in "lr":
            i=idx[f"xform_{s}_leg"]; fx,fy=legfoot.get(s,(0,-20)); c,sn=math.cos(wrot[i]),math.sin(wrot[i])
            feet[s]=((wpos[i][0]+c*fx-sn*fy)-wpos[i][0], (wpos[i][1]+sn*fx+c*fy)-wpos[i][1], wpos[i])
        return out,wpos[idx["xform_body"]],pose,feet,torso
    # scale: original hip-to-shoulder vs ours
    _,_,p0,_,_=frame_angles(dflt[1])
    sh=p0[idx["xform_r_arm"]][1]-p0[idx["xform_r_leg"]][1]
    k=(R15_SHOULDER-R15_HIP)/max(1e-3,abs(sh))
    base_ang,base,_,feet0,_=frame_angles(dflt[1])
    L1,L2=R15_THIGH,R15_SHIN
    legk={s:(L1+L2)*0.98/max(1e-3,math.hypot(feet0[s][0],feet0[s][1])) for s in "lr"}
    # Head and hands: measure against the original's rest pose, so their sprites' drawing
    # offset doesn't become a permanent tilt.
    CAL=("Head","RightHand","LeftHand")
    frames=[]
    for f in range(clip[1],clip[2]+1):
        ang,bp,_,feet,torso=frame_angles(f)
        for j in CAL: ang[j]=wrap(ang[j]-base_ang[j])
        # Legs: two-bone IK onto the original's foot, knee forward, foot kept level.
        for s,S in (("r","Right"),("l","Left")):
            dx,dy=feet[s][0]*legk[s],feet[s][1]*legk[s]
            d=min(max(math.hypot(dx,dy),abs(L1-L2)+1e-3),L1+L2-1e-3)
            psi=math.atan2(dx,-dy)
            a=math.acos((L1*L1+d*d-L2*L2)/(2*L1*d)); b=math.acos((L2*L2+d*d-L1*L1)/(2*L2*d))
            th,sh=psi+a,psi-b
            ang[f"{S}UpperLeg"]=wrap(th-(torso-math.pi/2))
            ang[f"{S}LowerLeg"]=wrap(sh-th)
            ang[f"{S}Foot"]=wrap(-sh)
        # LowerTorso offset in its joint space: X right, Y up, Z back (forward = -Z)
        frames.append({"angles":{k_:round(v,4) for k_,v in ang.items()},"offset":[0.0,round((bp[1]-base[1])*k,4),round(-(bp[0]-base[0])*k,4)]})
    # Airborne clips: height comes from physics, so keep only the bob within the clip.
    if any(clip_name.upper().startswith(a) for a in AIRBORNE):
        y0,z0=frames[0]["offset"][1],frames[0]["offset"][2]
        for fr in frames: fr["offset"][1]=round(fr["offset"][1]-y0,4); fr["offset"][2]=round(fr["offset"][2]-z0,4)
    return {"model":model_file,"clip":clip_name,"fps":m["fps"],"frames":frames,"scale":k}
if __name__=="__main__":
    r=convert(sys.argv[1],sys.argv[2])
    print(r["clip"],len(r["frames"]),"frames, scale",round(r["scale"],4))
    for fr in r["frames"][:3]: print({k:round(math.degrees(v)) for k,v in fr["angles"].items()},fr["offset"])
```

### `make_clips_json.py`
```python
import sys,os,json
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from to_r15 import convert
from cm import parse
M="vault/05 Assets/Original Game/assets/Models/"
out=[]; char,model=sys.argv[1],sys.argv[2]; wanted=sys.argv[4:]
names=[c[0] for c in parse(M+model)["clips"]] if not wanted else wanted
for n in names:
    if "default_pose" in n: continue
    r=convert(model,n); r["character"]=char; out.append(r)
json.dump(out,open(sys.argv[3],"w"),separators=(",",":")); print(len(out),"clips ->",sys.argv[3])
```

### `import_original_clips.py` (runs inside Blender)
```python
"""Blender (5.x) importer: builds actions on an R15 rig (bones named like the R15 parts,
pointing +Z, roll 0, as in Max_Spin.blend / Max_Rifle.blend) from clips converted by
to_r15.py. Run inside Blender:  blender rig.blend --python import_original_clips.py -- clips.json
Each clip becomes an action "Orig_<character>_<clip>" keyed at 30 fps (the original's 15 fps
frames land on even frames, linear in between), rotation about each bone's local X."""
import bpy, json, sys
args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
clips = json.load(open(args[0]))
rig = next(o for o in bpy.data.objects if o.type == "ARMATURE")
scene = bpy.context.scene
scene.render.fps = 30
bpy.context.preferences.edit.keyframe_new_interpolation_type = "LINEAR"
if rig.animation_data is None:
    rig.animation_data_create()
made = []
for c in clips:
    name = f"Orig_{c['character']}_{c['clip']}"
    old = bpy.data.actions.get(name)
    if old:
        bpy.data.actions.remove(old)
    act = bpy.data.actions.new(name)
    act.use_fake_user = True
    rig.animation_data.action = act
    step = round(30 / c.get("fps", 15))
    for i, fr in enumerate(c["frames"]):
        frame = i * step
        for bone, angle in fr["angles"].items():
            pb = rig.pose.bones.get(bone)
            if pb is None:
                continue
            pb.rotation_mode = "XYZ"
            pb.rotation_euler = (angle, 0.0, 0.0)
            pb.keyframe_insert("rotation_euler", frame=frame, group=bone)
        lt = rig.pose.bones.get("LowerTorso")
        if lt is not None:
            lt.location = fr["offset"]
            lt.keyframe_insert("location", frame=frame, group="LowerTorso")
    act["source"] = f"Storm the Train: {c['model']} / {c['clip']} (reference)"
    act.frame_range = (0, (len(c["frames"]) - 1) * step)
    made.append(name)
# leave every bone at rest when no action plays, and show the first clip
for pb in rig.pose.bones:
    pb.rotation_euler = (0, 0, 0); pb.location = (0, 0, 0)
rig.animation_data.action = bpy.data.actions.get(made[0]) if made else None
if len(args) > 1:
    bpy.ops.wm.save_as_mainfile(filepath=args[1])
print("Imported", len(made), "actions:", ", ".join(made))
```

## Notes
- Agents use the `_3` (full armour) texture of each part; enemies take their textures and
  weapons from their `scripts/Enemies/*.lua` archetype.
- `weapon_gail_dual_revolver` (the cowgirl's) isn't in any atlas; `export.py` uses
  `wpn_revolver.png` instead.
- The mesh-to-bone mapping is by name; the original's archetype code (not decoded) may
  differ for unusual meshes (backpacks, shields).

Related: [[Original Game - Animations]] · [[Blender to Roblox Animation]] · [[Techniques]]
