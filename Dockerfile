FROM python:3.8-slim-buster
FROM restreamio/gstreamer:1.18.2.0-prod
WORKDIR /app


RUN apt update && apt install -y python3-pip
RUN python3 -m pip install --upgrade pip
RUN pip install --upgrade setuptools
# Various Python and C/build deps
# RUN apt-get update && apt-get install -y \
#     gstreamer1.0*
# RUN apt install -y ubuntu-restricted-extras
RUN apt install -y build-essential cmake git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb2 libtbb-dev libdc1394-22-dev libopenexr-dev \
    libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev



# Install Open CV - Warning, this takes absolutely forever

RUN git clone https://github.com/opencv/opencv.git /home/thomas/Desktop/opencv-gstreamer/opencv && \
    cd /home/thomas/Desktop/opencv-gstreamer/opencv && \
    git checkout 4.5.1 && \
#     unzip 4.5.1.zip && \
#     rm 4.5.1.zip && \
#     mv opencv-3.0.0 OpenCV && \
#     cd OpenCV && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D PYTHON_EXECUTABLE=$(which python3) \
    -D BUILD_opencv_python2=OFF \
    -D CMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
    -D PYTHON3_EXECUTABLE=$(which python3) \
    -D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
    -D WITH_GSTREAMER=ON \
    -D BUILD_EXAMPLES=ON .. && \
    make -j4 && \
    make install


COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
