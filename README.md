# simple_input_brute.sh
Short bash script that spawns multiple processes (numCPU + 1) to feed a target program words from a specified wordlist.

Lines from the wordlist are split evenly amongst each process, and the program inputs and corresponding outputs are logged to a separate directory for post-session analysis.

# Usage:
`./simple_input_brute.sh <wordlist> <program_which_reads_stdin>`

# Effects:
A results directory containing each process's inputs and outputs is created in the current directory.

The naming format of the results directory is `./sb_results_${program_name}_${wordlist}`

Each individual results file is formatted `sb_res_${process_num}_${startword}_${endword}`

# Limitations:
To "cancel" the current session, you'll need to find and kill the guessing `simple_input_brute.sh` processes yourself -- happy hunting! 😁

One (quick, not always accurate, YMMV) way to do this is via the command `pgrep -a 'xargs' | grep '<target_program>' | awk '{print $1}' | xargs -I{} kill {}`

The script also assumes the presence of certain tools on the system, such as `awk`, `nproc`, `xargs`, and `sed`.  
