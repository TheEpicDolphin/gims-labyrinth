import numpy as np
import imageio



def bin_maze_coe_gen(bin_maze_im):
    "memory_initialization_radix=2;\nmemory_initialization_vector="
    coe_contents = "memory_initialization_radix=2;\nmemory_initialization_vector=\n"
    r, c = bin_maze_im.shape
    for i in range(r):
        for j in range(c):
            if(i == r - 1 and j == c - 1):
                coe_contents += '{:01b}'.format(bin_maze_im[i,j]) + ";\n"
            else:
                coe_contents += '{:01b}'.format(bin_maze_im[i,j]) + ",\n"

    with open("bin_maze.coe", 'w') as f:
        f.write(coe_contents)
    return None

bin_maze_im = (imageio.imread("../test_imgs/skel.png") > 0).astype(int)
bin_maze_coe_gen(bin_maze_im)

def pixel_type_map_coe_gen(bin_maze_im):
    r, c = bin_maze_im.shape
    segmented_img = np.zeros((r,c))
    segmented_img = segmented_img.astype(np.uint8)
    
    #assign start
    segmented_img[12:18, 42:56] = 2
    
    #assign end
    segmented_img[216:226,186:196] = 3

    "memory_initialization_radix=2;\nmemory_initialization_vector="
    coe_contents = "memory_initialization_radix=2;\nmemory_initialization_vector=\n"
    for i in range(r):
        for j in range(c):
            if(i == r - 1 and j == c - 1):
                coe_contents += '{:02b}'.format(segmented_img[i,j]) + ";\n"
            else:
                coe_contents += '{:02b}'.format(segmented_img[i,j]) + ",\n"

    with open("pixel_type_map.coe", 'w') as f:
        f.write(coe_contents)
    return None
    
pixel_type_map_coe_gen(bin_maze_im)
