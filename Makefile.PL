use ExtUtils::MakeMaker;

WriteMakefile (
    PREREQ_PM	=> { "Tk"		=> "402.000"	},
    NAME	=> "Tk::Clock",
    DISTNAME	=> "Tk-Clock",
    VERSION_FROM=> "Clock.pm",
    "dist"	=> { COMPRESS		=> "gzip -9f",
		     SUFFIX		=> ".gz"	}
    );


