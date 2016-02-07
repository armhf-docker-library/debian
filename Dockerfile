FROM scratch

ARG IMAGE=image.tar

ADD $IMAGE /

CMD ["/bin/bash"]
