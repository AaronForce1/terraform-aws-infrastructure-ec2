FROM registry.git.hk.asiaticketing.com/ansible/deployments:1.0.0

ENV TERM=xterm-256color
ENV ANSIBLE_FORCE_COLOR=true

RUN wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip && unzip /tmp/terraform.zip -d /usr/local/bin/

COPY . /deploy/terraform_repo
RUN chown -R deploy:deploy /deploy

WORKDIR /deploy/terraform_repo