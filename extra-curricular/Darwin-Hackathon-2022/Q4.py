from PIL import Image
import numpy
from numpy import random

im = Image.open("darwin.png")
px1 = im.load()
px2 = px1
width, height = im.size

def val(x,y) :
    if x==690 : x=0
    if x==-1 : x=689
    if y==690 : y=0
    if y==-1 : y=689
    return bool(px1[x,y][0])

for iteration in range (420) :
    for i in range (random.randint(width*2,width*width)) :
        posx = random.randint(0,690)
        posy = random.randint(0,690)
        if (posx<width/2 and posy<height/2) :
            if not(val(posx-1,posy-1)) and not(val(posx,posy-1)) and not(val(posx+1,posy-1)) and not(val(posx-1,posy)) and not(val(posx+1,posy)) and not(val(posx-1,posy+1)) and not(val(posx,posy+1)) and not(val(posx+1,posy+1)) : px2[posx,posy] = (0, 0, 0)
            elif val(posx-1,posy-1) and val(posx,posy-1) and val(posx+1,posy-1) and val(posx-1,posy) and val(posx+1,posy) and val(posx-1,posy+1) and val(posx,posy+1) and val(posx+1,posy+1) : px2[posx,posy] = (1, 1, 1)
            else :
                a = int(((val(posx-1,posy-1) and val(posx,posy-1) and val(posx+1,posy-1)) or (val(posx-1,posy) and val(posx,posy) and val(posx+1,posy)) or (val(posx-1,posy+1) and val(posx,posy+1) and val(posx+1,posy+1)) or (val(posx,posy-1) and val(posx+1,posy-1))))
                px2[posx,posy] = (a, a, a)
        if (posx>=width/2 and posy<height/2) :
            if not(val(posx-1,posy-1)) and not(val(posx,posy-1)) and not(val(posx+1,posy-1)) and not(val(posx-1,posy)) and not(val(posx+1,posy)) and not(val(posx-1,posy+1)) and not(val(posx,posy+1)) and not(val(posx+1,posy+1)) : px2[posx,posy] = (0, 0, 0)
            elif val(posx-1,posy-1) and val(posx,posy-1) and val(posx+1,posy-1) and val(posx-1,posy) and val(posx+1,posy) and val(posx-1,posy+1) and val(posx,posy+1) and val(posx+1,posy+1) : px2[posx,posy] = (1, 1, 1)
            else :
                a = int(((val(posx-1,posy-1) and val(posx,posy-1) and val(posx+1,posy-1)) or (val(posx-1,posy) and val(posx,posy) and val(posx+1,posy)) or (val(posx-1,posy+1) and val(posx,posy+1) and val(posx+1,posy+1)) or (val(posx,posy) and val(posx+1,posy))))
                px2[posx,posy] = (a, a, a)
        if (posx<width/2 and posy>=height/2) :
            if not(val(posx-1,posy-1)) and not(val(posx,posy-1)) and not(val(posx+1,posy-1)) and not(val(posx-1,posy)) and not(val(posx+1,posy)) and not(val(posx-1,posy+1)) and not(val(posx,posy+1)) and not(val(posx+1,posy+1)) : px2[posx,posy] = (0, 0, 0)
            elif val(posx-1,posy-1) and val(posx,posy-1) and val(posx+1,posy-1) and val(posx-1,posy) and val(posx+1,posy) and val(posx-1,posy+1) and val(posx,posy+1) and val(posx+1,posy+1) : px2[posx,posy] = (1, 1, 1)
            else :
                a = int(((val(posx-1,posy-1) and val(posx,posy-1) and val(posx+1,posy-1)) or (val(posx-1,posy) and val(posx,posy) and val(posx+1,posy)) or (val(posx-1,posy+1) and val(posx,posy+1) and val(posx+1,posy+1)) or (val(posx,posy+1) and val(posx+1,posy+1))))
                px2[posx,posy] = (a, a, a)
        if (posx>=width/2 and posy>=height/2) :
            if not(val(posx-1,posy-1)) and not(val(posx,posy-1)) and not(val(posx+1,posy-1)) and not(val(posx-1,posy)) and not(val(posx+1,posy)) and not(val(posx-1,posy+1)) and not(val(posx,posy+1)) and not(val(posx+1,posy+1)) : px2[posx,posy] = (0, 0, 0)
            elif val(posx-1,posy-1) and val(posx,posy-1) and val(posx+1,posy-1) and val(posx-1,posy) and val(posx+1,posy) and val(posx-1,posy+1) and val(posx,posy+1) and val(posx+1,posy+1) : px2[posx,posy] = (1, 1, 1)
            else :
                a = int(((val(posx-1,posy-1) and val(posx,posy-1) and val(posx+1,posy-1)) or (val(posx-1,posy) and val(posx,posy) and val(posx+1,posy)) or (val(posx-1,posy+1) and val(posx,posy+1) and val(posx+1,posy+1)) or (val(posx-1,posy-1) and val(posx+1,posy-1))))
                px2[posx,posy] = (a, a, a)
        px1=px2


data = numpy.zeros((height, width, 3), dtype=numpy.uint8)
for x in range (690) :
    for y in range (690) :
        data[y, x] = list(px1[x, y])
img = Image.fromarray(data, 'RGB')
img.save('my.png')

