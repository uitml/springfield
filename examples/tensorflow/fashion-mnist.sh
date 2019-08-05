#!/bin/sh

# Install additional dependencies.
# TODO: Solve by using a custom Docker image.
curl https://bootstrap.pypa.io/get-pip.py | python3
pip3 install --no-cache h5py matplotlib pyyaml

# Run the first experiment...
python3 fashion-mnist.py
