FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Copy package files
COPY platform.pkg /tmp/platform.pkg
COPY brew.pkg /tmp/brew.pkg

# Install system dependencies from platform.pkg
RUN apt-get update && \
    # Read platform.pkg, filter comments/empty lines, trim whitespace, install packages
    grep -v '^#' /tmp/platform.pkg | grep -v '^[[:space:]]*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
    xargs -r apt-get install -y && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -s /bin/zsh aiuser && \
    usermod -aG sudo aiuser && \
    echo "aiuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER aiuser
WORKDIR /home/aiuser

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install NVM (Node Version Manager)
ENV NVM_DIR=/home/aiuser/.nvm
ENV NODE_VERSION=lts/*
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# Install pyenv and a default Python version
ENV PYENV_ROOT=/home/aiuser/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH
RUN curl https://pyenv.run | bash && \
    . /home/aiuser/.pyenv/pyenv.sh && \
    pyenv install $(pyenv install --list | grep -v - | grep -v b | tail -1) && \
    pyenv global $(pyenv install --list | grep -v - | grep -v b | tail -1)

# Install SDKMAN and a default Java version
ENV SDKMAN_DIR=/home/aiuser/.sdkman
RUN curl -s "https://get.sdkman.io" | bash && \
    . /home/aiuser/.sdkman/bin/sdkman-init.sh && \
    sdk install java $(sdk list java | grep -o \'[0-9]*\\.[0-9]*\\.[0-9]*-tem\' | head -1)

# Install Homebrew
ENV HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
ENV HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
ENV HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH
ENV NONINTERACTIVE=1
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Homebrew packages from brew.pkg
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    grep -v '^#' /tmp/brew.pkg | grep -v '^[[:space:]]*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
    xargs -r brew install

# Configure .zshrc with all environment variables
RUN echo '\
export LANG=en_US.UTF-8\
export LC_ALL=en_US.UTF-8\
\
# NVM Configuration\
export NVM_DIR="$HOME/.nvm"\
[ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"\
[ -s "$NVM_DIR/bash_completion" ] && \\. "$NVM_DIR/bash_completion"\
\
# Pyenv Configuration\
export PYENV_ROOT="$HOME/.pyenv"\
export PATH="$PYENV_ROOT/bin:$PATH"\
eval "$(pyenv init -)"\
\
# SDKMAN Configuration\
export SDKMAN_DIR="$HOME/.sdkman"\
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"\
\
# Homebrew Configuration\
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"\' >> ~/.zshrc

# Create workspace directory
RUN mkdir -p /home/aiuser/workspace

# Set working directory
WORKDIR /home/aiuser/workspace

# Default command
CMD ["/bin/zsh"]
