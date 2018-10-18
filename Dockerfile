FROM bvlc/caffe:cpu

RUN apt-get -y update && \
  apt-get -y install \
  vim \
  wget \
  curl \
  jq \
  openssh-client \
  git \
  rsync

RUN pip install --upgrade pip
RUN pip install lmdb
RUN pip install imageio
RUN pip install pydot
RUN pip install requests
RUN pip install git+https://github.com/mnick/scikit-tensor.git
RUN pip install jupyter

ENV JUPYTER_TOKEN 1234

CMD jupyter notebook --allow-root --no-browser --ip 0.0.0.0
