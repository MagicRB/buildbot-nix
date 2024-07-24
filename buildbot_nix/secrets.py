import os
import sys
from pathlib import Path


def read_secret_file(secret_file: Path) -> str:
    directory = os.environ.get("CREDENTIALS_DIRECTORY")
    if directory is None:
        print("directory not set", file=sys.stderr)
        sys.exit(1)
    return Path(directory).joinpath(secret_file).read_text().rstrip()
