import numpy as np
import imageio # install this with `pip install imageio`
import matplotlib.pyplot as plt

def get_pixel(image, x, y, extending=True, default_value=0):
    new_x = min(max(x, 0), len(image[0])-1)
    new_y = min(max(y, 0), len(image)-1)
    return image[new_y][new_x] if extending else default_value


def get_neighbors(image, center, kernel_size=(3, 3), extending=True, default_value=0):
    center_x, center_y = center
    # assuming kernel size is tuple of odd integers
    kernel_width, kernel_height = kernel_size
    neighbors = []
    for delta_x in range(-kernel_width//2+1, kernel_width//2+1):
        for delta_y in range(-kernel_height//2+1, kernel_height//2+1):
            neighbors.append(get_pixel(image, center_x+delta_x, center_y+delta_y,
                                       extending, default_value))
    return neighbors


def apply_filter(image, kernel_size=(9, 9), erosion=True, extending=True, default_value=0):
    filtered_image = []
    for y in range(len(image)):
        row = []
        for x in range(len(image[0])):
            center = (x, y)
            center_neighbors = get_neighbors(image, center, kernel_size, extending, default_value)
            if erosion:
                row.append(min(center_neighbors))
            else:
                row.append(max(center_neighbors))
        filtered_image.append(row)
    return filtered_image

'''
test_image = [[1, 1, 1, 0, 1],
              [1, 1, 0, 0, 0],
              [1, 1, 0, 1, 0],
              [1, 1, 0, 0, 0]]
'''
#test_image = imageio.imread("black-white-small-noisy.bmp") > 0
#test_image = test_image.astype(int)

test_image = imageio.imread("test_imgs/maze_gen.bmp") > 0
test_image = test_image.astype(int)

eroded = apply_filter(test_image)
print('After erosion:')
#for line in eroded:
#    print(line)

print('\n')
print('After dilation:')
dilated = apply_filter(eroded, erosion=False)
#for line in dilated:
#    print(line)

plt.figure()
plt.imshow(test_image, cmap='Greys')
plt.figure()
plt.imshow(eroded, cmap='Greys')
plt.figure()
plt.imshow(dilated, cmap='Greys')
plt.show()

