FROM ubuntu:24.04

# Argomento per la versione di CODA (passato dal docker-compose)
ARG CODA_VERSION=2.25.6

# Installa dipendenze di build e runtime
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    bison \
    flex \
    git \
    libhdf4-dev \
    libhdf5-dev \
    libnetcdf-dev \
    python3-dev \
    python3-numpy \
    python3-cffi \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Crea symlink per 'python' → 'python3'
RUN ln -s /usr/bin/python3 /usr/bin/python

# Clona il repository CODA con la versione specificata
RUN git clone --depth 1 --branch ${CODA_VERSION} https://github.com/stcorp/coda.git /coda || \
    (git clone https://github.com/stcorp/coda.git /coda && cd /coda && git checkout ${CODA_VERSION})
WORKDIR /coda

# Bootstrap
RUN ./bootstrap

# Configura con variabili per HDF4, HDF5, NetCDF + LDFLAGS per fixare linking HDF4
RUN HDF4_LIB=/usr/lib/x86_64-linux-gnu HDF4_INCLUDE=/usr/include/hdf \
    HDF5_LIB=/usr/lib/x86_64-linux-gnu/hdf5/serial HDF5_INCLUDE=/usr/include/hdf5/serial \
    NETCDF_LIB=/usr/lib/x86_64-linux-gnu NETCDF_INCLUDE=/usr/include \
    LDFLAGS="-L/usr/lib/x86_64-linux-gnu -lmfhdf -ldf" \
    ./configure --prefix=/usr/local \
    --with-hdf4 \
    --with-hdf5 \
    --with-netcdf \
    --enable-python

# Compila e installa
RUN make -j$(nproc)
RUN make install

# Aggiorna ldconfig
RUN ldconfig

# Trova dove sono stati installati i binding Python
RUN find /usr/local -name "*coda*.py" -o -name "*coda*.so" 2>/dev/null || true
RUN python3 -c "import sys; print('\n'.join(sys.path))"

# Imposta variabili d'ambiente per CODA e Python
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib/x86_64-linux-gnu/hdf5/serial:/usr/lib/x86_64-linux-gnu
ENV PATH=/usr/local/bin:$PATH
ENV PYTHONPATH=/usr/local/lib/python3.12/dist-packages:/usr/local/lib/python3.12/site-packages

# Crea script di benvenuto
RUN echo '#!/bin/bash' > /usr/local/bin/welcome.sh && \
    echo 'echo "=========================================="' >> /usr/local/bin/welcome.sh && \
    echo 'echo "     Welcome to CODA Development Container"' >> /usr/local/bin/welcome.sh && \
    echo 'echo "=========================================="' >> /usr/local/bin/welcome.sh && \
    echo 'echo ""' >> /usr/local/bin/welcome.sh && \
    echo 'echo "CODA Version Information:"' >> /usr/local/bin/welcome.sh && \
    echo 'python -c "import coda; print(f\"CODA Python binding version: {coda.version()}\")" 2>/dev/null || echo "CODA Python bindings not available"' >> /usr/local/bin/welcome.sh && \
    echo 'echo ""' >> /usr/local/bin/welcome.sh && \
    echo 'echo "Available tools:"' >> /usr/local/bin/welcome.sh && \
    echo 'echo "  - codacheck"' >> /usr/local/bin/welcome.sh && \
    echo 'echo "  - codacmp"' >> /usr/local/bin/welcome.sh && \
    echo 'echo "  - codadump"' >> /usr/local/bin/welcome.sh && \
    echo 'echo "  - codaeval"' >> /usr/local/bin/welcome.sh && \
    echo 'echo "  - codafind"' >> /usr/local/bin/welcome.sh && \
    echo 'echo ""' >> /usr/local/bin/welcome.sh && \
    echo 'echo "Your source files are mounted in: /workspace"' >> /usr/local/bin/welcome.sh && \
    echo 'echo "=========================================="' >> /usr/local/bin/welcome.sh && \
    echo 'echo ""' >> /usr/local/bin/welcome.sh && \
    chmod +x /usr/local/bin/welcome.sh

WORKDIR /workspace

# Esegui lo script di benvenuto e poi bash
CMD ["/bin/bash", "-c", "/usr/local/bin/welcome.sh && exec /bin/bash"]