FROM ubuntu:16.04

MAINTAINER K-Lab Authors <service@kesci.com>

USER root 
# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV NB_USER kesci
ENV NB_UID 1000
ENV HOME /home/$NB_USER
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LD_LIBRARY_PATH /usr/local/lib:/opt/conda/lib
ENV KERAS_BACKEND tensorflow
ENV CFLAGS="-I /opt/conda/lib/python3.6/site-packages/numpy/core/include $CFLAGS"

# Install prerequisites
RUN apt-get update && apt-get -yqq dist-upgrade && \
    apt-get install -yqq --no-install-recommends \
    locales \
    bzip2 \
    ca-certificates \
    sudo \
    wget \
    # Install all OS dependencies for fully functional notebook server
    git \
    && \
    # Setup locales
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    # Create kesci user with UID=1000 and in the 'users' group
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER $CONDA_DIR

# Setup kesci home directory and install conda
COPY Miniconda3-4.4.10-Linux-x86_64.sh /tmp/Miniconda3-latest-Linux-x86_64.sh

RUN su -m -l $NB_USER -c '\
    mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/input && \
    mkdir /home/$NB_USER/.jupyter && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc && \
    # Install conda as kesci
    cd /tmp && \
    mkdir -p $CONDA_DIR && \
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    $CONDA_DIR/bin/conda --version && \
    $CONDA_DIR/bin/conda config --set show_channel_urls yes && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda clean -tipsy \
    ' && \
    echo "jpeg 9*" >> /opt/conda/conda-meta/pinned

# Delete files that pip caches when installing a package.
RUN rm -rf /root/.cache/pip/* && \
    # Delete old downloaded archive files 
    apt-get autoremove -y && \
    # Delete downloaded archive files
    apt-get clean && \
    # Ensures the current working directory won't be deleted
    cd /usr/local/src/ && \
    # Delete source files used for building binaries
    rm -rf /usr/local/src/* && \
    # Delete conda downloaded tarballs
    conda clean -y --tarballs && \
    # Delete matplotlib cache
    rm -rf /home/$NB_USER/.cache/matplotlib && \
    # Remove conda install script
    rm /tmp/Miniconda3-latest-Linux-x86_64.sh

# Make sure /usr/local/ and conda directories belong to user, and install fonts.
RUN chown $NB_USER /usr/local/bin && \
    chown $NB_USER /usr/local/share && \
    chown -R $NB_USER /usr/local/lib && \
    chown -R $NB_USER /opt/conda/lib/python3.6/site-packages/ && \
    mkdir -p /home/$NB_USER/.cache && chown $NB_USER -R /home/$NB_USER/.cache && \
    # Allow kesci run sudo apt-get
    echo "kesci ALL=NOPASSWD: /usr/bin/apt-get" > /etc/sudoers.d/kesci && chmod 0400 /etc/sudoers.d/kesci

WORKDIR /home/$NB_USER/work
USER $NB_USER

# Install Jupyter and Py3 packages
RUN mkdir -p ~/.pip/ && \
    pip install --upgrade pip && \
    pip install jupyter && \
    pip install \
    opencv-python==3.4.4.19 \
    scipy==1.2.0 \
    numpy==1.15.4 \
    scikit-learn==0.20.2 \
    keras==2.2.4 \
    patsy==0.5.1 \
    pandas==0.23.4 \
    theano==1.0.3 \
    xgboost==0.81 \
    statsmodels==0.9.0 \
    tensorflow==1.12.0 \
    line_profiler==2.1.2 \
    orderedmultidict==1.0 \
    smhasher==0.150.1 \
    textblob==0.15.1 \
    h5py==2.8.0.rc1 \
    pudb==2017.1 \
    bokeh==1.0.2 \
    seaborn==0.9.0 \
    pillow==5.3.0 \
    mpld3==0.3 \
    mplleaflet==0.0.5 \
    gpxpy==1.1.2 \
    arrow==0.12.1 \
    sexmachine==0.1.1 \
    geohash==1.0 \
    tpot==0.6.8 \
    haversine==0.4.5 \
    toolz==0.8.2 \
    cytoolz==0.8.2 \
    sacred==0.6.10 \
    plotly==3.4.2 \
    fitter==1.0.8 \
    langid==1.1.6 \
    delorean==0.6.0 \
    trueskill==0.4.4 \
    heamy==0.0.7 \
    vida==0.3 \
    missingno==0.4.0 \
    pandas-profiling==1.4.0 \
    s2sphere==0.2.4 \
    matplotlib-venn==0.11.5 \
    pyldavis==2.1.1 \
    altair==1.2.0 \
    ml_metrics==0.1.4 \
    tables==3.4.2 \
    blaze==0.10.1 \
    pydot==1.2.3 \
    pyparsing==2.1.10 \
    mdp==3.5 \
    rsa==3.4.2 \
    netaddr==0.7.19 \
    bs4==0.0.1 \
    jieba==0.39 \
    lightgbm==2.1.0 \
    xlrd==1.0.0 \
    h2o==3.18.0.4 \
    mxnet==1.1.0.post0 \
    wordcloud==1.4.1 \
    gensim==3.4.0 \
    pygal==2.4.0 \
    cufflinks==0.12.1 \
    bunch==1.0.1 \
    https://download.pytorch.org/whl/cpu/torch-1.0.0-cp36-cp36m-linux_x86_64.whl \
    torchvision \
    lxml==4.2.1 \
    xlearn==0.40a1 \
    mlxtend==0.12.0 \
    librosa==0.6.1 \
    python_speech_features==0.6 \
    sympy==1.2 \
    nltk==3.3 \
    tornado==4.5.3 \
    scikit-image==0.14.1 \
    onnx==1.3.0 \
    # klab-plugin
    klab-autotime==0.0.2 \
    && \
    jupyter nbextension install --user --py vega

# Install chinese fonts, set minus numbers available,  and set it as default(must be set after matplotlib installed), add tuna mirror pypi souce index
COPY MicrosoftYaHei.ttf /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/fonts/ttf/
RUN echo 'font.family         : sans-serif' >> /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc && \
    echo 'font.sans-serif     : Microsoft YaHei, DejaVu Sans, Bitstream Vera Sans, Lucida Grande, Verdana, Geneva, Lucid, Arial, Helvetica, Avant Garde, sans-serif' >> /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc && \
    echo 'axes.unicode_minus  : False' >> /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc && \
 
RUN rm -rf /home/$NB_USER/.cache/pip/*
