################################################################################
# base system
################################################################################
FROM ubuntu:16.04 as system

ENV USERNAME diUser
RUN useradd -m $USERNAME && \
    echo "$USERNAME:$USERNAME" | chpasswd && \
    usermod --shell /bin/bash $USERNAME && \
    usermod -aG video,audio $USERNAME

ENV HOME /opt


################################################################################
# builder
################################################################################
FROM system as builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libavformat-dev libswscale-dev byacc gtk+-2.0-dev gcc-5 g++-5 \
    automake libtool unzip flex git ca-certificates cmake

### set default compilers
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 100 && \
    update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-5 30 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30 && \
    cc --version && \
    c++ --version && \
    cpp --version

### build SDL_ffmpeg
RUN git clone -b FFmpeg-2018 http://github.com/lynxabraxas/SDL_ffmpeg && \
    mkdir SDL_ffmpeg_build && \
    cd SDL_ffmpeg_build && \
    cmake \
    	  -DCMAKE_INSTALL_PREFIX=/usr/local/ \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_VERBOSE_MAKEFILEL=ON \
	  ../SDL_ffmpeg && \
    make && \
    make install

### SDL_ffmpeg built

ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

## ctp2CD/ copy not done in install stage to have one layer less in the final DI to decrease DI download size
COPY ctp2CD/ /opt/ctp2/
## ctp2CD/ before ctp2/ as it changes less often
COPY ctp2/ /ctp2/

RUN cd /ctp2 && \
    ./autogen.sh && \
    CPPFLAGS="-I/usr/include/SDL/ -I/usr/local/include/SDL/" \
    CC=/usr/bin/gcc-5 \
    CXX=/usr/bin/g++-5 \
    CFLAGS="$CFLAGS -w -fuse-ld=gold" \
    CXXFLAGS="$CXXFLAGS -fpermissive -w -fuse-ld=gold" \
    LDFLAGS="$LDFLAGS -L/usr/local/lib" \
    ./configure --prefix=/opt/ctp2 --bindir=/opt/ctp2/ctp2_program/ctp --enable-silent-rules && \
    make -j"$(nproc)" && \
    make -j"$(nproc)" install && \
    cp -r /ctp2/ctp2_data/ /opt/ctp2/ && \
    cp -v /ctp2/ctp2_code/mapgen/.libs/*.so /opt/ctp2/ctp2_program/ctp/dll/map/


################################################################################
# merge
################################################################################
FROM system as install

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsdl1.2debian libsdl-mixer1.2 libsdl-image1.2 libgtk2.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
COPY --from=builder /opt/ctp2/ /opt/ctp2/

COPY --from=builder /usr/local/lib /usr/local/lib
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

USER $USERNAME

WORKDIR /opt/ctp2/ctp2_program/ctp/

CMD ["./ctp2"]


################################################################################
# install new sprites
################################################################################
FROM install

COPY newSprites/ /opt/ctp2/ctp2_data/default/graphics/sprites/
COPY TGAs/       /opt/ctp2/ctp2_data/default/graphics/pictures/
