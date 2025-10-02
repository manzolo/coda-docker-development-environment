# CODA Docker Development Environment

## Quick Start

1. **Configure environment** (optional):
   Edit `.env` file to customize settings

2. **Run the manager**:
   ```bash
   ./coda-manager.sh
   ```

3. **Build and start**:
   - Select option 1 to build the Docker image
   - Select option 2 to start the container
   - Select option 4 to enter the container shell

## Project Structure

```
.
├── Dockerfile           # Docker image definition
├── docker-compose.yml   # Docker Compose configuration
├── .env                # Environment variables
├── coda-manager.sh     # Interactive management script
├── setup.sh           # Initial setup script
├── src/               # Your source code directory
├── data/              # Data files directory
└── output/            # Output files directory
```

## Available Commands in Container

- `codacheck` - Check CODA product files
- `codacmp` - Compare CODA products
- `codadump` - Dump CODA product contents
- `codaeval` - Evaluate expressions on CODA products
- `codafind` - Find CODA products

## Python Usage

```python
import coda

# Check version
print(coda.version())

# Open a product file
pf = coda.open("your_file.nc")

# Work with the product
# ...

# Close the product
coda.close(pf)
```

## Configuration

Edit `.env` file to change:
- `CODA_VERSION`: Version of CODA to use
- `SOURCE_PATH`: Path to your source files
- `CONTAINER_NAME`: Name of the Docker container
- `PROJECT_NAME`: Name of the project

## Troubleshooting

If you encounter issues:
1. Check Docker is running: `docker ps`
2. View logs: Use option 5 in the manager
3. Rebuild image: Use option 1 in the manager
4. Check status: Use option 6 in the manager
