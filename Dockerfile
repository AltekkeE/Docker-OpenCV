# build works with Jessie, maybe not with newer versions - YMMV
FROM debian:jessie
MAINTAINER Mark Lennox mark@webpusher.ie

ENV CPUCOUNT 1
RUN CPUCOUNT=$(cat /proc/cpuinfo | grep '^processor.*:' | wc -l)

ENV OPENCV_VERSION 3.1.0

# install OpenCV 3 =======================
RUN pip install numpy && \
	pip3 install numpy

# prepare Python
RUN apt-get update && \
	apt-get -y -f install \
		python3.4-dev \
		build-essential \
		libssl-dev \
		openssl \
		cmake git pkg-config \
		# libtiff4-dev not available in Debian use libtiff5-dev instead?
		# libjpeg8-dev not available on Debian jessie, use libjpeg62-turbo-dev instead?
		libjpeg62-turbo-dev libtiff5-dev libjasper-dev libpng12-dev \
		libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
		libgtk2.0-dev \
		libatlas-base-dev gfortran \
		tesseract-ocr tesseract-ocr-eng libtesseract-dev libleptonica-dev
		# libleptonica-dev tesseract-ocr

RUN cd /opt/ && \
	git clone https://github.com/Itseez/opencv.git && \
	git clone https://github.com/Itseez/opencv_contrib.git && \
	cd opencv && \
	git checkout ${OPENCV_VERSION} && \
	cd ../opencv_contrib && \
	git checkout ${OPENCV_VERSION}

RUN mkdir -p /opt/opencv/build && \
	cd /opt/opencv/build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE \
		-D CMAKE_INSTALL_PREFIX=/usr/local \
		# -D INSTALL_C_EXAMPLES=ON \
		# -D INSTALL_PYTHON_EXAMPLES=ON \
		-D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
		# -D BUILD_EXAMPLES=ON \
		.. && \
	make -j${CPUCOUNT} && \
	make install && \
	ldconfig

# RUN OPENCVBINDING=$(ls /usr/local/lib/python3.4/site-packages/cv2.cpython*.*) && \
# 	cd /root/.virtualenvs/cv/lib/python3.4/site-packages/ && \
# 	ln -s ${OPENCVBINDING} cv2.so

# now clean up the unwanted source
RUN cd /opt && \
	rm -rf /opt/opencv && \
	rm -rf /opt/opencv_contrib && \
	apt-get purge -y cmake && \
	apt-get autoremove -y --purge

# no CMD