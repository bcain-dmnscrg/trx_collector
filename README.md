# trx_collector
Takes the output of ngrep and organizes tcp traffic by connection. A connection is defined by a unique source IP and port.

An example of gathering the ngrep output against a defined "eth port" and zipping the contents

ngrep -P ' ' -t -l -W single -d "eth port" -S 2000 -v '@@version_comment' 'tcp and dst port 3306' | pigz > ngrep.log.gz

Alternatively the ngrep output can be piped over nc to another server for zipping and later analysis.

trx_collector takes 3 arguments, the name of the gzipped ngrep data file along with a start and end datetime for narrowing results. The start and end datetime format can be anything the 'date' command takes as valid for converting to an epoch time.

./trx_collector.sh ngrep.log.gz "2015-05-22 10:00:00" "2015-05-22 10:00:05" > connections.log

With the connections.log you can then use sessions.sh to get a listing by connection of the time of its first and last recorded statement.

./sessions.sh connections.log > sessions.log

And further break down the results of sessions.log into an accounting of how many connections occured from each host per second

for ts in \`cat sessions.log | cut -f 3 -d ' ' | sort | uniq\`; do echo "$ts"; cat sessions.log | cut -f 1-3 -d ' ' | grep "$ts" | sort | uniq -c | sort -nr | cut -f 1 -d '.'; done > sessions_per_second.log
