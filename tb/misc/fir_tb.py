import commpy
import numpy as np

###
import matplotlib.pyplot as plt
###

from fixedpoint import FixedPoint

coefs = [-6.518263187043542e-19, -7.986557578197472e-04, -0.002095202987291, -0.003667107969085, -0.005116643415385, -0.005928729916395, -0.005574799504880, -0.003647417401953, 4.178988515525191e-18, 0.005140327380087, 0.011118819256345, 0.016883231769783, 0.021109413050609, 0.022415483902514, 0.019637994970885, 0.012126229259175, -8.833912267524514e-18, -0.015685124676703, -0.032911842822594, -0.048841462160068, -0.060120550944356, -0.063323725395885, -0.055474603586424, -0.034566931655455, 1.284346534816169e-17, 0.047150897274960, 0.104087211505337, 0.166488826877401, 0.228951469309608, 0.285607773393619, 0.330847986488195, 0.360037028336954, 0.370121787174637, 0.360037028336954, 0.330847986488195, 0.285607773393619, 0.228951469309608, 0.166488826877401, 0.104087211505337, 0.047150897274960, 1.284346534816169e-17, -0.034566931655455, -0.055474603586424, -0.063323725395885, -0.060120550944356, -0.048841462160068, -0.032911842822594, -0.015685124676703, -8.833912267524514e-18, 0.012126229259175, 0.019637994970885, 0.022415483902514, 0.021109413050609, 0.016883231769783, 0.011118819256345, 0.005140327380087, 4.178988515525191e-18, -0.003647417401953, -0.005574799504880, -0.005928729916395, -0.005116643415385, -0.003667107969085, -0.002095202987291, -7.986557578197472e-04]
coefs_fxp = [FixedPoint(i, True, m=1, n=29) for i in coefs]

for i in coefs:
    print(bin(FixedPoint(i, True, m=1, n=29))[2:].zfill(30))
    
    

def save_vector_to_file(vect, f_name):
    f = open(f_name, "wb")
    print(len(vect[0]))
    for i in range(len(vect[0])):
        f.write(int(vect[0][i]).to_bytes(length=2, byteorder="big", signed=True)) #write i
        f.write(int(vect[1][i]).to_bytes(length=2, byteorder="big", signed=True)) #write q
    f.close()
    
fs = 10**7
in_len = 10**3

#create and normalize filter response

# t_idx, h_rrc = commpy.filters.rrcosfilter(64, 0.35, 8/fs, fs)
h_rrc = np.array(coefs)
h_rrc = h_rrc/(sum([i**2 for i in coefs])/len(coefs))**0.5
# h_rrc = np.array(h_rrc)/(sum(h_rrc**2)**0.5)
# h_rrc = h_rrc/sum(np.abs(h_rrc))
# print(h_rrc)
# print(sum(np.abs(h_rrc)))
# h_rrc = h_rrc / max(np.abs(np.fft.fft(h_rrc))) / 1.44

plt.figure()
plt.plot(h_rrc, "x")
# plt.figure()
# plt.plot(np.abs(np.fft.fft(h_rrc)), 'x-')
# plt.show()

# generate vector

# in_vect_i, in_vect_q = np.array([[i]*8 for i in np.random.choice([1.0, -1.0], size=in_len)]).flatten(), np.array([[i]*8 for i in np.random.choice([1.0, -1.0], size=in_len)]).flatten()
in_vect_i = [1.0,-1.0,1.0,-1.0,1.0,1.0,-1.0,-1.0,-1.0,-1.0,1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,-1.0,-1.0,1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,1.0,1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,1.0,-1.0,-1.0,-1.0,-1.0,1.0,-1.0,-1.0,1.0,1.0,-1.0,-1.0,1.0,1.0,1.0]
in_vect_q = [1.0,-1.0,1.0,-1.0,1.0,1.0,-1.0,-1.0,-1.0,-1.0,1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,1.0,1.0,-1.0,1.0,-1.0,1.0,-1.0,-1.0,1.0,1.0,1.0,-1.0,-1.0,1.0,1.0,1.0,-1.0,1.0,1.0,-1.0,1.0,1.0,-1.0,-1.0,-1.0]
out_vect_i, out_vect_q = np.correlate(in_vect_i, h_rrc), np.correlate(in_vect_q, h_rrc) # *(2**11-1) *(2**11-1)

#save vectors

save_vector_to_file([in_vect_i, in_vect_q], "vectors.in")
save_vector_to_file([out_vect_i, out_vect_q], "vectors.out")

plt.figure()
plt.plot(in_vect_i, "x")

plt.figure()
plt.plot(np.abs(np.fft.fft(out_vect_i)), "x")

plt.show()