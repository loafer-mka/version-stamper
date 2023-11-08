#!/bin/bash

ls -1 "$(dirname "$0")/"[0-9][0-9]-* | sort | while read T ; do
	./$T
done
