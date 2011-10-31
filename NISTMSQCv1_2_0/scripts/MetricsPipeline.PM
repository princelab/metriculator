{
    
package MetricsPipeline;
use ParseMetrics;
use strict;
use Cwd;

sub new {
    my ($class,
        $version,
        $version_date,
        ) = @_;
    my $self = {};
    $self->{_usage} = "\nUSAGE: run_NISTMSQC_pipeline.pl --in_dir <full path> (--in_dir <full path2..N>) --out_dir <full path> --library <library name> (--library <library 2..N>) --instrument_type <inst. type>\n\n[opts. --search_engine <search engine> --fasta <path to file> --sort_by <'date' or 'name'> --overwrite_all --overwrite_searches --mode <full,lite> --pro_ms --log_file --ini_tag --target_file <targets.ini> --verbose --help]

Command-line Arguments (Required):

--in_dir (req'd.) Full path to raw data files.  Multiple are allowed and will be compared as series.
--out_dir (req'd.) Full path to directory to write pipeline output files.
--library (req'd.) Basename of library.  Multiple are allowed for MSPepSearch ONLY.
--instrument_type (req'd.) LCQ, LTQ, LXQ, ORBI, FT, Agilent_QTOF and Orbi_HCD are currently allowable values.

Options (NOT required):

--search_engine (default=MSPepSearch) Name of search engine.  Other allowable values are SpectraST and OMSSA.
--fasta (default=<basename of library [.fasta]) Full path to a fasta file.  Only used for protein metrics in 'full' mode.
--sort_by (default=data) Controls the ordering of columns in the output file.  'name' or 'date' are allowed.
--overwrite_all Will force all programs to re-run overwriting any data files.  Useful if pipeline binaries have been updated.
--overwrite_searches Will force search engine to overwrite existing search results.  Useful if changing databases.
--no_peptide Use if libraries are not peptide.
--mcp_summary Generate an additional output file (.CSV) with ONLY metrics referenced in the publication (Rudnick et al, MCP, 2010).
--mode (default=full) Controls content of output file.  'Full' will include protein level summaries. 'lite' and 'full' are allowed.
--log_file If specified, output from program will be directed to a LOG file appearing in the same directory as the out file.
--ini_tag <tag> If a tag name is given, this section from ms.ini will be used and a new one will NOT be generated.  This is helpful if re-ordering of runs (manual editing of ms.ini) is required for presentation or grouping of multiple series.  NOTE: No validation of the structure of the ms.ini file is done; exercise caution when editing the ms.ini file.
--target_file <name of target file> This ini file can be used for analysis of a set of peptides.  See targets.ini for file structure.
--verbose If specified, additional output will be written to the screen and log file.
--help Prints arguments and options then exits.

VERSION $version
$version_date\n\n";
    $self->{_version} = $version;
    $self->{_version_date} = $version_date;
    bless($self, $class);
    return $self;
}
sub usage {
    my $self = shift;
    print STDERR $self->{_usage};
}
sub exiting {
    my $self = shift;
    foreach (@{$self->{_fhs}}) {
	print $_ "NISTMSQC: Exiting with errors.\n";
    }
    exit(0);
}
sub set_global_configuration {
    my ($self,
        $cl,
        $overwrite_all,
        $overwrite_searches,
        $run_converter,
        $run_search_engine,
        $run_nistms_metrics,
        $instrument_types,
        $search_engines,
        $no_peptide,
        $pro_ms,
        $mcp_summary,
        $log_file,
        $ini_tag,
        $target_file,
        $verbose,
        ) = @_;
    $self->{_cl} = $cl;
    $self->{_overwrite_all} = $overwrite_all;
    $self->{_overwrite_searches} = $overwrite_searches;
    $self->{_run_converter} = $run_converter;
    $self->{_run_search_engine} = $run_search_engine;
    $self->{_run_nistms_metrics} = $run_nistms_metrics;
    $self->{_available_instrument_types} = $instrument_types;
    $self->{_available_search_engines} = $search_engines;
    $self->{_no_peptide} = $no_peptide;
    $self->{_pro_ms} = $pro_ms;
    $self->{_mcp_summary} = $mcp_summary;
    $self->{_log_file} = $log_file;
    $self->{_ini_tag} = $ini_tag;
    $self->{_target_file} = $target_file;
    $self->{_verbose} = $verbose;
    if ($self->{_verbose}) {
        push(@{$self->{_fhs}}, *STDOUT);
    }
}
sub check_proms {
    my $self = shift;
    if (!$self->{_pro_ms} ) {
	if ($self->{_instrument_type} eq 'LTQ' || $self->{_instrument_type} eq 'ORBI') {
	    print STDERR "ProMS is now reccomended for all vendor types. Suggest adding --pro_ms to command-line.\n";
	    return 0;
	} else {
	    print STDERR "ProMS must be used with $self->{_instrument_type} data files.  Add --pro_ms to the command-line.\n";
	    return 1;
	}
    }
}
sub set_base_paths {
    my $self = shift;
    ### Base paths
    my $root = &Cwd::abs_path('..'); # To use full paths. (09/09/08) PAR
    $root =~ s/\//\\/g; # Windows slashes.
    $self->{_lib_path} = "$root\\libs";
    $self->{_scripts_path} = "$root\\scripts";
    $self->{_bin_path} = "$root\\bin";
    $self->{_ms_ini} = "$root\\scripts\\ms.ini";
}

sub set_instrument {
    my ($self, $instrument_type, $high_accuracy_pmt, $low_accuracy_pmt) = @_;
    if (! grep(/^$instrument_type$/i, @{$self->{_available_instrument_types}}) ) {
        print STDERR "\nInstrument type must be one of the following: ";
        print join(", ", @{$self->{_available_instrument_types}})."\n";
        return 1;
    } else {
        $instrument_type =~ tr/[a-z]/[A-Z]/;
    }
    if ($instrument_type eq 'LCQ' || $instrument_type eq 'LTQ' || $instrument_type eq 'LXQ') { # Adjust precursor mass tolerance based on instrument selection
        $self->{_pmt} = $low_accuracy_pmt;
        $self->{_fmt} = 0.8;
    } else {
        $self->{_pmt} = $high_accuracy_pmt; # Large so that majority of 13C-containing peptides are not missed
        $self->{_fmt} = 0.8;
    }
    $self->{_instrument_type} = $instrument_type;
    if ( $self->_is_thermo() ) {
	$self->{_base_ext} = 'RAW';
    } elsif ($self->_is_agilent()) {
	$self->{_base_ext} = 'd';
    } else {
	print STDERR "Could not define base extension for instrumen type: $instrument_type.\n";
	return 1;
    }
    return 0;
}
sub _is_thermo {
    my $self = shift;
    my @thermo = (
	'LCQ',
	'LTQ',
	'LXQ',
	'ORBI',
	'ORBI_CID',
	'ORBI_HCD',
	'ORBI_ETD'
    );
    if (grep { /^$self->{_instrument_type}$/ } @thermo ) {
	return 1;
    } else {
	return 0;
    }
}
sub _is_agilent {
    my $self = shift;
    my @agilent = (
	'AGILENT_QTOF'
    );
    if (grep { /^$self->{_instrument_type}$/ } @agilent ) {
	return 1;
    } else {
	return 0;
    }
}
sub check_executables {
    my $self = shift;
    ### Check for required executables.
    my @exes = ('ReAdW4Mascot2.exe', 'MSPepSearch.exe', 'spectrast.exe', 'omssacl.exe', 'nistms_metrics.exe', 'merge_pep_results.exe', 'ProMS.exe');
    foreach (@exes) {
        my $exe = "$self->{_bin_path}\\$_";
        if (! -e $exe) {
            print STDERR "Required program: $exe not found.\n";
            return 1;
        } else {
            $self->{$_} = "\"$self->{_bin_path}\\$_\"";
        }        
    }
    # check trapper for Agilent_QTOF instrument
    my @A_QTOF_exes = ('mzData2MGF.exe', 'trapper.exe', 'zlib1.dll');
    if ($self->{_instrument_type} eq "AGILENT_QTOF") {
        foreach (@A_QTOF_exes) {
            my $exe = "$self->{_bin_path}\\trapper\\$_";
            if (! -e $exe) {
                print STDERR "Required program: $exe not found.\n";
                return 1;
            } else {
                $self->{$_} = "\"$self->{_bin_path}\\trapper\\$_\"";
            }        
        }
    }
    
    # For HCD
    my @HCD_exes = ('msconvert.exe');
    if ($self->{_instrument_type} eq "ORBI_HCD" || ($self->{_instrument_type} eq "ORBI_CID" || $self->{_instrument_type} eq "ORBI_ETD")) {
        foreach (@HCD_exes) {
            my $exe = "$self->{_bin_path}\\2562\\$_";
            if (! -e $exe) {
                print STDERR "Required program: $exe not found.\n";
                return 1;
            } else {
                $self->{$_} = "\"$self->{_bin_path}\\2562\\$_\"";
            }        
        }
    }
    
    return 0;
}
sub check_in_dirs {
    my ($self, $in_dirs) = @_;
    foreach ( @{$in_dirs} ) {
        my $in_dir = $_;
        if (! -d $in_dir ) {
            print STDERR "In Directory: $in_dir does not exist.\n";
            return 1;
        } else {
            push( @{$self->{_in_dirs}}, $in_dir );
        }
    }
    return 0;
}
sub check_out_dir {
    my ($self, $out_dir) = @_;
    #$out_dir = "\"$out_dir\"";
    if ( ! -d $out_dir ) {
        if (!mkdir($out_dir)) {
            print STDERR "NISTMSQC: Out dir: \'$out_dir\' does not exist and could not be created.\n";
            return 1;
        } else {
            foreach (@{$self->{_fhs}}) {
                print $_ "NISTMSQC: Out dir: \'$out_dir\' successfully created.\n";
            }
        }
    }
    $self->{_out_dir} = $out_dir;
    
    return 0;
}

sub check_report_location {
    my ($self) = @_;
    my @parts = split(/\\/,$self->{_out_dir});
    my $report_name = $parts[$#parts];
    if ( -e "$self->{_out_dir}\\$report_name"."_report.msqc" ) {
        print STDERR "NISTMSQC: \"$report_name"."_report.msqc\" already exists.\n";
        for (my $i=1; $i<100; $i++) {
            my $version = "$report_name"."_report__$i.msqc";
            if (! -e "$self->{_out_dir}\\$version") {
                $self->{_out_file} = "$self->{_out_dir}\\$version";
                last;
            }
        }
        print STDERR "NISTMSQC: \"$self->{_out_file}\" will be used instead.\n";
    } else {
        $self->{_out_file} = "$self->{_out_dir}\\$report_name"."_report.msqc";
    }
    open(OUT, ">$self->{_out_file}") || die "$!\nOut file: $self->{_out_file} could not be created. Exiting.\n";
    close OUT;
    if ($self->{_log_file}) {
        $self->{_log_file_name} = "$self->{_out_file}.LOG";
        open(LOG, ">$self->{_log_file_name}") || die "Could not open log file: $self->{_log_file_name}\n";
        push(@{$self->{_fhs}}, *LOG);
        # Initiate log file. 12/24/09
        my $datestamp = $self->_get_datestamp();
        foreach (@{$self->{_fhs}}) {
            print $_ "NISTMSQC: Log file created for this run: \"$self->{_log_file_name}\"\n";
            print $_ "NISTMSQC: Run started: $datestamp\n";
            print $_ "NISTMSQC: Command-line: $self->{_cl}\n";
        }
    } else {
        print STDOUT "Note: No log file will be created for this run.\n";
    }
    return 0;
}
sub check_target_file {
    my $self = shift;
    if (!$self->{_target_file}) {
        return 0;
    }
    if (-e $self->{_target_file}) {
    } elsif (-e "$self->{_scripts_path}\\$self->{_target_file}") {
        $self->{_target_file} = "$self->{_scripts_path}\\$self->{_target_file}";
    } else {
        foreach (@{$self->{_fhs}}) {
            print $_ "NISTMSQC: Target file, \"$self->{_target_file}\" or \"$self->{_scripts_path}\\$self->{_target_file}\" could not be found.\n";
        }
        return 1;
    }
    foreach (@{$self->{_fhs}}) {
        print $_ "NISTMSQC: Target file, \"$self->{_target_file}\" will be used.\n";
    }
    return 0;
}
sub _get_datestamp {
    my $self = shift;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $date_stamp = sprintf "%4d-%02d-%02d_%02d:%02d", $year+1900,$mon+1,$mday,$hour,$min;
    return $date_stamp;
}
sub running_converter {
    my $self = shift;
    return $self->{_run_converter};
}
sub running_search_engine {
    my $self = shift;
    return $self->{_run_search_engine};
}
sub running_pro_ms {
    my $self = shift;
    return $self->{_pro_ms};
}
sub running_nistms_metrics {
    my $self = shift;
    return $self->{_run_nistms_metrics};
}
sub is_peptide {
    my $self = shift;
    if (!$self->{_no_peptide}) {
        return 1;
    } else {
        return 0;
    }
}
sub set_search_engine {
    my ($self, $search_engine, $num_matches) = @_;
    # Validate search engine
    if (! grep(/^$search_engine$/i, @{$self->{_available_search_engines}}) ) {
        print  STDERR "\nSearch engine (opt. search_engine) must be one of the following: ";
        print  STDERR join(", ", @{$self->{_available_search_engines}})."\n";
        return 1;
    } else {
        $search_engine =~ tr/[A-Z]/[a-z]/;
    }
    $self->{_search_engine} = $search_engine;
    $self->{_num_matches} = $num_matches;
    return 0;
}
sub search_engine {
    my ($self) = @_;
    return $self->{_search_engine};
}
sub set_score_threshold {
    my ($self, $threshold) = @_;
    $self->{_threshold} = $threshold;
}
sub check_fastas {
    my ($self, $fasta, $libs) = @_;
    if (!$fasta) {
        $fasta = "$self->{_lib_path}\\$libs->[0].fasta";
        if ( scalar(@{$libs}) > 1 ) {
            if ($self->{_mode} eq '-pp') { # FULL mode only
                print STDERR "Proteins will only be mapped to $fasta.\n";
                print STDERR "When using >1 library, you must create a combined fasta and specifiy it using (opt. --fasta)\n";
            }
        }
    }
    if (-e $fasta) {
        $self->{_seq_lib} = $fasta;
        return 0;
    } else {
        print STDERR "Fasta file: $fasta not found.\n";
        if ($self->{_mode} eq 'full') {
            print STDERR "Fasta file need for full mode.\n";
            return 1;
        } else {
            return 0;
        }
    }
}
sub check_search_libs {
    my ($self, $libs) = @_;
    $self->{_libs_to_search} = $libs;
    if ($self->{_search_engine} eq 'omssa') {
        my $lib = $self->{_libs_to_search}->[0];
        if (! -e "$self->{_lib_path}\\$lib.psq") {
            print STDERR "OMSSA library for $lib not found in libs.  Create using 'formatdb.exe -p T -n $lib -t $lib -i $lib.fasta' or use the default, library searching.\n";
            return 1;
        } else {
            $self->{_blast_lib} = "$self->{_lib_path}\\$lib";
            $self->{_seq_lib} = "$self->{_lib_path}\\$lib.fasta";
            return 0;
        }
    } elsif ($self->{_search_engine} eq 'spectrast') { # allows searching only 1 library
        my $lib = $self->{_libs_to_search}->[0];
        if (! -e "$self->{_lib_path}\\$lib.splib") {
            print STDERR "SpectraST library for $lib not found in libs.  Either download the library or try a different search engine (opt. -e).\n";
            return 1;
        } else {
            $self->{_spec_lib} = "$self->{_lib_path}\\$lib.splib";
            $self->{_seq_lib} = "$self->{_lib_path}\\$lib.fasta";
            return 0;
        }
    } elsif ( (!$self->{_search_engine}) || ($self->{_search_engine} eq 'mspepsearch') ) { # allows searching of >1 library (and is default)
        foreach my $lib (@{$self->{_libs_to_search}}) {
            if (! -d "$self->{_lib_path}\\$lib") {
                print STDERR "MSPepSearch library for \'$lib\' not found in libs.  Either download the library or try OMSSA.\n";
                return 1;
            } else {
                push(@{$self->{_spec_libs}}, "$self->{_lib_path}\\$lib");
            }
        }
        return 0;
    }
    print STDERR "Problem finding search library.\nExiting.\n";
    return 1;
}

sub configure_omssa {
    my ($self, $omssa_semi, $missed_clvs, $omssa_mods) = @_;
    $self->{_omssa_semi} = $omssa_semi;
    $self->{_missed_clvs} = $missed_clvs;
    $self->{_omssa_mods} = $omssa_mods;
}
sub set_sort_option {
    my ($self, $sort_by) = @_;
    if ($sort_by =~ /name/i) {
        $self->{_sort_by_date} = 0;
    } else {
        $self->{_sort_by_date} = 1;
    }
    return 0;
}
sub set_mode { # This is currently hidden in USAGE.
    my ($self, $opt_m) = @_;# Options are full or lite.  Full additionally produces peptide intensities per protein.  Full is the default.
    if ($opt_m =~ /^lite$/i) {
        $self->{_mode} = '-p';
    } elsif ( ($opt_m =~ /^full$/) ) {
        $self->{_mode} = '-pp';
    } else {
        print STDERR "Mode '$opt_m' given must be 'full' or 'lite'\n";
        print STDERR "'Full' output will additionally include individual protein and peptide intensities values.  'Lite' is reccomended for routine use. Exiting.\n";
        return 1;
    }
    return 0;
}
sub _get_files {
    my ($path, $sort_by_date, $type) = @_;
    opendir(DIR, $path) || die "Could not open $path.\n";
    my @files = grep { /\.$type$/i } readdir(DIR);
    for (my $i=0; $i<scalar(@files); $i++) {
        $files[$i] = "$path\\$files[$i]"; # Prepend the full path
        if ( ($type eq 'mzXML') || ($type eq 'MGF') ) {
            my $ms1 = $files[$i];
            $ms1 =~ s/\.$type//;
            $ms1 .= '.MS1';
            if (! -e $ms1) {
                print STDERR "MS1 file $ms1 is required. Exiting.\n";
                return 1;
            }
        }
    }
    if ($sort_by_date) {
        @files = sort _by_last_mod_date @files;  # Sorting by date causes results in metric table to be displayed in chronological order from left to right.
    } else {
        @files = sort _by_name @files;
    }
    close DIR;
    return @files;
}


sub _document_raw_files {
    my ($self, $sample_path, $raws, $dir_index, $from_ini) = @_;
    if (!$dir_index) {
	open(INI, ">$self->{_out_dir}\\raw.ini") || return 1;
    } else {
	open(INI, ">>$self->{_out_dir}\\raw.ini") || return 1;
    }
    print INI "[$sample_path]\n";
    foreach (@{$raws}) {
	if ($from_ini) {
	    print INI _get_base_file($_), ".$self->{_base_ext}\n";
	} else {
	    print INI "$_\n";
	}
    }
    close INI;
    return 0;
}
sub _read_raw_ini {
    my ($self, $sample_path) = @_;
    my @raw_files = ();
    open(I, "<$self->{_out_dir}\\raw.ini") || return;
    while (<I>) {
	chomp();
	if ($_ eq "[$sample_path]") {
	    while (<I>) {
		chomp();
		if (/^\[/) {
		    last;
		} else {
		    push(@raw_files, "$sample_path\\$_");
		}
	    }
	}
    }
    close I;
    return @raw_files;
}
sub run_converter {
    my $self = shift;
    my $from_ini = 0;
    for (my $i=0; $i<scalar(@{$self->{_in_dirs}}); $i++) {
	my $sample_path = $self->{_in_dirs}->[$i];
	my @raw_files = _get_files($sample_path, $self->{_sort_by_date}, $self->{_base_ext} ); # Collect the sorted full path raw file names.
	if (!@raw_files) {
	    foreach (@{$self->{_fhs}}) {
		print $_ "Converter: $sample_path contains no $self->{_base_ext} files - assume files were moved.  Checking raw.ini.\n";
	    }
	    # Read raw.ini to see if raw files have been moved.
	    @raw_files = $self->_read_raw_ini($sample_path);
	    if (!@raw_files) {
		foreach (@{$self->{_fhs}}) {
		    print $_ "Converter: Could not find raw files in $sample_path or raw.ini.\n";
		    $self->exiting();
		}
		next; # Skips any conversion
	    } else { # Raw file references retrieved from raw.ini
		foreach (@{$self->{_fhs}}) {
		    print $_ "Converter: RAW file names found in raw.ini for $sample_path. Continuing.\n";
		}
		$from_ini = 1;
	    }
	}
	# Must have found raw files
	if ( $self->_document_raw_files($sample_path, \@raw_files, $i, $from_ini) ) { # Create/append raw.ini
	    foreach (@{$self->{_fhs}}) {
		print $_ "warn: Could not create raw.ini in $self->{_scripts_path} for $sample_path. Skipping.\n";
	    }
	}
	#my @base_names = _get_base_names(\@raw_files);
	foreach my $raw_file (@raw_files) {
	    $self->{_raw_files}->{"$raw_file"}->{_raw_path} = $sample_path; # Create raw file data structure to be used throughout
	    $self->{_raw_files}->{"$raw_file"}->{_base_name} = _get_base_file($raw_file);
	    $self->{_raw_files}->{"$raw_file"}->{_raw_file} = $raw_file;
	}
	if ($self->{_instrument_type} eq 'LTQ' || $self->{_instrument_type} eq 'ORBI') {
	    $self->run_readraw4mascot2();
	} elsif ($self->{_instrument_type} eq 'AGILENT_QTOF') {
	    $self->run_trapper();
	} elsif ($self->{_instrument_type} eq 'ORBI_HCD') {
	    $self->run_msconvert();
	} else {
	    return 1;
	}
    }
    return 0;
}
sub _check_mgf {
    my ($self, $mgf_file, $mzxml_file, $program) = @_;
    my $convert = 0;
    if ( $self->{_overwrite_all} ) {
	return 1;
    }
    if (-e $mgf_file ) {  # MGF file already exists
	if ($self->{_pro_ms} || $self->{_search_engine} eq 'spectrast' ) {
	    if (-e $mzxml_file) { # Check for mzXML for ProMS and SpectraST, skip
		foreach (@{$self->{_fhs}}) {
		    print $_ "$program: $mzxml_file found. Skipping.\n";
		}
	    } else {
		$convert = 1;
	    }
	} else {
	    foreach (@{$self->{_fhs}}) {
		print $_ "$program: $mgf_file found. Skipping.\n";
	    }
	}
    } else {
	$convert = 1;
    }
    return $convert;
}
sub run_readraw4mascot2 {
    my $self = shift;
    my $num_raw_files = scalar(keys(%{$self->{_raw_files}}));
    my ($cntr,$skipped) = (0,0);
    my $program = 'ReAdW4Mascot2';
    foreach (@{$self->{_fhs}}) {
	print $_ "#--> 1.) Extracting peak lists and measurements ($program):\n";
    }
    foreach my $raw_file ( keys(%{$self->{_raw_files}}) ) {
	my $file = $self->{_raw_files}->{"$raw_file"};
	my $raw_path = $file->{_raw_path};
	my $out_base_file = "$self->{_out_dir}\\$file->{_base_name}.$self->{_base_ext}";
	my $mgf_file = "$out_base_file.MGF";
	my $mzxml_file = "$out_base_file.mzXML";
	my $convert = $self->_check_mgf($mgf_file, $mzxml_file, $program);
	if ( $convert ) {
	    $cntr++;
	    # Set up ReAdW4Mascot2 command-line. / Multi-threading can be added here.
	    my $cmd = $self->{'ReAdW4Mascot2.exe'}. " -sep1 -NoPeaks1 -MaxPI -metadata -PIvsRT -c ";
	    if ( $self->{_pro_ms} ) {
		$cmd .= '-XmlOrbiMs1Profile ';
	    } else {
		$cmd .= '-NoMzXml ';
	    }
	    if ($self->{_converter_centroid}) {
		$cmd .= '-c ';
	    }
	    if ($self->{_instrument_type} eq 'ORBI' || $self->{_instrument_type} eq 'FT') {
		$cmd .= '-ChargeMgfOrbi -MonoisoMgfOrbi -FixPepmass '; # Extract monoisotopic precursor masses from highres instruments.
	    }
	    $cmd .= "\"$raw_file\" \"$self->{_out_dir}\"";
	    $cntr++;
	    foreach (@{$self->{_fhs}}) {
		print $_ "$program: Processing $file->{_base_name}.$self->{_base_ext} ($cntr of $num_raw_files)...\n";
		print $_ "$cmd\n";
	    }
	    my $readw_output = `$cmd`; # Run converter
	    foreach (@{$self->{_fhs}}) {
		print $_ $readw_output;
	    }
	} else {
	    $skipped++;
	}
	$self->{_raw_files}->{$raw_file}->{_mgf_file} = $mgf_file; # Copy the MGF file to structure.
	if ($self->{_pro_ms}) {
	    $self->{_raw_files}->{$raw_file}->{_mzxml_file} = $mzxml_file; # Copy the mzXML file to structure.
	}
    }
    foreach (@{$self->{_fhs}}) {
	print $_ "$program: Found $num_raw_files $self->{_base_ext} files.\n";
	print $_ "$program: Converted $cntr, skipped $skipped.\n";
	print $_ "$program: MGF files are here: $self->{_out_dir}.\n";
	print $_ "$program: Done with conversions.\n";
    }
    return 0;
}

sub run_trapper {
    my $self = shift;
    my $program = 'Agilent Trapper';
    my $num_raw_files = scalar(keys(%{$self->{_raw_files}}));
    my ($cntr,$skipped) = (0,0);
    foreach (@{$self->{_fhs}}) {
	print $_ "#--> 1.) Extracting peak lists and measurements ($program):\n";
    }
    foreach my $raw_file ( keys(%{$self->{_raw_files}}) ) {
	my $file = $self->{_raw_files}->{"$raw_file"};
	my $raw_path = $file->{_raw_path};
	my $out_base_file = "$self->{_out_dir}\\$file->{_base_name}.$self->{_base_ext}";
	my $mgf_file = "$out_base_file.MGF";
	my $mzxml_file = "$out_base_file.mzXML";
	my $convert = $self->_check_mgf($mgf_file, $mzxml_file, $program);
	if ( $convert ) {
	    $cntr++;
	    my $cmd = $self->{'trapper.exe'}. " --mzXML -c \"$raw_file\" \"$mzxml_file\"";
	    foreach (@{$self->{_fhs}}) {
		print $_ "$program: Processing \"$file->{_base_name}.$self->{_base_ext}\" ($cntr of $num_raw_files)...\n";
		print $_ "$cmd\n";
	    }
	    my $trapper_output = `$cmd`; # Run converter
	    foreach (@{$self->{_fhs}}) {
		print $_ $trapper_output;
	    }
	    $cmd = $self->{'mzData2MGF.exe'} . " \"$mzxml_file\" \"$self->{_out_dir}\"";   # Run mzXML -> MGF conversion            
	    foreach (@{$self->{_fhs}}) {
		print $_ "mzData2MGF: Processing \"$mzxml_file\" ($cntr of $num_raw_files)...\n";
		print $_ "$cmd\n";
	    }
	    $trapper_output = `$cmd`; # Run converter
	    foreach (@{$self->{_fhs}}) {
		print $_ $trapper_output;
	    }
	    if (-e $mzxml_file ) {
		system("move \"$mzxml_file.MGF\"", "\"$out_base_file.MGF\""); # Removes the extra .mzXML from file name
		#push(@{$self->{_mgf_files}}, $mgf_file);
		#push(@{$self->{_mzxml_files}}, $mzxml_file);
	    } else {
		print STDERR "$program: warn: expected mzXML file $mzxml_file was not generated.\n";
	    }
	} else {
	    $skipped++;
	}
	$self->{_raw_files}->{$raw_file}->{_mgf_file} = $mgf_file; # Copy the MGF file to structure.
	if ($self->{_pro_ms}) {
	    $self->{_raw_files}->{$raw_file}->{_mzxml_file} = $mzxml_file; # Copy the mzXML file to structure.
	}
    }
    foreach (@{$self->{_fhs}}) {
	print $_ "$program: Found $num_raw_files .$self->{_base_ext} folders.\n";
	print $_ "$program: Converted $cntr, skipped $skipped.\n";
	print $_ "$program: MGF/mzXML files are here: $self->{_out_dir}.\n";
	print $_ "$program: Done with conversions.\n";
    }
    return 0;    
}

sub run_msconvert {
    my $self = shift;
    my $program = 'ProteoWizard msconvert';
    my $num_raw_files = scalar(keys(%{$self->{_raw_files}}));
    my ($cntr,$skipped) = (0,0);
    foreach (@{$self->{_fhs}}) {
	print $_ "#--> 1.) Extracting peak lists and measurements ($program):\n";
    }
    foreach my $raw_file ( keys(%{$self->{_raw_files}}) ) {
	my $file = $self->{_raw_files}->{"$raw_file"};
	my $raw_path = $file->{_raw_path};
	my $out_base_file = "$self->{_out_dir}\\$file->{_base_name}.$self->{_base_ext}";
	my $mgf_file = "$out_base_file.MGF";
	my $mzxml_file = "$out_base_file.mzXML";
	my $convert = $self->_check_mgf($mgf_file, $mzxml_file, $program);
	if ( $convert ) {
	    $cntr++;
	    my $cmd = $self->{'msconvert.exe'} . " \"$raw_file\" -o \"$self->{_out_dir}\" --mgf -e .$self->{_base_ext}.MGF ";
	    my $type_filter;
	    if ($self->{_instrument_type} eq 'ORBI_HCD') {
		$type_filter= '--filter "activation HCD" ';
	    } elsif ($self->{_instrument_type} eq 'ORBI_CID') { # not used
		$type_filter = '--filter "activation CID" ';
	    } elsif ($self->{_instrument_type} eq 'ORBI_ETD') { # not used
		$type_filter = '--filter "activation ETD" ';
	    } else {
		die "Instrument type: $self->{_instrument_type} not defined for run_msconvert().  Try ORBI_HCD.\n"; # should never get here
	    }
	    $cmd .= $type_filter.' --filter "msLevel 2" --filter "peakPicking true 2-" --filter "threshold count 200 most-intense 2-" ';
	    $cmd .= '--filter "titleMaker Scan:<ScanNumber> RT:<ScanStartTimeInMinutes> Itot:<TotalIonCurrent> ActivationType:<ActivationType> MS_level:<MsLevel> PrecursorScan:<PrecursorSpectrumId>"';
	    foreach (@{$self->{_fhs}}) {
		print $_ "$program: Processing \"$file->{_base_name}.$self->{_base_ext}\" ($cntr of $num_raw_files)...\n";
		print $_ "$cmd\n";
	    }
	    my $output = `$cmd`; # Generate MGF
	    foreach (@{$self->{_fhs}}) {
		print $_ $output;
	    }
	    $cmd = $self->{'msconvert.exe'}." \"$raw_file\" -o \"$self->{_out_dir}\" --mzXML -e .$self->{_base_ext}.mzXML $type_filter"; # no filter is used. Might add --filter "peakPicking true 1-" --filter "threshold count 200 most-intense 1-" later 
	    foreach (@{$self->{_fhs}}) {
		print $_ "$cmd\n";
	    }
	    $output = `$cmd`; # Generate mzXML
	    foreach (@{$self->{_fhs}}) {
		print $_ $output;
	    }
	} else {
	    $skipped++;
	}
	$self->{_raw_files}->{$raw_file}->{_mgf_file} = $mgf_file; # Copy the MGF file to structure.
	if ($self->{_pro_ms}) {
	    $self->{_raw_files}->{$raw_file}->{_mzxml_file} = $mzxml_file; # Copy the mzXML file to structure.
	}
    }
    foreach (@{$self->{_fhs}}) {
	print $_ "$program: Found $num_raw_files RAW files.\n";
	print $_ "$program: Converted $cntr, skipped $skipped.\n";
	print $_ "$program: MGF files are here: $self->{_out_dir}.\n";
	print $_ "$program: Done with conversions.\n";
    }
    return 0;
}

sub _get_base_names {
    my $in = shift;
    my @files = ();
    my @base_names = ();
    my $type = ref($in);
    if ( $type eq 'SCALAR') {
        push(@files, $$in);
    } else {
        @files = @{$in};
    }
    foreach (@files) {
        my @tmp = split /\\+/;
        my $file = $tmp[$#tmp];
        $file =~ s/\..{1,3}$//;
        push(@base_names, $file); # Collect the sorted base names.
    }
    return @base_names;
}

sub _get_base_dir {
    my $file = shift;
    my @tmp = split(/\\+/, $file);
    pop(@tmp);
    my $dir = join('\\', @tmp);
    return $dir;
}
sub _get_base_file {
    my $in = shift;
    my @tmp = split /\\+/, $in;
    my $file = $tmp[$#tmp];
    $file =~ s/\..{1,3}$//;
    return $file;
}
sub _by_last_mod_date {
    my ($self) = @_;
    my $a_date = (stat($a))[9]; # last mod date in s from 01/01/1970
    my $b_date = (stat($b))[9];
    return $a_date <=> $b_date;
}
sub _by_name {
    my $self = shift;
    return $a <=> $b;
}
sub run_search_engine {
    my $self = shift;
    if ($self->{_search_engine} eq 'mspepsearch') {
        $self->run_mspepsearch();
    } elsif ($self->{_search_engine} eq 'spectrast') {
        $self->run_spectrast();
    } elsif ($self->{_search_engine} eq 'omssa') {
        $self->run_omssa();
    } else {
        print STDERR "Search engine not defined.\n";
        return 1;
    }
    return 0;
}
sub _check_search_result {
    my ($self, $file, $program) = @_;
    if ( $self->{_overwrite_all} || $self->{_overwrite_searches} ) {
	return 1;
    }
    if (-e $file) {  # MGF file already exists
	foreach (@{$self->{_fhs}}) {
	    print $_ "$program: $file found. Skipping.\n";
	}
	return 0;
    } else {
	return 1;
    }
}
sub run_mspepsearch {
    my $self = shift;
    my $program = 'MSPepSearch';
    my $num_mgf_files = scalar(keys(%{$self->{_raw_files}}));
    my ($cntr,$skipped) = (0,0);
    foreach (@{$self->{_fhs}}) {
	print $_ "#--> 2.) Identifying MS/MS spectra ($program):\n";
    }
    foreach my $raw_file ( keys(%{$self->{_raw_files}}) ) {
	my $file = $self->{_raw_files}->{"$raw_file"};
	my $mgf_file = $file->{_mgf_file};
	my $tsv_file = "$mgf_file.TSV";
	my $search = $self->_check_search_result($tsv_file, $program);
	if ($search) {
	    $cntr++;
	    my $cmd = "$self->{'MSPepSearch.exe'} fiPv";
	    if ($self->{_instrument_type} eq "AGILENT_QTOF") {
		$cmd .= 'o';
	    }
	    $cmd .=  " /OutSpecNum /OutPrecursorMZ /HiPri /MinMF $self->{_threshold} /HITS $self->{_num_matches} /Z $self->{_pmt} /M $self->{_fmt} /All ";
	    foreach my $lib (@{$self->{_spec_libs}}) {
		$cmd .= "/LIB \"$lib\" ";
	    }
	    $cmd .= "/INP \"$mgf_file\" /OUTTAB \"$tsv_file\"";
	    foreach (@{$self->{_fhs}}) {
		print $_ "$program: Searching ($cntr of $num_mgf_files)\n";
		print $_ "$program: Running $cmd\n";
	    }                    
	    my $mspepsearch_output = `$cmd 2>&1`;
	    foreach (@{$self->{_fhs}}) {
		print $_ $mspepsearch_output;
	    }  
	} else {
	    $skipped++;
	}
	$self->{_raw_files}->{"$raw_file"}->{_tsv_file} = $tsv_file;
	$self->{_raw_files}->{"$raw_file"}->{_search_result} = $tsv_file;
    }
    foreach (@{$self->{_fhs}}) {
	print $_ "MSPepSearch: Searched $cntr files.  Skipped $skipped.\n";
    }
    return 0;
}
sub run_spectrast {
    my $self = shift;
    my $program = 'SpectraST';
    my $num_mgf_files = scalar(keys(%{$self->{_raw_files}}));
    my ($cntr,$skipped) = (0,0);
    foreach (@{$self->{_fhs}}) {
	print $_ "#--> 2.) Identifying MS/MS spectra ($program):\n";
    }
    my $mgfs;
    foreach my $raw_file ( keys(%{$self->{_raw_files}}) ) {
	my $file = $self->{_raw_files}->{"$raw_file"};
	my $mgf_file = $file->{_mgf_file};
	my $pepxml_file = "$mgf_file.pep.xml";
	$self->{_raw_files}->{"$raw_file"}->{_search_result} = $pepxml_file;
	$self->{_raw_files}->{"$raw_file"}->{_pep_xml_file} = $pepxml_file;
	my $search = $self->_check_search_result($pepxml_file, $program);
	if ($search) {
	    $cntr++;
	    #my @base_names = _get_base_names(\$mgf_file);
	    $mgfs .= "$file->{_mgf_file} "
	} else {
	    $skipped++;
	}
    }
    foreach (@{$self->{_fhs}}) {
        print $_ "SpectraST: Searching $cntr files.  Skipping $skipped.\n";
    }
    if ($cntr) {
	my $cmd = "$self->{'spectrast.exe'} -s_FV1$self->{_threshold} ";# Keep only top hit, filter out below F-value=0.45
	if ($self->{_spec_lib} ne 'human') {
	    $cmd .= "-sR "; # Cache the spectral library in memory only for smaller libs
	}
	$cmd .= "-sL$self->{_spec_lib} -sM$self->{_pmt} -sO$self->{_out_dir} ";
	if ($mgfs) {
	    $cmd .= $mgfs; # Run the whole batch of MGF files at once.  
	    $cmd =~ s/\.MGF/\.mgf/g;
	    foreach (@{$self->{_fhs}}) {
		print $_ "\tSpectraST: $cmd\n";
	    }
	    my $spectrast_output = `$cmd`; # Could multi-thread here.
	    foreach (@{$self->{_fhs}}) {
		print $_ "SpectraST: $spectrast_output"; # Run SpectraST
	    }
	} else {
	    foreach (@{$self->{_fhs}}) {
		print $_ "SpectraST: No MGF files to search.\n";
	    }
	}
	foreach (@{$self->{_fhs}}) {
	    print $_ "SpectraST: Done.\n";
	}
    }
    return 0;
}

sub run_omssa {
    # Don't multi-thread OMSSA, it splits over available cores.
    my $self = shift;
    my $program = 'OMSSA';
    my $num_mgf_files = scalar(keys(%{$self->{_raw_files}}));
    my ($cntr,$skipped) = (0,0);
    foreach (@{$self->{_fhs}}) {
	print $_ "#--> 2.) Identifying MS/MS spectra ($program):\n";
    }
    foreach my $raw_file ( keys(%{$self->{_raw_files}}) ) {
	my $file = $self->{_raw_files}->{"$raw_file"};
	my $mgf_file = $file->{_mgf_file};
	my $pepxml_file = "$mgf_file.pepXML";
	my $search = $self->_check_search_result($pepxml_file, $program);
	if ($search) {
	    $cntr++;
	    if ($self->{_omssa_semi}) { # Semi-trypsin path
		my $cmd = "$self->{'omssacl.exe'} -fm \"$mgf_file\" -hl $self->{_num_matches} -te $self->{_pmt} -to $self->{_fmt} -v $self->{_missed_clvs} -he $self->{_threshold} -zh 4 -mv $self->{_omssa_mods} -d \"$self->{_blast_lib}\" -ob \"$mgf_file.OMS\" -w";
		#$cmd .= " -tem 2 -tom 2"; ###################### 15N
		foreach (@{$self->{_fhs}}) {
		    print $_ "OMSSA: Running (trypsin iteration): $cmd\n";
		}
		my $output = `$cmd 2>&1`; # semitrypsin
		my @lines = split(/\n/, $output);
		foreach (@lines) {
		    if ($_ !~ /not enough/) { # Don't write these lines to the screen or log file.
			foreach my $fh (@{$self->{_fhs}}) {
			    print $fh "$_\n";
			}
		    }
		}
		$cmd = "$self->{'omssacl.exe'} -foms \"$mgf_file.OMS\" -is $self->{_threshold} -hc $self->{_num_matches} -te $self->{_pmt} -to $self->{_fmt} -v $self->{_missed_clvs} -he $self->{_threshold} -zh 4 -mv $self->{_omssa_mods} -d \"$self->{_blast_lib}\" -op \"$pepxml_file\" -w -e 16 -oc \"$mgf_file.CSV\"\n";
		#$cmd .= " -tem 2 -tom 2"; ###################### 15N
		foreach my $fh (@{$self->{_fhs}}) {
		    print $fh "OMSSA: Running (semitrypsin iteration): $cmd\n";
		}
		$output = `$cmd 2>&1`; # semitrypsin
		@lines = split(/\n/, $output);
		foreach (@lines) {
		    if ($_ !~ /not enough/) {
			foreach my $fh (@{$self->{_fhs}}) {
			    print $fh "$_\n";
			}
		    }
		}
		system("del \"$mgf_file.OMS\""); # Delete trypsin iteration, keep only last pepXML and CSV
	    } else { # Search trypsin only
		my $cmd = "$self->{'omssacl.exe'} -fm \"$mgf_file\" -hl $self->{_num_matches} -te $self->{_pmt} -to $self->{_fmt} -v $self->{_missed_clvs} -he $self->{_threshold} -zh 4 -mv $self->{_omssa_mods} -d \"$self->{_blast_lib}\" -op \"$mgf_file.pepXML\" -oc \"$mgf_file.CSV\"";
		#$cmd .= " -tem 2 -tom 2"; ########################## 15N
		foreach (@{$self->{_fhs}}) {
		    print $_ "OMSSA: Running $cmd\n";
		}
		my $output = `$cmd 2>&1`; # Trypsin search
		my @lines = split(/\n/, $output);
		foreach (@lines) {
		    if ($_ !~ /not enough/) {
			foreach my $fh (@{$self->{_fhs}}) {
			    print $fh "$_\n";
			}
		    }
		}
            }
	} else {
            $skipped++;
        }
	$self->{_raw_files}->{"$raw_file"}->{_pepxml_file} = $pepxml_file;
	$self->{_raw_files}->{"$raw_file"}->{_search_result} = $pepxml_file;
    }
    foreach (@{$self->{_fhs}}) {
        print $_ "$program: Searched $cntr files.  Skipped $skipped.\n";
        print $_ "$program: Done.\n";
    }
    return 0;
}
sub run_pro_ms {
    my $self = shift;
    my $program = 'ProMS';
    my $num_mgf_files = scalar(keys(%{$self->{_raw_files}}));
    my ($cntr,$skipped) = (0,0);
    foreach (@{$self->{_fhs}}) {
	print $_ "#--> 3.) Performing MS1 calculations ($program):\n";
    }
    foreach my $raw_file ( keys(%{$self->{_raw_files}}) ) {
	my $file = $self->{_raw_files}->{"$raw_file"};
	my $mzxml_file = $file->{_mzxml_file};
	my $search_result = $file->{_search_result};
	my $txt_file = "$self->{_out_dir}\\$file->{_base_name}.$self->{_base_ext}.TXT";
	my $run = $self->_check_search_result($txt_file, $program);
	if ($run) {
	    my $cmd = "$self->{'ProMS.exe'}";
	    open(INI, ">proms.ini") || die "Could not open proms.ini\n";
	    print INI "$mzxml_file\n";
	    print INI "$search_result\n";
	    print INI "$txt_file\n";
	    print INI "$self->{_search_engine}\n";
	    print INI "$self->{_instrument_type}\n";
	    close INI;
	    foreach (@{$self->{_fhs}}) {
		print $_ "$program: Running $cmd on $file->{_base_name}.mzXML.\n";
	    }
	    my $proms_output = `$cmd`; # Run ProMS / Add multi-threading here.
	    foreach (@{$self->{_fhs}}) {
		print $_ "$proms_output\n";
	    }
	} else {
	    $skipped++;
	}
    }
    return 0;
}
sub get_cl_from_ini_tag {
    # Also validates existence of tag, so no need to do it later.
    my ($self, $ini_tag) = @_;
    open(INI, "<$self->{_ms_ini}") || die "Could not open $self->{_ms_ini}\n";
    my ($cl, $tag_found);
    while (<INI>) {
        if (/^\[$ini_tag]$/) {
            $tag_found++;
            $cl = <INI>;
            last;
        }
    }
    close INI;
    if (!$tag_found) {
        print STDERR "Tag $ini_tag not found in $self->{_ms_ini}.\n";
        $self->exiting();
    }
    if ($cl !~ /^\-/) {
        print STDERR "Problem finding command-line for $ini_tag in $self->{_ms_ini}.\n";
        $self->exiting();
    }
    return $cl;
}
sub run_nistms_metrics {
    my $self = shift;
    my ($cntr, $skipped) = (0,0);
    my ($cmd, $series_cntr);
    if ( $self->{_ini_tag} ) { # Manual editing of ms.ini file re-run
        $cmd = "$self->{'nistms_metrics.exe'} $self->{_ms_ini} $self->{_ini_tag} $self->{_mode}";
        open(INI, "<$self->{_ms_ini}") || die "Could not open $self->{_ms_ini}\n";
        my @lines = ();
        while (<INI>) {
            if (/^\[$self->{_ini_tag}\]$/) {
                push(@lines, $_);
                while (<INI>) {
                    if (/^\[/) {
                        last;
                    } elsif ( (/^SERIES$/) || (/^LAB$/) ) {
                        $series_cntr++;
                        push(@lines, $_);
                    } else {
                        push(@lines, $_);
                    }
                }
                last;
            }
        }
        close INI;
        foreach (@{$self->{_fhs}}) {
            print $_ "nist_metrics: Running (ini_tag=$self->{_ini_tag}): $cmd\n";
            print $_ "nist_metrics: Results are in $self->{_out_file}.\n";
        }
        my $nistmsmetrics_output = `$cmd`;
        foreach (@{$self->{_fhs}}) {
            print $_ $nistmsmetrics_output;
        }
    } else {
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
        my $date_stamp = sprintf "%4d-%02d-%02d_%02d:%02d:%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec;
        foreach (@{$self->{_fhs}}) {
            print $_ "#--> 3.) Calculating metrics (nistms_metrics): $self->{_subs_string}\n";
        }
        $cmd = "$self->{'nistms_metrics.exe'} \"$self->{_ms_ini}\" $date_stamp $self->{_mode}";
        # Process the existing ms.ini file.
        open(INI, ">>$self->{_ms_ini}") || die "Could not open $self->{_ms_ini}\n";
        # Print the current runs.
        print INI "[$date_stamp]\n";
        print INI "$self->{_cl}\n";
        if ($self->{_pro_ms}) {
            print INI "LoadEricsData\n";
        }
        if ($self->{_target_file}) {
            print INI "TargetFile=$self->{_target_file}\n";
        }
        print INI "OUT=$self->{_out_file}\n";
        if ($self->{_no_peptide}) {
            print INI "NoPeptide\n";
        } else {
            print INI "FASTA=$self->{_seq_lib}\n";
        }
        print INI "DIR=$self->{_out_dir}\\\n";
        foreach my $sample_path (@{$self->{_in_dirs}}) { # Writing the file references
	    my @raw_files = _get_files($sample_path, $self->{_sort_by_date}, $self->{_base_ext} ); # Collect the sorted full path raw file names.
	    if (!@raw_files) { # Have raw files been moved?
		@raw_files = $self->_read_raw_ini($sample_path);
		if (!@raw_files) {
		    #print "Problem finding raw files (run_nistms_metrics()).\n";
		    return 1;
		}
	    }
            if ($series_cntr > 0) {
		print INI "SERIES\n";
	    }
	    $series_cntr++;
	    foreach my $raw_file (@raw_files) {
		$cntr++;
		my $file = $self->{_raw_files}->{"$raw_file"};
		#my $mgf_file = $file->{_mgf_file};
		my $base_name = "$file->{_base_name}.$self->{_base_ext}.MGF";
		my $ext;
		if ($self->{_search_engine} eq 'mspepsearch') {
		    $ext = '.TSV';
		} else {
		    $ext = '.pepXML';
		}
		my $search_result = $base_name.$ext;
		print INI "FILE=$search_result\n";
		$cntr++;
		#print INI "MGF=$mgf_file\n"; # Still needed?
	    }
        }
        close INI;
        if ($cntr) {
            my $output = `$cmd`; # Run nistms_metrics.exe
            foreach (@{$self->{_fhs}}) {
                print $_ "nist_metrics: Running: $cmd\n";
                print $_ $output;
                print $_ "nist_metrics: Results are in $self->{_out_file}.\n";
            }
        } else {
            print STDERR "No pepXML or TSV files in $self->{_out_dir} to process. Exiting.\n";
        }
        foreach (@{$self->{_fhs}}) {
            print $_ "nistms_metrics: Processed $cntr files, skipped $skipped.\n";
            print $_ "nistms_metrics: Done.\n";
        }
    }
    if ( $series_cntr > 1 ) { # Add the lab averages section by running merge_pep_results. 09/26/08
        my $cmd = "$self->{'merge_pep_results.exe'} $self->{_out_file}";
        my $output = `$cmd`;
        foreach (@{$self->{_fhs}}) {
            print $_ "merge_pep_results: Creating summary.\n";
        }
        my $base_file = _get_base_file($self->{_out_file});
        my $base_dir = _get_base_dir($self->{_out_file});
        my $summary_file = "$base_dir\\summary_$base_file";
        my $summary;
        open(SUMMARY, "<$summary_file") || die "No summary file.\n";
        while (<SUMMARY>) {
            if (!$summary) {
                if (/^Begin Series Averages$/) {
                    $summary .= $_;
                    while (my $line = <SUMMARY>) {
                        if ($line !~ /^End Series Averages$/) {
                            $summary .= $line;
                        } else {
                            $summary .= $line;
                            last;
                        }
                    }
                }
            } else {
                last;
            }
        }
        close SUMMARY;
        open(REPORT, ">>$self->{_out_file}") || warn "Cannot open $self->{_out_file}. Exiting.\n";
        print REPORT "\n$summary"; # Write the averages section onto the end of the report.
        close REPORT;
        system("del \"$summary_file\""); # Delete the, now redundant, summary file.
        foreach (@{$self->{_fhs}}) {
            print $_ "merge_pep_results: Done.\n";
            print $_ "merge_pep_results: Final output file is $self->{_out_file}\n";
        }
    }
    if ($self->{_mcp_summary}) {
        my $mcp_summary = new ParseMetrics();
        if ( $mcp_summary->create_summary($self->{_out_file}) ) {
            $self->exiting();
        }
    }
    my $datestamp = $self->_get_datestamp();
    foreach (@{$self->{_fhs}}) {
        print $_ "NISTMSQC: Run ended at $datestamp\n";
    }
    return 0;
}
1;
}