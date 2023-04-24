import numpy as np
from header_tb import add_header
from fir_tb import coefs, save_vector_to_file
import scipy.signal as signal

def qpsk(data_in):
    AMPLITUDE=1447
    out_i = []
    out_q = []
    for i in range(len(data_in)//2):
        a = data_in[2*i:2*i+2]
        # print(a)
        # break
        if a == [0, 0]:
            out_i.append(AMPLITUDE)
            out_q.append(AMPLITUDE)
        elif a == [0, 1]:
            out_i.append(AMPLITUDE)
            out_q.append(-AMPLITUDE)
        elif a == [1, 0]:
            out_i.append(-AMPLITUDE)
            out_q.append(AMPLITUDE)
        else:
            out_i.append(-AMPLITUDE)
            out_q.append(-AMPLITUDE)
    return out_i, out_q

def bin_to_file(in_data, fname):
    in_data_str = ['1' if i else '0' for i in in_data]
    in_data_str = "".join(in_data_str)
    in_data_arr = [int(in_data_str[i*8:i*8+8],2) for i in range(len(in_data)//8)]
    f = open(fname, "wb")
    for i in in_data_arr:
        f.write(i.to_bytes(1, byteorder='little'))
    f.close()

N = 63*120
in_data = [np.random.choice([0, 1]) for i in range(N)]
qpsk_i, qpsk_q = qpsk(in_data)
header_i, header_q = add_header(qpsk_i, qpsk_q)
header_i, header_q = np.array([[i]*8 for i in header_i]).flatten(), np.array([[i]*8 for i in header_q]).flatten()
fir_i, fir_q = np.correlate(header_i, coefs), np.correlate(header_q, coefs)

save_vector_to_file([fir_i, fir_q], "tb.out")
bin_to_file(in_data, "tb.in")

import matplotlib.pyplot as plt

print(in_data[0:64])

plt.figure()
plt.plot(fir_i)
# plt.plot(fir_q)
plt.show()