import argparse
import os

from PIL import Image

parser = argparse.ArgumentParser(
        description='Convert GIF into frames and then create '
                    'AnimatedTexture .tres')
parser.add_argument('gif', help='GIF to process')
args = parser.parse_args()

name = os.path.splitext(args.gif)[0]

frames = []

# Break GIF into PNG frames.
with Image.open(args.gif) as im:
    fps = 1 / (im.info['duration'] / 1000.)
    n_frames = im.n_frames

    for i in range(n_frames):
        im.seek(i)
        fn = '{}-{}.png'.format(name, i)
        im.save(fn)
        frames.append(fn)

header = '[gd_resource type="AnimatedTexture" load_steps={} format=2]\n\n'\
            .format(n_frames + 1)
ext_resource = '[ext_resource path="res://{}" type="Texture" id={}]\n'
resource = """[resource]
frames = {}
fps = {}
"""

# Create .tres file.
with open(name + '.tres', 'w') as tres:
    tres.write(header)

    for i, frame in enumerate(frames, 1):
        tres.write(ext_resource.format(frame, i))
    tres.write('\n')

    tres.write(resource.format(n_frames, fps))

    frame_data = ('frame_{0}/texture = ExtResource( {1} )\n'
                  'frame_{0}/delay_sec = 0.0\n')

    for i in range(n_frames):
        if i == 0:
            no_delay = frame_data.splitlines()[0]
            tres.write(no_delay.format(i, i+1) + '\n')
            continue

        tres.write(frame_data.format(i, i+1))