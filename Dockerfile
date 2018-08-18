FROM perl:5.26
MAINTAINER Tore Andersson

# Build:
# docker build -t cpanminiserver .

# After build:
# docker run -it -v /my/home/.minicpan:/root/.minicpan cpanminiserver script/cpanminiserver.pl -i '' -p 9999 -m <mirror url> -d /root/.minicpan

# docker run -it -v /home/tore/dev/CPAN-Mini-Server:/root/CPAN-Mini-Server cpanminiserver minil dist

# Then using cpanm elsewhere
# cpanm --mirror http://<ip of docker>:<port> --mirror-only My::Module

RUN apt update && apt install -y apt-utils nano less

RUN cpanm \
  Minilla \
  Test::CPAN::Meta  \
  Test::MinimumVersion::Fast  \
  Test::PAUSE::Permissions  \
  Test::Pod \
  Test::Spellunker

RUN cpanm Minilla

COPY . /root/CPAN-Mini-Server
WORKDIR /root/CPAN-Mini-Server

RUN cpanm --installdeps .

EXPOSE 9999

