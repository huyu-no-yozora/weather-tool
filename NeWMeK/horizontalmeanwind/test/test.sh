#!/bin/bash

line="1 2 3 5 7 9 10"
awk '{print 123,567,$3.$4,$5,$6,$7}' $(dirname $0)/line.txt

