lines = []
with open("hsv.txt") as f:
    lines = f.readlines()
for line in lines:
    h_str = line[0:5]
    s_str = line[5:7]
    v_str = line[7:]
    h = int(h_str[0:3], 16) + int(h_str[3:5], 16)/2**8
    s = int(s_str, 16) / 2**8
    v = int(v_str, 16) / 2**8
    print("h:", h, "s:", s, "v:", v)
    
