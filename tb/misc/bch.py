import galois
import numpy as np

# print(ccsds.field)
# print(ccsds.generator_poly)
# print(ccsds.is_systematic)
# print(ccsds.G)
# print(ccsds.roots)
# print(bin(int('721', 16)))


# print(bin(gf6('x^1 + 1')**2))

ccsds = galois.BCH(63, 51)
gf6 = galois.GF(2**6, irreducible_poly="x^6+x+1")
print(gf6.primitive_element)
print(ccsds.generator_poly)
st = [i for i in range(63)]

def find_error(err_pos):
  r = ccsds.encode([1 for i in range(51)])
  e = [0 for i in range(63)]
  err_set = set(np.random.choice(st, 2))
  for i in err_set:
    e[i] = 1
  # e[np.random.choice(st, 1)] = 1
  # e[np.random.choice(st, 1)] = 1
  r = r ^ e
  # print(len(r))
  a = gf6.primitive_element
  N = 63
  S1, S2, S3 = 0, 0, 0
  for i in range(N):
    if r[i]:
      S1 = S1 ^ a**i
      S2 = S2 ^ (a**2)**i
      S3 = S3 ^ (a**3)**i

  # print(S1, S2, S3)

  sig1 = S1
  sig2 = S1**2 ^ S3*(S1**-1)
  epos1 = []
  for j in range(63):
    if ( sig1*(a**-1)**j ^ sig2*((a**-1)**2)**j) == 1:
      epos1.append(j)
  epos1 = set(epos1)
  if epos1 != err_set:
    print("error :(")

  # epos = ((epos & 0xFE) >> 1) | ((epos & 0x01)<<5)
  print(f"real error pos {err_set}, found err pos {epos1}")
  # print(f"real error pos {err_pos}, found err pos {epos}")
  # print(a**epos)

for i in range(62):
  find_error(i)
# S1 = S1 % [1, 0, 0, 0, 0, 1, 1]
# (x6+x+1)(x6+x4+x2+x+1)

# for i in range(1, 64):
#   print("6'b"+(bin(gf6(i)**-1)[2:]).zfill(6), end=", ")

# r = ccsds.encode([1 for i in range(51)])
# print(r)
# v = [np.random.choice([0,1]) for i in range(51)]
# r = ccsds.encode(v)
# print("".join([f"{i}" for i in v]), "".join([f"{i}" for i in r]))
