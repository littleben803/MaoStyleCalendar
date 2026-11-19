from pathlib import Path
from PIL import Image, ImageChops
p=Path(__file__).parent
master=Image.open(p/'panorama-zh-master.png')
assert master.size==(4824,2622) and master.mode=='RGB'
for i,name in enumerate(['01-widgets-zh.png','02-today-zh.png','03-yearbook-zh.png','04-wallpaper-zh.png']):
    crop=master.crop((i*1206,0,(i+1)*1206,2622))
    crop.save(p/name,dpi=(72,72))
    assert ImageChops.difference(Image.open(p/name),crop).getbbox() is None
