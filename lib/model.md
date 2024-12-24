# MODEL Structure

input size = 1 * 1 * 32 * 280
resize to 1 * 1 * 32 * 160
resize to 160 * 160 for hardwares

*model-cnn*

---dumping 'conv0.txt'
conv0(1->64, k3, s1, p1) -> 1 * 64 * 32 * 160
relu0
pool0(k2, s2) -> 1 * 64 * 16 * 80

---dumping 'conv1.txt'
conv1(64->128, k3, s1, p1) -> 1 * 128 * 16 * 80
relu1
pool1(k2, s2) -> 1 * 128 * 8 * 40

---dumping 'conv2.txt'
conv2(128->256, k3, s1, p1) -> 1 * 256 * 8 * 40
relu2
norm2

---dumping 'conv3.txt'
conv3(256->256, k3, s1, p1) -> 1 * 256 * 8 * 40
relu3
pool2(k22, s21, p01) -> 1 * 256 * 4 * 41

---dumping 'conv4.txt'
conv4(256->512, k3, s1, p1) -> 1 * 512 * 4 * 41
relu4
norm4

---dumping 'conv5.txt'
conv5(512->512, k3, s1, p1) -> 1 * 512 * 4 * 41
relu5
pool3(k22, s21, p01) -> 1 * 256 * 2 * 42

conv6(256->512, k2, s1, p0) -> 1 * 512 * 1 * 41
relu6
norm6

squeeze(2) -> 1 * 512 * 41
permute(2, 0, 1) -> 41 * 1 * 512

*model-rnn*

---dumping 'lstm0.txt'
lstm0 -> 41 * 1 * (256*2)
i_t = \sigma(W_{ii} x_t + b_{ii} + W_{hi} h_{t-1} + b_{hi})
f_t = \sigma(W_{if} x_t + b_{if} + W_{hf} h_{t-1} + b_{hf})
g_t = \tanh(W_{ig} x_t + b_{ig} + W_{hg} h_{t-1} + b_{hg})
o_t = \sigma(W_{io} x_t + b_{io} + W_{ho} h_{t-1} + b_{ho})
c_t = f_t \odot c_{t-1} + i_t \odot g_t
h_t = o_t \odot \tanh(c_t)
* 256 layer(s)

linear(256*2->256) -> 41 * 256

---dumping 'lstm1.txt'
lstm1 -> 41 * 1 * (256*2)
i_t = \sigma(W_{ii} x_t + b_{ii} + W_{hi} h_{t-1} + b_{hi})
f_t = \sigma(W_{if} x_t + b_{if} + W_{hf} h_{t-1} + b_{hf})
g_t = \tanh(W_{ig} x_t + b_{ig} + W_{hg} h_{t-1} + b_{hg})
o_t = \sigma(W_{io} x_t + b_{io} + W_{ho} h_{t-1} + b_{ho})
c_t = f_t \odot c_{t-1} + i_t \odot g_t
h_t = o_t \odot \tanh(c_t)
* 1 layer(s)

linear(256*2->1) -> 41 * 6736

