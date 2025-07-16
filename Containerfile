FROM registry.access.redhat.com/ubi9:9.5

ENV BUILDAH_ISOLATION=chroot

COPY --chown=0:0 entrypoint.sh /
COPY --chown=0:0 create-backup-image.sh /

RUN dnf install -y buildah ; \
  dnf update -y ; \
  dnf clean all ; \
  chgrp -R 0 /home ; \
  chmod -R g=u /home ${WORK_DIR} ; \
  chmod +x /entrypoint.sh /create-backup-image.sh ; \
  chown 0:0 /etc/passwd ; \
  chown 0:0 /etc/group ; \
  chmod g=u /etc/passwd /etc/group ; \
  # Setup for rootless podman
  setcap cap_setuid+ep /usr/bin/newuidmap ; \
  setcap cap_setgid+ep /usr/bin/newgidmap ; \
  touch /etc/subgid /etc/subuid ; \
  chown 0:0 /etc/subgid ; \
  chown 0:0 /etc/subuid ; \
  chmod -R g=u /etc/subuid /etc/subgid

USER 1000
ENTRYPOINT ["/entrypoint.sh"]
