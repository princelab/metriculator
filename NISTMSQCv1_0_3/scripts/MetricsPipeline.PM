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
    $self->{_usage} = "\nUSAGE: run_NISTMSQC_pipeline.pl --in_dir <full path> (--in_dir <full path2..N>) --out_dir <full path> --out_file <path to output file> --library <library name> (--library <library 2..N>) --instrument_type <inst. type>\n\n[opts. --search_engine <search engine> --fasta <path to file> --sort_by <'date' or 'name'> --overwrite_all --overwrite_searches --mode <full,lite> --pro_ms --log_file --ini_tag --help]

Command-line Arguments (Required):

--in_dir (req'd.) Full path to RAW or MGF+MS1 files.  Multiple are allowed and will be compared as series.
--out_dir (req'd.) Full path to directory to write pipeline output files.
--out_file (req'd.) Full path to final output file.
--library (req'd.) Basename of library.  Multiple are allowed for MSPepSearch ONLY.
--instrument_type (req'd.) LCQ, LTQ, LXQ, ORBI and FT are currently allowable values.

Options (NOT required):

--search_engine (default=MSPepSearch) Name of search engine.  Other allowable values are SpectraST and OMSSA.
--fasta (default=<basename of library [.fasta]) Full path to a fasta file.  Only used for protein metrics in 'full' mode.
--sort_by (default=data) Controls the ordering of columns in the output file.  'name' or 'date' are allowed.
--overwrite_all Will force all programs to re-run overwriting any data files.  Useful if pipeline binaries have been updated.
--overwrite_searches Will force search engine to overwrite existing search results.  Useful if changing databases.
--no_peptide Use if libraries are not peptide.
--mcp_summary Generate an additional output file (.CSV) with ONLY metrics referenced in the publication (Rudnick et al, MCP in press).
--mode (default=lite) Controls content of output file.  'Full' will include protein level summaries. 'lite' and 'full' are allowed.
--pro_ms If specified, ProMS will be used for MS1 data analysis.
--log_file If specified, output from program will be directed to a LOG file appearing in the same directory as the out file.
--ini_tag <tag> If a tag name is given, this section from ms.ini will be used and a new one will NOT be generated.  This is helpful if re-ordering of runs (manual editing of ms.ini) is required for presentation or grouping of multiple series.  NOTE: No validation of the structure of the ms.ini file is done; exercise caution when editing the ms.ini file.
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
    print STDERR "NISTMSQC: Exiting with errors.\n";
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
sub check_executables {
    my $self = shift;
    ### Check for required executables.
    my @exes = ('ReAdW4Mascot2.exe', 'MSPepSearch.exe', 'spectrast.exe', 'omssacl.exe', 'nistms_metrics.exe', 'merge_pep_results.exe', 'ProMS.exe');
    foreach (@exes) {
        $self->{$_} = "$self->{_bin_path}\\$_";
        if (! -e $self->{$_}) {
            print STDERR "Required program: $self->{$_} not found in $self->{_bin_path}.\n";
            return 1;
        }
    }
    return 0;
}
sub check_in_dirs {
    my ($self, $in_dirs) = @_;
    foreach ( @{$in_dirs} ) {
        if ( ! -d $_ ) {
            print STDERR "In Directory: $_ does not exist.\n";
            return 1;
        } else {
            push( @{$self->{_in_dirs}}, $_ );
        }
    }
    return 0;
}
sub check_out_dir {
    my ($self, $out_dir) = @_;
    if ( ! -d $out_dir ) {
        if (!mkdir($out_dir)) {
            print STDERR "NISTMSQC: Out dir: $out_dir\' does not exist and could not be created.\n";
            return 1;
        } else {
            print STDERR "NISTMSQC: Out dir: $out_dir successfully created.\n";
        }
    }
    $self->{_out_dir} = $out_dir;
    
    return 0;
}

sub check_out_file {
    my ($self, $out_file) = @_;
    if ( -s $out_file ) {
        print STDERR "NISTMSQC: Output file: $out_file already exists.\n";
        my @parts = split(/\\/, $out_file);
        my $file = pop(@parts);
        my $path = join('\\', @parts);
        my ($file_root, $file_ext) = split(/\./, $file, 2);
        for (my $i=1; $i<100; $i++) {
            my $version = "$path\\$file_root"."__$i.$file_ext";
            if (! -s $version) {
                $out_file = $version;
                last;
            }
        }
        print STDERR "NISTMSQC: Output file: $out_file will be used instead.\n";
    }
    $self->{_out_file} = $out_file;
    open(OUT, ">$out_file") || die "$!\nOut file: $out_file could not be created. Exiting.\n";
    close OUT;
    if ($self->{_log_file}) {
        $self->{_log_file_name} = "$self->{_out_file}.LOG";
        print STDERR "Log file created for this run: $self->{_log_file_name}\n";
        # Initiate log file. 12/24/09
        open(LOG, ">>$self->{_log_file_name}") || die "Could not open log file: $self->{_log_file_name}\n";
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
        my $date_stamp = sprintf "%4d-%02d-%02d_%02d:%02d", $year+1900,$mon+1,$mday,$hour,$min;
        print LOG "Started run: $date_stamp\n";
        print LOG "Command-line: $self->{_cl}\n";
        close LOG;
    }
    return 0;
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
                print STDERR "When using >1 library, you must create a combined fasta and specifiy it using (opt. --fast)\n";
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
    return 0;
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
    my ($self, $opt_m) = @_;# Options are full or lite.  Full additionally produces peptide intensities per protein.  Lite is the default.
    if ($opt_m =~ /^full$/i) {
        $self->{_mode} = '-pp';
    } elsif ( ($opt_m =~ /^lite$/) || (!$opt_m) ) {
        $self->{_mode} = '-p';
    } else {
        print STDERR "Mode must be 'full' or 'lite'\n";
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
sub run_converter {
    my $self = shift;
    my $fh;
    if ($self->{_log_file}) {
        open(LOG, ">>$self->{_log_file_name}") || die "Could not open LOG file: $self->{_log_file_name}.\n";
        $fh = *LOG;
    } else {
        $fh = *STDOUT;
    }
    for (my $i=0; $i<scalar(@{$self->{_in_dirs}}); $i++) {
        my $sample_path = $self->{_in_dirs}->[$i];
        my ($cntr,$skipped) = (0,0);
        my @raw_files = _get_files($sample_path, $self->{_sort_by_date}, 'RAW'); # Collect the sorted full path raw file names.
        if (!@raw_files) { # Starting from MGF
            print $fh "ReAdW4Mascot2: $sample_path contains no raw files.  Skipping conversion.\n";
            my @mgf_files = _get_files($sample_path, $self->{_sort_by_date}, 'MGF'); # Collect the sorted full path mgf file names.
            if (@mgf_files) {
                my $cntr;
                @{$self->{_base_names}->{$sample_path}} = _get_base_names(\@mgf_files); # Raw file base names only, no extensions.
                foreach (@{$self->{_base_names}->{$sample_path}}) {
                    if ( -e "$sample_path\\$_.RAW.MS1" && -e "$sample_path\\$_.RAW.MGF" ) { # Check for MS1 file.
                        push(@{$self->{_mgf_files}}, "$sample_path\\$_.RAW.MGF");
                        $cntr++;
                    } else {
                        print $fh "ReAdW4Mascot2: File $_: MS1 file not found for OR naming convention not understood.  Skipping.\n";
                    }
                }
                if (!$cntr) {
                    print $fh "ReAdW4Mascot2: In directory: $sample_path contains no MGF files.  Skipping directory.\n";
                } else {
                    print $fh "ReAdW4Mascot2: Will attempt to process $cntr MGF files found in $sample_path.\n";
                }
            } else {
                print $fh "ReAdW4Mascot2: $sample_path contains no MGF files.  Skipping directory.\n";
            }
            return 0;
            # Must be trying to use pre-generated MGF files, skip to searches.
        } else {
            @{$self->{_base_names}->{$sample_path}} = _get_base_names(\@raw_files); # Raw file base names only, no extensions.
            my $num_raw_files = scalar(@raw_files); # Total number of raw files to process for this sub.
            print $fh "#--> 1.) Extracting peak lists and measurements (ReAdW4Mascot2.exe): $self->{_subs}->[$i]\n";
            foreach my $base_name (@{$self->{_base_names}->{$sample_path}}) {
                if (!$self->{_overwrite_all}) {
                    if (-e "$self->{_out_dir}\\$base_name.RAW.MGF") {  # Do not reconvert RAW files if MGF's already exist.
                        push(@{$self->{_mgf_files}}, "$self->{_out_dir}\\$base_name.RAW.MGF");
                        if ($self->{_pro_ms}) {
                            if (-e "$self->{_out_dir}\\$base_name.RAW.mzXML") {
                                print $fh "ReAdW4Mascot2: $base_name.RAW already converted. Skipping.\n";
                                $skipped++;
                                next;
                            }
                        } else {
                            print $fh "ReAdW4Mascot2: $base_name.RAW already converted. Skipping.\n";
                            $skipped++;
                            next;
                        }
                    }
                }
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
                    $cmd .= '-ChargeMgfOrbi -MonoisoMgfOrbi -FixPepmass '; # Extract monoisotopic masses from highres instruments.
                }
                $cmd .= "$sample_path\\$base_name.RAW $self->{_out_dir}";
                $cntr++;
                print $fh "ReAdW4Mascot2: Processing \"$base_name.RAW\" ($cntr of $num_raw_files)...\n";
                print $fh "$cmd\n";
                print $fh `$cmd`;
                push(@{$self->{_mgf_files}}, "$self->{_out_dir}\\$base_name.RAW.MGF");
            }
            print $fh "ReAdW4Mascot2: Found $num_raw_files RAW files.\n";
            print $fh "ReAdW4Mascot2: Converted $cntr, skipped $skipped.\n";
            print $fh "ReAdW4Mascot2: MGF files are here: $self->{_out_dir}.\n";
            print $fh "ReAdW4Mascot2: Done with conversions.\n";
        }
    }
    if ($self->{_log_file}) {
        close $fh;
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
        $file =~ s/\..+$//;
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

sub run_mspepsearch {
    my $self = shift;
    my $fh;
     if ($self->{_log_file}) {
        open(LOG, ">>$self->{_log_file_name}") || die "Could not open LOG file: $self->{_log_file_name}.\n";
        $fh = *LOG;
    } else {
        $fh = *STDOUT;
    }
    my $num_mgf_files = scalar(@{$self->{_mgf_files}});
    if ($num_mgf_files) {
        print  $fh "#--> 2.) Identifying the spectra (MSPepSearch)\n";
        my ($cntr,$skipped) = (1,0);
        foreach my $mgf_file (@{$self->{_mgf_files}}) {
            my @base_names = _get_base_names(\$mgf_file);
            my $tsv_file = "$self->{_out_dir}\\$base_names[0].RAW.MGF.TSV";
            if ( -e $tsv_file && !$self->{_overwrite_searches} ) {
                print $fh "MSPepSearch: $mgf_file already searched. Skipping.\n";
                $skipped++;
                next;
            } else {
                if (-e $mgf_file) {
                    my $cmd = "$self->{'MSPepSearch.exe'} fiPv /OutSpecNum /OutPrecursorMZ /HiPri /MinMF $self->{_threshold} /HITS $self->{_num_matches} /Z $self->{_pmt} /M $self->{_fmt} ";
                    foreach my $lib (@{$self->{_spec_libs}}) {
                        $cmd .= "/LIB $lib ";
                    }
                    $cmd .= "/INP $mgf_file /OUTTAB $tsv_file";
                    print $fh "MSPepSearch: Searching ($cntr of ".($num_mgf_files-$skipped).")\n";
                    print $fh "MSPepSearch: Running $cmd\n";
                    print $fh `$cmd 2>&1`;
                    $cntr++;
                } else {
                    warn "MSPepSearch: Could not find $mgf_file.  Skipping.\n";
                    $skipped++;
                    next;
                }
            }
        }
        print $fh "MSPepSearch: Searched ". ($cntr - 1) ." files.  Skipped $skipped.\n";
    }
    print $fh "MSPepSearch: Done.\n";
    if ($self->{_log_file}) {
        close $fh;
    }
    return 0;
}
sub run_spectrast {
    my $self = shift;
    my $fh;
     if ($self->{_log_file}) {
        open(LOG, ">>$self->{_log_file_name}") || die "Could not open LOG file: $self->{_log_file_name}.\n";
        $fh = *LOG;
    } else {
        $fh = *STDOUT;
    }
    my ($cntr,$skipped) = (1,0);
    my $mgfs;
    print $fh "#--> 2.) Identifying the spectra (SpectraST)\n";
    foreach my $mgf_file (@{$self->{_mgf_files}}) {
        my @base_names = _get_base_names(\$mgf_file);
        my $xml = "$self->{_out_dir}\\$base_names[0].RAW.pep.xml";
        if (-e $xml && !$self->{_overwrite_searches} ) { # Already searched 
            $skipped++;
        } else {
            $mgfs .= "$mgf_file ";
            $cntr++;
        }
    }
    print $fh "SpectraST: Searching ". ($cntr - 1) ." files.  Skipping $skipped.\n";
    my $cmd = "$self->{'spectrast.exe'} -s_FV1$self->{_threshold} ";# Keep only top hit, filter out below F-value=0.45
    if ($self->{_spec_lib} ne 'human') {
        $cmd .= "-sR "; # Cache the spectral library in memory only for smaller libs
    }
    $cmd .= "-sL$self->{_spec_lib} -sM$self->{_pmt} -sO$self->{_out_dir} ";
    if ($mgfs) {
        $cmd .= $mgfs; # Run the whole batch of mzXML files at once.  
        $cmd =~ s/\.MGF/\.mgf/g;
        print $fh "\tSpectraST: $cmd\n";
        print $fh `$cmd`; # Run SpectraST
        #system("move ")
    } else {
        print $fh "SpectraST: No MGF files to search.\n";
    }
    print $fh "SpectraST: Done.\n";
    if ($self->{_log_file}) {
        close $fh;
    }
    return 0;
}
sub run_omssa {
    my $self = shift;
    my $fh;
     if ($self->{_log_file}) {
        open(LOG, ">>$self->{_log_file_name}") || die "Could not open LOG file: $self->{_log_file_name}.\n";
        $fh = *LOG;
    } else {
        $fh = *STDOUT;
    }
    my ($cntr,$skipped) = (1,0);
    print  $fh "#--> 2.) Identifying the spectra (OMSSA)\n";
    foreach my $mgf_file (@{$self->{_mgf_files}}) {
        my @base_names = _get_base_names(\$mgf_file);
        my $pepxml = "$self->{_out_dir}\\$base_names[0].RAW.MGF.pepXML";
        my $root = "$self->{_out_dir}\\$base_names[0].RAW.MGF";
        if ( (-e $pepxml) && (!$self->{_overwrite_searches}) ) {
            #$self->{_search_results}->
            print $fh "OMSSA: $mgf_file already searched. Skipping.\n";
            $skipped++;
            next;
        } else {
            if (-e $mgf_file) {
                $cntr++;
                if ($self->{_omssa_semi}) { # Semi-trypsin path
                    my $cmd = "$self->{'omssacl.exe'} -fm $mgf_file -hl $self->{_num_matches} -te $self->{_pmt} -to $self->{_fmt} -v $self->{_missed_clvs} -he $self->{_threshold} -zh 4 -mv $self->{_omssa_mods} -d $self->{_blast_lib} -ob $root.OMS -w";
                    #$cmd .= " -tem 2 -tom 2"; ###################### 15N
                    print $fh "OMSSA: Running (trypsin iteration): $cmd\n";
                    my $output = `$cmd 2>&1`; # semitrypsin
                    my @lines = split(/\n/, $output);
                    foreach (@lines) {
                        if ($_ !~ /not enough/) {
                            print $fh "$_\n";
                        }
                    }
                    $cmd = "$self->{'omssacl.exe'} -foms $root.OMS -is $self->{_threshold} -hl $self->{_num_matches} -te $self->{_pmt} -to $self->{_fmt} -v $self->{_missed_clvs} -he $self->{_threshold} -zh 4 -mv $self->{_omssa_mods} -d $self->{_blast_lib} -op $root.pepXML -w -e 16 -oc $root.CSV\n";
                    #$cmd .= " -tem 2 -tom 2"; ###################### 15N
                    print $fh "OMSSA: Running (semitrypsin iteraction): $cmd\n";
                    $output = `$cmd 2>&1`; # semitrypsin
                    @lines = split(/\n/, $output);
                    foreach (@lines) {
                        if ($_ !~ /not enough/) {
                            print $fh "$_\n";
                        }
                    }
                    system("del $root.OMS"); # Delete trypsin iteration, keep only last pepXML and CSV
                } else { # Search trypsin only
                    my $cmd = "$self->{'omssacl.exe'} -fm $mgf_file -hl $self->{_num_matches} -te $self->{_pmt} -to $self->{_fmt} -v $self->{_missed_clvs} -he $self->{_threshold} -zh 4 -mv $self->{_omssa_mods} -d $self->{_blast_lib} -op $root.XML -oc $root.CSV";
                    #$cmd .= " -tem 2 -tom 2"; ########################## 15N
                    print $fh "OMSSA: Running $cmd\n";
                    my $output = `$cmd 2>&1`; # Trypsin search
                    my @lines = split(/\n/, $output);
                    foreach (@lines) {
                        if ($_ !~ /not enough/) {
                            print $fh "$_\n";
                        }
                    }
                }
            } else {
                $skipped++;
                warn "OMSSA: $mgf_file does not exist! Skipping.\n";
            }
        }
    }
    print $fh "OMSSA: Searched ". ($cntr - 1) ." files.  Skipped $skipped.\n";
    print $fh "OMSSA: Done.\n";
    if ($self->{_log_file}) {
        close $fh;
    }
    return 0;
}
sub run_pro_ms {
    my $self = shift;
    my $fh;
     if ($self->{_log_file}) {
        open(LOG, ">>$self->{_log_file_name}") || die "Could not open LOG file: $self->{_log_file_name}.\n";
        $fh = *LOG;
    } else {
        $fh = *STDOUT;
    }
    if ($self->{_overwrite_searches}) {
        print STDERR "Overwrite_searches selected: Deleting previously generated ProMS output files.\n";
        foreach my $base_name ( @{ $self->{_mgf_files} } ) {
            $base_name =~ s/\.mgf$//i;
            my $pro_ms_file = "$base_name.txt";
            if (-e $pro_ms_file) {
                system("del $pro_ms_file"); # Work-around.  Ask Eric to add --overwrite option to his program.
            }
        }
    }
    my $cmd = "$self->{'ProMS.exe'} $self->{_out_dir} $self->{_search_engine}";
    print $fh "ProMS: Running $cmd\n";
    print $fh `$cmd`;
    if ($self->{_log_file}) {
        close $fh;
    }
    return 0;
}
sub run_nistms_metrics {
    my $self = shift;
    my $fh;
    if ($self->{_log_file}) {
        open(LOG, ">>$self->{_log_file_name}") || die "Could not open LOG file: $self->{_log_file_name}.\n";
        $fh = *LOG;
    } else {
        $fh = *STDOUT;
    }
    my ($cntr, $skipped) = (0,0);
    my ($cmd, $series_cntr);
    if ( $self->{_ini_tag} ) {
        my $tag_found;
        $cmd = "$self->{'nistms_metrics.exe'} $self->{_ms_ini} $self->{_ini_tag} $self->{_mode}";
        open(INI, "<$self->{_ms_ini}") || die "Could not open $self->{_ms_ini}\n";
        my @lines = ();
        while (<INI>) {
            if (/^\[$self->{_ini_tag}\]$/) {
                $tag_found++;
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
        if (!$tag_found) {
            print STDERR "nistms_metrics: Tag $self->{_ini_tag} not found in $self->{_ms_ini}.\n";
            return 1;
        } else {
            print $fh "nist_metrics: Running (ini_tag=$self->{_ini_tag}): $cmd\n";
            print $fh `$cmd`; # Run nistms_metrics.exe
            print $fh "nist_metrics: Results are in $self->{_out_file}.\n";
        }
    } else {
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
        my $date_stamp = sprintf "%4d-%02d-%02d_%02d:%02d:%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec;
        print $fh "#--> 3.) Calculating metrics (nistms_metrics): $self->{_subs_string}\n";
        $cmd = "$self->{'nistms_metrics.exe'} $self->{_ms_ini} $date_stamp $self->{_mode}";
        # Process the existing ms.ini file.
        open(INI, ">>$self->{_ms_ini}") || die "Could not open $self->{_ms_ini}\n";
        # Print the current runs.
        print INI "[$date_stamp]\n";
        print INI "$self->{_cl}\n";
        if ($self->{_pro_ms}) {
            print INI "LoadEricsData\n";
        }
        print INI "OUT=$self->{_out_file}\n";
        if ($self->{_no_peptide}) {
            print INI "NoPeptide\n";
        } else {
            print INI "FASTA=$self->{_seq_lib}\n";
        }
        print INI "DIR=$self->{_out_dir}\\\n";
        foreach my $sample_path (@{$self->{_in_dirs}}) {
            # Local paths.
            if ($series_cntr > 0) { print INI "SERIES\n"; }
                $series_cntr++;
                foreach my $base_name (@{$self->{_base_names}->{$sample_path}}) {
                my $mgf;
                if (!-e "$self->{_out_dir}\\$base_name.RAW.MGF") {
                    $mgf = "$sample_path\\$base_name.RAW.MGF";
                    if (!-e $mgf) {
                        print STDERR "NISTMSQC: Warn: $mgf not found.\n";
                        $skipped++;
                    }
                }
                if ($self->{_search_engine} eq 'omssa') {
                    my $file = "$base_name.RAW.MGF.pepXML";
                    my $search_result = "$self->{_out_dir}\\$file";
                    if (-e $search_result) { # OMSSA
                        print INI "FILE=$file\n";
                        $cntr++;
                        if ($mgf) {
                            print INI "MGF=$mgf\n";
                        }
                    } else {
                        print STDERR "NISTMSQC: Warn: Could not find $file\n";
                        $skipped++;
                    }
                } elsif ($self->{_search_engine} eq 'mspepsearch') {
                    my $file = "$base_name.RAW.MGF.TSV";
                    my $search_result = "$self->{_out_dir}\\$file";
                    if (-e $search_result) { # MSPepSearch
                        print INI "FILE=$file\n";
                        $cntr++;
                        if ($mgf) {
                            print INI "MGF=$mgf\n";
                        }
                    } else {
                        print STDERR "NISTMSQC: Warn: Could not find $file\n";
                        $skipped++;
                    }
                } elsif  ($self->{_search_engine} eq 'spectrast') {
                    my $file = "$base_name.RAW.pep.xml";
                    my $search_result = "$self->{_out_dir}\\$file";
                    if (-e $search_result) { # SpectraST
                        print INI "FILE=$file\n";
                        $cntr++;
                        if ($mgf) {
                            print INI "MGF=$mgf\n";
                        }
                    } else {
                        print STDERR "NISTMSQC: Warn: Could not find $file\n";
                        $skipped++;
                    }
                } else {
                    warn "Search results for $base_name not found. Skipping.\n";
                    $skipped++;
                }
            }
        }
        close INI;
        if ($cntr) {
            print $fh "nist_metrics: Running: $cmd\n";
            print $fh `$cmd`; # Run nistms_metrics.exe
            print $fh "nist_metrics: Results are in $self->{_out_file}.\n";
        } else {
            print STDERR "No pepXML or TSV files in $self->{_out_dir} to process. Exiting.\n";
        }
        print $fh "nistms_metrics: Processed $cntr files, skipped $skipped.\n";
        print $fh "nistms_metrics: Done.\n";
    }
    if ( $series_cntr > 1 ) { # Add the lab averages section by running merge_pep_results. 09/26/08
        print $fh "merge_pep_results: Creating summary.\n";
        my $cmd = "$self->{'merge_pep_results.exe'} $self->{_out_file}";
        print $fh `$cmd`; # Run merge_pep_results.
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
        system("del $summary_file"); # Delete the, now redundant, summary file.
        print $fh "merge_pep_results: Done.\n";
        print $fh "merge_pep_results: Final output file is $self->{_out_file}\n";
    }
    if ($self->{_mcp_summary}) {
        my $mcp_summary = new ParseMetrics();
        if ( $mcp_summary->create_summary($self->{_out_file}) ) {
            $self->exiting();
        }
    }
    if ($self->{_log_file}) {
        close $fh;
    }
    return 0;
}
1;
}