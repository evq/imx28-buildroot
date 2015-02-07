# Freescale i.MX28 build environment
# Instructions here https://community.freescale.com/docs/DOC-98910
FROM ubuntu:13.10

RUN apt-get update

RUN apt-get install -y gettext libgtk2.0-dev rpm bison m4 libfreetype6-dev
RUN apt-get install -y libdbus-glib-1-dev liborbit2-dev intltool
RUN apt-get install -y ccache ncurses-dev zlib1g zlib1g-dev gcc g++ libtool
RUN apt-get install -y uuid-dev liblzo2-dev
RUN apt-get install -y tcl dpkg
RUN apt-get install -y asciidoc texlive-latex-base dblatex xutils-dev
RUN apt-get install -y texlive texinfo
RUN apt-get install -y lib32z1 lib32ncurses5 lib32bz2-1.0
RUN apt-get install -y libc6-dev-i386
RUN apt-get install -y u-boot-tools
RUN apt-get install -y scrollkeeper
RUN apt-get install -y gparted
RUN apt-get install -y nfs-common nfs-kernel-server
RUN apt-get install -y git-core git-doc git-email git-gui gitk
RUN apt-get install -y meld atftpd

RUN ln -s /usr/lib/x86_64-linux-gnu/librt.so   /usr/lib/librt.so

ADD L2.6.35_1.1.0_130130_source.tar.gz /build/

WORKDIR /build/ 

RUN useradd build 
RUN chown -R build /build
USER build

RUN echo -e 'yes\nyes\n' | ./L2.6.35_1.1.0_130130_source/install

WORKDIR /build/ltib
ADD 0001_make_L2.6.35_1.1.0_130130_compile_on_ubuntu_13.10_64bit_OS.patch.zip /build/ltib/

RUN unzip 0001_make_L2.6.35_1.1.0_130130_compile_on_ubuntu_13.10_64bit_OS.patch.zip
RUN git apply 0001_make_L2.6.35_1.1.0_130130_compile_on_ubuntu_13.10_64bit_OS.patch

USER root
RUN apt-get install -y sudo wget
RUN echo 'build ALL = NOPASSWD: /usr/bin/rpm, /opt/freescale/ltib/usr/bin/rpm' >> /etc/sudoers
RUN apt-get install -y vim
RUN rm /bin/sh && ln -sf /bin/bash /bin/sh

RUN usermod -d /build build

# Hacky, doesn't compile otherwise. Seems like ccache issue.
RUN sed '/export BUILD_CC=/c\export BUILD_CC="/usr/bin/gcc"' -i dist/lfs-5.1/texinfo/texinfo.spec

USER build

ADD defconfig /build/ltib/defconfig

RUN ./ltib --preconfig defconfig -m config --batch

RUN sudo /opt/freescale/ltib/usr/bin/rpm --dbpath /opt/freescale/ltib/var/lib/rpm -ivh --force --ignorearch --nodeps /opt/freescale/pkgs/gcc-4.4.4-glibc-2.11.1-multilib-1.0-1.i386.rpm

ENV HOME=/build
CMD ./ltib -m shell
