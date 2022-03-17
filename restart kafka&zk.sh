#!/bin/bash
# Get Kafka PID
KPID=`ps aux | grep kafka | grep -v grep | awk '{print $2}'`
# Kill Kafka 
if [ "$KPID" -ne "" ]; then
   echo "-----GET KAFKA PID SUCCESS-----"
   kstop=`/cust/cig/utils/kafka_2.11-2.2.0/bin/kafka-server-stop.sh`
   echo "-----WAIT FOR KILLING KAFKA SERVER------"
   sleep 30s
   if [ "$kstop" -eq 0 && "$KPID" -eq ""]; then
        echo "-----KILL KAFKA SUCCESS-----"
   else 
        Kill -9 $KPID
        if [ $? -eq 0 &&  "$KPID" -eq ""]; then
        echo "-----KILL KAFKA SUCCESS-----"
        fi
   fi
fi

# Stop ZooKeeper Server
ZPID=`ps aux | grep zookeeper | grep -v grep | awk '{print $2}'`
if [ "$ZPID" -ne "" ]; then
    zkstop=`/cust/cig/utils/zookeeper-3.4.14/bin/zkServer.sh stop`
    echo "-----WAIT FOR KILLING ZOOKEEPER SERVER-----"
    sleep 10s
    if [ "$zkstop" -eq 0 && "$ZPID" -ne "" ]; then
        echo "-----STOP ZOOKEEPER SUCCESS-----"
    fi

fi

# Restart Zookeeper $ Kafka Server
if [ "$ZPID" -eq "" ]; then
    # Start Zookeeper Server
    reszk=`/cust/cig/utils/zookeeper-3.4.14/bin/zkServer.sh start`
    sleep 5
    if [ "$reszk" -eq 0 && "$ZPID" -ne "" ]; then
        echo "-----START ZOOKEEPER SUCCESS-----"

        # Start Kafka Server
        resk=`/cust/cig/utils/kafka_2.11-2.2.0/bin/kafka-server-start.sh -daemon /cust/cig/utils/kafka_2.11-2.2.0/config/server.properties`
        sleep 5
        if [ "$resk" -eq 0 && "$KPID" -ne "" ]; then
            echo "-----START KAFKA SUCCESS-----"
        fi
    fi
fi
