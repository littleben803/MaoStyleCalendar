from pathlib import Path
from PIL import Image,ImageChops
import hashlib,json,zipfile
p=Path(__file__).parent
out=p.parent.parent/'zh-Hans'/'20261113';out.mkdir(parents=True,exist_ok=True)
master=Image.open(p/'panorama-DUO-zh-master.png');assert master.size==(8028,2853) and master.mode=='RGB'
rows=[]
for i,name in enumerate(['01-widgets-DUO-zh.png','02-today-DUO-zh.png','03-yearbook-DUO-zh.png','04-wallpaper-DUO-zh.png']):
    crop=master.crop((i*2007,0,(i+1)*2007,2853))
    crop.save(out/name,dpi=(72,72))
    check=Image.open(out/name)
    assert check.size==(2007,2853) and check.mode=='RGB'
    assert ImageChops.difference(check,crop).getbbox() is None
    rows.append({'file':name,'size':check.size,'mode':check.mode,'sha256':hashlib.sha256((out/name).read_bytes()).hexdigest(),'exact_master_slice':True})
(out/'manifest.json').write_text(json.dumps({'status':'user_visual_approved_archived','date':'2026-11-13','platform':'DUO portrait simulator hardware reference','locale':'zh-Hans','spec_source':'User supplied App Store Connect screenshot, portrait 2007x2853','master_size':master.size,'artwork':'Creative promotion: asymmetric simulator chassis, upper-right camera; widgets and today/detail cards float beyond screen; not runtime screenshots','uploaded':False,'files':rows},ensure_ascii=False,indent=2))
print('4 exact 2007x2853 RGB preview slices: PASS')
