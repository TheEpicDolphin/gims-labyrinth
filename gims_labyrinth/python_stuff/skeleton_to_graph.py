import matplotlib.pyplot as plt
import numpy as np
import imageio
from scipy import ndimage

# Load maze


#skel_img = (imageio.imread("test_imgs/mock_skel.bmp") > 0).astype(int)
skel_img = (imageio.imread("test_imgs/skel.png") > 0).astype(int)
#skel_img = (imageio.imread("test_imgs/skel2.png") > 0).astype(int)

iterations = 30
r, c = skel_img.shape
node_pos = []

for i in range(3, r - 3):
    print(i)
    for j in range(3, c - 3):            
        win = skel_img[i - 3 : i + 4, j - 3 : j + 4]

        k_90 = (win[2,0] | win[3,0] | win[4,0]) and \
               (win[2,1] | win[3,1] | win[4,1]) and \
               (win[2,2] | win[3,2] | win[4,2])
                
        k_270 =(win[2,4] | win[3,4] | win[4,4]) and \
               (win[2,5] | win[3,5] | win[4,5]) and \
               (win[2,6] | win[3,6] | win[4,6])
        
        k_0 =  (win[4,2] | win[4,3] | win[4,4]) and \
               (win[5,2] | win[5,3] | win[5,4]) and \
               (win[6,2] | win[6,3] | win[6,4])

        k_180 =(win[0,2] | win[0,3] | win[0,4]) and \
               (win[1,2] | win[1,3] | win[1,4]) and \
               (win[2,2] | win[2,3] | win[2,4])
        
        #k_45 = (win[4,2] & win[5,1]) & ((win[5,0] ^ win[6,0] ^ win[6,1]) and not (win[5,0] & win[6,0] & win[6,1]))
        #k_135 =(win[2,2] & win[1,1]) & ((win[1,0] ^ win[0,0] ^ win[1,0]) and not (win[1,0] & win[0,0] & win[1,0]))
        #k_225 =(win[1,5] & win[2,4]) & ((win[0,5] ^ win[0,6] ^ win[1,6]) and not (win[0,5] & win[0,6] & win[1,6]))
        #k_315 =(win[4,4] & win[5,5]) & ((win[5,6] ^ win[6,6] ^ win[6,5]) and not (win[5,6] & win[6,6] & win[6,5]))

        node_mark = ((k_0 and k_90) or (k_90 and k_180) or (k_180 and k_270) or (k_270 and k_0)) or \
                    ((k_0 and k_90 and k_180) or (k_90 and k_180 and k_270) or (k_180 and k_270 and k_0) or (k_270 and k_0 and k_90)) or \
                    (k_0 and k_90 and k_180 and k_270)

        '''
        node_mark = ((k_0 and k_90) or (k_90 and k_180) or (k_180 and k_270) or (k_270 and k_0)) or \
                    ((k_0 and k_90 and k_180) or (k_90 and k_180 and k_270) or (k_180 and k_270 and k_0) or (k_270 and k_0 and k_90)) or \
                    (k_0 and k_90 and k_180 and k_270) or \
                    ((k_45 and k_135) or (k_135 and k_225) or (k_225 and k_315) or (k_315 and k_45)) or \
                    ((k_45 and k_135 and k_225) or (k_135 and k_225 and k_315) or (k_225 and k_315 and k_45) or (k_315 and k_45 and k_135)) or \
                    (k_45 and k_135 and k_225 and k_315) or \
                    ((k_225 and k_0) or (k_135 and k_0) or (k_45 and k_180) or (k_225 and k_180)) or \
                    ((k_135 and k_270) or (k_45 and k_270) or (k_225 and k_90) or (k_315 and k_90)) or \
                    ((k_0 and k_135 and k_225) or (k_90 and k_225 and k_315) or (k_180 and k_45 and k_315) or (k_270 and k_45 and k_135))
                    
        '''
        if(node_mark and (win[3,3] == 1)):
            node_pos.append([j,i])

print(len(node_pos))
node_pos = np.array(node_pos)
plt.figure()
plt.imshow(skel_img, cmap='Greys')
plt.scatter(node_pos[:,0], node_pos[:,1], color='red')
plt.show()

