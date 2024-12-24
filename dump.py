import torch
import os
import numpy as np
import cv2
import alphabets as alphabets
import lib.utils.toTensor as toTensor

def dump_pth(t, dir, name, i_bits, f_bits):
    print("dumping paras #{} to txt file".format(name))
    arr = np.array(t[name].detach().cpu().numpy())
    typ = name.split('.')[0]
    shape = arr.shape
    split = (typ == 'rnn')
    print("type of para is {}, with size of {}".format(typ, arr.shape))

    split_list = ['ii', 'if', 'ig', 'io']
    if split:
        spvars = name.replace('.', '_').split('_')
        name = '_'.join([spvars[0], spvars[1], spvars[3]]) + '_'
        for i, spname in enumerate(split_list):
            f = open(dir + name + spname + '.txt', 'w', encoding='utf-8')
            height = arr.shape[0] // 4
            tmp = arr[height*i: height*(i+1)].flatten()
            for item in tmp:
                f.write(toTensor.to_fixed(item, i_bits, f_bits) + '\n')
                f.flush()
            f.close()
    else:
        if len(shape) == 4:
            f = open(dir + name.replace('.', '_') + '.txt', 'w', encoding='utf-8')
            for o_c in arr:
                item = ''.join([toTensor.to_fixed(i) for i in o_c.flatten()[::-1]])
                f.write(item + '\n')
                f.flush()
            f.close()
        elif len(shape) == 1:
            f = open(dir + name.replace('.', '_') + '.txt', 'w', encoding='utf-8')
            for o_c in arr:
                item = toTensor.to_fixed(o_c)
                f.write(item + '\n')
                f.flush()
            f.close()

def dump_img(config, path, name, i_bits, f_bits):
    img = cv2.imread(path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    h, w = img.shape
    img = cv2.resize(img, (0, 0), fx=config.MODEL.IMAGE_SIZE.H / h, fy=config.MODEL.IMAGE_SIZE.H / h, interpolation=cv2.INTER_CUBIC)

    h, w = img.shape
    w_cur = int(img.shape[1] / (config.MODEL.IMAGE_SIZE.OW / config.MODEL.IMAGE_SIZE.W))
    img = cv2.resize(img, (0, 0), fx=w_cur / w, fy=1.0, interpolation=cv2.INTER_CUBIC)
    img = np.reshape(img, (config.MODEL.IMAGE_SIZE.H, w_cur, 1))

    print("img.shape={}".format(img.shape))
    img = img.astype(np.float32)
    img = (img / 255. - config.DATASET.MEAN) / config.DATASET.STD
    img = img.transpose([2, 0, 1])

    tensor = torch.from_numpy(img).to(torch.device('cuda:0') if torch.cuda.is_available() else torch.device('cpu'))
    tensor = tensor.view(1, *tensor.size())

    img = ''.join([toTensor.to_fixed(pixel, i_bits, f_bits) for pixel in img.flatten()[::-1]])

    dirname = 'data_input/'
    if not os.path.exists(dirname):
        os.mkdir(dirname)
    f = open(dirname + name + '.txt', "w", encoding='utf-8')
    f.write(img + '\n')
    f.flush()
    f.close()

    return tensor
    
def dump(config, args):
    debug = 0
    checkpoint = torch.load(args.checkpoint)
    dirname = 'model_para_float' if debug else 'model_para'
    if not os.path.exists(dirname):
        os.mkdir(dirname)
    
    layer_name = ['cnn.conv0.weight',
                  'cnn.conv0.bias',
                  'cnn.conv1.weight',
                  'cnn.conv1.bias',
                  'cnn.conv2.weight',
                  'cnn.conv2.bias',
                  'cnn.conv3.weight',
                  'cnn.conv3.bias',
                  'cnn.conv4.weight',
                  'cnn.conv4.bias',
                  'cnn.conv5.weight',
                  'cnn.conv5.bias',
                  'cnn.conv6.weight',
                  'cnn.conv6.bias',
                  'cnn.batchnorm2.weight',
                  'cnn.batchnorm2.bias',
                  'cnn.batchnorm2.running_mean',
                  'cnn.batchnorm2.running_var',
                  'cnn.batchnorm4.weight',
                  'cnn.batchnorm4.bias',
                  'cnn.batchnorm4.running_mean',
                  'cnn.batchnorm4.running_var',
                  'cnn.batchnorm6.weight',
                  'cnn.batchnorm6.bias',
                  'cnn.batchnorm6.running_mean',
                  'cnn.batchnorm6.running_var',
                  'rnn.0.rnn.weight_ih_l0',
                  'rnn.0.rnn.weight_hh_l0',
                  'rnn.0.rnn.weight_ih_l0_reverse',
                  'rnn.0.rnn.weight_ih_l0_reverse',
                  'rnn.0.rnn.bias_ih_l0',
                  'rnn.0.rnn.bias_hh_l0',
                  'rnn.0.rnn.bias_ih_l0_reverse',
                  'rnn.0.rnn.bias_ih_l0_reverse',
                  'rnn.0.embedding.weight',
                  'rnn.0.embedding.bias',
                  'rnn.1.rnn.weight_ih_l0',
                  'rnn.1.rnn.weight_hh_l0',
                  'rnn.1.rnn.weight_ih_l0_reverse',
                  'rnn.1.rnn.weight_ih_l0_reverse',
                  'rnn.1.rnn.bias_ih_l0',
                  'rnn.1.rnn.bias_hh_l0',
                  'rnn.1.rnn.bias_ih_l0_reverse',
                  'rnn.1.rnn.bias_ih_l0_reverse',
                  'rnn.1.embedding.weight',
                  'rnn.1.embedding.bias']
    # for layer in layer_name:
    #     dump_pth(checkpoint, dirname + '/', layer, 10, 13)

    return dump_img(config, args.image_path, 'cnn_conv0', 10, 13)

if __name__ == '__main__':
    pass