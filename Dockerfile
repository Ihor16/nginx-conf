FROM nginx:1.23

RUN apt update -y && \
    apt upgrade -y
RUN apt install neovim -y

RUN apt install less -y
