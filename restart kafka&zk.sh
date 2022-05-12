#!/bin/bash
echo "<-----Server `hostname` Start----->"
KafkaDir=/cust/cig/utils/kafka_2.11-2.2.0
ZKDir=/cust/cig/utils/zookeeper-3.4.14/bin
echo "Show Kafka Dir: $KafkaDir & ZooKeeper Dir: $ZKDir"
CheckKafka() {
# Get Kafka PID
    echo "<-----Check Kafka Service----->"
    KPID=`ps aux | grep kafka | grep -v grep | awk '{print $2}'`
    if [ -z "$KPID" ]; then
        echo "<-----Kafka Service is Down----->"
        :
	echo "Kafka PID : $KPID"
        return 1
    else
        echo "<-----Kafka Service is On----->"
	echo "Kafka PID : $KPID"
        return 0
    fi
}
resck=$(CheckKafka)
resck2=`echo $?`


ResKafka(){
    CheckKafka
    resck=$(CheckKafka)
    resck2=`echo $?`
}

KillKafka() {
    #kstop=`/cust/cig/utils/kafka_2.11-2.2.0/bin/kafka-server-stop.sh`
    KPID=`ps aux | grep kafka | grep -v grep | awk '{print $2}'`
    kstop=`kill -9 $KPID`
    reskstop=$?
    sleep 15
    KPID=`ps aux | grep kafka | grep -v grep | awk '{print $2}'`
    echo "After kill kafka pid is: $KPID"
    echo "<-----WAIT FOR KILLING KAFKA SERVER------>"
    if [ $reskstop -eq 0 ]; then
            echo "<-----EXEC KILL KAFKA SUCCESS----->"
    else 
            kill -9 $KPID
                if [ $? -eq 0 ]; then
                  echo "<-----EXEC KILL KAFKA SUCCESS IN ELSE----->"
                fi
    fi
}

CheckZooKeeper() {
# Get ZooKeeper PID
    echo "<-----Check ZooKeeper Service----->"
    ZPID=`ps aux | grep zookeeper | grep -v grep | awk '{print $2}'`
    if [ -z "$ZPID" ]; then
        echo "<-----ZooKeeper Service is Down----->"
        :
	echo "Zookpeer PID : $ZPID"
        return 1
    else
      echo "<-----ZooKeeper Service is On----->"
      echo "Zookpeer PID : $ZPID"

      return 0
    fi
    
}
rescz=$(CheckZooKeeper)
rescz2=`echo $?`

ResZooKeeper(){
    CheckZooKeeper
    rescz=$(CheckZooKeeper)
    rescz2=`echo $?`
}

KillZooKeeper() {
# Stop ZooKeeper Server
        zkstop=`$ZKDir/zkServer.sh stop`
        reszkstop=$?
        sleep 10
        ZPID=`ps aux | grep zookeeper | grep -v grep | awk '{print $2}'`
        echo "After kill zookpeer pid is: $ZPID"
        echo "<-----WAIT FOR KILLING ZOOKEEPER SERVER----->"
        if [ $reszkstop -eq 0 ]; then
            echo "<-----STOP ZOOKEEPER SUCCESS----->"
        fi

}

RestartZooKeeper() {
# Restart Zookeeper $ Kafka Server
    echo "<-----Restart Zookeeper Server----->"
    ZPID=`ps aux | grep zookeeper | grep -v grep | awk '{print $2}'`
    if [ -z "$ZPID" ]; then
        echo "ZPID: $ZPID"
        # Start Zookeeper Server
        reszk=`$ZKDir/zkServer.sh start`
        resreszk=$?
        sleep 10
        if [ "$resreszk" -eq 0 ]; then
            echo "<-----EXEC START ZOOKEEPER SUCCESS----->"

        fi
    fi
    ZPID=`ps aux | grep zookeeper | grep -v grep | awk '{print $2}'`
    echo "Zookeeper PID is: $ZPID"
}

RestartKafka() {
# Start Kafka Server
    echo "<-----Restart Kafka Server----->"
    resk=`$KafkaDir/bin/kafka-server-start.sh -daemon $KafkaDir/config/server.properties`
    resresk=$?
    sleep 10
    if [ $resresk -eq 0 ]; then
        echo "<-----EXEC START KAFKA SUCCESS----->"
    fi
    
    KPID=`ps aux | grep kafka | grep -v grep | awk '{print $2}'`
    echo "Kafka PID is: $KPID"
      
}

CheckKafka
KillKafka
CheckZooKeeper
KillZooKeeper


countzk=1
while ((countzk = 1))
do
    ResZooKeeper
    echo "Check zookeeper Result is: $rescz2"
    echo "Service Down = 1; Service ON = 0"
    echo "Zookeeper init value is: $countzk"
    echo "Default while value = 1"
    if [ $rescz2 -ne 0 ]; then
        RestartZooKeeper
        echo "<-----Restart Zookeeper Server Again----->"
    
    else
        countzk=0
        rescz2=0
        break
    fi
    ZPID=`ps aux | grep zookeeper | grep -v grep | awk '{print $2}'`
    if [ -n "$ZPID" ]; then
        countzk=0
        echo "Zookeeper value in if is: $countzk"
    fi
    #countzk=0
    echo "Zookeeper after if value is: $countzk"
done


countkafka=1
while ((countkafka = 1))
do
    ResKafka
    echo "Check Kafka Result is: $resck2"
    echo "Service Down = 1; Service ON = 0"
    echo "Kafka init value is: $countkafka"
    echo "Default while value = 1"
    if [ $resck2 -ne 0 ]; then
        RestartKafka
        echo "<-----Restart Kafka Server Again----->"
    
    else
        countzk=0
        resck2=0
        break
    fi
    KPID=`ps aux | grep kafka | grep -v grep | awk '{print $2}'`
    if [ -n "$KPID" ]; then
        countkafka=0
        echo "Kafka value is: $countkafka"
        echo "Default while value = 1"
    fi
    #countzk=0
    echo "Kafka after if value is: $countkafka"
    echo "Default while value = 1"
done

CheckZooKeeper
echo "<-----ZooKeeper Restart Completed----->"
CheckKafka
echo "<-----Kafka Restart Completed----->"
echo "<-----Server `hostname` End----->"
