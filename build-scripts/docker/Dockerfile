FROM 32bit/debian

RUN apt-get -y update && \
    apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm vim sed wget cvs subversion coreutils texi2html docbook-utils python-pysqlite2 help2man desktop-file-utils cpio sudo rpm curl guilt iasl quilt bin86 bcc liburi-perl genisoimage policycoreutils libncurses5-dev jq

# Install GHC prereqs
RUN cd /tmp && \
    wget http://archive.debian.org/debian/pool/main/g/gmp/libgmpxx4ldbl_4.3.2+dfsg-1_i386.deb http://archive.debian.org/debian/pool/main/g/gmp/libgmp3c2_4.3.2+dfsg-1_i386.deb http://archive.debian.org/debian/pool/main/g/gmp/libgmp3-dev_4.3.2+dfsg-1_i386.deb && \
    dpkg -i libgmpxx4ldbl_4.3.2+dfsg-1_i386.deb libgmp3c2_4.3.2+dfsg-1_i386.deb libgmp3-dev_4.3.2+dfsg-1_i386.deb && \
    wget http://www.haskell.org/ghc/dist/6.12.3/ghc-6.12.3-i386-unknown-linux-n.tar.bz2 && \
    tar jxf ghc-6.12.3-i386-unknown-linux-n.tar.bz2 && \
    cd /tmp/ghc-6.12.3 && \
    ./configure --prefix=/usr && \
    make install

# Set up user and shell
RUN useradd -m build && \
    gpasswd -a build sudo && \
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash && \
    sed -i 's/%sudo\(.*\) ALL/%sudo\1 NOPASSWD: ALL/' /etc/sudoers

# install build configs
ADD root/home/build/build.sh /home/build
RUN chmod 755 /home/build/build.sh && \
    chown -R build:build /home/build
