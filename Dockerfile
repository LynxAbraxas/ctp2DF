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
    libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev byacc gtk+-2.0-dev gcc-5 g++-5 \
    automake libtool unzip flex

COPY ctp2/ /ctp2/
COPY ctp2CD/ /opt/ctp2/

RUN cd /ctp2 && \
    ./autogen.sh && \
    CC=/usr/bin/gcc-5 \
    CXX=/usr/bin/g++-5 \
    CFLAGS="$CFLAGS -w -fuse-ld=gold" \
    CXXFLAGS="$CXXFLAGS -w -fuse-ld=gold" \
    ./configure --prefix=/opt/ctp2 --bindir=/opt/ctp2/ctp2_program/ctp --enable-silent-rules && \
    make -j"$(nproc)" && \
    make -j"$(nproc)" install && \
    cp -r /ctp2/ctp2_data/ /opt/ctp2/ && \
    cp -v /ctp2/ctp2_code/mapgen/.libs/*.so /opt/ctp2/ctp2_program/ctp/dll/map/


################################################################################
# merge
################################################################################
FROM system

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsdl1.2debian libsdl-mixer1.2 libsdl-image1.2 libgtk2.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
COPY --from=builder /opt/ctp2/ /opt/ctp2/

USER $USERNAME

WORKDIR /opt/ctp2/ctp2_program/ctp/

CMD ["./ctp2"]
