FROM ubuntu:xenial
MAINTAINER Chris Miller <c.a.miller@wustl.edu>

LABEL Image for basic ad-hoc bioinformatic analyses

#some basic tools
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    bzip2 \
    curl \
    csh \
    default-jdk \
    default-jre \
    emacs \
    emacs-goodies-el \
    evince \
    g++ \
    gawk \
    git \
    grep \
    less \
    libcurl4-openssl-dev \
    libpng-dev \
    librsvg2-bin \
    libssl-dev \
    libxml2-dev \
    libz-dev \
    lsof \
    make \
    man \
    ncurses-dev \
    nodejs \
    openssh-client \
    pdftk \
    pkg-config \
    python \
    rsync \
    screen \
    tabix \
    unzip \
    wget \
    zip \
    zlib1g-dev \
    libbz2-dev

##############
#HTSlib 1.3.2#
##############
ENV HTSLIB_INSTALL_DIR=/opt/htslib

WORKDIR /tmp
RUN wget https://github.com/samtools/htslib/releases/download/1.3.2/htslib-1.3.2.tar.bz2 && \
    tar --bzip2 -xvf htslib-1.3.2.tar.bz2 && \
    cd /tmp/htslib-1.3.2 && \
    ./configure  --enable-plugins --prefix=$HTSLIB_INSTALL_DIR && \
    make && \
    make install && \
    cp $HTSLIB_INSTALL_DIR/lib/libhts.so* /usr/lib/
    #&& \
#    ln -s $HTSLIB_INSTALL_DIR/bin/tabix /usr/bin/tabix

#################################
# Python 2 and 3, plus packages

# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc


# needed for MGI data mounts
RUN apt-get update && apt-get install -y libnss-sss && apt-get clean all

WORKDIR /opt
# Install Juicer
ADD https://github.com/theaidenlab/juicer/archive/1.6.2.zip .
RUN unzip 1.6.2.zip
RUN cd juicer-1.6.2 && chmod +x CPU/* CPU/common/* 

# Install Juicer tools
ADD http://hicfiles.tc4ga.com.s3.amazonaws.com/public/juicer/juicer_tools.1.7.6_jcuda.0.8.jar /opt/juicer-1.6.2/CPU/common
RUN ln -s /opt/juicer-1.6.2/CPU/common/juicer_tools.1.7.6_jcuda.0.8.jar /opt/juicer-1.6.2/CPU/common/juicer_tools.jar
RUN ln -s juicer-1.6.2/CPU scripts


# For sorting, LC_ALL is C
ENV LC_ALL C
ENV PATH=/opt:/opt/scripts:/opt/scripts/common:$PATH
