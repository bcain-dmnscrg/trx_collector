# trx_collector
Takes the output of ngrep and organizes tcp traffic by connection. A connection is defined by a unique source IP and port.

An example of gathering the ngrep output against a defined "eth port" and zipping the contents

ngrep -P ' ' -t -l -W single -d "eth port" -S 2000 -v '@@version_comment' 'tcp and dst port 3306' | pigz > ngrep.log.gz

Alternatively the ngrep output can be piped over nc to another server for zipping and later analysis.

trx_collector takes 3 arguments, the name of the gzipped ngrep data file along with a start and end datetime for narrowing results. The start and end datetime format can be anything the 'date' command takes as valid for converting to an epoch time.

trx_collector.sh ngrep.log.gz "2015-05-22 10:00:00" "2015-05-22 10:00:05" > connections.log

