# Freescale i.MX28 build environment
# Instructions here https://community.freescale.com/docs/DOC-98910
FROM ubuntu:13.10

RUN sed -i 's$archive.ubuntu.com/ubuntu$mirrors.digitalocean.com/ubuntu-old$' /etc/apt/sources.list

RUN apt-get update

RUN apt-get install -y gettext libgtk2.0-dev rpm bison m4 libfreetype6-dev \
libdbus-glib-1-dev liborbit2-dev intltool \
ccache ncurses-dev zlib1g zlib1g-dev gcc g++ libtool \
uuid-dev liblzo2-dev tcl dpkg asciidoc texlive-latex-base dblatex xutils-dev \
texlive texinfo lib32z1 lib32ncurses5 lib32bz2-1.0 \
libc6-dev-i386 u-boot-tools scrollkeeper gparted nfs-common nfs-kernel-server \
git-core git-doc git-email git-gui gitk meld atftpd vim sudo wget cmake

RUN ln -s /usr/lib/x86_64-linux-gnu/librt.so   /usr/lib/librt.so

ADD L2.6.35_1.1.0_130130_source.tar.gz /build/

WORKDIR /build/ 
RUN useradd build 
RUN usermod -d /build build

RUN echo 'build ALL(ALL) = NOPASSWD:ALL' >> /etc/sudoers
RUN rm /bin/sh && ln -sf /bin/bash /bin/sh

RUN git clone git://git.yoctoproject.org/opkg-utils
RUN cd opkg-utils && make install

RUN chown -R build /build
USER build

RUN echo -e 'yes\nyes\n' | ./L2.6.35_1.1.0_130130_source/install

WORKDIR /build/ltib
ADD 0001_make_L2.6.35_1.1.0_130130_compile_on_ubuntu_13.10_64bit_OS.patch.zip /build/ltib/

RUN unzip 0001_make_L2.6.35_1.1.0_130130_compile_on_ubuntu_13.10_64bit_OS.patch.zip
RUN git apply 0001_make_L2.6.35_1.1.0_130130_compile_on_ubuntu_13.10_64bit_OS.patch

RUN sed '/export BUILD_CC=/c\export BUILD_CC="/usr/bin/gcc"' -i dist/lfs-5.1/texinfo/texinfo.spec

ADD defconfig /build/ltib/defconfig

RUN ./ltib --preconfig defconfig -m config --batch

RUN sudo /opt/freescale/ltib/usr/bin/rpm --dbpath /opt/freescale/ltib/var/lib/rpm -ivh --force --ignorearch --nodeps /opt/freescale/pkgs/gcc-4.4.4-glibc-2.11.1-multilib-1.0-1.i386.rpm

ENV HOME=/build
CMD ./ltib -m shell
