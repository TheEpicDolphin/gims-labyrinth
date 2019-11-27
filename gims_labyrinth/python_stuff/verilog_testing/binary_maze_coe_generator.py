import numpy as np
import imageio



def bin_maze_coe_gen(bin_maze_im):
    "memory_initialization_radix=2;\nmemory_initialization_vector="
    bin_img_contents = "memory_initialization_radix=2;\nmemory_initialization_vector=\n"
    r, c = bin_maze_im.shape
    print(r,c)
    for i in range(r):
        for j in range(c):
            if(i == r - 1 and j == c - 1):
                bin_img_contents += '{:01b}'.format(bin_maze_im[i,j]) + ";\n"
            else:
                bin_img_contents += '{:01b}'.format(bin_maze_im[i,j]) + ",\n"

    with open("bin_maze.coe", 'w') as f:
        f.write(bin_img_contents)
    return None

bin_maze_im = (imageio.imread("../test_imgs/skel.png") > 0).astype(int)
bin_maze_coe_gen(bin_maze_im)
