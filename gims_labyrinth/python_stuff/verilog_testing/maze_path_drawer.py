import matplotlib.pyplot as plt
import numpy as np
import imageio

#bin_maze_im = (imageio.imread("../test_imgs/maze_noiseless.bmp") > 0).astype(int)
#bin_maze_im = (imageio.imread("../test_imgs/maze_complicated.bmp") > 0).astype(int)
#bin_maze_im = (imageio.imread("../test_imgs/real_maze.png") > 0).astype(int)
bin_maze_im = imageio.imread("../test_imgs/real_maze.png")
path_pts = []
with open("maze_sol.txt", 'r') as f:
    lines = f.readlines()
    for line in lines:
        x = int(line[0:9],2)
        y = int(line[9:17],2)
        path_pts.append([x, y])

plt.figure()
plt.imshow(bin_maze_im, cmap='Greys')
plt.plot(*zip(*path_pts), c="b")
plt.show()
