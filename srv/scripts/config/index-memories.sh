#!/bin/bash

for i in {1..4};
do
    (./scripts/config/occ.sh memories:index &);
done
