#!/bin/bash
git clone https://github.com/pycontribs/jenkinsapi.git
cd jenkinsapi
python setup.py install
cd ..
rm -rf jenkinsapi
