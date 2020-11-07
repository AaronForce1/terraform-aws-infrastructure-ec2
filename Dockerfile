FROM registry.git.hk.asiaticketing.com/technology/system/utils/terraform:0.12.28

ENV TERM=xterm-256color
ENV ANSIBLE_FORCE_COLOR=true

RUN apk add --update bash sudo git vim aws-cli

RUN addgroup -S deploy && adduser -S deploy -G deploy --home /deploy
RUN echo "deploy ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers

COPY . /deploy/terraform_repo
RUN chown -R deploy:deploy /deploy


WORKDIR /deploy/terraform_repo