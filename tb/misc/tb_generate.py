import numpy as np
from header_tb import add_header
from fir_tb import coefs, coefs_rc, save_vector_to_file
import scipy.signal as signal
import galois
bch = galois.BCH(63, 51)

def qpsk(data_in):
    AMPLITUDE=int(1447)
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
    print(f"In stream len: {len(in_data_str)}")
    in_data_str = "".join(in_data_str)
    in_data_arr = [int(in_data_str[i*8:i*8+8],2) for i in range(len(in_data)//8)]
    print(f"In str len: {len(in_data_str)}, in arr len: {len(in_data_arr)}")
    f = open(fname, "wb")
    for i in in_data_arr:
        f.write(i.to_bytes(1, byteorder='little'))
    f.close()

N = 51*1200
# in_data = [1 if i=='1' else 0 for i in "1100"*(N//4)]
# print(in_data)
in_data = [np.random.choice([0, 1]) for i in range(N)]
bch_data = []
for i in range(len(in_data)//51):
    bch_data.extend(bch.encode(in_data[i*51:(i+1)*51]))
    # print("".join([str(i) for i in in_data[i*51:(i+1)*51]]))
    # print("".join([str(int(i)) for i in bch_data]))
    # quit()
qpsk_i, qpsk_q = qpsk(bch_data)
header_i, header_q = add_header(qpsk_i, qpsk_q)
# print(header_i)
# print(header_q)
# save_vector_to_file([np.array([[i]*8 for i in header_i]).flatten(), np.array([[i]*8 for i in header_q]).flatten()], "hd.out")

header_i, header_q = np.array([[i]*8 for i in header_i]).flatten(), np.array([[i]*8 for i in header_q]).flatten()
fir_i, fir_q = np.correlate(header_i, coefs), np.correlate(header_q, coefs)
save_vector_to_file([fir_i, fir_q], "tb.out")
fir_i, fir_q = np.correlate(header_i, coefs_rc), np.correlate(header_q, coefs_rc)
save_vector_to_file([fir_i, fir_q], "tb_rx.out")
bin_to_file(in_data, "tb.in")
bin_to_file(bch_data, "bch.out")
# import matplotlib.pyplot as plt

# print(in_data[0:64])

# plt.figure()
# plt.plot(fir_i)
# # plt.plot(fir_q)
# plt.show()