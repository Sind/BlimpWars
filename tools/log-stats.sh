#!/bin/bash
PROCESS_ID=$(pgrep love)

echo "Attached to PID $PID."

ps v -$PROCESS_ID > stats.log
while true
do
    sleep 1s
    ps vh -$PROCESS_ID >> stats.log
done
