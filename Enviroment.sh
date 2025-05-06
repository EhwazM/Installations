#!/bin/bash

read -p "What's going to be the mame for the Venv?: " _VenvName
read -p "What version are you going to use?: " _Version

mkdir -p ~/.virtualenvs
mkdir -p ~/.pyenv

if [ -n "$_Version" ]; then
    pyenv install "$_Version"
    path_to_pyenv = ~/.pyenv/versions/"$_Version"/bin/python3
else
    path_to_pyenv = /usr/bin/python3
fi

virtualenv -p "$path_to_pyenv" ~/.virtualenvs/$_VenvName
source ~/.virtualenvs/$_VenvName/bin/activate
pip install --upgrade pip
pip install numpy matplotlib notebook
python -m notebook

