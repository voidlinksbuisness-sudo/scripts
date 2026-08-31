#!/usr/bin/env python3
"""Build deterministic center-cropped JPEG variants for the INS background."""

from __future__ import annotations

import argparse
from io import BytesIO
from pathlib import Path

from PIL import Image


RATIOS = (0.8, 1.0, 1.2, 4 / 3, 1.5, 1.6, 16 / 9, 2.0, 7 / 3, 8 / 3, 3.0)
MAGIC = b"FFTMBG1\n"


def center_crop(image: Image.Image, ratio: float) -> Image.Image:
    width, height = image.size
    current = width / height

    if current > ratio:
        crop_width = round(height * ratio)
        left = (width - crop_width) // 2
        box = (left, 0, left + crop_width, height)
    else:
        crop_height = round(width / ratio)
        top = (height - crop_height) // 2
        box = (0, top, width, top + crop_height)

    return image.crop(box)


def encode_jpeg(image: Image.Image) -> bytes:
    max_edge = 1100
    if max(image.size) > max_edge:
        scale = max_edge / max(image.size)
        image = image.resize(
            (round(image.width * scale), round(image.height * scale)),
            Image.Resampling.LANCZOS,
        )

    output = BytesIO()
    image.convert("RGB").save(
        output,
        format="JPEG",
        quality=72,
        optimize=True,
        progressive=True,
        subsampling="4:2:0",
    )
    return output.getvalue()


def build(source: Path, destination: Path) -> None:
    image = Image.open(source)
    chunks = [MAGIC]

    for ratio in RATIOS:
        data = encode_jpeg(center_crop(image, ratio))
        chunks.append(f"{ratio:.6f}|{len(data)}\n".encode("ascii"))
        chunks.append(data)

    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(b"".join(chunks))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    build(args.source, args.destination)


if __name__ == "__main__":
    main()
