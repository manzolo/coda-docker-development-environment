# CODA Docker Development Environment

[![CODA](https://img.shields.io/badge/CODA-v2.25.6-blue)](https://github.com/stcorp/coda)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](https://www.docker.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu)](https://ubuntu.com/)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python)](https://www.python.org/)

A complete Docker-based development environment for **CODA** (Common Data Access toolset), providing easy access to tools for reading and processing Earth Observation data products.

## 📚 About CODA

**CODA** is a versatile toolset developed by [S&T](https://www.stcorp.nl/) for accessing and analyzing data from various Earth Observation missions. It provides a unified interface for reading complex scientific data formats.

### Official Resources
- 🌐 **GitHub Repository**: [https://github.com/stcorp/coda](https://github.com/stcorp/coda)
- 📖 **Python Documentation**: [https://stcorp.github.io/coda/doc/html/python/index.html](https://stcorp.github.io/coda/doc/html/python/index.html)
- 📘 **Full Documentation**: [https://stcorp.github.io/coda/doc/html/index.html](https://stcorp.github.io/coda/doc/html/index.html)

### Supported Formats
CODA supports reading data from numerous satellite missions and instruments including:
- **ESA Missions**: Envisat (GOMOS, MIPAS, SCIAMACHY), ERS, Sentinel series
- **Third Party Missions**: GOSAT, NPP, Aura (OMI, TES, MLS, HIRDLS), Calipso, CloudSat
- **Data Formats**: HDF4, HDF5, NetCDF, GRIB, SP3, RINEX, and many mission-specific formats

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- `dialog` package for interactive menu (optional but recommended)
  ```bash
  # Ubuntu/Debian
  sudo apt-get install dialog
  
  # MacOS
  brew install dialog
  
  # RHEL/CentOS
  sudo yum install dialog
  ```

### Installation

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/manzolo/coda-docker-development-environment
   cd coda-docker-development-environment
   ```

2. **Run the initial setup**
   ```bash
   chmod +x setup.sh coda-manager.sh
   ./setup.sh
   ```

3. **Launch the interactive manager**
   ```bash
   ./coda-manager.sh
   ```

4. **Build and start the container**
   - Select option `1` to build the Docker image
   - Select option `2` to start the container
   - Select option `4` to enter the container shell

## 📁 Project Structure

```
.
├── Dockerfile           # Docker image definition with CODA build instructions
├── docker-compose.yml   # Docker Compose configuration
├── .env                # Environment variables (CODA version, paths)
├── coda-manager.sh     # Interactive management script with dialog UI
├── setup.sh           # Initial setup script
├── src/               # Your source code directory (mounted to /workspace)
│   └── test_coda.py   # Sample Python script to test CODA
├── data/              # Data files directory (for your .nc, .h5 files)
└── output/            # Output files directory
```

## 🛠️ Available CODA Tools

Once inside the container, you have access to all CODA command-line tools:

| Tool | Description | Example Usage |
|------|-------------|---------------|
| `codacheck` | Verify product file integrity | `codacheck product.nc` |
| `codacmp` | Compare two product files | `codacmp file1.nc file2.nc` |
| `codadump` | Display product contents | `codadump -d product.nc` |
| `codaeval` | Evaluate expressions on products | `codaeval -e "latitude" product.nc` |
| `codafind` | Search for products matching criteria | `codafind -filter "*.nc"` |
| `codadd` | Access CODA definition database | `codadd list` |

## 🐍 Python Usage

The container includes Python 3.12 with CODA bindings pre-installed. Here are some examples:

### Basic Usage
```python
import coda

# Check CODA version
print(f"CODA version: {coda.version()}")

# Open a product file
product = coda.open("data/sample_product.nc")

# Get product type and format
product_type = coda.get_product_type(product)
product_format = coda.get_product_format(product)
print(f"Product type: {product_type}")
print(f"Product format: {product_format}")

# Close the product
coda.close(product)
```

### Advanced Example - Reading Data
```python
import coda
import numpy as np

# Open a product
pf = coda.open("data/S5P_OFFL_L2_NO2.nc")

# Navigate to a specific data field
cursor = coda.Cursor()
coda.cursor_set_product(cursor, pf)
coda.cursor_goto(cursor, "PRODUCT/nitrogen_dioxide_tropospheric_column")

# Read the data
data = coda.cursor_read_array(cursor)
print(f"Data shape: {np.array(data).shape}")

# Clean up
coda.close(pf)
```

### Working with Attributes
```python
import coda

pf = coda.open("data/product.h5")

# Get product attributes
attributes = coda.get_product_attributes(pf)
for key, value in attributes.items():
    print(f"{key}: {value}")

# Get specific variable attributes
cursor = coda.Cursor()
coda.cursor_set_product(cursor, pf)
coda.cursor_goto(cursor, "/PRODUCT/latitude")

# Read variable attributes
num_elements = coda.cursor_get_num_elements(cursor)
print(f"Number of elements: {num_elements}")

coda.close(pf)
```

## ⚙️ Configuration

### Environment Variables (.env)

The `.env` file controls the Docker environment configuration:

```bash
# CODA Configuration
CODA_VERSION=2.25.6        # CODA version to build (see GitHub releases)

# Container Configuration
CONTAINER_NAME=coda-dev    # Docker container name
PROJECT_NAME=coda-project  # Docker project name

# Volume Configuration
SOURCE_PATH=./src          # Path to your source code (mounted to /workspace)
```

### Changing CODA Version

To use a different CODA version:

1. Edit `.env` file and change `CODA_VERSION`
2. Or use the interactive manager (option 7)
3. Rebuild the image (option 1 in manager)

Available versions: [https://github.com/stcorp/coda/releases](https://github.com/stcorp/coda/releases)

## 🔧 Container Management

### Using the Interactive Manager

The `coda-manager.sh` script provides a user-friendly dialog interface:

```
┌─────────────────────────────────┐
│        CODA Docker Manager      │
├─────────────────────────────────┤
│ 1. Build Docker Image           │
│ 2. Start Container              │
│ 3. Stop Container               │
│ 4. Enter Container Shell        │
│ 5. View Container Logs          │
│ 6. Check Container Status       │
│ 7. Edit Configuration           │
│ 8. Initialize Source Directory  │
│ 9. Clean Docker Resources       │
│ 10. About                       │
│ 11. Exit                        │
└─────────────────────────────────┘
```

### Manual Docker Commands

If you prefer using Docker directly:

```bash
# Build the image
docker-compose build

# Start the container
docker-compose up -d

# Enter the container
docker-compose exec coda /bin/bash

# Stop the container
docker-compose down

# View logs
docker-compose logs -f

# Remove everything including volumes
docker-compose down -v
```

## 📊 Working with Data Files

1. **Place your data files** in the `./data` directory
2. **Access them in the container** at `/workspace/data/`
3. **Save outputs** to `/workspace/output/` (mapped to `./output`)

Example workflow:
```bash
# Outside container: copy your data files
cp ~/Downloads/*.nc ./data/

# Inside container: process them
cd /workspace
python src/process_data.py data/input.nc output/result.csv
```

## 🧪 Testing Installation

A test script is automatically created during setup:

```bash
# Inside the container
python /workspace/test_coda.py
```

Expected output:
```
✓ CODA successfully imported
✓ CODA version: 2.25.6
✓ CODA Python bindings are working correctly
```

## 🐛 Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Container won't start | Check Docker daemon: `sudo systemctl status docker` |
| Build fails | Check internet connection and GitHub access |
| Python import error | Rebuild image with option 1 in manager |
| Permission denied | Check file permissions: `chmod +x *.sh` |
| Out of space | Clean Docker: `docker system prune -a` |

### Debug Commands

```bash
# Check container status
docker ps -a | grep coda

# Inspect container
docker inspect coda-dev

# Check CODA installation inside container
docker exec coda-dev python -c "import coda; print(coda.version())"

# View detailed logs
docker-compose logs --tail=50 coda

# Check volume mounts
docker exec coda-dev ls -la /workspace
```

### Getting Help

1. Check the official CODA documentation
2. View container logs (option 5 in manager)
3. Check CODA GitHub issues: [https://github.com/stcorp/coda/issues](https://github.com/stcorp/coda/issues)
4. Verify your data files are in supported formats

## 📝 Notes

- The container uses Ubuntu 24.04 as base image
- Includes support for HDF4, HDF5, and NetCDF formats
- Python bindings are automatically configured
- All CODA tools are available in the system PATH
- The working directory inside container is `/workspace`

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## 📄 License

This Docker environment is provided as-is. CODA itself is licensed under BSD-3-Clause. See [CODA License](https://github.com/stcorp/coda/blob/master/LICENSE) for details.

## 🙏 Acknowledgments

- [S&T Corporation](https://www.stcorp.nl/) for developing and maintaining CODA
- The Earth Observation community for continuous support

---

**Version**: 1.0.0  
**Last Updated**: 10-03-2025
**CODA Version**: 2.25.6