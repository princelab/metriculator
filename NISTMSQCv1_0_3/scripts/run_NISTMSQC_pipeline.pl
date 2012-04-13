#!c:\Perl\bin\perl

use strict;
use Getopt::Long;
use lib '.';
use lib 'C:\code\run_nistmsqc_pipeline';
use MetricsPipeline;
use ParseMetrics;

# NIST Mass Spectrometry Data Center
# Paul A. Rudnick
# paul.rudnick@nist.gov
# 09/09/09

# Pipeline program to generate NIST LC-MS/MS QC metrics from Thermo Raw
# files.

#### Globals
my $version = '1.03beta';
my $version_date = '12-28-2009';

### Read command-line parameters
my @in_dirs = (); 
my @libs = (); 
my (
    $out_dir,
    $out_file,
    $instrument_type,
    $fasta, $overwrite_all,
    $overwrite_searches,
    $no_peptide,
    $pro_ms,
    $mcp_summary,
    $help,
    $log_file,
    $ini_tag
    );
my $search_engine = 'mspepsearch'; # Default
my $sort_by = 'date'; # Default
my $mode = 'lite';

my $pl = new MetricsPipeline($version, $version_date);
my $cl; # Command-line used

if (!@ARGV) {
	$pl->usage();
	$pl->exiting();
} else {
	$cl = join(' ', @ARGV);
}

# Command-line specification
if (!GetOptions ('in_dir=s' => \@in_dirs,
	    'out_dir=s' => \$out_dir,
	    'out_file=s' => \$out_file,
	    'library=s' => \@libs,
	    'instrument_type=s' => \$instrument_type,
	    'fasta:s' => \$fasta,
	    'search_engine:s' => \$search_engine,
	    'overwrite_all!' => \$overwrite_all,
	    'overwrite_searches!' => \$overwrite_searches,
	    'sort_by:s' => \$sort_by,
	    'mode:s' => \$mode,
	    'no_peptide!' => \$no_peptide,
	    'pro_ms!' => \$pro_ms,
	    'mcp_summary!' => \$mcp_summary,
	    'help!' => \$help,
	    'log_file!' => \$log_file,
	    'ini_tag:s' => \$ini_tag,
	    )
    ) {
	$pl->exiting();
	}

if ($help) {
	$pl->usage();
	$pl->exiting();
}

### Pipeline Configuration (advanced/debugging)
my $run_converter = 1; # Programs can be skipped by setting these to 0.
my $run_search_engine = 1;
my $run_nistms_metrics = 1;
my $num_matches = 5; # Number of ID's per spectrum to return by search engines (only top match counted)
my $mspepsearch_threshold = 450; # Score
my $spectrast_threshold = 0.45; # fval
my $omssa_threshold = 0.1; # E-value

# Currently allowable instrument and engines
my @instrument_types = ('LCQ', 'LXQ', 'LTQ', 'FT', 'ORBI'); # Allowable instrument types.
my @search_engines = ('mspepsearch', 'spectrast', 'omssa'); # Available search engines

# General search engine parameters
my $low_accuracy_pmt = 2; # used by set_instrument()
my $high_accuracy_pmt = 0.6; # Large but will catch +2, 13C containing peptides.

# OMSSA configurable parameters
my $omssa_semi = 1; # Run a second OMSSA semitryptic search
my $missed_cleavages = 2;
my $omssa_mods = '1,3,10,110'; # metox, cam, n-term acetylation, pyro-glu

### End configuration
#### End Globals

# Initiate pipeline
$pl->set_global_configuration($cl,
			      $overwrite_all,
			      $overwrite_searches,
			      $run_converter,
			      $run_search_engine,
			      $run_nistms_metrics,
			      \@instrument_types,
			      \@search_engines,
			      $no_peptide,
			      $pro_ms,
			      $mcp_summary,
			      $log_file,
			      $ini_tag,
			      );


$pl->set_base_paths(); # Must be run from scripts directory.

if ( $pl->check_executables() ) {
	$pl->exiting();
}

# Validate in_directories
if ( $pl->check_in_dirs(\@in_dirs) ) {
	$pl->exiting();
}

# Validate out_dir
if ( $pl->check_out_dir($out_dir) ) {
	$pl->exiting();
}
# Validate out_file
if ( $pl->check_out_file($out_file) ) {
	$pl->exiting();
}

# Search engine configuration, including setting hard thresholds
if ( $pl->set_search_engine($search_engine, $num_matches) ) {
	$pl->exiting();
}
if ($pl->search_engine() eq 'mspepsearch') {
	$pl->set_score_threshold($mspepsearch_threshold);
} elsif ($pl->search_engine() eq 'spectrast') {
	$pl->set_score_threshold($spectrast_threshold);
} elsif ($pl->search_engine() eq 'omssa') {
	$pl->set_score_threshold($omssa_threshold);
	$pl->configure_omssa($omssa_semi, $missed_cleavages, $omssa_mods);
} else {
	print STDERR "Search engine not identified.\nExiting.\n";
	$pl->exiting();
}

# Check/validate search libs
if ( (scalar(@libs)>1) && ($pl->search_engine() ne 'mspepsearch') ) {
	print STDERR "Searching multiple databases/libraries only allowed for MSPepSearch.\n";
	$pl->exiting();
}
if ( $pl->is_peptide() ) {
	if ( $pl->check_fastas($fasta, \@libs) ) {
		$pl->exiting();
	}
}
if ( $pl->check_search_libs(\@libs) ) {
	$pl->exiting();
}

# Validate instrument selection
if ( $pl->set_instrument($instrument_type, $high_accuracy_pmt, $low_accuracy_pmt) ) {
	$pl->exiting();
}

# Set data file sort option
if ( $pl->set_sort_option($sort_by) ) {
	$pl->exiting();
}
## Set mode (Currently, default mode ONLY is recommended)
if ( $pl->set_mode($mode) ) {
	$pl->exiting();
}

### Begin processing.
print "NISTMSQC: Pipeline Started $cl\n";

# Conversions with ReAdW4Mascot2.exe
if ( $pl->running_converter() ) {
	print "NISTMSQC: Running converter.\n";
	if ( $pl->run_converter() ) {
		$pl->exiting();
	}
}

# Identify peptide MS/MS spectra with a search engine
if ( $pl->running_search_engine() ) {
	print "NISTMSQC: Running search engine.\n";
	if ( $pl->run_search_engine() ) {
		$pl->exiting();
	}
}
# Run ProMS as MS1 analysis option
if ( $pl->running_pro_ms() ) {
	print "NISTMSQC: Running ProMS.\n";
	if ($pl->run_pro_ms() ) {
		$pl->exiting();
	}
}

# Calculate metrics using output from the above programs
if ( $pl->running_nistms_metrics() ) {
	print "NISTMSQC: Running nistms_metrics.\n";
	if ( $pl->run_nistms_metrics() ) {
		$pl->exiting();
	}
}

print "\n#--> NISTMSQC: Pipeline completed and exiting. <--#\n";

exit(0);
