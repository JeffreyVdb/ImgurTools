#!/usr/bin/perl -w
# Perl imgur uploader
use Getopt::Long;
use Pod::Usage;
use LWP::UserAgent;
# use JSON;

my $version = '1.0';
my $api_url = "http://imgur.com/api/upload.json";
my $api_key = "cea84480cf3f38814b991094fb8be8ed";

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
}

sub upload_file {
    my $ua    =	 LWP::UserAgent->new;
    my $resp  =	 $ua->post($api_url, {
	key   => api_key,
	image => $_[0]
    });

    if ($resp->is_success) {
	print $resp->content;
    }
    else {
	print 'Unsuccesful', "\n";
	print $resp->content;
    }
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
