#!/usr/bin/perl -w
# Perl imgur uploader
use Getopt::Long;
use Pod::Usage;
use LWP::UserAgent;
use JSON;
use MIME::Base64;

my $version = '1.0';
my $api_url = 'http://api.imgur.com/2/upload.json';
my $api_key = 'cea84480cf3f38814b991094fb8be8ed';
my $img_prefix = 'http://i.imgur.com/';

my @exts      = ('png','jpg', 'gif');
my $verbose   = undef;
my $recursive = undef; 
my $newest    = 1;
my $oldest    = 0;
my $help      = 0;
my $file      = undef;

sub usage {
    open my $fh, '<', 'documentation.pod';
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

    my $resp  =	 $ua->post($api_url, {
	key   => $api_key,
	image => $bufenc,
	type => 'base64',
	name => $_[0]
    });

    unless ($resp->is_success) {
	print "Failed to fetch\n";
	return;
    }

    my $json_data = from_json($resp->content);
    my %values = %{$json_data->{'upload'}{'links'}};

    print $values{'original'}, "\n";
    print "\n";
}

sub init_config {
    my $conf_file = 'settings.pl';
    return unless (-f $conf_file);

    open (my $CONF, '<', $conf_file);
    my $plconfig = join "", <$CONF>;
    close $CONF;
    eval $plconfig;
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

# Some configuration
init_config;

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
