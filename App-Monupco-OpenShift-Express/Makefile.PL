use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'App::Monupco::OpenShift::Express',
    VERSION_FROM      => 'lib/App/Monupco/OpenShift/Express.pm', # finds $VERSION
    PREREQ_PM         => {JSON, LWP::UserAgent}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/App/Monupco/OpenShift/Express.pm', # retrieve abstract from module
       AUTHOR         => 'Alexander Todorov <atodorov@otb.bg>') : ()),
);
