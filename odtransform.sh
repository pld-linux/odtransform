#!/bin/sh
#
# $Id$
#
# This script is based on a script provided by odtransform authors available
# from subversion repository:
# http://svn.clazzes.org/svn/odtransform/trunk/odtransform/src/main/assembly/odtransform.sh

if test "$JAVA_HOME" = ""; then
  JAVA_CMD=java
else
  JAVA_CMD=$JAVA_HOME/bin/java
fi

LOG4JPROPS=/usr/share/odtransform/log4j.properties

DEBUG=0

usage() {
	cat << EOF
odtversion rev 19
Usage: $0 [stylesheet] [OpenDocument]
EOF
}

while [ $# -ge 1 ]; do
    case "$1" in
    --debug)
		LOG4JPROPS=/usr/share/odtransform/log4j_debug.properties
        shift
        ;;
    --debug-startup)
		DEBUG=1
        shift
        ;;
    --quiet)
		LOG4JPROPS=/usr/share/odtransform/log4j_quiet.properties
        shift
        ;;
    --verbose)
		LOG4JPROPS=/usr/share/odtransform/log4j_verbose.properties
        shift
        ;;
    --help)
    	usage()
		exit
		;;
    *)
        break
        ;;
    esac
done

CLASSPATH=$(build-classpath commons-logging log4j jaxp_parser_impl xalan odtransform)

if [ $DEBUG != 0 ]; then
    echo '*****************************************************'
    echo $JAVA_CMD -Dlog4j.configuration=file:$LOG4JPROPS -cp $CLASSPATH org.clazzes.odtransform.OdtTransform ${1:+"$@"}
    echo '*****************************************************'
fi

$JAVA_CMD -Dlog4j.configuration=file:$LOG4JPROPS -cp $CLASSPATH org.clazzes.odtransform.OdtTransform ${1:+"$@"}
