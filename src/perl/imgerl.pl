#!/usr/bin/perl -w
# Perl imgur uploader
use Getopt::Long;
use Pod::Usage;
use LWP::UserAgent;
use JSON;
use threads;
use threads::shared;
use Time::HiRes qw/usleep/;
use MIME::Base64;

my $version = '1.0';
my $api_url = 'http://api.imgur.com/2/upload.json';
my $api_key = 'cea84480cf3f38814b991094fb8be8ed';

my @exts      = ('png','jpg', 'gif');
my $verbose   = undef;
my $recursive = undef; 
my $newest    = 1;
my $oldest    = 0;
my $help      = 0;
my $file      = undef;

sub usage {
    open my $fh, '<', '/usr/share/doc/imgerl/documentation.pod';
    pod2usage(
	-exitval => 1,
	-input	 => $fh,
    );
}

sub scandir {
    return undef;
}

sub upload_file {
    # We need one argument, always
    return unless $_[0];

    # Turn buffering off for progress
    local $| = 1;

    my $ufile :shared = $_[0];
    my $finished :shared = 0;
    my $ua    =	 LWP::UserAgent->new;
    my $bufenc;
    open my $IMGF, '<', $_[0];
    binmode $IMGF;
    {
	my $buf;
	local $/ = undef;
	$buf = <$IMGF>;
	$bufenc = encode_base64($buf);
    }
    close $IMGF;

    # Let's show the user a progress bar..
    my $thr = async {
	my @progs = ('/', '-', '\\', '|');
	my $i = 0;
	my $message = 'uploading ' . $ufile . ' ';

	print $message;
	until ($finished) {
	    print $progs[$i++];
	    $i = 0 if $i == @progs;

	    usleep(50000);
	    print "\b";
	}

	print "... done\n";
    };

    my $resp = $ua->post($api_url, { key => $api_key, image =>
	$bufenc, type => 'base64', name => $_[0] });

    unless ($resp->is_success) {
	print "Failed to fetch\n";
	return;
    }

    my $json_data = from_json($resp->content);
    my %values = %{$json_data->{'upload'}{'links'}};

    # Tell progress to stop
    $finished = 1;
    $| = 0;
    $thr->join;

    print $values{'original'}, "\n";
    print "\n";
}

# Forbid the use without arguments
if ( scalar @ARGV < 1 ) {
    exit 1;
}

GetOptions (
    'help'	=> \$help,
    'verbose'	=> \$verbose,
    'recursive' => \$recursive,
    'newest+'	=> \$newest,
    'oldest+'	=> \$oldest
) || usage;

usage if $help;

# Now start reading arguments, quit when not file or dir
while (my $arg = shift @ARGV) {
    if (-d $arg) {
	my $found = scandir $arg;
	upload_file $found;
    }
    # -B might be better as pictures are always in binary format
    elsif (-f $arg) {
	upload_file $arg;
    }
    else {
	# Perhaps just exit, continue for now
	printf STDERR "%s is not a file or directory\nSkipping.\n\n", $arg;
	next;
    }
}
