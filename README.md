# **MD5** Hashing Accelerator Basic Verilog Design in 180 LoCs.

## About

This **MD5** Crypto-Accelerator eats at most **440-bits** messages and returns **128-bits** fixed length hashes.

Its implementation is based on the pseudo-code from the French and English **Wikipedia** pages.
It is an iterative design (loop on rounds).

This page has been used to dump **MD5 internal states** during the design with different test vectors to debug:
https://twy.name/Tools/Hash/md5.html

This page has been used to help with **MD5 padding** location:
https://cs360umass.org/md5-demo.html

This implementation has been tested in simulation only, with three test vectors.

Resources:
https://rosettacode.org/wiki/MD5/Implementation_Debug

## Verilator Testbench

```bash
make clean
```

```bash
make build
```

### Waveforms
```bash
make waves
[...]
### TEST VECTORS ###
md5sum("") = d41d8cd98f00b204e9800998ecf8427e
[...]
```

## Test Vectors
```bash
echo -n '' | md5sum
d41d8cd98f00b204e9800998ecf8427e  -
echo -n 'a' | md5sum
0cc175b9c0f1b6a831c399e269772661  -
echo -n '0123456789abcdef0123456789abcdef0123456789abcdef0123456' | md5sum
d8ea71eb4d2af27f59a5316c971065e6  -
echo -n '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' | md5sum
4fe130598d47f17c19a7c493b4ce0cf1  -
```

## Author
**Pierre GENARD**
