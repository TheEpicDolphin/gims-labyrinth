import numpy as np
import imageio
from scipy import signal
import matplotlib.pyplot as plt

'''
im = np.array([[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 1, 1, 1, 1, 1, 1, 1, 0],
            [1, 1, 1, 0, 1, 1, 0, 1, 1, 0],
            [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
            [0, 1, 1, 0, 1, 1, 1, 1, 1, 0],
            [0, 0, 1, 1, 1, 1, 0, 1, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
            [0, 0, 1, 1, 1, 1, 0, 1, 1, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 1, 0]])

im = np.array([[0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
             [0, 1, 1, 1, 1, 1, 0, 1, 0, 0],
             [0, 0, 1, 1, 0, 0, 0, 1, 1, 0],
             [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
             [0, 1, 0, 1, 0, 0, 0, 1, 1, 0],
             [0, 0, 0, 0, 1, 1, 0, 1, 1, 0],
             [0, 1, 1, 1, 0, 0, 1, 1, 0, 0],
             [0, 1, 1, 0, 1, 0, 1, 0, 1, 0],
             [0, 1, 0, 0, 0, 1, 1, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 1, 0, 0, 0]])

im = imageio.imread("test_imgs/black-white-small-noisy.bmp") > 0
im = im.astype(int)
'''
im = imageio.imread("test_imgs/maze_gen.bmp") > 0
im = im.astype(int)
filt_img = signal.medfilt(im, (11, 11))

plt.figure()
plt.imshow(im, cmap='Greys')

plt.figure()
plt.imshow(filt_img, cmap='Greys')
plt.show()
imageio.save("for_luis.bmp")

