# TODO:
# - shell wrapper

%define		snap	19
%include	/usr/lib/rpm/macros.java
Summary:	OpenDocument to XML FOP converter
Name:		odtransform
Version:	0.1.0
Release:	0.%{snap}.1
License:	Apache v2.0
Group:		Development/Languages/Java
Source0:	%{name}-%{version}-r%{snap}.tar.bz2
# Source0-md5:	e040305ffa4ed336711536d6cf092831
Source1:	%{name}.sh
# Source2 url: http://svn.clazzes.org/svn/ooo2xslfo/trunk/ooo2xslfo/src/main/resources/de/systemconcept/ooo/ooo2xslfo.xslt
Source2:	%{name}-ooo2xslfo.xslt
URL:		http://svn.clazzes.org/svn/odtransform/
BuildRequires:	jar
BuildRequires:	java-commons-logging
BuildRequires:	jdk
BuildRequires:	jpackage-utils
BuildRequires:	logging-log4j
BuildRequires:	rpm-javaprov
BuildRequires:	rpmbuild(macros) >= 1.300
BuildRequires:	xalan-j
BuildRequires:	xerces-j
Requires:	java-commons-logging
Requires:	jpackage-utils
Requires:	jre
Requires:	logging-log4j
Requires:	xalan-j
Requires:	xerces-j
Suggests:	fop
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
A simple java tool for converting OpenDocument files to XML FOP files
that can be easily converted to various formats like ps or pdf using
fop.

%prep
%setup -q -n %{name}-%{version}-r%{snap}

%build
required_jars="commons-logging log4j jaxp_parser_impl xalan"
CLASSPATH=$(build-classpath $required_jars)
export CLASSPATH
%javac main/java/org/clazzes/odtransform/*.java
cd main/java
%jar cf ../../odtransform-%{version}.jar org/clazzes/odtransform/*.class
cd ../resources
%jar uf ../../odtransform-%{version}.jar org/clazzes/odtransform/*.xslt
%jar uef org.clazzes.odtransform.OdtTransform ../../odtransform-%{version}.jar

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_javadir},%{_datadir}/odtransform,%{_bindir}}

# jars
cp -a %{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
ln -s %{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}.jar

cp conf/log4j*.properties $RPM_BUILD_ROOT%{_datadir}/odtransform

install %{SOURCE1} $RPM_BUILD_ROOT%{_bindir}/odtransform
install %{SOURCE2} $RPM_BUILD_ROOT%{_datadir}/odtransform/ooo2xslfo.xslt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%{_datadir}/odtransform
%{_javadir}/*.jar
%attr(755,root,root) %{_bindir}/odtransform
