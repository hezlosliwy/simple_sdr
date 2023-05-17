BCH_FRAME_LEN = 63
BCH_CNT_IN_FRAME = 1
PAYLOAD_LEN = BCH_FRAME_LEN*BCH_CNT_IN_FRAME
AMPLITUDE = 1447

header_i = [1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0]
header_q = [1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1]
header_i, header_q = [AMPLITUDE if i else -AMPLITUDE for i in header_i], [AMPLITUDE if i else -AMPLITUDE for i in header_q]

def add_header(in_data_i, in_data_q):
    out_data_i, out_data_q = [], []
    for i in range(len(in_data_i)//(PAYLOAD_LEN)):
        out_data_i.extend(header_i)
        out_data_i.extend(in_data_i[i*PAYLOAD_LEN:(i+1)*PAYLOAD_LEN])
        out_data_q.extend(header_q)
        out_data_q.extend(in_data_q[i*PAYLOAD_LEN:(i+1)*PAYLOAD_LEN])
    return out_data_i, out_data_q
