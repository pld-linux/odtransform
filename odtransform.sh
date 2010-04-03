#!/bin/sh
#
# $Id$
#
# This script is based on a script provided by odtransform authors available
# from subversion repository:
# http://svn.clazzes.org/svn/odtransform/trunk/odtransform/src/main/assembly/odtransform.sh

if [ -x /usr/bin/gij ]; then
  JAVA_CMD=gij
else
  if [ "$JAVA_HOME" = "" ]; then
    JAVA_CMD=java
  else
    JAVA_CMD=$JAVA_HOME/bin/java
  fi
fi

LOG4JPROPS=/usr/share/odtransform/log4j.properties

DEBUG=0

usage() {
	cat << EOF
odtversion rev 19
Usage: $0 [stylesheet] [OpenDocument]    - apply stylesheet to OpenDocument
       $0 [OpenDocument]                 - convert OpenDocument to XML-FOP
Example:
       Convert OpenDocument to PDF file:
       $0 document.odt | fop /dev/sdtin file.pdf
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
    	usage
	exit 0
	;;
    *)
        break
        ;;
    esac
done

if [ "$#" == 2 ]; then
  STYLESHEET=$1
  shift 1
else
  STYLESHEET=/usr/share/odtransform/ooo2xslfo.xslt
fi

if [ "$#" -ne "1" ]; then
  usage
  exit 1
fi

CLASSPATH=$(build-classpath commons-logging xalan odtransform)

if ! [ -r $STYLESHEET ]; then
  echo "Could not open $STYLESHEET file" >&2
  exit 1
fi

if ! [ -r "$1" ]; then
  echo "Could not open $1 file" >&2
  exit 1
fi

if [ $DEBUG != 0 ]; then
    echo '*****************************************************'
    echo $JAVA_CMD -Dlog4j.configuration=file:$LOG4JPROPS -cp $CLASSPATH org.clazzes.odtransform.OdtTransform $STYLESHEET ${1:+"$@"}
    echo '*****************************************************'
fi

exec $JAVA_CMD -Dlog4j.configuration=file:$LOG4JPROPS -cp $CLASSPATH org.clazzes.odtransform.OdtTransform $STYLESHEET ${1:+"$@"}
