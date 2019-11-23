import numpy as np


f_contents = ""
for n in range(1, 64):
    w = np.random.randint(100)
    bp = np.random.randint(1, 64)
    print('{:04x}'.format(w) + '{:03x}'.format(n) + '{:03x}'.format(bp))
    f_contents += '{:016b}'.format(w) + '{:010b}'.format(n) + '{:010b}'.format(bp) + "\n"
with open("min_heap_input.txt", 'w') as f:
    f.write(f_contents)
    
