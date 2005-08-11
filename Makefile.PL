use ExtUtils::MakeMaker;

WriteMakefile (
    NAME	  =>   "Tk::Clock",
    DISTNAME	  =>   "Tk-Clock",
    VERSION_FROM  =>   "Clock.pm",
    ABSTRACT_FROM =>   "Clock.pm",
    AUTHOR        =>   "H.Merijn Brand <h.m.brand\@xs4all.nl>",

    PREREQ_PM	  => { "Tk"	=> "402.000",
		       },

    dist	  => { COMPRESS	=> "gzip -9f",
		       SUFFIX	=> ".gz",
		       }
    );

1;
