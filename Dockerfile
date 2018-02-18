FROM quay.io/pypa/manylinux1_x86_64

RUN ( \
    yum -y update && \
    yum install -y zlib-devel openssl-devel sqlite-devel bzip2-devel readline-devel \
)

RUN ( \
    curl -L "https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer" | bash && \
    echo 'export PATH="/root/.pyenv/bin:$PATH" && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc \
)

RUN "/root/.pyenv/bin/pyenv" install -s -v 3.6.3

WORKDIR /pyginx
