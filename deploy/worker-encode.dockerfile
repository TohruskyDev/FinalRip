FROM golang:1.22-bookworm AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /build

COPY . .

RUN go mod download

RUN make worker

FROM continuumio/miniconda3:24.5.0-0 AS app

# prepare environment
RUN conda install python=3.10.* -y
RUN apt update && apt install -y libgl1-mesa-glx

# install vapoursynth
RUN conda install conda-forge::vapoursynth=69 -y

# install vapoursynth C++ plugins
RUN conda install -n base libarchive -c main --force-reinstall -y
RUN conda install tongyuantongyu::vapoursynth-bestsource=5 -y
RUN conda install tongyuantongyu::vapoursynth-fmtconv=30 -y

# install python packages
RUN pip install numpy==1.26.4
RUN pip install opencv-python==4.10.0.82

# install vapoursynth python plugins
RUN conda install tongyuantongyu::vapoursynth-mvsfunc=10.10 -y
RUN conda install tongyuantongyu::vapoursynth-vsutil=0.8.0 -y
RUN pip install git+https://github.com/HomeOfVapourSynthEvolution/havsfunc.git

# worker app
WORKDIR /app

COPY --from=builder /build/worker/worker /app/
COPY --from=builder /build/conf/finalrip.yml /app/conf/

CMD ["/app/worker", "encode"]