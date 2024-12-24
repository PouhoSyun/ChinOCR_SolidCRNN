import os

dir = 'images'
files = os.listdir(dir)

for i, file in enumerate(files):
    os.rename(dir + '/' + file, dir + '/' + str(i) + '.png')