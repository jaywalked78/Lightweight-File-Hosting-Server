# Lightweight Image Server (formerly TinyImageHoster)

A high-performance, lightweight image server optimized for hosting local images and generating accessible HTTP URLs. It plays a crucial role in machine learning workflows, particularly RAG pipelines involving multimodal data, by providing stable URLs for visual content like screen recording frames.

While maintaining a small footprint, this server is optimized for stability and performance, capable of efficiently loading and serving numerous images. Integration with tools like Ngrok ([NGROK_SETUP.md](./NGROK_SETUP.md)) allows for easy generation of stable public URLs, essential when integrating with external services like n8n or AI models.

## Workflow Context

This Image Server is often used within a larger content ingestion pipeline, providing the necessary URLs for visual context alongside processed text. Here's a typical workflow where it fits in, orchestrated heavily by n8n:

```mermaid
flowchart TD
    A[Video Input] --> B(n8n: Trigger Frame Processor);
    B --> C{[Frame Processor Extractor]};
    C --> D(n8n: AI Enrichment + OCR Refinement + Airtable Upsert);
    D --> E(n8n: Trigger IntelliChunk);
    E --> F{IntelliChunk + LIGHTWEIGHT IMAGE SERVER};
    F --> G(n8n: Embedding Generation);
    G --> H[(PostgreSQL Vector DB)];
```

In this pipeline:
- Raw images (e.g., frames extracted by the Frame Processor) are stored locally.
- The `Lightweight Image Server` is run (often via `persistent_run.sh`) to host these images.
- The [IntelliChunk](https://github.com/jaywalked78/IntelliChunk) processor (or other parts of the n8n workflow) interacts with this server via its API (`/load-directory`) to ensure images are loaded and gets the corresponding `http://.../images/<image_name>` URLs.
- These URLs are then combined with the chunked text data before embedding and storage, allowing RAG systems to retrieve both text and relevant visuals.

## Features

- **Efficient Serving:** Serve images (and potentially other files) from local directories.
- **URL Generation:** Provides stable HTTP URLs for locally hosted files.
- **High Performance:** Optimized loading using parallel processing (ThreadPoolExecutor) and async I/O (`load_folder_v2.py`).
- **API Control:** RESTful API for loading/unloading directories and managing server state.
- **Progress Tracking:** Interactive progress bars during bulk loading (`run_with_progress.sh`).
- **Configurable:** Uses `.env` for port, host, auto-unload timeout, and base directories.
- **Ngrok Integration:** Scripts and documentation for exposing the server publicly via Ngrok.

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/jaywalked78/Lightweight-File-Hosting-Server.git
cd Lightweight-File-Hosting-Server
```

2. Create a virtual environment (optional but recommended):
```bash
python3 -m venv venv
source venv/bin/activate
```

3. Copy and configure the environment variables:
```bash
cp .env.example .env
# Edit .env: Set IMAGE_SERVER_PORT, IMAGE_SERVER_HOST, FRAME_BASE_DIR
```

4. Start the persistent server:
```bash
./persistent_run.sh
# Server will run in the background
```

5. Load images using the API or script:
   - **Via script (shows progress):**
     ```bash
     ./run_with_progress.sh /path/to/your/images
     ```
   - **Via API (e.g., from n8n):**
     ```bash
     curl -X POST -H "Content-Type: application/json" -d '{"directory": "/path/to/your/images"}' http://localhost:7779/load-directory
     ```

6. Access images via their generated URLs:
   ```
   http://localhost:7779/images/<image_name>
   ```
   *(Replace `localhost:7779` with your Ngrok URL if using)*

7. Unload directories when no longer needed (optional, uses auto-unload or API):
   ```bash
   curl -X POST http://localhost:7779/unload
   ```

## Performance

The optimized image loader (`load_folder_v2.py`) offers significant performance improvements:

- **Parallel Processing**: Uses ThreadPoolExecutor.
- **Asynchronous I/O**: Uses asyncio and aiohttp.
- **Batch Processing**: Configurable batch sizes.
- **Smart Header Checking**: Verifies availability quickly.
- **Real-time Progress Tracking**: Uses tqdm via `run_with_progress.sh`.

## Configuration

### Environment Variables (`.env`)

- `IMAGE_SERVER_PORT`: Port for the server (default: 7779).
- `IMAGE_SERVER_HOST`: Host to bind (default: 0.0.0.0).
- `IMAGE_SERVER_TIMEOUT`: Auto-unload timeout in minutes (default: 30, 0 = disabled).
- `FRAME_BASE_DIR`: Base directory for resolving relative paths provided to the API.

### Command-Line Arguments (`run_with_progress.sh`)

Loads images and outputs a JSON file with URLs. Primarily for manual loading or testing.

```bash
./run_with_progress.sh <directory_path> [options]
```
Options include `--server`, `--output`, `--unload`, `--timeout`, `--name`, `--workers`, `--batch-size`.

## Scripts

- `persistent_run.sh`: Runs the Flask server persistently using `nohup`.
- `run_with_progress.sh`: Loads images via the API, showing progress.
- `load_folder_v2.py`: The core Python script performing the optimized loading (used by `run_with_progress.sh`).
- `setup_ngrok.sh` & `simple_ngrok_for_n8n.sh`: Scripts for Ngrok integration.
- `unload_directory.sh`: Simple script to call the `/unload` API endpoint.

## API Endpoints

- `POST /load-directory`: Load images from a specified directory.
  - Body: `{"directory": "/path/or/relative/path"}`
- `GET /images/{image_name}`: Serve a specific image from the currently loaded directory.
- `POST /unload`: Unload the current directory.
- `GET /`: Get status and info about the loaded directory.
- `GET /timeout`, `POST /timeout/{minutes}`: Manage auto-unload timer.

## Output (`run_with_progress.sh`)

Generates a JSON file in the `output/json` directory containing image URLs and server details.

## Requirements

- Python 3.7+
- `pip install -r requirements.txt` (Flask, requests, tqdm, aiohttp, aiofiles, python-dotenv)

## License

MIT 
