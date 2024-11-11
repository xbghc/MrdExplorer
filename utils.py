# flake8: noqa
# parseMrd来自于mrscan项目，注意更新
# 其中的output修改为data，因为只需要data


from PySide6.QtGui import QImage
import numpy as np
import logging
import os

def getMrdImagesNum(path):
    with open(path, 'rb') as f:
        mrd = f.read()
    shape = parseMrd(mrd).shape
    return shape[2] * shape[4]  # slices和views2有且仅有一个为1


def parseMrd(mrd):
    if not isinstance(mrd, bytes):
        return None
    if len(mrd) < 512:
        return None

    samples = int(0).from_bytes(mrd[0:4], byteorder="little", signed=True)
    views = int(0).from_bytes(mrd[4:8], byteorder="little", signed=True)
    views2 = int(0).from_bytes(mrd[8:12], byteorder="little", signed=True)
    slices = int(0).from_bytes(mrd[12:16], byteorder="little", signed=True)
    # 16-18 Unspecified
    datatype = int(0).from_bytes(mrd[18:20], byteorder="little", signed=True)
    # 20-152 Unspecified
    echoes = int(0).from_bytes(mrd[152:156], byteorder="little", signed=True)
    experiments = int(0).from_bytes(mrd[156:160], byteorder="little", signed=True)

    nele = experiments * echoes * slices * views * views2 * samples

    if datatype & 0xF == 0:
        dt = "u1"
        eleSize = 1
    elif datatype & 0xF == 1:
        dt = "i1"
        eleSize = 1
    elif datatype & 0xF == 2:
        dt = "i2"
        eleSize = 2
    elif datatype & 0xF == 3:
        dt = "i2"
        eleSize = 2
    elif datatype & 0xF == 4:
        dt = "i4"
        eleSize = 4
    elif datatype & 0xF == 5:
        dt = "f4"
        eleSize = 4
    elif datatype & 0xF == 6:
        dt = "f8"
        eleSize = 8
    else:
        logging.error("Unknown data type in the MRD file!")
        return None
    if datatype & 0x10:
        eleSize *= 2

    #
    # XXX - The value of NO_AVERAGES in PPR cannot be used to
    #       calculate the data size.
    #       Maybe COMPLETED_AVERAGES? ref. p14 of the manual
    #
    posPPR = mrd.rfind(b"\x00")
    if posPPR == -1:
        logging.error("Corrupted MRD file!")
        return None
    posPPR += 1
    dataSize = posPPR - 512 - 120
    if dataSize < nele * eleSize:
        logging.error("Corrupted MRD file!")
        return None

    ndata = dataSize // (nele * eleSize)
    data = []

    offset = 512
    for i in range(ndata):
        x = np.frombuffer(
            mrd[offset:],
            dtype=(
                [("re", "<" + dt), ("im", "<" + dt)]
                if (datatype & 0x10)
                else ("<" + dt)
            ),
            count=nele,
        )
        if dt in ("f4", "f8"):
            pass
        else:
            x = x.astype(np.float32)
            if datatype & 0x10:
                x = x.astype([("re", "<f4"), ("im", "<f4")])
            else:
                x = x.astype(np.float32)

        if datatype & 0x10:
            if dt in ("f8",):
                x = x.view(np.complex128)
            else:
                x = x.view(np.complex64)

        x = x.reshape((experiments, echoes, slices, views, views2, samples))

        offset += nele * eleSize

        data.append(x)

    if offset != posPPR - 120:
        logging.warning("Corrupted MRD file!")

    # output = {}
    # output['description'] = mrd[256:512].decode('cp437', errors='ignore').rstrip('\0')
    # output['data'] = data
    # output['sampleInfoFilePath'] = mrd[(posPPR-120):posPPR].decode('cp437', errors='ignore').rstrip('\0')
    # output['pulseq'] = SmisPulseq(mrd[posPPR:])

    # return output
    return data[0]


def loadImagesFromMrdFile(fpath):
    if not fpath.endswith(".mrd"):
        return None

    with open(fpath, "rb") as f:
        mrd = f.read()
        kdata = parseMrd(mrd)

    experiments, echoes, slices, views, views2, samples = kdata.shape
    assert experiments == 1 and echoes == 1

    if slices == 1:
        kdata = kdata.reshape(views, views2, samples).swapaxes(0, 1)
    else:
        # views2一定是1
        kdata = kdata.reshape(slices, views, samples)

    images = np.fft.fftshift(np.fft.ifftn(kdata))
    images = np.abs(images)

    return images


def numpy_to_qimage_grayscale(array):
    """
    将2D NumPy数组转换为QImage灰度图像 (Qt6版本)
    
    参数:
        array: 2D NumPy数组,未归一化的数据
        
    返回:
        QImage: 8位灰度图像
    """
    # 确保输入是2D数组
    if len(array.shape) != 2:
        raise ValueError("输入必须是2D数组")
    
    array_8bit = array.astype(np.uint8)
    
    # 确保数据是连续的
    if not array_8bit.flags['C_CONTIGUOUS']:
        array_8bit = np.ascontiguousarray(array_8bit)
    
    # 创建QImage
    height, width = array_8bit.shape
    bytes_per_line = width  # 对于8位灰度图像,每行字节数等于宽度
    
    # 创建QImage(数据,宽,高,每行字节数,格式)
    qimage = QImage(array_8bit.data, width, height, bytes_per_line, QImage.Format.Format_Grayscale8)
    
    # 创建深拷贝,确保数据独立
    return qimage.copy()


def parseMrdFileName(filename: str):
    filename = os.path.basename(filename)
    if not (filename.endswith(".mrd") or filename.endswith(".MRD")):
        raise ValueError

    filename = os.path.splitext(filename)[0]
    if "#" in filename:
        return filename.split("#")
    else:
        return [filename, None]