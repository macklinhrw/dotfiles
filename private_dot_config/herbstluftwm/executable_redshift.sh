#!/bin/bash

pgrep redshift >/dev/null && killall redshift || redshift
