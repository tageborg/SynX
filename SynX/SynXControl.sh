#!/bin/sh

#  SynXControl.sh
#  
#  Control and query the SynXAgent application
#
#  Usage: SynXControl.sh start|stop|status [server|client]
#
#  The status command will return 0 when no agent is running, 1 when running as
#  client and 2 when running as server.
#
#
#  Created by Tage Borg on 20110502.
#  Copyright 2011 Tage Borg. All rights reserved.

SYNX_AGENT_PATH=`dirname $0`;

case $1 in
  start)
    if [ ! -x $SYNX_AGENT_PATH/SynXAgent -o ! -f $SYNX_AGENT_PATH/SynXAgent ] ; then
      echo "$SYNX_AGENT_PATH/SynXAgent does not exist or is not executable!"
      exit;
    fi
    $SYNX_AGENT_PATH/SynXAgent $2 &
    exit;
  ;;
  stop)
    /bin/kill `/bin/ps -ef|/usr/bin/grep SynXAgent|/usr/bin/grep -v grep|/usr/bin/awk '{print $2}'`
    exit;
  ;;
  status)
    RESULT=0;
    if  [ `/bin/ps -ef|/usr/bin/grep SynXAgent|/usr/bin/grep client|/usr/bin/grep -v grep|/usr/bin/awk '{print $2}'|/usr/bin/wc -l` -eq 1 ] ; then
      exit 1;
    fi
    if  [ `/bin/ps -ef|/usr/bin/grep SynXAgent|/usr/bin/grep server|/usr/bin/grep -v grep|/usr/bin/awk '{print $2}'|/usr/bin/wc -l` -eq 1 ] ; then
      exit 2;
    fi
    exit $RESULT
  ;;
  *)
    echo "Usage: $0 command [mode]";
    echo " ";
    echo "where";
    echo " ";
    echo "   command:  start  | stop";
    echo "   mode:     server | client";
    echo " ";
    echo "Defaults to client mode if none is given.";
    echo " ";
  ;;
esac

