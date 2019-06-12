###############################################
# THIS DOCKER FILE IS WRITTEN FOR ROBOCUP3D
# SIMULATION RUNNING ENVIRONMENT BY LAB OF
# ROBOCUP OF HFUT
###############################################
# set system base
FROM ubuntu:16.04
MAINTAINER whistral@gmail.com
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libfreetype6 libode6 libsdl1.2debian ruby libdevil1c2 qt4-default \
#     && apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# set cmd args
ARG RCSSSERVER3D_RELEASE=0.7.1
ARG buildDeps='g++ cmake git ssh libfreetype6-dev libode-dev libsdl-dev ruby-dev libdevil-dev libboost-dev libboost-thread-dev libboost-regex-dev libboost-system-dev libqt4-opengl-dev'
ENV LD_LIBRARY_PATH=/usr/local/lib/simspark:/usr/local/lib/rcssserver3d
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
# replace source list
COPY sources.list /etc/apt/
# install 
# setting `DEBIAN_FRONTEND` to "noninteractive" informs OS that running commands shall not ask user to check
# make sure to set this in `RUN` rather than `ENV`, 'cause you may need to operate on interactive shell later on
RUN DEBIAN_FRONTEND="noninteractive"; rm -Rf /var/lib/apt/lists/* && apt-get clean && apt-get update -y --fix-missing && apt-get install --fix-missing --no-install-recommends $buildDeps \
    && mkdir /home/robocup3d && chown robocup3d /home/robocup3d && useradd robocup3d -d /home/robocup3d && su robocup3d
WORKDIR /home/robocup3d
# clone src, build and install
RUN git clone --branch RCSSSERVER3D_${RCSSSERVER3D_RELEASE}_RELEASE --depth 1 https://gitlab.com/robocup-sim/SimSpark.git /tmp/SimSpark \
    && mkdir -p /tmp/SimSpark/spark/build && cd /tmp/SimSpark/spark/build && cmake -DRVDRAW=ON .. && make -j$(nproc) && make install && ldconfig \
    && mkdir -p /tmp/SimSpark/rcssserver3d/build && cd /tmp/SimSpark/rcssserver3d/build && cmake -DRVDRAW=ON .. && make -j$(nproc) && make install && ldconfig \
    && rm -fr /tmp/SimSpark \
    && apt-get purge -y --auto-remove $buildDeps && rm -rf /var/lib/apt/lists/* 
# for test
WORKDIR /home/robocup3d
RUN git clone https://github.com/LARG/utaustinvilla3d && cd utaustinvilla3d && cmake . && make -j${nproc} && echo "build successfully!"

# can be rewritten by command line args
CMD [ "rcssserver3d" ]
# can not be rewritten
ENTRYPOINT ["bash"]
