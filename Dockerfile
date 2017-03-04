FROM ubuntu:14.04
MAINTAINER Cleverson Nahum <cleversonahum@gmail.com>

#install pre-requesits for ndn-cxx, ns-3, etc...
RUN apt update
RUN apt-get install -y git
RUN apt-get install -y python-dev python-pygraphviz python-kiwi
RUN apt-get install -y python-pygoocanvas python-gnome2
RUN apt-get install -y python-rsvg ipython
RUN apt-get install -y build-essential
RUN apt-get install -y libsqlite3-dev libcrypto++-dev
RUN apt-get install -y libboost-all-dev

# install pre-requesits for libdash
RUN apt-get install -y git-core cmake libxml2-dev libcurl4-openssl-dev

# install mercurial for BRITE
RUN apt-get install -y mercurial

#Cloning repositories
RUN mkdir /home/ndnSIM
WORKDIR /home/ndnSIM/
RUN git clone https://github.com/named-data/ndn-cxx.git
RUN cd /home/ndnSIM/ndn-cxx && git checkout a1ffbc7a256f308d0ac318f02ebba1d6fa2305f8
RUN git clone https://github.com/cawka/ns-3-dev-ndnSIM.git ns-3

RUN cd /home/ndnSIM/ns-3 && git checkout rebase-20131101

RUN git clone https://github.com/cawka/pybindgen.git pybindgen

RUN cd /home/ndnSIM/pybindgen && git checkout 0.16.0

RUN git clone https://github.com/ChristianKreuzberger/amus-ndnSIM.git ns-3/src/ndnSIM
RUN git clone https://github.com/bitmovin/libdash.git

# download and built BRITE
RUN hg clone http://code.nsnam.org/BRITE
RUN cd BRITE && make

# build ndn-cxx
RUN cd ndn-cxx && ./waf configure --enable-shared --disable-static
RUN cd ndn-cxx && ./waf

# install ndn-cxx
RUN cd ndn-cxx && sudo ./waf install

# build libdash
RUN cd libdash/libdash && mkdir build
RUN cd libdash/libdash/build && cmake ../
RUN cd libdash/libdash/build && make dash # only build dash, no need for network stuff

# build ns-3/ndnSIM with brite and dash enabled
RUN cd ns-3 && ./waf configure -d optimized --with-brite=/home/ndnSIM/BRITE 
RUN cd ns-3 && ./waf
RUN cd ns-3 && sudo ./waf install