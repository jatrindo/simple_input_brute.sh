#!/bin/bash

function err_exit() {
	local message="$1"
	echo "Error: ${message}"
	exit 1
}

if [ $# -ne 2 ]; then
	echo "$(basename $0) <wordlist> <program_which_reads_stdin>"
	exit 1
fi

wordlist="$1"
program="$2"

# File checks
if [[ ! -f "${wordlist}" ]]; then
	err_exit "Wordlist should be a regular file"
fi
if [[ ! -x "${program}"  ]]; then
	err_exit "Program should be executable"
fi

nproc="$(($(nproc) + 1))"
resdir="./sb_results_$(basename ${program})_$(basename ${wordlist})"

# Calculate size of each range
num_lines="$(wc -l ${wordlist} | awk '{print $1}')"
range_size=$((num_lines / nproc))

# Handle edge case of more CPUs than lines
if [ ${range_size} -le 0 ]; then
	range_size=1
fi

# Create result directory
mkdir -p ${resdir}

# Divvy up ranges
for (( i=0; i < ${nproc}; i++)); do
	lower=$(((range_size * i) + 1))
	upper=$((range_size * (i+1)))

	lowerword="$(sed -n ${lower}p ${wordlist})"
	upperword="$(sed -n ${upper}p ${wordlist})"

	outfile="${resdir}/sb_res_${i}_from_${lowerword}_to_${upperword}"

	echo "Range size: ${range_size}"
	echo "Range ${i}: [${lowerword}, ${upperword}]"


	# Checks for empty lines/other weirdness
	if [[ -z "${lowerword}" ]] || [[ -z "${upperword}" ]]; then
		err_exit "No more guesses? Stopping..."
	fi

	(sed -n "${lower},${upper}p" ${wordlist} | xargs -I{} -n1  sh -c "echo -n {}: ; echo -n {} | $program" >> "${outfile} 2>&1") &
done
