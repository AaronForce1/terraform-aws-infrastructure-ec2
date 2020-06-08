FROM hashicorp/terraform:light

ENV TERM=xterm-256color
ENV ANSIBLE_FORCE_COLOR=true

WORKDIR /deploy
COPY . ./terraform_repo

WORKDIR /deploy/terraform_repo