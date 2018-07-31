# Yang Dai -- MIT Chemistry Ceyer Lab
FROM jupyter/minimal-notebook

LABEL maintainer="Yang Dai <daiy@mit.edu>"

USER $NB_UID

# Install Python 3 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda install --quiet --yes \
    'conda-forge::blas=*=openblas' \
    'ipywidgets=7.2*' \
    'cython=0.28*' \
    'bokeh=0.12*' \

    # lab-specific package from conda channel
    'lmfit=0.9.10*' \
    'pandas=0.23*' \
    'matplotlib=2.2*' \
    'scipy=1.1*' \

    # packages not from conda channel
    &&pip install --quiet \
    'Logbook' \

    &&conda remove --quiet --yes --force qt pyqt \
    &&conda clean -tipsy \
    # Activate ipywidgets extension in the environment that runs the notebook server
    &&jupyter nbextension enable --py widgetsnbextension --sys-prefix \
    # Also activate ipywidgets extension for JupyterLab
    &&jupyter labextension install @jupyter-widgets/jupyterlab-manager@^0.36.0 \
    &&jupyter labextension install jupyterlab_bokeh@^0.6.0 \
    &&npm cache clean --force \
    &&rm -rf $CONDA_DIR/share/jupyter/lab/staging \
    &&rm -rf /home/$NB_USER/.cache/yarn \
    &&rm -rf /home/$NB_USER/.node-gyp \
    &&fix-permissions $CONDA_DIR \
    &&fix-permissions /home/$NB_USER

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
    &&fix-permissions /home/$NB_USER

USER $NB_UID
