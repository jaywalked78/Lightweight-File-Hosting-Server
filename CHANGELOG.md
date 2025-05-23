# Changelog

All notable changes to the TinyImageHoster project will be documented in this file.

## [2.2.0] - 2024-06-06

### Added
- Simplified ngrok integration script for reliable tunneling
- Enhanced webhook routing between test and production endpoints
- Permanent subdomain support for consistent public URLs
- Central Standard Time (CST) timestamps in output filenames
- Improved n8n integration with executionMode parameter support

### Changed
- Streamlined processor-background.sh script for better error handling
- Simplified ngrok script to focus on core tunneling functionality
- Enhanced environment variable management for public URLs
- Improved tunnel detection and verification
- Better handling of image server startup and teardown

### Fixed
- Address reliability issues with webhook routing
- Simplified tunnel establishment process
- Reduced script complexity for better maintainability
- Fixed output file naming consistency with timestamps

## [2.1.0] - 2024-03-01

### Added
- ngrok integration for stable public URL generation
- Robust monitoring and auto-recovery for ngrok tunnels
- Health checking to ensure tunnel stability
- Resource usage monitoring to prevent memory leaks
- Log rotation for long-running services
- Detailed diagnostic information for troubleshooting
- Web interface access for tunnel management

### Changed
- Replaced localtunnel with ngrok for more reliable public access
- Enhanced public URL stability with automatic recovery
- Improved error handling and diagnostic capabilities
- Updated integration scripts for better n8n compatibility
- Enhanced resource management for long-running tunnels

### Fixed
- Stability issues with public URL generation
- Connection drops during extended operation
- Memory usage growth over time
- Multiple instances conflict resolution

## [2.0.0] - 2025-04-24

### Added
- Parallel image processing using ThreadPoolExecutor
- Asynchronous I/O with aiohttp and asyncio
- Batch processing for optimized performance
- Real-time progress tracking with tqdm progress bars
- Smart environment variable handling via .env file
- Support for relative path resolution via FRAME_BASE_DIR
- Enhanced verbose debugging with detailed progress information
- Support for custom worker count and batch size configuration
- Command-line arguments for fine-tuning performance
- Detailed performance metrics during loading process
- Proper error handling when directories don't exist
- Improved virtual environment detection and activation
- Significant code cleanup and refactoring (moved old scripts)

### Changed
- Completely rewrote image loading logic for parallel processing
- Restructured directory handling for better path resolution
- Improved error handling with better error messages
- Enhanced JSON output with more detailed information
- Server startup procedure to ensure proper environment variables
- Optimized HTTP requests to only verify headers instead of downloading entire images

### Fixed
- Issue with server startup in virtual environments
- Path resolution problems with relative directories
- Proper error handling when directories don't exist
- Improved virtual environment detection and activation

### Performance
- Reduced loading time from ~10 minutes to under 2 seconds for typical directories
- Reduced CPU usage by optimizing HTTP requests
- Improved memory usage and stability for large directories

## [1.0.0] - 2023-10-01

### Initial Release
- Basic image server functionality
- Sequential image loading
- RESTful API for directory management
- Auto-unload timeout feature
- Simple command-line interface
- Support for loading directories and generating URLs 