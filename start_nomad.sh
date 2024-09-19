#!/usr/bin/env bash

tmux new-session -d -s nomadnet-session 'nomadnet'
sleep 10
tmux new-session -d -s nomadmb 'nomadmb'
