#!/usr/bin/env python3
"""
Simple test script to verify CODA installation
"""

try:
    import coda
    print(f"✓ CODA successfully imported")
    print(f"✓ CODA version: {coda.version()}")
    print(f"✓ CODA Python bindings are working correctly")
except ImportError as e:
    print(f"✗ Failed to import CODA: {e}")
except Exception as e:
    print(f"✗ Error: {e}")
