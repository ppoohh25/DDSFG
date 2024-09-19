import math

f = open("coefficient3.mi","w")

f.write("#File_format=Hex\n")
f.write("#Address_depth=2048\n")
f.write("#Data_width=48\n")

n = 100

for i in range(0,2048):
    alpha1 = math.sin(2*math.pi*n/24000) * 0.95
    alpha = round(alpha1 *536870912, 0)
    alpha = int(alpha) >> 4

    y11 = math.cos(2*math.pi*n/24000) 
    y12 = round (y11 * 1073741824, 0)
    y1 = (int(y12) & 0x03FFFFFC) >> 2

    if (n <= 1000):
        f.write("%06x%06x \n" % (alpha, y1))
        n = n + 0.5
    else :
        f.write("%06x%06x \n" % (0, 0))
        n = n + 0.5
