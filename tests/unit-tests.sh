#!/bin/bash

ls -1 [0-9][0-9]-* | sort | while read T ; do
	./$T
done
