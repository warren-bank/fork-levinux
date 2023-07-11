#!/bin/sh

# ------------------------------------------------
# remove lines in the OpenVPN config file
# that are unsupported by the installed
# version of OpenVPN, and produce the error:
#
# Unrecognized option or missing parameter(s)
# ------------------------------------------------

input_ovpncfg_fpath="$1"
output_ovpncfg_fpath="$2"

grep_filter_pattern='(verify-x509-name)'

grep -v -i -h -E "$grep_filter_pattern" "$input_ovpncfg_fpath" > "$output_ovpncfg_fpath"
