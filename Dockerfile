FROM ubuntu:latest

RUN apt update
RUN apt install openssh-client -y
#RUN service sshd enable
#RUN service sshd restart

RUN apt-get install -y borgbackup

ENV BORG_RSH='ssh -o StrictHostKeyChecking=no'
ENV BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes

WORKDIR /root

COPY params.sh /root

RUN chmod +x params.sh

CMD ["/bin/bash", "./params.sh"]
