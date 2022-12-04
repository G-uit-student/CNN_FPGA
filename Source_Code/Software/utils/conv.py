import numpy as np
import cv2
import torch
import torch.nn as nn
from cnn_model import cnn_model
from torchsummary import summary


def twos_complement(dec, bit_depth):
    if (dec < 0):
        dec += 2**bit_depth

    if (bit_depth == 8):
        return "{:02x}".format(dec)
    elif (bit_depth == 16):
        return "{:04x}".format(dec)
    elif (bit_depth == 32):
        return "{:08x}".format(dec)


def window_2_bin(window, bit_depth):
    bin_str = ""

    for line in window:
        for val in line:
            bin_str += twos_complement(val, bit_depth)

    return bin_str


def layer_2_txt(image, txt_path, bit_depth):
    txt_file = open(txt_path, "w")

    height, width = image.shape

    for i in range(height):
        for j in range(width):
            pixel = twos_complement(int(image[i, j]), bit_depth)
            txt_file.write(pixel + "\n")

    txt_file.close()


def img_2_txt(image, txt_path):
    txt_file = open(txt_path, "w")

    height, width, depth = image.shape

    for i in range(height):
        for j in range(width):
            pixel = ""

            for k in range(depth):
                pixel += twos_complement(int(image[i, j, k]), 8)
                
            txt_file.write(pixel + "\n")

    txt_file.close()


def conv2d(image, kernel, kernel_size=3, padding=0, strides=1):
    img_width = image.shape[0]
    img_height = image.shape[1]

    out_width = int(((img_width - kernel_size + 2*padding) / strides) + 1)
    out_height = int(((img_height - kernel_size + 2*padding) / strides) + 1)
    output = np.zeros((out_width, out_height))

    if padding != 0:
        padded_image = np.zeros((img_width + padding*2, img_height + padding*2))
        padded_image[int(padding):int(-1 * padding), int(padding):int(-1 * padding)] = image
    else:
        padded_image = image

    for y in range(img_height):
        if y > img_height + padding*2 - kernel_size:
            break

        if y % strides == 0:
            for x in range(img_width):
                if x > img_width + padding*2 - kernel_size:
                    break
                try:
                    if x % strides == 0:
                        output[x, y] = (kernel * padded_image[x: x + kernel_size, y: y + kernel_size]).sum()
                except:
                    break
    return output

if __name__ == "__main__":
    in_channel = 1
    out_channel = 32
    kernel_size = 3
    padding = 1
    stride = 1

    image = cv2.imread("40820.jpg")
    image = cv2.normalize(image, None, 0, 255, cv2.NORM_MINMAX, cv2.CV_8S)

    i_fm = cv2.split(image)

    test_case = open("testcase.txt", "w")
    weight = open("weights.txt", "w")

    kernel = np.random.randint(-128, 127, size=(out_channel, in_channel, kernel_size, kernel_size))
    kernel_bin = ""

    for i in range(out_channel):
        test_case.write("Out channel " + str(i+1) + ":\n")
        
        o_fm = 0
        for j in range(in_channel):
            test_case.write("Kernel " + str(j+1) + ":\n")
            test_case.write(str(kernel[i][j]) + "\n")
            test_case.write(window_2_bin(kernel[i][j], 8) + "\n")
            kernel_bin += window_2_bin(kernel[i][j], 8)

            o_fm += conv2d(i_fm[j], kernel[i][j], kernel_size=3, padding=1, strides=1)

        layer_2_txt(o_fm, "conv_output/out_" + str(i) + ".txt", 32)

    while (len(kernel_bin)):
        weight.write(kernel_bin[0:8] + "\n")
        kernel_bin = kernel_bin[8:]

    test_case.close()
    weight.close()
