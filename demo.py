import numpy as np
import torch
from torch.autograd import Variable
import torch.nn.functional as F
import lib.utils.utils as utils
import lib.utils.toTensor as toTensor
import lib.models.crnn as crnn
import alphabets as alphabets
import yaml
from easydict import EasyDict as edict
import argparse
import dump
from subprocess import run, Popen
import os

def parse_arg():
    parser = argparse.ArgumentParser(description="demo")

    parser.add_argument('--i_bits', help='bits of integer part in fixed point number', type=int, default=10)
    parser.add_argument('--f_bits', help='bits of fraction part in fixed point number', type=int, default=13)
    parser.add_argument('--cfg', help='experiment configuration filename', type=str, default='360CC_config.yaml')
    parser.add_argument('--image_path', type=str, default='images/18.png', help='the path to your image')
    parser.add_argument('--checkpoint', type=str, default='output/checkpoints/mixed_second_finetune_acc_97P7.pth',
                        help='the path to your checkpoints')

    args = parser.parse_args()

    with open(args.cfg, 'r') as f:
        config = yaml.safe_load(f)
        config = edict(config)

    config.DATASET.ALPHABETS = alphabets.alphabet
    config.MODEL.NUM_CLASSES = len(config.DATASET.ALPHABETS)

    return config, args

def consistency(refer, img):
    return np.square((refer-img).cpu().detach().numpy()).mean()

def run_verilog(tb_path):
    dump_path = 'tb/files/' + tb_path + '.txt'
    if os.path.exists(dump_path):
        print("File " + dump_path + ' already exists, iVerilog cmdline will not be executed')
    else:
        print("Running hardware accelerator {}".format(tb_path))
        cmdline = "iverilog -g2012 -o \"tb/test_tb.vvp\" tb/" + tb_path + ".v"
        #  tb/Conv2d.v tb/ConvKernel.v tb/qmult.v
        print(cmdline)
        print("Waiting for outputs from Icarus Verilog compiler")
        run(cmdline, shell=True)
        print("vvp tb/test_tb.vvp")
        print("Waiting for outputs from Vvp debugger")
        Popen("vvp tb/test_tb.vvp", shell=True, stdout=None, stderr=None).wait()
    
    return dump_path
       
if __name__ == '__main__':

    config, args = parse_arg()
    device = torch.device('cuda:0') if torch.cuda.is_available() else torch.device('cpu')

    model = crnn.get_crnn(config).to(device)
    print('Loading pretrained model from {0}'.format(args.checkpoint))
    checkpoint = torch.load(args.checkpoint)
    
    model.load_state_dict(checkpoint)
    converter = utils.strLabelConverter(config.DATASET.ALPHABETS)

    img = dump.dump(config, args)

    model.eval()
    # ////////////////////////////////////////////////////////////////
    debug = [0, 1, 1, 1, 1, 1, 0, 1]
    # 0(run_verilog) 1(get_tensor) for each layer
    # debug = [cr0, cr1, cr2, cr3, cr4, cr5, ls0, ls1]
    # ////////////////////////////////////////////////////////////////

    # conv_relu0
    print("conv_relu0 get img of {}".format(img.shape))
    refer = model.cnn.conv0(img)
    if debug[0]:
        img = refer
        print("Executing in 'debug' mode, get tensor file from software results")
    else:
        dump_path = run_verilog("accelerator_tb0")
        img = toTensor.path_to_tensor(device, dump_path, 32, 160, args.i_bits, args.f_bits)
        print("Executing completed")
        print("MSE error is {}, continue to inference".format(consistency(refer, img)))
    img = model.cnn.relu0(img)
    img = model.cnn.pooling0(img)
    dump_path = "data_input/cnn_conv1.txt"
    toTensor.tensor_to_file(dump_path, img)

    # conv_relu1
    print("conv_relu1 get img of {}".format(img.shape))
    refer = model.cnn.conv1(img)
    if debug[1]:
        img = refer
        print("Executing in 'debug' mode, getting tensor file from software results")
    else:
        dump_path = run_verilog("accelerator_tb1")
        img = toTensor.path_to_tensor(device, dump_path, 16, 80, args.i_bits, args.f_bits)
        print("Executing completed")
        print("MSE error is {}, continue to inference",consistency(refer, img))
    img = model.cnn.relu1(img)
    img = model.cnn.pooling1(img)
    dump_path = "data_input/cnn_conv2.txt"
    toTensor.tensor_to_file(dump_path, img)

    # conv_relu2
    print("conv_relu2 get img of {}".format(img.shape))
    refer = model.cnn.conv2(img)
    if debug[2]:
        img = refer
        print("Executing in 'debug' mode, getting tensor file from software results")
    else:
        dump_path = run_verilog("accelerator_tb2")
        img = toTensor.path_to_tensor(device, dump_path, 8, 40, args.i_bits, args.f_bits)
        print("Executing completed")
        print("MSE error is {}, continue to inference",consistency(refer, img))
    img = model.cnn.batchnorm2(img)
    img = model.cnn.relu2(img)
    dump_path = "data_input/cnn_conv3.txt"
    toTensor.tensor_to_file(dump_path, img)

    # conv_relu3
    print("conv_relu3 get img of {}".format(img.shape))
    refer = model.cnn.conv3(img)
    if debug[3]:
        img = refer
        print("Executing in 'debug' mode, getting tensor file from software results")
    else:
        dump_path = run_verilog("accelerator_tb3")
        img = toTensor.path_to_tensor(device, dump_path, 8, 40, args.i_bits, args.f_bits)
        print("Executing completed")
        print("MSE error is {}, continue to inference",consistency(refer, img))
    img = model.cnn.relu3(img)
    img = model.cnn.pooling2(img)
    dump_path = "data_input/cnn_conv4.txt"
    toTensor.tensor_to_file(dump_path, img)

    # conv_relu4
    print("conv_relu4 get img of {}".format(img.shape))
    refer = model.cnn.conv4(img)
    if debug[4]:
        img = refer
        print("Executing in 'debug' mode, getting tensor file from software results")
    else:
        dump_path = run_verilog("accelerator_tb4")
        img = toTensor.path_to_tensor(device, dump_path, 4, 41, args.i_bits, args.f_bits)
        print("Executing completed")
        print("MSE error is {}, continue to inference",consistency(refer, img))
    img = model.cnn.batchnorm4(img)
    img = model.cnn.relu4(img)
    dump_path = "data_input/cnn_conv5.txt"
    toTensor.tensor_to_file(dump_path, img)

    # conv_relu5
    print("conv_relu5 get img of {}".format(img.shape))
    refer = model.cnn.conv5(img)
    if debug[5]:
        img = refer
        print("Executing in 'debug' mode, getting tensor file from software results")
    else:
        dump_path = run_verilog("accelerator_tb5")
        img = toTensor.path_to_tensor(device, dump_path, 4, 41, args.i_bits, args.f_bits)
        print("Executing completed")
        print("MSE error is {}, continue to inference",consistency(refer, img))
    img = model.cnn.relu5(img)
    img = model.cnn.pooling3(img)

    # conv_relu6
    print("conv_relu6 get img of {}".format(img.shape))
    img = model.cnn.conv6(img)
    img = model.cnn.batchnorm6(img)
    img = model.cnn.relu6(img)

    b, c, h, w = img.size()
    print("conv.shape={}".format(img.shape))
    assert h == 1, "the height of conv must be 1"
    img = img.squeeze(2) # b * 512 * width
    img = img.permute(2, 0, 1)  # [w, b, c]
    print("rnn_pre.shape={}".format(img.shape))
    dump_path = "data_input/rnn_lstm0.txt"
    toTensor.tensor_to_file(dump_path, img)

    # lstm0
    refer, _ = model.rnn._modules['0'].rnn(img)
    T, b, h = refer.size()
    refer = refer.view(T * b, h)
    if debug[6]:
        img = refer
        print("Executing in 'debug' mode, getting tensor file from software results")
    else:
        dump_path = run_verilog("lstmtb")
        img = toTensor.path_to_tensor(device, dump_path, 1, 41, args.i_bits, args.f_bits)
        print("Executing completed")
        print("MSE error is {}, continue to inference",consistency(refer, img))
    img = model.rnn._modules['0'].embedding(img)  # [T * b, nOut]
    img = img.view(T, b, -1)
    dump_path = "data_input/rnn_lstm1.txt"
    toTensor.tensor_to_file(dump_path, img)

    # lstm1
    refer, _ = model.rnn._modules['1'].rnn(img)
    T, b, h = refer.size()
    refer = refer.view(T * b, h)
    if debug[7]:
        img = refer
        print("Executing in 'debug' mode, getting tensor file from software results")
    else:
        dump_path = run_verilog("accelerator_tb7")
        img = toTensor.path_to_tensor(device, dump_path, 1, 41, args.i_bits, args.f_bits)
        print("Executing completed")
        print("MSE error is {}, continue to inference",consistency(refer, img))
    img = model.rnn._modules['1'].embedding(img)  # [T * b, nOut]
    img = img.view(T, b, -1)

    preds = F.log_softmax(img, dim=2)
    print("preds.shape={}".format(preds.shape))
    _, preds = preds.max(2)
    preds = preds.transpose(1, 0).contiguous().view(-1)

    preds_size = Variable(torch.IntTensor([preds.size(0)]))
    sim_pred = converter.decode(preds.data, preds_size.data, raw=False)

    print('results: {0}'.format(sim_pred))

