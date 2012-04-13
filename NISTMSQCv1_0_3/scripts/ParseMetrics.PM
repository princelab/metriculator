{
	
package ParseMetrics;
use strict;

sub new {
	my ($class,
	    ) = @_;
	my $self = {};
	%{$self->{_metrics}} = (#'Spectrum Counts' => [1,2],
		'Tryptic Peptide Counts' => [1,2,3],
		'Peptide Counts' => [4],
		'Middle Peptide Retention Time Period \(min\)' => [1,5,6,7],
		'MS1 During Middle \(and Early\) Peptide Retention Period' => [1,2,14,15],
		'Precursor m/z for IDs' => [1],
		'Ion IDs by Charge State \(Relative to \+2\)' => [2,4,5],
		'MS2 ID S/N' => [1],
		'MS2 ID Peaks' => [1],
		'MS2 ID Score' => [1],
		'MS1 ID Max' => [1,8],
		'Fraction of MS2 Identified at Different MS1max Quartiles' => [1,2,3,4],
		'Peak Width at Half Height for IDs' => [1,5],
		#'Peak Widths at Half Max over RT deciles for IDs' => [1,2,3],
		'Fraction of Repeat Peptide IDs with Divergent RT \(RT vs RT-best ID\) - Chromatographic \'Bleed\'' => [1,2],
		'Ratios of Peptide Ions IDed by Different Numbers of Spectra - Oversampling Measure' => [1,2],
		'MS1max/MS1sampled Abundance Ratio IDs - Inefficient Sampling' => [1,7],
		#'Relative Fraction of Peptides in Abundance Quartile Matching a Peptide in Other Runs' => [1,2,3,4],
		#'Differences in Elution Rank \(Percent\) of Matching
		#Peptides in Other Runs' => [1],
		'Ion Injection Times for IDs \(ms\)' => [1,3],
		'IDs by Charge State \(Relative to \+2\)' => [2,4,5]
	       );
	%{$self->{_titles}} = (
		'Fraction of MS2 Identified at Different MS1max Quartiles - ID Fract Q3' => ' MS2-4C (fract. ID\'d Q3)',
		'Fraction of MS2 Identified at Different MS1max Quartiles - ID Fract Q1' => 'MS2-4A (fract. ID\'d Q1)',
		'Fraction of MS2 Identified at Different MS1max Quartiles - ID Fract Q4' => 'MS2-4D (fract. ID\'d Q4)',
		'Fraction of MS2 Identified at Different MS1max Quartiles - ID fract Q2' => 'MS2-4B (fract. ID\'d Q2)',
		'Fraction of Repeat Peptide IDs with Divergent RT \(RT vs RT-best ID\) - Chromatographic \'Bleed\' - - 4 min    ' => 'C-1A (\'bleed\' -4 min.)*100',
		'Fraction of Repeat Peptide IDs with Divergent RT \(RT vs RT-best ID\) - Chromatographic \'Bleed\' - + 4 min      ' => 'C-1B (\'bleed\' +4 min.)*100',
		'Ion IDs by Charge State \(Relative to \+2\) - Charge +1' => 'IS-3A (ratio IDs +1/+2)',
		'Ion IDs by Charge State \(Relative to \+2\) - Charge +4' => 'IS-3C (ratio IDs +4/+2)',
		'Ion IDs by Charge State \(Relative to \+2\) - Charge +3' => 'IS-3B (ratio IDs +3/+2)',
		'Ion Injection Times for IDs \(ms\) - MS2 Median' => 'MS2-1 (Ion injection (ms) for IDs)*0.01',
		'Ion Injection Times for IDs \(ms\) - MS1 Median' => 'MS1-1 (ion injection (ms) for IDs)',
		'MS1 During Middle \(and Early\) Peptide Retention Period - MS1 Falls >10x' => 'IS-1B (MS1 >10X falls)',
		'MS1 During Middle \(and Early\) Peptide Retention Period - MS1 Jumps >10x' => 'IS-1A (MS1 >10X jumps)',
		'MS1 During Middle \(and Early\) Peptide Retention Period - S/N Median' => 'MS1-2A (S/N)',
		'MS1 During Middle \(and Early\) Peptide Retention Period - TIC Median/1000' => 'MS1-2B (med. TIC/1e3 over C-2A)',
		'MS1 ID Max - 95/5 Pctile' => 'MS1-3A (dynamic range 95th/5th for IDs)',
		'MS1 ID Max - Median  ' => 'MS1-3B (med. MS1 signal for IDs)',
		'MS1max/MS1sampled Abundance Ratio IDs - Inefficient Sampling - Median All IDs' => 'DS-3A (med. MS1max/MS1sampled all IDs)',
		'MS1max/MS1sampled Abundance Ratio IDs - Inefficient Sampling - Med Bottom 1/2' => 'DS-3B (med. MS1max/MS1sampled for bottom 50% by abund.)',
		'MS2 ID Peaks - Median  ' => 'MS2-3 (med. num peaks for IDs)*0.001',
		'MS2 ID S/N - Median  ' => 'MS2-2 (S/N for IDs)*0.001',
		'MS2 ID Score - Median  ' => 'P-1 (med. f-value score for IDs)*100',
		'Middle Peptide Retention Time Period \(min\) - MS2 scans' => 'DS-2B (MS2 Scans over C-2A)*0.001',
		'Middle Peptide Retention Time Period \(min\) - Pep ID Rate' => 'C-2B (peptides/min.)',
		'Middle Peptide Retention Time Period \(min\) - MS1 Scans' => 'DS-2A (MS1 Scans over C-2A)*0.01',
		'Middle Peptide Retention Time Period \(min\) - Half Period' => 'C-2A (IQ pep. RT period)*0.1',
		'Peak Width at Half Height for IDs - Median Disper' => 'C-3B (IQ for peak widths)',
		'Peak Width at Half Height for IDs - Median Value' => 'C-3A (med. peak width)',
		'Peptide Counts - Semi/Tryp Peps' => 'P-3 (semi/full tryptic peps)*100',      
		'Precursor m/z for IDs - Median  ' => 'IS-2 (med. precursor m/z)*0.001',
		'Ratios of Peptide Ions IDed by Different Numbers of Spectra - Oversampling Measure - Once/Twice' => 'DS-1A (oversampling - once/twice)',
		'Ratios of Peptide Ions IDed by Different Numbers of Spectra - Oversampling Measure - Twice/Thrice' => 'DS-1B (oversampling - twice/thrice)',
		'Tryptic Peptide Counts - Peptides  ' => 'P-2C (unique peptide IDs)',
		'Tryptic Peptide Counts - Ions    ' => 'P-2B (unique ion IDs)',
		'Tryptic Peptide Counts - Identifications' => 'P-2A (total IDs)'
		);
	bless($self, $class);
	return $self;
}
sub create_summary {
	my ($self, $file) = @_;
	my @file = ();
	print "ParseMetrics: Reading $file and generating summary.\n";
	open (IN, "<$file") || die "$!: $file\n";
	while (<IN>) { # Read the report into an array of lines
		unless (/^Begin Series Averages/) {
			push(@file, $_);
		} else {
			last;
		}
	}
	# Parse the file for the values and lines in %metrics.
	my %table = $self->_build_table(\@file, 1, 0); # send metrics hash and start column.
	
	# Transpose rows of data to columns for export of series.
	my @data = $self->_build_columns(\%table);
	$self->{_mcp_summary_file} = "$file.CSV";
	print "ParseMetrics: MCP Summary file: $self->{_mcp_summary_file}\n";
	open(CSV, ">$self->{_mcp_summary_file}") || die "$!\n";
	# Print
	for my $r (@data) {
		print CSV "@$r\n";
	}
	# Read averages section produced by merge_pep_results
	seek(IN, 0, 0);
	@file = ();
	my $series = 0;
	while (<IN>) {
		if (/^Begin Series Averages/) {
			while (<IN>) {
				push(@file, $_);
			}
			last;
		} elsif (/^End Series=(\d+)/) {
			$series = $1;
		} else {
			next;
		}
	}
	close IN;		
	# AVERAGES
	my $start = 0 + 1;
	%table = $self->_build_table(\@file, $start, 1);
	@data = $self->_build_columns(\%table);
	for my $r (@data) {
		print CSV "@$r\n";
	}
	close CSV;
	return 0;
}

sub _build_table {
	my ($self, $file, $start_field, $split) = @_;
	my %table = ();
	foreach my $metric (keys(%{$self->{_metrics}})) {
		#print $metric;
		for (my $i=0; $i<=scalar(@{$file}); $i++) {
			if ($file->[$i] =~ /^$metric$/) { # Found the metric
				for (my $j=0; $j<scalar( @{$self->{_metrics}->{$metric}} ); $j++) { # lines to print
					my $line_to_print = ($i+$self->{_metrics}->{$metric}[$j]);
					my $line = $file->[$line_to_print];
					chomp($line);
					my @tmp = split /\t+/, $line;
					my $cntr = 0;
					for (my $k=$start_field; $k<=scalar(@tmp); $k++) {
						if ($split && $tmp[$k] && ($k > 0 )) {
							my @tmp2 = split /\//, $tmp[$k];
							if (!$cntr) {
								#$tmp[$k] = $tmp[1]; # keep the median dev
							} else {
								#$tmp[$k] = $tmp2[0]; # keep the median
							}
							$cntr++;
						}
						push( @{$table{$metric}{$tmp[0]}}, $tmp[$k])
					}
				}
			}
		}
	}
	return %table;
}
sub _build_columns {
	my ($self, $table) = @_;
	my $row = 0;
	my $column = 0;
	my @data = ();
	foreach my $metric (sort(keys(%{$table}))) {
		foreach my $sub_metric (keys(%{$table->{$metric}})) {
			my @values = @{$table->{$metric}->{$sub_metric}};
			my $title = "$metric - $sub_metric";
			if (!$self->{_titles}->{$title}) {
				die "!$title!\n";
			}
			$data[$row][$column] = "$self->{_titles}->{$title},";
			my $scaling_factor = 1; # Parse scaling factor from %titles value
			if ($self->{_titles}->{$title} =~ /\*(\d+\.?\d?\d?\d?\d?)/) {
				$scaling_factor = $1;
			}	
			#print Dumper(\@values);
			#die;
			foreach my $value (@values) {
				$row++;
				my $scaled_value = $value * $scaling_factor;
				$data[$row][$column] = "$scaled_value,";
			}
			$column++;
			$row = 0;
		}
	}
	return @data;
}
sub open_summary {
	my $self = shift;
	exec("notepad.exe $self->{_mcp_summary_file}");
}
1;
}