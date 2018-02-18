FROM quay.io/pypa/manylinux1_x86_64

RUN uname -a

RUN ( \
    yum -y update && \
    yum install -y \
        bzip2-devel \
        openssl-devel \
        pcre-devel \
        readline-devel \
        sqlite-devel \
        xz-devel \
        zlib-devel \
)

RUN ( \
    curl -L "https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer" | bash && \
    echo 'export PATH="/root/.pyenv/bin:$PATH" && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc \
)

RUN /opt/python/cp36-cp36m/bin/pip install virtualenv

ENV MANYLINUX=1
