import torch
import numpy as np

def to_float(fixed, i_bits=10, f_bits=13):
    sign = 1.0 if fixed[0] == '0' else -1.0
    if sign == -1.0:
        fixed = (1<<(i_bits + f_bits + 1)) - int(fixed, 2)
    else:
        fixed = int(fixed, 2)
    
    return sign * fixed / (2 ** f_bits)

def to_fixed(value, i_bits=10, f_bits=13):
    fixed_integer = int(value * (1 << f_bits))
    if fixed_integer < 0:
        fixed_integer = (1<<(i_bits + f_bits + 1)) + fixed_integer
    binary_str = format(fixed_integer, '0{}b'.format(i_bits + f_bits + 1))

    return binary_str

def path_to_tensor(device, dump_path, src_h, src_w, i_bits=10, f_bits=13):
    with open(dump_path, "r") as f:
        lines = f.read().splitlines()[:-1]
        c = len(lines)
        img = []
        for channel in lines:
            sec = i_bits + f_bits + 1
            words = [to_float(channel[i:i+sec]) for i in range(0, len(channel), sec)][::-1]
            img.append(words)
        img = np.array(img).astype(np.float32)
        img.resize(1, c, src_h, src_w)
        img = torch.from_numpy(img).to(device)
        return img
    
def tensor_to_file(dump_path, tensor: torch.Tensor, i_bits=10, f_bits=13):
    img = tensor.detach().cpu().numpy()
    with open(dump_path, "w") as f:
        for channel in img[0]:
            channel = [to_fixed(i) for i in channel.flatten()]
            for item in channel:
                f.write(item + '\n')
                f.flush()