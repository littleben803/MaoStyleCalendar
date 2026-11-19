from pathlib import Path
from PIL import Image,ImageChops
import hashlib,json
p=Path(__file__).parent
out=p.parent.parent/'zh-Hans'/'20261113';out.mkdir(parents=True,exist_ok=True)
master=Image.open(p/'panorama-ipad-zh-master.png');assert master.size==(8256,2752) and master.mode=='RGB'
rows=[]
for i,name in enumerate(['01-widgets-ipad-zh.png','02-today-ipad-zh.png','03-yearbook-ipad-zh.png','04-wallpaper-ipad-zh.png']):
    crop=master.crop((i*2064,0,(i+1)*2064,2752));crop.save(out/name,dpi=(72,72))
    im=Image.open(out/name);assert im.size==(2064,2752) and im.mode=='RGB'
    assert ImageChops.difference(im,crop).getbbox() is None
    rows.append({'file':name,'size':im.size,'mode':im.mode,'sha256':hashlib.sha256((out/name).read_bytes()).hexdigest(),'exact_master_slice':True})
master.resize((2477,826),Image.Resampling.LANCZOS).save(p/'four-page-preview.png')
(out/'manifest.json').write_text(json.dumps({'date':'2026-11-13','platform':'iPad 13 inch','locale':'zh-Hans','status':'user_visual_approved_archived','size':[2064,2752],'master_size':master.size,'spec_source':'User supplied App Store Connect screenshot; supported 2064x2752 portrait selected','artwork':'Creative promotional illustration, not runtime screenshots','uploaded':False,'packaged':True,'archived_final':True,'files':rows},ensure_ascii=False,indent=2))
print('4 independent 2064x2752 RGB portrait PNGs, exact master slices: PASS')
