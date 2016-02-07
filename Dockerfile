FROM scratch

ARG IMAGE_TAR=image.tar

ADD $IMAGE_TAR /

CMD ["/bin/bash"]
