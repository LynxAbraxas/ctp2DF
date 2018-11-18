################################################################################
# base system
################################################################################
FROM i386/ubuntu:14.04 as system

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
    libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev byacc gtk+-2.0-dev build-essential \
    automake libtool unzip flex libbsd-dev \
    libltdl-dev \
    wget ca-certificates \
    git cmake

### build freetype-1.3.1
COPY misc/ftdump-newer-GCC.patch /root/

RUN wget http://sourceforge.net/projects/freetype/files/freetype/1.3.1/freetype-1.3.1.tar.gz && \
    tar xvf freetype-1.3.1.tar.gz && \
    cd freetype-1.3.1 && \
    wget 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' -O config.sub `# support for newer CPUs`  && \
    patch -d test -i /root/ftdump-newer-GCC.patch && \
    ./configure && \
    make && \
    make install
    
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"
### freetype-1.3.1 built

### build ffmpeg
RUN git clone --depth 1 -b v0.6.1 https://github.com/FFmpeg/FFmpeg/ && \
    cd FFmpeg && \
    ./configure \
	--disable-doc \
	--disable-ffmpeg \
	--disable-ffplay \
	--disable-ffprobe \
	--disable-ffserver \
	--disable-avdevice && \
    make -j"$(nproc)" && \
    make install

### ffmpeg built

### build SDL_ffmpeg
RUN git clone https://github.com/arjanhouben/SDL_ffmpeg && \
    mkdir SDL_ffmpeg_build && \
    cd SDL_ffmpeg_build && \
    cmake \
    	  -DCMAKE_INSTALL_PREFIX=/usr/ \
	  -DCMAKE_BUILD_TYPE=Release \
	  ../SDL_ffmpeg && \
    make && \
    make install

### SDL_ffmpeg built

COPY ctp2/ /ctp2/
COPY ctp2CD/ /opt/ctp2/

RUN cd /ctp2 && \
    make bootstrap && \
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH} /usr/lib/i386-linux-gnu/" \
    CFLAGS="-Wl,--no-as-needed -w -m32" \
    CXXFLAGS="-fpermissive -Wl,--no-as-needed -w -m32" \
    ./configure --prefix=/opt/ctp2 --bindir=/opt/ctp2/ctp2_program/ctp --enable-silent-rules && \
    make && \
    make install && \
    cp -r /ctp2/ctp2_data/ /opt/ctp2/ && \
    cp -v /ctp2/ctp2_code/mapgen/.libs/*.so /opt/ctp2/ctp2_program/ctp/dll/map/ && \
    cp -v /ctp2/ctp2_code/mapgen/.libs/*.la /opt/ctp2/ctp2_program/ctp/dll/map/


################################################################################
# merge
################################################################################
FROM system

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsdl1.2debian libsdl-mixer1.2 libsdl-image1.2 libgtk2.0-0 libltdl7 libsm6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
COPY --from=builder /opt/ctp2/ /opt/ctp2/

COPY --from=builder /usr/local/lib /usr/local/lib
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib"

USER $USERNAME

WORKDIR /opt/ctp2/ctp2_program/ctp/

CMD ["./ctp2"]
