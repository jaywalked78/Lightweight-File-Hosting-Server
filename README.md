# Lightweight-File-Hosting-Server

A high-performance, lightweight server for hosting local files with HTTP URLs. Built with Python, this tool makes file sharing simple with fast uploads, easy access, and minimal configuration.

## Features

- Serve files from any local directory with blazing-fast loading
- Parallel processing with ThreadPoolExecutor and async I/O
- Batch processing to optimize performance
- Interactive progress bars for real-time loading feedback
- Load and unload directories on demand
- RESTful API for directory management
- Auto-unload timeout (configurable in `.env` file)
- Environment variable support for flexible configuration
- Support for absolute and relative path resolution

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/jaywalked78/Lightweight-File-Hosting-Server.git
cd Lightweight-File-Hosting-Server
```

2. Create a virtual environment:
```bash
python3 -m venv tinyHosterVenv
```

3. Copy and configure the environment variables:
```bash
cp .env.example .env
# Edit .env to set your preferences and paths
```

4. Load files from a directory:
```bash
./run_with_progress.sh /path/to/your/files
```

5. Use the file URLs in your application:
```
http://localhost:7779/files/<file_name>
```

6. When finished, unload the directory:
```bash
./unload_directory.sh
```

## Performance

The optimized file loader (`load_folder_v2.py`) offers significant performance improvements:

- **Parallel Processing**: Uses ThreadPoolExecutor to load multiple files concurrently
- **Asynchronous I/O**: Implements async processing with asyncio and aiohttp
- **Batch Processing**: Processes files in configurable batches for better throughput
- **Smart Header Checking**: Verifies file availability without downloading full content
- **Real-time Progress Tracking**: Shows actual loading progress with tqdm progress bars

Example performance gains:
- Original sequential loader: ~10 minutes for a typical directory
- Optimized parallel loader: Under 2 seconds for the same directory (up to 300x faster)

## Configuration

### Environment Variables

The application uses the following environment variables (defined in `.env`):

- `FILE_SERVER_PORT`: The port to run the file server on (default: 7779)
- `FILE_SERVER_HOST`: The host to bind the server to (default: 0.0.0.0)
- `FILE_SERVER_TIMEOUT`: Auto-unload timeout in minutes (default: 30, 0 = disabled)
- `FILE_BASE_DIR`: Base directory for resolving relative paths

### Command-Line Arguments

The `run_with_progress.sh` script accepts the following arguments:

```bash
./run_with_progress.sh <directory_path> [options]
# or
./run_with_progress.sh --dir=<directory_path> [options]
```

Additional options:
- `--server`: Custom server URL (default: http://localhost:7779)
- `--output`: Directory to save JSON output (default: ~/Documents/LightweightFileServer/output/json)
- `--unload`: Unload directory when done
- `--unload-first`: Unload any previous directories before loading new ones
- `--timeout`: Set timeout in minutes (0 to disable)
- `--name`: Custom name for the output JSON file
- `--workers`: Number of concurrent workers (default: 10)
- `--batch-size`: Batch size for file uploads (default: 20)

## Scripts

The following scripts are provided:

- `run_with_progress.sh`: Main script for loading files with real-time progress tracking
- `load_folder_v2.py`: Optimized Python script with parallel/async file loading
- `persistent_run.sh`: Runs the file server in persistent mode
- `unload_directory.sh`: Unloads the current directory from the server

## API Endpoints

The server provides the following endpoints:

- `GET /`: Get information about the currently loaded directory
- `POST /load-directory`: Load a directory of files
- `GET /files/{file_name}`: Get a specific file
- `POST /unload`: Unload the current directory
- `GET /timeout`: Get current timeout settings
- `POST /timeout/{minutes}`: Set a new timeout value

## Output

When loading files, a JSON file is generated in the output directory with:
- URLs for all files
- Server information
- Timeout settings
- Directory information

Example:
```json
{
  "success": true,
  "directory": "/path/to/your/files",
  "timestamp": "2023-11-15 14:30:00",
  "message": "Generated URLs for 150 files",
  "count": 150,
  "file_urls": [
    "http://localhost:7779/files/file1.txt",
    "http://localhost:7779/files/file2.pdf",
    ...
  ],
  "timeout_minutes": 30,
  "auto_unload_at": "2023-11-15 15:00:00",
  "time_remaining": "29m 45s"
}
```

## Requirements

- Python 3.7+
- Dependencies (installed automatically):
  - tqdm
  - aiohttp
  - aiofiles
  - python-dotenv
  - PIL (optional, for image dimensions)

## License

MIT
