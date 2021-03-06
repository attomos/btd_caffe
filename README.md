# btd_caffe
Block Term Decomposition for Caffe model

## Setup (on GCP)
https://docs.docker.com/install/linux/docker-ce/ubuntu
https://docs.docker.com/compose/install
https://github.com/NVIDIA/nvidia-docker
http://mathalope.co.uk/2017/05/31/nvidia-cuda-toolkit-installation-ubuntu-16-04-lts-notes/
https://medium.com/@zhanwenchen/install-cuda-and-cudnn-for-tensorflow-gpu-on-ubuntu-79306e4ac04e

Basically I just need a driver in order to run nvidia-docker
```bash
$ sudo apt-get install gcc
$ sudo apt-get install nvidia-384 nvidia-modprobe
```

### could be useful
https://github.com/eywalker/nvidia-docker-compose

### but for now
```bash
$ nvidia-docker run -v $(pwd):/workspace -p 8888:8888 -it --rm bvlc/caffe:gpu bash
```

## Setup (caffe)
```bash
# https://github.com/BVLC/caffe/tree/master/docker
$ docker-compose up
$ wget -c "https://www.dropbox.com/s/3qidow3qr77ruob/vgg16.caffemodel?dl=0" -O vgg16.caffemodel
```

## Setup (caffe2)
```bash
$ conda create -n caffe2 python=3.6
$ source activate caffe2
(caffe2) $ conda install -c caffe2 caffe2
(caffe2) $ conda install pytorch-nightly-cpu -c pytorch
(caffe2) $ pip install git+https://github.com/mnick/scikit-tensor.git
```

## Setup (caffe2 on docker)
```bash
# https://hub.docker.com/r/caffe2/caffe2/
$ docker run --rm -it -p 8888:8888 caffe2/caffe2:snapshot-py2-gcc5-ubuntu16.04 jupyter notebook --allow-root --no-browser --ip 0.0.0.0

$ pip install lmdb
$ pip install imageio
$ pip install pydot
$ pip install requests
```

```bash
python approximate_net.py \
         --netdef vgg16/deploy.prototxt \
         --save_netdef vgg16/lowrank/deploy.prototxt \
         --config vgg16/params.csv

python approximate_net.py \
         --netdef vgg16/train_test.prototxt \
         --save_netdef vgg16/lowrank/train_test.prototxt \
         --config vgg16/params.csv \
         --params vgg16/vgg16.caffemodel \
         --save_params vgg16/lowrank/vgg16_lowrank.caffemodel \
         --max_iter 1000 \
         --min_decrease 1e-5

# working netdef
python approximate_net.py \
         --netdef vgg16/deploy.prototxt \
         --save_netdef vgg16/lowrank/train_test.prototxt \
         --config vgg16/params.csv \
         --params vgg16/vgg16.caffemodel \
         --save_params vgg16/lowrank/vgg16_lowrank.caffemodel \
         --max_iter 1000 \
         --min_decrease 1e-5
```

## Issues
```
Referenced from: ~/anaconda/envs/caffe2/lib/libavcodec.57.dylib
Reason: image not found
https://github.com/flatironinstitute/CaImAn/issues/317

$ conda install -c conda-forge x264=20131218
```

https://github.com/BVLC/caffe/issues/2780
https://medium.com/@mccode/processes-in-containers-should-not-run-as-root-2feae3f0df3b
https://stackoverflow.com/questions/27701930/add-user-to-docker-container
https://github.com/yihui-he/resnet-cifar10-caffe/blob/master/vgg16/trainval.prototxt

Just install these
```bash
$ conda install protobuf
$ pip install future
$ conda install nb_conda
$ conda install -c conda-forge python-lmdb
$ conda install lmdb
```

## Tricks from VS Code
```
conda install --name caffe2 yapf # to install package to specific conda env
```

## Block Term Decomposition (BTD) for CNNs
- [Accelerating Convolutional Neural Networks for Mobile Applications](http://dl.acm.org/citation.cfm?id=2967280)
- 2016, ACM Multimedia
- Peisong Wang and Jian Cheng / Chinese Academy of Sciences & University of Chinese Academy of Sciences, Beijing, China
- Parameters for '3.2 Whole-Model Acceleration for VGG-16’ in ‘3. EXPERIMENTS’
  >The S', T' and R for conv1_2 to conv5_3 are as follows:  
  >conv1_2: 11, 18, 1  
  >conv2_1: 10, 24, 1  
  >conv2_2: 28, 28, 2  
  >conv3_1: 36, 48, 4  
  >conv3_2: 60, 48, 4  
  >conv3_3: 64, 56, 4  
  >conv4_1: 64, 100, 4  
  >conv4_2: 116, 100, 4  
  >conv4_3: 132, 132, 4  
  >conv5_1: 224, 224, 4  
  >conv5_2: 224, 224, 4  
  >conv5_3: 224, 224, 4  
- 'group' parameter is used in 'convolution_param' in Caffe network definition (.prototxt)
  - description of 'group' in [Caffe Tutorial for Convolution Layer](http://caffe.berkeleyvision.org/tutorial/layers/convolution.html)
  >group (g) [default 1]: If g > 1, we restrict the connectivity of each filter to a subset of the input. Specifically, the input and output channels are separated into g groups, and the iith output group channels will be only connected to the iith input group channels.

## Usage
### Create approximated .prototxt
```sh
$ python approximate_net.py \
         --netdef vgg16/deploy.prototxt \
         --save_netdef vgg16/lowrank/deploy.prototxt \
         --config config.csv
```

### Create approximated .prototxt & Approximate parameters  
```sh
$ python approximate_net.py \
         --netdef vgg16/train_test.prototxt \
         --save_netdef vgg16/lowrank/train_test.prototxt \
         --config config.csv \
         --params vgg16/vgg16.caffemodel \
         --save_params vgg16/lowrank/vgg16_lowrank.caffemodel \
         --max_iter 1000 \
         --min_decrease 1e-5 
```

| Argument | Description | Type | Required |
| :-- | :-- | :-: | :-: |
| --netdef | original model (deploy.prototxt)| input | True |
| --save_netdef | low-rank model (deploy.prototxt) | output | True |
| --config | parameter config file for BTD (.csv)| input | True |
| --params | original model (.caffemodel) | input | - |
| --save_params | low-rank model (.caffemodel)| output | - |
| --max_iter | Max iteration for BTD| input | - |
| --min_decrease | Minimum error decrease in each iteration for BTD| input | - |

## Parameter config file for BTD (.csv)
```
conv, S', T', R
```
- conv : name of "Convolution" layer in .prototxt which you want to approximate
- S' : # of input channels
- T' : # of output channels
- R  : # of blocks
