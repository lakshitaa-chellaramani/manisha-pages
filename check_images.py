from PIL import Image
import glob, os
for path in glob.glob('pictures/*.webp'):
    img = Image.open(path)
    print(path, img.format, img.size)
    newpath = os.path.splitext(path)[0] + '.jpg'
    img.convert('RGB').save(newpath, 'JPEG', quality=85)
    print('converted', path, '->', newpath)