#!/usr/bin/env python3
"""A CORRECT MD3 reader, because the one I used all night was not.

MD3 SURFACE HEADER, byte offsets from the start of the surface -- written out because getting two of
these wrong is what produced "no shader name inside", which is what drove a whole argument about
whether the Star Wars models had textures:

    0  ident          4  name[64]      68 flags         72 numFrames
    76 numShaders    80 numVerts      84 numTriangles  88 ofsTriangles
    92 ofsShaders    96 ofsSt         100 ofsXyzNormal 104 ofsEnd

I read numShaders from +68 (that is FLAGS, always 0) and numVerts from +76 (that is numShaders).
Every surface therefore "had no shader", and every vertex count was wrong.
"""
import struct


def read(data):
    """{'frames', 'surfaces': [{'name','shaders','verts'}]} or None."""
    if data[:4] != b"IDP3":
        return None
    nframes = struct.unpack_from("<i", data, 76)[0]
    nsurf = struct.unpack_from("<i", data, 84)[0]
    off = struct.unpack_from("<i", data, 100)[0]
    surfs = []
    for _ in range(nsurf):
        name = data[off + 4:off + 68].split(b"\0")[0].decode("latin1")
        nsh = struct.unpack_from("<i", data, off + 76)[0]
        nv = struct.unpack_from("<i", data, off + 80)[0]
        osh = struct.unpack_from("<i", data, off + 92)[0]
        oxyz = struct.unpack_from("<i", data, off + 100)[0]
        oend = struct.unpack_from("<i", data, off + 104)[0]
        shaders = [data[off + osh + i * 68: off + osh + i * 68 + 64].split(b"\0")[0].decode("latin1")
                   for i in range(nsh)]
        verts = []
        for i in range(nv):          # frame 0 only
            x, y, z = struct.unpack_from("<hhh", data, off + oxyz + i * 8)
            verts.append((x / 64.0, y / 64.0, z / 64.0))
        surfs.append({"name": name, "shaders": shaders, "verts": verts})
        off += oend
    return {"frames": nframes, "surfaces": surfs}
